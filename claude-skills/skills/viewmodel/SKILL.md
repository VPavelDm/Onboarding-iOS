---
name: viewmodel
description: Use when creating or modifying any ViewModel — the @Observable pattern, init-injected Services, View ownership, and the Swift Testing template. Triggers on any edit to *ViewModel.swift or *ViewModelTests.swift files, including bug fixes. Not needed for trivial edits (typos, renames, constants).
---

# ViewModels

ViewModels orchestrate Services and hold UI state. Business logic belongs in domain Models; data access belongs in Repositories behind Services (see the `service` and `repository` skills). ViewModels inject Services only — never Repositories directly.

## Template (new ViewModels)

```swift
import Observation

@MainActor
@Observable
final class SomeFeatureViewModel {

    private(set) var isLoading = false
    private(set) var items: [SomeItem] = []
    var error: SomeFeatureError?

    private let service: SomeServiceProtocol

    init(service: SomeServiceProtocol = SomeService()) {
        self.service = service
    }

    func onAppear() async {
        isLoading = true
        defer { isLoading = false }
        do {
            items = try await service.loadItems()
        } catch let serviceError as SomeFeatureError {
            error = serviceError
        } catch {
            self.error = .unknown
        }
    }
}
```

Rules the template encodes:
- `@MainActor @Observable final class`. No `@Published`, no `ObservableObject` in new code.
- State exposed as `private(set) var` unless the View must write it (e.g. text input).
- Dependencies injected via init with default parameters: `service: SomeServiceProtocol = SomeService()`. Tests override the defaults with Fakes.
- ViewModels depend on Services only. Retries, error mapping, and DTO → UI-model parsing already happened in the Service — the ViewModel just presents the outcome; it never inspects `URLError` codes or HTTP statuses.
- Never nest ViewModels — nested observation chains break SwiftUI updates and leak memory. One ViewModel per View, owned directly.

## View ownership

```swift
struct SomeFeatureView: View {
    @State private var viewModel = SomeFeatureViewModel()
}
```

`@State`, never `@StateObject`, for `@Observable` ViewModels.

## Legacy code

Existing `ObservableObject`/`@StateObject`/`@ObservedObject` ViewModels keep their pattern for small edits. Migrate to `@Observable` only when substantially refactoring the feature.

## Testing (Swift Testing — mandatory)

```swift
@testable import SomeApp
import Testing

@Suite
@MainActor
struct SomeFeatureViewModelTests {

    private func makeViewModel(
        service: FakeSomeService = FakeSomeService()
    ) -> SomeFeatureViewModel {
        SomeFeatureViewModel(service: service)
    }

    @Test
    func loadingStateClearsAfterOnAppear() async {
        let viewModel = makeViewModel()

        await viewModel.onAppear()

        #expect(viewModel.isLoading == false)
    }
}
```

- `@Suite @MainActor struct`, a private `makeViewModel` factory with Fake defaults, `#expect` assertions.
- Fakes over mocks — see the `service` skill for the `stub_` closure pattern and Fake rules.
- Test behavior, not coverage. Never delete a failing test — update it to the new behavior.
