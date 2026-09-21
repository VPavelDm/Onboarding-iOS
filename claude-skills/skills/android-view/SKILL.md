---
name: android-view
description: Use when creating or modifying any Jetpack Compose screen or component — the stateful/stateless screen split, state hoisting, ViewModel creation, UI-only local state, events out via lambdas, one-off effects, Material 3 styling, string resources, and previews. Triggers on any edit to *Screen.kt or other @Composable files in the Android app (except trivial edits — typos, renames, constants).
---

# Screens (Compose)

Screens render `UiState` and forward user intent to their ViewModel. No business logic, no data access. Navigation is a lambda the parent passes in; the screen never knows the back stack.

## Shape of a screen

Two composables with the same name: a **stateful** entry point that owns the ViewModel, and a **stateless** one that takes state and lambdas. Only the stateless one has previews.

```kotlin
@Composable
fun WordsScreen(
    onOpenWord: (WordId) -> Unit,
    onOpenListenMode: () -> Unit,
    viewModel: WordsViewModel = appViewModel { WordsViewModel(wordsScreenService()) },
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    WordsScreen(
        uiState = uiState,
        onQueryChange = viewModel::onQueryChange,
        onRetry = viewModel::reload,
        onWordClick = { row -> onOpenWord(row.id) },
        onListenModeClick = onOpenListenMode,
        onErrorShown = viewModel::onErrorShown,
    )
}

@Composable
private fun WordsScreen(
    uiState: WordsUiState,
    onQueryChange: (String) -> Unit,
    onRetry: () -> Unit,
    onWordClick: (WordRow) -> Unit,
    onListenModeClick: () -> Unit,
    onErrorShown: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val snackbarHostState = remember { SnackbarHostState() }
    var isRemoveDialogShown by rememberSaveable { mutableStateOf(false) }

    uiState.error?.let { error ->
        val message = stringResource(error.messageRes())
        LaunchedEffect(error) {
            snackbarHostState.showSnackbar(message)
            onErrorShown()
        }
    }

    Scaffold(
        modifier = modifier,
        snackbarHost = { SnackbarHost(snackbarHostState) },
        topBar = { WordsTopBar(onListenModeClick = onListenModeClick) },
    ) { padding ->
        Column(modifier = Modifier.padding(padding).fillMaxSize()) {
            SearchField(query = uiState.query, onQueryChange = onQueryChange)
            when {
                uiState.isLoading -> LoadingIndicator(modifier = Modifier.weight(1f))
                uiState.rows.isEmpty() -> EmptyWords(onRetry = onRetry, modifier = Modifier.weight(1f))
                else -> WordList(rows = uiState.rows, onWordClick = onWordClick, modifier = Modifier.weight(1f))
            }
        }
    }
}

@Composable
private fun WordList(rows: List<WordRow>, onWordClick: (WordRow) -> Unit, modifier: Modifier = Modifier) {
    LazyColumn(modifier = modifier) {
        items(rows, key = { it.id }) { row ->
            WordListItem(row = row, onClick = { onWordClick(row) })
        }
    }
}

@PreviewLightDark
@Composable
private fun WordsScreenPreview() {
    PretzlyTheme {
        WordsScreen(
            uiState = WordsUiState(
                isLoading = false,
                rows = listOf(WordRow.sample(text = "das Fenster", translation = "window")),
            ),
            onQueryChange = {}, onRetry = {}, onWordClick = {}, onListenModeClick = {}, onErrorShown = {},
        )
    }
}
```

## Rules

### Ownership & state
- **The stateful screen creates its ViewModel** with `appViewModel { … }` (see `android-app-shell`) as a default parameter, so a navigation entry can also pass one built with arguments. Nothing else calls `viewModel()`; child composables never receive the ViewModel — pass state down, lambdas up.
- **Collect with `collectAsStateWithLifecycle()`** (`lifecycle-runtime-compose`), never `collectAsState()`: it stops collecting while the app is in the background.
- **UI-only state stays in the composable** — `remember` for things that may reset on rotation (scroll, snackbar host), `rememberSaveable` for things that must survive it (a dialog toggle, an expanded section). If the state outlives the screen or another layer needs it, it belongs in UiState.
- **The stateless screen is a pure function of its parameters.** No `viewModel()`, no `LocalAppContainer`, no `LocalContext` beyond resources — that is what makes it previewable and testable.

### Events & navigation
- Every user action calls a lambda (`onQueryChange`, `onWordClick`); the screen never mutates domain state itself.
- **Navigation is a lambda from the parent** (`onOpenWord: (WordId) -> Unit`). The navigation root (`navigation/`) maps it to `backStack.add(WordRoute(id))`. A screen never sees `NavBackStack`.
- Guard navigation clicks with `dropUnlessResumed { … }` when a double tap could push twice.
- One-off outcomes in UiState (an error, "finished") are handled in a `LaunchedEffect(key)` that performs the effect and calls the ViewModel's `on…Shown()`/`on…Handled()` so it doesn't repeat.

### Composition
- The screen body is a short layout of **small named private composables** (`WordsTopBar`, `SearchField`, `WordList`, `EmptyWords`) — every logical block gets a name; a piece is a separate public composable only when reused across screens (then it lives in `core/ui`).
- Every composable that draws takes `modifier: Modifier = Modifier` as its **first optional parameter** and applies it to its root node exactly once.
- `LazyColumn`/`LazyRow` items always have a stable `key`.
- Never call a `suspend` function or launch a coroutine directly in composition: `LaunchedEffect` for state-driven effects, `rememberCoroutineScope()` for click-driven ones (snackbar, scroll-to).
- Loading data is **not** a composable's job — the ViewModel loads in `init`; the screen only renders `isLoading`.

### Styling
- **Material 3 only** (`androidx.compose.material3`). Colours, typography and shapes come from `MaterialTheme` via `PretzlyTheme` (`core/ui`): `MaterialTheme.colorScheme.primary`, never `Color(0xFF…)` inline. Brand yellow is the theme's `primary`.
- Shared components (`PrimaryButton`, `GenericErrorPopup`, `LinearProgressBar`) live in `core/ui`; reuse before creating.
- **All user-facing strings via `stringResource(R.string.…)`**, plurals via `pluralStringResource`. No literals in composables outside previews. Keys mirror the iOS catalog; the app is localized for en, de, fr, ru, uk.
- Dimensions as `.dp`, text as `.sp`; spacing constants in `core/ui` if they repeat.

### Layout & motion polish
- Reserve space for variable-length content so swaps never shove siblings around (`Modifier.heightIn(min = …)`, `maxLines` + `overflow = TextOverflow.Ellipsis`).
- Animate by state: `AnimatedVisibility`, `AnimatedContent(targetState = …)` for swaps, `animate*AsState` for values. Continuous progress uses `animateFloatAsState` on the state value, not a manual ticker.
- Edge-to-edge is on by default: content behind system bars must use `Scaffold` padding or `WindowInsets` modifiers.
- Comments state constraints the code can't show, not what the next line does.

## Previews

Every stateless screen gets a `@PreviewLightDark` preview inside `PretzlyTheme` with realistic demo content built from `*.sample(...)` factories that live beside the UI models. Add a second preview for the loading or empty state when the layout differs. Previews never construct a ViewModel or touch the container — they call the stateless overload, so no Fakes are needed in `main`.

## UI tests

Compose UI tests are optional and run under Robolectric in `src/test`; they target the stateless screen with a fixed UiState and assert via semantics (`onNodeWithText`), falling back to `testTag` only when a matcher gets complicated. Behaviour lives in ViewModel tests — a UI test that needs a Fake service is testing the wrong layer.
