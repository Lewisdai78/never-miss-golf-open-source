import CoreLocation
import Foundation
import UserNotifications

@MainActor
final class AppViewModel: NSObject, ObservableObject, @preconcurrency CLLocationManagerDelegate {
    enum LocationError: LocalizedError {
        case permissionRequired
        case requestAlreadyActive
        case noLocation

        var errorDescription: String? {
            switch self {
            case .permissionRequired:
                return L10n.string("error.location_permission_required")
            case .requestAlreadyActive:
                return L10n.string("error.location_request_active")
            case .noLocation:
                return L10n.string("error.no_location")
            }
        }
    }

    @Published private(set) var courses: [SavedCourse] = []
    @Published private(set) var locationAuthorization: CLAuthorizationStatus
    @Published private(set) var notificationAuthorization: UNAuthorizationStatus = .notDetermined
    @Published var isBusy = false
    @Published var showingError = false
    @Published var errorMessage = ""

    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    override init() {
        locationAuthorization = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    var canAddCourse: Bool {
        courses.count < PrototypeConfiguration.maximumCourses
            && (locationAuthorization == .authorizedWhenInUse
                || locationAuthorization == .authorizedAlways)
    }

    var locationStatusText: String {
        switch locationAuthorization {
        case .authorizedAlways:
            return L10n.string("status.location.always")
        case .authorizedWhenInUse:
            return L10n.string("status.location.when_in_use")
        case .denied:
            return L10n.string("status.location.denied")
        case .restricted:
            return L10n.string("status.location.restricted")
        case .notDetermined:
            return L10n.string("status.location.not_determined")
        @unknown default:
            return L10n.string("status.location.unknown")
        }
    }

    var notificationStatusText: String {
        switch notificationAuthorization {
        case .authorized:
            return L10n.string("status.notification.authorized")
        case .provisional:
            return L10n.string("status.notification.provisional")
        case .ephemeral:
            return L10n.string("status.notification.ephemeral")
        case .denied:
            return L10n.string("status.notification.denied")
        case .notDetermined:
            return L10n.string("status.notification.not_determined")
        @unknown default:
            return L10n.string("status.notification.unknown")
        }
    }

    func start() async {
        await reload()
        await AppServices.courseMonitor.start()
    }

    func requestWhenInUseLocation() {
        locationManager.requestWhenInUseAuthorization()
    }

    func requestAlwaysLocation() {
        guard locationAuthorization == .authorizedWhenInUse else {
            present(error: LocationError.permissionRequired)
            return
        }
        locationManager.requestAlwaysAuthorization()
    }

    func requestNotifications() async {
        do {
            _ = try await AppServices.notifications.requestAuthorization()
            await refreshNotificationAuthorization()
        } catch {
            present(error: error)
        }
    }

    func addCourse(name: String, radiusMeters: Double) async -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            present(message: L10n.string("error.course_name_required"))
            return false
        }

        isBusy = true
        defer { isBusy = false }

        do {
            let coordinate = try await requestCurrentCoordinate()
            let course = SavedCourse(
                name: trimmedName,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                radiusMeters: radiusMeters
            )
            try await AppServices.courseStore.upsert(course)
            await reload()
            await AppServices.courseMonitor.syncConditions()
            return true
        } catch {
            present(error: error)
            return false
        }
    }

    func deleteCourse(_ course: SavedCourse) async {
        do {
            try await AppServices.courseStore.delete(id: course.id)
            await AppServices.courseMonitor.removeCondition(for: course)
            await reload()
        } catch {
            present(error: error)
        }
    }

    func sendTestReminder() async {
        guard let course = courses.first else {
            present(message: L10n.string("error.save_course_before_test"))
            return
        }

        do {
            try await AppServices.notifications.scheduleTestReminder(for: course)
        } catch {
            present(error: error)
        }
    }

    func deleteAllLocalData() async {
        await AppServices.courseMonitor.removeAllConditions()
        await AppServices.courseStore.deleteAll()
        await reload()
    }

    func reload() async {
        courses = await AppServices.courseStore.all()
        locationAuthorization = locationManager.authorizationStatus
        await refreshNotificationAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationAuthorization = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else {
            locationContinuation?.resume(throwing: LocationError.noLocation)
            locationContinuation = nil
            return
        }

        locationContinuation?.resume(returning: coordinate)
        locationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }

    private func requestCurrentCoordinate() async throws -> CLLocationCoordinate2D {
        guard locationAuthorization == .authorizedWhenInUse
                || locationAuthorization == .authorizedAlways else {
            throw LocationError.permissionRequired
        }
        guard locationContinuation == nil else {
            throw LocationError.requestAlreadyActive
        }

        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            locationManager.requestLocation()
        }
    }

    private func refreshNotificationAuthorization() async {
        notificationAuthorization = await UNUserNotificationCenter.current()
            .notificationSettings().authorizationStatus
    }

    private func present(error: Error) {
        present(message: error.localizedDescription)
    }

    private func present(message: String) {
        errorMessage = message
        showingError = true
    }
}
