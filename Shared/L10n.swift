import Combine
import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case english = "en"
    case simplifiedChinese = "zh-Hans"

    static let storageKey = "never-miss-golf.app-language"

    var id: String { rawValue }

    var displayNameKey: LocalizedStringKey {
        switch self {
        case .system:
            return "language.system"
        case .english:
            return "language.english"
        case .simplifiedChinese:
            return "language.simplified_chinese"
        }
    }

    var displayName: String {
        switch self {
        case .system:
            return L10n.string("language.system")
        case .english:
            return L10n.string("language.english")
        case .simplifiedChinese:
            return L10n.string("language.simplified_chinese")
        }
    }

    var localeIdentifier: String? {
        switch self {
        case .system:
            return nil
        case .english, .simplifiedChinese:
            return rawValue
        }
    }

    var bundle: Bundle {
        guard let localeIdentifier,
              let path = Bundle.main.path(forResource: localeIdentifier, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return .main
        }
        return bundle
    }

    static var selected: AppLanguage {
        guard let rawValue = UserDefaults.standard.string(forKey: storageKey),
              let language = AppLanguage(rawValue: rawValue) else {
            return .system
        }
        return language
    }
}

@MainActor
final class LanguageSettings: ObservableObject {
    @Published var selectedLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: AppLanguage.storageKey)
        }
    }

    init() {
        selectedLanguage = AppLanguage.selected
    }
}

enum L10n {
    static func string(_ key: String) -> String {
        NSLocalizedString(key, bundle: AppLanguage.selected.bundle, comment: "")
    }

    static func format(_ key: String, _ arguments: CVarArg...) -> String {
        let locale = AppLanguage.selected.localeIdentifier.map(Locale.init(identifier:)) ?? .autoupdatingCurrent
        return String(format: string(key), locale: locale, arguments: arguments)
    }
}
