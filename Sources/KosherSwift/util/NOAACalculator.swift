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
public class NOAACalculator : AstronomicalCalculator {
    /**
     * The <a href="https://en.wikipedia.org/wiki/Julian_day">Julian day</a> of January 1, 2000, known as
     * <a href="https://en.wikipedia.org/wiki/Epoch_(astronomy)#J2000">J2000.0</a>.
     */
    private static let JULIAN_DAY_JAN_1_2000 = 2451545.0;

    /**
     * Julian days per century.
     */
    private static let JULIAN_DAYS_PER_CENTURY = 36525.0;
    
    /**
     * GeoLocation is only used to keep track of timezone
     */
    public static var geoLocation: GeoLocation = GeoLocation()
    
    /**
     * timezone will be system default
     */
    public override init() {
        NOAACalculator.geoLocation.setTimeZone(timeZone: TimeZone.current)
    }
    
    /**
     * GeoLocation is only used to keep track of timezone
     */
    public init(geoLocation: GeoLocation) {
        NOAACalculator.geoLocation = geoLocation
    }
    
    /**
     * An enum to indicate what type of solar event is being calculated.
     */
        enum SolarEvent {
            /**SUNRISE A solar event related to sunrise*/case SUNRISE
            /**SUNSET A solar event related to sunset*/case SUNSET
            // possibly add the following in the future, if added, an IllegalArgumentException should be thrown in getSunHourAngle
            // /**NOON A solar event related to noon*/NOON, /**MIDNIGHT A solar event related to midnight*/MIDNIGHT
        }

    /**
     * Returns the name of the algorithm.
     * @return the descriptive name of the algorithm.
     */
    public func getCalculatorName() -> String {
        return "US National Oceanic and Atmospheric Administration Algorithm"; // Implementation of the Jean Meeus algorithm
    }

    /**
     A method that calculates UTC sunrise as well as any time based on an angle above or below sunrise. This abstract method is implemented by the classes that extend this class.
     @param calendar Used to calculate day of year.
     @param geoLocation The location information used for astronomical calculating sun times.
     @param zenith the azimuth below the vertical zenith of 90 degrees. for sunrise typically the ``adjustZenith`` zenith used for the calculation uses geometric zenith of 90&deg; and ``adjustZenith`` adjusts this slightly to account for solar refraction and the sun's radius. Another example would be ``AstronomicalCalendar.getBeginNauticalTwilight()`` that passes ``AstronomicalCalendar.NAUTICAL_ZENITH`` to this method.
     @param adjustForElevation Should the time be adjusted for elevation
     @return The UTC time of sunrise in 24 hour format. 5:45:00 AM will return 5.75.0. If an error was encountered in
     the calculation (expected behavior for some locations such as near the poles, ``Double.nan`` will be returned.
     @see #getElevationAdjustment(double)
    */
    public override func getUTCSunrise(date: Date, geoLocation: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double {
        let elevation = adjustForElevation ? geoLocation.getElevation() : 0;
        let adjustedZenith = adjustZenith(zenith: zenith, elevation: elevation);
        var sunrise = NOAACalculator.getSunRiseSetUTC(julianDay: NOAACalculator.getJulianDay(date: date), latitude: geoLocation.getLatitude(), longitude: -geoLocation.getLongitude(), zenith: adjustedZenith, solarEvent: SolarEvent.SUNRISE);
        sunrise = sunrise / 60;

        // ensure that the time is >= 0 and < 24
        while (sunrise < 0.0) {
            sunrise += 24.0;
        }
        while (sunrise >= 24.0) {
            sunrise -= 24.0;
        }
        return sunrise;
    }

    /**
     * A method that calculates UTC sunset as well as any time based on an angle above or below sunset. This abstract
     * method is implemented by the classes that extend this class.
     *
     * @param calendar
     *            Used to calculate day of year.
     * @param geoLocation
     *            The location information used for astronomical calculating sun times.
     * @param zenith
     *            the azimuth below the vertical zenith of 90&deg;. For sunset typically the ``adjustZenith``
     *            zenith used for the calculation uses geometric zenith of 90&deg; and ``adjustZenith`` adjusts
     *            this slightly to account for solar refraction and the sun's radius. Another example would be
     *            ``AstronomicalCalendar.getEndNauticalTwilight()`` that passes
     *            ``AstronomicalCalendar.NAUTICAL_ZENITH`` to this method.
     * @param adjustForElevation
     *            Should the time be adjusted for elevation
     * @return The UTC time of sunset in 24 hour format. 5:45:00 AM will return 5.75.0. If an error was encountered in
     *         the calculation (expected behavior for some locations such as near the poles,
     *         ``Double.nan`` will be returned.
     * @see #getElevationAdjustment(double)
     */
    public override func getUTCSunset(date: Date, geoLocation: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double {
        let elevation = adjustForElevation ? geoLocation.getElevation() : 0;
        let adjustedZenith = adjustZenith(zenith: zenith, elevation: elevation);

        var sunset = NOAACalculator.getSunRiseSetUTC(julianDay: NOAACalculator.getJulianDay(date: date), latitude: geoLocation.getLatitude(), longitude: -geoLocation.getLongitude(),zenith: adjustedZenith, solarEvent: SolarEvent.SUNSET);
        sunset = sunset / 60;

        // ensure that the time is >= 0 and < 24
        while (sunset < 0.0) {
            sunset += 24.0;
        }
        while (sunset >= 24.0) {
            sunset -= 24.0;
        }
        return sunset;
    }

    /**
     * Return the <a href="https://en.wikipedia.org/wiki/Julian_day">Julian day</a> from a Swift Date
     *
     * @param date
     *            The Swift Date
     * @return the Julian day corresponding to the date Note: Number is returned for start of day. Fractional days
     *         should be added later.
     */
    private static func getJulianDay(date: Date) -> Double {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = geoLocation.getTimeZone()
        var year = calendar.component(.year, from: date)
        var month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        if (month <= 2) {
            year -= 1;
            month += 12;
        }
        let a = year / 100;
        let b = 2 - a + a / 4;
        let c = floor(365.25 * (Double(year) + 4716))
        let d = floor(30.6001 * Double(month + 1))
        let e = Double(day) + Double(b) - 1524.5
        return Double(c + d + e);
    }

    /**
     * Convert <a href="https://en.wikipedia.org/wiki/Julian_day">Julian day</a> to centuries since <a href=
     * "https://en.wikipedia.org/wiki/Epoch_(astronomy)#J2000">J2000.0</a>.
     *
     * @param julianDay
     *            the Julian Day to convert
     * @return the centuries since 2000 Julian corresponding to the Julian Day
     */
    private static func getJulianCenturiesFromJulianDay(julianDay: Double) -> Double {
        return (julianDay - JULIAN_DAY_JAN_1_2000) / JULIAN_DAYS_PER_CENTURY;
    }

    /**
     * Convert centuries since <a href="https://en.wikipedia.org/wiki/Epoch_(astronomy)#J2000">J2000.0</a> to
     * <a href="https://en.wikipedia.org/wiki/Julian_day">Julian day</a>.
     *
     * @param julianCenturies
     *            the number of Julian centuries since <a href=
     *            "https://en.wikipedia.org/wiki/Epoch_(astronomy)#J2000">J2000.0</a>.
     * @return the Julian Day corresponding to the Julian centuries passed in
     */
    private static func getJulianDayFromJulianCenturies(julianCenturies: Double) -> Double {
        return julianCenturies * JULIAN_DAYS_PER_CENTURY + JULIAN_DAY_JAN_1_2000;
    }

    /**
     * Returns the Geometric <a href="https://en.wikipedia.org/wiki/Mean_longitude">Mean Longitude</a> of the Sun.
     *
     * @param julianCenturies
     *            the number of Julian centuries since <a href=
     *            "https://en.wikipedia.org/wiki/Epoch_(astronomy)#J2000">J2000.0</a>.
     * @return the Geometric Mean Longitude of the Sun in degrees
     */
    private static func getSunGeometricMeanLongitude(julianCenturies: Double) -> Double {
        var longitude = 280.46646 + julianCenturies * (36000.76983 + 0.0003032 * julianCenturies);
        while (longitude > 360.0) {
            longitude -= 360.0;
        }
        while (longitude < 0.0) {
            longitude += 360.0;
        }

        return longitude; // in degrees
    }

    /**
     * Returns the Geometric <a href="https://en.wikipedia.org/wiki/Mean_anomaly">Mean Anomaly</a> of the Sun.
     *
     * @param julianCenturies
     *            the number of Julian centuries since <a href=
     *            "https://en.wikipedia.org/wiki/Epoch_(astronomy)#J2000">J2000.0</a>.
     * @return the Geometric Mean Anomaly of the Sun in degrees
     */
    private static func getSunGeometricMeanAnomaly(julianCenturies: Double) -> Double {
        return 357.52911 + julianCenturies * (35999.05029 - 0.0001537 * julianCenturies); // in degrees
    }

    /**
     * Return the <a href="https://en.wikipedia.org/wiki/Eccentricity_%28orbit%29">eccentricity of earth's orbit</a>.
     *
     * @param julianCenturies
     *            the number of Julian centuries since <a href=
     *            "https://en.wikipedia.org/wiki/Epoch_(astronomy)#J2000">J2000.0</a>.
     * @return the unitless eccentricity
     */
    private static func getEarthOrbitEccentricity(julianCenturies: Double) -> Double {
        return 0.016708634 - julianCenturies * (0.000042037 + 0.0000001267 * julianCenturies); // unitless
    }

    /**
     * Returns the <a href="https://en.wikipedia.org/wiki/Equation_of_the_center">equation of center</a> for the sun.
     *
     * @param julianCenturies
     *            the number of Julian centuries since <a href=
     *            "https://en.wikipedia.org/wiki/Epoch_(astronomy)#J2000">J2000.0</a>.
     * @return the equation of center for the sun in degrees
     */
    private static func getSunEquationOfCenter(julianCenturies: Double) -> Double {
        let m = getSunGeometricMeanAnomaly(julianCenturies: julianCenturies);

        let mrad = toRadians(degrees: m);
        let sinm = Double(sin(mrad));
        let sin2m = Double(sin(mrad + mrad));
        let sin3m = Double(sin(mrad + mrad + mrad));

        return sinm * (1.914602 - julianCenturies * (0.004817 + 0.000014 * julianCenturies)) + sin2m
                * (0.019993 - 0.000101 * julianCenturies) + sin3m * 0.000289;// in degrees
    }

    /**
     * Return the <a href="https://en.wikipedia.org/wiki/True_longitude">true longitude</a> of the sun.
     *
     * @param julianCenturies
     *            the number of Julian centuries since <a href=
     *            "https://en.wikipedia.org/wiki/Epoch_(astronomy)#J2000">J2000.0</a>.
     * @return the sun's true longitude in degrees
     */
    private static func getSunTrueLongitude(julianCenturies: Double) -> Double {
        let sunLongitude = getSunGeometricMeanLongitude(julianCenturies: julianCenturies);
        let center = getSunEquationOfCenter(julianCenturies: julianCenturies);

        return sunLongitude + center; // in degrees
    }

    // /**
    // * Returns the <a href="https://en.wikipedia.org/wiki/True_anomaly">true anamoly</a> of the sun.
    // *
    // * @param julianCenturies
    // * the number of Julian centuries since J2000.0
    // * @return the sun's true anamoly in degrees
    // */
    // private static double getSunTrueAnomaly(double julianCenturies) {
    // double meanAnomaly = getSunGeometricMeanAnomaly(julianCenturies);
    // double equationOfCenter = getSunEquationOfCenter(julianCenturies);
    //
    // return meanAnomaly + equationOfCenter; // in degrees
    // }

    /**
     * Return the <a href="https://en.wikipedia.org/wiki/Apparent_longitude">apparent longitude</a> of the sun.
     *
     * @param julianCenturies
     *            the number of Julian centuries since <a href=
     *            "https://en.wikipedia.org/wiki/Epoch_(astronomy)#J2000">J2000.0</a>.
     * @return sun's apparent longitude in degrees
     */
    private static func getSunApparentLongitude(julianCenturies: Double) -> Double {
        let sunTrueLongitude = getSunTrueLongitude(julianCenturies: julianCenturies);

        let omega = 125.04 - 1934.136 * julianCenturies;
        let lambda = sunTrueLongitude - 0.00569 - 0.00478 * sin(toRadians(degrees: omega));
        return lambda; // in degrees
    }

    /**
     * Returns the mean <a href="https://en.wikipedia.org/wiki/Axial_tilt">obliquity of the ecliptic</a> (Axial tilt).
     *
     * @param julianCenturies
     *            the number of Julian centuries since <a href=
     *            "https://en.wikipedia.org/wiki/Epoch_(astronomy)#J2000">J2000.0</a>.
     * @return the mean obliquity in degrees
     */
    private static func getMeanObliquityOfEcliptic(julianCenturies: Double) -> Double {
        let seconds = 21.448 - julianCenturies * (46.8150 + julianCenturies * (0.00059 - julianCenturies * (0.001813)));
        return 23.0 + (26.0 + (seconds / 60.0)) / 60.0; // in degrees
    }

    /**
     * Returns the corrected <a href="https://en.wikipedia.org/wiki/Axial_tilt">obliquity of the ecliptic</a> (Axial
     * tilt).
     *
     * @param julianCenturies
     *            the number of Julian centuries since <a href=
     *            "https://en.wikipedia.org/wiki/Epoch_(astronomy)#J2000">J2000.0</a>.
     * @return the corrected obliquity in degrees
     */
    private static func getObliquityCorrection(julianCenturies: Double) -> Double {
        let obliquityOfEcliptic = getMeanObliquityOfEcliptic(julianCenturies: julianCenturies);

        let omega = 125.04 - 1934.136 * julianCenturies;
        return obliquityOfEcliptic + 0.00256 * cos(toRadians(degrees: omega)); // in degrees
    }

    /**
     * Return the <a href="https://en.wikipedia.org/wiki/Declination">declination</a> of the sun.
     *
     * @param julianCenturies
     *            the number of Julian centuries since <a href=
     *            "https://en.wikipedia.org/wiki/Epoch_(astronomy)#J2000">J2000.0</a>.
     * @return
     *            the sun's declination in degrees
     */
    private static func getSunDeclination(julianCenturies:Double) -> Double {
        let obliquityCorrection = getObliquityCorrection(julianCenturies: julianCenturies);
        let lambda = getSunApparentLongitude(julianCenturies: julianCenturies);

        let sint = sin(toRadians(degrees: obliquityCorrection)) * sin(toRadians(degrees: lambda));
        let theta = toDegrees(radians: asin(sint));
        return theta; // in degrees
    }

    /**
     * Return the <a href="https://en.wikipedia.org/wiki/Equation_of_time">Equation of Time</a> - the difference between
     * true solar time and mean solar time
     *
     * @param julianCenturies
     *            the number of Julian centuries since <a href=
     *            "https://en.wikipedia.org/wiki/Epoch_(astronomy)#J2000">J2000.0</a>.
     * @return equation of time in minutes of time
     */
    private static func getEquationOfTime(julianCenturies: Double) -> Double {
        let epsilon = getObliquityCorrection(julianCenturies: julianCenturies);
        let geomMeanLongSun = getSunGeometricMeanLongitude(julianCenturies: julianCenturies);
        let eccentricityEarthOrbit = getEarthOrbitEccentricity(julianCenturies: julianCenturies);
        let geomMeanAnomalySun = getSunGeometricMeanAnomaly(julianCenturies: julianCenturies);

        var y = tan(toRadians(degrees: epsilon) / 2.0);
        y *= y;

        let sin2l0 = sin(2.0 * toRadians(degrees: geomMeanLongSun));
        let sinm = sin(toRadians(degrees: geomMeanAnomalySun));
        let cos2l0 = cos(2.0 * toRadians(degrees: geomMeanLongSun));
        let sin4l0 = sin(4.0 * toRadians(degrees: geomMeanLongSun));
        let sin2m = sin(2.0 * toRadians(degrees: geomMeanAnomalySun));

        let equationOfTime = y * sin2l0 - 2.0 * eccentricityEarthOrbit * sinm + 4.0 * eccentricityEarthOrbit * y
                * sinm * cos2l0 - 0.5 * y * y * sin4l0 - 1.25 * eccentricityEarthOrbit * eccentricityEarthOrbit * sin2m;
        return toDegrees(radians: equationOfTime) * 4.0; // in minutes of time
    }

    /**
     * Returns the <a href="https://en.wikipedia.org/wiki/Hour_angle">hour angle</a> of the sun in <a href=
     * "https://en.wikipedia.org/wiki/Radian">radians</a>at for the latitude.
     * @todo use - {@link #getSunHourAngleAtSunrise(double, double, double)} implementation to avoid duplication of code.
     *
     * @param lat
     *            the latitude of observer in degrees
     * @param solarDec
     *            the declination angle of sun in degrees
     * @param zenith
     *            the zenith
     * @param solarEvent
     *             If the hour angle is for sunrise or sunset
     * @return the hour angle of sunset in <a href="https://en.wikipedia.org/wiki/Radian">radians</a>
     */
    private static func getSunHourAngle(latitude: Double, solarDeclination: Double, zenith: Double, solarEvent: SolarEvent) -> Double {
        let latRad = toRadians(degrees: latitude);
        let sdRad = toRadians(degrees: solarDeclination);
        
        var hourAngle = (acos(cos(toRadians(degrees: zenith)) / (cos(latRad) * cos(sdRad)) - tan(latRad) * tan(sdRad)));
        if (solarEvent == SolarEvent.SUNSET) {
            hourAngle = -hourAngle;
        }
        return hourAngle;
    }

    /**
     * Return the <a href="https://en.wikipedia.org/wiki/Celestial_coordinate_system">Solar Elevation</a> for the
     * horizontal coordinate system at the given location at the given time. Can be negative if the sun is below the
     * horizon. Not corrected for altitude.
     *
     * @param date
     *            time of calculation
     * @param lat
     *            latitude of location for calculation
     * @param lon
     *            longitude of location for calculation
     * @return solar elevation in degrees - horizon is 0 degrees, civil twilight is -6 degrees
     */

    public static func getSolarElevation(date: Date, lat: Double, lon: Double) -> Double {
        let julianDay = getJulianDay(date: date);
        let julianCenturies = getJulianCenturiesFromJulianDay(julianDay: julianDay);

        let eot = getEquationOfTime(julianCenturies: julianCenturies);
        
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = geoLocation.getTimeZone()
        
        let hour = Double(cal.component(.hour, from: date)) + 12.0
        let minuteSeconds = Double(cal.component(.minute, from: date)) + eot + Double(cal.component(.second, from: date))

        var longitude =  hour + (minuteSeconds / 60.0) / 60.0;

        longitude = -(longitude * 360.0 / 24.0).truncatingRemainder(dividingBy: 360.0);
        let hourAngle_rad = toRadians(degrees: lon - longitude);
        let declination = getSunDeclination(julianCenturies: julianCenturies);
        let dec_rad = toRadians(degrees: declination);
        let lat_rad = toRadians(degrees: lat);
        return toDegrees(radians: asin((sin(lat_rad) * sin(dec_rad)) + (cos(lat_rad) * cos(dec_rad) * cos(hourAngle_rad))));

    }

    /**
     * Return the <a href="https://en.wikipedia.org/wiki/Celestial_coordinate_system">Solar Azimuth</a> for the
     * horizontal coordinate system at the given location at the given time. Not corrected for altitude. True south is 0
     * degrees.
     *
     * @param date
     *            time of calculation
     * @param lat
     *            latitude of location for calculation
     * @param lon
     *            longitude of location for calculation
     * @return the solar azimuth
     */

    public static func getSolarAzimuth(date: Date, lat: Double, lon: Double) -> Double {
        let julianDay = getJulianDay(date: date);
        let julianCenturies = getJulianCenturiesFromJulianDay(julianDay: julianDay);

        let eot = getEquationOfTime(julianCenturies: julianCenturies);
        
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = geoLocation.getTimeZone()
        
        let hour = Double(cal.component(.hour, from: date)) + 12.0
        let minuteSeconds = Double(cal.component(.minute, from: date)) + eot + Double(cal.component(.second, from: date))

        var longitude =  hour + (minuteSeconds / 60.0) / 60.0;

        longitude = -(longitude * 360.0 / 24.0).truncatingRemainder(dividingBy: 360.0);
        let hourAngle_rad = toRadians(degrees: lon - longitude);
        let declination = getSunDeclination(julianCenturies: julianCenturies);
        let dec_rad = toRadians(degrees: declination);
        let lat_rad = toRadians(degrees: lat);

        return toDegrees(radians: atan(sin(hourAngle_rad) / ((cos(hourAngle_rad) * sin(lat_rad)) - (tan(dec_rad) * cos(lat_rad)))))+180.0;

    }
    
    /**
     * Return the <a href="https://en.wikipedia.org/wiki/Universal_Coordinated_Time">Universal Coordinated Time</a> (UTC)
     * of <a href="https://en.wikipedia.org/wiki/Noon#Solar_noon">solar noon</a> for the given day at the given location
     * on earth. This implementation returns true solar noon as opposed to the time halfway between sunrise and sunset.
     * Other calculators may return a more simplified calculation of halfway between sunrise and sunset. See <a href=
     * "https://kosherjava.com/2020/07/02/definition-of-chatzos/">The Definition of <em>Chatzos</em></a> for details on
     * solar noon calculations.
     * @see com.kosherjava.zmanim.util.AstronomicalCalculator#getUTCNoon(Calendar, GeoLocation)
     * @see #getSolarNoonUTC(double, double)
     *
     * @param date
     *            The Date representing the date to calculate solar noon for
     * @param geoLocation
     *            The location information used for astronomical calculating sun times. This class uses only requires
     *            the longitude for calculating noon since it is the same time anywhere along the longitude line.
     * @return the time in minutes from zero UTC
     */
    public override func getUTCNoon(date: Date, geoLocation: GeoLocation) -> Double {
        let julianDay = NOAACalculator.getJulianDay(date: date);
        let julianCenturies = NOAACalculator.getJulianCenturiesFromJulianDay(julianDay: julianDay);
        
        var noon = NOAACalculator.getSolarNoonUTC(julianCenturies: julianCenturies, longitude: -geoLocation.getLongitude());
        noon = noon / 60;

        // ensure that the time is >= 0 and < 24
        while (noon < 0.0) {
            noon += 24.0;
        }
        while (noon >= 24.0) {
            noon -= 24.0;
        }
        return noon;
    }

    /**
     * Return the <a href="https://en.wikipedia.org/wiki/Universal_Coordinated_Time">Universal Coordinated Time</a> (UTC)
     * of <a href="http://en.wikipedia.org/wiki/Noon#Solar_noon">solar noon</a> for the given day at the given location
     * on earth.
     *
     * @param julianCenturies
     *            the number of Julian centuries since <a href=
     *            "https://en.wikipedia.org/wiki/Epoch_(astronomy)#J2000">J2000.0</a>.
     * @param longitude
     *            the longitude of observer in degrees
     *
     * @return the time in minutes from zero UTC
     *
     * @see com.kosherjava.zmanim.util.AstronomicalCalculator#getUTCNoon(Calendar, GeoLocation)
     * @see #getUTCNoon(Calendar, GeoLocation)
     */
    private static func getSolarNoonUTC(julianCenturies: Double, longitude: Double) -> Double {
        // Only 1 pass for approximate solar noon to calculate equation of time
        let tnoon = getJulianCenturiesFromJulianDay(julianDay: getJulianDayFromJulianCenturies(julianCenturies: julianCenturies) + longitude / 360.0);
        var eqTime = getEquationOfTime(julianCenturies: tnoon);
        let solNoonUTC = 720 + (longitude * 4) - eqTime; // min

        let newt = getJulianCenturiesFromJulianDay(julianDay: getJulianDayFromJulianCenturies(julianCenturies: julianCenturies) - 0.5
                + solNoonUTC / 1440.0);

        eqTime = getEquationOfTime(julianCenturies: newt);
        return 720 + (longitude * 4) - eqTime; // min
    }

    /**
     * Return the <a href="https://en.wikipedia.org/wiki/Universal_Coordinated_Time">Universal Coordinated Time</a> (UTC)
     * of sunrise or sunset for the given day at the given location on earth.
     *
     * @param julianDay
     *            the Julian day
     * @param latitude
     *            the latitude of observer in degrees
     * @param longitude
     *            longitude of observer in degrees
     * @param zenith
     *            zenith
     * @param solarEvent
     *             Is the calculation for sunrise or sunset
     * @return the time in minutes from zero Universal Coordinated Time (UTC)
     */
    private static func getSunRiseSetUTC(julianDay: Double, latitude: Double, longitude: Double, zenith: Double, solarEvent: SolarEvent) -> Double {
        let julianCenturies = getJulianCenturiesFromJulianDay(julianDay: julianDay);

        // Find the time of solar noon at the location, and use that declination.
        // This is better than start of the Julian day

        let noonmin = getSolarNoonUTC(julianCenturies: julianCenturies, longitude: longitude);
        let tnoon = getJulianCenturiesFromJulianDay(julianDay: julianDay + noonmin / 1440.0);

        // First calculates sunrise and approx length of day

        var eqTime = getEquationOfTime(julianCenturies: tnoon);
        var solarDec = getSunDeclination(julianCenturies: tnoon);
        var hourAngle = getSunHourAngle(latitude: latitude, solarDeclination: solarDec, zenith: zenith, solarEvent: solarEvent);

        var delta = longitude - toDegrees(radians: hourAngle);
        var timeDiff = 4 * delta;
        var timeUTC = 720 + timeDiff - eqTime;

        // Second pass includes fractional Julian Day in gamma calc

        let newt = getJulianCenturiesFromJulianDay(julianDay: getJulianDayFromJulianCenturies(julianCenturies: julianCenturies) + timeUTC
                / 1440.0);
        eqTime = getEquationOfTime(julianCenturies: newt);
        solarDec = getSunDeclination(julianCenturies: newt);
        hourAngle = getSunHourAngle(latitude: latitude, solarDeclination: solarDec, zenith: zenith, solarEvent: solarEvent);

        delta = longitude - toDegrees(radians: hourAngle);
        timeDiff = 4 * delta;
        timeUTC = 720 + timeDiff - eqTime; // in minutes
        return timeUTC;
    }
    
    public static func toRadians(degrees:Double) -> Double {
        return degrees * Double.pi / 180.0
    }
    
    public static func toDegrees(radians:Double) -> Double {
        return radians * 180.0 / Double.pi
    }
}
