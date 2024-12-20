import Foundation
import MapKit

struct POI: Identifiable {
    let id: UUID
    let name: String
    let description: String
    let coordinate: CLLocationCoordinate2D
    let category: POICategory
    let audioURL: URL?
    let images: [URL]
    let duration: TimeInterval // Duration of audio guide in seconds
    
    init(id: UUID = UUID(), 
         name: String, 
         description: String, 
         coordinate: CLLocationCoordinate2D,
         category: POICategory,
         audioURL: URL? = nil,
         images: [URL] = [],
         duration: TimeInterval = 0) {
        self.id = id
        self.name = name
        self.description = description
        self.coordinate = coordinate
        self.category = category
        self.audioURL = audioURL
        self.images = images
        self.duration = duration
    }
}

enum POICategory: String, CaseIterable {
    case historical = "Historical"
    case cultural = "Cultural"
    case modern = "Modern"
    case nature = "Nature"
    case gastronomy = "Gastronomy"
    
    var icon: String {
        switch self {
        case .historical: return "building.columns"
        case .cultural: return "theatermasks"
        case .modern: return "building"
        case .nature: return "leaf"
        case .gastronomy: return "fork.knife"
        }
    }
}

// Extension to make POI compatible with MapKit annotations
extension POI: Equatable {
    static func == (lhs: POI, rhs: POI) -> Bool {
        lhs.id == rhs.id
    }
}

// Sample POIs for Valencia
extension POI {
    static let samplePOIs: [POI] = [
        POI(name: "City of Arts and Sciences",
            description: "A cultural and architectural complex designed by Santiago Calatrava and Félix Candela.",
            coordinate: CLLocationCoordinate2D(latitude: 39.4543, longitude: -0.3515),
            category: .modern),
        
        POI(name: "Valencia Cathedral",
            description: "Gothic cathedral built between the 13th and 15th centuries, home to the Holy Grail.",
            coordinate: CLLocationCoordinate2D(latitude: 39.4755, longitude: -0.3753),
            category: .historical),
        
        POI(name: "Central Market",
            description: "One of the oldest European markets still running, featuring Art Nouveau architecture.",
            coordinate: CLLocationCoordinate2D(latitude: 39.4736, longitude: -0.3790),
            category: .gastronomy),
        
        POI(name: "Turia Gardens",
            description: "Former riverbed turned into a beautiful park running through the city.",
            coordinate: CLLocationCoordinate2D(latitude: 39.4766, longitude: -0.3714),
            category: .nature),
        
        POI(name: "La Lonja de la Seda",
            description: "UNESCO World Heritage site, a masterpiece of Gothic civil architecture.",
            coordinate: CLLocationCoordinate2D(latitude: 39.4744, longitude: -0.3792),
            category: .historical)
    ]
} 