//
//  MeeusCalculator.swift
//  KosherSwift
//
//  A port of KosherJava's MeeusCalculator.
//

import Foundation

/**
 * Implementation of sunrise and sunset methods using the <b>higher-accuracy</b> solar position algorithm of
 * <a href="https://en.wikipedia.org/wiki/Jean_Meeus">Jean Meeus</a> from
 * <a href="https://www.willbell.com/math/mc1.htm">Astronomical Algorithms</a> (2nd ed.). Unlike the ``NOAACalculator`` (which
 * uses the low-accuracy method from the same work, with a three-term equation of center and W. M. Smart's truncated equation of time,
 * good to roughly 0.01° / about 1 minute of time), this calculator computes the Earth's heliocentric position from the abridged <a
 * href="https://en.wikipedia.org/wiki/VSOP_(planets)">VSOP87</a> series printed in Meeus's Appendix III, then derives the Sun's
 * apparent geocentric longitude (applying the FK5 frame correction, nutation in longitude and the aberration of light), apparent
 * right ascension and declination, and the equation of time per Meeus chapter 28. The resulting solar position is good to roughly an
 * arc-second, an order of magnitude better than the low-accuracy method.
 *
 * <p><b>Practical note on accuracy.</b> For horizon events (sunrise / sunset) the extra precision is largely masked by atmospheric
 * refraction (uncertain by arc-minutes with temperature and pressure) and is therefore typically worth only a few seconds over
 * ``NOAACalculator``. The improvement is most visible for solar noon, the equation of time, and the Sun's elevation / azimuth
 * when it is well above the horizon.
 *
 * <p><b>Refraction and the Sun's radius are applied at sunrise and sunset only.</b> Like ``NOAACalculator``, this class does not
 * model atmospheric refraction itself; the horizon corrections come entirely from the parent ``adjustZenith``, which adds ``getRefraction`` (default 0.5667° / 34′), the solar radius - the date-based {@link
 * #getApparentSolarRadius(LocalDate)} by default (it varies slightly day to day), or the fixed ``getSolarRadius`` (default
 * 0.26667° / 16′) when ``isUseApparentSolarRadius`` is `false` - and the {@link
 * #getElevationAdjustment(double) elevation dip}, but <em>only</em> when the requested zenith is exactly the geometric 90°, that is,
 * only for true sunrise and sunset. For every other zenith - twilight angles and depression-angle <em>zmanim</em> such as
 * <em>alos</em> and <em>tzais</em> (e.g. 16.1°, 19.8°) - no refraction or solar-radius term is added and the time is solved for the
 * Sun's true geometric depression, as those <em>zmanim</em> are defined geometrically. Consequently ``setRefraction`` 
 * nd ``setSolarRadius`` affect sunrise / sunset (and any 90°-based time) but have no effect on depression-angle
 * <em>zmanim</em>. This calculator has no temperature or pressure inputs of any kind, since the only place they would matter is a
 * refraction model it does not use.
 *
 * <p><b>ΔT (terrestrial vs. universal time).</b> Meeus computes positions in Terrestrial Time (TT), whereas the civil times returned
 * here are Universal Time (UT ≈ UTC). This calculator therefore applies an estimate of <a href=
 * "https://en.wikipedia.org/wiki/%CE%94T_(timekeeping)">ΔT</a> (currently about a minute) when evaluating the Sun's position. This is
 * more correct than ``NOAACalculator``, which omits ΔT. The correction can be disabled via ``setApplyDeltaT`` to
 * reproduce NOAA-style UT = TT behavior, which is useful for direct comparison.
 *
 * <p><b>Coefficient coverage.</b> The VSOP87 tables below are the abridged Earth series from Meeus Appendix III and the principal
 * (Meeus chapter 22 abridged) nutation terms. They yield sub-arc-second to a few arc-seconds of accuracy - far beyond what any
 * <em>zman</em> requires. For full textbook precision the term tables can simply be extended with the remaining Appendix III /
 * IAU 1980 entries; the algorithm itself does not change.
 *
 * @author © Eliyahu Hershfeld 2026
 */
public class MeeusCalculator: AstronomicalCalculator {

    /** This calculator's results depend only on the arguments and on settings whose setters clear the cache. */
    public override func isResultCacheable() -> Bool {
        return true
    }

    /** The <a href="https://en.wikipedia.org/wiki/Julian_day">Julian day</a> of January 1, 2000, known as J2000.0. */
    private static let JULIAN_DAY_JAN_1_2000 = 2451545.0

    /** Julian days per century. */
    private static let JULIAN_DAYS_PER_CENTURY = 36525.0

    /** Whether to apply the ΔT (TT − UT) correction. Defaults to `true`. */
    private var applyDeltaT = true

    /** The kind of solar event being calculated. */
    private enum SolarEvent {
        case sunrise, sunset, noon, midnight
    }

    /** Default constructor of the MeeusCalculator. */
    public required init() {
        super.init()
    }

    /** @see AstronomicalCalculator/getCalculatorName() */
    public override func getCalculatorName() -> String {
        return "Jean Meeus Higher-Accuracy (VSOP87) Algorithm"
    }

    /**
     * Sets whether to apply the ΔT (TT − UT) correction. VSOP87 is a function of dynamical time (TT), so applying ΔT is more
     * accurate. The default is `true`.
     * @param applyDeltaT `true` (the default) to apply ΔT, or `false` to treat UT as TT.
     */
    public func setApplyDeltaT(applyDeltaT: Bool) {
        self.applyDeltaT = applyDeltaT
        clearResultCache()
    }

    /**
     * Returns whether the ΔT correction is applied.
     * @return whether the ΔT correction is applied.
     * @see setApplyDeltaT(applyDeltaT:)
     */
    public func isApplyDeltaT() -> Bool {
        return applyDeltaT
    }

    /** @see AstronomicalCalculator/getUTCSunrise(localDate:geoLocation:zenith:adjustForElevation:) */
    public override func getUTCSunrise(localDate: LocalDate, geoLocation: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double {
        return getUTCSunRiseSet(localDate, geoLocation, zenith, adjustForElevation, .sunrise)
    }

    /** @see AstronomicalCalculator/getUTCSunset(localDate:geoLocation:zenith:adjustForElevation:) */
    public override func getUTCSunset(localDate: LocalDate, geoLocation: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double {
        return getUTCSunRiseSet(localDate, geoLocation, zenith, adjustForElevation, .sunset)
    }

    /** The UTC time of sunrise or sunset in hours, or NaN if the sun does not reach the zenith that day. */
    private func getUTCSunRiseSet(_ localDate: LocalDate, _ geoLocation: GeoLocation, _ zenith: Double, _ adjustForElevation: Bool,
                                  _ solarEvent: SolarEvent) -> Double {
        var elevation = 0.0
        if adjustForElevation {
            elevation = solarEvent == .sunrise ? geoLocation.getSunriseElevation() : geoLocation.getSunsetElevation()
        }
        let adjustedZenith = adjustZenith(zenith: zenith, elevation: elevation, localDate: localDate)
        var riseSet = getSunRiseSetUTC(localDate, geoLocation.getLatitude(), -geoLocation.getLongitude(), adjustedZenith, solarEvent)
        riseSet = riseSet / 60
        return JavaMath.rem(JavaMath.rem(riseSet, 24) + 24, 24) // ensure that the time is >= 0 and < 24
    }

    /** @see AstronomicalCalculator/getUTCNoon(localDate:geoLocation:) */
    public override func getUTCNoon(localDate: LocalDate, geoLocation: GeoLocation) -> Double {
        var noon = getSolarNoonMidnightUTC(MeeusCalculator.getJulianDay(localDate), -geoLocation.getLongitude(), .noon)
        noon = noon / 60
        return JavaMath.rem(JavaMath.rem(noon, 24) + 24, 24) // ensure that the time is >= 0 and < 24
    }

    /** @see AstronomicalCalculator/getUTCMidnight(localDate:geoLocation:) */
    public override func getUTCMidnight(localDate: LocalDate, geoLocation: GeoLocation) -> Double {
        var midnight = getSolarNoonMidnightUTC(MeeusCalculator.getJulianDay(localDate), -geoLocation.getLongitude(), .midnight)
        midnight = midnight / 60
        return JavaMath.rem(JavaMath.rem(midnight, 24) + 24, 24) // ensure that the time is >= 0 and < 24
    }

    /** The UTC of solar noon or midnight in minutes after the start of the Julian day. */
    private func getSolarNoonMidnightUTC(_ julianDay: Double, _ longitude: Double, _ solarEvent: SolarEvent) -> Double {
        // no day-half shift: the loop epoch julianDay + solNoonUTC/1440 already lands on the event
        // First pass: seed includes the 720/1440-minute transit base so the equation of time is sampled near the true
        // transit (the NOAACalculator omits this base in its seed; here it is included for consistency with the loop).
        let base: Double = (solarEvent == .noon) ? 720 : 1440
        let tnoon = getJulianCenturiesFromJulianDay(julianDay + longitude / 360.0)
        var equationOfTime = MeeusCalculator.getEquationOfTime(tnoon)
        var solNoonUTC = base + (longitude * 4) - equationOfTime // minutes

        // Refine the equation of time at the calculated transit time.
        for _ in 0..<3 {
            let newt = getJulianCenturiesFromJulianDay(julianDay + solNoonUTC / 1440.0)
            equationOfTime = MeeusCalculator.getEquationOfTime(newt)
            solNoonUTC = base + (longitude * 4) - equationOfTime
        }
        return solNoonUTC
    }

    /**
     * The equation of time and declination at solar noon, which every zman of a day needs. The last one calculated is reused when
     * the Julian day, longitude and ΔT setting match, so results are bit-for-bit identical to calculating them each time.
     */
    private struct NoonSolution {
        let julianDay: Double
        let longitude: Double
        let applyDeltaT: Bool
        let equationOfTime: Double
        let solarDeclination: Double
    }

    /** The last NoonSolution calculated, guarded by `lock`. */
    private var lastNoonSolution: NoonSolution?
    private let lock = NSLock()

    /** Returns the noon solution for the day and longitude, reusing the last one when every input matches. */
    private func getNoonSolution(_ julianDay: Double, _ longitude: Double) -> NoonSolution {
        let applyDeltaTNow = applyDeltaT // read the setting once, so the key and the calculation use the same value
        lock.lock()
        let cached = lastNoonSolution
        lock.unlock()
        if let cached = cached, cached.julianDay == julianDay && cached.longitude == longitude && cached.applyDeltaT == applyDeltaTNow {
            return cached
        }
        let noonmin = getSolarNoonMidnightUTC(julianDay, longitude, .noon)
        let tnoon = getJulianCenturiesFromJulianDay(julianDay + noonmin / 1440.0)
        let sun = MeeusCalculator.getSunApparentEclipticCoordinates(tnoon) // shared by the equation of time and the declination
        let solution = NoonSolution(julianDay: julianDay, longitude: longitude, applyDeltaT: applyDeltaTNow,
                                    equationOfTime: MeeusCalculator.getEquationOfTime(tnoon, sun),
                                    solarDeclination: MeeusCalculator.getSunDeclination(tnoon, sun))
        if applyDeltaT == applyDeltaTNow { // only cache if the setting did not change mid calculation
            lock.lock()
            lastNoonSolution = solution
            lock.unlock()
        }
        return solution
    }

    /** The UTC of sunrise or sunset in minutes for the date, or NaN if the sun does not reach the zenith. */
    private func getSunRiseSetUTC(_ localDate: LocalDate, _ latitude: Double, _ longitude: Double, _ zenith: Double,
                                  _ solarEvent: SolarEvent) -> Double {
        let julianDay = MeeusCalculator.getJulianDay(localDate)

        // Use the declination at local solar noon as the starting point, then iterate.
        let noon = getNoonSolution(julianDay, longitude) // independent of the zenith, so shared by every zman of the day
        var equationOfTime = noon.equationOfTime
        var solarDeclination = noon.solarDeclination
        var hourAngle = MeeusCalculator.getSunHourAngle(latitude, solarDeclination, zenith, solarEvent)
        if hourAngle.isNaN {
            // Using the Sun's declination at noon, the Sun never reaches this zenith today. But the declination changes
            // during the day (by up to about 0.2° in 12 hours), so the Sun may still just reach it around midnight, when it
            // is at its lowest. Before reporting that there is no event, try again with the declination and equation of time
            // at that solar midnight: the one before sunrise, or the one after sunset.
            let noonmin = getSolarNoonMidnightUTC(julianDay, longitude, .noon)
            let midnight = noonmin + (solarEvent == .sunrise ? -720 : 720)
            let tmidnight = getJulianCenturiesFromJulianDay(julianDay + midnight / 1440.0)
            equationOfTime = MeeusCalculator.getEquationOfTime(tmidnight)
            solarDeclination = MeeusCalculator.getSunDeclination(tmidnight)
            hourAngle = MeeusCalculator.getSunHourAngle(latitude, solarDeclination, zenith, solarEvent)
        }
        var delta = longitude - JavaMath.toDegrees(hourAngle)
        var timeUTC = 720 + (4 * delta) - equationOfTime

        // Additional passes including the fractional Julian Day for improved accuracy (a third pass over the NOAA
        // implementation's two helps convergence at high latitudes).
        for _ in 0..<2 {
            let newt = getJulianCenturiesFromJulianDay(julianDay + timeUTC / 1440.0)
            let sun = MeeusCalculator.getSunApparentEclipticCoordinates(newt) // shared by the equation of time and the declination
            equationOfTime = MeeusCalculator.getEquationOfTime(newt, sun)
            solarDeclination = MeeusCalculator.getSunDeclination(newt, sun)
            hourAngle = MeeusCalculator.getSunHourAngle(latitude, solarDeclination, zenith, solarEvent)
            if hourAngle.isNaN {
                return Double.nan
            }
            delta = longitude - JavaMath.toDegrees(hourAngle)
            timeUTC = 720 + (4 * delta) - equationOfTime
        }
        return timeUTC
    }

    /**
     * Returns the UTC time (in hours) on the given day when the sun is due east (90°) or due west (270°), or NaN where it never
     * is.
     *
     * `azimuth` must be 90 or 270; other values return NaN and report a ``KosherSwiftWarnings`` warning (KosherJava throws an
     * IllegalArgumentException).
     */
    public override func getTimeAtAzimuth(localDate: LocalDate, geoLocation: GeoLocation, azimuth targetAzimuth: Double) -> Double {
        if targetAzimuth != 90.0 && targetAzimuth != 270.0 {
            KosherSwiftWarnings.report("The azimuth \(targetAzimuth) must be 90 or 270, the only azimuths supported; returning NaN")
            return Double.nan
        }
        let julianDay = MeeusCalculator.getJulianDay(localDate)
        let solarNoonBase = 0.5 - (geoLocation.getLongitude() / 360.0)
        var dateTime = solarNoonBase + ((targetAzimuth == 90.0) ? 0.25 : 0.75)
        for _ in 0..<3 {
            let julianCenturies = getJulianCenturiesFromJulianDay(julianDay + dateTime)
            let ratio = Self.tanDegrees(MeeusCalculator.getSunDeclination(julianCenturies)) / Self.tanDegrees(geoLocation.getLatitude())
            if ratio.isNaN || ratio > 1.0 || ratio < -1.0 { // Handle Tropics, Polar Regions, and Equator line divisions
                return Double.nan
            }
            let offset = ((targetAzimuth == 90.0) ? -1.0 : 1.0) * (Self.acosDegrees(ratio) / 360.0)
            dateTime = solarNoonBase + offset - (MeeusCalculator.getEquationOfTime(julianCenturies) / 1440.0)
        }
        let timeUTC = dateTime * 24.0
        return JavaMath.rem(JavaMath.rem(timeUTC, 24) + 24, 24) // normalize to [0,24) like the sibling UTC methods
    }

    /** Return the solar elevation in degrees, corrected for refraction, at the given time and location. */
    public override func getSolarElevation(date: Date, geoLocation: GeoLocation) -> Double {
        return getSolarElevationAzimuth(date, geoLocation, false)
    }

    /** Return the solar azimuth in degrees, measured clockwise from North, at the given time and location. */
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
        let jc = getJulianCenturiesFromJulianDay(MeeusCalculator.getJulianDay(utc.localDate) + fractionalDay)
        let decl = MeeusCalculator.getSunDeclination(jc)
        let eot = MeeusCalculator.getEquationOfTime(jc)
        let trueSolarTime = JavaMath.rem((fractionalDay + eot / 1440.0 + lon / 360.0) + 2, 1)
        let hourAngle = trueSolarTime * 2 * Double.pi - Double.pi
        let cosZenith = Self.sinDegrees(lat) * Self.sinDegrees(decl) + Self.cosDegrees(lat) * Self.cosDegrees(decl) * cos(hourAngle)
        let zenithDeg = Self.acosDegrees(max(-1, min(1, cosZenith)))
        let elevation = (90.0 - zenithDeg) + adjustElevationForRefraction(90.0 - zenithDeg)
        var azimuth: Double
        let azDenom = Self.cosDegrees(lat) * Self.sinDegrees(zenithDeg)
        if abs(azDenom) > 0.001 {
            let az = (Self.sinDegrees(lat) * Self.cosDegrees(zenithDeg) - Self.sinDegrees(decl)) / azDenom
            azimuth = 180 - Self.acosDegrees(max(-1, min(1, az))) * (hourAngle > 0 ? -1 : 1)
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
        let te = Self.tanDegrees(elevation)
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

    /** The hour angle of the sun in radians at the zenith; negative for sunset, NaN if the sun never reaches it. */
    private static func getSunHourAngle(_ latitude: Double, _ solarDeclination: Double, _ zenith: Double, _ solarEvent: SolarEvent) -> Double {
        let ratio = cosDegrees(zenith) / (cosDegrees(latitude) * cosDegrees(solarDeclination))
            - tanDegrees(latitude) * tanDegrees(solarDeclination)
        if ratio < -1.0 || ratio > 1.0 {
            return Double.nan // the sun never reaches this zenith (polar day / night)
        }
        var hourAngle = acos(ratio)
        if solarEvent == .sunset {
            hourAngle = -hourAngle
        }
        return hourAngle
    }

    // ---------------------------------------------------------------------------------------------------------------
    // Time scales
    // ---------------------------------------------------------------------------------------------------------------

    /** The Julian day at 0:00 UT of a date. */
    private static func getJulianDay(_ localDate: LocalDate) -> Double {
        var year = localDate.year
        var month = localDate.month
        let day = localDate.day
        if month <= 2 {
            year -= 1
            month += 12
        }
        let a = year / 100
        let b = 2 - a + a / 4
        return (365.25 * Double(year + 4716)).rounded(.down) + (30.6001 * Double(month + 1)).rounded(.down) + Double(day) + Double(b) - 1524.5
    }

    /** Julian centuries of dynamical time (TT, when ΔT is applied) since J2000.0 for a Julian day in UT. */
    private func getJulianCenturiesFromJulianDay(_ julianDayUT: Double) -> Double {
        var jde = julianDayUT
        if applyDeltaT {
            jde += MeeusCalculator.getDeltaT(julianDayUT) / 86400.0 // ΔT is in seconds; convert to days
        }
        return (jde - MeeusCalculator.JULIAN_DAY_JAN_1_2000) / MeeusCalculator.JULIAN_DAYS_PER_CENTURY
    }

    /** An estimate of ΔT (TT − UT) in seconds, from the Espenak and Meeus polynomials. */
    private static func getDeltaT(_ julianDay: Double) -> Double {
        let year = 2000.0 + (julianDay - JULIAN_DAY_JAN_1_2000) / 365.25
        var t: Double
        if year >= 2005 && year < 2050 {
            t = year - 2000
            return 62.92 + 0.32217 * t + 0.005589 * t * t
        } else if year >= 1986 && year < 2005 {
            t = year - 2000
            let partial = 63.86 + 0.3345 * t - 0.060374 * t * t + 0.0017275 * t * t * t
            return partial + 0.000651814 * pow(t, 4) + 0.00002373599 * pow(t, 5)
        } else if year >= 1961 && year < 1986 {
            t = year - 1975
            return 45.45 + 1.067 * t - t * t / 260.0 - t * t * t / 718.0
        } else if year >= 2050 && year < 2150 {
            return -20 + 32 * pow((year - 1820) / 100.0, 2) - 0.5628 * (2150 - year)
        } else { // generic parabola of Espenak and Meeus for dates well outside the calibrated range
            let u = (year - 1820) / 100.0
            return -20 + 32 * u * u
        }
    }

    // ---------------------------------------------------------------------------------------------------------------
    // High-accuracy solar position (Meeus chapters 22, 25, 28 with abridged VSOP87, Appendix III)
    // ---------------------------------------------------------------------------------------------------------------

    /** The Sun's apparent declination in degrees. */
    private static func getSunDeclination(_ julianCenturies: Double) -> Double {
        return getSunDeclination(julianCenturies, getSunApparentEclipticCoordinates(julianCenturies))
    }

    /** The Sun's apparent declination in degrees, from its apparent ecliptic coordinates {lambda, beta} in degrees. */
    private static func getSunDeclination(_ julianCenturies: Double, _ sun: [Double]) -> Double {
        let lambda = sun[0]
        let beta = sun[1]
        let epsilon = getTrueObliquity(julianCenturies)
        let sinDec = sinDegrees(beta) * cosDegrees(epsilon) + cosDegrees(beta) * sinDegrees(epsilon) * sinDegrees(lambda)
        return asinDegrees(sinDec)
    }

    /** The Sun's apparent right ascension in degrees (0 to 360). */
    private static func getSunRightAscension(_ julianCenturies: Double, _ sun: [Double]) -> Double {
        let lambda = sun[0]
        let beta = sun[1]
        let epsilon = getTrueObliquity(julianCenturies)
        let y = sinDegrees(lambda) * cosDegrees(epsilon) - tanDegrees(beta) * sinDegrees(epsilon)
        let x = cosDegrees(lambda)
        let ra = JavaMath.toDegrees(atan2(y, x))
        return JavaMath.rem(JavaMath.rem(ra, 360) + 360, 360)
    }

    /** The Sun's apparent ecliptic coordinates {lambda (longitude), beta (latitude)} in degrees. */
    private static func getSunApparentEclipticCoordinates(_ julianCenturies: Double) -> [Double] {
        let tau = julianCenturies / 10.0 // Julian millennia
        let earthL = JavaMath.toDegrees(sumSeries(EARTH_L, tau))   // Earth heliocentric longitude (deg)
        let earthB = JavaMath.toDegrees(sumSeries(EARTH_B, tau))   // Earth heliocentric latitude (deg)
        let earthR = sumSeries(EARTH_R, tau)                       // Earth radius vector (AU)

        // Geocentric position of the Sun is diametrically opposite the heliocentric Earth.
        var theta = earthL + 180.0 // geocentric longitude (deg), dynamical (VSOP87) frame
        var beta = -earthB         // geocentric latitude (deg)

        // FK5 frame correction (Meeus 25.9): convert from the VSOP87 dynamical frame to FK5.
        let lambdaPrime = theta - 1.397 * julianCenturies - 0.00031 * julianCenturies * julianCenturies
        let deltaLongFK5 = -0.09033 + 0.03916 * (cosDegrees(lambdaPrime) + sinDegrees(lambdaPrime)) * tanDegrees(beta)
        let deltaLatFK5 = 0.03916 * (cosDegrees(lambdaPrime) - sinDegrees(lambdaPrime))
        theta += deltaLongFK5 / 3600.0
        beta += deltaLatFK5 / 3600.0

        // Nutation in longitude (apparent place) and aberration of light.
        let nut = getNutation(julianCenturies) // {Δψ, Δε} in arc-seconds
        let aberration = -20.4898 / earthR      // arc-seconds (Meeus 25, abridged)
        let lambda = theta + nut[0] / 3600.0 + aberration / 3600.0
        return [JavaMath.rem(JavaMath.rem(lambda, 360) + 360, 360), beta]
    }

    /** The true obliquity of the ecliptic in degrees (mean obliquity plus nutation in obliquity). */
    private static func getTrueObliquity(_ julianCenturies: Double) -> Double {
        let seconds = 21.448 - julianCenturies
            * (46.8150 + julianCenturies * (0.00059 - julianCenturies * 0.001813))
        let epsilon0 = 23.0 + (26.0 + (seconds / 60.0)) / 60.0
        let deltaEpsilon = getNutation(julianCenturies)[1] / 3600.0
        return epsilon0 + deltaEpsilon
    }

    /** The nutation in longitude and obliquity {Δψ, Δε} in arc-seconds, from the principal terms (Meeus 22). */
    private static func getNutation(_ julianCenturies: Double) -> [Double] {
        let t = julianCenturies
        let omega = 125.04452 - 1934.136261 * t + 0.0020708 * t * t + t * t * t / 450000.0 // moon's ascending node
        let lSun = 280.4665 + 36000.7698 * t   // mean longitude of the sun
        let lMoon = 218.3165 + 481267.8813 * t // mean longitude of the moon
        let deltaPsi = -17.20 * sinDegrees(omega) - 1.32 * sinDegrees(2 * lSun)
            - 0.23 * sinDegrees(2 * lMoon) + 0.21 * sinDegrees(2 * omega)
        let deltaEpsilon = 9.20 * cosDegrees(omega) + 0.57 * cosDegrees(2 * lSun)
            + 0.10 * cosDegrees(2 * lMoon) - 0.09 * cosDegrees(2 * omega)
        return [deltaPsi, deltaEpsilon]
    }

    /** The equation of time in minutes. */
    private static func getEquationOfTime(_ julianCenturies: Double) -> Double {
        return getEquationOfTime(julianCenturies, getSunApparentEclipticCoordinates(julianCenturies))
    }

    /** The equation of time in minutes, from the Sun's apparent ecliptic coordinates. */
    private static func getEquationOfTime(_ julianCenturies: Double, _ sun: [Double]) -> Double {
        let tau = julianCenturies / 10.0
        // Mean longitude of the sun (Meeus 28.1), in degrees.
        var l0 = 280.4664567 + tau * (360007.6982779 + tau * (0.03032028
            + tau * (1.0 / 49931.0 - tau * (1.0 / 15300.0 + tau / 2000000.0))))
        l0 = JavaMath.rem(JavaMath.rem(l0, 360) + 360, 360)
        let alpha = getSunRightAscension(julianCenturies, sun)
        let nut = getNutation(julianCenturies)
        let epsilon = getTrueObliquity(julianCenturies)
        var e = l0 - 0.0057183 - alpha + (nut[0] / 3600.0) * cosDegrees(epsilon) // degrees
        // Reduce to (-180, 180] so the *4 conversion gives the customary +/- ~16 minute range.
        e = JavaMath.rem(JavaMath.rem(e + 180, 360) + 360, 360) - 180
        return e * 4.0 // 1 degree = 4 minutes of time
    }

    /**
     * Evaluate a VSOP87 series Σn (Σi Ai·cos(Bi + Ci·τ)) · τ^n with coefficients in 1e-8 of the native unit (radians or AU).
     */
    private static func sumSeries(_ series: [[[Double]]], _ tau: Double) -> Double {
        var total = 0.0
        var tauPow = 1.0
        for terms in series {
            var sum = 0.0
            for term in terms {
                sum += term[0] * cos(term[1] + term[2] * tau)
            }
            total += sum * tauPow
            tauPow *= tau
        }
        return total / 1.0e8
    }

    /** Two MeeusCalculator instances are equal if their settings, including ``isApplyDeltaT()``, are identical. */
    public override func equals(_ other: AstronomicalCalculator) -> Bool {
        guard super.equals(other), let other = other as? MeeusCalculator else {
            return false
        }
        return applyDeltaT == other.applyDeltaT
    }

    override func copyState(to copy: AstronomicalCalculator) {
        super.copyState(to: copy)
        if let copy = copy as? MeeusCalculator {
            copy.applyDeltaT = applyDeltaT
        }
    }

    // ---------------------------------------------------------------------------------------------------------------
    // Abridged VSOP87 Earth series (Meeus Appendix III). {A, B, C}; value Σ A·cos(B + C·τ), τ in Julian millennia,
    // result in 1e-8 rad (L, B) or 1e-8 AU (R).
    // ---------------------------------------------------------------------------------------------------------------

    /**
     * Earth heliocentric longitude series L0..L5. Abridged VSOP87 Earth series (Meeus, Astronomical Algorithms 2nd ed., Appendix
     * III). Each term is {A, B, C}; the series value is Σ A·cos(B + C·τ), τ in Julian millennia, result in 1e-8 rad (L, B) or
     * 1e-8 AU (R).
     */
    private static let EARTH_L: [[[Double]]] = [
        [ 
            [175347046, 0, 0], [3341656, 4.6692568, 6283.07585], [34894, 4.6261, 12566.1517],
            [3497, 2.7441, 5753.3849], [3418, 2.8289, 3.5231], [3136, 3.6277, 77713.7715],
            [2676, 4.4181, 7860.4194], [2343, 6.1352, 3930.2097], [1324, 0.7425, 11506.7698],
            [1273, 2.0371, 529.6910], [1199, 1.1096, 1577.3435], [990, 5.233, 5884.927],
            [902, 2.045, 26.298], [857, 3.508, 398.149], [780, 1.179, 5223.694],
            [753, 2.533, 5507.553], [505, 4.583, 18849.228], [492, 4.205, 775.523],
            [357, 2.920, 0.067], [317, 5.849, 11790.629], [284, 1.899, 796.298],
            [271, 0.315, 10977.079], [243, 0.345, 5486.778], [206, 4.806, 2544.314],
            [205, 1.869, 5573.143], [202, 2.458, 6069.777], [156, 0.833, 213.299],
            [132, 3.411, 2942.463], [126, 1.083, 20.775], [115, 0.645, 0.980],
            [103, 0.636, 4694.003], [102, 0.976, 15720.839], [102, 4.267, 7.114],
            [99, 6.21, 2146.17], [98, 0.68, 155.42], [86, 5.98, 161000.69],
            [85, 1.30, 6275.96], [85, 3.67, 71430.70], [80, 1.81, 17260.15],
            [79, 3.04, 12036.46], [75, 1.76, 5088.63], [74, 3.50, 3154.69],
            [74, 4.68, 801.82], [70, 0.83, 9437.76], [62, 3.98, 8827.39],
            [61, 1.82, 7084.90], [57, 2.78, 6286.60], [56, 4.39, 14143.50],
            [56, 3.47, 6279.55], [52, 0.19, 12139.55], [52, 1.33, 1748.02],
            [51, 0.28, 5856.48], [49, 0.49, 1194.45], [41, 5.37, 8429.24],
            [41, 2.40, 19651.05], [39, 6.17, 10447.39], [37, 6.04, 10213.29],
            [37, 2.57, 1059.38], [36, 1.71, 2352.87], [36, 1.78, 6812.77],
            [33, 0.59, 17789.85], [30, 0.44, 83996.85], [30, 2.74, 1349.87],
            [25, 3.16, 4690.48]
        ],
        [ 
            [628331966747.0, 0, 0], [206059, 2.678235, 6283.07585], [4303, 2.6351, 12566.1517],
            [425, 1.590, 3.523], [119, 5.796, 26.298], [109, 2.966, 1577.344],
            [93, 2.59, 18849.23], [72, 1.14, 529.69], [68, 1.87, 398.15],
            [67, 4.41, 5507.55], [59, 2.89, 5223.69], [56, 2.17, 155.42],
            [45, 0.40, 796.30], [36, 0.47, 775.52], [29, 2.65, 7.11],
            [21, 5.34, 0.98], [19, 1.85, 5486.78], [19, 4.97, 213.30],
            [17, 2.99, 6275.96], [16, 0.03, 2544.31], [16, 1.43, 2146.17],
            [15, 1.21, 10977.08], [12, 2.83, 1748.02], [12, 3.26, 5088.63],
            [12, 5.27, 1194.45], [12, 2.08, 4694.00], [11, 0.77, 553.57],
            [10, 1.30, 6286.60], [10, 4.24, 1349.87], [9, 2.70, 242.73],
            [9, 5.64, 951.72], [8, 5.30, 2352.87], [6, 2.65, 9437.76],
            [6, 4.67, 4690.48]
        ],
        [ 
            [52919, 0, 0], [8720, 1.0721, 6283.0758], [309, 0.867, 12566.152],
            [27, 0.05, 3.52], [16, 5.19, 26.30], [16, 3.68, 155.42],
            [10, 0.76, 18849.23], [9, 2.06, 77713.77], [7, 0.83, 775.52],
            [5, 4.66, 1577.34], [4, 1.03, 7.11], [4, 3.44, 5573.14],
            [3, 5.14, 796.30], [3, 6.05, 5507.55], [3, 1.19, 242.73],
            [3, 6.12, 529.69], [3, 0.31, 398.15], [3, 2.28, 553.57],
            [2, 4.38, 5223.69], [2, 3.75, 0.98]
        ],
        [ 
            [289, 5.844, 6283.076], [35, 0, 0], [17, 5.49, 12566.15],
            [3, 5.20, 155.42], [1, 4.72, 3.52], [1, 5.30, 18849.23], [1, 5.97, 242.73]
        ],
        [ 
            [114, 3.142, 0], [8, 4.13, 6283.08], [1, 3.84, 12566.15]
        ],
        [ 
            [1, 3.14, 0]
        ]
    ]

    /** Earth heliocentric latitude series B0..B1. */
    private static let EARTH_B: [[[Double]]] = [
        [ 
            [280, 3.199, 84334.662], [102, 5.422, 5507.553], [80, 3.88, 5223.69],
            [44, 3.70, 2352.87], [32, 4.00, 1577.34]
        ],
        [ 
            [9, 3.90, 5507.55], [6, 1.73, 5223.69]
        ]
    ]

    /** Earth radius-vector series R0..R4 (AU). */
    private static let EARTH_R: [[[Double]]] = [
        [ 
            [100013989, 0, 0], [1670700, 3.0984635, 6283.07585], [13956, 3.05525, 12566.1517],
            [3084, 5.1985, 77713.7715], [1628, 1.1739, 5753.3849], [1576, 2.8469, 7860.4194],
            [925, 5.453, 11506.770], [542, 4.564, 3930.210], [472, 3.661, 5884.927],
            [346, 0.964, 5507.553], [329, 5.900, 5223.694], [307, 0.299, 5573.143],
            [243, 4.273, 11790.629], [212, 5.847, 1577.344], [186, 5.022, 10977.079],
            [175, 3.012, 18849.228], [110, 5.055, 5486.778], [98, 0.89, 6069.78],
            [86, 5.69, 15720.84], [86, 1.27, 161000.69], [65, 0.27, 17260.15],
            [63, 0.92, 529.69], [57, 2.01, 83996.85], [56, 5.24, 71430.70],
            [49, 3.25, 2544.31], [47, 2.58, 775.52], [45, 5.54, 9437.76],
            [43, 6.01, 6275.96], [39, 5.36, 4694.00], [38, 2.39, 8827.39],
            [37, 0.83, 19651.05], [37, 4.90, 12139.55], [36, 1.67, 12036.46],
            [35, 1.84, 2942.46], [33, 0.24, 7084.90], [32, 0.18, 5088.63],
            [32, 1.78, 398.15], [28, 1.21, 6286.60], [28, 1.90, 6279.55],
            [26, 4.59, 10447.39]
        ],
        [ 
            [103019, 1.10749, 6283.07585], [1721, 1.0644, 12566.1517], [702, 3.142, 0],
            [32, 1.02, 18849.23], [31, 2.84, 5507.55], [25, 1.32, 5223.69],
            [18, 1.42, 1577.34], [10, 5.91, 10977.08], [9, 1.42, 6275.96], [9, 0.27, 5486.78]
        ],
        [ 
            [4359, 5.7846, 6283.0758], [124, 5.579, 12566.152], [12, 3.14, 0],
            [9, 3.63, 77713.77], [6, 1.87, 5573.14], [3, 5.47, 18849.23]
        ],
        [ 
            [145, 4.273, 6283.076], [7, 3.92, 12566.15]
        ],
        [ 
            [4, 2.56, 6283.08]
        ]
    ]
}
