---
name: android-service
description: 'Use when creating or modifying an Android Service — the layer between ViewModels and Repositories. Services own everything around the data: retry, error mapping into a per-feature error type, parsing DTOs into domain models, and screen logic (paging, queues, validation); they orchestrate one or more Repositories. Triggers on any edit to *Service.kt, Default*Service.kt or Fake*Service.kt files (Kotlin). Not needed for trivial edits (typos, renames, constants).'
---

# Services (Android)

Services sit between ViewModels and Repositories. Repositories fetch raw data as DTOs (see `android-repository`); Services do **everything else**:

- **Map DTOs into domain models** — typed Kotlin values with no display concerns; the ViewModel derives UI models from them
- **Retry** — decide what's transient and how often to retry it
- **Error handling** — translate transport/decoding errors into one per-feature error type the UI can `when` over
- **Orchestrate** — combine repositories, run independent calls in parallel
- **Own screen logic** — a paging cursor, the exercise queue, answer validation, goal progress: anything worth a unit test without a screen lives here (or in a plain class the Service owns), not in the ViewModel

ViewModels inject Services, never Repositories. Every screen gets a `<Screen>ScreenService`; the iOS `<Screen>ScreenService.swift` is the interface to port.

## Pattern

One file `WordsScreenService.kt` holding the interface, its result types, and the default implementation.

```kotlin
interface WordsScreenService {
    suspend fun reload(query: String, selectedTags: List<WordTag>): ReloadResult
    suspend fun fetchMore(query: String, selectedTags: List<WordTag>, cursor: WordsCursor): WordsPage
    suspend fun remove(word: Word)

    data class ReloadResult(
        val page: WordsPage?,
        val summary: InsightsSummary?,
        val totalCount: Int?,
    ) {
        /** The word list itself failed — lets the UI tell a failed load apart from an empty list. */
        val loadFailed: Boolean get() = page == null
    }
}

class DefaultWordsScreenService(
    private val wordsRepository: WordsRepository,
    private val insightsRepository: InsightsRepository,
) : WordsScreenService {

    override suspend fun reload(query: String, selectedTags: List<WordTag>) = coroutineScope {
        val page = async {
            runSuspendCatching {
                withRetry { wordsRepository.fetchWordsPage(WordsPageParams(query, FETCH_LIMIT, selectedTags.ids())) }
            }.getOrNull()?.toWordsPage()
        }
        val summary = async {
            runSuspendCatching { insightsRepository.fetchSummary() }.getOrNull()?.toInsightsSummary()
        }
        val totalCount = async {
            runSuspendCatching { wordsRepository.fetchWordsCount(WordsCountParams(query, selectedTags.ids())) }.getOrNull()?.count
        }
        WordsScreenService.ReloadResult(page.await(), summary.await(), totalCount.await())
    }

    override suspend fun fetchMore(query: String, selectedTags: List<WordTag>, cursor: WordsCursor): WordsPage =
        mapErrors { withRetry { wordsRepository.fetchWordsPage(WordsPageParams(query, FETCH_LIMIT, selectedTags.ids(), cursor.toDto())) }.toWordsPage() }

    override suspend fun remove(word: Word) =
        // Writes are NOT retried blindly — only when the operation is idempotent.
        mapErrors { wordsRepository.remove(RemoveWordParams(wordId = word.id.toString())) }

    private inline fun <T> mapErrors(block: () -> T): T =
        try {
            block()
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            throw WordsError.from(e)
        }

    private companion object {
        const val FETCH_LIMIT = 20
    }
}
```

### Shared helpers (`core/coroutines`, written once)

```kotlin
/** `runCatching` that never swallows cancellation. Use this, not `runCatching`, around suspend calls. */
inline fun <T> runSuspendCatching(block: () -> T): Result<T> =
    try {
        Result.success(block())
    } catch (e: CancellationException) {
        throw e
    } catch (e: Exception) {
        Result.failure(e)
    }

suspend fun <T> withRetry(
    attempts: Int = 3,
    initialDelay: Duration = 300.milliseconds,
    operation: suspend () -> T,
): T {
    var delay = initialDelay
    repeat(attempts - 1) {
        try {
            return operation()
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            if (!e.isTransient) throw e
        }
        delay(delay)
        delay *= 2
    }
    return operation()
}

/** Timeouts, connectivity loss and 5xx — never 4xx, decoding errors or cancellation. */
val Throwable.isTransient: Boolean
    get() = this is IOException ||
        this is HttpRequestTimeoutException ||
        this is HttpRequestException ||
        (this is RestException && statusCode >= 500)
```

`HttpRequestException` and `RestException` come from `io.github.jan.supabase.exceptions`; supabase-kt throws a `RestException` subclass for every non-2xx edge-function response. Check the installed version's exception hierarchy once when you write this file, then leave it alone.

### Domain models & error mapping

- Domain models (`Word`, not `WordDto`) live in `core/model` (shared) or the feature's `model` package: `data class`/`sealed interface`, `kotlin.uuid.Uuid` not `String` ids, `kotlin.time.Instant` not ISO strings (both are stdlib; add the module-level `optIn` the compiler asks for if the installed Kotlin still marks them experimental), enums not raw strings, **no display concerns** — no `@StringRes`, `Color`, `Painter`, no pre-formatted display strings, and no `android.*` imports at all, so they compile as plain Kotlin and unit tests never need Robolectric. Map in extension functions next to the DTO (`fun WordDto.toWord(): Word`). Services return domain models, never DTOs and never UI models.
- Errors surface as **one sealed error type per feature that extends `Exception`**, so it travels through `suspend` calls like any error and the ViewModel can `when` over it exhaustively:

```kotlin
sealed class WordsError : Exception() {
    data object Offline : WordsError()
    data object ServerDown : WordsError()
    data object AlreadyExists : WordsError()
    data object Unknown : WordsError()

    companion object {
        fun from(e: Exception): WordsError = when {
            e is WordsError -> e
            e is RestException && e.statusCode == 409 -> AlreadyExists
            e is RestException && e.statusCode >= 500 -> ServerDown
            e.isTransient -> Offline
            else -> Unknown
        }
    }
}
```

The ViewModel never sees `RestException`, `SerializationException` or Ktor types.

### Parallel calls

Independent reads run in `coroutineScope { async { } }` as above — structured, so cancelling the screen cancels all of them. Never build your own `CoroutineScope` in a Service.

### Caches and change streams

Repositories are stateless. A cache or a "something changed" signal (the tag store, profile changes after a level switch, sign-out) belongs to a Service, exposed as a `Flow`/`StateFlow`; the Service is a singleton in the `AppContainer`. Prefer `StateFlow` for state and `MutableSharedFlow(extraBufferCapacity = 1)` for pure signals.

## Fake (for every Service interface)

```kotlin
class FakeWordsScreenService : WordsScreenService {

    var stubReload: suspend (query: String, selectedTags: List<WordTag>) -> WordsScreenService.ReloadResult = { _, _ ->
        WordsScreenService.ReloadResult(
            page = WordsPage(words = listOf(Word.stub(text = "Fenster", translation = "window")), nextCursor = null),
            summary = InsightsSummary.stub(),
            totalCount = 1,
        )
    }
    var stubFetchMore: suspend (String, List<WordTag>, WordsCursor) -> WordsPage = { _, _, _ ->
        WordsPage(words = listOf(Word.stub(text = "Schlüssel", translation = "key")), nextCursor = null)
    }
    var stubRemove: suspend (Word) -> Unit = {}

    override suspend fun reload(query: String, selectedTags: List<WordTag>) = stubReload(query, selectedTags)
    override suspend fun fetchMore(query: String, selectedTags: List<WordTag>, cursor: WordsCursor) = stubFetchMore(query, selectedTags, cursor)
    override suspend fun remove(word: Word) = stubRemove(word)
}
```

Fake rules:
- One `stub…` `var` lambda per interface method, `suspend` so a test can `delay()` to observe a loading state; throwing from the lambda tests failure paths.
- Descriptive, uniquely identifiable default values (`"Fenster"`, not `"word1"`); `Word.stub(...)` factories live beside the fakes in `src/test/kotlin/com/pretzly/testing/`.
- No logic besides calling stubs — no call counters, no recording lists. If a test needs to know a call happened, set a flag inside the stub lambda in that test.
- Fakes live in `src/test`, one file per feature (`WordsScreenServiceFakes.kt`).

## Platform capabilities & SDKs

A platform capability (text-to-speech, notifications, subscriptions, sign-in, analytics) is an interface in the feature's `service` package or `core`, implemented by one adapter class over the Android API or SDK, registered in the `AppContainer`, and faked in tests. The SDK call itself goes in a Repository (one per SDK); the Service on top owns mapping and errors as usual. Adapters take `Context` in their constructor (application context, from the container) — a Service or ViewModel never holds a `Context`.

## Testing

- Test the Service against a `Fake*Repository`: DTO → model mapping, error mapping per failure kind (409 → `AlreadyExists`, 5xx → `ServerDown`, `IOException` → `Offline`), retry behaviour (transient error then success within `runTest`, whose virtual time makes the backoff free).
- JUnit 4, `runTest`, a `makeService` factory with Fake defaults, same conventions as `android-viewmodel`.
- Screen logic classes (`ExerciseQueue`, `AnswerValidator`, `GoalProgress`) are plain Kotlin: test them directly, port the iOS model tests as the spec.
