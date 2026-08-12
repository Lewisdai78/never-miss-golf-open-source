import CoreLocation
import SwiftUI
import UserNotifications

struct ContentView: View {
    @EnvironmentObject private var model: AppViewModel
    @EnvironmentObject private var routeStore: AppRouteStore
    @State private var showingAddCourse = false

    var body: some View {
        NavigationStack {
            ZStack {
                GolfTheme.pageBackground
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 18) {
                        hero

                        if let message = routeStore.message {
                            routeMessage(message)
                        }

                        permissionsCard
                        coursesSection
                        testCard
                        productBoundaryCard
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 10)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Never Miss Golf")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        PrivacyView()
                    } label: {
                        Image(systemName: "hand.raised.fill")
                            .fontWeight(.semibold)
                    }
                    .accessibilityLabel("app.privacy")
                }
            }
            .sheet(isPresented: $showingAddCourse) {
                AddCourseView()
                    .environmentObject(model)
            }
            .alert("app.unavailable", isPresented: $model.showingError) {
                Button("common.ok", role: .cancel) {}
            } message: {
                Text(model.errorMessage)
            }
        }
        .tint(GolfTheme.fairway)
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(GolfTheme.heroGradient)

            Circle()
                .fill(.white.opacity(0.08))
                .frame(width: 190, height: 190)
                .offset(x: 230, y: -48)

            Image(systemName: "figure.golf")
                .font(.system(size: 94, weight: .light))
                .foregroundStyle(.white.opacity(0.10))
                .offset(x: 220, y: 22)

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                    Text(model.locationAuthorization == .authorizedAlways ? "hero.ready" : "hero.setup")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.88))
                .padding(.horizontal, 11)
                .padding(.vertical, 7)
                .background(.white.opacity(0.12), in: Capsule())

                Text("hero.title")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineSpacing(-1)

                Text(L10n.format("hero.course_count", model.courses.count, PrototypeConfiguration.maximumCourses))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.72))
            }
            .padding(24)
        }
        .frame(height: 226)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: GolfTheme.deepGreen.opacity(0.22), radius: 24, y: 14)
        .accessibilityElement(children: .combine)
    }

    private func routeMessage(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 13) {
            GolfIconBadge(systemName: "applewatch", color: GolfTheme.fairway)

            VStack(alignment: .leading, spacing: 5) {
                Text("common.next")
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 4)

            Button {
                routeStore.message = nil
            } label: {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .padding(7)
                    .background(.quaternary, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("common.close")
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var permissionsCard: some View {
        GolfCard {
            VStack(alignment: .leading, spacing: 16) {
                GolfSectionHeader("section.permissions")

                permissionRow(
                    icon: "location.fill",
                    title: String(localized: "section.location"),
                    detail: model.locationStatusText,
                    color: locationStatusColor
                )

                Divider()

                permissionRow(
                    icon: "bell.badge.fill",
                    title: String(localized: "section.reminders"),
                    detail: model.notificationStatusText,
                    color: notificationStatusColor
                )

                permissionActions
            }
        }
    }

    private func permissionRow(icon: String, title: String, detail: String, color: Color) -> some View {
        HStack(spacing: 13) {
            GolfIconBadge(systemName: icon, color: color)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
        }
    }

    @ViewBuilder
    private var permissionActions: some View {
        if model.locationAuthorization == .notDetermined {
            compactAction("action.allow_location", icon: "location") {
                model.requestWhenInUseLocation()
            }
        } else if model.locationAuthorization == .authorizedWhenInUse {
            compactAction("action.enable_background_reminders", icon: "location.circle") {
                model.requestAlwaysLocation()
            }
        }

        if model.notificationAuthorization == .notDetermined {
            compactAction("action.allow_notifications", icon: "bell") {
                Task { await model.requestNotifications() }
            }
        }
    }

    private func compactAction(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: 14))
    }

    private var coursesSection: some View {
        VStack(spacing: 12) {
            HStack {
                GolfSectionHeader("section.my_courses", detail: "\(model.courses.count) / \(PrototypeConfiguration.maximumCourses)")

                Button {
                    showingAddCourse = true
                } label: {
                    Image(systemName: "plus")
                        .font(.subheadline.weight(.bold))
                        .frame(width: 34, height: 34)
                        .foregroundStyle(.white)
                        .background(GolfTheme.fairway, in: Circle())
                }
                .buttonStyle(.plain)
                .disabled(!model.canAddCourse || model.isBusy)
                .opacity(model.canAddCourse && !model.isBusy ? 1 : 0.4)
                .accessibilityLabel("accessibility.save_current_location")
            }

            if model.courses.isEmpty {
                GolfCard {
                    VStack(spacing: 12) {
                        Image(systemName: "flag.checkered")
                            .font(.system(size: 32, weight: .light))
                            .foregroundStyle(GolfTheme.fairway)

                        Text("empty.title")
                            .font(.headline)

                        Text("empty.detail")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Button("action.save_current_location") {
                            showingAddCourse = true
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .disabled(!model.canAddCourse || model.isBusy)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            } else {
                ForEach(model.courses) { course in
                    courseCard(course)
                }
            }
        }
    }

    private func courseCard(_ course: SavedCourse) -> some View {
        GolfCard {
            HStack(spacing: 14) {
                GolfIconBadge(systemName: "flag.fill")

                VStack(alignment: .leading, spacing: 4) {
                    Text(course.name)
                        .font(.headline)
                    Text(L10n.format("course.radius", Int(course.radiusMeters)))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Menu {
                    Button("action.delete_course", systemImage: "trash", role: .destructive) {
                        Task { await model.deleteCourse(course) }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .frame(width: 36, height: 36)
                        .background(.quaternary, in: Circle())
                }
                .accessibilityLabel("accessibility.course_actions")
            }
        }
    }

    private var testCard: some View {
        GolfCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 13) {
                    GolfIconBadge(systemName: "applewatch.radiowaves.left.and.right", color: GolfTheme.sky)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("test.title")
                            .font(.headline)
                        Text("test.detail")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Button {
                    Task { await model.sendTestReminder() }
                } label: {
                    HStack {
                        Image(systemName: "bell.and.waves.left.and.right.fill")
                        Text("test.action")
                    }
                }
                .buttonStyle(GolfPrimaryButtonStyle())
                .disabled(model.courses.isEmpty)
                .opacity(model.courses.isEmpty ? 0.45 : 1)

                Text("test.note")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var productBoundaryCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.shield.fill")
                .foregroundStyle(GolfTheme.fairway)
                .font(.title3)

            Text("boundary.note")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 6)
    }

    private var locationStatusColor: Color {
        switch model.locationAuthorization {
        case .authorizedAlways:
            return GolfTheme.fairway
        case .authorizedWhenInUse:
            return .orange
        case .notDetermined:
            return .secondary
        case .denied, .restricted:
            return .red
        @unknown default:
            return .secondary
        }
    }

    private var notificationStatusColor: Color {
        switch model.notificationAuthorization {
        case .authorized:
            return GolfTheme.fairway
        case .provisional, .ephemeral:
            return .orange
        case .notDetermined:
            return .secondary
        case .denied:
            return .red
        @unknown default:
            return .secondary
        }
    }
}
