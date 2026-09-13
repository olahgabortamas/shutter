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
- automatic local persistence for campaign progress and game-feel preferences;
- unit and widget tests.

## Run locally

Install a current stable Flutter SDK, then run:

```sh
flutter pub get
flutter test
flutter run -d edge
```

For a browser preview, `flutter run -d web-server --web-port 8080` serves the
game at `http://localhost:8080`. The repository includes its web runner; add
native mobile runners later with `flutter create --platforms=android,ios .`.

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
ratchets, spectrum filters, audio, monetization, and analytics are
intentionally deferred until the core interaction has been play-tested.
