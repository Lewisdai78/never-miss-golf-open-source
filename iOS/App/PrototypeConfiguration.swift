import Foundation

enum PrototypeConfiguration {
    #if DEBUG
    static let dwellDelay: TimeInterval = 60
    #else
    static let dwellDelay: TimeInterval = 10 * 60
    #endif

    static let snoozeDelay: TimeInterval = 10 * 60
    static let testNotificationDelay: TimeInterval = 3
    static let maximumCourses = 3
}

