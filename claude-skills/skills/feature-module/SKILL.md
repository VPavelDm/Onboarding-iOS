---
name: feature-module
description: Use when creating a new feature or restructuring an existing one — features live as folders inside one monolith package/app target, not as separate packages. Covers the folder layout, dependency layering between layers, and which layer skills to follow. Triggers on creating a new top-level feature folder in the app's sources.
---

# Feature modules

Features are **folders, not packages**. The app is one monolith package/target; each feature gets a single top-level folder with one subfolder per layer. No per-feature `Package.swift`, no `FeatureKit`/`FeatureUI` split.

## Folder layout

```
<Feature>/
├── View/          # SwiftUI views
├── ViewModel/     # orchestration + UI state (see `viewmodel` skill)
├── Service/       # retries, error mapping, DTO → UI models (see `service` skill)
├── Repository/    # one per data source; request → DTO (see `repository` skill) — DTOs live here
├── Model/         # UI/domain models the Views and ViewModels use
└── Testing/       # Fake* implementations, reusable by tests of other features
```

Omit folders the feature doesn't need; don't invent extra ones. Tests mirror the feature folder in the test target (`<Feature>Tests/`).

## Dependency layering

```
View → ViewModel → Service → Repository → data source
```

- Strictly downward. A View never touches a Service; a ViewModel never touches a Repository; a Repository never calls another Repository.
- Cross-feature reuse happens at the Service or Model level — never reach into another feature's Views or ViewModels.
- Shared building blocks (design system components, colors, fonts, analytics, networking helpers) live outside feature folders in their own shared folders; feature code may depend on shared code, never the reverse.

## Per-layer conventions

Follow the dedicated skills — do not improvise:
- Repositories & DTOs → `repository` skill
- Services, retries, error mapping, Fakes → `service` skill
- ViewModels & their tests → `viewmodel` skill
- Views → `view` skill (composition, ownership, closures out, styling, previews)
- Models: plain Swift types with business logic + validation; testable without Services or Repositories

## Definition of done for a new feature

- Builds via `xcodebuild`
- Unit tests for ViewModels and Services pass (Swift Testing)
- Fakes for every new Service/Repository protocol in `Testing/`
- No layering violations (spot-check the imports/usage against the arrows above)
