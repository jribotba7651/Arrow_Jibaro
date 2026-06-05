# 🏹 Arrows Offline (SwiftUI)

Offline, 100% local reimplementation of the *Arrows – Puzzle Escape* mechanic,
built from scratch in SwiftUI for personal use. No account, no Firebase, no ads,
no network.

> **IP note:** a game's *mechanic* isn't anyone's property, so reimplementing it
> is legitimate. For personal use there's no issue. If this is ever published,
> use original name, art and levels — don't copy Lessmore's assets or brand.

## The mechanic

An NxN grid filled with arrows pointing in 4 directions. Tap an arrow and it
fires straight in its direction. If its path to the edge is clear, it leaves the
board. If another arrow is in the way, it collides and you lose a life. You win
when the board is empty. No timer, no pressure.

## Project layout

The model and engine are **pure Swift** (no UIKit/SwiftUI), so they are 100%
testable without a UI. The app layer only observes them.

```
ArrowsCore/                 Swift Package — pure, testable core
  Sources/ArrowsCore/
    Models/                 Direction, Position, Arrow, Board, GameState
    Engine/                 ShotResolver, GameEngine
  Tests/ArrowsCoreTests/    XCTest suites + textual board builder
```

The SwiftUI app (added in a later phase) depends on `ArrowsCore` as a local
Swift Package.

## Running the tests

From a machine with the Swift toolchain (macOS / Xcode):

```sh
cd ArrowsCore
swift test
```

## Roadmap

- [x] **Setup** — repo + package structure
- [x] **Engine** — base types, shot resolution, apply move
- [ ] **Game Loop** — `GameViewModel`, lives, win/lose orchestration
- [ ] **Generator** — seeded placement, greedy solver, validation
- [ ] **Board UI** — grid, arrows, fire/collision animations, HUD
- [ ] **Persistence** — `ProgressStore`, Home, level navigation
- [ ] **Polish** — haptics, sounds, dark mode, hint, settings
- [ ] **Extras** — daily challenge, streaks, collection

Full plan and task board live in Notion (*Arrows Offline (SwiftUI)*).
