# ``AnvyxServiceKit``

Vendor-agnostic app services: analytics, feature flags / remote config, A/B
experiments, onboarding, and review prompting.

## Overview

Program against protocols (``AnalyticsService``, ``FeatureFlagProvider``,
``RemoteConfigService``) so the app stays decoupled from any SDK. Swap in Firebase,
Amplitude, etc. at the edges.

```swift
let analytics = BatchingAnalytics(uploader: myUploader)   // batched + offline queue
await analytics.log(.init(name: "opened"))

let variant = flags.variant(for: Experiment<Checkout>(name: "checkout"), participant: installID)
```

## Topics

### Analytics
- ``AnalyticsService``
- ``AnalyticsEvent``
- ``ConsoleAnalytics``
- ``CompositeAnalytics``
- ``BatchingAnalytics``
- ``AnalyticsUploader``

### Feature Flags & Experiments
- ``FeatureFlagProvider``
- ``StaticFeatureFlags``
- ``RemoteConfigService``
- ``Experiment``

### Lifecycle
- ``OnboardingState``
- ``ReviewService``
