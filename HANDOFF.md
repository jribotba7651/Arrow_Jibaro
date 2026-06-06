# Handoff — Arrows Offline (SwiftUI)

Continue this project in Claude Code on the Mac. This file is the single source
of truth for picking up where the web session left off.

---

## ⛔️ NON-NEGOTIABLE RULES (read first)

1. **Do not break the existing game mechanic.** The arrow maze must remain
   solvable by design. Any visual/density improvement must preserve the current
   deterministic seeded generation and the puzzle rules (tap a piece -> it
   slides along its head direction -> escapes if the path to the border is
   clear, else collision/lose a life; win when the board is cleared).

2. **Do not sacrifice guaranteed solvability.** Every generated level must be
   solvable (greedy solver clears it). If a change makes the maze prettier but
   reduces solvability, REJECT the change. Keep the reverse placement: a piece
   is placed only if its head's forward path is clear of placed pieces and its
   own body. Verify with `swift test` (`testGeneratedLevelsAreSolvable`,
   `testGenerationIsDeterministic`).

3. **Density inspiration only — do NOT add scope.** Use the "dense circuit /
   subway / snake routes" look as inspiration, but DO NOT add: JSON level
   systems, zoom/pan, 50x50–100x100 boards, mirrors, portals, walls, or new
   piece types. Those are future features, not this task. Boards here are small
   (3x3 .. ~8x8) and generated from a seed.

**Focus only on:** denser arrow paths · thinner rounded lines · smoother
corners · subtle dot-grid background · preserving deterministic seeded
generation · preserving guaranteed solvability.

---

## What this is
An offline, 100% local SwiftUI clone of the *Arrows – Puzzle* mechanic
(Lessmore). No account, no network, no ads. Mechanic reimplemented from scratch.

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
After adding/removing files under `App/Sources`, re-run `xcodegen generate`
(the project lists files explicitly). Files inside the `ArrowsCore` Swift
package are picked up automatically.

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
  tapping a piece slides it off the board. Tap targets use
  `.contentShape(Rectangle())` so taps register.

## The goal right now: make it look like the original
The original (level 10 "Hard") is a DENSE maze of connected bent arrows, thin
rounded line-art, on a light dotted paper background. Ours currently looks too
SPARSE and the lines a bit thick. Iterate visually (build + run + compare
screenshots), within the NON-NEGOTIABLE RULES above:

1. **Density (highest impact).** In
   `ArrowsCore/Sources/ArrowsCore/Generator/LevelGenerator.swift`, fill ~75-90%
   of cells with longer, turn-heavy paths, WHILE keeping the reverse-placement
   solvability invariant and determinism. Re-run `swift test`.
2. **Line weight / proportions.** In `App/Sources/Views/BoardView.swift` ->
   `strokeStyle` (currently `lineWidth = cellSize * 0.12`), `PiecePath` (chevron
   size, head extension), and `spacing`. Tune to the reference (fine rounded
   lines).
3. **Layout polish.** Board can be bigger / better centered (`GameView`).
4. **Cleanup (optional).** `ArrowView.swift` / `FlyingArrowView.swift` are
   legacy single-arrow glyphs (CollectionView still uses `ArrowGlyph`).

## Key files for the visual work
- `App/Sources/Views/BoardView.swift` — `PiecePath` (the rounded line), tap
  targets, slide-out `GhostPieceView`, collision shake, `DotGrid`.
- `ArrowsCore/Sources/ArrowsCore/Generator/LevelGenerator.swift` — density.

## Already solved (do not rebuild)
The board already uses grid coordinates (not pixels), procedural rendering, a
`Canvas`-drawn dot grid, and automatic scaling/centering via `GeometryReader` +
`.aspectRatio(1)`. No generic 100x100 dot-grid engine is needed.

## Suggested first prompt for the CLI session (speak Spanish, guide me)
> Lee HANDOFF.md y respeta las NON-NEGOTIABLE RULES. La app compila y corre en
> esta rama. Haz el tablero más denso (LevelGenerator, ~75-90% de celdas,
> siempre resoluble y determinista) y las líneas más finas/redondeadas
> (BoardView/PiecePath), iterando con build+run en el simulador y comparando con
> screenshots de referencia. Corre `swift test` tras cambios del núcleo.
> Guíame en español paso a paso; commit+push a la rama.
