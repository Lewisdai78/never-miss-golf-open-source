enum AppServices {
    static let courseStore = CourseStore()
    static let visitStateStore = VisitStateStore()
    static let notifications = NotificationCoordinator()
    static let courseMonitor = CourseMonitor(
        courseStore: courseStore,
        visitStateStore: visitStateStore,
        notifications: notifications
    )
}

