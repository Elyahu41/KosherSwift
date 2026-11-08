//
//  NOAACalculator.swift
//  KosherSwift
//
//  Created by Elyahu Jacobi on 12/21/23.
//

import Foundation

/**
 * Implementation of sunrise and sunset methods to calculate astronomical times based on the <a
 * href="https://noaa.gov">NOAA</a> algorithm. This calculator uses the Java algorithm based on the implementation by <a
 * href="https://noaa.gov">NOAA - National Oceanic and Atmospheric Administration</a>'s <a href =
 * "https://www.srrb.noaa.gov/highlights/sunrise/sunrise.html">Surface Radiation Research Branch</a>. NOAA's <a
 * href="https://www.srrb.noaa.gov/highlights/sunrise/solareqns.PDF">implementation</a> is based on equations from <a
 * href="https://www.amazon.com/Astronomical-Table-Sun-Moon-Planets/dp/1942675038/">Astronomical Algorithms</a> by <a
 * href="https://en.wikipedia.org/wiki/Jean_Meeus">Jean Meeus</a>. Added to the algorithm is an adjustment of the zenith
 * to account for elevation. The algorithm can be found in the <a
 * href="https://en.wikipedia.org/wiki/Sunrise_equation">Wikipedia Sunrise Equation</a> article.
 *
 * @author &copy; Eliyahu Hershfeld 2011 - 2023
 */
public class NOAACalculator: AstronomicalCalculator {

    /** NOAA results are cached; see `AstronomicalCalculator.isResultCacheable()`. */
    public override func isResultCacheable() -> Bool {
        return true
    }

    /** The <a href="https://en.wikipedia.org/wiki/Julian_day">Julian day</a> of January 1, 2000, known as J2000.0. */
    private static let JULIAN_DAY_JAN_1_2000 = 2451545.0

    /** Julian days per century. */
    private static let JULIAN_DAYS_PER_CENTURY = 36525.0

    /** The kinds of solar events that NOAA calculates. */
    private enum SolarEvent {
        case sunrise, sunset, noon, midnight
    }

    /** Default constructor of the NOAACalculator. */
    public required init() {
        super.init()
    }

    /** @see AstronomicalCalculator.getCalculatorName() */
    public override func getCalculatorName() -> String {
        return "US National Oceanic and Atmospheric Administration Algorithm" // Implementation of the Jean Meeus algorithm
    }

    /** @see AstronomicalCalculator.getUTCSunrise(localDate:geoLocation:zenith:adjustForElevation:) */
    public override func getUTCSunrise(localDate: LocalDate, geoLocation: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double {
        return getUTCSunRiseSet(localDate, geoLocation, zenith, adjustForElevation, .sunrise)
    }

    /** @see AstronomicalCalculator.getUTCSunset(localDate:geoLocation:zenith:adjustForElevation:) */
    public override func getUTCSunset(localDate: LocalDate, geoLocation: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double {
        return getUTCSunRiseSet(localDate, geoLocation, zenith, adjustForElevation, .sunset)
    }

    /**
     * The UTC time of sunrise or sunset in hours, or NaN if the sun does not reach the zenith on that day.
     */
    private func getUTCSunRiseSet(_ localDate: LocalDate, _ geoLocation: GeoLocation, _ zenith: Double, _ adjustForElevation: Bool,
                                  _ solarEvent: SolarEvent) -> Double {
        var elevation = 0.0
        if adjustForElevation {
            elevation = solarEvent == .sunrise ? geoLocation.getSunriseElevation() : geoLocation.getSunsetElevation()
        }
        let adjustedZenith = adjustZenith(zenith: zenith, elevation: elevation, localDate: localDate)
        var riseSet = NOAACalculator.getSunRiseSetUTC(localDate, geoLocation.getLatitude(), -geoLocation.getLongitude(),
                                                      adjustedZenith, solarEvent)
        riseSet = riseSet / 60
        return JavaMath.rem(JavaMath.rem(riseSet, 24) + 24, 24) // ensure that the time is >= 0 and < 24
    }

    /**
     * Return the <a href="https://en.wikipedia.org/wiki/Julian_day">Julian day</a> from a LocalDate.
     */
    private static func getJulianDay(_ localDate: LocalDate) -> Double {
        var year = localDate.year
        var month = localDate.month
        let day = localDate.day
        if month <= 2 {
            year -= 1
            month += 12
        }
        // Java int division truncates toward zero, as Swift's does
        let a = year / 100
        let b = 2 - a + a / 4
        return (365.25 * Double(year + 4716)).rounded(.down) + (30.6001 * Double(month + 1)).rounded(.down) + Double(day) + Double(b) - 1524.5
    }

    /** Convert a Julian day to centuries since J2000.0. */
    private static func getJulianCenturiesFromJulianDay(_ julianDay: Double) -> Double {
        return (julianDay - JULIAN_DAY_JAN_1_2000) / JULIAN_DAYS_PER_CENTURY
    }

    /** Returns the Geometric <a href="https://en.wikipedia.org/wiki/Mean_longitude">Mean Longitude</a> of the Sun in degrees. */
    private static func getSunGeometricMeanLongitude(_ julianCenturies: Double) -> Double {
        let longitude = 280.46646 + julianCenturies * (36000.76983 + 0.0003032 * julianCenturies)
        return JavaMath.rem(JavaMath.rem(longitude, 360) + 360, 360) // return a longitude is in the range of 0 - 360
    }

    /** Returns the Geometric <a href="https://en.wikipedia.org/wiki/Mean_anomaly">Mean Anomaly</a> of the Sun in degrees. */
    private static func getSunGeometricMeanAnomaly(_ julianCenturies: Double) -> Double {
        return 357.52911 + julianCenturies * (35999.05029 - 0.0001537 * julianCenturies)
    }

    /** Return the unitless <a href="https://en.wikipedia.org/wiki/Eccentricity_%28orbit%29">eccentricity of earth's orbit</a>. */
    private static func getEarthOrbitEccentricity(_ julianCenturies: Double) -> Double {
        return 0.016708634 - julianCenturies * (0.000042037 + 0.0000001267 * julianCenturies)
    }

    /** Returns the <a href="https://en.wikipedia.org/wiki/Equation_of_the_center">equation of center</a> for the sun in degrees. */
    private static func getSunEquationOfCenter(_ julianCenturies: Double) -> Double {
        let m = getSunGeometricMeanAnomaly(julianCenturies)
        let sinm = sinDegrees(m)
        let sin2m = sinDegrees(m + m)
        let sin3m = sinDegrees(m + m + m)
        return sinm * (1.914602 - julianCenturies * (0.004817 + 0.000014 * julianCenturies)) + sin2m
            * (0.019993 - 0.000101 * julianCenturies) + sin3m * 0.000289
    }

    /** Return the <a href="https://en.wikipedia.org/wiki/True_longitude">true longitude</a> of the sun in degrees. */
    private static func getSunTrueLongitude(_ julianCenturies: Double) -> Double {
        let sunLongitude = getSunGeometricMeanLongitude(julianCenturies)
        let center = getSunEquationOfCenter(julianCenturies)
        return sunLongitude + center
    }

    /** Return the <a href="https://en.wikipedia.org/wiki/Apparent_longitude">apparent longitude</a> of the sun in degrees. */
    private static func getSunApparentLongitude(_ julianCenturies: Double) -> Double {
        let sunTrueLongitude = getSunTrueLongitude(julianCenturies)
        let omega = 125.04 - 1934.136 * julianCenturies
        return sunTrueLongitude - 0.00569 - 0.00478 * sinDegrees(omega)
    }

    /** Returns the mean <a href="https://en.wikipedia.org/wiki/Axial_tilt">obliquity of the ecliptic</a> in degrees. */
    private static func getMeanObliquityOfEcliptic(_ julianCenturies: Double) -> Double {
        let seconds = 21.448 - julianCenturies
            * (46.8150 + julianCenturies * (0.00059 - julianCenturies * (0.001813)))
        return 23.0 + (26.0 + (seconds / 60.0)) / 60.0
    }

    /** Returns the corrected <a href="https://en.wikipedia.org/wiki/Axial_tilt">obliquity of the ecliptic</a> in degrees. */
    private static func getObliquityCorrection(_ julianCenturies: Double) -> Double {
        let obliquityOfEcliptic = getMeanObliquityOfEcliptic(julianCenturies)
        let omega = 125.04 - 1934.136 * julianCenturies
        return obliquityOfEcliptic + 0.00256 * cosDegrees(omega)
    }

    /** Return the <a href="https://en.wikipedia.org/wiki/Declination">declination</a> of the sun in degrees. */
    private static func getSunDeclination(_ julianCenturies: Double) -> Double {
        let obliquityCorrection = getObliquityCorrection(julianCenturies)
        let lambda = getSunApparentLongitude(julianCenturies)
        let sint = sinDegrees(obliquityCorrection) * sinDegrees(lambda)
        return asinDegrees(sint)
    }

    /**
     * Return the <a href="https://en.wikipedia.org/wiki/Equation_of_time">Equation of Time</a> - the difference between
     * true solar time and mean solar time, in minutes.
     */
    private static func getEquationOfTime(_ julianCenturies: Double) -> Double {
        let epsilon = getObliquityCorrection(julianCenturies)
        let geomMeanLongSun = getSunGeometricMeanLongitude(julianCenturies)
        let eccentricityEarthOrbit = getEarthOrbitEccentricity(julianCenturies)
        let geomMeanAnomalySun = getSunGeometricMeanAnomaly(julianCenturies)
        var y = tanDegrees(epsilon / 2.0)
        y *= y
        let sin2l0 = sinDegrees(2.0 * geomMeanLongSun)
        let sinm = sinDegrees(geomMeanAnomalySun)
        let cos2l0 = cosDegrees(2.0 * geomMeanLongSun)
        let sin4l0 = sinDegrees(4.0 * geomMeanLongSun)
        let sin2m = sinDegrees(2.0 * geomMeanAnomalySun)
        let term1 = y * sin2l0 - 2.0 * eccentricityEarthOrbit * sinm
        let term2 = 4.0 * eccentricityEarthOrbit * y * sinm * cos2l0
        let term3 = 0.5 * y * y * sin4l0
        let term4 = 1.25 * eccentricityEarthOrbit * eccentricityEarthOrbit * sin2m
        let equationOfTime = term1 + term2 - term3 - term4
        return JavaMath.toDegrees(equationOfTime) * 4.0
    }

    /**
     * Return the <a href="https://en.wikipedia.org/wiki/Hour_angle">hour angle</a> of the sun in radians at sunrise or
     * sunset for the latitude; negative for sunset.
     */
    private static func getSunHourAngle(_ latitude: Double, _ solarDeclination: Double, _ zenith: Double, _ solarEvent: SolarEvent) -> Double {
        let ratio = cosDegrees(zenith) / (cosDegrees(latitude) * cosDegrees(solarDeclination)) - tanDegrees(latitude)
            * tanDegrees(solarDeclination)
        var hourAngle = acos(ratio)
        if solarEvent == .sunset {
            hourAngle = -hourAngle
        }
        return hourAngle
    }

    /**
     * Return the <a href="https://en.wikipedia.org/wiki/Celestial_coordinate_system">Solar Elevation</a> in degrees,
     * corrected for atmospheric refraction, for the horizontal coordinate system at the given location at the given time.
     */
    public override func getSolarElevation(date: Date, geoLocation: GeoLocation) -> Double {
        return getSolarElevationAzimuth(date, geoLocation, false)
    }

    /**
     * Return the <a href="https://en.wikipedia.org/wiki/Celestial_coordinate_system">Solar Azimuth</a> in degrees for the
     * horizontal coordinate system at the given location at the given time, measured clockwise from North (0°).
     */
    public override func getSolarAzimuth(date: Date, geoLocation: GeoLocation) -> Double {
        return getSolarElevationAzimuth(date, geoLocation, true)
    }

    /** The solar elevation (corrected for refraction) or azimuth in degrees at a given time. */
    private func getSolarElevationAzimuth(_ date: Date, _ geoLocation: GeoLocation, _ isAzimuth: Bool) -> Double {
        let lat = geoLocation.getLatitude()
        let lon = geoLocation.getLongitude()
        let utc = JavaTime.utcFields(date)
        let fractionalDay = (Double(utc.hour) + (Double(utc.minute)
            + (Double(utc.second) + utc.nano / 1_000_000_000.0) / 60.0) / 60.0) / 24.0
        let jd = NOAACalculator.getJulianDay(utc.localDate) + fractionalDay
        let jc = NOAACalculator.getJulianCenturiesFromJulianDay(jd)
        let decl = NOAACalculator.getSunDeclination(jc)
        let eot = NOAACalculator.getEquationOfTime(jc)
        let trueSolarTime = JavaMath.rem((fractionalDay + eot / 1440.0 + lon / 360.0) + 2, 1)
        let hourAngle = trueSolarTime * 2 * Double.pi - Double.pi
        let cosZenith = AstronomicalCalculator.sinDegrees(lat) * AstronomicalCalculator.sinDegrees(decl)
            + AstronomicalCalculator.cosDegrees(lat) * AstronomicalCalculator.cosDegrees(decl) * cos(hourAngle)
        let zenithDeg = AstronomicalCalculator.acosDegrees(max(-1, min(1, cosZenith)))
        let elevation = (90.0 - zenithDeg) + adjustElevationForRefraction(90.0 - zenithDeg)
        var azimuth: Double
        let azDenom = AstronomicalCalculator.cosDegrees(lat) * AstronomicalCalculator.sinDegrees(zenithDeg)
        if abs(azDenom) > 0.001 {
            let az = (AstronomicalCalculator.sinDegrees(lat) * AstronomicalCalculator.cosDegrees(zenithDeg)
                - AstronomicalCalculator.sinDegrees(decl)) / azDenom
            azimuth = 180 - AstronomicalCalculator.acosDegrees(max(-1, min(1, az))) * (hourAngle > 0 ? -1 : 1)
        } else {
            azimuth = lat > 0 ? 180 : 0
        }
        return isAzimuth ? JavaMath.rem(azimuth + 360, 360) : elevation
    }

    /** The atmospheric refraction correction in degrees for a geometric elevation, per NOAA's solar calculator. */
    private func adjustElevationForRefraction(_ elevation: Double) -> Double {
        if elevation > 85.0 {
            return 0.0
        }
        let te = AstronomicalCalculator.tanDegrees(elevation)
        var correction: Double
        if elevation > 5.0 {
            correction = 58.1 / te - 0.07 / pow(te, 3) + 0.000086 / pow(te, 5)
        } else if elevation > -0.575 {
            correction = 1735.0 + elevation * (-518.2 + elevation * (103.4 + elevation * (-12.79 + 0.711 * elevation)))
        } else {
            correction = -20.774 / te
        }
        return correction / 3600.0
    }

    /**
     * Return the <a href="https://en.wikipedia.org/wiki/Universal_Coordinated_Time">Universal Coordinated Time</a> (UTC)
     * of <a href="https://en.wikipedia.org/wiki/Noon#Solar_noon">solar noon</a> for the given day at the given location
     * on earth. This implementation returns true solar noon as opposed to the time halfway between sunrise and sunset.
     */
    public override func getUTCNoon(localDate: LocalDate, geoLocation: GeoLocation) -> Double {
        var noon = NOAACalculator.getSolarNoonMidnightUTC(NOAACalculator.getJulianDay(localDate), -geoLocation.getLongitude(), .noon)
        noon = noon / 60
        return JavaMath.rem(JavaMath.rem(noon, 24) + 24, 24) // ensure that the time is >= 0 and < 24
    }

    /**
     * Return the UTC of <a href="https://en.wikipedia.org/wiki/Midnight">solar midnight</a> (the time the sun is at its
     * lowest point) following the given day at the given location.
     */
    public override func getUTCMidnight(localDate: LocalDate, geoLocation: GeoLocation) -> Double {
        var midnight = NOAACalculator.getSolarNoonMidnightUTC(NOAACalculator.getJulianDay(localDate), -geoLocation.getLongitude(), .midnight)
        midnight = midnight / 60
        return JavaMath.rem(JavaMath.rem(midnight, 24) + 24, 24) // ensure that the time is >= 0 and < 24
    }

    /** The UTC of solar noon or solar midnight in minutes after the start of the Julian day. */
    private static func getSolarNoonMidnightUTC(_ julianDay: Double, _ longitude: Double, _ solarEvent: SolarEvent) -> Double {
        // no day-half shift: the loop epoch julianDay + solNoonUTC/1440 already lands on the event
        // First pass for approximate solar noon to calculate equation of time
        let tnoon = getJulianCenturiesFromJulianDay(julianDay + longitude / 360.0)
        var equationOfTime = getEquationOfTime(tnoon)
        var solNoonUTC = (longitude * 4) - equationOfTime // minutes

        // Refine the equation of time at the calculated transit time.
        for _ in 0..<2 {
            let newt = getJulianCenturiesFromJulianDay(julianDay + solNoonUTC / 1440.0)
            equationOfTime = getEquationOfTime(newt)
            solNoonUTC = (solarEvent == .noon ? 720 : 1440) + (longitude * 4) - equationOfTime
        }
        return solNoonUTC
    }

    /**
     * Return the UTC of sunrise or sunset in minutes for the given day at the given location, or NaN if the sun does not
     * reach the zenith.
     */
    private static func getSunRiseSetUTC(_ localDate: LocalDate, _ latitude: Double, _ longitude: Double, _ zenith: Double,
                                         _ solarEvent: SolarEvent) -> Double {
        let julianDay = getJulianDay(localDate)

        // Find the time of solar noon at the location, and use that declination.
        // This is better than start of the Julian day
        let noonmin = getSolarNoonMidnightUTC(julianDay, longitude, .noon)
        let tnoon = getJulianCenturiesFromJulianDay(julianDay + noonmin / 1440.0)

        // First calculates sunrise and approximate length of day
        var equationOfTime = getEquationOfTime(tnoon)
        var solarDeclination = getSunDeclination(tnoon)
        var hourAngle = getSunHourAngle(latitude, solarDeclination, zenith, solarEvent)
        if hourAngle.isNaN {
            // Using the Sun's declination at noon, the Sun never reaches this zenith today. But the declination changes
            // during the day (by up to about 0.2° in 12 hours), so the Sun may still just reach it around midnight, when it
            // is at its lowest. Before reporting that there is no event, try again with the declination and equation of time
            // at that solar midnight: the one before sunrise, or the one after sunset.
            let midnight = noonmin + (solarEvent == .sunrise ? -720 : 720)
            let tmidnight = getJulianCenturiesFromJulianDay(julianDay + midnight / 1440.0)
            equationOfTime = getEquationOfTime(tmidnight)
            solarDeclination = getSunDeclination(tmidnight)
            hourAngle = getSunHourAngle(latitude, solarDeclination, zenith, solarEvent)
        }
        var delta = longitude - JavaMath.toDegrees(hourAngle)
        var timeDiff = 4 * delta
        var timeUTC = 720 + timeDiff - equationOfTime

        // Second pass includes fractional Julian Day in gamma calc
        let newt = getJulianCenturiesFromJulianDay(julianDay + timeUTC / 1440.0)
        equationOfTime = getEquationOfTime(newt)
        solarDeclination = getSunDeclination(newt)
        hourAngle = getSunHourAngle(latitude, solarDeclination, zenith, solarEvent)
        delta = longitude - JavaMath.toDegrees(hourAngle)
        timeDiff = 4 * delta
        timeUTC = 720 + timeDiff - equationOfTime
        return timeUTC
    }

    /**
     * Returns the UTC time (in hours) on the given day when the sun is due east (an azimuth of 90°) or due west (270°),
     * or NaN where it never is (for example in the tropics part of the year, or at the poles).
     *
     * `azimuth` must be 90 or 270; other values return NaN and report a ``KosherSwiftWarnings`` warning (KosherJava throws an
     * IllegalArgumentException).
     */
    public override func getTimeAtAzimuth(localDate: LocalDate, geoLocation: GeoLocation, azimuth targetAzimuth: Double) -> Double {
        if targetAzimuth != 90.0 && targetAzimuth != 270.0 {
            KosherSwiftWarnings.report("The azimuth \(targetAzimuth) must be 90 or 270, the only azimuths supported; returning NaN")
            return Double.nan
        }
        let julianDay = NOAACalculator.getJulianDay(localDate)
        let solarNoonBase = 0.5 - (geoLocation.getLongitude() / 360.0)
        var dateTime = solarNoonBase + ((targetAzimuth == 90.0) ? 0.25 : 0.75)
        for _ in 0..<3 {
            let julianCenturies = NOAACalculator.getJulianCenturiesFromJulianDay(julianDay + dateTime)
            let ratio = AstronomicalCalculator.tanDegrees(NOAACalculator.getSunDeclination(julianCenturies))
                / AstronomicalCalculator.tanDegrees(geoLocation.getLatitude())
            if ratio.isNaN || ratio > 1.0 || ratio < -1.0 { // Handle Tropics, the Poles, and Equator line divisions
                return Double.nan
            }
            let offset = ((targetAzimuth == 90.0) ? -1.0 : 1.0) * (AstronomicalCalculator.acosDegrees(ratio) / 360.0)
            dateTime = solarNoonBase + offset - (NOAACalculator.getEquationOfTime(julianCenturies) / 1440.0)
        }
        return JavaMath.rem(JavaMath.rem(dateTime * 24, 24) + 24, 24)
    }
}
