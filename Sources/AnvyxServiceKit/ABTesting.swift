//
//  ABTesting.swift
//  AppServices
//
//  Created by AnhPT on 13/07/2026.
//

/// A deterministic A/B experiment. Assigns a **stable** variant per participant by
/// hashing the experiment name with the participant id, so the same user always
/// sees the same variant across launches — and the split is reproducible without
/// storing per-user assignments.
///
/// ```swift
/// enum Checkout: String, CaseIterable, Sendable { case control, oneTap }
/// let experiment = Experiment<Checkout>(name: "checkout_flow")
/// switch experiment.variant(for: installID) { case .control: …; case .oneTap: … }
/// ```
public struct Experiment<Variant: RawRepresentable & CaseIterable & Sendable>: Sendable
where Variant.RawValue == String {
    public let name: String

    public init(name: String) {
        self.name = name
    }

    /// The variant assigned to `participant`, split evenly across all cases.
    public func variant(for participant: String) -> Variant {
        let variants = Array(Variant.allCases)
        guard !variants.isEmpty else {
            preconditionFailure("Experiment variant enum must have at least one case")
        }
        return variants[Self.stableBucket("\(name):\(participant)", modulo: variants.count)]
    }

    /// FNV-1a 64-bit hash → bucket. Deterministic across processes (unlike the
    /// standard-library `Hasher`, which is per-process randomized).
    static func stableBucket(_ input: String, modulo: Int) -> Int {
        guard modulo > 1 else { return 0 }
        var hash: UInt64 = 0xcbf2_9ce4_8422_2325
        for byte in input.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x0000_0100_0000_01b3
        }
        return Int(hash % UInt64(modulo))
    }
}

public extension FeatureFlagProvider {
    /// Resolve an experiment variant, letting a feature flag **override** the
    /// deterministic assignment. Set the flag `"<name>_variant"` to a variant's
    /// raw value (e.g. for QA or a staged rollout) to force it; otherwise fall
    /// back to the sticky assignment for `participant`.
    func variant<V>(for experiment: Experiment<V>, participant: String) -> V
    where V: RawRepresentable & CaseIterable & Sendable, V.RawValue == String {
        let forced = string("\(experiment.name)_variant", default: "")
        return V(rawValue: forced) ?? experiment.variant(for: participant)
    }
}
