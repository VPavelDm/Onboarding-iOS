import Testing
@testable import Onboarding

struct NumberStepperTileTests {

    @Test func test_dividedInto_whenTheChoiceDividesEvenly_thenGivesTheExactCount() {
        let tile = NumberStepperStep.Tile(label: "days to 1000 words", arithmetic: .dividedInto(1000))

        #expect(tile.value(forOption: 10) == 100)
    }

    @Test func test_dividedInto_whenTheChoiceLeavesARemainder_thenRoundsUp() {
        let tile = NumberStepperStep.Tile(label: "days to 1000 words", arithmetic: .dividedInto(1000))

        #expect(tile.value(forOption: 15) == 67)
    }

    @Test func test_multiplied_thenRepeatsTheChoice() {
        let tile = NumberStepperStep.Tile(label: "words a month", arithmetic: .multiplied(by: 30))

        #expect(tile.value(forOption: 15) == 450)
    }
}
