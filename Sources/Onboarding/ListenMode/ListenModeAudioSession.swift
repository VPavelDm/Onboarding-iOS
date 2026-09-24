import AVFoundation

/// The playback session the step holds while it is on screen, so a clip plays through the silent
/// switch and other audio yields to it.
///
/// Activating or deactivating a session blocks its caller while the system negotiates with
/// whatever else is playing, which AVAudioSession warns about on the main thread. iOS 27 has an
/// asynchronous form; before that the work goes to a background executor.
enum ListenModeAudioSession {

    static func activate() async {
        #if os(iOS)
        if #available(iOS 27.0, *) {
            let session = AVAudioSession.sharedInstance()
            try? session.setCategory(.playback, mode: .default)
            _ = try? await session.activate()
        } else {
            try? await Task.detached(priority: .userInitiated) {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playback, mode: .default)
                try session.setActive(true)
            }.value
        }
        #endif
    }

    /// Fire-and-forget: the step is going away and nothing waits on the result.
    static func deactivate() {
        #if os(iOS)
        if #available(iOS 27.0, *) {
            AVAudioSession.sharedInstance().deactivate(options: .notifyOthersOnDeactivation) { _, _ in }
        } else {
            Task.detached(priority: .utility) {
                try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            }
        }
        #endif
    }
}
