import UIKit
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        NotificationCoordinator.registerCategories()

        Task {
            await AppServices.courseMonitor.start()
        }

        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        guard
            let rawCourseID = response.notification.request.content
                .userInfo[NotificationContract.courseIDKey] as? String,
            let courseID = UUID(uuidString: rawCourseID)
        else {
            completionHandler()
            return
        }

        Task {
            switch response.actionIdentifier {
            case NotificationContract.notTodayAction:
                await AppServices.visitStateStore.set(.suppressedThisVisit, for: courseID)
                await AppServices.notifications.cancelReminders(for: courseID)

            case NotificationContract.snoozeAction:
                if let course = await AppServices.courseStore.course(id: courseID) {
                    await AppServices.visitStateStore.set(.snoozed, for: courseID)
                    try? await AppServices.notifications.scheduleSnooze(for: course)
                }

            case NotificationContract.openWorkoutAction:
                await MainActor.run {
                    AppRouteStore.shared.message = L10n.string("route.open_watch")
                }

            default:
                break
            }

            completionHandler()
        }
    }
}
