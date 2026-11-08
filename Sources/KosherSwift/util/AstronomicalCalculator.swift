//
//  AstronomicalCalculator.swift
//  KosherSwift
//
//  Created by Elyahu Jacobi on 12/21/23.
//

import Foundation

/**
 * An abstract class that all sun time calculating classes extend. This allows the algorithm used to be changed at
 * runtime, easily allowing comparison the results of using different algorithms.
 *
 * The calculators cache the sunrise, sunset, noon and midnight results of the dates they were last asked about (see
 * ``setUseResultCache(useResultCache:)``), since a day's zmanim need sunrise and sunset many times. Cached results are
 * only reused for identical inputs, so results are exactly the same as without caching.
 *
 * @author &copy; Eliyahu Hershfeld 2004 - 2026
 */
public class AstronomicalCalculator {
    /**
     * The commonly used average solar refraction. <a href="https://www.cs.tau.ac.il//~nachum/calendar-book/index.shtml">Calendrical
     * Calculations</a> lists a more accurate global average of 34.478885263888294
     *
     * @see #getRefraction()
     */
    public var refraction = 34.0 / 60.0

    /**
     * The commonly used average solar radius in minutes of a degree. It is only used if ``isUseApparentSolarRadius()``
     * is false.
     *
     * @see #getSolarRadius()
     */
    public var solarRadius = 16.0 / 60.0

    /** If true (the default), the sun's apparent radius for the date is used instead of ``getSolarRadius()``. */
    public var useApparentSolarRadius = true

    /**
     * The commonly used average earth radius in KM. At this time, this only affects elevation adjustment and not the
     * sunrise and sunset calculations. The value currently defaults to the IUGG mean radius R1 = (2a + b) / 3 of WGS-84.
     *
     * @see #getEarthRadius()
     */
    public var earthRadius = 6371.0088 // in KM

    /** If the results of the calculations are cached. */
    public var useResultCache = true

    /** The most recently used dates' caches (most recent first). */
    private var resultCaches: [(date: LocalDate, values: [ResultKey: Double])] = []
    private let resultCacheLock = NSLock()
    private static let resultCacheDates = 3

    private enum ResultEvent: Hashable {
        case sunrise, sunset, noon, midnight
    }

    private struct ResultKey: Hashable {
        let latitude: Double
        let longitude: Double
        let elevation: Double
        let horizonElevationAtSunrise: Double
        let horizonElevationAtSunset: Double
        let zenith: Double
        let adjustForElevation: Bool
        let event: ResultEvent

        init(_ geoLocation: GeoLocation, _ zenith: Double, _ adjustForElevation: Bool, _ event: ResultEvent) {
            latitude = geoLocation.getLatitude()
            longitude = geoLocation.getLongitude()
            elevation = geoLocation.getElevation()
            horizonElevationAtSunrise = geoLocation.getHorizonElevationAtSunrise()
            horizonElevationAtSunset = geoLocation.getHorizonElevationAtSunset()
            self.zenith = zenith
            self.adjustForElevation = adjustForElevation
            self.event = event
        }
    }

    /** Default constructor. */
    public required init() {
    }

    /**
     * If this calculator can cache its results. Calculators whose results only depend on the date, the location and the
     * zenith return true.
     */
    public func isResultCacheable() -> Bool {
        return false
    }

    /** Clears the cached results, for example after a setting that affects them changes. */
    public func clearResultCache() {
        resultCacheLock.lock()
        resultCaches = []
        resultCacheLock.unlock()
    }

    /**
     * Returns if the results of the calculations are cached (true by default).
     * @return if the results are cached
     */
    public func isUseResultCache() -> Bool {
        return useResultCache
    }

    /**
     * Sets if the results of the calculations are cached. Results are exactly the same either way; caching just avoids
     * calculating the same sunrise or sunset again.
     * @param useResultCache if the results should be cached
     */
    public func setUseResultCache(useResultCache: Bool) {
        self.useResultCache = useResultCache
        clearResultCache()
    }

    private func cached(_ localDate: LocalDate, _ key: ResultKey, _ calculate: () -> Double) -> Double {
        if !useResultCache || !isResultCacheable() {
            return calculate()
        }
        resultCacheLock.lock()
        if let index = resultCaches.firstIndex(where: { $0.date == localDate }), let value = resultCaches[index].values[key] {
            resultCacheLock.unlock()
            return value
        }
        resultCacheLock.unlock()
        let value = calculate()
        resultCacheLock.lock()
        if let index = resultCaches.firstIndex(where: { $0.date == localDate }) {
            resultCaches[index].values[key] = value
        } else {
            resultCaches.insert((date: localDate, values: [key: value]), at: 0)
            if resultCaches.count > AstronomicalCalculator.resultCacheDates {
                resultCaches.removeLast()
            }
        }
        resultCacheLock.unlock()
        return value
    }

    /** ``getUTCSunrise(localDate:geoLocation:zenith:adjustForElevation:)``, cached. */
    public func getCachedUTCSunrise(localDate: LocalDate, geoLocation: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double {
        return cached(localDate, ResultKey(geoLocation, zenith, adjustForElevation, .sunrise)) {
            getUTCSunrise(localDate: localDate, geoLocation: geoLocation, zenith: zenith, adjustForElevation: adjustForElevation)
        }
    }

    /** ``getUTCSunset(localDate:geoLocation:zenith:adjustForElevation:)``, cached. */
    public func getCachedUTCSunset(localDate: LocalDate, geoLocation: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double {
        return cached(localDate, ResultKey(geoLocation, zenith, adjustForElevation, .sunset)) {
            getUTCSunset(localDate: localDate, geoLocation: geoLocation, zenith: zenith, adjustForElevation: adjustForElevation)
        }
    }

    /** ``getUTCNoon(localDate:geoLocation:)``, cached. */
    public func getCachedUTCNoon(localDate: LocalDate, geoLocation: GeoLocation) -> Double {
        return cached(localDate, ResultKey(geoLocation, 0, false, .noon)) {
            getUTCNoon(localDate: localDate, geoLocation: geoLocation)
        }
    }

    /** ``getUTCMidnight(localDate:geoLocation:)``, cached. */
    public func getCachedUTCMidnight(localDate: LocalDate, geoLocation: GeoLocation) -> Double {
        return cached(localDate, ResultKey(geoLocation, 0, false, .midnight)) {
            getUTCMidnight(localDate: localDate, geoLocation: geoLocation)
        }
    }

    /**
     * A method that returns the earth radius in KM. The value currently defaults to 6371.0088 KM.
     * @return the earthRadius the earth radius in KM.
     */
    public func getEarthRadius() -> Double {
        return earthRadius
    }

    /**
     * A method that allows setting the earth's radius.
     * @param earthRadius the earthRadius to set in KM
     */
    public func setEarthRadius(earthRadius: Double) {
        self.earthRadius = earthRadius
        clearResultCache()
    }

    /** The zenith of astronomical sunrise and sunset. The sun is 90° from the vertical 0° */
    public static let GEOMETRIC_ZENITH = 90.0

    /**
     * Returns the default class for calculating sunrise and sunset. This is currently the more accurate
     * ``NOAACalculator``, but this may change in the future.
     * @return AstronomicalCalculator the default class for calculating sunrise and sunset.
     */
    public static func getDefault() -> AstronomicalCalculator {
        return NOAACalculator()
    }

    /**
     * Returns the name of the algorithm.
     * @return the descriptive name of the algorithm.
     */
    public func getCalculatorName() -> String {
        fatalError("getCalculatorName() must be overridden")
    }

    /**
     * A method that calculates UTC sunrise as well as any time based on an angle above or below sunrise.
     *
     * - Parameters:
     *   - localDate: The date to calculate for.
     *   - geoLocation: The location information used for astronomical calculating sun times.
     *   - zenith: the azimuth below the vertical zenith of 90 degrees. for sunrise typically the ``adjustZenith(zenith:elevation:localDate:)``
     *     zenith used for the calculation uses geometric zenith of 90° and adjusts this slightly to account for solar
     *     refraction and the sun's radius. Another example would be ``AstronomicalCalendar/getBeginNauticalTwilight()``
     *     that passes ``AstronomicalCalendar/NAUTICAL_ZENITH`` to this method.
     *   - adjustForElevation: Should the time be adjusted for elevation
     * - Returns: The UTC time of sunrise in 24-hour format. 5:45:00 AM will return 5.75.0. If an error was encountered in
     *   the calculation (expected behavior for some locations such as near the poles, ``Double/nan`` will be returned.
     */
    public func getUTCSunrise(localDate: LocalDate, geoLocation: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double {
        fatalError("getUTCSunrise must be overridden")
    }

    /**
     * A method that calculates UTC sunset as well as any time based on an angle above or below sunset.
     *
     * - Parameters:
     *   - localDate: The date to calculate for.
     *   - geoLocation: The location information used for astronomical calculating sun times.
     *   - zenith: the azimuth below the vertical zenith of 90°. For sunset typically the zenith used for the calculation
     *     uses geometric zenith of 90° and ``adjustZenith(zenith:elevation:localDate:)`` adjusts this slightly to account
     *     for solar refraction and the sun's radius.
     *   - adjustForElevation: Should the time be adjusted for elevation
     * - Returns: The UTC time of sunset in 24-hour format. 5:45:00 AM will return 5.75.0. If an error was encountered in
     *   the calculation (expected behavior for some locations such as near the poles, ``Double/nan`` will be returned.
     */
    public func getUTCSunset(localDate: LocalDate, geoLocation: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double {
        fatalError("getUTCSunset must be overridden")
    }

    /**
     * Return <a href="https://en.wikipedia.org/wiki/Noon#Solar_noon">solar noon</a> (UTC) for the given day at the given
     * location on earth. The ``NOAACalculator`` implementation calculates true solar noon, while the
     * ``SunTimesCalculator`` approximates it, calculating the time as halfway between sunrise and sunset.
     *
     * - Parameters:
     *   - localDate: The date to calculate for.
     *   - geoLocation: The location information used for astronomical calculating sun times.
     * - Returns: the time in minutes from zero UTC
     */
    public func getUTCNoon(localDate: LocalDate, geoLocation: GeoLocation) -> Double {
        fatalError("getUTCNoon must be overridden")
    }

    /**
     * Return <a href="https://en.wikipedia.org/wiki/Midnight">solar midnight</a> (UTC) for the given day at the given
     * location on earth. The ``NOAACalculator`` implementation calculates true solar midnight, while the
     * ``SunTimesCalculator`` approximates it, calculating the time as 12 hours after halfway between sunrise and sunset.
     *
     * - Parameters:
     *   - localDate: The date to calculate for.
     *   - geoLocation: The location information used for astronomical calculating sun times.
     * - Returns: the time in minutes from zero UTC
     */
    public func getUTCMidnight(localDate: LocalDate, geoLocation: GeoLocation) -> Double {
        fatalError("getUTCMidnight must be overridden")
    }

    /**
     * Returns the time (in UTC hours) that the sun is at the given azimuth.
     *
     * - Parameters:
     *   - localDate: The date to calculate for.
     *   - geoLocation: The location information.
     *   - azimuth: the azimuth to find; currently only 90° (east) and 270° (west) are supported.
     * - Returns: the time in UTC hours, or ``Double/nan`` if the sun doesn't reach that azimuth (for example in the tropics
     *   where it may stay north or south of the east-west line).
     */
    public func getTimeAtAzimuth(localDate: LocalDate, geoLocation: GeoLocation, azimuth: Double) -> Double {
        fatalError("getTimeAtAzimuth must be overridden")
    }

    /**
     * Return the <a href="https://en.wikipedia.org/wiki/Celestial_coordinate_system">Solar Elevation</a> for the
     * horizontal coordinate system at the given location at the given time. Can be negative if the sun is below the
     * horizon. Not corrected for altitude.
     *
     * - Parameters:
     *   - date: the instant
     *   - geoLocation: The location information
     * - Returns: solar elevation in degrees. The horizon (calculated in a vacuum using the solar radius as the point) is
     *   0°, and the zenith is 90°. Refraction is added for the NOAA and Meeus calculators.
     */
    public func getSolarElevation(date: Date, geoLocation: GeoLocation) -> Double {
        fatalError("getSolarElevation must be overridden")
    }

    /**
     * Return the <a href="https://en.wikipedia.org/wiki/Celestial_coordinate_system">Solar Azimuth</a> for the
     * horizontal coordinate system at the given location at the given time. Not corrected for altitude. True south is 180°.
     *
     * - Parameters:
     *   - date: the instant
     *   - geoLocation: The location information
     * - Returns: the solar azimuth in degrees
     */
    public func getSolarAzimuth(date: Date, geoLocation: GeoLocation) -> Double {
        fatalError("getSolarAzimuth must be overridden")
    }

    // MARK: - Date based convenience versions

    /** ``getUTCSunrise(localDate:geoLocation:zenith:adjustForElevation:)`` for the date of `date` in the location's time zone. */
    public func getUTCSunrise(date: Date, geoLocation: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double {
        return getUTCSunrise(localDate: LocalDate(date: date, timeZone: geoLocation.getTimeZone()), geoLocation: geoLocation,
                             zenith: zenith, adjustForElevation: adjustForElevation)
    }

    /** ``getUTCSunset(localDate:geoLocation:zenith:adjustForElevation:)`` for the date of `date` in the location's time zone. */
    public func getUTCSunset(date: Date, geoLocation: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double {
        return getUTCSunset(localDate: LocalDate(date: date, timeZone: geoLocation.getTimeZone()), geoLocation: geoLocation,
                            zenith: zenith, adjustForElevation: adjustForElevation)
    }

    /** ``getUTCNoon(localDate:geoLocation:)`` for the date of `date` in the location's time zone. */
    public func getUTCNoon(date: Date, geoLocation: GeoLocation) -> Double {
        return getUTCNoon(localDate: LocalDate(date: date, timeZone: geoLocation.getTimeZone()), geoLocation: geoLocation)
    }

    /** ``getUTCMidnight(localDate:geoLocation:)`` for the date of `date` in the location's time zone. */
    public func getUTCMidnight(date: Date, geoLocation: GeoLocation) -> Double {
        return getUTCMidnight(localDate: LocalDate(date: date, timeZone: geoLocation.getTimeZone()), geoLocation: geoLocation)
    }

    /**
     * Method to return the adjustment to the zenith required to account for the elevation. Since a person at a higher
     * elevation can see farther below the horizon, the calculation for sunrise / sunset is calculated below the horizon
     * used at sea level. This is only used for sunrise and sunset and not times before or after it such as
     * ``AstronomicalCalendar/getBeginNauticalTwilight()`` nautical twilight since those calculations are based on the
     * level of available light at the given dip below the horizon, something that is not affected by elevation, the
     * adjustment should only be made if the zenith == 90° ``adjustZenith(zenith:elevation:localDate:)`` adjusted for
     * refraction and solar radius. The algorithm used is
     *
     *     elevationAdjustment = Math.toDegrees(Math.acos(earthRadiusInMeters / (earthRadiusInMeters + elevationMeters)));
     *
     * The source of this algorithm is <a href="https://www.cs.tau.ac.il/~nachum/calendar-book/index.shtml">Calendrical
     * Calculations</a> by Edward M. Reingold and Nachum Dershowitz.
     *
     * - Parameter elevation: elevation in Meters.
     * - Returns: the adjusted zenith
     */
    func getElevationAdjustment(elevation: Double) -> Double {
        return JavaMath.toDegrees(acos(earthRadius / (earthRadius + (elevation / 1000))))
    }

    /**
     * Adjusts the zenith of astronomical sunrise and sunset to account for solar refraction, solar radius and elevation.
     * The value for Sun's zenith and true rise/set Zenith (used in this class and subclasses) is the angle that the
     * center of the Sun makes to a line perpendicular to the Earth's surface. If the Sun were a point and the Earth were
     * without an atmosphere, true sunset and sunrise would correspond to a 90° zenith. Because the Sun is not a point,
     * and because the atmosphere refracts light, this 90° zenith does not, in fact, correspond to true sunset or sunrise,
     * instead the centre of the Sun's disk must lie just below the horizon for the upper edge to be obscured. This means
     * that a zenith of just above 90° must be used. The Sun subtends an angle of 16 minutes of arc (this can be changed
     * via ``setSolarRadius(solarRadius:)``, or the apparent radius for the date is used, see
     * ``setUseApparentSolarRadius(useApparentSolarRadius:)``), and atmospheric refraction accounts for 34 minutes or so
     * (this can be changed via ``setRefraction(refraction:)``), giving a total of 50 arcminutes. The total value for
     * ZENITH is 90+(5/6) or 90.8333333° for true sunrise/sunset. Since a person at an elevation can see below the
     * horizon of a person at sea level, this will also adjust the zenith to account for elevation if available. Note
     * that this will only adjust the value if the zenith is exactly 90 degrees. For values below and above this no
     * correction is done. As an example, astronomical twilight is when the sun is 18° below the horizon or
     * ``AstronomicalCalendar/ASTRONOMICAL_ZENITH`` 108° below the zenith. This is traditionally calculated with none of
     * the above mentioned adjustments. The same goes for various <em>tzais</em> and <em>alos</em> times such as the
     * ``ZmanimCalendar/ZENITH_16_POINT_1`` 16.1° dip used in ``ComprehensiveZmanimCalendar/getAlos16Point1Degrees()``.
     *
     * - Parameters:
     *   - zenith: the azimuth below the vertical zenith of 90°. For sunset typically the zenith used for the calculation
     *     uses geometric zenith of 90° and adjusts this slightly to account for solar refraction and the sun's radius.
     *     Another example would be ``AstronomicalCalendar/getEndNauticalTwilight()`` that passes
     *     ``AstronomicalCalendar/NAUTICAL_ZENITH`` to this method.
     *   - elevation: elevation in Meters.
     *   - localDate: the date, used for the sun's apparent radius; if nil, ``getSolarRadius()`` is used.
     * - Returns: The zenith adjusted to include the sun's radius, refraction and ``getElevationAdjustment(elevation:)``
     *   elevation adjustment. This will only be adjusted for sunrise and sunset (if the zenith == 90°)
     */
    func adjustZenith(zenith: Double, elevation: Double, localDate: LocalDate?) -> Double {
        var adjustedZenith = zenith
        if zenith == AstronomicalCalculator.GEOMETRIC_ZENITH { // only adjust if it is exactly sunrise or sunset
            if useApparentSolarRadius, let localDate = localDate {
                adjustedZenith = zenith + (getApparentSolarRadius(localDate: localDate) + getRefraction() + getElevationAdjustment(elevation: elevation))
            } else {
                adjustedZenith = zenith + (getSolarRadius() + getRefraction() + getElevationAdjustment(elevation: elevation))
            }
        }
        return adjustedZenith
    }

    /**
     * Method to get the refraction value to be used when calculating sunrise and sunset. The default value is 34
     * arcminutes. The <a href="https://web.archive.org/web/20150915094635/http://www.cs.tau.ac.il/~nachum/calendar-book/second-edition/errata.pdf">Errata
     * and Notes for Calendrical Calculations: The Millennium Edition</a> by Edward M. Reingold and Nachum Dershowitz lists
     * the actual average refraction value as 34.478885263888294 or approximately 34' 29". The refraction value as well as
     * the solarRadius and elevation adjustment are added to the zenith used to calculate sunrise and sunset.
     *
     * - Returns: The refraction in arcminutes.
     */
    public func getRefraction() -> Double {
        return refraction
    }

    /**
     * A method to allow overriding the default refraction of the calculator.
     * @todo At some point in the future, an AtmosphericModel or Refraction object that models the atmosphere of different
     * locations might be used for increased accuracy.
     *
     * - Parameter refraction: The refraction in arcminutes.
     */
    public func setRefraction(refraction: Double) {
        self.refraction = refraction
        clearResultCache()
    }

    /**
     * Method to get the sun's radius. The default value is 16 arcminutes. The sun's radius as it appears from earth is
     * almost 16 arcminutes. It is only used when ``isUseApparentSolarRadius()`` is false.
     *
     * - Returns: The sun's radius in arcminutes.
     */
    public func getSolarRadius() -> Double {
        return solarRadius
    }

    /**
     * Method to set the sun's radius. Setting it turns ``isUseApparentSolarRadius()`` off, so the radius set is used.
     *
     * - Parameter solarRadius: The sun's radius in arcminutes. Negative and NaN values are ignored.
     */
    public func setSolarRadius(solarRadius: Double) {
        if solarRadius < 0 || solarRadius.isNaN {
            KosherSwiftWarnings.report("The solar radius \(solarRadius) must be a number of at least 0; it wasn't changed (\(self.solarRadius))")
            return
        }
        self.solarRadius = solarRadius
        self.useApparentSolarRadius = false
        clearResultCache()
    }

    /**
     * Returns if the sun's apparent radius for the date (which changes during the year with the earth's distance from the
     * sun) is used instead of the fixed ``getSolarRadius()`` (true by default).
     */
    public func isUseApparentSolarRadius() -> Bool {
        return useApparentSolarRadius
    }

    /** Sets if the sun's apparent radius for the date is used instead of the fixed ``getSolarRadius()``. */
    public func setUseApparentSolarRadius(useApparentSolarRadius: Bool) {
        self.useApparentSolarRadius = useApparentSolarRadius
        clearResultCache()
    }

    /**
     * Returns the sun's apparent radius (in degrees) for the date, which changes from about 0.2622° in early July to
     * about 0.2711° in early January. The values are for the year 2050 and the month and day of the date passed in.
     *
     * - Parameter localDate: the date. If nil, 16 arcminutes is returned.
     * - Returns: the apparent solar radius in degrees
     */
    public func getApparentSolarRadius(localDate: LocalDate?) -> Double {
        guard let localDate = localDate else {
            return 16.0 / 60.0
        }
        // LocalDate.withYear(2050) clamps February 29 to February 28 in the non-leap year 2050
        return AstronomicalCalculator.SOLAR_RADIUS_BY_DAY_OF_YEAR[localDate.withYear(2050).dayOfYear - 1]
    }

    static func tanDegrees(_ angle: Double) -> Double {
        return tan(JavaMath.toRadians(angle))
    }

    static func sinDegrees(_ angle: Double) -> Double {
        return sin(JavaMath.toRadians(angle))
    }

    static func cosDegrees(_ angle: Double) -> Double {
        return cos(JavaMath.toRadians(angle))
    }

    static func acosDegrees(_ angle: Double) -> Double {
        return JavaMath.toDegrees(acos(angle))
    }

    static func asinDegrees(_ angle: Double) -> Double {
        return JavaMath.toDegrees(asin(angle))
    }

    /** Creates a copy of this calculator with the same settings (and an empty result cache). */
    public func copy() -> AstronomicalCalculator {
        let copy = type(of: self).init()
        copy.refraction = refraction
        copy.solarRadius = solarRadius
        copy.useApparentSolarRadius = useApparentSolarRadius
        copy.earthRadius = earthRadius
        copy.useResultCache = useResultCache
        copyState(to: copy)
        return copy
    }

    /** Lets subclasses copy their own settings in ``copy()``. */
    func copyState(to copy: AstronomicalCalculator) {
    }

    /** Equal if the settings are equal (KosherJava's `equals`). */
    public func equals(_ other: AstronomicalCalculator) -> Bool {
        return type(of: self) == type(of: other) && earthRadius == other.earthRadius && refraction == other.refraction
            && solarRadius == other.solarRadius && useApparentSolarRadius == other.useApparentSolarRadius
    }

    /** The apparent solar radius by day of the year 2050, in degrees. */
    private static let SOLAR_RADIUS_BY_DAY_OF_YEAR: [Double] = [
        0.27108024, 0.27108486, 0.27108790, 0.27108930, 0.27108899, 0.27108695, 0.27108316, 0.27107762, 0.27107033,
        0.27106133, 0.27105062, 0.27103826, 0.27102427, 0.27100873, 0.27099168, 0.27097320, 0.27095337, 0.27093228,
        0.27091002, 0.27088667, 0.27086231, 0.27083701, 0.27081079, 0.27078369, 0.27075569, 0.27072676, 0.27069684,
        0.27066588, 0.27063378, 0.27060048, 0.27056589, 0.27052995, 0.27049261, 0.27045383, 0.27041359, 0.27037186,
        0.27032864, 0.27028396, 0.27023782, 0.27019025, 0.27014129, 0.27009098, 0.27003938, 0.26998658, 0.26993264,
        0.26987767, 0.26982177, 0.26976506, 0.26970763, 0.26964958, 0.26959099, 0.26953191, 0.26947239, 0.26941242,
        0.26935200, 0.26929108, 0.26922962, 0.26916755, 0.26910482, 0.26904136, 0.26897712, 0.26891206, 0.26884614,
        0.26877935, 0.26871165, 0.26864306, 0.26857358, 0.26850321, 0.26843197, 0.26835989, 0.26828703, 0.26821343,
        0.26813918, 0.26806437, 0.26798910, 0.26791348, 0.26783763, 0.26776167, 0.26768569, 0.26760979, 0.26753404,
        0.26745846, 0.26738308, 0.26730790, 0.26723289, 0.26715800, 0.26708320, 0.26700842, 0.26693363, 0.26685877,
        0.26678380, 0.26670870, 0.26663342, 0.26655796, 0.26648229, 0.26640640, 0.26633030, 0.26625399, 0.26617748,
        0.26610082, 0.26602406, 0.26594728, 0.26587055, 0.26579398, 0.26571769, 0.26564180, 0.26556641, 0.26549164,
        0.26541756, 0.26534425, 0.26527174, 0.26520006, 0.26512920, 0.26505915, 0.26498987, 0.26492132, 0.26485345,
        0.26478622, 0.26471959, 0.26465351, 0.26458794, 0.26452285, 0.26445820, 0.26439396, 0.26433010, 0.26426661,
        0.26420348, 0.26414070, 0.26407832, 0.26401636, 0.26395489, 0.26389400, 0.26383378, 0.26377435, 0.26371580,
        0.26365825, 0.26360179, 0.26354651, 0.26349247, 0.26343971, 0.26338825, 0.26333807, 0.26328918, 0.26324153,
        0.26319510, 0.26314983, 0.26310568, 0.26306261, 0.26302057, 0.26297951, 0.26293938, 0.26290014, 0.26286173,
        0.26282411, 0.26278725, 0.26275111, 0.26271570, 0.26268102, 0.26264710, 0.26261399, 0.26258177, 0.26255053,
        0.26252037, 0.26249137, 0.26246366, 0.26243731, 0.26241239, 0.26238897, 0.26236707, 0.26234671, 0.26232790,
        0.26231061, 0.26229481, 0.26228048, 0.26226756, 0.26225602, 0.26224581, 0.26223687, 0.26222914, 0.26222257,
        0.26221708, 0.26221262, 0.26220912, 0.26220653, 0.26220480, 0.26220392, 0.26220388, 0.26220470, 0.26220642,
        0.26220910, 0.26221282, 0.26221768, 0.26222375, 0.26223114, 0.26223991, 0.26225014, 0.26226187, 0.26227512,
        0.26228992, 0.26230626, 0.26232413, 0.26234349, 0.26236433, 0.26238659, 0.26241024, 0.26243521, 0.26246145,
        0.26248890, 0.26251746, 0.26254708, 0.26257766, 0.26260913, 0.26264141, 0.26267446, 0.26270823, 0.26274270,
        0.26277789, 0.26281382, 0.26285054, 0.26288813, 0.26292666, 0.26296622, 0.26300686, 0.26304868, 0.26309171,
        0.26313601, 0.26318159, 0.26322848, 0.26327666, 0.26332612, 0.26337685, 0.26342881, 0.26348197, 0.26353627,
        0.26359167, 0.26364809, 0.26370545, 0.26376368, 0.26382267, 0.26388233, 0.26394256, 0.26400328, 0.26406442,
        0.26412593, 0.26418777, 0.26424995, 0.26431249, 0.26437542, 0.26443880, 0.26450270, 0.26456718, 0.26463231,
        0.26469815, 0.26476474, 0.26483213, 0.26490034, 0.26496937, 0.26503922, 0.26510990, 0.26518138, 0.26525364,
        0.26532664, 0.26540034, 0.26547467, 0.26554957, 0.26562495, 0.26570072, 0.26577676, 0.26585296, 0.26592922,
        0.26600544, 0.26608154, 0.26615745, 0.26623314, 0.26630859, 0.26638382, 0.26645884, 0.26653372, 0.26660850,
        0.26668323, 0.26675798, 0.26683280, 0.26690773, 0.26698280, 0.26705803, 0.26713345, 0.26720905, 0.26728485,
        0.26736083, 0.26743698, 0.26751326, 0.26758964, 0.26766606, 0.26774245, 0.26781872, 0.26789476, 0.26797045,
        0.26804569, 0.26812035, 0.26819433, 0.26826755, 0.26833992, 0.26841141, 0.26848200, 0.26855170, 0.26862051,
        0.26868849, 0.26875567, 0.26882211, 0.26888786, 0.26895296, 0.26901746, 0.26908139, 0.26914478, 0.26920767,
        0.26927006, 0.26933199, 0.26939345, 0.26945445, 0.26951496, 0.26957497, 0.26963442, 0.26969325, 0.26975136,
        0.26980865, 0.26986502, 0.26992034, 0.26997450, 0.27002740, 0.27007895, 0.27012907, 0.27017773, 0.27022491,
        0.27027060, 0.27031483, 0.27035764, 0.27039906, 0.27043914, 0.27047794, 0.27051549, 0.27055186, 0.27058709,
        0.27062122, 0.27065430, 0.27068636, 0.27071746, 0.27074761, 0.27077684, 0.27080516, 0.27083256, 0.27085899,
        0.27088442, 0.27090875, 0.27093191, 0.27095379, 0.27097427, 0.27099326, 0.27101067, 0.27102640, 0.27104041,
        0.27105266, 0.27106312, 0.27107182, 0.27107876, 0.27108399
    ]
}
