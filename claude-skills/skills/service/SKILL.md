---
name: service
description: 'Use when creating or modifying a Service — the layer between ViewModels and Repositories. Services own everything around the data: retry mechanism, error handling and mapping, and parsing DTOs into UI models; they orchestrate one or more Repositories. Triggers on any edit to *Service.swift, *ServiceProtocol.swift, or Fake*Service.swift files. Not needed for trivial edits (typos, renames, constants).'
---

# Services

Services sit between ViewModels and Repositories. Repositories fetch raw data as DTOs (see the `repository` skill); Services do **everything else**:

- **Map DTOs into UI models** — the types the ViewModel and View actually use
- **Retry mechanism** — decide what's retryable and how often
- **Error handling** — translate transport/decoding errors into errors the UI can present
- **Orchestrate** — combine multiple repositories when a feature needs more than one data source

ViewModels inject Services, never Repositories directly.

## Pattern

Two files: `SomeServiceProtocol.swift`, `SomeService.swift`.

```swift
protocol LettersServiceProtocol {
    func loadLetters() async throws -> [Letter]
    func createLetter(message: String, deliveryDate: Date) async throws -> Letter
}

final class LettersService: LettersServiceProtocol {

    private let repository: LettersRepositoryProtocol

    init(repository: LettersRepositoryProtocol = LettersRepository()) {
        self.repository = repository
    }

    func loadLetters() async throws -> [Letter] {
        do {
            let dtos = try await withRetry { try await repository.fetchLetters() }
            return dtos.map(Letter.init(dto:))
        } catch {
            throw LettersError(wrapping: error)
        }
    }

    func createLetter(message: String, deliveryDate: Date) async throws -> Letter {
        let body = CreateLetterRequestDTO(
            message: message,
            deliveryDate: ISO8601DateFormatter().string(from: deliveryDate)
        )
        do {
            // Writes are NOT retried blindly — only when the operation is idempotent.
            let dto = try await repository.createLetter(body)
            return Letter(dto: dto)
        } catch {
            throw LettersError(wrapping: error)
        }
    }
}
```

### Retry helper

One shared helper; exponential backoff; only transient failures are retried:

```swift
func withRetry<T>(
    attempts: Int = 3,
    initialDelay: Duration = .milliseconds(300),
    operation: () async throws -> T
) async throws -> T {
    var delay = initialDelay
    for attempt in 1...attempts {
        do {
            return try await operation()
        } catch where attempt < attempts && error.isTransient {
            try await Task.sleep(for: delay)
            delay *= 2
        }
    }
    // Final attempt — let the error propagate.
    return try await operation()
}
```

`isTransient` covers timeouts, connectivity loss, and 5xx — never 4xx, decoding errors, or cancellation.

### UI models & error mapping

- UI models (`Letter`, not `LetterDTO`) live in the feature's `Model/` folder: proper Swift types (`Date` not ISO strings, enums not raw strings), plus whatever the View needs. Map in an `init(dto:)`.
- Errors surface as one feature error type the UI can switch over (e.g. `.offline`, `.serverDown`, `.unknown`) — ViewModels never inspect `URLError` codes or HTTP statuses themselves.

## Fake (for every Service protocol)

```swift
final class FakeLettersService: LettersServiceProtocol {

    var stub_loadLetters: () throws -> [Letter] = {
        [Letter(id: "letter84712", message: "message30956", deliveryDate: .distantFuture)]
    }
    var stub_createLetter: (String, Date) throws -> Letter = { message, date in
        Letter(id: "letter84712", message: message, deliveryDate: date)
    }

    func loadLetters() async throws -> [Letter] {
        try stub_loadLetters()
    }

    func createLetter(message: String, deliveryDate: Date) async throws -> Letter {
        try stub_createLetter(message, deliveryDate)
    }
}
```

Fake rules:
- `final`, one `stub_` closure per protocol method.
- Stub closures are NOT `async` (eases testing) but ARE `throws` (to test failure paths).
- Descriptive, uniquely identifiable default values (`"letter84712"`, not `"id123"`).
- No logic besides calling stubs — no call counters, no recording arrays.

## Third-party SDKs

Wrap SDK access behind the same protocol shape so it stays fakeable — the SDK call itself goes in a Repository (one per SDK), the Service on top owns mapping and errors as usual.

## Testing

- Test the Service against a `Fake*Repository`: DTO→model mapping, error mapping per failure kind, retry behavior (transient error then success).
- Swift Testing (`@Suite` struct, `makeService` factory with Fake defaults, `#expect`), same conventions as the `viewmodel` skill.
