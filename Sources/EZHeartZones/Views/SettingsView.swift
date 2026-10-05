import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: SettingsStore
    @ObservedObject var healthKitManager: HealthKitManager
    @Environment(\.dismiss) private var dismiss

    private static let breakpointLabels = [
        "Zone 1 Min", "Zone 1 / 2", "Zone 2 / 3", "Zone 3 / 4", "Zone 4 / 5", "Zone 5 Max"
    ]

    private var effectiveAge: Int {
        healthKitManager.fetchAge() ?? SettingsStore.defaultAge
    }

    private var displayedBoundaries: [HeartRateZone: ZoneBoundary] {
        settings.effectiveBoundaries(age: effectiveAge)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Apple Health") {
                    Button("Request Health Access") {
                        Task { await healthKitManager.requestAuthorization() }
                    }
                    Text(healthKitManager.authorizationStatusDescription)
                        .foregroundStyle(.secondary)
                }

                Section("Weekly Cardio Goal") {
                    HStack {
                        TextField("Weekly Goal", value: $settings.weeklyGoal, format: .number)
                            .keyboardType(.numberPad)
                        Text("pts")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Week Starts On") {
                    Picker("Week Starts On", selection: $settings.weekStartDay) {
                        ForEach(WeekStartDay.allCases) { day in
                            Text(day.name).tag(day)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section {
                    Toggle("Use Custom Zones", isOn: $settings.useCustomZones)

                    ForEach(HeartRateZone.allCases) { zone in
                        ZoneSummaryRow(zone: zone, boundary: displayedBoundaries[zone])
                    }
                } header: {
                    Text("Heart Rate Zones")
                } footer: {
                    if !settings.useCustomZones {
                        Text(
                            "Calculated from age \(effectiveAge) (220 − age). " +
                                "Set your birthdate in the Health app for a personalized estimate."
                        )
                    }
                }

                if settings.useCustomZones {
                    Section {
                        ForEach(0 ..< 6, id: \.self) { index in
                            HStack {
                                Text(Self.breakpointLabels[index])
                                Spacer()
                                TextField("", value: breakpointBinding(at: index), format: .number)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 60)
                                Text("bpm")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } header: {
                        Text("Zone Boundaries")
                    } footer: {
                        Text(
                            "Each boundary is shared by the two zones on either side of it, " +
                                "so zones always stay adjacent with no gaps or overlaps."
                        )
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    /// Clamps each breakpoint to stay between its immediate neighbors, so the sequence can never
    /// become out of order (which would otherwise create a gap or an inverted zone range).
    private func breakpointBinding(at index: Int) -> Binding<Int> {
        Binding(
            get: { settings.customZoneBreakpoints[index] },
            set: { newValue in
                var breakpoints = settings.customZoneBreakpoints
                let lowerBound = index > 0 ? breakpoints[index - 1] : 30
                let upperBound = index < breakpoints.count - 1 ? breakpoints[index + 1] : 250
                breakpoints[index] = min(max(newValue, lowerBound), upperBound)
                settings.customZoneBreakpoints = breakpoints
            }
        )
    }
}

private struct ZoneSummaryRow: View {
    let zone: HeartRateZone
    let boundary: ZoneBoundary?

    var body: some View {
        HStack {
            Circle()
                .fill(zone.color)
                .frame(width: 10, height: 10)
            Text("Zone \(zone.rawValue)")
            Spacer()
            if let boundary {
                Text("\(boundary.minBPM)–\(boundary.maxBPM) bpm")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
    }
}

#Preview {
    SettingsView(settings: SettingsStore(), healthKitManager: HealthKitManager())
}
