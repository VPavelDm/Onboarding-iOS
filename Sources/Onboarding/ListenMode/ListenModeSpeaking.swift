import Foundation

/// Reads a sample's phrase aloud in whatever voice the host app sells. The step plays recorded
/// clips itself; everything else goes through this.
@MainActor
public protocol ListenModeSpeaking: AnyObject {
    /// Returns once the phrase has been spoken, or straight away when it could not be.
    func speak(_ text: String) async
    func stop()
}

/// The words the step shows, localized by the host: the heading, the button that leaves the
/// step, and the transport's accessibility labels.
public struct ListenModeStepCopy: Sendable {
    public var title: String
    public var description: String
    public var buttonTitle: String
    public var previousWord: String
    public var nextWord: String
    public var play: String
    public var pause: String

    public init(
        title: String,
        description: String,
        buttonTitle: String,
        previousWord: String,
        nextWord: String,
        play: String,
        pause: String
    ) {
        self.title = title
        self.description = description
        self.buttonTitle = buttonTitle
        self.previousWord = previousWord
        self.nextWord = nextWord
        self.play = play
        self.pause = pause
    }
}
