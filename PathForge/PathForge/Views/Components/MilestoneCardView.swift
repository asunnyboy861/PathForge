import SwiftUI

struct MilestoneCardView: View {
    let milestone: Milestone
    let isLocked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Week \(milestone.weekNumber)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.forgeBlue)

                Spacer()

                if milestone.isCompleted {
                    Text("Completed")
                        .font(.caption)
                        .foregroundStyle(.pathGreen)
                } else if !isLocked {
                    Text("\(Int(milestone.progress * 100))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(milestone.title)
                .font(.headline)
                .foregroundStyle(isLocked ? .secondary : .primary)

            if !isLocked {
                ProgressView(value: milestone.progress)
                    .tint(milestone.isCompleted ? .pathGreen : .forgeBlue)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                    Text("Complete previous week first")
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
