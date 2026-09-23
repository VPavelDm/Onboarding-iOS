import Foundation

/// One item the listen mode step reads out: the word, what it means, and the sentence it is used
/// in. A sample either carries a recorded clip or is read aloud by the host's speaker.
public struct ListenModeSample: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let word: String
    public let translation: String
    public let phrase: String
    /// A recorded clip to play, or `nil` for a sample the speaker reads aloud.
    public let clip: URL?

    public init(id: UUID = UUID(), word: String, translation: String, phrase: String, clip: URL? = nil) {
        self.id = id
        self.word = word
        self.translation = translation
        self.phrase = phrase
        self.clip = clip
    }
}
