import Foundation
import AVFoundation

struct AudioContent: Identifiable {
    let id: UUID
    let title: String
    let audioURL: URL
    let duration: TimeInterval
    let language: Language
    let transcription: [SubtitleItem]
    let type: AudioType
    
    init(id: UUID = UUID(),
         title: String,
         audioURL: URL,
         duration: TimeInterval = 0,
         language: Language = .english,
         transcription: [SubtitleItem] = [],
         type: AudioType = .narration) {
        self.id = id
        self.title = title
        self.audioURL = audioURL
        self.duration = duration
        self.language = language
        self.transcription = transcription
        self.type = type
    }
}

struct SubtitleItem: Identifiable {
    let id: UUID
    let startTime: TimeInterval
    let endTime: TimeInterval
    let text: String
    
    init(id: UUID = UUID(),
         startTime: TimeInterval,
         endTime: TimeInterval,
         text: String) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.text = text
    }
}

enum Language: String, CaseIterable {
    case english = "en"
    case spanish = "es"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        }
    }
}

enum AudioType {
    case narration           // Pre-recorded tour narration
    case aiResponse         // AI-generated response
    case userQuestion      // User's recorded question
    
    var allowsTranscription: Bool {
        switch self {
        case .narration: return true
        case .aiResponse: return true
        case .userQuestion: return false
        }
    }
}

// Extension for managing audio metadata
extension AudioContent {
    var isDownloaded: Bool {
        FileManager.default.fileExists(atPath: audioURL.path)
    }
    
    var fileSize: Int64 {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: audioURL.path),
              let size = attributes[.size] as? Int64 else {
            return 0
        }
        return size
    }
    
    static func calculateDuration(for url: URL) -> TimeInterval {
        let asset = AVAsset(url: url)
        return asset.duration.seconds
    }
} 