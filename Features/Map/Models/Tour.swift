import Foundation
import MapKit

struct Tour: Identifiable {
    let id: UUID
    let name: String
    let description: String
    let pois: [POI]
    let category: POICategory
    let estimatedDuration: TimeInterval
    let difficulty: Difficulty
    let distance: Double?
    
    var totalDistance: CLLocationDistance = 0
    
    init(id: UUID = UUID(),
         name: String,
         description: String,
         pois: [POI],
         category: POICategory,
         estimatedDuration: TimeInterval = 0,
         difficulty: Difficulty = .medium,
         distance: Double? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.pois = pois
        self.category = category
        self.estimatedDuration = estimatedDuration
        self.difficulty = difficulty
        self.distance = distance
    }
    
    enum Difficulty: String {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        
        var icon: String {
            switch self {
            case .easy: return "figure.walk"
            case .medium: return "figure.walk.motion"
            case .hard: return "figure.hiking"
            }
        }
    }
}

// Sample tours for Valencia
extension Tour {
    static let sampleTours: [Tour] = [
        Tour(name: "Historical Valencia",
             description: "Explore the rich history of Valencia through its most iconic historical buildings and monuments. Visit the magnificent Cathedral, the historic Silk Exchange, and the bustling Central Market.",
             pois: [
                POI.samplePOIs[1], // Valencia Cathedral
                POI.samplePOIs[4], // La Lonja de la Seda
                POI.samplePOIs[2]  // Central Market
             ],
             category: .historical,
             estimatedDuration: 7200, // 2 hours
             difficulty: .easy),
        
        Tour(name: "Modern Valencia",
             description: "Discover the modern face of Valencia, including the stunning City of Arts and Sciences complex and the beautiful Turia Gardens, a green oasis in the heart of the city.",
             pois: [
                POI.samplePOIs[0], // City of Arts and Sciences
                POI.samplePOIs[3]  // Turia Gardens
             ],
             category: .modern,
             estimatedDuration: 5400, // 1.5 hours
             difficulty: .medium),
        
        Tour(name: "Valencia Essentials",
             description: "Experience the best of Valencia in one comprehensive tour. From historical landmarks to modern architecture, this tour covers the city's must-see attractions.",
             pois: [
                POI.samplePOIs[1], // Valencia Cathedral
                POI.samplePOIs[2], // Central Market
                POI.samplePOIs[0], // City of Arts and Sciences
                POI.samplePOIs[3]  // Turia Gardens
             ],
             category: .cultural,
             estimatedDuration: 10800, // 3 hours
             difficulty: .medium)
    ]
} 