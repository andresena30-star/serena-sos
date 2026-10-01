//
//  Views.swift
//  SerenaSOS
//

import SwiftUI
import SwiftData
import StoreKit

// MARK: - Cores Semânticas Adaptativas

public extension Color {
    static let serenaSage = Color(red: 0.35, green: 0.51, blue: 0.34)
    static let serenaLavender = Color(red: 0.49, green: 0.55, blue: 0.77)
    static let serenaOcean = Color(red: 0.23, green: 0.35, blue: 0.47)
    static let serenaEmergency = Color(red: 0.75, green: 0.36, blue: 0.33)
}

// MARK: - Main Container

public struct MainAppContainerView: View {
    @State private var selectedTab: Int = 0
    @State private var breathingVM = SOSBreathingViewModel()
    @State private var showingEmergencySheet: Bool = false
    @State private var showingPaywallSheet: Bool = false

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            SOSHomeView(viewModel: breathingVM, showingEmergency: $showingEmergencySheet)
                .tabItem {
                    Label("SOS Alívio", systemImage: "lungs.fill")
                }
                .tag(0)

            GroundingGuideView()
                .tabItem {
                    Label("Ancoragem", systemImage: "hand.point.up.braille.fill")
                }
                .tag(1)

            HistoryAndJournalView(showingPaywall: $showingPaywallSheet)
                .tabItem {
                    Label("Meu Diário", systemImage: "heart.text.square.fill")
                }
                .tag(2)
        }
        .tint(.serenaLavender)
        .confirmationDialog(
            "Ajuda Médica e Apoio Emocional de Emergência",
            isPresented: $showingEmergencySheet,
            titleVisibility: .visible
        ) {
            Button("Ligar para Apoio Emocional (188 CVV - Brasil)") {
                if let url = URL(string: "tel://188") {
                    UIApplication.shared.open(url)
                }
            }
            Button("Ligar para Linha de Crise (988 - EUA)") {
                if let url = URL(string: "tel://988") {
                    UIApplication.shared.open(url)
                }
            }
            Button("Ligar SAMU / Ambulância (192)", role: .destructive) {
                if let url = URL(string: "tel://192") {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("O Serena SOS é uma ferramenta complementar de alívio e não substitui assistência médica profissional.")
        }
        .sheet(isPresented: $showingPaywallSheet) {
            PaywallView()
        }
    }
}

// MARK: - Tela 1: SOS One-Tap Breathing (Home)

public struct SOSHomeView: View {
    @Bindable var viewModel: SOSBreathingViewModel
    @Binding var showingEmergency: Bool

    public var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        viewModel.isRunning ? Color.serenaLavender.opacity(0.15) : Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 32) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Serena SOS")
                                .font(.system(.headline, design: .rounded))
                                .foregroundStyle(.primary)
                            Text("Extintor de Pânico & Taquicardia")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button {
                            showingEmergency = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "phone.down.waves.and.radiowaves")
                                    .font(.caption.weight(.bold))
                                Text("SOS 188")
                                    .font(.caption.weight(.bold))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.serenaEmergency.opacity(0.15))
                            .foregroundStyle(Color.serenaEmergency)
                            .clipShape(Capsule())
                        }
                        .sensoryFeedback(.warning, trigger: showingEmergency)
                    }
                    .padding(.horizontal)

                    Spacer()

                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color.serenaLavender.opacity(0.4), Color.clear],
                                        center: .center,
                                        startRadius: 40,
                                        endRadius: 160
                                    )
                                )
                                .frame(width: 320, height: 320)
                                .scaleEffect(viewModel.orbScale * 1.1)
                                .blur(radius: 20)

                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.serenaLavender, Color.serenaSage],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 220, height: 220)
                                .scaleEffect(viewModel.orbScale)
                                .shadow(color: Color.serenaLavender.opacity(0.5), radius: 25, x: 0, y: 10)
                                .overlay {
                                    VStack(spacing: 6) {
                                        Image(systemName: viewModel.isRunning ? "wind" : "play.fill")
                                            .font(.system(size: 38, weight: .light))
                                            .foregroundStyle(.white)

                                        if viewModel.isRunning {
                                            Text("\(viewModel.sessionDuration)s")
                                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                .foregroundStyle(.white.opacity(0.9))
                                        }
                                    }
                                }
                        }
                        .contentShape(Circle())
                        .onTapGesture {
                            viewModel.toggleSession()
                        }
                        .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.isRunning)

                        Text(viewModel.instructionText)
                            .font(.system(.title3, design: .rounded).weight(.medium))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                            .frame(height: 50)
                            .padding(.horizontal, 24)
                            .animation(.smooth(duration: 0.4), value: viewModel.instructionText)
                    }

                    Spacer()

                    VStack(spacing: 12) {
                        Picker("Técnica", selection: $viewModel.currentTechnique) {
                            ForEach(BreathingTechnique.allCases, id: \.self) { technique in
                                Text(technique.displayName).tag(technique)
                            }
                        }
                        .pickerStyle(.segmented)
                        .disabled(viewModel.isRunning)

                        Button {
                            viewModel.toggleSession()
                        } label: {
                            HStack {
                                Image(systemName: viewModel.isRunning ? "stop.fill" : "sparkles")
                                Text(viewModel.isRunning ? "Encerrar e Estabilizar" : "Iniciar Suspiro Fisiológico")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(viewModel.isRunning ? Color(.secondarySystemFill) : Color.serenaLavender)
                            .foregroundStyle(viewModel.isRunning ? Color.primary : Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .sensoryFeedback(.success, trigger: viewModel.isRunning)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            }
        }
    }
}

// MARK: - Tela 2: Ancoragem 5-4-3-2-1

public struct GroundingGuideView: View {
    @State private var currentStep: Int = 0

    private let steps: [(icon: String, count: String, label: String, hint: String)] = [
        ("eye.fill", "5", "Coisas que você pode ver", "Olhe ao redor: uma cor, um objeto, um reflexo na janela."),
        ("hand.raised.fill", "4", "Coisas que você pode tocar", "Sinta a textura da sua roupa, a sola do sapato no chão ou a água na mão."),
        ("ear.fill", "3", "Sons que você pode ouvir", "O som da respiração, o ar condicionado ou o trânsito distante."),
        ("nose.fill", "2", "Aromas que você pode sentir", "O cheiro do café, do sabonete ou apenas do ar puro."),
        ("mouth.fill", "1", "Gosto que você pode notar", "Sinta o gosto da água, bala de menta ou passe a língua nos dentes.")
    ]

    public var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                ProgressView(value: Double(currentStep + 1), total: Double(steps.count))
                    .tint(.serenaLavender)
                    .padding(.horizontal)

                Spacer()

                let step = steps[currentStep]

                VStack(spacing: 20) {
                    Text(step.count)
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.serenaLavender)

                    Image(systemName: step.icon)
                        .font(.system(size: 42))
                        .foregroundStyle(Color.serenaSage)

                    Text(step.label)
                        .font(.title2.weight(.bold))
                        .multilineTextAlignment(.center)

                    Text(step.hint)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal)

                Spacer()

                HStack(spacing: 16) {
                    if currentStep > 0 {
                        Button("Voltar") {
                            withAnimation(.spring()) { currentStep -= 1 }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Button(currentStep < steps.count - 1 ? "Próximo Sentido" : "Concluir Ancoragem") {
                        withAnimation(.spring()) {
                            if currentStep < steps.count - 1 {
                                currentStep += 1
                            } else {
                                currentStep = 0
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.serenaLavender)
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationTitle("Ancoragem 5-4-3-2-1")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Tela 3: Histórico e Serena Pro

public struct HistoryAndJournalView: View {
    @Binding var showingPaywall: Bool
    @State private var store = StoreKitManager.shared
    @State private var sessions: [MockSession] = [
        MockSession(date: Date().addingTimeInterval(-3600 * 2), duration: 180, technique: "Suspiro Fisiológico", bpmReduced: 14),
        MockSession(date: Date().addingTimeInterval(-3600 * 26), duration: 240, technique: "Respiração Quadrada", bpmReduced: 18)
    ]

    public var body: some View {
        NavigationStack {
            List {
                if !store.isProUser {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Plano Serena Pro", systemImage: "sparkles")
                                    .font(.headline)
                                    .foregroundStyle(Color.serenaLavender)
                                Spacer()
                                Text("DESBLOQUEAR")
                                    .font(.caption2.weight(.bold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.serenaLavender.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                            Text("Acompanhe seus dados de frequência cardíaca via Apple HealthKit e mapeie seus gatilhos.")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Button("Ver Benefícios & Teste Grátis") {
                                showingPaywall = true
                            }
                            .font(.footnote.weight(.bold))
                            .foregroundStyle(Color.serenaLavender)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Sessões de Alívio Recentes") {
                    if sessions.isEmpty {
                        ContentUnavailableView(
                            "Nenhum Registro Salvo",
                            systemImage: "heart.slash",
                            description: Text("Suas sessões de respiração e alívio serão registradas aqui automaticamente.")
                        )
                    } else {
                        ForEach(sessions) { session in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(session.technique)
                                        .font(.subheadline.weight(.semibold))
                                    Text(session.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(session.duration)s")
                                        .font(.caption.weight(.bold))
                                    Text("-\(session.bpmReduced) BPM")
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(Color.serenaSage)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Meu Diário")
        }
    }
}

public struct MockSession: Identifiable {
    public let id = UUID()
    public let date: Date
    public let duration: Int
    public let technique: String
    public let bpmReduced: Int
}

// MARK: - Tela 4: PaywallView (StoreKit 2 Compliance)

public struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var store = StoreKitManager.shared
    @State private var selectedProduct: Product? = nil
    @State private var isProcessing: Bool = false

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 48))
                            .foregroundStyle(LinearGradient(colors: [Color.accentColor, Color.purple], startPoint: .top, endPoint: .bottom))

                        Text("Serena Pro")
                            .font(.system(size: 32, weight: .bold, design: .rounded))

                        Text("Sua rotina completa de prevenção contra ansiedade e regulação do sistema nervoso.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 16) {
                        benefitRow(icon: "heart.text.square.fill", title: "Biometria Apple HealthKit", subtitle: "Acompanhe a redução dos batimentos cardíacos após cada crise.")
                        benefitRow(icon: "waveform.path.badge.plus", title: "Todos os Padrões Hápticos", subtitle: "Desbloqueie Box Breathing, 4-7-8 e sons binaurais imersivos.")
                        benefitRow(icon: "chart.line.uptrend.xyaxis", title: "Mapa Somático de Gatilhos", subtitle: "Entenda em quais dias e horários sua ansiedade costuma se manifestar.")
                        benefitRow(icon: "lock.shield.fill", title: "Privacidade e Backup Seguro", subtitle: "Sincronização 100% criptografada entre seus dispositivos Apple.")
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .padding(.horizontal)

                    VStack(spacing: 12) {
                        ForEach(store.products, id: \.id) { product in
                            productCard(product)
                        }
                    }
                    .padding(.horizontal)

                    Button {
                        if let product = selectedProduct ?? store.products.first {
                            Task {
                                isProcessing = true
                                _ = try? await store.purchase(product)
                                isProcessing = false
                                if store.isProUser {
                                    dismiss()
                                }
                            }
                        }
                    } label: {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(selectedProduct?.id.contains("annual") == true ? "Testar 7 Dias Grátis" : "Continuar com Serena Pro")
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(isProcessing)
                    .padding(.horizontal)

                    VStack(spacing: 8) {
                        Button("Restaurar Compras Anteriores") {
                            Task {
                                await store.restorePurchases()
                                if store.isProUser { dismiss() }
                            }
                        }
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)

                        HStack(spacing: 16) {
                            Link("Termos de Uso (EULA)", destination: URL(string: "https://pnrt.studio/legal/terms")!)
                            Text("•")
                            Link("Política de Privacidade", destination: URL(string: "https://pnrt.studio/legal/privacy")!)
                        }
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    }
                    .padding(.bottom, 24)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                    }
                }
            }
            .onAppear {
                if selectedProduct == nil {
                    selectedProduct = store.products.first(where: { $0.id.contains("annual") })
                }
            }
        }
    }

    @ViewBuilder
    private func benefitRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private func productCard(_ product: Product) -> some View {
        let isSelected = (selectedProduct?.id == product.id)
        let isAnnual = product.id.contains("annual")

        Button {
            selectedProduct = product
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(product.displayName)
                            .font(.headline)
                        if isAnnual {
                            Text("MAIS POPULAR")
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }
                    Text(product.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(product.displayPrice)
                    .font(.title3.weight(.bold))
            }
            .padding()
            .background(isSelected ? Color.accentColor.opacity(0.12) : Color(.tertiarySystemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
