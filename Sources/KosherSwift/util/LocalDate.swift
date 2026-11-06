//
//  LocalDate.swift
//  KosherSwift
//
//  A date without a time or time zone (the equivalent of java.time.LocalDate in KosherJava), in the proleptic
//  Gregorian calendar. The calculators work on a LocalDate so that the day being calculated never depends on the
//  time of day or the time zone a Date happens to be in.
//

import Foundation

public struct LocalDate: Hashable, Comparable, CustomStringConvertible {
    /// The proleptic Gregorian year (year 0 is 1 BCE).
    public let year: Int
    /// The month, 1 (January) to 12 (December).
    public let month: Int
    /// The day of the month, 1 to 31.
    public let day: Int

    /// Creates a LocalDate. The values are not validated; use a valid year, month and day.
    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    /// Creates the LocalDate of an epoch day (days since 1970-01-01), like `LocalDate.ofEpochDay(long)`.
    public init(epochDay: Int) {
        // Howard Hinnant's civil_from_days, with 400-year eras starting on March 1
        let z = epochDay + 719468
        let era = (z >= 0 ? z : z - 146096) / 146097
        let dayOfEra = z - era * 146097
        let yearOfEra = (dayOfEra - dayOfEra / 1460 + dayOfEra / 36524 - dayOfEra / 146096) / 365
        let dayOfYear = dayOfEra - (365 * yearOfEra + yearOfEra / 4 - yearOfEra / 100)
        let mp = (5 * dayOfYear + 2) / 153
        let d = dayOfYear - (153 * mp + 2) / 5 + 1
        let m = mp < 10 ? mp + 3 : mp - 9
        self.init(year: yearOfEra + era * 400 + (m <= 2 ? 1 : 0), month: m, day: d)
    }

    /// The date of `date` in `timeZone`.
    public init(date: Date, timeZone: TimeZone) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let components = calendar.dateComponents([.era, .year, .month, .day], from: date)
        let year = components.era == 0 ? 1 - components.year! : components.year!
        self.init(year: year, month: components.month!, day: components.day!)
    }

    /// Today's date in `timeZone`.
    public static func now(timeZone: TimeZone) -> LocalDate {
        return LocalDate(date: Date(), timeZone: timeZone)
    }

    /// The number of days since 1970-01-01 (negative before it), like `LocalDate.toEpochDay()`.
    public var epochDay: Int {
        // Howard Hinnant's days_from_civil
        let y = month <= 2 ? year - 1 : year
        let era = (y >= 0 ? y : y - 399) / 400
        let yearOfEra = y - era * 400
        let dayOfYear = (153 * (month + (month > 2 ? -3 : 9)) + 2) / 5 + day - 1
        let dayOfEra = yearOfEra * 365 + yearOfEra / 4 - yearOfEra / 100 + dayOfYear
        return era * 146097 + dayOfEra - 719468
    }

    /// The day of the year, 1 to 366.
    public var dayOfYear: Int {
        return epochDay - LocalDate(year: year, month: 1, day: 1).epochDay + 1
    }

    /// The ISO day of the week, 1 (Monday) to 7 (Sunday).
    public var isoDayOfWeek: Int {
        return ((epochDay + 3) % 7 + 7) % 7 + 1
    }

    /// True if the year is a Gregorian leap year.
    public var isLeapYear: Bool {
        return LocalDate.isLeapYear(year)
    }

    public static func isLeapYear(_ year: Int) -> Bool {
        return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
    }

    /// The number of days in the month.
    public var lengthOfMonth: Int {
        switch month {
        case 2: return isLeapYear ? 29 : 28
        case 4, 6, 9, 11: return 30
        default: return 31
        }
    }

    public func plusDays(_ days: Int) -> LocalDate {
        return days == 0 ? self : LocalDate(epochDay: epochDay + days)
    }

    public func minusDays(_ days: Int) -> LocalDate {
        return plusDays(-days)
    }

    /// The same month and day in another year; February 29 becomes February 28 in a non-leap year, like
    /// `LocalDate.withYear(int)`.
    public func withYear(_ year: Int) -> LocalDate {
        let lastDay = LocalDate(year: year, month: month, day: 1).lengthOfMonth
        return LocalDate(year: year, month: month, day: min(day, lastDay))
    }

    /// The instant this date starts in UTC.
    public var startOfDayUTC: Date {
        return Date(timeIntervalSince1970: Double(epochDay) * 86400)
    }

    /// The instant this date starts in `timeZone`. A midnight that falls in a daylight saving gap becomes the first
    /// valid time after it, and an ambiguous midnight takes the earlier offset, like `LocalDate.atStartOfDay(ZoneId)`.
    public func atStartOfDay(timeZone: TimeZone) -> Date {
        return atTime(seconds: 0, timeZone: timeZone)
    }

    /// The instant of a local time on this date in `timeZone`, resolving daylight saving gaps and overlaps like java.time:
    /// a time in a gap moves forward by the length of the gap, and an ambiguous time takes the earlier offset.
    public func atTime(seconds: Double, timeZone: TimeZone) -> Date {
        let local = startOfDayUTC.timeIntervalSince1970 + seconds
        // the offsets just before and after the local time; a transition near it gives two candidates
        let before = Double(timeZone.secondsFromGMT(for: Date(timeIntervalSince1970: local - 86400 * 1.5)))
        let after = Double(timeZone.secondsFromGMT(for: Date(timeIntervalSince1970: local + 86400 * 1.5)))
        let candidates = before == after ? [before] : [max(before, after), min(before, after)]
        var valid: [Double] = []
        for offset in candidates {
            let instant = local - offset
            if Double(timeZone.secondsFromGMT(for: Date(timeIntervalSince1970: instant))) == offset {
                valid.append(instant)
            }
        }
        if valid.isEmpty {
            // in the gap: shift forward by the gap, i.e. use the offset before the transition
            let earlier = Double(timeZone.secondsFromGMT(for: Date(timeIntervalSince1970: local - min(before, after) - 86400)))
            return Date(timeIntervalSince1970: local - earlier)
        }
        // overlap: java.time uses the earlier offset (the one before the transition), which is the earliest instant
        return Date(timeIntervalSince1970: valid.min()!)
    }

    public static func < (lhs: LocalDate, rhs: LocalDate) -> Bool {
        return (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }

    /// The ISO-8601 form, for example 2026-03-08.
    public var description: String {
        let y = year >= 0 && year <= 9999 ? String(format: "%04d", year) : (year > 9999 ? "+\(year)" : String(format: "-%04d", -year))
        return "\(y)-\(String(format: "%02d", month))-\(String(format: "%02d", day))"
    }
}

/// Math helpers that match Java's `Math` methods bit for bit where KosherJava depends on them.
enum JavaMath {
    /// `Math.toDegrees(double)`: Java multiplies by the constant 180 / π.
    static func toDegrees(_ radians: Double) -> Double {
        return radians * 57.29577951308232
    }

    /// `Math.toRadians(double)`: Java multiplies by the constant π / 180.
    static func toRadians(_ degrees: Double) -> Double {
        return degrees * 0.017453292519943295
    }

    /// Java's `%` for doubles (the result has the sign of the dividend).
    static func rem(_ a: Double, _ b: Double) -> Double {
        return a.truncatingRemainder(dividingBy: b)
    }

    /// Java's `(long)` cast of a double: truncates toward zero, NaN is 0 and out of range values saturate (a plain Swift
    /// conversion would crash instead).
    static func toLong(_ value: Double) -> Int64 {
        if value.isNaN { return 0 }
        if value >= 9.2233720368547758E18 { return Int64.max }
        if value <= -9.2233720368547758E18 { return Int64.min }
        return Int64(value)
    }

    /// Java's `(int)` cast of a double.
    static func toInt(_ value: Double) -> Int {
        if value.isNaN { return 0 }
        if value >= 2147483647.0 { return Int(Int32.max) }
        if value <= -2147483648.0 { return Int(Int32.min) }
        return Int(value)
    }

    /// Java's `Instant.toEpochMilli()`: the milliseconds since the epoch, rounded down.
    static func toEpochMilli(_ date: Date) -> Int64 {
        return toLong((date.timeIntervalSince1970 * 1000).rounded(.down))
    }

    /// `Math.round(double)`: the closest long, ties rounding toward positive infinity.
    static func round(_ value: Double) -> Int64 {
        return toLong((value + 0.5).rounded(.down))
    }
}

/// Helpers for `java.time` behavior that KosherJava depends on.
enum JavaTime {
    /// The UTC date and time-of-day fields of an instant, like `instant.atZone(ZoneOffset.UTC)`. `nano` is the
    /// fraction of the second in nanoseconds (Swift's Date resolution is coarser than a nanosecond).
    static func utcFields(_ date: Date) -> (localDate: LocalDate, hour: Int, minute: Int, second: Int, nano: Double) {
        let seconds = date.timeIntervalSince1970
        let epochDay = (seconds / 86400).rounded(.down)
        var secondOfDay = seconds - epochDay * 86400
        var day = Int(epochDay)
        if secondOfDay >= 86400 { // rounding at the very end of a day
            secondOfDay -= 86400
            day += 1
        }
        let wholeSeconds = secondOfDay.rounded(.down)
        let s = Int(wholeSeconds)
        return (LocalDate(epochDay: day), s / 3600, s / 60 % 60, s % 60, ((secondOfDay - wholeSeconds) * 1_000_000_000).rounded())
    }
}

extension Date {
    /// Java's `Instant.isBefore(Instant)`.
    func isBefore(_ other: Date) -> Bool {
        return self < other
    }

    /// Java's `Instant.isAfter(Instant)`.
    func isAfter(_ other: Date) -> Bool {
        return self > other
    }
}
