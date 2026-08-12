import UserNotifications
import WatchKit

final class WatchAppDelegate: NSObject, WKApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        Self.registerNotificationCategory()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        guard response.actionIdentifier == NotificationContract.openWorkoutAction else {
            completionHandler()
            return
        }

        Task { @MainActor in
            await WorkoutOpener.shared.openGolf()
            completionHandler()
        }
    }

    static func registerNotificationCategory() {
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
}
