import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var routeManager = RouteManager()
    @State private var userTrackingMode: MapUserTrackingMode = .follow
    @State private var selectedPOI: POI?
    @State private var showTourList = false
    
    private let pois = POI.samplePOIs
    private let tours = Tour.sampleTours
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $locationManager.region,
                    showsUserLocation: true,
                    userTrackingMode: $userTrackingMode,
                    annotationItems: pois) { poi in
                    MapAnnotation(coordinate: poi.coordinate) {
                        POIAnnotationView(poi: poi)
                            .onTapGesture {
                                withAnimation {
                                    selectedPOI = poi
                                }
                            }
                    }
                }
                .overlay(
                    ForEach(routeManager.routes.indices, id: \.self) { index in
                        PolylineView(polyline: routeManager.routes[index].polyline)
                    }
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if routeManager.isCalculating {
                        ProgressView("Calculating route...")
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    
                    if let tour = routeManager.selectedTour {
                        VStack {
                            Text(tour.name)
                                .font(.headline)
                            Text(String(format: "%.1f km", routeManager.totalDistance / 1000))
                                .font(.subheadline)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            showTourList = true
                        }) {
                            Image(systemName: "map")
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                userTrackingMode = .follow
                            }
                        }) {
                            Image(systemName: "location.fill")
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(item: $selectedPOI) { poi in
            POIDetailView(poi: poi)
        }
        .sheet(isPresented: $showTourList) {
            TourListView(tours: tours) { tour in
                routeManager.calculateRoute(for: tour)
                showTourList = false
            }
        }
    }
}

struct PolylineView: UIViewRepresentable {
    let polyline: MKPolyline
    
    func makeUIView(context: Context) -> UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // The actual rendering is handled by the MKMapView's overlay renderer
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: PolylineView
        
        init(_ parent: PolylineView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

struct TourListView: View {
    let tours: [Tour]
    let onSelect: (Tour) -> Void
    @StateObject private var mapCacheManager = MapCacheManager()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(tours) { tour in
                VStack(alignment: .leading) {
                    Text(tour.name)
                        .font(.headline)
                    Text(tour.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(tour.pois.count) points of interest")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if mapCacheManager.isDownloading {
                        ProgressView(value: mapCacheManager.downloadProgress) {
                            Text("Downloading map tiles...")
                        }
                        .progressViewStyle(.linear)
                        .padding(.top, 4)
                    } else {
                        Button(action: {
                            mapCacheManager.cacheMapRegion(for: tour)
                        }) {
                            Label("Download offline map", systemImage: "arrow.down.circle")
                        }
                        .padding(.top, 4)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelect(tour)
                }
            }
            .navigationTitle("Available Tours")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct POIDetailView: View {
    let poi: POI
    @State private var showAudioPlayer = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(poi.description)
                        .padding(.horizontal)
                    
                    if poi.audioURL != nil {
                        Button(action: {
                            showAudioPlayer = true
                        }) {
                            Label("Start Audio Guide", systemImage: "play.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .padding(.horizontal)
                        .sheet(isPresented: $showAudioPlayer) {
                            if let url = poi.audioURL {
                                let audioContent = AudioContent(
                                    title: poi.name,
                                    audioURL: url,
                                    duration: AudioContent.calculateDuration(for: url)
                                )
                                AudioPlayerView(audioContent: audioContent)
                                    .presentationDetents([.height(300)])
                            }
                        }
                    }
                    
                    if poi.images.isEmpty {
                        Color.gray
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.white)
                            )
                    }
                }
            }
            .navigationTitle(poi.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
} 