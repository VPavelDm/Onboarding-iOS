import AVFoundation

/// The playback session the step holds while it is on screen, so a clip plays through the silent
/// switch and other audio yields to it.
enum ListenModeAudioSession {

    static func activate() async {
        #if os(iOS)
        try? await Task.detached(priority: .userInitiated) {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        }.value
        #endif
    }

    static func deactivate() {
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        #endif
    }
}
