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
 * <p>First create the Calendar for the location you would like to calculate:
 *
 * <pre style="background: #FEF0C9; display: inline-block;">
 * let locationName = &quot;Lakewood, NJ&quot;;
 * let latitude = 40.0828; // Lakewood, NJ
 * let longitude = -74.2094; // Lakewood, NJ
 * let elevation = 20; // optional elevation correction in Meters
 * // the String parameter in getTimeZone() has to be a valid timezone listed in {@link java.util.TimeZone#getAvailableIDs()}
 * let timeZone = TimeZone.getTimeZone(&quot;America/New_York&quot;);
 * let location = GeoLocation(locationName, latitude, longitude, elevation, timeZone);
 * let czc = ComplexZmanimCalendar(location);
 * let sunset = Zman(czc.getSunset(), "Sunset");
 * let shaah16 = Zman(czc.getShaahZmanis16Point1Degrees(), "Shaah zmanis 16.1");
 * let sunrise = Zman(czc.getSunrise(), "Sunrise");
 * let shaah = Zman(czc.getShaahZmanisGra(), "Shaah zmanis GRA");
 * let zl = new Array&lt;Zman&gt;();
 * zl.add(sunset);
 * zl.add(shaah16);
 * zl.add(sunrise);
 * zl.add(shaah);
 * //will sort sunset, shaah 16, sunrise, shaah GRA
 * print(zl);
 * Collections.sort(zl, Zman.DATE_ORDER);
 * // will sort sunrise, sunset, shaah, shaah 1.6 (the last 2 are not in any specific order)
 * Collections.sort(zl, Zman.DURATION_ORDER);
 * // will sort sunrise, sunset (the first 2 are not in any specific order), shaah GRA, shaah 1.6
 * Collections.sort(zl, Zman.NAME_ORDER);
 * // will sort shaah 1.6, shaah GRA, sunrise, sunset
 * </pre>
 *
 * @author &copy; Eliyahu Hershfeld 2007-2020
 * @todo Add secondary sorting. As of now the {@code Comparator}s in this class do not sort by secondary order. This means that when sorting a
 * {@link java.util.Collection} of <em>zmanim</em> and using the {@link #DATE_ORDER} {@code Comparator} will have the duration based <em>zmanim</em>
 * at the end, but they will not be sorted by duration. This should be N/A for label based sorting.
 */
public class Zman: Equatable {
    /**
     * The name / label of the <em>zman</em>.
     */
    public var label:String;
    
    /**
     * The Date of the <em>zman</em>
     */
    public var zman:Date?;
    
    /**
     * The duration if the <em>zman</em> is  a ``AstronomicalCalendar.getTemporalHour()`` temporal hour (or the various
     * <em>shaah zmanis</em> base times such as ``ZmanimCalendar.getShaahZmanisGra()``  <em>shaah Zmanis GRA</em> or
     * ``ComplexZmanimCalendar.getShaahZmanis16Point1Degrees()`` <em>shaah Zmanis 16.1&deg;</em>).
     */
    public var duration:Int64;
    
    /**
     * A longer description or explanation of a <em>zman</em>.
     */
    public var description:String;

    /**
     * The constructor setting a ``Date`` based <em>zman</em> and a label.
     * @param date the Date of the <em>zman</em>.
     * @param label the label of the  <em>zman</em> such as "<em>Sof Zman Krias Shema GRA</em>".
     * @see #Zman(long, String)
     */
    public init(label: String, zman: Date?) {
        self.label = label
        self.zman = zman
        self.duration = 0
        self.description = ""
    }

    /**
     * The constructor setting a duration based <em>zman</em> such as
     * ``AstronomicalCalendar.getTemporalHour()`` temporal hour (or the various <em>shaah zmanis</em> times such as
     * ``ZmanimCalendar.getShaahZmanisGra()`` <em>shaah zmanis GRA</em> or
     * ``ComplexZmanimCalendar.getShaahZmanis16Point1Degrees()`` <em>shaah Zmanis 16.1&deg;</em>) and label.
     * @param duration a duration based <em>zman</em> such as (``AstronomicalCalendar.getTemporalHour()``
     * @param label the label of the  <em>zman</em> such as "<em>Shaah Zmanis GRA</em>".
     * @see #Zman(Date, String)
     */
    public init(label: String, duration: Int64) {
        self.label = label
        self.duration = duration
        self.description = ""
    }

    /**
     * Returns the Date based <em>zman</em>.
     * @return the <em>zman</em>.
     * @see #setZman(Date)
     */
    public func getZman() -> Date? {
        return self.zman;
    }

    /**
     * Sets a Date based <em>zman</em>.
     * @param date a {@code Date} based <em>zman</em>
     * @see #getZman()
     */
    public func setZman(date:Date?) {
        self.zman = date;
    }

    /**
     * Returns a duration based <em>zman</em> such as ``AstronomicalCalendar#getTemporalHour()`` temporal hour
     * (or the various <em>shaah zmanis</em> times such as ``ZmanimCalendar.getShaahZmanisGra()`` <em>shaah zmanis GRA</em>
     * or ``ComplexZmanimCalendar.getShaahZmanis16Point1Degrees()`` <em>shaah zmanis 16.1&deg;</em>).
     * @return the duration based <em>zman</em>.
     * @see #setDuration(long)
     */
    public func getDuration() -> Int64 {
        return self.duration;
    }

    /**
     *  Sets a duration based <em>zman</em> such as ``AstronomicalCalendar.getTemporalHour()`` temporal hour
     * (or the various <em>shaah zmanis</em> times as ``ZmanimCalendar.getShaahZmanisGra()`` <em>shaah zmanis GRA</em> or
     * ``ComplexZmanimCalendar.getShaahZmanis16Point1Degrees()`` <em>shaah zmanis 16.1&deg;</em>).
     * @param duration duration based <em>zman</em> such as ``AstronomicalCalendar#getTemporalHour()``.
     * @see #getDuration()
     */
    public func setDuration(duration:Int64) {
        self.duration = duration;
    }

    /**
     * Returns the name / label of the <em>zman</em> such as "<em>Sof Zman Krias Shema GRA</em>". There are no automatically set labels
     * and you must set them using ``setLabel(label:)``.
     * @return the name/label of the <em>zman</em>.
     * @see #setLabel(String)
     */
    public func getLabel() -> String {
        return self.label;
    }

    /**
     * Sets the name / label of the <em>zman</em> such as "<em>Sof Zman Krias Shema GRA</em>".
     * @param label the name / label to set for the <em>zman</em>.
     * @see #getLabel()
     */
    public func setLabel(label:String) {
        self.label = label;
    }

    /**
     * Returns the longer description or explanation of a <em>zman</em>. There is no default value for this and it must be set using
     * ``setDescription(description:)``
     * @return the description or explanation of a <em>zman</em>.
     * @see #setDescription(String)
     */
    public func getDescription() -> String {
        return self.description;
    }

    /**
     * Sets the longer description or explanation of a <em>zman</em>.
     * @param description
     *            the <em>zman</em> description to set.
     * @see #getDescription()
     */
    public func setDescription(description:String) {
        self.description = description;
    }
    
    /// Sorts zmanim by date/time order. Nil objects or nil dates are placed at the end.
    public static let dateOrder: (Zman?, Zman?) -> Bool = { z1, z2 in
        // Use Date.distantFuture to mimic Long.MAX_VALUE (sorting nils to the end)
        let firstTime = z1?.zman ?? Date.distantFuture
        let secondTime = z2?.zman ?? Date.distantFuture
        return firstTime < secondTime
    }
    
    /// Sorts zmanim by label name order. Nil labels are treated as empty strings.
    public static let nameOrder: (Zman?, Zman?) -> Bool = { z1, z2 in
        let firstLabel = z1?.label ?? ""
        let secondLabel = z2?.label ?? ""
        return firstLabel.localizedCompare(secondLabel) == .orderedAscending
    }
    
    /// Sorts duration-based zmanim (like Shaah Zmanis). Nil objects are placed at the end.
    public static let durationOrder: (Zman?, Zman?) -> Bool = { z1, z2 in
        let firstDuration = z1?.duration ?? Int64.max
        let secondDuration = z2?.duration ?? Int64.max
        return firstDuration < secondDuration
    }
    
    public static func == (lhs: Zman, rhs: Zman) -> Bool {
        return lhs.label == rhs.label &&
        lhs.zman == rhs.zman &&
        lhs.duration == rhs.duration &&
        lhs.description == rhs.description
    }
    
    /// Compares this object with another instance for equality.
    ///
    /// - Parameter other: Another Zman instance to compare against.
    /// - Returns: `true` if all relevant properties match; otherwise `false`.
    public func equals(_ other: Zman) -> Bool {
        return self.label == other.label &&
        self.zman == other.zman &&
        self.duration == other.duration &&
        self.description == other.description
    }
    
    /// Returns a string representation of the Zman, including label, time, duration, and description.
    public func toString() -> String {
        var sb = ""
        sb += "\nLabel:\t\t\t\(label)"
        sb += "\nZman:\t\t\t\(zman?.description ?? "nil")"
        sb += "\nDuration:\t\t\t\(duration)"
        sb += "\nDescription:\t\t\t\(description)"
        return sb
    }
}
