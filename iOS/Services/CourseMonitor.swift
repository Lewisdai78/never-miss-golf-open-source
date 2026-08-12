import CoreLocation
import Foundation
import OSLog

actor CourseMonitor {
    private static let monitorName = "NeverMissGolfCourses"

    private let courseStore: CourseStore
    private let visitStateStore: VisitStateStore
    private let notifications: NotificationCoordinator
    private let logger = Logger(subsystem: "org.nevermissgolf.NeverMissGolf", category: "CourseMonitor")

    private var monitor: CLMonitor?
    private var eventTask: Task<Void, Never>?

    init(
        courseStore: CourseStore,
        visitStateStore: VisitStateStore,
        notifications: NotificationCoordinator
    ) {
        self.courseStore = courseStore
        self.visitStateStore = visitStateStore
        self.notifications = notifications
    }

    func start() async {
        if eventTask != nil {
            await syncConditions()
            return
        }

        let monitor = await CLMonitor(Self.monitorName)
        self.monitor = monitor
        await syncConditions()

        eventTask = Task { [weak self] in
            do {
                for try await event in await monitor.events {
                    await self?.handle(event)
                }
            } catch {
                await self?.logStreamFailure(error)
            }
        }
    }

    func syncConditions() async {
        guard let monitor else { return }

        let courses = await courseStore.all()
        let expectedIdentifiers = Set(courses.map(\.monitorIdentifier))
        let existingIdentifiers = Set(await monitor.identifiers)

        for identifier in existingIdentifiers.subtracting(expectedIdentifiers) {
            await monitor.remove(identifier)
        }

        for course in courses {
            let center = CLLocationCoordinate2D(
                latitude: course.latitude,
                longitude: course.longitude
            )
            let condition = CLMonitor.CircularGeographicCondition(
                center: center,
                radius: course.radiusMeters
            )
            await monitor.add(condition, identifier: course.monitorIdentifier)
        }
    }

    func removeCondition(for course: SavedCourse) async {
        if let monitor {
            await monitor.remove(course.monitorIdentifier)
        }
        await notifications.cancelReminders(for: course.id)
        await visitStateStore.remove(courseID: course.id)
    }

    func removeAllConditions() async {
        if let monitor {
            for identifier in await monitor.identifiers {
                await monitor.remove(identifier)
            }
        }
        await notifications.cancelAll()
        await visitStateStore.deleteAll()
    }

    private func handle(_ event: CLMonitor.Event) async {
        let courses = await courseStore.all()
        guard let course = courses.first(where: { $0.monitorIdentifier == event.identifier }) else {
            logger.notice("Ignoring an event for an unknown course identifier")
            return
        }

        if event.state == .satisfied {
            await handleEntry(for: course)
        } else if event.state == .unsatisfied {
            await handleExit(for: course)
        } else {
            await visitStateStore.set(.needsRecheck, for: course.id)
            logger.notice("Course condition is currently unknown")
        }
    }

    private func handleEntry(for course: SavedCourse) async {
        let state = await visitStateStore.state(for: course.id)
        let transition = ReminderReducer.reduce(state: state, event: .entered)
        await visitStateStore.set(transition.state, for: course.id)

        guard transition.command == .scheduleDwell else { return }

        do {
            try await notifications.scheduleDwellReminder(for: course)
            logger.notice("Scheduled a dwell reminder for a saved course")
        } catch {
            logger.error("Unable to schedule dwell reminder: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func handleExit(for course: SavedCourse) async {
        let state = await visitStateStore.state(for: course.id)
        let transition = ReminderReducer.reduce(state: state, event: .exited)
        await visitStateStore.set(transition.state, for: course.id)
        await notifications.cancelReminders(for: course.id)
        logger.notice("Cancelled reminders after leaving a saved course")
    }

    private func logStreamFailure(_ error: Error) {
        logger.error("CLMonitor event stream failed: \(error.localizedDescription, privacy: .public)")
        eventTask = nil
    }
}
