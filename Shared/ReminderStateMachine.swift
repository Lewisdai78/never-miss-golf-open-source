import Foundation

enum VisitState: String, Codable, Equatable, Sendable {
    case armedOutside
    case dwellPending
    case prompted
    case suppressedThisVisit
    case snoozed
    case workoutOpenRequested
    case awaitingUserStart
    case manualOpenRequired
    case needsRecheck
}

enum ReminderEvent: Equatable, Sendable {
    case entered
    case exited
    case reminderDelivered
    case notToday
    case snooze
    case openWorkout
    case workoutOpened
    case workoutOpenFailed
    case conditionUnknown
}

enum ReminderCommand: Equatable, Sendable {
    case none
    case scheduleDwell
    case cancelReminders
    case scheduleSnooze
    case requestWorkoutOpen
}

struct ReminderTransition: Equatable, Sendable {
    let state: VisitState
    let command: ReminderCommand
}

enum ReminderReducer {
    static func reduce(state: VisitState, event: ReminderEvent) -> ReminderTransition {
        switch event {
        case .entered:
            guard state != .suppressedThisVisit, state != .dwellPending else {
                return .init(state: state, command: .none)
            }
            return .init(state: .dwellPending, command: .scheduleDwell)

        case .exited:
            return .init(state: .armedOutside, command: .cancelReminders)

        case .reminderDelivered:
            guard state == .dwellPending || state == .snoozed else {
                return .init(state: state, command: .none)
            }
            return .init(state: .prompted, command: .none)

        case .notToday:
            return .init(state: .suppressedThisVisit, command: .cancelReminders)

        case .snooze:
            return .init(state: .snoozed, command: .scheduleSnooze)

        case .openWorkout:
            return .init(state: .workoutOpenRequested, command: .requestWorkoutOpen)

        case .workoutOpened:
            return .init(state: .awaitingUserStart, command: .none)

        case .workoutOpenFailed:
            return .init(state: .manualOpenRequired, command: .none)

        case .conditionUnknown:
            return .init(state: .needsRecheck, command: .none)
        }
    }
}

