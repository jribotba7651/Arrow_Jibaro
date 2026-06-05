import ArrowsCore

/// Builds a `Board` from a textual diagram, e.g.:
///
///     makeBoard([
///         ">.<",
///         ".^.",
///         "v.>",
///     ])
///
/// Legend: `^` up, `v` down, `<` left, `>` right, `.` empty.
/// Arrow ids are assigned in row-major order starting at 0.
enum BoardFactory {
    static func makeBoard(_ rows: [String]) -> Board {
        let size = rows.count
        precondition(rows.allSatisfy { $0.count == size }, "diagram must be square")
        var cells = [[Arrow?]](repeating: [Arrow?](repeating: nil, count: size), count: size)
        var nextID = 0
        for (r, line) in rows.enumerated() {
            for (c, ch) in line.enumerated() {
                guard let dir = direction(for: ch) else { continue }
                cells[r][c] = Arrow(id: nextID, direction: dir)
                nextID += 1
            }
        }
        return Board(size: size, cells: cells)
    }

    private static func direction(for ch: Character) -> Direction? {
        switch ch {
        case "^": return .up
        case "v": return .down
        case "<": return .left
        case ">": return .right
        case ".": return nil
        default: preconditionFailure("unexpected board char: \(ch)")
        }
    }
}
