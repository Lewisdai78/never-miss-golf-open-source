import Foundation

struct SavedCourse: Codable, Hashable, Identifiable, Sendable {
    let id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var radiusMeters: Double
    let createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        latitude: Double,
        longitude: Double,
        radiusMeters: Double,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.radiusMeters = radiusMeters
        self.createdAt = createdAt
    }

    var monitorIdentifier: String {
        "course" + id.uuidString.replacingOccurrences(of: "-", with: "")
    }
}

