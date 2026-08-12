import Foundation

actor VisitStateStore {
    private let defaults: UserDefaults
    private let storageKey = "never-miss-golf.visit-states"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func state(for courseID: UUID) -> VisitState {
        load()[courseID.uuidString].flatMap(VisitState.init(rawValue:)) ?? .armedOutside
    }

    func set(_ state: VisitState, for courseID: UUID) {
        var states = load()
        states[courseID.uuidString] = state.rawValue
        defaults.set(states, forKey: storageKey)
    }

    func remove(courseID: UUID) {
        var states = load()
        states.removeValue(forKey: courseID.uuidString)
        defaults.set(states, forKey: storageKey)
    }

    func deleteAll() {
        defaults.removeObject(forKey: storageKey)
    }

    private func load() -> [String: String] {
        defaults.dictionary(forKey: storageKey) as? [String: String] ?? [:]
    }
}

