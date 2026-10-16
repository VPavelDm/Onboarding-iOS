import AVFoundation

/// Plays a recorded clip and returns when it ends, or straight away when it cannot be opened.
@MainActor
final class ListenModeClipPlayer: NSObject {
    private var player: AVAudioPlayer?
    private var finished: CheckedContinuation<Void, Never>?

    func play(_ url: URL) async {
        stop()

        await ListenModeAudioSession.activate()
        guard !Task.isCancelled, let player = await Self.preparedPlayer(contentsOf: url) else { return }
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

    /// Opening a clip decodes it and preparing acquires the audio hardware, and both block their
    /// caller, which on the main thread is what AVAudioSession warns about. Prepared once the
    /// session is active, on a background executor, the player finds the hardware already running
    /// when it plays.
    private nonisolated static func preparedPlayer(contentsOf url: URL) async -> AVAudioPlayer? {
        await Task.detached(priority: .userInitiated) { () -> PlayerBox? in
            guard let player = try? AVAudioPlayer(contentsOf: url), player.prepareToPlay() else { return nil }
            return PlayerBox(player: player)
        }.value?.player
    }
}

/// Carries a player back from the background executor that built it; nothing touches it there
/// once it is handed over.
private struct PlayerBox: @unchecked Sendable {
    let player: AVAudioPlayer
}

extension ListenModeClipPlayer: AVAudioPlayerDelegate {

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.player = nil
            resumeFinished()
        }
    }
}
