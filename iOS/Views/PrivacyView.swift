import SwiftUI

struct PrivacyView: View {
    @EnvironmentObject private var model: AppViewModel
    @EnvironmentObject private var languageSettings: LanguageSettings
    @State private var confirmingDelete = false

    var body: some View {
        ZStack {
            GolfTheme.pageBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    privacyHero

                    privacyCard(
                        icon: "iphone.gen3",
                        title: String(localized: "privacy.local_title"),
                        text: String(localized: "privacy.local_text"),
                        color: GolfTheme.fairway
                    )

                    privacyCard(
                        icon: "network.slash",
                        title: String(localized: "privacy.no_upload_title"),
                        text: String(localized: "privacy.no_upload_text"),
                        color: GolfTheme.sky
                    )

                    privacyCard(
                        icon: "figure.golf",
                        title: String(localized: "privacy.workout_title"),
                        text: String(localized: "privacy.workout_text"),
                        color: .orange
                    )

                    GolfCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("language.title")
                                .font(.headline)
                            Text("language.detail")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Picker("language.title", selection: $languageSettings.selectedLanguage) {
                                ForEach(AppLanguage.allCases) { language in
                                    Text(language.displayNameKey).tag(language)
                                }
                            }
                            .pickerStyle(.menu)
                            .onChange(of: languageSettings.selectedLanguage) { _, _ in
                                NotificationCoordinator.registerCategories()
                            }
                        }
                    }

                    GolfCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("privacy.delete_title")
                                .font(.headline)
                            Text("privacy.delete_text")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Button(role: .destructive) {
                                confirmingDelete = true
                            } label: {
                                Label("privacy.delete_action", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.roundedRectangle(radius: 14))
                            .tint(.red)
                        }
                    }
                }
                .padding(18)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("privacy.navigation_title")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "privacy.confirm_delete",
            isPresented: $confirmingDelete,
            titleVisibility: .visible
        ) {
            Button("common.delete", role: .destructive) {
                Task { await model.deleteAllLocalData() }
            }
            Button("common.cancel", role: .cancel) {}
        }
    }

    private var privacyHero: some View {
        VStack(spacing: 12) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 66, height: 66)
                .background(GolfTheme.heroGradient, in: RoundedRectangle(cornerRadius: 21, style: .continuous))
                .shadow(color: GolfTheme.deepGreen.opacity(0.18), radius: 14, y: 8)

            Text("privacy.hero_title")
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)

            Text("privacy.hero_detail")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    private func privacyCard(icon: String, title: String, text: String, color: Color) -> some View {
        GolfCard {
            HStack(alignment: .top, spacing: 14) {
                GolfIconBadge(systemName: icon, color: color)

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline)
                    Text(text)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
