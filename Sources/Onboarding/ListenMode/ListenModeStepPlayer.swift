import Foundation

/// Plays one sample and returns when it has finished, so the step moves to the next word on the
/// audio rather than on a timer.
@MainActor
protocol ListenModeStepPlayerProtocol: AnyObject {
    func play(_ sample: ListenModeSample) async
    func stop()
}

@MainActor
final class ListenModeStepPlayer: ListenModeStepPlayerProtocol {

    // MARK: - Properties

    private let clipPlayer: ListenModeClipPlayer
    private let speaker: ListenModeSpeaking

    // MARK: - Inits

    init(speaker: ListenModeSpeaking) {
        self.speaker = speaker
        self.clipPlayer = ListenModeClipPlayer()
    }

    // MARK: - Intents

    /// A sample with a clip plays the recording; the rest are read by the host's speaker.
    func play(_ sample: ListenModeSample) async {
        if let clip = sample.clip {
            await clipPlayer.play(clip)
        } else {
            await speaker.speak(sample.phrase)
        }
    }

    func stop() {
        clipPlayer.stop()
        speaker.stop()
    }
}
