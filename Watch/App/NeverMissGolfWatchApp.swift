import SwiftUI

@main
struct NeverMissGolfWatchApp: App {
    @WKApplicationDelegateAdaptor(WatchAppDelegate.self) private var appDelegate
    @StateObject private var opener = WorkoutOpener.shared
    @StateObject private var languageSettings = LanguageSettings()

    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environmentObject(opener)
                .environmentObject(languageSettings)
                .environment(\.locale, appLocale)
        }
    }

    private var appLocale: Locale {
        guard let identifier = languageSettings.selectedLanguage.localeIdentifier else {
            return .autoupdatingCurrent
        }
        return Locale(identifier: identifier)
    }
}
