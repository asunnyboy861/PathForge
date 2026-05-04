import SwiftUI
import SwiftData

struct PathGenerationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PathGenerationViewModel

    init() {
        let apiKey = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
        let service = PathGenerationService(openAIService: OpenAIService(apiKey: apiKey))
        _viewModel = State(initialValue: PathGenerationViewModel(pathService: service))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ProgressView(
                    value: Double(viewModel.currentStep.rawValue),
                    total: Double(PathGenerationViewModel.GenerationStep.allCases.count - 1)
                )
                .tint(.forgeBlue)
                .padding(.horizontal)

                TabView(selection: Binding(
                    get: { viewModel.currentStep },
                    set: { _ in }
                )) {
                    GoalInputStep(viewModel: viewModel)
                        .tag(PathGenerationViewModel.GenerationStep.goalInput)

                    LevelAssessmentStep(viewModel: viewModel)
                        .tag(PathGenerationViewModel.GenerationStep.levelAssessment)

                    TimePreferencesStep(viewModel: viewModel)
                        .tag(PathGenerationViewModel.GenerationStep.timePreferences)

                    GeneratingStep()
                        .tag(PathGenerationViewModel.GenerationStep.generating)

                    if let path = viewModel.generatedPath {
                        PathPreviewStep(viewModel: viewModel, generatedPath: path) {
                            viewModel.savePath()
                            dismiss()
                        }
                        .tag(PathGenerationViewModel.GenerationStep.pathPreview)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: viewModel.currentStep)
            }
            .navigationTitle("Create Path")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.currentStep != .goalInput && viewModel.currentStep != .generating {
                        Button("Back") { viewModel.previousStep() }
                    } else {
                        Button("Cancel") { dismiss() }
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onAppear {
                viewModel.configure(modelContext: modelContext)
            }
        }
    }
}

struct GoalInputStep: View {
    @Bindable var viewModel: PathGenerationViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "compass")
                        .font(.largeTitle)
                        .foregroundStyle(.forgeBlue)

                    Text("What do you want to learn?")
                        .font(.title2)
                        .fontWeight(.bold)
                }

                TextField("e.g., Master React in 30 days", text: $viewModel.goalText)
                    .textFieldStyle(.roundedBorder)
                    .font(.body)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Popular Goals")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(viewModel.popularGoals, id: \.self) { goal in
                            Button(goal) {
                                viewModel.goalText = goal
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(viewModel.goalText == goal ? Color.forgeBlue.opacity(0.2) : Color.secondary.opacity(0.1))
                            .foregroundStyle(viewModel.goalText == goal ? .forgeBlue : .primary)
                            .clipShape(Capsule())
                        }
                    }
                }

                Spacer(minLength: 40)

                Button("Continue") {
                    viewModel.nextStep()
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.canProceed ? Color.forgeBlue : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(!viewModel.canProceed)
            }
            .padding()
        }
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
    }
}

struct LevelAssessmentStep: View {
    let viewModel: PathGenerationViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "chart.bar")
                        .font(.largeTitle)
                        .foregroundStyle(.forgeBlue)

                    Text("Assess Your Level")
                        .font(.title2)
                        .fontWeight(.bold)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Level")
                        .font(.headline)

                    ForEach(StudyPath.SkillLevel.allCases, id: \.self) { level in
                        Button {
                            viewModel.currentLevel = level
                        } label: {
                            HStack {
                                Image(systemName: viewModel.currentLevel == level ? "largecircle.fill.circle" : "circle")
                                    .foregroundStyle(viewModel.currentLevel == level ? .forgeBlue : .secondary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(level.rawValue)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    Text(levelDescription(for: level))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(viewModel.currentLevel == level ? Color.forgeBlue.opacity(0.1) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Target Level")
                        .font(.headline)

                    ForEach(StudyPath.SkillLevel.allCases.filter { $0.rawValue > viewModel.currentLevel.rawValue }, id: \.self) { level in
                        Button {
                            viewModel.targetLevel = level
                        } label: {
                            HStack {
                                Image(systemName: viewModel.targetLevel == level ? "largecircle.fill.circle" : "circle")
                                    .foregroundStyle(viewModel.targetLevel == level ? .forgeBlue : .secondary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(level.rawValue)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(viewModel.targetLevel == level ? Color.forgeBlue.opacity(0.1) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer(minLength: 40)

                Button("Continue") {
                    viewModel.nextStep()
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.forgeBlue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
    }

    private func levelDescription(for level: StudyPath.SkillLevel) -> String {
        switch level {
        case .beginner: return "New to this skill"
        case .intermediate: return "Know the basics"
        case .advanced: return "Looking to master it"
        case .expert: return "Industry-level expertise"
        }
    }
}

struct TimePreferencesStep: View {
    @Bindable var viewModel: PathGenerationViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "clock")
                        .font(.largeTitle)
                        .foregroundStyle(.forgeBlue)

                    Text("Time & Style")
                        .font(.title2)
                        .fontWeight(.bold)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Weekly Study Hours: \(viewModel.weeklyHours)h")
                        .font(.headline)

                    Stepper("", value: $viewModel.weeklyHours, in: 1...20)
                        .labelsHidden()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Timeline: \(viewModel.timelineWeeks) weeks")
                        .font(.headline)

                    Stepper("", value: $viewModel.timelineWeeks, in: 2...26)
                        .labelsHidden()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Learning Style")
                        .font(.headline)

                    ForEach(PathGenerationViewModel.LearningStyle.allCases, id: \.self) { style in
                        Button {
                            viewModel.learningStyle = style
                        } label: {
                            HStack {
                                Image(systemName: viewModel.learningStyle == style ? "largecircle.fill.circle" : "circle")
                                    .foregroundStyle(viewModel.learningStyle == style ? .forgeBlue : .secondary)
                                Text(style.rawValue)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                Spacer()
                            }
                            .padding()
                            .background(viewModel.learningStyle == style ? Color.forgeBlue.opacity(0.1) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer(minLength: 40)

                Button("Generate Path") {
                    viewModel.nextStep()
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.forgeBlue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
    }
}

struct GeneratingStep: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            ProgressView()
                .scaleEffect(1.5)
                .tint(.forgeBlue)

            Text("Generating your learning path...")
                .font(.title3)
                .fontWeight(.medium)

            Text("Our AI is creating a personalized plan based on your goals and preferences")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
    }
}

struct PathPreviewStep: View {
    let viewModel: PathGenerationViewModel
    let generatedPath: PathGenerationService.GeneratedPath
    let onSave: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(generatedPath.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(generatedPath.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                ForEach(generatedPath.milestones, id: \.weekNumber) { milestone in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Week \(milestone.weekNumber)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.forgeBlue)
                            Spacer()
                            Text("\(milestone.tasks.count) tasks")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Text(milestone.title)
                            .font(.headline)

                        Text(milestone.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        ForEach(milestone.tasks, id: \.title) { task in
                            HStack(spacing: 8) {
                                Image(systemName: taskIcon(task.resourceType))
                                    .font(.caption)
                                    .foregroundStyle(.forgeBlue)
                                Text(task.title)
                                    .font(.subheadline)
                                Spacer()
                                Text("\(task.estimatedMinutes)m")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }

                if !generatedPath.resources.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recommended Resources")
                            .font(.headline)

                        ForEach(generatedPath.resources, id: \.title) { resource in
                            HStack {
                                Image(systemName: taskIcon(resource.type))
                                    .foregroundStyle(.forgeBlue)
                                VStack(alignment: .leading) {
                                    Text(resource.title)
                                        .font(.subheadline)
                                    HStack {
                                        if resource.isFree {
                                            Text("Free")
                                                .font(.caption2)
                                                .foregroundStyle(.pathGreen)
                                        }
                                        Text("Quality: \(Int(resource.qualityScore))/10")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }

                Button("Save Path") {
                    onSave()
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.forgeBlue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
    }

    private func taskIcon(_ type: String) -> String {
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
