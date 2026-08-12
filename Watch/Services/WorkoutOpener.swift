import HealthKit
import SwiftUI
import WorkoutKit

@MainActor
final class WorkoutOpener: ObservableObject {
    enum Status: Equatable {
        case ready
        case opening
        case opened
        case failed(String)
    }

    static let shared = WorkoutOpener()

    @Published private(set) var status: Status = .ready

    private init() {}

    func openGolf() async {
        guard status != .opening else { return }
        status = .opening

        let golf = SingleGoalWorkout(
            activity: .golf,
            location: .outdoor,
            goal: .open
        )
        let plan = WorkoutPlan(.goal(golf))

        do {
            try await plan.openInWorkoutApp()
            status = .opened
        } catch {
            status = .failed(error.localizedDescription)
        }
    }

    func reset() {
        status = .ready
    }
}

