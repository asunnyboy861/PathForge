import SwiftData
import Foundation

@Model
final class LearningResource {
    @Attribute(.unique) var id: UUID
    var title: String
    var url: String
    var type: String
    var isFree: Bool
    var qualityScore: Double
    var source: String
    var studyPath: StudyPath?

    init(title: String, url: String, type: String,
         isFree: Bool, qualityScore: Double, source: String) {
        self.id = UUID()
        self.title = title
        self.url = url
        self.type = type
        self.isFree = isFree
        self.qualityScore = qualityScore
        self.source = source
    }
}
