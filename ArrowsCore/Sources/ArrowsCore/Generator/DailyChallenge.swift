import Foundation

/// Derives a deterministic seed from a calendar day, so everyone playing the
/// "daily" on the same date gets the same level — no network required.
public enum DailyChallenge {
    /// Seed encoded as YYYYMMDD.
    public static func seed(year: Int, month: Int, day: Int) -> UInt64 {
        UInt64(year) &* 10_000 &+ UInt64(month) &* 100 &+ UInt64(day)
    }

    /// Seed for the calendar day of `date` in the given calendar.
    public static func seed(for date: Date, calendar: Calendar = .current) -> UInt64 {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return seed(
            year: components.year ?? 0,
            month: components.month ?? 0,
            day: components.day ?? 0
        )
    }
}
