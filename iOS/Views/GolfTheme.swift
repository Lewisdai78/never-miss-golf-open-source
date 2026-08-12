import SwiftUI

enum GolfTheme {
    static let deepGreen = Color(red: 0.035, green: 0.19, blue: 0.12)
    static let fairway = Color(red: 0.08, green: 0.43, blue: 0.25)
    static let lime = Color(red: 0.58, green: 0.82, blue: 0.35)
    static let sky = Color(red: 0.35, green: 0.69, blue: 0.92)

    static let heroGradient = LinearGradient(
        colors: [deepGreen, Color(red: 0.04, green: 0.34, blue: 0.21)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let pageBackground = LinearGradient(
        colors: [
            Color(.systemGroupedBackground),
            fairway.opacity(0.07),
            Color(.systemGroupedBackground)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct GolfCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(.white.opacity(0.45), lineWidth: 0.5)
            }
            .shadow(color: .black.opacity(0.06), radius: 16, y: 8)
    }
}

struct GolfSectionHeader: View {
    let title: LocalizedStringKey
    let detail: String?

    init(_ title: LocalizedStringKey, detail: String? = nil) {
        self.title = title
        self.detail = detail
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title3.weight(.bold))

            Spacer()

            if let detail {
                Text(detail)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct GolfIconBadge: View {
    let systemName: String
    var color: Color = GolfTheme.fairway

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: 38, height: 38)
            .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct GolfPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(GolfTheme.heroGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}
