//
//  Zman.swift
//  KosherSwift
//
//  Created by Elyahu Jacobi on 12/21/23.
//

import Foundation

/**
 * A wrapper class for astronomical times / <em>zmanim</em> that is mostly intended to allow sorting collections of astronomical times.
 * It has fields for both date/time and duration based <em>zmanim</em>, name / labels as well as a longer description or explanation of a
 * <em>zman</em>.
 *
 * Here is an example of various ways of sorting <em>zmanim</em>.
 * First create the Calendar for the location you would like to calculate:
 * ```
 * let location = GeoLocation(locationName: "Lakewood, NJ", latitude: 40.0828, longitude: -74.2094, elevation: 20,
 *                            timeZone: TimeZone(identifier: "America/New_York")!)
 * let czc = ComprehensiveZmanimCalendar(location: location)
 * let sunset = Zman(zman: czc.getSunset(), label: "Sunset")
 * let shaah16 = Zman(duration: czc.getShaahZmanis16Point1Degrees(), label: "Shaah zmanis 16.1")
 * let sunrise = Zman(zman: czc.getSunrise(), label: "Sunrise")
 * let shaah = Zman(duration: czc.getShaahZmanisGRA(), label: "Shaah zmanis GRA")
 * let zl = [sunset, shaah16, sunrise, shaah]
 * // will sort sunrise, sunset, shaah GRA, shaah 16.1
 * var sorted = zl.sorted(by: Zman.dateOrder)
 * // will sort shaah GRA, shaah 16.1, sunrise, sunset
 * sorted = zl.sorted(by: Zman.durationOrder)
 * // will sort shaah zmanis 16.1, shaah zmanis GRA, sunrise, sunset
 * sorted = zl.sorted(by: Zman.nameOrder)
 * ```
 *
 * @author &copy; Eliyahu Hershfeld 2007-2026
 */
public class Zman: Equatable {
    /** The name / label of the <em>zman</em>. */
    public var label: String?

    /** The time of the <em>zman</em>. */
    public var zman: Date?

    /** The duration (in seconds) if the object is used for a duration such as a <em>sha'ah zmanis</em>. */
    public var duration: TimeInterval?

    /** A longer description or explanation of a <em>zman</em>. */
    public var description: String?

    /** The location of the <em>zman</em>, used to format it in the location's time zone. */
    public var geoLocation: GeoLocation?

    /**
     * The constructor setting a `Date` based <em>zman</em> and a label.
     *
     * - Parameters:
     *   - zman: the time of the <em>zman</em>.
     *   - label: the label of the <em>zman</em>, such as "<em>Sof Zman Krias Shema GRA</em>".
     */
    public convenience init(zman: Date?, label: String?) {
        self.init(zman: zman, geoLocation: nil, label: label)
    }

    /**
     * The constructor setting a `Date` based <em>zman</em>, the location it is for and a label.
     *
     * - Parameters:
     *   - zman: the time of the <em>zman</em>.
     *   - geoLocation: the location of the <em>zman</em>.
     *   - label: the label of the <em>zman</em>, such as "<em>Sof Zman Krias Shema GRA</em>".
     */
    public init(zman: Date?, geoLocation: GeoLocation?, label: String?) {
        self.zman = zman
        self.geoLocation = geoLocation
        self.label = label
    }

    /**
     * The constructor setting a duration based <em>zman</em> such as a <em>sha'ah zmanis</em>, and a label.
     *
     * - Parameters:
     *   - duration: the duration of the <em>zman</em> in seconds.
     *   - label: the label of the <em>zman</em>, such as "<em>Shaah Zmanis GRA</em>".
     */
    public init(duration: TimeInterval?, label: String?) {
        self.label = label
        self.duration = duration
    }

    /** Returns the <em>zman</em>. */
    public func getZman() -> Date? {
        return zman
    }

    /** Sets the <em>zman</em>. */
    public func setZman(date: Date?) {
        self.zman = date
    }

    /** Returns the location of the <em>zman</em>. */
    public func getGeoLocation() -> GeoLocation? {
        return geoLocation
    }

    /** Sets the location of the <em>zman</em>. */
    public func setGeoLocation(geoLocation: GeoLocation?) {
        self.geoLocation = geoLocation
    }

    /** Returns the duration in seconds. */
    public func getDuration() -> TimeInterval? {
        return duration
    }

    /** Sets the duration in seconds. */
    public func setDuration(duration: TimeInterval?) {
        self.duration = duration
    }

    /** Returns the label of the <em>zman</em>. */
    public func getLabel() -> String? {
        return label
    }

    /** Sets the label of the <em>zman</em>. */
    public func setLabel(label: String?) {
        self.label = label
    }

    /** Returns the description of the <em>zman</em>. */
    public func getDescription() -> String? {
        return description
    }

    /** Sets the description of the <em>zman</em>. */
    public func setDescription(description: String?) {
        self.description = description
    }

    /// Three-way comparison of optional values, with nil sorting last.
    private static func compareNilLast<T: Comparable>(_ a: T?, _ b: T?) -> Int? {
        switch (a, b) {
        case let (a?, b?): return a < b ? -1 : (a > b ? 1 : 0)
        case (_?, nil): return -1
        case (nil, _?): return 1
        default: return nil
        }
    }

    /**
     * A comparison of two <em>zmanim</em> by their times, for sorting (`zmanim.sort(by: Zman.dateOrder)`). <em>Zmanim</em>
     * without a time sort after those with one, by duration.
     */
    public static let dateOrder: (Zman, Zman) -> Bool = { z1, z2 in
        return (compareNilLast(z1.zman, z2.zman) ?? compareNilLast(z1.duration, z2.duration) ?? 0) < 0
    }

    /** A comparison of two <em>zmanim</em> by their labels, for sorting. A nil label sorts first. */
    public static let nameOrder: (Zman, Zman) -> Bool = { z1, z2 in
        switch (z1.label, z2.label) {
        case let (a?, b?): return a < b
        case (nil, _?): return true
        default: return false
        }
    }

    /**
     * A comparison of two <em>zmanim</em> by their durations, for sorting a list of <em>sha'os zmaniyos</em>. Those without
     * a duration sort after those with one, by time.
     */
    public static let durationOrder: (Zman, Zman) -> Bool = { z1, z2 in
        return (compareNilLast(z1.duration, z2.duration) ?? compareNilLast(z1.zman, z2.zman) ?? 0) < 0
    }

    public static func == (lhs: Zman, rhs: Zman) -> Bool {
        return lhs.equals(rhs)
    }

    /// True if both have the same label, time, duration, description and location.
    public func equals(_ other: Zman) -> Bool {
        let sameLocation: Bool
        switch (geoLocation, other.geoLocation) {
        case let (a?, b?): sameLocation = a.equals(b)
        case (nil, nil): sameLocation = true
        default: sameLocation = false
        }
        return label == other.label && zman == other.zman && duration == other.duration
            && description == other.description && sameLocation
    }

    /**
     * An XML representation of the <em>zman</em>. The time is formatted in the location's time zone (UTC if there is no
     * location) as yyyy-MM-dd'T'HH:mm:ss.SSS, and the duration as an xsd:duration. Text values are XML escaped.
     */
    public func toXML() -> String {
        let timeZone = geoLocation?.getTimeZone() ?? TimeZone(identifier: "UTC")!
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        var sb = "<Zman>\n"
        sb += "\t<Label>" + ZmanimFormatter.escapeXML(label ?? "null") + "</Label>\n"
        sb += "\t<Zman>" + (zman == nil ? "" : formatter.string(from: zman!)) + "</Zman>\n"
        if let geoLocation = geoLocation {
            sb += "\t" + geoLocation.toXML().replacingOccurrences(of: "\n", with: "\n\t")
        }
        let durationText = duration.map { ZmanimFormatter(timeZone: timeZone).formatXSDDurationTime(duration: $0) } ?? "null"
        sb += "\n\t<Duration>" + durationText + "</Duration>\n"
        sb += "\t<Description>" + ZmanimFormatter.escapeXML(description ?? "null") + "</Description>\n"
        sb += "</Zman>"
        return sb
    }

    /** A string representation of the <em>zman</em>. */
    public func toString() -> String {
        var sb = ""
        sb += "\nLabel:\t" + (label ?? "null")
        sb += "\nZman:\t" + (zman.map { "\($0)" } ?? "null")
        sb += "\nGeoLocation:\t"
        if let geoLocation = geoLocation {
            sb += geoLocation.toString().replacingOccurrences(of: "\n", with: "\n\t")
        } else {
            sb += "null"
        }
        sb += "\nDuration:\t" + (duration.map { ZmanimFormatter(timeZone: TimeZone(identifier: "UTC")!).formatXSDDurationTime(duration: $0) } ?? "null")
        sb += "\nDescription:\t" + (description ?? "null")
        return sb
    }
}
