import SwiftUI

struct POIAnnotationView: View {
    let poi: POI
    @State private var showTitle = true
    @State private var isPressed = false
    
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
                .background(isPressed ? Color.accentColor.opacity(0.7) : Color.accentColor)
                .clipShape(Circle())
                .shadow(radius: 2)
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .onTapGesture {
            withAnimation {
                showTitle.toggle()
            }
        }
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity,
                           pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct POIAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        POIAnnotationView(poi: POI.samplePOIs[0])
            .previewLayout(.sizeThatFits)
            .padding()
    }
} 