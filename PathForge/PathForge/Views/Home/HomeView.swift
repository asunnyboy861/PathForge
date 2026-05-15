import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HomeViewModel()
    @State private var showCreatePath = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if DemoDataService.isDemoMode {
                        demoModeBanner
                    }

                    greetingSection

                    todayTasksSection

                    myPathsSection

                    weeklyStatsSection
                }
                .padding()
            }
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            .navigationTitle("PathForge")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreatePath = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreatePath) {
                PathGenerationView()
            }
            .onAppear {
                viewModel.fetchPaths(modelContext: modelContext)
            }
            .refreshable {
                viewModel.fetchPaths(modelContext: modelContext)
            }
        }
    }

    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
                .font(.title2)
                .fontWeight(.bold)
            Text("Keep learning, keep growing")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var todayTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Tasks")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.todayTasks.filter(\.isCompleted).count)/\(viewModel.todayTasks.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if viewModel.todayTasks.isEmpty {
                Text("No tasks for today. Create a learning path to get started!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            } else {
                ProgressView(
                    value: viewModel.todayTasks.isEmpty ? 0 :
                        Double(viewModel.todayTasks.filter(\.isCompleted).count) /
                        Double(viewModel.todayTasks.count)
                )
                .tint(.forgeBlue)

                ForEach(viewModel.todayTasks.prefix(5)) { task in
                    TaskRowView(task: task) {
                        viewModel.toggleTask(task, modelContext: modelContext)
                    }
                }

                if viewModel.todayTasks.count > 5 {
                    Text("+\(viewModel.todayTasks.count - 5) more tasks")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var myPathsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("My Paths")
                .font(.headline)

            if viewModel.studyPaths.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "map")
                        .font(.system(size: 36))
                        .foregroundStyle(.forgeBlue)

                    if DemoDataService.isDemoMode {
                        Text("Configure your API key to get started")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        NavigationLink {
                            SettingsView()
                        } label: {
                            HStack {
                                Image(systemName: "key")
                                Text("Go to Settings")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color.forgeBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    } else {
                        Button {
                            showCreatePath = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Create New Path")
                            }
                            .font(.headline)
                            .foregroundStyle(.forgeBlue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.forgeBlue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.studyPaths) { path in
                            NavigationLink {
                                PathDetailView(studyPath: path)
                            } label: {
                                PathCardView(studyPath: path)
                                    .frame(width: 180)
                            }
                            .buttonStyle(.plain)
                        }

                        Button {
                            showCreatePath = true
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "plus.circle")
                                    .font(.title)
                                Text("New Path")
                                    .font(.caption)
                            }
                            .foregroundStyle(.forgeBlue)
                            .frame(width: 180, height: 120)
                            .background(.forgeBlue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
        }
    }

    private var weeklyStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Stats")
                .font(.headline)

            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Image(systemName: "clock")
                        .foregroundStyle(.forgeBlue)
                    Text("\(viewModel.weeklyStudyMinutes / 60)h")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("studied")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 4) {
                    Image(systemName: "flame")
                        .foregroundStyle(.alertOrange)
                    Text("\(viewModel.streakDays)")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("day streak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 4) {
                    Image(systemName: "checkmark.circle")
                        .foregroundStyle(.pathGreen)
                    Text("\(viewModel.todayTasks.filter(\.isCompleted).count)")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("completed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        else if hour < 17 { return "Good Afternoon" }
        else { return "Good Evening" }
    }

    private var demoModeBanner: some View {
        NavigationLink {
            SettingsView()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.forgeBlue)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Demo Mode")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Text("Add your API key in Settings to unlock AI features")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.forgeBlue.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.forgeBlue.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
