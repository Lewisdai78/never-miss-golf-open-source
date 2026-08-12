import Foundation

enum NotificationContract {
    static let reminderCategory = "GOLF_REMINDER"
    static let openWorkoutAction = "OPEN_APPLE_WORKOUT"
    static let notTodayAction = "NOT_TODAY"
    static let snoozeAction = "SNOOZE_TEN_MINUTES"
    static let courseIDKey = "course_id"

    enum RequestKind: String {
        case dwell
        case snooze
        case test
    }

    static func requestIdentifier(kind: RequestKind, courseID: UUID) -> String {
        "golf-reminder.\(kind.rawValue).\(courseID.uuidString)"
    }
}

