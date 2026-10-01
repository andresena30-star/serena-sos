import CoreHaptics
import Foundation

@MainActor
public final class HapticsEngineService: Sendable {
    private var engine: CHHapticEngine?
    private var isSupported: Bool = false

    public init() {
        self.isSupported = CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    public func startEngine() {
        guard isSupported else { return }
        do {
            let newEngine = try CHHapticEngine()
            try newEngine.start()
            self.engine = newEngine
        } catch {
            self.engine = nil
        }
    }

    public func playInhaleRamp(duration: Double) {
        guard isSupported, let engine = engine else { return }

        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [intensity, sharpness],
            relativeTime: 0,
            duration: duration
        )

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            // Falha graciosa sem travar a UI
        }
    }

    public func playExhaleSoft(duration: Double) {
        guard isSupported, let engine = engine else { return }

        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [intensity, sharpness],
            relativeTime: 0,
            duration: duration
        )

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            // Falha graciosa sem travar a UI
        }
    }
}
