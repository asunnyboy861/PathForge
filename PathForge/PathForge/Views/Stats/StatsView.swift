import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = StatsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    summaryCards

                    weeklyChart

                    pathBreakdown
                }
                .padding()
            }
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            .navigationTitle("Statistics")
            .onAppear {
                viewModel.fetchStats(modelContext: modelContext)
            }
        }
    }

    private var summaryCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCardView(title: "Study Time", value: "\(viewModel.totalStudyMinutes / 60)h", icon: "clock", color: .forgeBlue)
            StatCardView(title: "Tasks Done", value: "\(viewModel.completedTasks)", icon: "checkmark.circle", color: .pathGreen)
            StatCardView(title: "Milestones", value: "\(viewModel.completedMilestones)/\(viewModel.totalMilestones)", icon: "flag", color: .alertOrange)
            StatCardView(title: "Active Paths", value: "\(viewModel.activePaths)", icon: "map", color: .purple)
        }
    }

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)

            if viewModel.weeklyData.isEmpty {
                Text("No data yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Chart(viewModel.weeklyData) { data in
                    BarMark(
                        x: .value("Day", data.day),
                        y: .value("Minutes", data.minutes)
                    )
                    .foregroundStyle(.forgeBlue.gradient)
                }
                .frame(height: 200)
                .chartYAxisLabel("Minutes")
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var pathBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Completion Rate")
                .font(.headline)

            let rate = viewModel.totalTasks > 0 ?
                Double(viewModel.completedTasks) / Double(viewModel.totalTasks) : 0

            ProgressView(value: rate)
                .tint(.forgeBlue)

            Text("\(Int(rate * 100))% of all tasks completed")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
