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

The model, engine and level generator are **pure Swift** (no UIKit/SwiftUI), so
they are 100% testable without a UI. The app layer only observes them.

```
ArrowsCore/                 Swift Package — pure, testable core
  Sources/ArrowsCore/
    Models/                 Direction, Position, Arrow, Board, GameState
    Engine/                 ShotResolver, GreedySolver, GameEngine
    Generator/              SeededGenerator, LevelGenerator, DailyChallenge
  Tests/ArrowsCoreTests/    XCTest suites + textual board builder

App/                        SwiftUI app (depends on ArrowsCore)
  project.yml               XcodeGen spec — generates the Xcode project
  Sources/
    ArrowsOfflineApp.swift  @main entry point
    ViewModels/             GameViewModel
    Views/                  Home, Game, Board, Arrow, HUD, Settings, Stats,
                            Collection
    Feedback/               Haptics, SoundFX (system sounds)
    Persistence/            ProgressStore, settings, appearance, skins
```

## Running the tests (core)

From a machine with the Swift toolchain (macOS / Xcode):

```sh
cd ArrowsCore
swift test
```

## Running the app

The Xcode project is generated from `App/project.yml` with
[XcodeGen](https://github.com/yonaskolb/XcodeGen):

```sh
brew install xcodegen   # once
cd App
xcodegen generate
open ArrowsOffline.xcodeproj
```

Then run the `ArrowsOffline` scheme on an iOS 16+ simulator.

## Roadmap

- [x] **Setup** — repo + package structure
- [x] **Engine** — base types, shot resolution, apply move
- [x] **Game Loop** — `GameViewModel`, lives, win/lose orchestration
- [x] **Generator** — seeded placement, greedy solver, validation
- [x] **Board UI** — grid, arrows, HUD, win/lose overlay
- [x] **Persistence** — `ProgressStore`, Home, Continue / New game
- [x] **Polish** — haptics, system sounds, dark mode, hint, settings
- [x] **Extras** — daily challenge + streaks, stats
- [x] **Collection** — unlockable arrow skins

## References

- goarrows (Go terminal clone) — generation logic + greedy solver
- SERAP-KEREM/Arrows (Unity) — component architecture + collision detection
- Original: *Arrows – Puzzle Escape* (Lessmore) — mechanic reference only
