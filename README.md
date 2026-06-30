# AppServices

Vendor-agnostic app services: analytics, App Store review prompting, and feature flags — protocol-first so your app stays decoupled from any SDK.

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/iOS-16%2B-blue.svg)](https://developer.apple.com/ios/)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

## Features

- **`AnalyticsService`** — a protocol with `ConsoleAnalytics` and `CompositeAnalytics` (fan-out to multiple providers). Implement with Firebase/Amplitude behind it.
- **`ReviewService`** — counter-gated `SKStoreReviewController` prompting (once per version).
- **`FeatureFlagProvider`** — remote-config abstraction with a `StaticFeatureFlags` default.

## Installation

```swift
.package(url: "https://github.com/anvyxhq/AppServices.git", from: "1.0.0")
```

## Usage

```swift
import AppServices

// Analytics (swap the providers for production)
let analytics: AnalyticsService = CompositeAnalytics([ConsoleAnalytics()])
analytics.log(event: "document_exported", parameters: ["pages": 3])

// Review prompt after meaningful actions
ReviewService.registerSignificantEvent(threshold: 5)

// Feature flags
let flags: FeatureFlagProvider = StaticFeatureFlags(["new_paywall": true])
if flags.bool("new_paywall", default: false) { showNewPaywall() }
```

## Requirements

- iOS 16.0+ · Swift 5.9+

## License

MIT
