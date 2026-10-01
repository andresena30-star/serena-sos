import Foundation
import SwiftData

@Model
public final class ReliefSession {
    @Attribute(.unique) public var id: UUID
    public var timestamp: Date
    public var durationSeconds: Int
    public var techniqueRaw: String
    public var preHeartRate: Double?
    public var postHeartRate: Double?
    public var triggerTag: String?
    public var notes: String?

    public var technique: BreathingTechnique {
        get { BreathingTechnique(rawValue: techniqueRaw) ?? .physiologicalSigh }
        set { techniqueRaw = newValue.rawValue }
    }

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        durationSeconds: Int,
        technique: BreathingTechnique = .physiologicalSigh,
        preHeartRate: Double? = nil,
        postHeartRate: Double? = nil,
        triggerTag: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.durationSeconds = durationSeconds
        self.techniqueRaw = technique.rawValue
        self.preHeartRate = preHeartRate
        self.postHeartRate = postHeartRate
        self.triggerTag = triggerTag
        self.notes = notes
    }
}

public enum BreathingTechnique: String, CaseIterable, Sendable, Codable {
    case physiologicalSigh = "physiological_sigh"
    case boxBreathing       = "box_breathing"
    case deepRelaxation    = "deep_relaxation"

    public var displayName: String {
        switch self {
        case .physiologicalSigh: return "Suspiro Fisiológico (SOS)"
        case .boxBreathing:       return "Respiração Quadrada (Foco)"
        case .deepRelaxation:    return "Relaxamento Profundo (4-7-8)"
        }
    }
}

public enum BreathingPhase: Sendable {
    case inhale
    case inhaleSecond
    case hold
    case exhale
}
