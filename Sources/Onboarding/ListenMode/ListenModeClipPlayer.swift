import AVFoundation

/// Plays a recorded clip and returns when it ends, or straight away when it cannot be opened.
@MainActor
final class ListenModeClipPlayer: NSObject {
    private var player: AVAudioPlayer?
    private var finished: CheckedContinuation<Void, Never>?

    func play(_ url: URL) async {
        stop()

        guard let player = try? AVAudioPlayer(contentsOf: url), player.prepareToPlay() else { return }
        await ListenModeAudioSession.activate()
        guard !Task.isCancelled else { return }

        player.delegate = self
        self.player = player
        player.play()

        await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                finished = continuation
            }
        } onCancel: {
            Task { @MainActor in self.stop() }
        }
    }

    func stop() {
        player?.stop()
        player = nil
        resumeFinished()
    }

    private func resumeFinished() {
        finished?.resume()
        finished = nil
    }
}

extension ListenModeClipPlayer: AVAudioPlayerDelegate {

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.player = nil
            resumeFinished()
        }
    }
}
