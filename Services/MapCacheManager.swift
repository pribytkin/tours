import MapKit

class MapCacheManager: ObservableObject {
    @Published var isDownloading = false
    @Published var downloadProgress: Float = 0
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    init() {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        cacheDirectory = documentsPath.appendingPathComponent("MapCache")
        
        try? fileManager.createDirectory(at: cacheDirectory, 
                                       withIntermediateDirectories: true)
    }
    
    func cacheMapRegion(for tour: Tour, zoomLevels: ClosedRange<Int> = 13...16) {
        guard !isDownloading else { return }
        isDownloading = true
        downloadProgress = 0
        
        // Calculate region that encompasses all POIs
        var minLat = Double.infinity
        var maxLat = -Double.infinity
        var minLon = Double.infinity
        var maxLon = -Double.infinity
        
        tour.pois.forEach { poi in
            minLat = min(minLat, poi.coordinate.latitude)
            maxLat = max(maxLat, poi.coordinate.latitude)
            minLon = min(minLon, poi.coordinate.longitude)
            maxLon = max(maxLon, poi.coordinate.longitude)
        }
        
        // Add some padding
        let latPadding = (maxLat - minLat) * 0.1
        let lonPadding = (maxLon - minLon) * 0.1
        
        minLat -= latPadding
        maxLat += latPadding
        minLon -= lonPadding
        maxLon += lonPadding
        
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2,
                longitude: (minLon + maxLon) / 2
            ),
            span: MKCoordinateSpan(
                latitudeDelta: maxLat - minLat,
                longitudeDelta: maxLon - minLon
            )
        )
        
        downloadTiles(for: region, zoomLevels: zoomLevels)
    }
    
    private func downloadTiles(for region: MKCoordinateRegion, zoomLevels: ClosedRange<Int>) {
        let tileOverlay = MKTileOverlay()
        var totalTiles = 0
        var downloadedTiles = 0
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            for zoom in zoomLevels {
                let tiles = self.getTileCoordinates(for: region, zoomLevel: zoom)
                totalTiles += tiles.count
                
                for tile in tiles {
                    let url = tileOverlay.url(forTilePath: tile)
                    let localURL = self.cacheDirectory
                        .appendingPathComponent("\(zoom)_\(tile.x)_\(tile.y).cache")
                    
                    if !self.fileManager.fileExists(atPath: localURL.path) {
                        if let data = try? Data(contentsOf: url) {
                            try? data.write(to: localURL)
                        }
                    }
                    
                    downloadedTiles += 1
                    DispatchQueue.main.async {
                        self.downloadProgress = Float(downloadedTiles) / Float(totalTiles)
                        if downloadedTiles == totalTiles {
                            self.isDownloading = false
                        }
                    }
                }
            }
        }
    }
    
    private func getTileCoordinates(for region: MKCoordinateRegion, zoomLevel: Int) -> [(x: Int, y: Int, z: Int)] {
        let minLat = region.center.latitude - region.span.latitudeDelta / 2
        let maxLat = region.center.latitude + region.span.latitudeDelta / 2
        let minLon = region.center.longitude - region.span.longitudeDelta / 2
        let maxLon = region.center.longitude + region.span.longitudeDelta / 2
        
        let minX = Int(floor((minLon + 180.0) / 360.0 * pow(2.0, Double(zoomLevel))))
        let maxX = Int(floor((maxLon + 180.0) / 360.0 * pow(2.0, Double(zoomLevel))))
        let minY = Int(floor((1.0 - log(tan(maxLat * .pi / 180.0) + 1.0 / cos(maxLat * .pi / 180.0)) / .pi) / 2.0 * pow(2.0, Double(zoomLevel))))
        let maxY = Int(floor((1.0 - log(tan(minLat * .pi / 180.0) + 1.0 / cos(minLat * .pi / 180.0)) / .pi) / 2.0 * pow(2.0, Double(zoomLevel))))
        
        var tiles: [(x: Int, y: Int, z: Int)] = []
        
        for x in minX...maxX {
            for y in minY...maxY {
                tiles.append((x: x, y: y, z: zoomLevel))
            }
        }
        
        return tiles
    }
    
    func clearCache() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, 
                                       withIntermediateDirectories: true)
    }
} 