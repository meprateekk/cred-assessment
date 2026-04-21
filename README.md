# CRED Flutter Assessment

This project implements the assignment brief for a swipeable vertical carousel in Flutter, powered by the provided mock APIs.

## What Is Implemented

- Vertical swipe carousel for the `> 2 items` state using a custom animated `PageView`
- Compact list layout for the `<= 2 items` state
- API-backed data flow with `Dio` against:
  - `https://api.mocklets.com/p26/mock1`
  - `https://api.mocklets.com/p26/mock2`
- Safe fallback to local fixture payloads when the mock API is unavailable during development
- Footer text rendering when `flipper_config` is absent
- Flipping bottom tag behavior when `flipper_config` is present
- Widget tests for UI correctness
- Integration performance test to detect frame-budget violations during carousel swipes

## Architecture

The project uses a lightweight layered structure:

- `lib/services`
  - `BillRepository` is responsible for fetching and decoding the mock API payload
  - `mock_bill_payloads.dart` mirrors the remote payloads for offline fallback
- `lib/models`
  - Holds strongly typed models for scenarios, bills, flipper config, and the bill section
- `lib/bloc`
  - `BillCubit` coordinates loading states and selected mock scenario
- `lib/screens`
  - `HomeScreen` handles the top-level presentation and scenario switching
- `lib/widgets`
  - `BillCard`, `FlipperWidget`, and `StackedCarousel` contain the assignment-specific UI behavior

I used `flutter_bloc` because the app has a small but meaningful state surface:

- loading / loaded / error states
- switching between the 2-item and many-item API scenarios
- keeping data flow separate from rendering

This keeps the code testable without over-engineering the project.

## Tests Covered

### Widget tests

- `test/bill_card_test.dart`
  - verifies CTA, amount, footer text, and flipper rendering
- `test/flipper_widget_test.dart`
  - verifies empty-state safety and final-stage flipping behavior
- `test/stacked_carousel_test.dart`
  - verifies the vertical carousel renders and responds to swipe gestures
- `test/widget_test.dart`
  - verifies the full app can switch between the 2-item and many-item assignment states

### Performance test

- `integration_test/app_performance_test.dart`
  - captures frame timings during repeated carousel swipes
  - flags frames whose build or raster duration exceeds the 16 ms budget

Run commands:

```bash
flutter test
flutter test integration_test/app_performance_test.dart
flutter analyze
```

## Important Assumptions

- The brief mentions `10 cards min` in one place, but the provided `mock2` endpoint currently returns `9` cards. I treated the live mock payload as the source of truth and documented the mismatch here.
- The brief references attached videos for exact animation parity, but the video assets were not bundled into this repo. I implemented a smooth stacked vertical swipe interaction that aims to match the described behavior as closely as possible from the written brief.
- The app first attempts the actual API call and falls back to local fixture payloads only if the network call fails during development/testing.

## AI Usage

AI assistance was used during development for implementation support, review, and documentation drafting. All code was reviewed and adjusted to match the assignment requirements.

## Submission Notes

Before sharing:

- remove generated folders such as `build/` and `.dart_tool/`
- create a local git history with micro-commits
- build and attach a working APK
- record a walkthrough video covering both data states and the swipe interaction
