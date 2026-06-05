# Handoff — Arrows Offline (SwiftUI)

Continue this project in Claude Code on the Mac. This file is the single source
of truth for picking up where the web session left off.

## What this is
An offline, 100% local SwiftUI clone of the *Arrows – Puzzle* mechanic
(Lessmore). No account, no network, no ads. Personal use; original assets/levels
only (mechanic reimplemented from scratch).

## Repo / branch / location
- Repo: `jribotba7651/arrow_jibaro`
- Work branch: `claude/youthful-ramanujan-f1UPC` (ALL changes go here)
- Local path: `/Users/juanribot/Arrow_Jibaro`
- Open PR: #1 (this branch -> main). Commit + push when done.

## Project layout
```
ArrowsCore/                 Pure-Swift package (no UIKit/SwiftUI) + XCTest
  Sources/ArrowsCore/
    Models/    Direction, Position, Piece, Board, GameState
    Engine/    ShotResolver, GameEngine, GreedySolver
    Generator/ LevelGenerator, SeededGenerator, DailyChallenge
  Tests/ArrowsCoreTests/    XCTest suites
App/                        SwiftUI app (depends on ArrowsCore)
  project.yml               XcodeGen spec -> generates ArrowsOffline.xcodeproj
  Sources/
    ArrowsOfflineApp.swift  @main
    ViewModels/GameViewModel.swift
    Views/                  Home, Game, Board, HUD, Settings, Stats, Collection,
                            ArrowView (legacy glyph), Effects/*
    Persistence/            ProgressStore, ArrowSkin, settings keys, appearance
.github/workflows/ci.yml    CI: swift test (macos-14) + xcodebuild (macos-15)
```

## Build / run / test
```sh
# core (fast, pure Swift)
cd ArrowsCore && swift test

# app
cd App && xcodegen generate && open ArrowsOffline.xcodeproj
# In Xcode: Shift+Cmd+K (clean), Cmd+R (run) on an iOS 16+ simulator.
```
IMPORTANT: after adding/removing files under `App/Sources`, re-run
`xcodegen generate` (the project lists files explicitly). Files inside the
`ArrowsCore` Swift package are picked up automatically.

## Mechanic (current model)
- A `Piece` is a CONNECTED PATH of cells (`cells: [Position]`, tail..head) that
  can bend at corners (snake-like). `headDirection` is the last segment's
  direction. `head = cells.last`, `tail = cells.first`.
- `Board` stores `pieces: [Int: Piece]` and an `occupancy: [[Int?]]` grid.
- Tap a piece -> it slides along `headDirection`. `ShotResolver` returns
  `.escaped` if the straight path from the head to the border is clear, else
  `.blocked(by: pieceID)`. Escape removes the piece; blocked loses a life.
- Win when the board is empty; lose at 0 lives.
- `LevelGenerator` builds boards in REVERSE: each new piece is a self-avoiding
  random walk placed only if its head's forward path is clear of already-placed
  pieces AND of its own body. This guarantees the board is always greedy-
  solvable (removing pieces only frees cells). Deterministic from the seed.

## Status
- Core: compiles, all XCTest pass (CI green on the core job).
- App: compiles and runs (Xcode 16 / iOS sim).
- Bent snake pieces render as one continuous rounded line with a chevron head;
  tapping a piece slides it off the board. (Tap fix: cells use
  `.contentShape(Rectangle())` so taps register.)

## The goal right now: make it look like the original
The original (see level 10 "Hard") is a DENSE maze of connected bent arrows,
thin rounded line-art, on a light dotted paper background. Ours currently looks
too SPARSE and the lines a bit thick. Iterate visually (build + run + compare
screenshots) on:

1. **Density (highest impact).** `ArrowsCore/Sources/ArrowsCore/Generator/LevelGenerator.swift`
   should fill MOST of the board (few empty cells) while staying solvable. The
   reverse-placement invariant (head forward-path clear of placed pieces) must
   be preserved so it never produces an unsolvable board. Consider: more/longer
   walks, smarter anchor/direction choice favoring near-border heads, and a
   stronger leftover-cell fill pass. Re-run `swift test` after changes
   (`testGeneratedLevelsAreSolvable`, `testGenerationIsDeterministic`).
2. **Line weight / proportions.** `App/Sources/Views/BoardView.swift` ->
   `strokeStyle` currently `lineWidth = cellSize * 0.12`. Tune line width,
   chevron size (`PiecePath`), cell `spacing`, and head extension to match the
   reference.
3. **Layout polish.** The board can be bigger / better centered; reduce empty
   white space below it (`GameView`).
4. **Cleanup (optional).** `ArrowView.swift` / `FlyingArrowView.swift` are
   legacy single-arrow glyphs (CollectionView still uses `ArrowGlyph`). Remove
   or repurpose if not needed.

## Key files for the visual work
- `App/Sources/Views/BoardView.swift` — `PiecePath` (the rounded line), tap
  targets, slide-out `GhostPieceView`, collision shake, `DotGrid`. This is the
  main rendering file.
- `ArrowsCore/Sources/ArrowsCore/Generator/LevelGenerator.swift` — density.

## Constraints / preferences
- Keep it 100% offline (no network).
- Keep the core pure Swift and test-covered; run `swift test` after core edits.
- Keep generation deterministic from the seed and always solvable.
- Match the reference look: dense, thin rounded connected lines, dotted bg.

## Suggested first prompt for the CLI session
> Read HANDOFF.md. The app builds and runs on this branch. Make the board look
> like the original Arrows puzzle: much denser packing (LevelGenerator) and
> finer rounded lines (BoardView/PiecePath), iterating by building and running
> in the iOS simulator and comparing to reference screenshots. Keep the core
> solvable and tested (swift test).
