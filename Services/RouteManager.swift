import MapKit

class RouteManager: ObservableObject {
    @Published var routes: [MKRoute] = []
    @Published var selectedTour: Tour?
    @Published var isCalculating = false
    @Published var totalDistance: CLLocationDistance = 0
    
    func calculateRoute(for tour: Tour) {
        isCalculating = true
        routes.removeAll()
        totalDistance = 0
        
        guard tour.pois.count >= 2 else {
            isCalculating = false
            return
        }
        
        let group = DispatchGroup()
        
        // Calculate routes between consecutive POIs
        for i in 0..<(tour.pois.count - 1) {
            group.enter()
            
            let source = tour.pois[i]
            let destination = tour.pois[i + 1]
            
            let sourcePlacemark = MKPlacemark(coordinate: source.coordinate)
            let destinationPlacemark = MKPlacemark(coordinate: destination.coordinate)
            
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: sourcePlacemark)
            request.destination = MKMapItem(placemark: destinationPlacemark)
            request.transportType = .walking
            
            let directions = MKDirections(request: request)
            directions.calculate { [weak self] response, error in
                defer { group.leave() }
                
                if let error = error {
                    print("Route calculation error: \(error.localizedDescription)")
                    return
                }
                
                if let route = response?.routes.first {
                    DispatchQueue.main.async {
                        self?.routes.append(route)
                        self?.totalDistance += route.distance
                    }
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.isCalculating = false
            self?.selectedTour = tour
        }
    }
    
    func clearRoutes() {
        routes.removeAll()
        selectedTour = nil
        totalDistance = 0
    }
} 