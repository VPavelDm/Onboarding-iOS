---
name: android-viewmodel
description: Use when creating or modifying any Android ViewModel — the `androidx.lifecycle.ViewModel` + single `StateFlow<UiState>` pattern, constructor-injected Services, one-off events as state, and the JUnit 4 + kotlinx-coroutines-test template. Triggers on any edit to *ViewModel.kt, *UiState.kt or *ViewModelTest.kt files, including bug fixes. Not needed for trivial edits (typos, renames, constants).
---

# ViewModels (Android)

ViewModels orchestrate Services and hold UI state. Business logic belongs in domain models and Services — screen logic such as paging, queues and validation goes in the Service, not here; data access belongs in Repositories behind Services (see `android-service` and `android-repository`). ViewModels inject Services only — never Repositories directly.

## Template (new ViewModels)

```kotlin
class WordsViewModel(
    private val service: WordsScreenService,
) : ViewModel() {

    private val _uiState = MutableStateFlow(WordsUiState())
    val uiState: StateFlow<WordsUiState> = _uiState.asStateFlow()

    init {
        reload()
    }

    fun reload() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            val current = _uiState.value
            val result = service.reload(query = current.query, selectedTags = current.selectedTags)
            _uiState.update { state ->
                state.copy(
                    isLoading = false,
                    rows = result.page?.words?.map(::WordRow) ?: state.rows,
                    error = if (result.loadFailed) WordsError.Unknown else null,
                )
            }
        }
    }

    fun remove(row: WordRow) {
        viewModelScope.launch {
            runSuspendCatching { service.remove(row.word) }
                .onSuccess { reload() }
                .onFailure { error -> _uiState.update { it.copy(error = error as? WordsError ?: WordsError.Unknown) } }
        }
    }

    fun onQueryChange(query: String) {
        _uiState.update { it.copy(query = query) }
        reload()
    }

    fun onErrorShown() {
        _uiState.update { it.copy(error = null) }
    }
}

data class WordsUiState(
    val isLoading: Boolean = true,
    val query: String = "",
    val selectedTags: List<WordTag> = emptyList(),
    val rows: List<WordRow> = emptyList(),
    val error: WordsError? = null,
)
```

Rules the template encodes:
- **One immutable `data class` UiState per screen**, exposed as a single `StateFlow`. Every field the screen renders is in it. No second flow for "events", no `mutableStateOf` inside the ViewModel, no `LiveData`.
- **Mutate with `_uiState.update { it.copy(...) }`** — atomic, no read-then-write races between coroutines.
- **Load once in `init`.** A ViewModel survives rotation, so `init` runs exactly once per screen instance; that is why Android puts the initial load here and not in the composable. Expose `reload()` for retry and pull-to-refresh.
- **Coroutines only through `viewModelScope`.** It is cancelled when the screen leaves the back stack. Never `GlobalScope`, never `runBlocking`.
- **Never swallow `CancellationException`.** Plain `runCatching` does; use the shared `runSuspendCatching` from `core/coroutines` (see `android-service`) or `try/catch` that rethrows it.
- **Dependencies via the constructor**, no defaults that reach into a global — the `AppContainer` creates ViewModels through `appViewModel { }` (see `android-app-shell`), tests pass Fakes.
- **Services only.** Retries, error mapping and DTO → domain parsing already happened below. The ViewModel maps domain models to the UI models the screen needs (`Word` → `WordRow`) and never inspects HTTP statuses or Ktor exceptions.
- **One-off events are state.** An error to show, a "navigate to recap" outcome: put it in UiState, let the screen react in a `LaunchedEffect`, and clear it via a `on…Shown()`/`on…Handled()` intent. No `SharedFlow`/`Channel` event buses — they lose events across configuration changes.
- **Navigation arguments come through the constructor** (`TagDetailViewModel(service, tagId)`), passed from the navigation entry — not read from a `SavedStateHandle` by string key.
- Never nest ViewModels. One ViewModel per screen, created by the screen's composable.

## Main-safety

Services and repositories are main-safe (Ktor and supabase-kt switch threads themselves), so the ViewModel never calls `withContext(Dispatchers.IO)`. If a Service does CPU work worth moving off main, the Service does the `withContext`, not the ViewModel.

## UI models beside the screen

`WordRow`, display labels, `@StringRes` ids, colours — anything about *how* it looks — is a UI model in the feature's `ui` package. The ViewModel maps domain → UI; domain models (`core/model`) never carry a display concern, so a screen can change how something looks without touching the Service.

## Testing (JUnit 4 + kotlinx-coroutines-test — mandatory)

```kotlin
class WordsViewModelTest {

    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    private fun makeViewModel(
        service: FakeWordsScreenService = FakeWordsScreenService(),
    ) = WordsViewModel(service)

    @Test
    fun `loading clears after the first reload`() = runTest {
        val viewModel = makeViewModel()

        assertFalse(viewModel.uiState.value.isLoading)
    }

    @Test
    fun `failed reload surfaces an error and keeps the previous rows`() = runTest {
        val service = FakeWordsScreenService()
        val viewModel = makeViewModel(service)
        service.stubReload = { _, _ -> WordsScreenService.ReloadResult(page = null, summary = null, totalCount = null) }

        viewModel.reload()

        assertEquals(WordsError.Unknown, viewModel.uiState.value.error)
        assertEquals(1, viewModel.uiState.value.rows.size)
    }

    @Test
    fun `remove failure surfaces the service error`() = runTest {
        val service = FakeWordsScreenService()
        service.stubRemove = { throw WordsError.Offline }
        val viewModel = makeViewModel(service)

        viewModel.remove(viewModel.uiState.value.rows.first())

        assertEquals(WordsError.Offline, viewModel.uiState.value.error)
    }
}
```

`MainDispatcherRule` lives once in `src/test/kotlin/com/pretzly/testing/`:

```kotlin
class MainDispatcherRule(
    private val dispatcher: TestDispatcher = UnconfinedTestDispatcher(),
) : TestWatcher() {
    override fun starting(description: Description) = Dispatchers.setMain(dispatcher)
    override fun finished(description: Description) = Dispatchers.resetMain()
}
```

- `UnconfinedTestDispatcher` as Main runs `viewModelScope.launch` eagerly, so a Fake that doesn't really suspend completes before the next line — assert directly on `uiState.value`, as the iOS tests do after `await`.
- When the *sequence* of states matters (loading → list), collect with Turbine: `viewModel.uiState.test { assertTrue(awaitItem().isLoading); … }`.
- A private `makeViewModel` factory with Fake defaults; backticked, descriptive test names.
- Fakes over mocks — see `android-service` for the `stub…` lambda pattern. No MockK unless a platform class can't be faked.
- Test behaviour, not coverage. Never delete a failing test — update it to the new behaviour.
- Port the iOS `PretzlyTests/<Screen>ViewModelTests.swift` cases one-to-one first; they are the spec for the UiState shape.
