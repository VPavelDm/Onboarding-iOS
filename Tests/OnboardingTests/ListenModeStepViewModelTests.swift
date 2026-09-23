import Foundation
import Testing
@testable import Onboarding

@MainActor
struct ListenModeStepViewModelTests {

    @Test func test_load_thenTakesTheSamplesTheHostGives() async {
        let (viewModel, _) = await loadedViewModel(count: 3)

        #expect(viewModel.samples.count == 3)
        #expect(viewModel.currentSample?.word == "Wort0")
    }

    @Test func test_playCurrentSample_whenCalledRepeatedly_thenWalksTheQueueAndWrapsAround() async {
        let (viewModel, player) = await loadedViewModel(count: 3)

        for _ in 0..<4 {
            await viewModel.playCurrentSample()
        }

        #expect(player.played.map(\.word) == ["Wort0", "Wort1", "Wort2", "Wort0"])
    }

    /// The word moves on when the audio ends, not on a timer, so the screen never runs ahead of
    /// what is being heard.
    @Test func test_playCurrentSample_thenAdvancesOnlyAfterTheSampleFinishes() async {
        let (viewModel, player) = await loadedViewModel(count: 3)

        await viewModel.playCurrentSample()

        #expect(player.played.count == 1)
        #expect(viewModel.index == 1)
    }

    @Test func test_playCurrentSample_whenPaused_thenStopsInsteadOfPlaying() async {
        let (viewModel, player) = await loadedViewModel(count: 3)
        viewModel.togglePlaying()

        await viewModel.playCurrentSample()

        #expect(player.played.isEmpty)
        #expect(player.stopCount == 1)
    }

    @Test func test_goToSample_thenWrapsInBothDirections() async {
        let (viewModel, _) = await loadedViewModel(count: 3)

        viewModel.goToSample(offset: -1)
        #expect(viewModel.index == 2)

        viewModel.goToSample(offset: 1)
        #expect(viewModel.index == 0)
    }

    @Test func test_stop_thenPausesAndSilencesThePlayer() async {
        let (viewModel, player) = await loadedViewModel(count: 3)

        viewModel.stop()

        #expect(viewModel.isPlaying == false)
        #expect(player.stopCount == 1)
    }

    // MARK: - Player

    @Test func test_play_whenTheSampleHasNoClip_thenTheSpeakerReadsThePhrase() async {
        let speaker = FakeListenModeSpeaker()
        let player = ListenModeStepPlayer(speaker: speaker)

        await player.play(ListenModeSample(word: "der Hund", translation: "the dog", phrase: "Der Hund spielt."))

        #expect(speaker.spoken == ["Der Hund spielt."])
    }

    @Test func test_play_whenTheSampleHasAClip_thenTheSpeakerStaysQuiet() async {
        let speaker = FakeListenModeSpeaker()
        let player = ListenModeStepPlayer(speaker: speaker)
        let missingClip = URL(fileURLWithPath: "/nonexistent/hund.mp3")

        await player.play(ListenModeSample(word: "der Hund", translation: "the dog", phrase: "Der Hund.", clip: missingClip))

        #expect(speaker.spoken.isEmpty)
    }

    @Test func test_stop_thenSilencesTheSpeaker() {
        let speaker = FakeListenModeSpeaker()
        let player = ListenModeStepPlayer(speaker: speaker)

        player.stop()

        #expect(speaker.stopCount == 1)
    }

    // MARK: - Helpers

    private func loadedViewModel(count: Int) async -> (ListenModeStepViewModel, FakeListenModeStepPlayer) {
        let player = FakeListenModeStepPlayer()
        // No waiting in tests: the gap between words is the screen's pacing, not this queue's logic.
        let viewModel = ListenModeStepViewModel(
            fetchSamples: { (0..<count).map { ListenModeSample(word: "Wort\($0)", translation: "translation", phrase: "Wort\($0) im Satz.") } },
            player: player,
            gap: .zero
        )
        await viewModel.load()
        return (viewModel, player)
    }
}

@MainActor
private final class FakeListenModeStepPlayer: ListenModeStepPlayerProtocol {
    private(set) var played: [ListenModeSample] = []
    private(set) var stopCount = 0

    func play(_ sample: ListenModeSample) async {
        played.append(sample)
    }

    func stop() {
        stopCount += 1
    }
}

@MainActor
private final class FakeListenModeSpeaker: ListenModeSpeaking {
    private(set) var spoken: [String] = []
    private(set) var stopCount = 0

    func speak(_ text: String) async {
        spoken.append(text)
    }

    func stop() {
        stopCount += 1
    }
}
