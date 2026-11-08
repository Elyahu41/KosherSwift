//
//  SunTimesCalculator.swift
//  KosherSwift
//
//  Created by Elyahu Jacobi on 12/21/23.
//

import Foundation

/**
 * Implementation of sunrise and sunset methods to calculate astronomical times. This calculator uses the Java algorithm
 * written by <a href="https://web.archive.org/web/20090531215353/http://www.kevinboone.com/suntimes.html">Kevin
 * Boone</a> that is based on the <a href = "https://aa.usno.navy.mil/">US Naval Observatory's</a> <a href="https://aa.usno.navy.mil/publications/asa">Astronomical Almanac</a> and used with his permission. Added to Kevin's
 * code is adjustment of the zenith to account for elevation. This algorithm returns the same time every year and does not
 * account for leap years. It is not as accurate as the Jean Meeus based ``NOAACalculator`` that is the default calculator
 * use by the KosherJava/KosherSwift <em>zmanim</em> libraries.
 *
 * @author &copy; Eliyahu Hershfeld 2004 - 2023
 * @author &copy; Kevin Boone 2000
 */
@available(*, deprecated, message: "This calculator implements the legacy Almanac for Computers procedure of the US Naval Observatory, a deliberately simplified solar model (a single-term equation of center, fixed mean obliquity, and no nutation or aberration) that was designed for roughly one-minute accuracy on early calculators and personal computers. Use the NOAACalculator or SPACalculator instead.")
public class SunTimesCalculator: AstronomicalCalculator {

    /** Results are cached; see `AstronomicalCalculator.isResultCacheable()`. */
    override func isResultCacheable() -> Bool {
        return true
    }

    /** Default constructor of the SunTimesCalculator. */
    public required init() {
        super.init()
    }

    /** @see AstronomicalCalculator.getCalculatorName() */
    public override func getCalculatorName() -> String {
        return "US Naval Almanac Algorithm"
    }

    /** @see AstronomicalCalculator.getUTCSunrise(localDate:geoLocation:zenith:adjustForElevation:) */
    public override func getUTCSunrise(localDate: LocalDate, geoLocation: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double {
        let elevation = adjustForElevation ? geoLocation.getSunriseElevation() : 0
        let adjustedZenith = adjustZenith(zenith: zenith, elevation: elevation, localDate: localDate)
        return SunTimesCalculator.getTimeUTC(localDate, geoLocation, adjustedZenith, true)
    }

    /** @see AstronomicalCalculator.getUTCSunset(localDate:geoLocation:zenith:adjustForElevation:) */
    public override func getUTCSunset(localDate: LocalDate, geoLocation: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double {
        let elevation = adjustForElevation ? geoLocation.getSunsetElevation() : 0
        let adjustedZenith = adjustZenith(zenith: zenith, elevation: elevation, localDate: localDate)
        return SunTimesCalculator.getTimeUTC(localDate, geoLocation, adjustedZenith, false)
    }

    /** The number of degrees of longitude that corresponds to one hour of time difference. */
    private static let DEG_PER_HOUR = 360.0 / 24.0

    /** The offset from the meridian in hours. */
    private static func getHoursFromMeridian(_ longitude: Double) -> Double {
        return longitude / DEG_PER_HOUR
    }

    /** The approximate time of sunrise or sunset in days since midnight Jan 1st, assuming 6am and 6pm events. */
    private static func getApproxTimeDays(_ dayOfYear: Int, _ hoursFromMeridian: Double, _ isSunrise: Bool) -> Double {
        if isSunrise {
            return Double(dayOfYear) + ((6.0 - hoursFromMeridian) / 24)
        } else { // sunset
            return Double(dayOfYear) + ((18.0 - hoursFromMeridian) / 24)
        }
    }

    /** The Sun's mean anomaly in degrees at sunrise or sunset. */
    private static func getMeanAnomaly(_ dayOfYear: Int, _ longitude: Double, _ isSunrise: Bool) -> Double {
        return (0.9856 * getApproxTimeDays(dayOfYear, getHoursFromMeridian(longitude), isSunrise)) - 3.289
    }

    /** The Sun's true longitude in degrees, from 0 to 360. */
    private static func getSunTrueLongitude(_ sunMeanAnomaly: Double) -> Double {
        let l = sunMeanAnomaly + (1.916 * sinDegrees(sunMeanAnomaly)) + (0.020 * sinDegrees(2 * sunMeanAnomaly)) + 282.634
        return JavaMath.rem(JavaMath.rem(l, 360) + 360, 360) // return longitude as a 0-360 degree range
    }

    /** The Sun's right ascension in hours, in the same quadrant as its true longitude. */
    private static func getSunRightAscensionHours(_ sunTrueLongitude: Double) -> Double {
        let a = 0.91764 * tanDegrees(sunTrueLongitude)
        var ra = 360.0 / (2.0 * Double.pi) * atan(a)

        let lQuadrant = (sunTrueLongitude / 90.0).rounded(.down) * 90.0
        let raQuadrant = (ra / 90.0).rounded(.down) * 90.0
        ra = ra + (lQuadrant - raQuadrant)

        return ra / DEG_PER_HOUR // convert to hours
    }

    /** The cosine of the Sun's local hour angle. */
    private static func getCosLocalHourAngle(_ sunTrueLongitude: Double, _ latitude: Double, _ zenith: Double) -> Double {
        let sinDec = 0.39782 * sinDegrees(sunTrueLongitude)
        let cosDec = cosDegrees(asinDegrees(sinDec))
        return (cosDegrees(zenith) - (sinDec * sinDegrees(latitude))) / (cosDec * cosDegrees(latitude))
    }

    /** The local mean time of the event. */
    private static func getLocalMeanTime(_ localHour: Double, _ sunRightAscensionHours: Double, _ approxTimeDays: Double) -> Double {
        return localHour + sunRightAscensionHours - (0.06571 * approxTimeDays) - 6.622
    }

    /** The UTC time of sunrise or sunset in hours, or NaN if the sun does not reach the zenith. */
    private static func getTimeUTC(_ localDate: LocalDate, _ geoLocation: GeoLocation, _ zenith: Double, _ isSunrise: Bool) -> Double {
        let dayOfYear = localDate.dayOfYear
        let sunMeanAnomaly = getMeanAnomaly(dayOfYear, geoLocation.getLongitude(), isSunrise)
        let sunTrueLong = getSunTrueLongitude(sunMeanAnomaly)
        let sunRightAscensionHours = getSunRightAscensionHours(sunTrueLong)
        let cosLocalHourAngle = getCosLocalHourAngle(sunTrueLong, geoLocation.getLatitude(), zenith)

        var localHourAngle: Double
        if isSunrise {
            localHourAngle = 360.0 - acosDegrees(cosLocalHourAngle)
        } else { // sunset
            localHourAngle = acosDegrees(cosLocalHourAngle)
        }
        let localHour = localHourAngle / DEG_PER_HOUR

        let localMeanTime = getLocalMeanTime(localHour, sunRightAscensionHours,
                                             getApproxTimeDays(dayOfYear, getHoursFromMeridian(geoLocation.getLongitude()), isSunrise))
        let pocessedTime = localMeanTime - getHoursFromMeridian(geoLocation.getLongitude())
        return JavaMath.rem(JavaMath.rem(pocessedTime, 24) + 24, 24) // ensure that the time is >= 0 and < 24
    }

    /**
     * Return the UTC of solar noon for the given day at the given location: halfway between sunrise and sunset, which
     * differs slightly from true solar noon (see the NOAACalculator).
     */
    public override func getUTCNoon(localDate: LocalDate, geoLocation: GeoLocation) -> Double {
        let sunrise = getUTCSunrise(localDate: localDate, geoLocation: geoLocation, zenith: 90, adjustForElevation: false)
        let sunset = getUTCSunset(localDate: localDate, geoLocation: geoLocation, zenith: 90, adjustForElevation: false)
        var noon = sunrise + ((sunset - sunrise) / 2)
        if noon < sunrise {
            noon -= 12
        }
        return JavaMath.rem(JavaMath.rem(noon, 24) + 24, 24) // ensure that the time is >= 0 and < 24
    }

    /** Return the UTC of solar midnight: 12 hours after `getUTCNoon(localDate:geoLocation:)`. */
    public override func getUTCMidnight(localDate: LocalDate, geoLocation: GeoLocation) -> Double {
        return JavaMath.rem(getUTCNoon(localDate: localDate, geoLocation: geoLocation) + 12, 24)
    }

    /**
     * Not supported by this calculator; returns NaN and reports a ``KosherSwiftWarnings`` warning (KosherJava throws an UnsupportedOperationException). Use the
     * NOAACalculator instead.
     */
    public override func getSolarAzimuth(date: Date, geoLocation: GeoLocation) -> Double {
        KosherSwiftWarnings.report("The SunTimesCalculator can't calculate the solar azimuth; returning NaN. Use the NOAACalculator or SPACalculator instead")
        return Double.nan
    }

    /**
     * Not supported by this calculator; returns NaN and reports a ``KosherSwiftWarnings`` warning (KosherJava throws an UnsupportedOperationException). Use the
     * NOAACalculator instead.
     */
    public override func getSolarElevation(date: Date, geoLocation: GeoLocation) -> Double {
        KosherSwiftWarnings.report("The SunTimesCalculator can't calculate the solar elevation; returning NaN. Use the NOAACalculator or SPACalculator instead")
        return Double.nan
    }

    /**
     * Not supported by this calculator; returns NaN and reports a ``KosherSwiftWarnings`` warning (KosherJava throws an UnsupportedOperationException). Use the
     * NOAACalculator instead.
     */
    public override func getTimeAtAzimuth(localDate: LocalDate, geoLocation: GeoLocation, azimuth: Double) -> Double {
        KosherSwiftWarnings.report("The SunTimesCalculator can't calculate the time at an azimuth; returning NaN. Use the NOAACalculator or SPACalculator instead")
        return Double.nan
    }
}
