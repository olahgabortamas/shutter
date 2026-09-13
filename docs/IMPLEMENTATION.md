# SHUTTER implementation brief

## Product promise

The experience should feel like a beautifully engineered desk object: precise,
calm, tactile, and mechanically legible. The mechanism owns the visual hierarchy;
navigation and controls recede. There are no timers, scores, stars, currencies,
confetti, or decorative illustrations in the base campaign.

## Visual system

- Warm paper background `#F3EFE7`.
- Matte ivory ceramic plates over a graphite cavity.
- Brass is reserved for rails, handles, and meaningful state (about 5–10%).
- Amber lamps have a small warm core and restrained halo, never a neon glow.
- Product identity uses a light editorial serif; functional UI uses a neutral sans.
- The square mechanism has a 600 logical-pixel maximum on larger displays.

## MVP interaction contract

1. The whole board is an accessible drag target.
2. The dominant drag direction selects a matching horizontal or vertical plate.
3. Motion is axis-constrained and continuous while held.
4. Release snaps to the nearest legal notch in 140 ms with `easeOutCubic`.
5. A snapped move alone enters history and triggers a restrained haptic.
6. Visible lights update as the visual position crosses notch boundaries.
7. Exact target equality completes the puzzle immediately; there is no submit.
8. Hint identifies one move from a shortest solution but leaves execution to the player.

## Domain boundary

`ShutterLevel` is immutable and contains no Flutter widget references. A plate
contains a binary, board-sized aperture mask for every notch. Visibility is:

```text
baseLights AND plateA[currentNotch] AND plateB[currentNotch] ...
```

`GameController` owns snapped positions, undo history, completion, and hint
search. `ShutterBoard` owns temporary drag and snap-rendering state. This keeps
offline generation, validation, and future solver ports independent from UI.

## Deferred work

- additional campaign levels and progression persistence;
- onboarding, pause, and settings surfaces;
- reduced-motion, sound, and haptic preferences;
- mechanical audio;
- locks, couplings, ratchets, spectrum, and sequence chapters;
- analytics, crash reporting, ads, purchases, and remote content.

