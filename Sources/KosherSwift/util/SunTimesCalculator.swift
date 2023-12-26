//
//  SunTimesCalculator.swift
//  KosherSwift
//
//  Created by Elyahu Jacobi on 12/21/23.
//

import Foundation

/**
 * Implementation of sunrise and sunset methods to calculate astronomical times. This calculator uses the Java algorithm
 * written by <a href="htts://web.archive.org/web/20090531215353/http://www.kevinboone.com/suntimes.html">Kevin
 * Boone</a> that is based on the <a href = "https://aa.usno.navy.mil/">US Naval Observatory's</a><a
 * href="https://aa.usno.navy.mil/publications/asa">Astronomical Almanac</a> and used with his permission. Added to Kevin's
 * code is adjustment of the zenith to account for elevation. This algorithm returns the same time every year and does not
 * account for leap years. It is not as accurate as the Jean Meeus based {@link NOAACalculator} that is the default calculator
 * use by the KosherJava <em>zmanim</em> library.
 *
 * @author &copy; Eliyahu Hershfeld 2004 - 2023
 * @author &copy; Kevin Boone 2000
 */
public class SunTimesCalculator : AstronomicalCalculator {
    
    static var geoLocation: GeoLocation = GeoLocation()
    
    public override init() {
        SunTimesCalculator.geoLocation.setTimeZone(timeZone: TimeZone.current)
    }
    
    public init(geoLocation: GeoLocation) {
        SunTimesCalculator.geoLocation = geoLocation
    }

    /**
     * @see com.kosherjava.zmanim.util.AstronomicalCalculator#getCalculatorName()
     */
    public func getCalculatorName() -> String {
        return "US Naval Almanac Algorithm";
    }

    /**
     * @see com.kosherjava.zmanim.util.AstronomicalCalculator#getUTCSunrise(Calendar, GeoLocation, double, boolean)
     */
    public override func getUTCSunrise(date:Date, geoLocation:GeoLocation, zenith:Double, adjustForElevation:Bool) -> Double {
        var doubleTime = Double.nan;
        let elevation = adjustForElevation ? geoLocation.getElevation() : 0;
        let adjustedZenith = adjustZenith(zenith: zenith, elevation: elevation);
        doubleTime = SunTimesCalculator.getTimeUTC(date: date, geoLocation: geoLocation, zenith: adjustedZenith, isSunrise: true);
        return doubleTime;
    }

    /**
     * @see com.kosherjava.zmanim.util.AstronomicalCalculator#getUTCSunset(Calendar, GeoLocation, double, boolean)
     */
    public override func getUTCSunset(date:Date, geoLocation:GeoLocation, zenith:Double, adjustForElevation:Bool) -> Double {
        var doubleTime = Double.nan;
        let elevation = adjustForElevation ? geoLocation.getElevation() : 0;
        let adjustedZenith = adjustZenith(zenith: zenith, elevation: elevation);
        doubleTime = SunTimesCalculator.getTimeUTC(date: date, geoLocation: geoLocation, zenith: adjustedZenith, isSunrise: false);
        return doubleTime;
    }

    /**
     * The number of degrees of longitude that corresponds to one hour time difference.
     */
    private static let DEG_PER_HOUR = Double(360.0 / 24.0);

    /**
     * @param deg the degrees
     * @return sin of the angle in degrees
     */
    private static func sinDeg(deg:Double) -> Double {
        return sin(deg * 2.0 * Double.pi / 360.0);
    }

    /**
     * @param x angle
     * @return acos of the angle in degrees
     */
    private static func acosDeg(x:Double) -> Double {
        return acos(x) * 360.0 / (2 * Double.pi);
    }

    /**
     * @param x angle
     * @return asin of the angle in degrees
     */
    private static func asinDeg(x:Double) -> Double {
        return asin(x) * 360.0 / (2 * Double.pi);
    }

    /**
     * @param deg degrees
     * @return tan of the angle in degrees
     */
    private static func tanDeg(deg:Double) -> Double {
        return tan(deg * 2.0 * Double.pi / 360.0);
    }
    
    /**
     * Calculate cosine of the angle in degrees
     *
     * @param deg degrees
     * @return cosine of the angle in degrees
     */
    private static func cosDeg(deg:Double) -> Double {
        return cos(deg * 2.0 * Double.pi / 360.0);
    }

    /**
     * Get time difference between location's longitude and the Meridian, in hours.
     *
     * @param longitude the longitude
     * @return time difference between the location's longitude and the Meridian, in hours. West of Meridian has a negative time difference
     */
    private static func getHoursFromMeridian(longitude:Double) -> Double {
        return longitude / DEG_PER_HOUR;
    }
    
    /**
     * Calculate the approximate time of sunset or sunrise in days since midnight Jan 1st, assuming 6am and 6pm events. We
     * need this figure to derive the Sun's mean anomaly.
     *
     * @param dayOfYear the day of year
     * @param hoursFromMeridian hours from the meridian
     * @param isSunrise true for sunrise and false for sunset
     *
     * @return the approximate time of sunset or sunrise in days since midnight Jan 1st, assuming 6am and 6pm events. We
     * need this figure to derive the Sun's mean anomaly.
     */
    private static func getApproxTimeDays(dayOfYear:Int, hoursFromMeridian:Double, isSunrise:Bool) -> Double {
        if (isSunrise) {
            return Double(dayOfYear) + ((6.0 - hoursFromMeridian) / 24);
        } else { // sunset
            return Double(dayOfYear) + ((18.0 - hoursFromMeridian) / 24);
        }
    }
    
    /**
     * Calculate the Sun's mean anomaly in degrees, at sunrise or sunset, given the longitude in degrees
     *
     * @param dayOfYear the day of the year
     * @param longitude longitude
     * @param isSunrise true for sunrise and false for sunset
     * @return the Sun's mean anomaly in degrees
     */
    private static func getMeanAnomaly(dayOfYear:Int, longitude:Double, isSunrise:Bool) -> Double {
        return (0.9856 * getApproxTimeDays(dayOfYear: dayOfYear, hoursFromMeridian: getHoursFromMeridian(longitude: longitude), isSunrise: isSunrise)) - 3.289;
    }

    /**
     * @param sunMeanAnomaly the Sun's mean anomaly in degrees
     * @return the Sun's true longitude in degrees. The result is an angle &gt;= 0 and &lt;= 360.
     */
    private static func getSunTrueLongitude(sunMeanAnomaly:Double) -> Double {
        var l = sunMeanAnomaly + (1.916 * sinDeg(deg: sunMeanAnomaly)) + (0.020 * sinDeg(deg: 2 * sunMeanAnomaly)) + 282.634;

        // get longitude into 0-360 degree range
        if (l >= 360.0) {
            l = l - 360.0;
        }
        if (l < 0) {
            l = l + 360.0;
        }
        return l;
    }

    /**
     * Calculates the Sun's right ascension in hours.
     * @param sunTrueLongitude the Sun's true longitude in degrees &gt; 0 and &lt; 360.
     * @return the Sun's right ascension in hours in angles &gt; 0 and &lt; 360.
     */
    private static func getSunRightAscensionHours(sunTrueLongitude:Double) -> Double {
        let a = 0.91764 * tanDeg(deg: sunTrueLongitude);
        var ra = 360.0 / (2.0 * Double.pi) * atan(a);

        let lQuadrant = floor(sunTrueLongitude / 90.0) * 90.0;
        let raQuadrant = floor(ra / 90.0) * 90.0;
        ra = ra + (lQuadrant - raQuadrant);

        return ra / DEG_PER_HOUR; // convert to hours
    }

    /**
     * Calculate the cosine of the Sun's local hour angle
     *
     * @param sunTrueLongitude the sun's true longitude
     * @param latitude the latitude
     * @param zenith the zenith
     * @return the cosine of the Sun's local hour angle
     */
    private static func getCosLocalHourAngle(sunTrueLongitude:Double, latitude:Double, zenith:Double) -> Double {
        let sinDec = 0.39782 * sinDeg(deg: sunTrueLongitude);
        let cosDec = cosDeg(deg: asinDeg(x: sinDec));
        return (cosDeg(deg: zenith) - (sinDec * sinDeg(deg: latitude))) / (cosDec * cosDeg(deg: latitude));
    }
    
    /**
     * Calculate local mean time of rising or setting. By 'local' is meant the exact time at the location, assuming that
     * there were no time zone. That is, the time difference between the location and the Meridian depended entirely on
     * the longitude. We can't do anything with this time directly; we must convert it to UTC and then to a local time.
     *
     * @param localHour the local hour
     * @param sunRightAscensionHours the sun's right ascention in hours
     * @param approxTimeDays approximate time days
     *
     * @return the fractional number of hours since midnight as a double
     */
    private static func getLocalMeanTime(localHour:Double, sunRightAscensionHours:Double, approxTimeDays:Double) -> Double {
        return localHour + sunRightAscensionHours - (0.06571 * approxTimeDays) - 6.622;
    }

    /**
     * Get sunrise or sunset time in UTC, according to flag. This time is returned as
     * a double and is not adjusted for time-zone.
     *
     * @param calendar
     *            the Calendar object to extract the day of year for calculation
     * @param geoLocation
     *            the GeoLocation object that contains the latitude and longitude
     * @param zenith
     *            Sun's zenith, in degrees
     * @param isSunrise
     *            True for sunrise and false for sunset.
     * @return the time as a double. If an error was encountered in the calculation
     *         (expected behavior for some locations such as near the poles,
     *         {@link Double#NaN} will be returned.
     */
    private static func getTimeUTC(date:Date, geoLocation:GeoLocation, zenith:Double, isSunrise:Bool) -> Double {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = geoLocation.timeZone
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date)!
        let sunMeanAnomaly = getMeanAnomaly(dayOfYear: dayOfYear, longitude: geoLocation.getLongitude(), isSunrise: isSunrise);
        let sunTrueLong = getSunTrueLongitude(sunMeanAnomaly: sunMeanAnomaly);
        let sunRightAscensionHours = getSunRightAscensionHours(sunTrueLongitude: sunTrueLong);
        let cosLocalHourAngle = getCosLocalHourAngle(sunTrueLongitude: sunTrueLong, latitude: geoLocation.getLatitude(), zenith: zenith);

        var localHourAngle = Double(0);
        if (isSunrise) {
            localHourAngle = Double(360.0 - acosDeg(x: cosLocalHourAngle));
        } else { // sunset
            localHourAngle = Double(acosDeg(x: cosLocalHourAngle));
        }
        let localHour = Double(localHourAngle) / DEG_PER_HOUR;

        let localMeanTime = getLocalMeanTime(localHour: localHour, sunRightAscensionHours: sunRightAscensionHours, approxTimeDays: getApproxTimeDays(dayOfYear: dayOfYear, hoursFromMeridian: getHoursFromMeridian(longitude: geoLocation.getLongitude()), isSunrise: isSunrise));
        var pocessedTime = localMeanTime - getHoursFromMeridian(longitude: geoLocation.getLongitude());
        while (pocessedTime < 0.0) {
            pocessedTime += 24.0;
        }
        while (pocessedTime >= 24.0) {
            pocessedTime -= 24.0;
        }
        return pocessedTime;
    }
    
    /**
     * Return the <a href="https://en.wikipedia.org/wiki/Universal_Coordinated_Time">Universal Coordinated Time</a> (UTC)
     * of <a href="https://en.wikipedia.org/wiki/Noon#Solar_noon">solar noon</a> for the given day at the given location
     * on earth. This implementation returns solar noon as the time halfway between sunrise and sunset.
     * {@link NOAACalculator}, the default calculator, returns true solar noon. See <a href=
     * "https://kosherjava.com/2020/07/02/definition-of-chatzos/">The Definition of Chatzos</a> for details on solar
     * noon calculations.
     * @see com.kosherjava.zmanim.util.AstronomicalCalculator#getUTCNoon(Calendar, GeoLocation)
     * @see NOAACalculator
     *
     * @param calendar
     *            The Calendar representing the date to calculate solar noon for
     * @param geoLocation
     *            The location information used for astronomical calculating sun times.
     * @return the time in minutes from zero UTC. If an error was encountered in the calculation (expected behavior for
     *         some locations such as near the poles, {@link Double#NaN} will be returned.
     */
    public override func getUTCNoon(date:Date, geoLocation:GeoLocation) -> Double {
        let sunrise = getUTCSunrise(date: date, geoLocation: geoLocation, zenith: 90, adjustForElevation: false);
        let sunset = getUTCSunset(date: date, geoLocation: geoLocation, zenith: 90, adjustForElevation: false);
        var noon = sunrise + ((sunset - sunrise) / 2);
        if (noon < 0) {
            noon += 12;
        }
        if (noon < sunrise) {
            noon -= 12;
        }
        return noon;
    }
}
