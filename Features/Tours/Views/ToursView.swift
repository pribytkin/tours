import SwiftUI

struct ToursView: View {
    let tours = Tour.sampleTours
    @State private var selectedTour: Tour?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(tours) { tour in
                    TourRowView(tour: tour)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedTour = tour
                        }
                }
            }
            .navigationTitle("Tours")
            .sheet(item: $selectedTour) { tour in
                TourDetailView(tour: tour)
            }
        }
    }
}

struct TourRowView: View {
    let tour: Tour
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: tour.category.icon)
                    .foregroundColor(.accentColor)
                Text(tour.name)
                    .font(.headline)
            }
            
            Text(tour.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Image(systemName: "mappin.circle.fill")
                Text("\(tour.pois.count) points")
                
                Image(systemName: "clock.fill")
                Text("\(Int(tour.estimatedDuration / 60)) min")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct TourDetailView: View {
    let tour: Tour
    @Environment(\.dismiss) private var dismiss
    @StateObject private var routeManager = RouteManager()
    
    var body: some View {
        NavigationView {
            List {
                Section("Description") {
                    Text(tour.description)
                }
                
                Section("Points of Interest") {
                    ForEach(tour.pois) { poi in
                        VStack(alignment: .leading) {
                            Text(poi.name)
                                .font(.headline)
                            Text(poi.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                if let distance = routeManager.totalDistance {
                    Section("Route Details") {
                        HStack {
                            Image(systemName: "figure.walk")
                            Text("Walking distance: \(String(format: "%.1f", distance / 1000)) km")
                        }
                        HStack {
                            Image(systemName: "clock")
                            Text("Estimated time: \(Int(distance / 1000 * 12)) min")
                        }
                    }
                }
            }
            .navigationTitle(tour.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Start Tour") {
                        routeManager.calculateRoute(for: tour)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ToursView_Previews: PreviewProvider {
    static var previews: some View {
        ToursView()
    }
} 