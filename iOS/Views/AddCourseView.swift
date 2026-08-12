import SwiftUI

struct AddCourseView: View {
    @EnvironmentObject private var model: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var radiusMeters = 300.0

    var body: some View {
        NavigationStack {
            ZStack {
                GolfTheme.pageBackground
                    .ignoresSafeArea()

                Form {
                    Section {
                        VStack(spacing: 12) {
                            GolfIconBadge(systemName: "flag.fill")
                            Text("add.title")
                                .font(.title2.weight(.bold))
                            Text("add.detail")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                    .listRowBackground(Color.clear)

                    Section("add.name_section") {
                        TextField("add.name_placeholder", text: $name)
                            .textInputAutocapitalization(.words)
                    }

                    Section {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Label("add.radius", systemImage: "scope")
                                    .font(.subheadline.weight(.semibold))
                                Spacer()
                                Text(L10n.format("add.radius_value", Int(radiusMeters)))
                                    .font(.subheadline.monospacedDigit())
                                    .foregroundStyle(GolfTheme.fairway)
                            }

                            Slider(value: $radiusMeters, in: 100...1_000, step: 50)

                            HStack {
                                Text("add.precise")
                                Spacer()
                                Text("add.relaxed")
                            }
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                    }

                    Section {
                        Label {
                            Text("add.privacy")
                        } icon: {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(GolfTheme.fairway)
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("add.navigation_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("common.save") {
                        Task {
                            if await model.addCourse(name: name, radiusMeters: radiusMeters) {
                                dismiss()
                            }
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .tint(GolfTheme.fairway)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
