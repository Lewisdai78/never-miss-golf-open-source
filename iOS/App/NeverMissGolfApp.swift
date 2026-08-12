import SwiftUI

@main
struct NeverMissGolfApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = AppViewModel()
    @StateObject private var routeStore = AppRouteStore.shared
    @StateObject private var languageSettings = LanguageSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .environmentObject(routeStore)
                .environmentObject(languageSettings)
                .environment(\.locale, appLocale)
                .task {
                    await model.start()
                }
        }
    }

    private var appLocale: Locale {
        guard let identifier = languageSettings.selectedLanguage.localeIdentifier else {
            return .autoupdatingCurrent
        }
        return Locale(identifier: identifier)
    }
}
