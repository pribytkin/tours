import AVFoundation
import Combine

class AudioManager: NSObject, ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var currentSubtitle: SubtitleItem?
    @Published var volume: Float = 1.0
    
    private var audioPlayer: AVPlayer?
    private var timeObserver: Any?
    private var currentContent: AudioContent?
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        setupAudioSession()
        
        // Handle audio interruptions
        NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)
            .sink { [weak self] notification in
                self?.handleAudioInterruption(notification: notification)
            }
            .store(in: &cancellables)
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    func play(_ content: AudioContent) {
        guard content.isDownloaded else {
            print("Audio content is not downloaded")
            return
        }
        
        currentContent = content
        
        let playerItem = AVPlayerItem(url: content.audioURL)
        audioPlayer = AVPlayer(playerItem: playerItem)
        audioPlayer?.volume = volume
        
        // Add time observer
        timeObserver = audioPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
            self?.updateCurrentSubtitle(at: time.seconds)
        }
        
        // Observe duration
        playerItem.publisher(for: \.duration)
            .map { $0.seconds }
            .replaceError(with: 0)
            .receive(on: RunLoop.main)
            .assign(to: &$duration)
        
        audioPlayer?.play()
        isPlaying = true
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            audioPlayer?.play()
            isPlaying = true
        }
    }
    
    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        audioPlayer?.seek(to: cmTime)
        updateCurrentSubtitle(at: time)
    }
    
    private func updateCurrentSubtitle(at time: TimeInterval) {
        currentSubtitle = currentContent?.transcription.first { subtitle in
            time >= subtitle.startTime && time <= subtitle.endTime
        }
    }
    
    private func handleAudioInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            pause()
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                audioPlayer?.play()
                isPlaying = true
            }
        @unknown default:
            break
        }
    }
    
    func cleanup() {
        if let timeObserver = timeObserver {
            audioPlayer?.removeTimeObserver(timeObserver)
        }
        audioPlayer = nil
        currentContent = nil
        timeObserver = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        currentSubtitle = nil
    }
    
    deinit {
        cleanup()
    }
} 