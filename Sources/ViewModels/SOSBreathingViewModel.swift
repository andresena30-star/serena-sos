import SwiftUI
import SwiftData

@Observable
@MainActor
public final class SOSBreathingViewModel {
    public var isRunning: Bool = false
    public var currentTechnique: BreathingTechnique = .physiologicalSigh
    public var currentPhase: BreathingPhase = .inhale
    public var orbScale: CGFloat = 1.0
    public var instructionText: String = "Toque para respirar"
    public var sessionDuration: Int = 0

    private let hapticsService = HapticsEngineService()
    private var timerTask: Task<Void, Never>?

    public init() {
        hapticsService.startEngine()
    }

    public func toggleSession() {
        if isRunning {
            stopSession()
        } else {
            startSession()
        }
    }

    public func startSession() {
        isRunning = true
        sessionDuration = 0
        runBreathingLoop()
    }

    public func stopSession() {
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            orbScale = 1.0
            instructionText = "Sessão concluída. Respire no seu ritmo."
        }
    }

    private func runBreathingLoop() {
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self = self, self.isRunning else { break }

                // 1. Inalação Inicial
                self.currentPhase = .inhale
                self.instructionText = "Inale profundamente pelo nariz..."
                withAnimation(.easeInOut(duration: 3.0)) { self.orbScale = 1.6 }
                self.hapticsService.playInhaleRamp(duration: 3.0)
                try? await Task.sleep(for: .seconds(3.0))
                guard !Task.isCancelled else { break }

                // Inalação dupla (Suspiro Fisiológico)
                if self.currentTechnique == .physiologicalSigh {
                    self.currentPhase = .inhaleSecond
                    self.instructionText = "Puxe mais um pouco de ar..."
                    withAnimation(.easeInOut(duration: 1.0)) { self.orbScale = 1.8 }
                    try? await Task.sleep(for: .seconds(1.0))
                    guard !Task.isCancelled else { break }
                }

                // 2. Retenção
                self.currentPhase = .hold
                self.instructionText = "Segure..."
                try? await Task.sleep(for: .seconds(1.5))
                guard !Task.isCancelled else { break }

                // 3. Exalação Longa
                self.currentPhase = .exhale
                self.instructionText = "Solte devagar pela boca..."
                withAnimation(.easeInOut(duration: 7.0)) { self.orbScale = 1.0 }
                self.hapticsService.playExhaleSoft(duration: 7.0)
                try? await Task.sleep(for: .seconds(7.0))

                self.sessionDuration += 13
            }
        }
    }
}
