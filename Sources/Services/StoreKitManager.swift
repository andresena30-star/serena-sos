import Foundation
import StoreKit

@Observable
@MainActor
public final class StoreKitManager: Sendable {
    public static let shared = StoreKitManager()

    public private(set) var products: [Product] = []
    public private(set) var purchasedProductIDs = Set<String>()
    public private(set) var isProUser: Bool = false
    public private(set) var isLoading: Bool = false
    public var errorMessage: String? = nil

    private let productIDs = [
        "com.pnrt.serenasos.annual",
        "com.pnrt.serenasos.monthly"
    ]

    private var transactionListener: Task<Void, Error>? = nil

    private init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    public func stop() {
        transactionListener?.cancel()
        transactionListener = nil
    }

    public func loadProducts() async {
        isLoading = true
        errorMessage = nil
        do {
            let loadedProducts = try await Product.products(for: productIDs)
            self.products = loadedProducts.sorted(by: { $0.price > $1.price })
            self.isLoading = false
        } catch {
            self.errorMessage = "Falha ao carregar ofertas da App Store: \(error.localizedDescription)"
            self.isLoading = false
        }
    }

    public func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updatePurchasedProducts()
            return true

        case .userCancelled:
            return false

        case .pending:
            return false

        @unknown default:
            return false
        }
    }

    public func restorePurchases() async {
        isLoading = true
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            self.isLoading = false
        } catch {
            self.errorMessage = "Não foi possível restaurar compras: \(error.localizedDescription)"
            self.isLoading = false
        }
    }

    public func updatePurchasedProducts() async {
        var activeIDs = Set<String>()

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.revocationDate == nil {
                    activeIDs.insert(transaction.productID)
                }
            } catch {
                continue
            }
        }

        self.purchasedProductIDs = activeIDs
        self.isProUser = !activeIDs.isEmpty
    }

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                } catch {
                    continue
                }
            }
        }
    }

    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
}
