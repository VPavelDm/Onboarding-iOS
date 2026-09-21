---
name: android-feature-module
description: Use when creating a new Android feature (screen) or restructuring one — features are Kotlin packages inside the single `:app` Gradle module, not separate modules. Covers the package layout, dependency layering between layers, where fakes and tests live, and which layer skills to follow. Triggers on creating a new package under `feature/` in the Android app (Kotlin + Jetpack Compose).
---

# Feature packages (Android)

Features are **packages, not Gradle modules**. The app is one `:app` module; each feature gets one package with one sub-package per layer. No `:feature:words` module, no `core`/`ui` module split — a module boundary costs Gradle configuration and buys nothing until there is a second consumer. The iOS app follows the same rule with folders (see the `feature-module` skill); the Android layout mirrors it so a screen can be ported one-to-one.

## Package layout

Root package = the `applicationId` (for Pretzly: `com.pretzly`).

```
com.pretzly
├── feature/
│   └── words/
│       ├── ui/          # WordsScreen.kt (composables), WordsViewModel.kt, WordsUiState.kt, UI models (rows, labels)
│       ├── service/     # WordsScreenService.kt — interface + Default impl: retries, error mapping, DTO → domain, screen logic
│       ├── repository/  # WordsRepository.kt — interface + edge-function impl; *Dto.kt and *Params.kt beside it
│       └── model/       # domain models only this feature uses
├── core/
│   ├── model/           # domain models shared by several features (Word, Profile, WordTag, LanguageLevel, …)
│   ├── network/         # SupabaseClient configuration + the EdgeFunctions helper (see `android-repository`)
│   ├── ui/              # theme, colours, typography, shared components (buttons, popups, progress bars)
│   ├── analytics/       # Analytics interface + PostHog implementation
│   └── coroutines/      # withRetry, runSuspendCatching (see `android-service`)
├── di/                  # AppContainer + LocalAppContainer + appViewModel (see `android-app-shell`)
├── navigation/          # NavKey routes + the root NavDisplay
├── PretzlyApplication.kt
└── MainActivity.kt
```

Omit sub-packages the feature doesn't need; don't invent extra ones. Tests mirror the package under `src/test/kotlin` (`feature/words/WordsViewModelTest.kt`, `feature/words/DefaultWordsScreenServiceTest.kt`).

## Where fakes live

`Fake*` implementations of every service and repository interface live in the **test source set**, in `src/test/kotlin/com/pretzly/testing/` (one file per feature, e.g. `WordsScreenServiceFakes.kt`), reusable by every test. They are not in `main` because Compose previews don't need them: previews render the stateless screen overload with a sample `UiState` (see `android-view`).

## Dependency layering

```
Screen (Compose) → ViewModel → Service → Repository → data source
```

- Strictly downward. A composable never touches a Service; a ViewModel never touches a Repository; a Repository never calls another Repository.
- Cross-feature reuse happens at the Service or Model level — never reach into another feature's `ui` package.
- `core/*` is shared code; feature code may depend on it, never the reverse. If a feature needs something from another feature's package, the thing belongs in `core`.
- `di/AppContainer` is the only place that knows concrete classes. Features depend on interfaces.

## Per-layer conventions

Follow the dedicated skills — do not improvise:
- Repositories & DTOs → `android-repository` skill
- Services, retries, error mapping, Fakes → `android-service` skill
- ViewModels, UiState & their tests → `android-viewmodel` skill
- Screens → `android-view` skill (stateful/stateless split, state hoisting, previews, navigation callbacks)
- App wiring (container, navigation root, Gradle) → `android-app-shell` skill
- Models: plain Kotlin `data class`/`sealed interface` with business logic + validation; testable without Services or Repositories; no Android imports

## Porting a screen from iOS

The iOS feature folder and its tests are the spec:
1. Read `<Feature>/Service/<Screen>ScreenService.swift` → write the Kotlin interface with the same methods.
2. Read `PretzlyTests/<Screen>ViewModelTests.swift` → write the same tests in Kotlin first (they drive the UiState shape).
3. Read `<Feature>/ViewModel/` → write the ViewModel until the tests pass.
4. Read `<Feature>/View/` → write the screen. Don't copy SwiftUI structure literally; use Material 3 components and Compose idioms.

Logic that iOS still keeps in a view model (the Learn screen's exercise queue and answer validation, `app/follow-ups.md`) goes into the Android Service from day one — don't reproduce the iOS debt.

## Definition of done for a new feature

- `./gradlew :app:assembleDebug` builds
- `./gradlew :app:testDebugUnitTest` passes; ViewModel and Service tests exist (JUnit 4 + `kotlinx-coroutines-test`)
- Fakes for every new interface in `src/test/kotlin/com/pretzly/testing/`
- The stateless screen has a `@PreviewLightDark` preview with a realistic UiState
- All user-facing strings in `res/values/strings.xml`
- No layering violations (spot-check imports against the arrows above)
