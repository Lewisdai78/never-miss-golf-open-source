import Foundation

@MainActor
final class AppRouteStore: ObservableObject {
    static let shared = AppRouteStore()

    @Published var message: String?

    private init() {}
}

