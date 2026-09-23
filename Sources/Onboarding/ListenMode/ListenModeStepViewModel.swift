import Foundation

/// Runs the listen mode step: a short queue of words that plays through itself, one after the
/// next, until the user pauses it or moves on.
@Observable
@MainActor
final class ListenModeStepViewModel {

    // MARK: - Properties

    private(set) var samples: [ListenModeSample] = []
    private(set) var index: Int = 0
    private(set) var isPlaying: Bool = true

    private let fetchSamples: @MainActor () async -> [ListenModeSample]
    private let player: ListenModeStepPlayerProtocol
    /// The pause between one word finishing and the next starting.
    private let gap: Duration

    // MARK: - Inits

    init(
        fetchSamples: @escaping @MainActor () async -> [ListenModeSample],
        player: ListenModeStepPlayerProtocol,
        gap: Duration = .betweenSamples
    ) {
        self.fetchSamples = fetchSamples
        self.player = player
        self.gap = gap
    }

    // MARK: - Derived

    var currentSample: ListenModeSample? {
        samples.indices.contains(index) ? samples[index] : nil
    }

    // MARK: - Intents

    func load() async {
        samples = await fetchSamples()
    }

    /// Plays the word the screen is on and moves to the next one. Moving is what makes the screen
    /// ask for the next play, so the queue walks itself without a loop to cancel: pausing or
    /// skipping cancels the call in flight and the audio with it.
    func playCurrentSample() async {
        guard isPlaying, let sample = currentSample else {
            player.stop()
            return
        }
        await player.play(sample)
        guard !Task.isCancelled else { return }

        // A beat between words, so one has finished before the next starts rather than the two
        // running together. Cancelling during it — a pause or a skip — stops the queue here.
        try? await Task.sleep(for: gap)
        guard !Task.isCancelled else { return }

        goToSample(offset: 1)
    }

    func togglePlaying() {
        isPlaying.toggle()
    }

    func goToSample(offset: Int) {
        guard !samples.isEmpty else { return }
        index = (index + offset + samples.count) % samples.count
    }

    func stop() {
        isPlaying = false
        player.stop()
    }
}

private extension Duration {

    static let betweenSamples: Duration = .milliseconds(1500)
}
