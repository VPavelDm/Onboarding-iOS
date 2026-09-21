---
name: android-repository
description: Use when creating or modifying an Android Repository — the data-access layer. One Repository per data source (a Supabase edge function group, DataStore, a third-party SDK, assets); it builds the request, sends it, and returns wire DTOs. No business logic, no retries, no mapping, no UI models. Triggers on any edit to *Repository.kt, *Dto.kt, *Params.kt or Fake*Repository.kt files (Kotlin). Not needed for trivial edits (typos, renames, constants).
---

# Repositories (Android)

Repositories provide data. Each one wraps exactly **one data source** — a group of Supabase edge functions, DataStore preferences, a third-party SDK, APK assets — behind an interface. A Repository constructs the request, sends it, and returns the DTO as decoded. Nothing else lives here: retries, error mapping, DTO → domain mapping and UI models belong to the Service (see `android-service`).

## Pattern

One file `WordsRepository.kt`: interface, edge-function implementation, DTOs and params next to it (or `WordsDtos.kt` when they grow).

```kotlin
interface WordsRepository {
    suspend fun fetchWordsPage(params: WordsPageParams): WordsPageDto
    suspend fun fetchWordsCount(params: WordsCountParams): WordsCountDto
    suspend fun remove(params: RemoveWordParams)
}

class EdgeWordsRepository(private val edge: EdgeFunctions) : WordsRepository {

    override suspend fun fetchWordsPage(params: WordsPageParams): WordsPageDto =
        edge.fetch("get-words", params)

    override suspend fun fetchWordsCount(params: WordsCountParams): WordsCountDto =
        edge.fetch("get-words-count", params)

    override suspend fun remove(params: RemoveWordParams) =
        edge.send("delete-word", params)
}

@Serializable
data class WordDto(
    @SerialName("word_id") val wordId: String,
    val word: String,
    val translation: String,
    @SerialName("part_of_speech") val partOfSpeech: PartOfSpeechDto? = null,
    @SerialName("created_at") val createdAt: String,
    val repetitions: Int? = null,
    @SerialName("is_first_reviewed") val isFirstReviewed: Boolean,
    val notes: String? = null,
    @SerialName("usage_examples") val usageExamples: List<UsageExampleDto> = emptyList(),
    @SerialName("word_tags") val tags: List<TagDto> = emptyList(),
)

@Serializable
data class RemoveWordParams(@SerialName("p_word_id") val wordId: String)
```

Rules the template encodes:
- **One repository per data source.** Words, profile, tags, insights each get one over the edge functions; DataStore, RevenueCat, TextToSpeech each get their own. A repository never calls another repository — combining sources is Service work.
- **One edge function per method**, the whole round trip inline: name + params in, DTO out. No endpoint/resource layer.
- **DTOs mirror the wire format exactly.** `@Serializable data class` named `*Dto`, field names via `@SerialName` in snake_case, `String` for UUIDs and ISO 8601 dates, nullable with `= null` defaults where the function may omit a field. No computed properties, no logic — mapping to domain models happens in the Service.
- **Params mirror the DB function signature.** `@Serializable data class *Params` with `@SerialName("p_…")` names, exactly like the iOS `CodingKeys`. The `authID` is never a param — the edge function derives it from the session.
- **Throw raw errors.** `RestException`, `HttpRequestException`, `SerializationException` propagate as-is; interpreting them (and retrying) is the Service's job.
- **Stateless.** No caches, no flows, no `Context`. A cache belongs to a Service.
- Non-HTTP sources follow the same shape: a DataStore repository wraps keys, an SDK repository wraps the SDK call — always interface + DTO/primitive out.

## `EdgeFunctions` (`core/network`, written once)

All repositories share one thin helper so JSON configuration lives in one place — the Kotlin counterpart of the iOS `EdgeFunction.swift` overloads. Kotlin can't overload on return type, so the verbs differ by name:

```kotlin
class EdgeFunctions(
    // `@PublishedApi internal`, not `private`: the public inline functions below must reach them.
    @PublishedApi internal val supabase: SupabaseClient,
    @PublishedApi internal val json: Json,
) {
    /** GET-like: no params, decoded body. */
    suspend inline fun <reified R> fetch(name: String): R =
        json.decodeFromString(supabase.functions.invoke(name).bodyAsText())

    /** Params in, decoded body out. */
    suspend inline fun <reified P : Any, reified R> fetch(name: String, params: P): R =
        json.decodeFromString(supabase.functions.invoke(function = name, body = params).bodyAsText())

    /** Fire and check status only. */
    suspend fun send(name: String) {
        supabase.functions.invoke(name)
    }

    suspend inline fun <reified P : Any> send(name: String, params: P) {
        supabase.functions.invoke(function = name, body = params)
    }

    /** Raw bytes, for functions that answer with something other than JSON — audio, for one. */
    suspend inline fun <reified P : Any> fetchBytes(name: String, params: P): ByteArray =
        supabase.functions.invoke(function = name, body = params).readRawBytes()
}
```

- `supabase.functions.invoke` (supabase-kt `functions-kt`) serialises `body` with the client's default serializer and throws a `RestException` subclass on any non-2xx status, so `send` needs no status check.
- The `Json` instance is the one configured on the client (`ignoreUnknownKeys = true`, `explicitNulls = false`, see `android-app-shell`); decode from `bodyAsText()` rather than relying on Ktor content negotiation so every repository decodes the same way.
- The `SupabaseClient` is created once in the `AppContainer`; repositories receive `EdgeFunctions` through their constructor.

## Fake (for every Repository interface)

Same `stub…` lambda pattern as Services (full rules in `android-service`), in `src/test/kotlin/com/pretzly/testing/`:

```kotlin
class FakeWordsRepository : WordsRepository {

    var stubFetchWordsPage: suspend (WordsPageParams) -> WordsPageDto = { _ ->
        WordsPageDto(words = listOf(WordDto.stub(word = "Fenster", translation = "window")), nextCursor = null)
    }
    var stubFetchWordsCount: suspend (WordsCountParams) -> WordsCountDto = { _ -> WordsCountDto(count = 1) }
    var stubRemove: suspend (RemoveWordParams) -> Unit = {}

    override suspend fun fetchWordsPage(params: WordsPageParams) = stubFetchWordsPage(params)
    override suspend fun fetchWordsCount(params: WordsCountParams) = stubFetchWordsCount(params)
    override suspend fun remove(params: RemoveWordParams) = stubRemove(params)
}
```

## Testing

- Repositories are declarative; test what can break: **DTO decoding against fixture JSON** copied from a real edge-function response (`src/test/resources/fixtures/get-words.json`), including nulls and missing fields, with the same `Json` configuration the app uses.
- Request construction (function name, params encoding) only when it matters — with Ktor's `MockEngine` behind a `SupabaseClient` built for the test. Usually the params `@SerialName`s are checked by encoding a params object and asserting on the JSON string.
- JUnit 4, `runTest`, same conventions as `android-viewmodel`.
