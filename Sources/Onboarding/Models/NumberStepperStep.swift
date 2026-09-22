import Foundation

/// Picks one number out of a short list of options and shows what that choice adds up to. The
/// options and the arithmetic behind each tile are carried in the payload, so a daily goal, a
/// weekly budget or a session length are all the same step.
struct NumberStepperStep: Sendable, Equatable, Hashable {
    let title: String
    let description: String?
    let options: [Int]
    /// The option the step opens on. Without one it opens in the middle of the list.
    let defaultOption: Int?
    let tiles: [Tile]
    let answer: StepAnswer

    /// What the chosen number comes to, in a unit the user already thinks in.
    struct Tile: Sendable, Equatable, Hashable {
        let label: String
        let arithmetic: Arithmetic

        enum Arithmetic: Sendable, Equatable, Hashable {
            /// The choice repeated: 10 a day is 300 over 30 days.
            case multiplied(by: Int)
            /// How long the choice takes to reach a target: 1000 words at 10 a day is 100 days.
            case dividedInto(Int)
        }

        func value(forOption option: Int) -> Int {
            switch arithmetic {
            case .multiplied(let factor): option * factor
            case .dividedInto(let target): target / max(option, 1)
            }
        }
    }

    var defaultIndex: Int {
        defaultOption.flatMap(options.firstIndex(of:)) ?? options.count / 2
    }
}

// MARK: - Convert

extension NumberStepperStep {

    init(response: OnboardingStepResponse.NumberStepperStep) {
        self.init(
            title: response.title,
            description: response.description,
            options: response.options,
            defaultOption: response.defaultOption,
            tiles: response.tiles.compactMap(Tile.init(response:)),
            answer: StepAnswer(response: response.answer)
        )
    }
}

extension NumberStepperStep.Tile {

    /// A tile whose payload says neither what to multiply nor what to divide into has nothing to
    /// show, so it is dropped rather than drawn empty.
    init?(response: OnboardingStepResponse.NumberStepperStep.Tile) {
        guard let arithmetic = Arithmetic(response: response) else { return nil }
        self.init(label: response.label, arithmetic: arithmetic)
    }
}

extension NumberStepperStep.Tile.Arithmetic {

    init?(response: OnboardingStepResponse.NumberStepperStep.Tile) {
        if let factor = response.multiplyBy {
            self = .multiplied(by: factor)
        } else if let target = response.divideInto {
            self = .dividedInto(target)
        } else {
            return nil
        }
    }
}
