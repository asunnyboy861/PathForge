import SwiftUI

struct PathCardView: View {
    let studyPath: StudyPath

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: categoryIcon)
                    .font(.title2)
                    .foregroundStyle(.forgeBlue)

                Spacer()

                Text("Week \(studyPath.currentWeekNumber)/\(studyPath.totalWeeks)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(studyPath.title)
                .font(.headline)
                .lineLimit(2)

            ProgressView(value: studyPath.overallProgress)
                .tint(.forgeBlue)

            Text("\(Int(studyPath.overallProgress * 100))% complete")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var categoryIcon: String {
        let category = studyPath.skillCategory.lowercased()
        if category.contains("python") || category.contains("react") || category.contains("swift") || category.contains("code") || category.contains("program") {
            return "laptopcomputer"
        } else if category.contains("design") || category.contains("ui") {
            return "paintbrush"
        } else if category.contains("photo") {
            return "camera"
        } else if category.contains("music") || category.contains("guitar") {
            return "music.note"
        } else if category.contains("language") || category.contains("spanish") {
            return "text.bubble"
        } else {
            return "book"
        }
    }
}
