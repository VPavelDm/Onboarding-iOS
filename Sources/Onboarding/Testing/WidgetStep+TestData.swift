import Foundation

extension WidgetStep {
    static var testData: WidgetStep {
        return WidgetStep(
            title: "Add a free widget to your home screen",
            description: "On your phone's Home Screen, touch and hold an empty area, the tap Edit",
            image: .init(imageType: .named("IPhone"), aspectRationType: "fit"),
            answer: StepAnswer(title: "Ok, got it!")
        )
    }
}
