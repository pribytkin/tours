import SwiftUI

struct AudioPlayerView: View {
    @StateObject private var audioManager = AudioManager()
    let audioContent: AudioContent
    
    var body: some View {
        VStack(spacing: 16) {
            // Title and subtitle
            VStack(spacing: 4) {
                Text(audioContent.title)
                    .font(.headline)
                
                if let subtitle = audioManager.currentSubtitle {
                    Text(subtitle.text)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .animation(.easeInOut, value: subtitle.id)
                }
            }
            
            // Progress slider
            Slider(value: Binding(
                get: { audioManager.currentTime },
                set: { audioManager.seek(to: $0) }
            ), in: 0...audioManager.duration)
            .disabled(audioManager.duration == 0)
            
            // Time labels
            HStack {
                Text(formatTime(audioManager.currentTime))
                Spacer()
                Text(formatTime(audioManager.duration))
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            // Playback controls
            HStack(spacing: 40) {
                Button(action: {
                    audioManager.seek(to: max(0, audioManager.currentTime - 10))
                }) {
                    Image(systemName: "gobackward.10")
                        .font(.title2)
                }
                
                Button(action: {
                    audioManager.togglePlayback()
                }) {
                    Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                }
                
                Button(action: {
                    audioManager.seek(to: min(audioManager.duration, audioManager.currentTime + 10))
                }) {
                    Image(systemName: "goforward.10")
                        .font(.title2)
                }
            }
            
            // Volume control
            HStack {
                Image(systemName: "speaker.fill")
                    .foregroundColor(.secondary)
                Slider(value: $audioManager.volume)
                Image(systemName: "speaker.wave.3.fill")
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
        }
        .padding()
        .onAppear {
            audioManager.play(audioContent)
        }
        .onDisappear {
            audioManager.cleanup()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleURL = URL(fileURLWithPath: "sample.mp3")
        let sampleContent = AudioContent(
            title: "Sample Audio",
            audioURL: sampleURL,
            duration: 180,
            transcription: [
                SubtitleItem(startTime: 0, endTime: 5, text: "Sample subtitle text")
            ]
        )
        
        AudioPlayerView(audioContent: sampleContent)
            .previewLayout(.sizeThatFits)
            .padding()
    }
} 