import Foundation
import UserNotifications

actor NotificationCoordinator {
    static func registerCategories() {
        let openWorkout = UNNotificationAction(
            identifier: NotificationContract.openWorkoutAction,
            title: L10n.string("action.open_workout"),
            options: [.foreground]
        )
        let notToday = UNNotificationAction(
            identifier: NotificationContract.notTodayAction,
            title: L10n.string("action.not_today"),
            options: []
        )
        let snooze = UNNotificationAction(
            identifier: NotificationContract.snoozeAction,
            title: L10n.string("action.snooze_ten_minutes"),
            options: []
        )
        let category = UNNotificationCategory(
            identifier: NotificationContract.reminderCategory,
            actions: [openWorkout, notToday, snooze],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
    }

    func scheduleDwellReminder(for course: SavedCourse) async throws {
        try await schedule(
            for: course,
            kind: .dwell,
            delay: PrototypeConfiguration.dwellDelay
        )
    }

    func scheduleSnooze(for course: SavedCourse) async throws {
        try await schedule(
            for: course,
            kind: .snooze,
            delay: PrototypeConfiguration.snoozeDelay
        )
    }

    func scheduleTestReminder(for course: SavedCourse) async throws {
        try await schedule(
            for: course,
            kind: .test,
            delay: PrototypeConfiguration.testNotificationDelay
        )
    }

    func cancelReminders(for courseID: UUID) {
        let center = UNUserNotificationCenter.current()
        let identifiers = [
            NotificationContract.requestIdentifier(kind: .dwell, courseID: courseID),
            NotificationContract.requestIdentifier(kind: .snooze, courseID: courseID),
            NotificationContract.requestIdentifier(kind: .test, courseID: courseID)
        ]
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    func cancelAll() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }

    private func schedule(
        for course: SavedCourse,
        kind: NotificationContract.RequestKind,
        delay: TimeInterval
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = L10n.string("notification.title")
        content.body = L10n.string("notification.body")
        content.sound = .default
        content.categoryIdentifier = NotificationContract.reminderCategory
        content.userInfo = [NotificationContract.courseIDKey: course.id.uuidString]

        let request = UNNotificationRequest(
            identifier: NotificationContract.requestIdentifier(kind: kind, courseID: course.id),
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        )

        try await UNUserNotificationCenter.current().add(request)
    }
}
