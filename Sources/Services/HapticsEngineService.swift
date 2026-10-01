import CoreHaptics
import Foundation

public actor HapticsEngineService {
    private var engine: CHHapticEngine?
    private var isSupported: Bool = false

    public init() {
        self.isSupported = CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    public func startEngine() async throws {
        guard isSupported else { return }
        engine = try CHHapticEngine()
        try await engine?.start()
    }

    public func playInhaleRamp(duration: Double) async throws {
        guard isSupported, let engine = engine else { return }

        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [intensity, sharpness],
            relativeTime: 0,
            duration: duration
        )

        let pattern = try CHHapticPattern(events: [event], parameters: [])
        let player = try engine.makePlayer(with: pattern)
        try player.start(atTime: CHHapticTimeImmediate)
    }

    public func playExhaleSoft(duration: Double) async throws {
        guard isSupported, let engine = engine else { return }

        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [intensity, sharpness],
            relativeTime: 0,
            duration: duration
        )

        let pattern = try CHHapticPattern(events: [event], parameters: [])
        let player = try engine.makePlayer(with: pattern)
        try player.start(atTime: CHHapticTimeImmediate)
    }
}
