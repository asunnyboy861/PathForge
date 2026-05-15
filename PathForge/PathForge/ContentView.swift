import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)

            PathsView()
                .tabItem {
                    Label("Paths", systemImage: "map")
                }
                .tag(1)

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(3)
        }
        .tint(.forgeBlue)
        .onAppear {
            DemoDataService.loadDemoDataIfNeeded(modelContext: modelContext)
        }
    }
}

struct PathsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HomeViewModel()
    @State private var showCreatePath = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.studyPaths) { path in
                    NavigationLink {
                        PathDetailView(studyPath: path)
                    } label: {
                        PathCardView(studyPath: path)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                }
                .onDelete(perform: deletePaths)
            }
            .listStyle(.plain)
            .navigationTitle("My Paths")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreatePath = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .overlay {
                if viewModel.studyPaths.isEmpty {
                    ContentUnavailableView(
                        "No Learning Paths",
                        systemImage: "map",
                        description: Text("Create your first learning path to get started")
                    )
                }
            }
            .sheet(isPresented: $showCreatePath) {
                PathGenerationView()
            }
            .onAppear {
                viewModel.fetchPaths(modelContext: modelContext)
            }
        }
    }

    private func deletePaths(offsets: IndexSet) {
        for index in offsets {
            let path = viewModel.studyPaths[index]
            modelContext.delete(path)
        }
        try? modelContext.save()
        viewModel.fetchPaths(modelContext: modelContext)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [StudyPath.self, Milestone.self, StudyTask.self, LearningResource.self], inMemory: true)
}
