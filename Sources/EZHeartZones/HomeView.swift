import SwiftUI

struct HomeView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var settings = SettingsStore()
    @StateObject private var viewModel: HeartZonesViewModel

    @Environment(\.scenePhase) private var scenePhase

    @State private var weekOffset = 0
    @State private var isShowingSettings = false
    @State private var confettiBurstID = 0
    @State private var lastCelebratedWeekStart: Date?

    init() {
        let healthKitManager = HealthKitManager()
        let settings = SettingsStore()
        _healthKitManager = StateObject(wrappedValue: healthKitManager)
        _settings = StateObject(wrappedValue: settings)
        _viewModel = StateObject(
            wrappedValue: HeartZonesViewModel(healthKitManager: healthKitManager, settings: settings)
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                HStack {
                    Text("Heart Zones")
                        .font(.system(size: 22, weight: .bold))
                    Spacer()
                    if viewModel.isLoading {
                        ProgressView()
                    }
                    Button {
                        Task { await viewModel.load(weekOffset: weekOffset) }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 15))
                            .foregroundStyle(Color(hex: "5B6472"))
                            .frame(width: 36, height: 36)
                            .background(AppColors.iconButtonBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    Button {
                        isShowingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(Color(hex: "5B6472"))
                            .frame(width: 36, height: 36)
                            .background(AppColors.iconButtonBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }

                WeekSelectorBar(weekOffset: $weekOffset, dateRangeDescription: viewModel.week.dateRangeDescription)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12))
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                NavigationLink {
                    WeekDetailView(week: viewModel.week)
                } label: {
                    GoalCard(
                        points: viewModel.week.totalBreakdown.totalPoints,
                        goal: viewModel.week.weeklyGoal,
                        confettiBurstID: confettiBurstID
                    )
                }
                .buttonStyle(.plain)

                IntensityLegendRow()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Daily Breakdown")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.6)
                    .foregroundStyle(AppColors.secondaryText)
                    .textCase(.uppercase)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 1) {
                    ForEach(viewModel.week.days) { day in
                        NavigationLink {
                            DayDetailView(
                                date: day.date,
                                breakdown: day.breakdown,
                                healthKitManager: healthKitManager,
                                settings: settings
                            )
                        } label: {
                            DailyBreakdownRow(day: day, maxDayPoints: viewModel.week.maxDayPoints)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)
            .background(AppColors.background)
            .navigationBarHidden(true)
            .sheet(isPresented: $isShowingSettings) {
                SettingsView(settings: settings, healthKitManager: healthKitManager)
            }
            .task {
                await healthKitManager.requestAuthorization()
                await viewModel.load(weekOffset: weekOffset)
                checkCelebration()
                healthKitManager.startObservingHeartRateChanges {
                    Task {
                        await viewModel.load(weekOffset: weekOffset)
                        checkCelebration()
                    }
                }
            }
            .onDisappear {
                healthKitManager.stopObservingHeartRateChanges()
            }
            .onChange(of: weekOffset) { _, newOffset in
                Task {
                    await viewModel.load(weekOffset: newOffset)
                    checkCelebration()
                }
            }
            .onChange(of: isShowingSettings) { _, isShowing in
                guard !isShowing else { return }
                Task {
                    await viewModel.load(weekOffset: weekOffset)
                    checkCelebration()
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                guard newPhase == .active else { return }
                Task {
                    await viewModel.load(weekOffset: weekOffset)
                    checkCelebration()
                }
            }
        }
    }

    /// Fires the confetti burst once per week reaching/crossing its goal — keyed by the week's
    /// start date so reloading the same already-celebrated week (e.g. a background refresh)
    /// doesn't re-burst confetti every time, per DESIGN.md §8's optional-polish suggestion.
    private func checkCelebration() {
        let week = viewModel.week
        guard week.weeklyGoal > 0, week.totalBreakdown.totalPoints >= week.weeklyGoal else { return }
        guard lastCelebratedWeekStart != week.weekStartDate else { return }
        lastCelebratedWeekStart = week.weekStartDate
        confettiBurstID += 1
    }
}

#Preview {
    HomeView()
}
