import SwiftUI

/// Transport only. There is no scrubber: a sample is a recorded clip or a sentence the speaker
/// reads, and a spoken one has no length to draw a position against.
struct ListenModePlayerControls: View {
    let copy: ListenModeStepCopy
    let color: Color
    let isPlaying: Bool
    let onPlayPause: () -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 44) {
            backwardButton
            playPauseButton
            forwardButton
        }
    }

    private var backwardButton: some View {
        Button(action: onPrevious) {
            Image(systemName: "backward.fill")
                .font(.system(size: .skipGlyphSize))
                .foregroundStyle(color)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(verbatim: copy.previousWord))
    }

    private var forwardButton: some View {
        Button(action: onNext) {
            Image(systemName: "forward.fill")
                .font(.system(size: .skipGlyphSize))
                .foregroundStyle(color)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(verbatim: copy.nextWord))
    }

    /// Drawn as the system player draws it: three glyphs of the same colour, the middle one large
    /// enough to be the obvious target, and no disc behind it.
    private var playPauseButton: some View {
        Button(action: onPlayPause) {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: .playGlyphSize))
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(verbatim: isPlaying ? copy.pause : copy.play))
    }
}

/// Animated equalizer bars: heights randomize on a loop while playing, settle to a flat line when
/// paused.
struct ListenModeWaveformView: View {
    let isPlaying: Bool
    let color: Color

    @State private var heights: [CGFloat] = Array(repeating: 12, count: .barCount)
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let restingHeight: CGFloat = 6

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<Int.barCount, id: \.self) { index in
                Capsule()
                    .fill(isPlaying ? color.opacity(0.8) : Color.white.opacity(0.25))
                    .frame(width: 3, height: heights[index])
            }
        }
        .frame(height: 36)
        .accessibilityHidden(true)
        .task(id: isPlaying) {
            guard isPlaying, !reduceMotion else {
                withAnimation(.easeOut(duration: 0.35)) {
                    heights = Array(repeating: restingHeight, count: heights.count)
                }
                return
            }
            while !Task.isCancelled {
                withAnimation(.easeInOut(duration: 0.35)) {
                    heights = heights.map { _ in CGFloat.random(in: 6...32) }
                }
                try? await Task.sleep(for: .milliseconds(180))
            }
        }
    }
}

private extension CGFloat {

    static let playGlyphSize: CGFloat = 32
    static let skipGlyphSize: CGFloat = 20
}

private extension Int {

    static let barCount: Int = 17
}
