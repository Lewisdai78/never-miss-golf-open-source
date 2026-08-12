import Foundation

actor CourseStore {
    enum StoreError: LocalizedError {
        case courseLimitReached

        var errorDescription: String? {
            switch self {
            case .courseLimitReached:
                return L10n.string("error.course_limit")
            }
        }
    }

    private let defaults: UserDefaults
    private let storageKey = "never-miss-golf.saved-courses"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func all() -> [SavedCourse] {
        guard
            let data = defaults.data(forKey: storageKey),
            let courses = try? JSONDecoder().decode([SavedCourse].self, from: data)
        else {
            return []
        }

        return courses.sorted { $0.createdAt < $1.createdAt }
    }

    func course(id: UUID) -> SavedCourse? {
        all().first { $0.id == id }
    }

    func upsert(_ course: SavedCourse) throws {
        var courses = all()

        if let index = courses.firstIndex(where: { $0.id == course.id }) {
            courses[index] = course
        } else {
            guard courses.count < PrototypeConfiguration.maximumCourses else {
                throw StoreError.courseLimitReached
            }
            courses.append(course)
        }

        try persist(courses)
    }

    func delete(id: UUID) throws {
        try persist(all().filter { $0.id != id })
    }

    func deleteAll() {
        defaults.removeObject(forKey: storageKey)
    }

    private func persist(_ courses: [SavedCourse]) throws {
        defaults.set(try JSONEncoder().encode(courses), forKey: storageKey)
    }
}
