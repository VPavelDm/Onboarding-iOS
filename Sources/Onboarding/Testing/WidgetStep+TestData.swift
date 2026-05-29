#if !os(Android)
import Foundation

extension WidgetStep {
    static var testData: WidgetStep {
        return WidgetStep(
            image: .init(imageType: .named("IPhone"), aspectRatioType: "fit"),
            nextStepID: nil
        )
    }
}
#endif
