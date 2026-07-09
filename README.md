# AppServices

> Provider-agnostic app services: analytics, remote config, feature flags, review prompts, onboarding.

![Swift](https://img.shields.io/badge/Swift-5.9-F05138?logo=swift&logoColor=white)
![Platform](https://img.shields.io/badge/iOS-17%2B-000000?logo=apple)
![SPM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen)
![License](https://img.shields.io/badge/License-MIT-blue)

AppServices defines protocol-first abstractions for the cross-cutting services most apps need, plus lightweight built-in implementations. Concrete backends (e.g. Firebase) live in separate adapter packages so this core stays dependency-free.

## Features

- **Analytics** — `AnalyticsService` protocol with `ConsoleAnalytics` and `CompositeAnalytics` (fan-out to multiple sinks).
- **Remote config** — `RemoteConfigService` with a `JSONRemoteConfig` implementation.
- **Feature flags** — `FeatureFlagProvider` with `StaticFeatureFlags`.
- **Review & onboarding** — `ReviewService` (rating-prompt timing) and `OnboardingState`.

No third-party dependencies. See [AppServicesFirebase](https://github.com/anvyxhq/AppServicesFirebase) for the Firebase adapter.

## Requirements

- iOS 17.0+
- Swift 5.9+ / Xcode 16+

## Installation

```swift
.package(url: "https://github.com/anvyxhq/AppServices.git", branch: "main"),
```

Add `AnvyxServiceKit` to your target.

## Usage

```swift
import AnvyxServiceKit

let analytics = CompositeAnalytics([ConsoleAnalytics()])
analytics.track(AnalyticsEvent(name: "app_open"))
```

## Modules

| Product | Description |
| --- | --- |
| `AnvyxServiceKit` | Analytics, remote config, feature flags, review prompts, onboarding state — protocol-first. |

## License

MIT — see [LICENSE](LICENSE).
