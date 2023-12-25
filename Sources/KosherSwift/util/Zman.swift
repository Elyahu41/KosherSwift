//
//  Zman.swift
//  KosherSwift
//
//  Created by Elyahu Jacobi on 12/21/23.
//

import Foundation

/**
 * A wrapper class for a astronomical times / <em>zmanim</em> that is mostly intended to allow sorting collections of astronomical times.
 * It has fields for both date/time and duration based <em>zmanim</em>, name / labels as well as a longer description or explanation of a
 * <em>zman</em>.
 *
 * Here is an example of various ways of sorting <em>zmanim</em>.
 * <p>First create the Calendar for the location you would like to calculate:
 *
 * <pre style="background: #FEF0C9; display: inline-block;">
 * String locationName = &quot;Lakewood, NJ&quot;;
 * double latitude = 40.0828; // Lakewood, NJ
 * double longitude = -74.2094; // Lakewood, NJ
 * double elevation = 20; // optional elevation correction in Meters
 * // the String parameter in getTimeZone() has to be a valid timezone listed in {@link java.util.TimeZone#getAvailableIDs()}
 * TimeZone timeZone = TimeZone.getTimeZone(&quot;America/New_York&quot;);
 * GeoLocation location = new GeoLocation(locationName, latitude, longitude, elevation, timeZone);
 * ComplexZmanimCalendar czc = new ComplexZmanimCalendar(location);
  * Zman sunset = new Zman(czc.getSunset(), "Sunset");
 * Zman shaah16 = new Zman(czc.getShaahZmanis16Point1Degrees(), "Shaah zmanis 16.1");
 * Zman sunrise = new Zman(czc.getSunrise(), "Sunrise");
 * Zman shaah = new Zman(czc.getShaahZmanisGra(), "Shaah zmanis GRA");
 * ArrayList&lt;Zman&gt; zl = new ArrayList&lt;Zman&gt;();
 * zl.add(sunset);
 * zl.add(shaah16);
 * zl.add(sunrise);
 * zl.add(shaah);
 * //will sort sunset, shaah 1.6, sunrise, shaah GRA
 * System.out.println(zl);
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
public class Zman {
    /**
     * The name / label of the <em>zman</em>.
     */
    private var label:String;
    
    /**
     * The {@link Date} of the <em>zman</em>
     */
    private var zman:Date?;
    
    /**
     * The duration if the <em>zman</em> is  a {@link com.kosherjava.zmanim.AstronomicalCalendar#getTemporalHour() temporal hour} (or the various
     * <em>shaah zmanis</em> base times such as {@link com.kosherjava.zmanim.ZmanimCalendar#getShaahZmanisGra()  <em>shaah Zmanis GRA</em>} or
     * {@link com.kosherjava.zmanim.ComplexZmanimCalendar#getShaahZmanis16Point1Degrees() <em>shaah Zmanis 16.1&deg;</em>}).
     */
    var duration:Int64;
    
    /**
     * A longer description or explanation of a <em>zman</em>.
     */
    var description:String;

    /**
     * The constructor setting a {@link Date} based <em>zman</em> and a label.
     * @param date the Date of the <em>zman</em>.
     * @param label the label of the  <em>zman</em> such as "<em>Sof Zman Krias Shema GRA</em>".
     * @see #Zman(long, String)
     */
    init(label: String, zman: Date?) {
        self.label = label
        self.zman = zman
        self.duration = 0
        self.description = ""
    }

    /**
     * The constructor setting a duration based <em>zman</em> such as
     * {@link com.kosherjava.zmanim.AstronomicalCalendar#getTemporalHour() temporal hour} (or the various <em>shaah zmanis</em> times such as
     * {@link com.kosherjava.zmanim.ZmanimCalendar#getShaahZmanisGra() <em>shaah zmanis GRA</em>} or
     * {@link com.kosherjava.zmanim.ComplexZmanimCalendar#getShaahZmanis16Point1Degrees() <em>shaah Zmanis 16.1&deg;</em>}) and label.
     * @param duration a duration based <em>zman</em> such as ({@link com.kosherjava.zmanim.AstronomicalCalendar#getTemporalHour()}
     * @param label the label of the  <em>zman</em> such as "<em>Shaah Zmanis GRA</em>".
     * @see #Zman(Date, String)
     */
    init(label: String, duration: Int64) {
        self.label = label
        self.duration = duration
        self.description = ""
    }

    /**
     * Returns the {@code Date} based <em>zman</em>.
     * @return the <em>zman</em>.
     * @see #setZman(Date)
     */
    public func getZman() -> Date? {
        return self.zman;
    }

    /**
     * Sets a {@code Date} based <em>zman</em>.
     * @param date a {@code Date} based <em>zman</em>
     * @see #getZman()
     */
    public func setZman(date:Date?) {
        self.zman = date;
    }

    /**
     * Returns a duration based <em>zman</em> such as {@link com.kosherjava.zmanim.AstronomicalCalendar#getTemporalHour() temporal hour}
     * (or the various <em>shaah zmanis</em> times such as {@link com.kosherjava.zmanim.ZmanimCalendar#getShaahZmanisGra() <em>shaah zmanis GRA</em>}
     * or {@link com.kosherjava.zmanim.ComplexZmanimCalendar#getShaahZmanis16Point1Degrees() <em>shaah zmanis 16.1&deg;</em>}).
     * @return the duration based <em>zman</em>.
     * @see #setDuration(long)
     */
    public func getDuration() -> Int64 {
        return self.duration;
    }

    /**
     *  Sets a duration based <em>zman</em> such as {@link com.kosherjava.zmanim.AstronomicalCalendar#getTemporalHour() temporal hour}
     * (or the various <em>shaah zmanis</em> times as {@link com.kosherjava.zmanim.ZmanimCalendar#getShaahZmanisGra() <em>shaah zmanis GRA</em>} or
     * {@link com.kosherjava.zmanim.ComplexZmanimCalendar#getShaahZmanis16Point1Degrees() <em>shaah zmanis 16.1&deg;</em>}).
     * @param duration duration based <em>zman</em> such as {@link com.kosherjava.zmanim.AstronomicalCalendar#getTemporalHour()}.
     * @see #getDuration()
     */
    public func setDuration(duration:Int64) {
        self.duration = duration;
    }

    /**
     * Returns the name / label of the <em>zman</em> such as "<em>Sof Zman Krias Shema GRA</em>". There are no automatically set labels
     * and you must set them using {@link #setLabel(String)}.
     * @return the name/label of the <em>zman</em>.
     * @see #setLabel(String)
     */
    public func getLabel() -> String {
        return self.label;
    }

    /**
     * Sets the the name / label of the <em>zman</em> such as "<em>Sof Zman Krias Shema GRA</em>".
     * @param label the name / label to set for the <em>zman</em>.
     * @see #getLabel()
     */
    public func setLabel(label:String) {
        self.label = label;
    }

    /**
     * Returns the longer description or explanation of a <em>zman</em>. There is no default value for this and it must be set using
     * {@link #setDescription(String)}
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

    /**
     * A {@link Comparator} that will compare and sort <em>zmanim</em> by date/time order. Compares its two arguments by the zman's date/time
     * order. Returns a negative integer, zero, or a positive integer as the first argument is less than, equal to, or greater
     * than the second.
     * Please note that this class will handle cases where either the {@code Zman} is a null or {@link #getZman()} returns a null.
     */
//    public static final Comparator<Zman> DATE_ORDER = new Comparator<Zman>() {
//        public int compare(Zman zman1, Zman zman2) {
//            long firstTime = (zman1 == null || zman1.getZman() == null) ? Long.MAX_VALUE : zman1.getZman().getTime();
//            long secondTime = (zman2 == null || zman2.getZman() == null) ? Long.MAX_VALUE : zman2.getZman().getTime();
//            return Long.valueOf(firstTime).compareTo(Long.valueOf(secondTime));
//        }
//    };

    /**
     * A {@link Comparator} that will compare and sort zmanim by zmanim label order. Compares its two arguments by the zmanim label
     * name order. Returns a negative integer, zero, or a positive integer as the first argument is less than, equal to, or greater
     * than the second.
     * Please note that this class will will sort cases where either the {@code Zman} is a null or {@link #label} returns a null
     * as empty {@code String}s.
     */
//    public static final Comparator<Zman> NAME_ORDER = new Comparator<Zman>() {
//        public int compare(Zman zman1, Zman zman2) {
//            String firstLabel = (zman1 == null || zman1.getLabel() == null) ? "" : zman1.getLabel();
//            String secondLabel = (zman2 == null || zman2.getLabel() == null) ? "" : zman2.getLabel();
//            return firstLabel.compareTo(secondLabel);
//        }
//    };

    /**
     * A {@link Comparator} that will compare and sort duration based <em>zmanim</em>  such as
     * {@link com.kosherjava.zmanim.AstronomicalCalendar#getTemporalHour() temporal hour} (or the various <em>shaah zmanis</em> times
     * such as <em>{@link com.kosherjava.zmanim.ZmanimCalendar#getShaahZmanisGra() shaah zmanis GRA}</em> or
     * {@link com.kosherjava.zmanim.ComplexZmanimCalendar#getShaahZmanis16Point1Degrees() <em>shaah zmanis 16.1&deg;</em>}). Returns a negative
     * integer, zero, or a positive integer as the first argument is less than, equal to, or greater than the second.
     * Please note that this class will will sort cases where {@code Zman} is a null.
     */
//    public static final Comparator<Zman> DURATION_ORDER = new Comparator<Zman>() {
//        public int compare(Zman zman1, Zman zman2) {
//            long firstDuration  = zman1 == null ? Long.MAX_VALUE : zman1.getDuration();
//            long secondDuration  = zman2 == null ? Long.MAX_VALUE : zman2.getDuration();
//            return firstDuration == secondDuration ? 0     : firstDuration > secondDuration ? 1 : -1;
//        }
//    };
    
    /**
     * @see java.lang.Object#toString()
     */
//    public String toString() {
//        StringBuffer sb = new StringBuffer();
//        sb.append("\nLabel:\t\t\t").append(this.getLabel());
//        sb.append("\nZman:\t\t\t").append(getZman());
//        sb.append("\nDuration:\t\t\t").append(getDuration());
//        sb.append("\nDescription:\t\t\t").append(getDescription());
//        return sb.toString();
//    }
}
