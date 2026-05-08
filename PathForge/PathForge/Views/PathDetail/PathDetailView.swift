import SwiftUI
import SwiftData

struct PathDetailView: View {
    let studyPath: StudyPath
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: PathDetailViewModel?
    @State private var subscriptionManager = SubscriptionManager()
    @State private var showAdjustSheet = false
    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                overallProgressSection

                ForEach(Array(studyPath.milestones.enumerated()), id: \.element.id) { index, milestone in
                    let isLocked = index > 0 && !studyPath.milestones[index - 1].isCompleted

                    MilestoneCardView(milestone: milestone, isLocked: isLocked)

                    if !isLocked {
                        ForEach(milestone.tasks) { task in
                            TaskRowView(task: task) {
                                viewModel?.toggleTask(task, modelContext: modelContext)
                            }
                            .padding(.leading, 20)
                        }
                    }
                }

                resourcesSection

                adjustPathButton
            }
            .padding()
        }
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
        .navigationTitle(studyPath.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            let apiKey = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
            let service = PathGenerationService(openAIService: OpenAIService(apiKey: apiKey))
            viewModel = PathDetailViewModel(pathService: service)
        }
        .sheet(isPresented: $showAdjustSheet) {
            adjustPathSheet
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(subscriptionManager: subscriptionManager)
        }
    }

    private var overallProgressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Overall Progress")
                .font(.headline)

            ProgressView(value: studyPath.overallProgress)
                .tint(.forgeBlue)

            HStack {
                Text("Week \(studyPath.currentWeekNumber) of \(studyPath.totalWeeks)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(studyPath.overallProgress * 100))% complete")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var resourcesSection: some View {
        Group {
            if !studyPath.resources.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Resources")
                        .font(.headline)

                    ForEach(studyPath.resources) { resource in
                        HStack {
                            Image(systemName: resourceIcon(resource.type))
                                .foregroundStyle(.forgeBlue)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(resource.title)
                                    .font(.subheadline)
                                HStack {
                                    if resource.isFree {
                                        Text("Free")
                                            .font(.caption2)
                                            .foregroundStyle(.pathGreen)
                                    }
                                    Text("\(Int(resource.qualityScore))/10")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            if let url = URL(string: resource.url), !resource.url.isEmpty {
                                Link(destination: url) {
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundStyle(.forgeBlue)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var adjustPathButton: some View {
        Button {
            if subscriptionManager.canAdjustPath {
                showAdjustSheet = true
            } else {
                showPaywall = true
            }
        } label: {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                Text(subscriptionManager.canAdjustPath ? "Adjust Path with AI" : "Adjust Path (Pro)")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.forgeBlue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var adjustPathSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("What would you like to adjust?")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextEditor(text: Binding(
                    get: { viewModel?.adjustmentFeedback ?? "" },
                    set: { viewModel?.adjustmentFeedback = $0 }
                ))
                .frame(minHeight: 120)
                .padding(8)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))

                if let error = viewModel?.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Button {
                    Task {
                        await viewModel?.adjustPath(studyPath, modelContext: modelContext)
                        if viewModel?.errorMessage == nil {
                            subscriptionManager.incrementFreeAdjustmentsUsed()
                            showAdjustSheet = false
                        }
                    }
                } label: {
                    HStack {
                        if viewModel?.isAdjusting == true {
                            ProgressView()
                                .tint(.white)
                        }
                        Text("Adjust Path")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.forgeBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(viewModel?.isAdjusting == true)

                Spacer()
            }
            .padding()
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            .navigationTitle("Adjust Path")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { showAdjustSheet = false }
                }
            }
        }
    }

    private func resourceIcon(_ type: String) -> String {
        switch type {
        case "Video": return "play.circle"
        case "Article": return "doc.text"
        case "Exercise": return "dumbbell"
        case "Project": return "hammer"
        case "Book": return "book"
        case "Podcast": return "headphones"
        default: return "doc"
        }
    }
}
