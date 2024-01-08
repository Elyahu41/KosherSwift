//
//  Time.swift
//  KosherSwift
//
//  Created by Elyahu Jacobi on 12/21/23.
//

import Foundation

/**
 * A class that represents a numeric time. Times that represent a time of day are stored as ``Date``s in
 * this API. The time class is used to represent numeric time such as the time in hours, minutes, seconds and
 * milliseconds of a ``AstronomicalCalendar.getTemporalHour()`` temporal hour.
 *
 * @author &copy; Eliyahu Hershfeld 2004 - 2020
 */
public class Time {
    
    /** milliseconds in a second. */
    private static let SECOND_MILLIS = 1000;

    /** milliseconds in a minute. */
    private static let MINUTE_MILLIS = SECOND_MILLIS * 60;

    /** milliseconds in an hour. */
    private static let HOUR_MILLIS = MINUTE_MILLIS * 60;

    /**
     * @see #getHours()
     */
    public var hours = 0;

    /**
     * @see #getMinutes()
     */
    public var minutes = 0;

    /**
     * @see #getSeconds()
     */
    public var seconds = 0;

    /**
     * @see #getMilliseconds()
     */
    public var milliseconds = 0;

    /**
     * @see #isNegative()
     * @see #setIsNegative(boolean)
     */
    public var isNegative = false;

    /**
     * Constructor with parameters for the hours, minutes, seconds and millisecods.
     *
     * @param hours the hours to set
     * @param minutes the minutes to set
     * @param seconds the seconds to set
     * @param milliseconds the milliseconds to set
     */
    public init(hours: Int = 0, minutes: Int = 0, seconds: Int = 0, milliseconds: Int = 0) {
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
        self.milliseconds = milliseconds
    }

    /**
     * Constructor with a parameter for milliseconds. This constructor casts the milliseconds to an int and
     * calls ``init(millis:)``
     * @param millis the milliseconds to set the object with.
     */
    public convenience init(millis:Double) {
        self.init(millis: Int(millis));
    }

    /**
     * A constructor that sets the time by milliseconds. The milliseconds are converted to hours, minutes, seconds
     * and milliseconds. If the milliseconds are negative it will call ``setIsNegative(isNegative:)``.
     * @param millis the milliseconds to set.
     */
    public init(millis:Int) {
        var adjustedMillis = millis;
        if (adjustedMillis < 0) {
            self.isNegative = true;
            adjustedMillis = abs(adjustedMillis);
        }
        self.hours = adjustedMillis / Time.HOUR_MILLIS;
        adjustedMillis = adjustedMillis - self.hours * Time.HOUR_MILLIS;

        self.minutes = adjustedMillis / Time.MINUTE_MILLIS;
        adjustedMillis = adjustedMillis - self.minutes * Time.MINUTE_MILLIS;

        self.seconds = adjustedMillis / Time.SECOND_MILLIS;
        adjustedMillis = adjustedMillis - self.seconds * Time.SECOND_MILLIS;

        self.milliseconds = adjustedMillis;
    }

    /**
     * Does the time represent a negative time such as using this to subtract time from another Time.
     * @return if the time is negative.
     */
    public func getIsNegative() -> Bool {
        return self.isNegative;
    }

    /**
     * Set this to represent a negative time.
     * @param isNegative that the Time represents negative time
     */
    public func setIsNegative(isNegative:Bool) {
        self.isNegative = isNegative;
    }

    /**
     * @return Returns the hour.
     */
    public func getHours() -> Int {
        return self.hours;
    }

    /**
     * @param hours
     *            The hours to set.
     */
    public func setHours(hours:Int) {
        self.hours = hours;
    }

    /**
     * @return Returns the minutes.
     */
    public func getMinutes() -> Int {
        return self.minutes;
    }

    /**
     * @param minutes
     *            The minutes to set.
     */
    public func setMinutes(minutes:Int) {
        self.minutes = minutes;
    }

    /**
     * @return Returns the seconds.
     */
    public func getSeconds() -> Int {
        return self.seconds;
    }

    /**
     * @param seconds
     *            The seconds to set.
     */
    public func setSeconds(seconds:Int) {
        self.seconds = seconds;
    }

    /**
     * @return Returns the milliseconds.
     */
    public func getMilliseconds() -> Int {
        return self.milliseconds;
    }

    /**
     * @param milliseconds
     *            The milliseconds to set.
     */
    public func setMilliseconds(milliseconds:Int) {
        self.milliseconds = milliseconds;
    }

    /**
     * Returns the time in milliseconds by converting hours, minutes and seconds into milliseconds.
     * @return the time in milliseconds
     */
    public func getTime() -> Double {
        let hours = self.hours * Time.HOUR_MILLIS
        let minutes = self.minutes * Time.MINUTE_MILLIS
        let seconds = self.seconds * Time.SECOND_MILLIS
        return Double(hours + minutes + seconds + self.milliseconds);
    }

    /**
     * @see java.lang.Object#toString()
     */
//    public func toString() -> String {
//        return ZmanimFormatter(TimeZone.getTimeZone("UTC")).format(this);
//    }
}
