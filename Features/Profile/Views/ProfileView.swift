import SwiftUI

struct ProfileView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage = Language.english
    @State private var showLanguageSelector = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Settings") {
                    Button(action: {
                        showLanguageSelector = true
                    }) {
                        HStack {
                            Label("Language", systemImage: "globe")
                            Spacer()
                            Text(selectedLanguage.displayName)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Cache") {
                    Button(action: {
                        // TODO: Clear cache
                    }) {
                        Label("Clear Offline Maps", systemImage: "map")
                    }
                    
                    Button(action: {
                        // TODO: Clear audio cache
                    }) {
                        Label("Clear Audio Files", systemImage: "speaker.wave.2")
                    }
                }
                
                Section("About") {
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                    
                    Link(destination: URL(string: "https://example.com/terms")!) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                    
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Profile")
            .confirmationDialog("Select Language",
                              isPresented: $showLanguageSelector,
                              titleVisibility: .visible) {
                ForEach(Language.allCases, id: \.self) { language in
                    Button(language.displayName) {
                        selectedLanguage = language
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
} 