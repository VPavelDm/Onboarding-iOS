---
name: android-app-shell
description: Use when bootstrapping the Android app or touching its wiring — Gradle setup (AGP 9 built-in Kotlin, version catalog, Compose BOM), the manual dependency container (`AppContainer`, `LocalAppContainer`, `appViewModel`), the Supabase client, the Navigation 3 root, edge-to-edge activity, sharing `onboarding_steps.json` with iOS, test dependencies, and build/test commands. Triggers on edits to build.gradle.kts, libs.versions.toml, *Application.kt, MainActivity.kt, AppContainer.kt or the navigation package.
---

# App shell (Android)

The app is one `:app` module at `app/android/` in the Pretzly monorepo, Kotlin + Jetpack Compose, Material 3, sharing only the Supabase backend and `onboarding_steps.json` with iOS. This skill covers the wiring that every feature relies on; features themselves follow `android-feature-module`.

## Scaffold from Google's template, then add

Don't hand-write the Gradle files. Generate the project with Android Studio's **Empty Activity** template (or `android create empty-activity --name=Pretzly --output=app/android` with Google's `android` CLI) so AGP, the bundled Kotlin, the Compose plugin and the version catalog start consistent, then add the libraries below to `gradle/libs.versions.toml`.

Keep the template's `agp` and `kotlin` versions. AGP 9 has **built-in Kotlin**: no `org.jetbrains.kotlin.android` plugin, and the Kotlin Gradle plugin version on the classpath is what `./gradlew buildEnvironment` prints — the `org.jetbrains.kotlin.plugin.compose` and `org.jetbrains.kotlin.plugin.serialization` plugins must use that same version. Compiler options go in a top-level `kotlin { compilerOptions { … } }` block, not `android.kotlinOptions`.

Libraries to add (stable as of 2026-09-21; bump to the latest stable when you scaffold — check Maven, don't guess):

| Purpose | Coordinates | Version |
|---|---|---|
| Compose | `androidx.compose:compose-bom` (then `ui`, `material3`, `ui-tooling-preview`; `ui-tooling` as `debugImplementation`) | 2026.09.00 |
| Activity | `androidx.activity:activity-compose` | 1.13.0 |
| Lifecycle | `androidx.lifecycle:lifecycle-runtime-compose`, `lifecycle-viewmodel-compose`, `lifecycle-viewmodel-navigation3` | 2.11.0 |
| Navigation 3 | `androidx.navigation3:navigation3-runtime`, `navigation3-ui` | 1.1.7 |
| Serialization | `org.jetbrains.kotlinx:kotlinx-serialization-json` + plugin `org.jetbrains.kotlin.plugin.serialization` | 1.11.0 / = kotlin |
| Supabase | `io.github.jan-tennert.supabase:bom` (then `auth-kt`, `functions-kt`) | 3.8.0 |
| Ktor engine | `io.ktor:ktor-client-okhttp` (same Ktor major as supabase-kt) | 3.6.0 |
| Analytics | `com.posthog:posthog-android` | 3.68.0 |
| Tests | `junit:junit` 4.13.2, `org.jetbrains.kotlinx:kotlinx-coroutines-test` 1.11.0, `app.cash.turbine:turbine` 1.2.1 | |

Not used: Hilt/Dagger/Koin (manual container below), Room (no local database — the client is thin by design), Retrofit (supabase-kt owns HTTP), MockK (hand-written fakes).

`minSdk` 28, `compileSdk`/`targetSdk` = the template's latest stable. `applicationId` `com.pretzly`.

## Dependency injection: one manual container

Google's manual-DI pattern: a plain class holding the app's singletons, owned by the `Application`. It is small enough to read in one screen, has no code generation, and mirrors the iOS `DependencyContainer`. Switch to Hilt only if the container grows past a couple hundred lines or a second Gradle module appears.

```kotlin
// di/AppContainer.kt
class AppContainer(context: Context) {
    private val appContext = context.applicationContext

    private val json = Json {
        ignoreUnknownKeys = true
        explicitNulls = false
    }

    val supabase: SupabaseClient = createSupabaseClient(
        supabaseUrl = BuildConfig.SUPABASE_URL,
        supabaseKey = BuildConfig.SUPABASE_ANON_KEY,
    ) {
        defaultSerializer = KotlinXSerializer(json)
        install(Auth)
        install(Functions)
    }
    private val edge = EdgeFunctions(supabase, json)

    // Singletons: stateful services and repositories over SDKs.
    val analytics: Analytics = PostHogAnalytics(appContext)
    val profileService: ProfileService = DefaultProfileService(EdgeProfileRepository(edge), analytics)
    val wordTagsService: WordTagsService = DefaultWordTagsService(EdgeWordTagsRepository(edge))

    // Factories: one fresh screen service per ViewModel.
    fun wordsScreenService(): WordsScreenService =
        DefaultWordsScreenService(EdgeWordsRepository(edge), EdgeInsightsRepository(edge))
}

// PretzlyApplication.kt
class PretzlyApplication : Application() {
    val container by lazy { AppContainer(this) }
}
```

```kotlin
// di/LocalAppContainer.kt
val LocalAppContainer = staticCompositionLocalOf<AppContainer> { error("AppContainer not provided") }

/** Creates a ViewModel from the container; the lambda runs once per screen instance. */
@Composable
inline fun <reified VM : ViewModel> appViewModel(crossinline create: AppContainer.() -> VM): VM {
    val container = LocalAppContainer.current
    return viewModel { container.create() }
}
```

Rules:
- Only `AppContainer` names concrete classes (`Default*`, `Edge*`, `PostHog*`). Everything else depends on interfaces.
- Singletons are `val`s (stateful services, the Supabase client, analytics); per-screen services are `fun` factories so a ViewModel gets its own instance.
- Secrets come from `BuildConfig` fields fed by `local.properties`/CI env, never committed literals. The anon key is public by design; the service-role key never ships in the app.
- Supabase sessions persist through supabase-kt's default Android session storage; never store tokens yourself.

## Activity and theme

```kotlin
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        val container = (application as PretzlyApplication).container
        setContent {
            CompositionLocalProvider(LocalAppContainer provides container) {
                PretzlyTheme { PretzlyApp() }
            }
        }
    }
}
```

`PretzlyTheme` (`core/ui/Theme.kt`) defines the Material 3 `ColorScheme` (brand yellow as `primary`), typography and shapes, light and dark. One `Activity` for the whole app; screens are composables.

## Navigation 3 root

Routes are `@Serializable` `NavKey`s; the root owns the back stack and maps screen callbacks onto it.

```kotlin
// navigation/Routes.kt
@Serializable data object LearnRoute : NavKey
@Serializable data object WordsRoute : NavKey
@Serializable data class TagDetailRoute(val tagId: String) : NavKey

// navigation/PretzlyApp.kt
@Composable
fun PretzlyApp() {
    val backStack = rememberNavBackStack(LearnRoute)
    NavDisplay(
        backStack = backStack,
        onBack = { backStack.removeLastOrNull() },
        entryDecorators = listOf(
            rememberSaveableStateHolderNavEntryDecorator(),
            rememberViewModelStoreNavEntryDecorator(),
        ),
        entryProvider = entryProvider {
            entry<WordsRoute> {
                WordsScreen(
                    onOpenWord = { id -> backStack.add(WordDetailRoute(id.toString())) },
                    onOpenListenMode = { backStack.add(ListenModeRoute) },
                )
            }
            entry<TagDetailRoute> { key ->
                TagDetailScreen(
                    onClose = { backStack.removeLastOrNull() },
                    viewModel = appViewModel { TagDetailViewModel(tagDetailScreenService(), TagId.parse(key.tagId)) },
                )
            }
        },
    )
}
```

- `rememberViewModelStoreNavEntryDecorator()` (`lifecycle-viewmodel-navigation3`) scopes each ViewModel to its entry, so it is cleared when the route is popped and a second `TagDetailRoute` gets its own ViewModel.
- Route arguments are primitives/strings (`NavKey`s are saved to a `Bundle`); parse them into domain ids when building the ViewModel.
- Launch flow (loading → onboarding → home) and the four home tabs with their own back stacks follow Google's `navigation-3` skill recipes ("conditional navigation", "multiple back stacks"); install it with `android skills add navigation-3` rather than reinventing them.

## Sharing `onboarding_steps.json` with iOS

Copy it into assets at build time; never keep a second copy:

```kotlin
// app/build.gradle.kts
val copyOnboardingSteps by tasks.registering(Copy::class) {
    from(rootProject.file("../Pretzly/Pretzly/Resources/onboarding_steps.json"))
    into(layout.projectDirectory.dir("src/main/assets"))
}
tasks.named("preBuild") { dependsOn(copyOnboardingSteps) }
```

Add `app/src/main/assets/onboarding_steps.json` to `.gitignore`. Read it through an `OnboardingStepsRepository` over `context.assets`, decode with the shared `Json`.

## Localization

`res/values/strings.xml` plus `values-de`, `values-fr`, `values-ru`, `values-uk`, keys mirroring the iOS `Localizable.xcstrings` English keys (snake_case). A generator script from the xcstrings catalog is planned at `app/android/scripts/`; until it exists, add keys by hand in all five files.

## Analytics

`Analytics` interface in `core/analytics`, `PostHogAnalytics` implementation, set up in `PretzlyApplication.onCreate` before anything else and skipped for debug builds. Call sites use the interface (injected), never the PostHog SDK.

## Commands

Run from `app/android/`.

```bash
./gradlew :app:assembleDebug
```

```bash
./gradlew :app:testDebugUnitTest
```

Install on the running emulator with `./gradlew :app:installDebug`; Google's `android` CLI (`android skills add android-cli` documents it) drives emulators, screenshots and layout inspection.

## Definition of done for the shell

- `assembleDebug` and `testDebugUnitTest` pass from a clean checkout
- No `org.jetbrains.kotlin.android` plugin; Compose and serialization plugin versions equal the KGP version `buildEnvironment` prints
- `AppContainer` is the only file that constructs `Default*`/`Edge*` classes
- Anonymous sign-in and `create-profile` work end to end against the real backend on an emulator
