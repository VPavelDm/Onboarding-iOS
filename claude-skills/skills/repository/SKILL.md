---
name: repository
description: Use when creating or modifying a Repository — the data-access layer. One Repository per data source (REST API, database, AI model, third-party SDK); it constructs the request, sends it, and parses the response into DTOs. No Resource layer, no business logic, no retries, no UI models. Triggers on any edit to *Repository.swift, *RepositoryProtocol.swift, *DTO.swift, or Fake*Repository.swift files. Not needed for trivial edits (typos, renames, constants).
---

# Repositories

Repositories provide data. Each one wraps exactly **one data source** — a REST API, a local database, an AI model, UserDefaults, a third-party SDK — behind a protocol. A Repository constructs the request, sends it, and parses the response into DTOs. Nothing else lives here: retries, error mapping, and UI models belong to the Service layer (see the `service` skill).

## Pattern

Two files (or protocol on top of the impl file — match the feature's existing style): `SomeRepositoryProtocol.swift`, `SomeRepository.swift`. DTOs live next to the repository that produces them.

```swift
protocol LettersRepositoryProtocol {
    func fetchLetters() async throws -> [LetterDTO]
    func createLetter(_ body: CreateLetterRequestDTO) async throws -> LetterDTO
}

final class LettersRepository: LettersRepositoryProtocol {

    private let session: URLSession
    private let baseURL: URL

    init(session: URLSession = .shared, baseURL: URL = AppEnvironment.apiBaseURL) {
        self.session = session
        self.baseURL = baseURL
    }

    func fetchLetters() async throws -> [LetterDTO] {
        var request = URLRequest(url: baseURL.appending(path: "letters"))
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await session.data(for: request)
        try HTTPError.check(response)
        return try JSONDecoder().decode([LetterDTO].self, from: data)
    }

    func createLetter(_ body: CreateLetterRequestDTO) async throws -> LetterDTO {
        var request = URLRequest(url: baseURL.appending(path: "letters"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await session.data(for: request)
        try HTTPError.check(response)
        return try JSONDecoder().decode(LetterDTO.self, from: data)
    }
}
```

Rules the template encodes:
- **One repository per data source.** The users API, the AI model, the local database, and UserDefaults each get their own repository. A repository never calls another repository — combining sources is Service work.
- **Build the request, send it, decode the DTO — inline in the method.** No separate Resource/endpoint layer; the repository method is the whole round trip.
- **DTOs mirror the wire format exactly.** `Codable` structs named `*DTO` (`LetterDTO`, `CreateLetterRequestDTO`), fields matching the JSON. No convenience computed properties, no UI concerns — mapping to UI models happens in the Service.
- **Throw raw errors.** Transport errors, `HTTPError`, `DecodingError` propagate as-is; interpreting them for the user (and retrying) is the Service's job.
- Non-HTTP sources follow the same shape: a database repository wraps queries, an AI repository wraps the model call, a UserDefaults repository wraps keys — always protocol + DTO out.

## Fake (for every Repository protocol)

Same `stub_` closure pattern as Services (full rules in the `service` skill):

```swift
final class FakeLettersRepository: LettersRepositoryProtocol {

    var stub_fetchLetters: () throws -> [LetterDTO] = {
        [LetterDTO(id: "letter84712", message: "message30956", deliveryDate: "2030-01-01T09:00:00Z")]
    }
    var stub_createLetter: (CreateLetterRequestDTO) throws -> LetterDTO = { body in
        LetterDTO(id: "letter84712", message: body.message, deliveryDate: body.deliveryDate)
    }

    func fetchLetters() async throws -> [LetterDTO] {
        try stub_fetchLetters()
    }

    func createLetter(_ body: CreateLetterRequestDTO) async throws -> LetterDTO {
        try stub_createLetter(body)
    }
}
```

## Testing

- Repositories are mostly declarative request-building + decoding; test what can break: DTO decoding against fixture JSON (including nulls/missing fields), request construction (path, method, headers, body) via a `URLProtocol` stub when it matters.
- Swift Testing (`@Suite` struct, `#expect`), same conventions as the `viewmodel` skill.
