import SwiftUI

struct TaskRowView: View {
    let task: StudyTask
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? .pathGreen : .secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.body)
                        .foregroundStyle(task.isCompleted ? .secondary : .primary)
                        .strikethrough(task.isCompleted)

                    HStack(spacing: 8) {
                        Label("\(task.estimatedMinutes)m", systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Label(task.resourceType, systemImage: resourceIcon)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if let url = task.resourceURL, !task.isCompleted {
                    Link(destination: URL(string: url)!) {
                        Image(systemName: "arrow.up.right.square")
                            .font(.body)
                            .foregroundStyle(.forgeBlue)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private var resourceIcon: String {
        switch task.resourceType {
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
