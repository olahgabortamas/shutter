# SHUTTER

SHUTTER is a premium minimalist mobile puzzle about sliding precision plates so
their apertures reveal exactly the requested constellation of lights.

This repository contains the first Flutter vertical slice:

- a five-level, JSON-backed Aperture campaign;
- framework-independent mask logic and breadth-first hint solver;
- drag-to-slide plates with discrete notch snapping and haptics;
- a custom-painted ceramic, graphite, brass, and amber board;
- undo, one-move hint, reset, automatic completion, and level progression;
- functional pause and game-feel controls, including haptic and reduced-motion settings;
- unit and widget tests.

## Run locally

Install a current stable Flutter SDK, then run:

```sh
flutter create --platforms=android,ios .
flutter pub get
flutter test
flutter run
```

`flutter create` adds the generated platform runner directories while preserving
the implementation in `lib/`, tests, assets, and project metadata.

## Architecture

```text
assets/levels/        external campaign data
lib/domain/           immutable puzzle definitions
lib/game/             state, history, solve detection, and hint search
lib/data/             asset loading
lib/presentation/     theme, screen, controls, and CustomPainter board
```

The puzzle model deliberately has no widget references. A plate stores one
binary aperture mask per legal notch, which makes the rules deterministic and
keeps future level generation and validation straightforward.

## MVP scope

The current build covers the first five mechanisms in Chapter 1: Aperture.
Locks, coupled mechanisms,
ratchets, spectrum filters, persistence, audio, monetization, and analytics are
intentionally deferred until the core interaction has been play-tested.
