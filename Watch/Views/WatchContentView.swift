import SwiftUI

struct WatchContentView: View {
    @EnvironmentObject private var opener: WorkoutOpener
    @EnvironmentObject private var languageSettings: LanguageSettings
    @State private var showingLanguagePicker = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.16, blue: 0.10),
                    Color(red: 0.03, green: 0.31, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(.white.opacity(0.06))
                .frame(width: 170, height: 170)
                .offset(x: 88, y: -92)

            ScrollView {
                VStack(spacing: 12) {
                    logo
                    statusCard
                    openButton

                    languageMenu

                    Text("watch.manual_start")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.62))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
        }
        .animation(.easeInOut(duration: 0.22), value: opener.status)
        .sheet(isPresented: $showingLanguagePicker) {
            WatchLanguagePicker()
                .environmentObject(languageSettings)
        }
    }

    private var logo: some View {
        VStack(spacing: 7) {
            Image(systemName: "figure.golf")
                .font(.system(size: 25, weight: .semibold))
                .foregroundStyle(Color(red: 0.70, green: 0.95, blue: 0.48))
                .frame(width: 52, height: 52)
                .background(.white.opacity(0.11), in: RoundedRectangle(cornerRadius: 17, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                        .stroke(.white.opacity(0.12), lineWidth: 0.5)
                }

            Text("Never Miss Golf")
                .font(.headline)
                .foregroundStyle(.white)
        }
    }

    private var statusCard: some View {
        HStack(spacing: 9) {
            Image(systemName: statusIcon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(statusColor)
                .frame(width: 28, height: 28)
                .background(statusColor.opacity(0.16), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(statusTitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                Text(statusDetail)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.62))
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var openButton: some View {
        Button {
            Task { await opener.openGolf() }
        } label: {
            HStack(spacing: 7) {
                if opener.status == .opening {
                    ProgressView()
                        .tint(Color(red: 0.02, green: 0.20, blue: 0.12))
                } else {
                    Image(systemName: "arrow.up.forward.app.fill")
                }

                Text(opener.status == .opening ? "watch.opening" : "watch.open_workout")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(Color(red: 0.02, green: 0.20, blue: 0.12))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(.white, in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(opener.status == .opening)
        .opacity(opener.status == .opening ? 0.82 : 1)
    }

    private var languageMenu: some View {
        Button {
            showingLanguagePicker = true
        } label: {
            Label("language.title", systemImage: "globe")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.78))
        }
        .buttonStyle(.plain)
    }

    private var statusIcon: String {
        switch opener.status {
        case .ready:
            return "flag.checkered"
        case .opening:
            return "arrow.triangle.2.circlepath"
        case .opened:
            return "checkmark"
        case .failed:
            return "exclamationmark"
        }
    }

    private var statusColor: Color {
        switch opener.status {
        case .ready:
            return Color(red: 0.70, green: 0.95, blue: 0.48)
        case .opening:
            return .white
        case .opened:
            return Color(red: 0.43, green: 0.88, blue: 0.62)
        case .failed:
            return Color(red: 1.0, green: 0.48, blue: 0.42)
        }
    }

    private var statusTitle: String {
        switch opener.status {
        case .ready:
            return L10n.string("watch.status.ready_title")
        case .opening:
            return L10n.string("watch.status.opening_title")
        case .opened:
            return L10n.string("watch.status.opened_title")
        case .failed:
            return L10n.string("watch.status.failed_title")
        }
    }

    private var statusDetail: String {
        switch opener.status {
        case .ready:
            return L10n.string("watch.status.ready_detail")
        case .opening:
            return L10n.string("watch.status.opening_detail")
        case .opened:
            return L10n.string("watch.status.opened_detail")
        case .failed(let message):
            return message
        }
    }
}

private struct WatchLanguagePicker: View {
    @EnvironmentObject private var languageSettings: LanguageSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(AppLanguage.allCases) { language in
                    Button {
                        languageSettings.selectedLanguage = language
                        WatchAppDelegate.registerNotificationCategory()
                        dismiss()
                    } label: {
                        HStack {
                            Text(language.displayName)
                            Spacer()
                            if language == languageSettings.selectedLanguage {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                }
            }
            .navigationTitle("language.title")
        }
    }
}
