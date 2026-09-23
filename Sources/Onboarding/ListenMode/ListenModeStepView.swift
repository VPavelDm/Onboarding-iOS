import SwiftUI
import CoreUI

/// A step that plays words to the user, one after another, to show what listening practice
/// sounds like. The host supplies the words and the voice; the step owns the queue, the transport
/// and the recorded clips' playback.
///
/// Meant for a custom step: show it from the `OnboardingView`'s custom-step builder and call the
/// step's params from `onClose`.
public struct ListenModeStepView: View {
    @State private var viewModel: ListenModeStepViewModel

    private let copy: ListenModeStepCopy
    private let colorPalette: ColorPalette
    private let onClose: () async -> Void

    public init(
        copy: ListenModeStepCopy,
        colorPalette: ColorPalette,
        speaker: ListenModeSpeaking,
        fetchSamples: @escaping @MainActor () async -> [ListenModeSample],
        onClose: @escaping () async -> Void
    ) {
        self.copy = copy
        self.colorPalette = colorPalette
        self.onClose = onClose
        _viewModel = State(
            initialValue: ListenModeStepViewModel(
                fetchSamples: fetchSamples,
                player: ListenModeStepPlayer(speaker: speaker)
            )
        )
    }

    public var body: some View {
        VStack(spacing: 28) {
            Spacer()
            headerSection
            audioCard
            Spacer()
            continueButton
        }
        .padding(.horizontal, UIConstants.hScreenPadding)
        .padding(.bottom, UIConstants.vScreenPadding)
        .task { await viewModel.load() }
        // Keyed on the word itself, not its position: the queue arrives after the screen does, and
        // the first word appearing has to start playback the same way skipping to the next one does.
        .task(id: PlaybackKey(isPlaying: viewModel.isPlaying, sampleID: viewModel.currentSample?.id)) {
            await viewModel.playCurrentSample()
        }
        .onDisappear {
            viewModel.stop()
            ListenModeAudioSession.deactivate()
        }
    }

    private var headerSection: some View {
        VStack(spacing: UIConstants.headingSpacing) {
            titleView
            descriptionView
        }
    }

    private var titleView: some View {
        Text(verbatim: copy.title)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(colorPalette.textColor)
            .multilineTextAlignment(.center)
    }

    private var descriptionView: some View {
        Text(verbatim: copy.description)
            .font(.subheadline)
            .foregroundStyle(colorPalette.textColor.opacity(0.7))
            .multilineTextAlignment(.center)
    }

    private var continueButton: some View {
        AsyncButton {
            viewModel.stop()
            ListenModeAudioSession.deactivate()
            await onClose()
        } label: {
            Text(verbatim: copy.buttonTitle)
        }
        .buttonStyle(PrimaryButtonStyle(colorPalette: colorPalette))
    }

    private var audioCard: some View {
        VStack(spacing: 20) {
            wordView
                // The header belongs to the sample, not to the card: without an identity of its
                // own SwiftUI keeps the same labels and slides them as the words change length.
                .id(viewModel.currentSample?.id)
                .transition(.opacity)
            ListenModeWaveformView(isPlaying: viewModel.isPlaying, color: colorPalette.accentColor)
            ListenModePlayerControls(
                copy: copy,
                color: colorPalette.textColor,
                isPlaying: viewModel.isPlaying,
                onPlayPause: viewModel.togglePlaying,
                onPrevious: { viewModel.goToSample(offset: -1) },
                onNext: { viewModel.goToSample(offset: 1) }
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity)
        .glassBackground(cornerRadius: 20)
        .animation(.easeInOut(duration: 0.45), value: viewModel.currentSample?.id)
    }

    @ViewBuilder
    private var wordView: some View {
        if let sample = viewModel.currentSample {
            VStack(spacing: 6) {
                // The dot is the card's anchor: each side takes half the width, so it stays on the
                // centre line however long the word and its translation are.
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(verbatim: sample.word)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(colorPalette.textColor)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    Text(verbatim: "·")
                        .font(.system(size: 18))
                        .foregroundStyle(colorPalette.textColor.opacity(0.35))
                    Text(verbatim: sample.translation)
                        .font(.system(size: 22))
                        .foregroundStyle(colorPalette.textColor.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .multilineTextAlignment(.center)
                Text(verbatim: sample.phrase)
                    .font(.callout).italic()
                    .foregroundStyle(colorPalette.textColor.opacity(0.75))
                    .multilineTextAlignment(.center)
            }
        }
    }
}

/// What restarts playback: the word being played and whether it is playing at all.
private struct PlaybackKey: Hashable {
    let isPlaying: Bool
    let sampleID: UUID?
}

#Preview {
    ListenModeStepView(
        copy: ListenModeStepCopy(
            title: "Learn while your hands are busy.",
            description: "Press play and the words come to you. Walking, on the train, doing chores.",
            buttonTitle: "Sounds great",
            previousWord: "Previous word",
            nextWord: "Next word",
            play: "Play",
            pause: "Pause"
        ),
        colorPalette: .testData,
        speaker: PreviewListenModeSpeaker(),
        fetchSamples: {
            [ListenModeSample(word: "der Hund", translation: "the dog", phrase: "Der Hund spielt im Park.")]
        },
        onClose: {}
    )
    .background(Color.black)
}

@MainActor
private final class PreviewListenModeSpeaker: ListenModeSpeaking {
    func speak(_ text: String) async {
        try? await Task.sleep(for: .seconds(2))
    }

    func stop() {}
}
