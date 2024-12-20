import SwiftUI

struct POIAnnotationView: View {
    let poi: POI
    @State private var showTitle = true
    
    var body: some View {
        VStack(spacing: 0) {
            if showTitle {
                Text(poi.name)
                    .font(.caption)
                    .padding(4)
                    .background(Color.white)
                    .cornerRadius(4)
                    .shadow(radius: 2)
            }
            
            Image(systemName: poi.category.icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .padding(8)
                .background(Color.accentColor)
                .clipShape(Circle())
                .shadow(radius: 2)
        }
        .onTapGesture {
            withAnimation {
                showTitle.toggle()
            }
        }
    }
}

struct POIAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        POIAnnotationView(poi: POI.samplePOIs[0])
            .previewLayout(.sizeThatFits)
            .padding()
    }
} 