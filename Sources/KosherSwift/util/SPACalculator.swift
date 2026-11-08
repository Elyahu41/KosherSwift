//
//  SPACalculator.swift
//  KosherSwift
//
//  A port of KosherJava's SPACalculator.
//

import Foundation

/**
 * Implementation of solar times using the <a href="https://midcdmz.nrel.gov/spa/">Solar Position Algorithm (SPA)</a>. This was the
 * work of Ibrahim Reda and Afshin Andreas (NREL/TP-560-34302, <a href="https://doi.org/10.1016/j.solener.2003.12.003">Solar Energy
 * 76 (2004) 577-589</a>). SPA computes the Earth's heliocentric position from the <a href=
 * "https://en.wikipedia.org/wiki/VSOP_(planets)">VSOP87</a> series, applies nutation, aberration and the obliquity of the ecliptic
 * to obtain the Sun's apparent geocentric right ascension and declination, then performs the full <b>topocentric</b> reduction -
 * observer parallax (using latitude, longitude and elevation) and atmospheric refraction - to yield the observed topocentric zenith
 * and azimuth. Its stated uncertainty is ±0.0003° (about one arc-second) for the years −2000 to +6000.
 *
 * <p><b>Refraction is fully configurable through the parent ``AstronomicalCalculator``.</b> Many SPA ports hardcode their
 * refraction model (and even their solar radius); this one does not:
 * <ul>
 * <li><b>Sunrise / sunset (the geometric 90° zenith only).</b> The horizon geometry is taken entirely from the parent's {@link
 *     #adjustZenith(double, double, LocalDate)}: ``getRefraction`` / ``setRefraction`` (default 0.5667° / 34′);
 *     the solar radius - the date-based ``getApparentSolarRadius`` by default (it varies slightly day to day), or the
 *     fixed ``getSolarRadius`` (default 0.26667° / 16′) when ``isUseApparentSolarRadius`` is `false`;
 *     and the elevation dip. SPA's own atmospheric refraction is <em>not</em> applied on this
 *     path - the calculator solves for the geometric (parallax-included, un-refracted) center of the Sun reaching the parent-supplied
 *     zenith, exactly as ``NOAACalculator`` and ``MeeusCalculator`` do. The parent only adds these corrections when the
 *     zenith is exactly 90°, so ``setRefraction`` and ``setSolarRadius`` change sunrise / sunset (and any
 *     90°-based time) and nothing else.</li>
 * <li><b>Twilight and depression-angle <em>zmanim</em> (e.g. <em>alos</em> / <em>tzais</em> at 16.1°, 19.8°).</b> These pass a zenith
 *     other than 90°, so ``adjustZenith`` adds nothing: no refraction, no solar radius. The time is
 *     solved for the Sun's <em>true geometric</em> depression, as such <em>zmanim</em> are defined. None of {@link
 *     #setRefraction(double)}, ``setSolarRadius``, ``setPressure`` or ``setTemperature``
 *     affect them.</li>
 * <li><b>Instantaneous elevation / *     azimuth only.</b> Here the full SPA (Reda-Andreas / Sæmundsson) atmospheric-refraction model is used, with its horizon
 *     parameter taken from the parent's ``getRefraction`` and the pressure and {@link
 *     #setTemperature(double) temperature} settable. <b>These two settings affect this path and only this path</b> - they have no
 *     effect on sunrise, sunset, twilight or any depression-angle <em>zman</em>. (Note that within the KosherJava calendar nothing
 *     calls  ``getSolarElevation`` / `#getSolarAzimuth(Instant, GeoLocation)`; they are direct-query
 *     methods, so in normal calendar use the pressure and temperature settings are inert.)</li>
 * </ul>
 *
 * <p><b>ΔT</b> (TT − UT) is integral to SPA and is applied here. It defaults to an Espenak-Meeus estimate but can be overridden
 * exactly via ``setDeltaTOverride`` (the published SPA test case fixes ΔT = 67 seconds), or disabled via {@link
 * #setApplyDeltaT(boolean)}.
 *
 * <p><b>Topocentric note.</b> Unlike ``NOAACalculator/getSolarElevation`` (sea-level, altitude-independent),
 * this calculator's elevation / azimuth are genuinely topocentric: the observer's elevation feeds
 * the parallax term. The `adjustForElevation` flag on sunrise / sunset continues to control only the geometric horizon
 * <em>dip</em> via the parent.
 *
 * <p><b>Coefficient coverage.</b> The VSOP87 Earth tables are the abridged Appendix III set (validated to about 0.1′ against Meeus's
 * worked example), and the nutation uses the principal terms. These give a few arc-seconds of accuracy - vastly beyond any
 * <em>zmanim</em> requirements. For the full published SPA ±0.0003° envelope, the VSOP87 tables and the IAU 1980 nutation series can
 * be extended without changing the algorithm.
 *
 * @author © Eliyahu Hershfeld 2026; NREL SPA (Reda and Andreas) port
 */
public class SPACalculator: AstronomicalCalculator {

    /** This calculator's results depend only on the arguments and on settings whose setters clear the cache. */
    override func isResultCacheable() -> Bool {
        return true
    }

    /** The <a href="https://en.wikipedia.org/wiki/Julian_day">Julian day</a> of J2000.0. */
    private static let JULIAN_DAY_JAN_1_2000 = 2451545.0

    /** Julian days per century. */
    private static let JULIAN_DAYS_PER_CENTURY = 36525.0

    /** Whether to apply the ΔT (TT−UT) correction. Defaults to `true`. */
    private var applyDeltaT = true

    /** An explicit ΔT (seconds) override; `nil` means estimate it from the date. */
    private var deltaTOverride: Double? = nil

    /** Annual average local pressure in millibars, used by the SPA refraction model. Default 1013.25. */
    private var pressure = 1013.25

    /** Annual average local temperature in °C, used by the SPA refraction model. Default 10. */
    private var temperature = 10.0

    /** The kind of solar event being calculated. */
    private enum SolarEvent {
        case sunrise, sunset, noon, midnight
    }

    /**
     * The part of a rise / set solution that does not depend on the zenith: the declination and the equation of time at solar
     * noon. Every zman of a day needs the same values, so the last one calculated is kept and reused. The key is every input
     * the values depend on (the Julian day, the longitude and the two ΔT settings), so a cached value is only ever returned for
     * identical inputs, and the results are bit-for-bit identical to calculating them each time.
     */
    private struct NoonSolution {
        let jdDay: Double
        let lonWest: Double
        let applyDeltaT: Bool
        let deltaTOverride: Double?
        let declNoon: Double
        let eot: Double

        func matches(_ jdDay: Double, _ lonWest: Double, _ applyDeltaT: Bool, _ deltaTOverride: Double?) -> Bool {
            return self.jdDay == jdDay && self.lonWest == lonWest && self.applyDeltaT == applyDeltaT
                && self.deltaTOverride == deltaTOverride
        }
    }

    /** The last NoonSolution calculated, and the interpolation windows; guarded by `lock`. Not part of ``equals(_:)``. */
    private var lastNoonSolution: NoonSolution?
    private var seriesWindows: [SeriesWindow] = []
    private let lock = NSLock()

    /** Returns the noon solution for the day and longitude, reusing the last one when every input matches. */
    private func getNoonSolution(_ jdDay: Double, _ lonWest: Double) -> NoonSolution {
        let applyDeltaTNow = applyDeltaT // read the settings once, so the key and the calculation use the same values
        let deltaTOverrideNow = deltaTOverride
        lock.lock()
        let cached = lastNoonSolution
        lock.unlock()
        if let cached = cached, cached.matches(jdDay, lonWest, applyDeltaTNow, deltaTOverrideNow) {
            return cached
        }
        let noonMin = solveNoonMidnight(jdDay, lonWest, .noon)
        let declNoon = solarCoords(jdDay + noonMin / 1440.0)[1]
        let eot = equationOfTime(jdDay + noonMin / 1440.0)
        let solution = NoonSolution(jdDay: jdDay, lonWest: lonWest, applyDeltaT: applyDeltaTNow, deltaTOverride: deltaTOverrideNow,
                                    declNoon: declNoon, eot: eot)
        if applyDeltaT == applyDeltaTNow && deltaTOverride == deltaTOverrideNow { // only cache if the settings did not change
            lock.lock()
            lastNoonSolution = solution
            lock.unlock()
        }
        return solution
    }

    /** Default constructor of the SPACalculator. */
    public required init() {
        super.init()
    }

    /** @see AstronomicalCalculator/getCalculatorName() */
    public override func getCalculatorName() -> String {
        return "NREL Solar Position Algorithm"
    }

    /**
     * Sets to apply ΔT `true` (default), or `false` to omit it (UT = TT).
     * @param applyDeltaT `true` (default) to apply ΔT, `false` to omit it (UT = TT).
     * @see isApplyDeltaT()
     */
    public func setApplyDeltaT(applyDeltaT: Bool) {
        self.applyDeltaT = applyDeltaT
        clearResultCache()
    }

    /**
     * Returns whether the ΔT correction is being applied.
     * @return whether the ΔT correction is being applied.
     * @see setApplyDeltaT(applyDeltaT:)
     */
    public func isApplyDeltaT() -> Bool {
        return applyDeltaT
    }

    /**
     * Override the estimated ΔT with an explicit value in seconds (for example 67 seconds for the published SPA test case), or
     * `nil` to revert to the date-based estimate.
     * @param deltaTSeconds ΔT in seconds, or `nil` to estimate.
     */
    public func setDeltaTOverride(deltaTSeconds: Double?) {
        self.deltaTOverride = deltaTSeconds
        clearResultCache()
    }

    /**
     * Return the explicit ΔT (TT - UT) override in seconds, or `nil` if ΔT is being estimated from the date (the default).
     * Note that this returns the override setting, not the estimated value in use.
     * @return the explicit ΔT override in seconds, or `nil` if it is being estimated from the date.
     * @see setDeltaTOverride(deltaTSeconds:)
     */
    public func getDeltaTOverride() -> Double? {
        return deltaTOverride
    }

    /**
     * Set the annual average local pressure used by the SPA atmospheric-refraction model. <b>This affects only
     * ``getSolarElevation(date:geoLocation:)`` and ``getSolarAzimuth(date:geoLocation:)``</b>; it has no effect on sunrise,
     * sunset, twilight or any depression-angle <em>zman</em>, whose refraction (if any) comes from the parent's fixed
     * ``AstronomicalCalculator/getRefraction()``. See the class documentation.
     * @param pressureMillibars the pressure in millibars (hPa).
     */
    public func setPressure(pressureMillibars: Double) {
        self.pressure = pressureMillibars
        clearResultCache()
    }

    /**
     * Return the pressure in millibars used by the refraction model.
     * @return the pressure in millibars used by the refraction model.
     */
    public func getPressure() -> Double {
        return pressure
    }

    /**
     * Set the annual average local temperature used by the SPA atmospheric-refraction model. <b>This affects only
     * ``getSolarElevation(date:geoLocation:)`` and ``getSolarAzimuth(date:geoLocation:)``</b>; it has no effect on sunrise,
     * sunset, twilight or any depression-angle <em>zman</em>, whose refraction (if any) comes from the parent's fixed
     * ``AstronomicalCalculator/getRefraction()``. See the class documentation.
     * @param temperatureCelsius the temperature in degrees Celsius.
     */
    public func setTemperature(temperatureCelsius: Double) {
        self.temperature = temperatureCelsius
        clearResultCache()
    }

    /**
     * Returns the temperature in °C used by the refraction model.
     * @return the temperature in °C used by the refraction model.
     */
    public func getTemperature() -> Double {
        return temperature
    }

    /** @see AstronomicalCalculator/getUTCSunrise(localDate:geoLocation:zenith:adjustForElevation:) */
    public override func getUTCSunrise(localDate: LocalDate, geoLocation: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double {
        return getUTCSunRiseSet(localDate, geoLocation, zenith, adjustForElevation, .sunrise)
    }

    /** @see AstronomicalCalculator/getUTCSunset(localDate:geoLocation:zenith:adjustForElevation:) */
    public override func getUTCSunset(localDate: LocalDate, geoLocation: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double {
        return getUTCSunRiseSet(localDate, geoLocation, zenith, adjustForElevation, .sunset)
    }

    /**
     * Calculate UTC sunrise or sunset (or any twilight angle) in 24-hour format. The horizon geometry (refraction, the sun's
     * radius and the elevation dip) is supplied entirely by the parent `adjustZenith`, so the SPA topocentric solution is solved
     * for the un-refracted, parallax-corrected center of the Sun reaching that zenith.
     * @return the UTC time in hours, or NaN if the sun does not reach the zenith that day.
     */
    private func getUTCSunRiseSet(_ localDate: LocalDate, _ geoLocation: GeoLocation, _ zenith: Double, _ adjustForElevation: Bool,
                                  _ solarEvent: SolarEvent) -> Double {
        var elevation = 0.0
        if adjustForElevation {
            elevation = solarEvent == .sunrise ? geoLocation.getSunriseElevation() : geoLocation.getSunsetElevation()
        }
        let adjustedZenith = adjustZenith(zenith: zenith, elevation: elevation, localDate: localDate)
        if !adjustedZenith.isFinite {
            // A NaN or infinite zenith (or a NaN / infinite refraction, solar radius or earth radius, which make the adjusted
            // zenith NaN) has no crossing, and the bracketing search can't rule out any interval of a NaN function.
            return Double.nan
        }
        var riseSet = solveRiseSet(localDate, geoLocation, adjustedZenith, solarEvent)
        if riseSet.isNaN {
            return Double.nan
        }
        riseSet = riseSet / 60
        return JavaMath.rem(JavaMath.rem(riseSet, 24) + 24, 24)
    }

    /** Solve for the UTC minutes after 0:00 of the date at which the topocentric true zenith equals the adjusted zenith. */
    private func solveRiseSet(_ localDate: LocalDate, _ geoLocation: GeoLocation, _ adjustedZenith: Double, _ solarEvent: SolarEvent) -> Double {
        let jdDay = SPACalculator.getJulianDay(localDate)
        let lonWest = -geoLocation.getLongitude()
        let lat = geoLocation.getLatitude()
        let longitude = geoLocation.getLongitude()
        let elevation = geoLocation.getElevation()

        // Closed-form first guess using the geocentric declination at local apparent noon.
        let noon = getNoonSolution(jdDay, lonWest) // independent of the zenith, so shared by every zman of the day
        let declNoon = noon.declNoon
        let eot = noon.eot
        let cosH0 = (Self.cosDegrees(adjustedZenith) - Self.sinDegrees(lat) * Self.sinDegrees(declNoon))
            / (Self.cosDegrees(lat) * Self.cosDegrees(declNoon))
        if cosH0 < -1.0 || cosH0 > 1.0 {
            return bracketRiseSet(jdDay, lat, longitude, elevation, adjustedZenith, solarEvent) // the estimate says no event: let the exact search decide
        }
        let h0 = Self.acosDegrees(cosH0) // degrees, positive
        let signed = (solarEvent == .sunrise) ? h0 : -h0
        let guess = 720 + 4 * (lonWest - signed) - eot // minutes

        // Fast path: the secant on interpolated solar coordinates, accepted only after it is verified exactly and lies in the window.
        var stats = [0.0, 0.0]
        let ti = secant(jdDay, lat, longitude, elevation, adjustedZenith, guess, true, &stats)
        let fastWindow = SPACalculator.getRiseSetWindowMinutes(longitude, solarEvent)
        let fastInWindow = solarEvent == .sunrise ? ti > fastWindow[0] && ti <= fastWindow[1] : ti >= fastWindow[0] && ti < fastWindow[1]
        if fastInWindow && isInterpolatedSolutionAcceptable(ti, stats, jdDay, lat, longitude, elevation, adjustedZenith) {
            return ti
        }

        // Exact path: secant refinement on f(t) = topocentricTrueZenith(t) - adjustedZenith.
        var t0 = guess
        var t1 = guess + 0.5
        var f0 = topocentricTrueZenith(jdDay + t0 / 1440.0, lat, longitude, elevation, false) - adjustedZenith
        var f1 = topocentricTrueZenith(jdDay + t1 / 1440.0, lat, longitude, elevation, false) - adjustedZenith
        var minSlope = abs((f1 - f0) / (t1 - t0)) // degrees per minute
        var i = 0
        while i < 12 && abs(f1) > 1e-9 {
            let denom = (f1 - f0)
            if denom == 0 {
                break
            }
            minSlope = min(minSlope, abs(denom / (t1 - t0)))
            let t2 = t1 - f1 * (t1 - t0) / denom
            t0 = t1
            f0 = f1
            t1 = t2
            f1 = topocentricTrueZenith(jdDay + t1 / 1440.0, lat, longitude, elevation, false) - adjustedZenith
            i += 1
        }
        // Accept the secant result only if it converged onto the requested zenith inside this date's window. Otherwise (no
        // convergence near the poles or on a grazing day, or a crossing belonging to a neighbouring date) use the bracketing search.
        let window = SPACalculator.getRiseSetWindowMinutes(longitude, solarEvent)
        let inWindow = solarEvent == .sunrise ? t1 > window[0] && t1 <= window[1] : t1 >= window[0] && t1 < window[1]
        // A slow crossing anywhere along the path means a near-grazing day, where the secant can settle on a near miss (the closest
        // approach to the zenith) or on another crossing; the bracketing search decides those days.
        if inWindow && abs(f1) <= SPACalculator.MAX_ZENITH_RESIDUAL && minSlope >= SPACalculator.GRAZING_MIN_SLOPE {
            return t1
        }
        return bracketRiseSet(jdDay, lat, longitude, elevation, adjustedZenith, solarEvent)
    }

    /**
     * Whether a solution found on interpolated coordinates can be returned as is: the crossing must be steep enough, and the
     * exact zenith at that time must be within GUARD_TOLERANCE_MINUTES of the requested one (measured in time along the slope).
     */
    private func isInterpolatedSolutionAcceptable(_ t: Double, _ stats: [Double], _ jdDay: Double, _ lat: Double, _ longitude: Double,
                                                  _ elevation: Double, _ adjustedZenith: Double) -> Bool {
        if t.isNaN || t.isInfinite || !(stats[0] >= SPACalculator.GUARD_MIN_SLOPE) {
            return false
        }
        let exactResidual = topocentricTrueZenith(jdDay + t / 1440.0, lat, longitude, elevation, false) - adjustedZenith
        return abs(exactResidual / stats[1]) <= SPACalculator.GUARD_TOLERANCE_MINUTES
    }

    /**
     * The secant method on f(t) = topocentricTrueZenith(t) - adjustedZenith. `stats` receives the smallest slope seen (0 if it did
     * not converge) and the last slope, in degrees per minute.
     */
    private func secant(_ jdDay: Double, _ lat: Double, _ longitude: Double, _ elevation: Double, _ adjustedZenith: Double,
                        _ guess: Double, _ interpolate: Bool, _ stats: inout [Double]) -> Double {
        var t0 = guess
        var t1 = guess + 0.5
        var f0 = topocentricTrueZenith(jdDay + t0 / 1440.0, lat, longitude, elevation, interpolate) - adjustedZenith
        var f1 = topocentricTrueZenith(jdDay + t1 / 1440.0, lat, longitude, elevation, interpolate) - adjustedZenith
        var minSlope = Double.greatestFiniteMagnitude
        var lastSlope = (f1 - f0) / (t1 - t0)
        var i = 0
        while i < 12 && abs(f1) > 1e-9 {
            let denom = (f1 - f0)
            if denom == 0 {
                break
            }
            lastSlope = denom / (t1 - t0)
            minSlope = min(minSlope, abs(lastSlope))
            let t2 = t1 - f1 * (t1 - t0) / denom
            t0 = t1
            f0 = f1
            t1 = t2
            f1 = topocentricTrueZenith(jdDay + t1 / 1440.0, lat, longitude, elevation, interpolate) - adjustedZenith
            i += 1
        }
        stats[0] = abs(f1) > 1e-6 ? 0 : min(minSlope, abs(lastSlope)) // not converged: use the exact path
        stats[1] = lastSlope
        return t1
    }

    /** The number of nodes (one day apart / (nodes - 1)) the solar series are interpolated over. */
    private static let INTERPOLATION_NODES = 5
    /** The number of interpolation windows (days) kept. */
    private static let INTERPOLATION_WINDOWS = 4
    /** The smallest slope (degrees of zenith per minute) at which an interpolated crossing is trusted. */
    private static let GUARD_MIN_SLOPE = 0.02
    /** The tolerance in minutes (0.5 ms) for accepting an interpolated crossing after verifying it exactly. */
    private static let GUARD_TOLERANCE_MINUTES = 0.5 / 60000.0

    /** The VSOP87 L, B (degrees), R (AU), and the nutation Δψ, Δε (degrees) at a time. */
    private static func exactSeries(_ jme: Double, _ jce: Double) -> [Double] {
        let nut = nutation(jce)
        return [JavaMath.toDegrees(sumSeries(EARTH_L, jme)), JavaMath.toDegrees(sumSeries(EARTH_B, jme)), sumSeries(EARTH_R, jme),
                nut[0], nut[1]]
    }

    /** The exact series at INTERPOLATION_NODES equally spaced times over one day starting at `start`. */
    private final class SeriesWindow {
        let start: Double
        let nodes: [[Double]]

        init(_ start: Double) {
            self.start = start
            var nodes: [[Double]] = []
            for k in 0..<SPACalculator.INTERPOLATION_NODES {
                let jce = (start + Double(k) / Double(SPACalculator.INTERPOLATION_NODES - 1) - SPACalculator.JULIAN_DAY_JAN_1_2000)
                    / SPACalculator.JULIAN_DAYS_PER_CENTURY
                nodes.append(SPACalculator.exactSeries(jce / 10.0, jce))
            }
            self.nodes = nodes
        }
    }

    /** The solar series at a time, interpolated (Lagrange) over the day's window of exact values. */
    private func getInterpolatedSeries(_ jde: Double) -> [Double] {
        let start = (jde - 0.5).rounded(.down) + 0.5
        lock.lock()
        var window = seriesWindows.first(where: { $0.start == start })
        lock.unlock()
        if window == nil {
            let created = SeriesWindow(start)
            lock.lock()
            seriesWindows.insert(created, at: 0)
            if seriesWindows.count > SPACalculator.INTERPOLATION_WINDOWS {
                seriesWindows.removeLast(seriesWindows.count - SPACalculator.INTERPOLATION_WINDOWS)
            }
            lock.unlock()
            window = created
        }
        let nodes = window!.nodes
        let n = SPACalculator.INTERPOLATION_NODES
        let x = (jde - start) * Double(n - 1)
        var weights = [Double](repeating: 0, count: n)
        for i in 0..<n {
            var w = 1.0
            for j in 0..<n where j != i {
                w *= (x - Double(j)) / Double(i - j)
            }
            weights[i] = w
        }
        var result = [Double](repeating: 0, count: 5)
        for c in 0..<5 {
            var sum = 0.0
            for i in 0..<n {
                sum += weights[i] * nodes[i][c]
            }
            result[c] = sum
        }
        return result
    }

    /** The largest zenith residual (degrees) at which a secant solution is accepted. */
    private static let MAX_ZENITH_RESIDUAL = 1e-4

    /** The smallest slope (degrees per minute) along the secant path below which a day is treated as grazing. */
    private static let GRAZING_MIN_SLOPE = 0.02

    /**
     * The window of UTC minutes (after 0:00 of the date) that belongs to the date: sunrise from 18:00 local mean time the day
     * before to 18:00, sunset from 06:00 to 06:00 the next day, matching AstronomicalCalendar's day resolution.
     */
    private static func getRiseSetWindowMinutes(_ longitude: Double, _ solarEvent: SolarEvent) -> [Double] {
        let startHours = (solarEvent == .sunrise ? -6.0 : 6.0) - longitude / 15.0
        return [startHours * 60.0, (startHours + 24.0) * 60.0]
    }

    /** The time tolerance of the bracketing search, in hours (1 ms). */
    private static let TIME_TOLERANCE = 1.0 / 3600.0 / 1000.0

    /** The allowance for rounding error in the bracketing search. */
    private static let ROUNDING_ERROR = 1e-8

    /**
     * The first time in the date's window at which the sun crosses the zenith in the direction of the event (rising for sunrise,
     * setting for sunset), found with a bracketing search that can't miss a crossing. Returns NaN when there is none.
     */
    private func bracketRiseSet(_ jdDay: Double, _ latitude: Double, _ longitude: Double, _ elevation: Double, _ adjustedZenith: Double,
                                _ solarEvent: SolarEvent) -> Double {
        let window = SPACalculator.getRiseSetWindowMinutes(longitude, solarEvent)
        let startHours = window[0] / 60.0
        let hours = (window[1] - window[0]) / 60.0
        let direction = solarEvent == .sunrise ? 1.0 : -1.0
        let horizon = sin(JavaMath.toRadians(90.0 - adjustedZenith))
        // Engineering estimate for |f''| in hours, as solarpositioning: daily rotation contributes about (2*pi/24)^2 * cos(latitude).
        let curvature = 0.1 * abs(cos(JavaMath.toRadians(latitude))) + 0.0001
        let f: (Double) -> Double = { t in
            direction * (sin(JavaMath.toRadians(self.topocentric(jdDay + (startHours + t) / 24.0, latitude, longitude, elevation, false)[0])) - horizon)
        }
        let search = CrossingSearch(f, curvature)
        let b = search.value(hours)
        var crossing = search.find(0.0, hours, search.value(0.0), b)
        if crossing.isNaN && b == 0.0 {
            // Include a zero endpoint only when it crosses, rather than touches, the horizon.
            if search.value(max(0.0, hours - SPACalculator.TIME_TOLERANCE)) < 0.0 && search.value(hours + SPACalculator.TIME_TOLERANCE) > 0.0 {
                crossing = hours
            }
        }
        return crossing.isNaN ? Double.nan : (startHours + crossing) * 60.0
    }

    /**
     * A search for the first rising zero of a function, which discards intervals that provably can't contain one (from a bound
     * on the function's curvature), splits the rest, and refines a bracket with the ITP method.
     */
    private struct CrossingSearch {
        let function: (Double) -> Double
        let curvature: Double

        init(_ function: @escaping (Double) -> Double, _ curvature: Double) {
            self.function = function
            self.curvature = curvature
        }

        func value(_ time: Double) -> Double {
            return function(time)
        }

        func find(_ start: Double, _ end: Double, _ a: Double, _ b: Double) -> Double {
            if a.isNaN || b.isNaN {
                // No interval of a NaN function can be discarded, so without this the search would split all the way down to
                // TIME_TOLERANCE in every branch (about 2^27 evaluations).
                return Double.nan
            }
            let width = end - start
            let slope = (b - a) / width
            let slopeError = curvature * width / 2.0 + 2.0 * SPACalculator.ROUNDING_ERROR / width
            // Standard interpolation bounds, using the conservative curvature estimate above:
            // slope error M*w/2, chord error M*w*w/8 (https://dlmf.nist.gov/3.3.E5).
            // Discard only intervals that cannot rise through zero; otherwise search left first.
            if slope + slopeError <= 0.0
                || ((a > 0.0) == (b > 0.0) && min(abs(a), abs(b)) > curvature * width * width / 8.0 + SPACalculator.ROUNDING_ERROR) {
                return Double.nan
            }
            if a < 0.0 && b >= 0.0 && slope > slopeError {
                return refine(start, end, a, b)
            }
            if width <= SPACalculator.TIME_TOLERANCE {
                return a < 0.0 && b > 0.0 ? end : Double.nan
            }
            var middle = start + width / 2.0
            var m = value(middle)
            // Keep a shallow crossing inside a bracket instead of splitting at zero.
            // Stay strictly inside the interval so both recursive searches progress.
            if m == 0.0 && (a != 0.0 || b != 0.0) {
                middle += min(SPACalculator.TIME_TOLERANCE, width / 4.0)
                m = value(middle)
            }
            let left = find(start, middle, a, m)
            return left.isNaN ? find(middle, end, m, b) : left
        }

        func refine(_ startIn: Double, _ endIn: Double, _ aIn: Double, _ bIn: Double) -> Double {
            var start = startIn, end = endIn, a = aIn, b = bIn
            // ITP (Oliveira & Takahashi): https://doi.org/10.1145/3423597.
            // Use k1 = 0.2 / initial width, k2 = 2, n0 = 1. The projection allows
            // at most one extra iteration over bisection while favouring interpolation.
            let scale = 0.2 / (end - start)
            // Maximum remaining width after a step; halve the allowance each time.
            var maxWidth = SPACalculator.TIME_TOLERANCE
            while maxWidth < end - start {
                maxWidth *= 2.0
            }
            while end - start > SPACalculator.TIME_TOLERANCE {
                let width = end - start
                let middle = start + width / 2.0
                // Equal values can occur on a rounded zero; use the midpoint then.
                let interpolated = a == b ? middle : start - a * width / (b - a)
                let towardsMiddle = middle - interpolated
                let truncated = interpolated + copysign(min(scale * width * width, abs(towardsMiddle)), towardsMiddle)
                let radius = max(0.0, maxWidth - width / 2.0)
                let trial = middle + max(-radius, min(radius, truncated - middle))
                let value = self.value(trial)
                if value > 0.0 {
                    end = trial
                    b = value
                } else {
                    start = trial
                    a = value
                }
                maxWidth /= 2.0
            }
            // Keep the later endpoint, so the next search cannot rediscover this crossing.
            return end
        }
    }

    /** @see AstronomicalCalculator/getUTCNoon(localDate:geoLocation:) */
    public override func getUTCNoon(localDate: LocalDate, geoLocation: GeoLocation) -> Double {
        let noon = solveNoonMidnight(SPACalculator.getJulianDay(localDate), -geoLocation.getLongitude(), .noon) / 60
        return JavaMath.rem(JavaMath.rem(noon, 24) + 24, 24)
    }

    /** @see AstronomicalCalculator/getUTCMidnight(localDate:geoLocation:) */
    public override func getUTCMidnight(localDate: LocalDate, geoLocation: GeoLocation) -> Double {
        let midnight = solveNoonMidnight(SPACalculator.getJulianDay(localDate), -geoLocation.getLongitude(), .midnight) / 60
        return JavaMath.rem(JavaMath.rem(midnight, 24) + 24, 24)
    }

    /** The UTC minutes after 0:00 at which the Sun's apparent hour angle is 0 (noon) or 180 (midnight). */
    private func solveNoonMidnight(_ julianDay: Double, _ lonWest: Double, _ solarEvent: SolarEvent) -> Double {
        // Rigorous meridian solve: find the UT at which the Sun's apparent hour angle equals 0 (transit / noon)
        // or 180 (anti-transit / midnight). This matches the definition used by reference ephemerides (and the
        // NREL SPA Appendix A.2 transit procedure); the previous equation-of-time formulation differed from the
        // true meridian crossing by a near-constant ~0.2 s.
        let lonEast = -lonWest
        let targetHourAngle = (solarEvent == .noon) ? 0.0 : 180.0
        var dayFraction = ((solarEvent == .noon) ? 0.5 : 1.0) - lonEast / 360.0
        for _ in 0..<3 {
            let sc = solarCoords(julianDay + dayFraction)
            let alpha = sc[0] // apparent right ascension (degrees)
            let nu = sc[3]    // apparent sidereal time at Greenwich (degrees)
            let hourAngle = JavaMath.rem(JavaMath.rem(nu + lonEast - alpha - targetHourAngle, 360) + 540, 360) - 180 // [-180, 180)
            dayFraction -= hourAngle / 360.0 // the Sun's hour angle advances 360 deg per solar day
        }
        return dayFraction * 1440.0 // UTC minutes after 0:00
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
        let julianDay = SPACalculator.getJulianDay(localDate)
        let solarNoonBase = 0.5 - (geoLocation.getLongitude() / 360.0)
        var dateTime = solarNoonBase + ((targetAzimuth == 90.0) ? 0.25 : 0.75)
        for _ in 0..<4 {
            let jd = julianDay + dateTime
            let decl = solarCoords(jd)[1]
            let ratio = Self.tanDegrees(decl) / Self.tanDegrees(geoLocation.getLatitude())
            if ratio.isNaN || ratio > 1.0 || ratio < -1.0 {
                return Double.nan
            }
            let offset = ((targetAzimuth == 90.0) ? -1.0 : 1.0) * (Self.acosDegrees(ratio) / 360.0)
            dateTime = solarNoonBase + offset - (equationOfTime(jd) / 1440.0)
        }
        let timeUTC = dateTime * 24.0
        return JavaMath.rem(JavaMath.rem(timeUTC, 24) + 24, 24)
    }

    /**
     * Return the observed (refraction-corrected) topocentric solar elevation in degrees at the given time and location. The
     * observer's elevation feeds the parallax term.
     */
    public override func getSolarElevation(date: Date, geoLocation: GeoLocation) -> Double {
        let jd = SPACalculator.julianDayFromDate(date)
        let topo = topocentric(jd, geoLocation.getLatitude(), geoLocation.getLongitude(), geoLocation.getElevation(), false)
        return topo[1] // observed (refraction-corrected) topocentric elevation
    }

    /** Return the topocentric solar azimuth in degrees, eastward from north, at the given time and location. */
    public override func getSolarAzimuth(date: Date, geoLocation: GeoLocation) -> Double {
        let jd = SPACalculator.julianDayFromDate(date)
        let topo = topocentric(jd, geoLocation.getLatitude(), geoLocation.getLongitude(), geoLocation.getElevation(), false)
        return topo[2] // topocentric azimuth, eastward from north
    }

    /**
     * The Sun's apparent geocentric coordinates: {α (right ascension), δ (declination), ε (true obliquity), ν (apparent
     * sidereal time at Greenwich), R (AU), λ (apparent longitude)}, all in degrees except R.
     */
    private func solarCoords(_ julianDayUT: Double, _ interpolate: Bool = false) -> [Double] {
        let deltaTSeconds = applyDeltaT ? (deltaTOverride ?? SPACalculator.estimateDeltaT(julianDayUT)) : 0.0
        let jde = julianDayUT + deltaTSeconds / 86400.0
        let jce = (jde - SPACalculator.JULIAN_DAY_JAN_1_2000) / SPACalculator.JULIAN_DAYS_PER_CENTURY
        let jc = (julianDayUT - SPACalculator.JULIAN_DAY_JAN_1_2000) / SPACalculator.JULIAN_DAYS_PER_CENTURY
        let jme = jce / 10.0

        let series = interpolate ? getInterpolatedSeries(jde) : SPACalculator.exactSeries(jme, jce)
        let earthL = series[0]
        let earthB = series[1]
        let radius = series[2] // AU

        let theta = JavaMath.rem(earthL + 180.0, 360.0) // geocentric longitude
        let beta = -earthB                               // geocentric latitude

        let nut = [series[3], series[4]] // {Δψ, Δε} in degrees
        let epsilon = SPACalculator.meanObliquity(jme) + nut[1]

        let aberration = -20.4898 / (3600.0 * radius) // degrees
        let lambda = theta + nut[0] + aberration      // apparent longitude

        // apparent sidereal time at Greenwich
        var nu0 = 280.46061837 + 360.98564736629 * (julianDayUT - SPACalculator.JULIAN_DAY_JAN_1_2000)
        nu0 = nu0 + 0.000387933 * jc * jc - jc * jc * jc / 38710000.0
        nu0 = JavaMath.rem(JavaMath.rem(nu0, 360) + 360, 360)
        let nu = nu0 + nut[0] * Self.cosDegrees(epsilon)

        var alpha = JavaMath.toDegrees(atan2(
            Self.sinDegrees(lambda) * Self.cosDegrees(epsilon) - Self.tanDegrees(beta) * Self.sinDegrees(epsilon),
            Self.cosDegrees(lambda)))
        alpha = JavaMath.rem(JavaMath.rem(alpha, 360) + 360, 360)
        let delta = Self.asinDegrees(Self.sinDegrees(beta) * Self.cosDegrees(epsilon)
            + Self.cosDegrees(beta) * Self.sinDegrees(epsilon) * Self.sinDegrees(lambda))

        return [alpha, delta, epsilon, nu, radius, lambda]
    }

    /**
     * Topocentric solar position: {e0 (true elevation), e (observed, refraction-corrected elevation), azimuth (eastward from
     * north)}, in degrees.
     */
    private func topocentric(_ julianDayUT: Double, _ latitude: Double, _ longitude: Double, _ elevationMeters: Double,
                             _ interpolate: Bool) -> [Double] {
        let sc = solarCoords(julianDayUT, interpolate)
        let alpha = sc[0], delta = sc[1], nu = sc[3], radius = sc[4]

        var h = JavaMath.rem(nu + longitude - alpha, 360.0) // observer local hour angle (deg), positive west
        h = JavaMath.rem(h + 360, 360)

        // equatorial horizontal parallax of the sun
        let xi = 8.794 / (3600.0 * radius) // degrees
        let u = atan(0.99664719 * Self.tanDegrees(latitude))
        let x = cos(u) + (elevationMeters / 6378140.0) * Self.cosDegrees(latitude)
        let y = 0.99664719 * sin(u) + (elevationMeters / 6378140.0) * Self.sinDegrees(latitude)

        let deltaAlpha = JavaMath.toDegrees(atan2(-x * Self.sinDegrees(xi) * Self.sinDegrees(h),
                                                  Self.cosDegrees(delta) - x * Self.sinDegrees(xi) * Self.cosDegrees(h)))
        let deltaPrime = JavaMath.toDegrees(atan2(
            (Self.sinDegrees(delta) - y * Self.sinDegrees(xi)) * Self.cosDegrees(deltaAlpha),
            Self.cosDegrees(delta) - x * Self.sinDegrees(xi) * Self.cosDegrees(h))) // topocentric declination
        let hPrime = h - deltaAlpha // topocentric local hour angle

        let e0 = Self.asinDegrees(Self.sinDegrees(latitude) * Self.sinDegrees(deltaPrime)
            + Self.cosDegrees(latitude) * Self.cosDegrees(deltaPrime) * Self.cosDegrees(hPrime)) // true (no refraction)
        let deltaE = refractionCorrection(e0) // degrees
        let e = e0 + deltaE                    // observed elevation

        let gamma = JavaMath.toDegrees(atan2(Self.sinDegrees(hPrime),
                                             Self.cosDegrees(hPrime) * Self.sinDegrees(latitude) - Self.tanDegrees(deltaPrime) * Self.cosDegrees(latitude)))
        var azimuth = JavaMath.rem(gamma + 180.0, 360.0) // eastward from north
        azimuth = JavaMath.rem(azimuth + 360, 360)

        return [e0, e, azimuth]
    }

    /** The topocentric true (un-refracted) zenith angle in degrees. */
    private func topocentricTrueZenith(_ julianDayUT: Double, _ latitude: Double, _ longitude: Double, _ elevationMeters: Double,
                                       _ interpolate: Bool) -> Double {
        return 90.0 - topocentric(julianDayUT, latitude, longitude, elevationMeters, interpolate)[0]
    }

    /**
     * The SPA (Sæmundsson) atmospheric refraction correction in degrees for a true elevation, using this calculator's pressure
     * and temperature and the parent's refraction as the horizon threshold.
     */
    private func refractionCorrection(_ trueElevation: Double) -> Double {
        let atmosRefract = getRefraction() // parent's configurable horizon refraction (degrees), default 34'
        // Fixed solar-radius constant (~16'), used only as a coarse below-horizon cutoff for refraction —
        // deliberately NOT the date-based apparent radius, since the seasonal ~16" variation is irrelevant to this gate.
        let sunRadius = getSolarRadius()
        if trueElevation < -1.0 * (sunRadius + atmosRefract) {
            return 0.0 // sun fully below the refracted horizon
        }
        return (pressure / 1010.0) * (283.0 / (273.0 + temperature))
            * 1.02 / (60.0 * Self.tanDegrees(trueElevation + 10.3 / (trueElevation + 5.11)))
    }

    /** The equation of time in minutes (apparent minus mean solar time). */
    private func equationOfTime(_ julianDayUT: Double) -> Double {
        let sc = solarCoords(julianDayUT)
        let alpha = sc[0], epsilon = sc[2]
        let deltaTSeconds = applyDeltaT ? (deltaTOverride ?? SPACalculator.estimateDeltaT(julianDayUT)) : 0.0
        let jme = ((julianDayUT + deltaTSeconds / 86400.0) - SPACalculator.JULIAN_DAY_JAN_1_2000) / SPACalculator.JULIAN_DAYS_PER_CENTURY / 10.0
        var l0 = 280.4664567 + jme * (360007.6982779 + jme * (0.03032028
            + jme * (1.0 / 49931.0 - jme * (1.0 / 15300.0 + jme / 2000000.0))))
        l0 = JavaMath.rem(JavaMath.rem(l0, 360) + 360, 360)
        let deltaPsi = SPACalculator.nutation(((julianDayUT + deltaTSeconds / 86400.0) - SPACalculator.JULIAN_DAY_JAN_1_2000)
            / SPACalculator.JULIAN_DAYS_PER_CENTURY)[0]
        var e = l0 - 0.0057183 - alpha + deltaPsi * Self.cosDegrees(epsilon) // degrees
        e = JavaMath.rem(JavaMath.rem(e + 180, 360) + 360, 360) - 180
        return e * 4.0
    }

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

    /** The Julian day (UT) of an instant. */
    private static func julianDayFromDate(_ date: Date) -> Double {
        let utc = JavaTime.utcFields(date)
        let fractionalDay = (Double(utc.hour) + (Double(utc.minute)
            + (Double(utc.second) + utc.nano / 1_000_000_000.0) / 60.0) / 60.0) / 24.0
        return getJulianDay(utc.localDate) + fractionalDay
    }

    /** The mean obliquity of the ecliptic in degrees (Reda & Andreas equation 24). */
    private static func meanObliquity(_ jme: Double) -> Double {
        let u = jme / 10.0
        var seconds = 84381.448 - 4680.93 * u - 1.55 * u * u + 1999.25 * pow(u, 3) - 51.38 * pow(u, 4)
        seconds = seconds - 249.67 * pow(u, 5) - 39.05 * pow(u, 6) + 7.12 * pow(u, 7) + 27.87 * pow(u, 8)
        seconds = seconds + 5.79 * pow(u, 9) + 2.45 * pow(u, 10)
        return seconds / 3600.0
    }

    /** The nutation in longitude and obliquity {Δψ, Δε}, in degrees. */
    private static func nutation(_ jce: Double) -> [Double] {
        var x = [Double](repeating: 0, count: NUTATION_COEFFS.count)
        for i in 0..<x.count {
            x[i] = polynomial(jce, NUTATION_COEFFS[i])
        }
        var deltaPsi = 0.0
        var deltaEpsilon = 0.0
        for i in 0..<TERMS_PE.count {
            var sum = 0.0
            for j in 0..<x.count {
                sum = sum.addingProduct(x[j], TERMS_Y[i][j]) // Math.fma(x[j], TERMS_Y[i][j], sum)
            }
            let xjYtermSum = JavaMath.toRadians(sum)
            let termsPeI = TERMS_PE[i]
            deltaPsi = deltaPsi.addingProduct(termsPeI[0].addingProduct(termsPeI[1], jce), sin(xjYtermSum))
            deltaEpsilon = deltaEpsilon.addingProduct(termsPeI[2].addingProduct(termsPeI[3], jce), cos(xjYtermSum))
        }
        return [deltaPsi / 36_000_000, deltaEpsilon / 36_000_000]
    }

    /** Evaluates a polynomial with Horner's method (fused multiply-adds), coefficients from the constant term up. */
    private static func polynomial(_ x: Double, _ coeffs: [Double]) -> Double {
        let n = coeffs.count - 1
        var sum = coeffs[n]
        var i = n - 1
        while i >= 0 {
            sum = coeffs[i].addingProduct(x, sum) // Math.fma(x, sum, coeffs[i])
            i -= 1
        }
        return sum
    }

    /**
     * Estimates ΔT (TT − UT) in seconds for a Julian day, using the Espenak-Meeus polynomials as in the solarpositioning
     * library. Beyond the year 3000, where that library declines to estimate, its last branch is extrapolated.
     */
    private static func estimateDeltaT(_ julianDay: Double) -> Double {
        let epochDay = JavaMath.toLong((julianDay - 2440587.5).rounded(.down))
        if epochDay < -365243219162 || epochDay > 365241780471 {
            // outside the years -999,999,999 to 999,999,999 that java.time supports (KosherJava throws a DateTimeException)
            return Double.nan
        }
        let date = LocalDate(epochDay: Int(epochDay))
        return estimateDeltaTForYear(Double(date.year) + (Double(date.month) - 0.5) / 12)
    }

    /** Estimates ΔT for a decimal year, using the same branches and coefficients as solarpositioning 3.0. */
    private static func estimateDeltaTForYear(_ year: Double) -> Double {
        if year < -500 {
            let u = (year - 1820) / 100.0
            return polynomial(u, [-20, 0, 32])
        } else if year < 500 {
            let u = year / 100.0
            return polynomial(u, [10583.6, -1014.41, 33.78311, -5.952053, -0.1798452, 0.022174192, 0.0090316521])
        } else if year < 1600 {
            let u = (year - 1000) / 100.0
            return polynomial(u, [1574.2, -556.01, 71.23472, 0.319781, -0.8503463, -0.005050998, 0.0083572073])
        } else if year < 1700 {
            let t = year - 1600
            return polynomial(t, [120, -0.9808, -0.01532, 1.0 / 7129])
        } else if year < 1800 {
            let t = year - 1700
            return polynomial(t, [8.83, 0.1603, -0.0059285, 0.00013336, -1.0 / 1174000])
        } else if year < 1860 {
            let t = year - 1800
            return polynomial(t, [13.72, -0.332447, 0.0068612, 0.0041116, -0.00037436, 0.0000121272, -0.0000001699, 0.000000000875])
        } else if year < 1900 {
            let t = year - 1860
            return polynomial(t, [7.62, 0.5737, -0.251754, 0.01680668, -0.0004473624, 1.0 / 233174])
        } else if year < 1920 {
            let t = year - 1900
            return polynomial(t, [-2.79, 1.494119, -0.0598939, 0.0061966, -0.000197])
        } else if year < 1941 {
            let t = year - 1920
            return polynomial(t, [21.20, 0.84493, -0.076100, 0.0020936])
        } else if year < 1961 {
            let t = year - 1950
            return polynomial(t, [29.07, 0.407, -1.0 / 233, 1.0 / 2547])
        } else if year < 1986 {
            let t = year - 1975
            return polynomial(t, [45.45, 1.067, -1.0 / 260, -1.0 / 718])
        } else if year < 2005 {
            let t = year - 2000
            return polynomial(t, [63.86, 0.3345, -0.060374, 0.0017275, 0.000651814, 0.00002373599])
        } else if year < 2015 {
            let t = year - 2005
            return polynomial(t, [64.69, 0.2930])
        } else if year < 2026.5 {
            let t = year - 2015
            // Retain full precision; the branches join in value and slope at 2015 and 2026.5.
            return polynomial(t, [67.62, 0.2930, 0.08753166427153103, -0.020049795884351372, 0.0009758496126416308])
        } else {
            let t = year - 2026.5
            return polynomial(t, [69.14, 0.28805287963416737, 0.0057380400318460655]) // beyond 3000 this branch is extrapolated
        }
    }

    /**
     * Evaluate a VSOP87 series Σn (Σi Ai·cos(Bi + Ci·τ)) · τ^n with coefficients in 1e-8 of the native unit (radians or AU).
     * @param series indexed `[n][term][{A,B,C}]`.
     * @param tau time in Julian millennia from J2000.0 (JME).
     * @return the evaluated quantity (radians or AU).
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

    /** Equal if the calculator settings, including ΔT, pressure and temperature, are equal. */
    public override func equals(_ other: AstronomicalCalculator) -> Bool {
        guard super.equals(other), let other = other as? SPACalculator else {
            return false
        }
        return applyDeltaT == other.applyDeltaT && deltaTOverride == other.deltaTOverride
            && pressure == other.pressure && temperature == other.temperature
    }

    override func copyState(to copy: AstronomicalCalculator) {
        super.copyState(to: copy)
        if let copy = copy as? SPACalculator {
            copy.applyDeltaT = applyDeltaT
            copy.deltaTOverride = deltaTOverride
            copy.pressure = pressure
            copy.temperature = temperature
        }
    }

    // ---------------------------------------------------------------------------------------------------------------
    // Nutation and abridged VSOP87 Earth series (Meeus Appendix III). {A, B, C}; value Σ A·cos(B + C·τ), τ in Julian
    // millennia, result in 1e-8 rad (L, B) or 1e-8 AU (R). Validated to ~0.1" against Meeus's worked example.
    // ---------------------------------------------------------------------------------------------------------------

    /** Polynomial coefficients of the nutation arguments X0 - X4 (Reda &amp; Andreas, equations 15 - 19). */
    private static let NUTATION_COEFFS: [[Double]] = [
        [297.85036, 445267.111480, -0.0019142, 1.0 / 189474],
        [357.52772, 35999.050340, -0.0001603, -1.0 / 300000],
        [134.96298, 477198.867398, 0.0086972, 1.0 / 56250],
        [93.27191, 483202.017538, -0.0036825, 1.0 / 327270],
        [125.04452, -1934.136261, 0.0020708, 1.0 / 450000]
    ]

    /** Multipliers of X0 - X4 for each of the 63 nutation terms (Reda &amp; Andreas, Table A4.3). */
    private static let TERMS_Y: [[Double]] = [
        [0, 0, 0, 0, 1],
        [-2, 0, 0, 2, 2],
        [0, 0, 0, 2, 2],
        [0, 0, 0, 0, 2],
        [0, 1, 0, 0, 0],
        [0, 0, 1, 0, 0],
        [-2, 1, 0, 2, 2],
        [0, 0, 0, 2, 1],
        [0, 0, 1, 2, 2],
        [-2, -1, 0, 2, 2],
        [-2, 0, 1, 0, 0],
        [-2, 0, 0, 2, 1],
        [0, 0, -1, 2, 2],
        [2, 0, 0, 0, 0],
        [0, 0, 1, 0, 1],
        [2, 0, -1, 2, 2],
        [0, 0, -1, 0, 1],
        [0, 0, 1, 2, 1],
        [-2, 0, 2, 0, 0],
        [0, 0, -2, 2, 1],
        [2, 0, 0, 2, 2],
        [0, 0, 2, 2, 2],
        [0, 0, 2, 0, 0],
        [-2, 0, 1, 2, 2],
        [0, 0, 0, 2, 0],
        [-2, 0, 0, 2, 0],
        [0, 0, -1, 2, 1],
        [0, 2, 0, 0, 0],
        [2, 0, -1, 0, 1],
        [-2, 2, 0, 2, 2],
        [0, 1, 0, 0, 1],
        [-2, 0, 1, 0, 1],
        [0, -1, 0, 0, 1],
        [0, 0, 2, -2, 0],
        [2, 0, -1, 2, 1],
        [2, 0, 1, 2, 2],
        [0, 1, 0, 2, 2],
        [-2, 1, 1, 0, 0],
        [0, -1, 0, 2, 2],
        [2, 0, 0, 2, 1],
        [2, 0, 1, 0, 0],
        [-2, 0, 2, 2, 2],
        [-2, 0, 1, 2, 1],
        [2, 0, -2, 0, 1],
        [2, 0, 0, 0, 1],
        [0, -1, 1, 0, 0],
        [-2, -1, 0, 2, 1],
        [-2, 0, 0, 0, 1],
        [0, 0, 2, 2, 1],
        [-2, 0, 2, 0, 1],
        [-2, 1, 0, 2, 1],
        [0, 0, 1, -2, 0],
        [-1, 0, 1, 0, 0],
        [-2, 1, 0, 0, 0],
        [1, 0, 0, 0, 0],
        [0, 0, 1, 2, 0],
        [0, 0, -2, 2, 2],
        [-1, -1, 1, 0, 0],
        [0, 1, 1, 0, 0],
        [0, -1, 1, 2, 2],
        [2, -1, -1, 2, 2],
        [0, 0, 3, 2, 2],
        [2, -1, 0, 2, 2]
    ]

    /** The a, b, c, d coefficients of &Delta;&psi; and &Delta;&epsilon; for each of the 63 nutation terms (Reda &amp; Andreas, Table A4.3). */
    private static let TERMS_PE: [[Double]] = [
        [-171996, -174.2, 92025, 8.9],
        [-13187, -1.6, 5736, -3.1],
        [-2274, -0.2, 977, -0.5],
        [2062, 0.2, -895, 0.5],
        [1426, -3.4, 54, -0.1],
        [712, 0.1, -7, 0],
        [-517, 1.2, 224, -0.6],
        [-386, -0.4, 200, 0],
        [-301, 0, 129, -0.1],
        [217, -0.5, -95, 0.3],
        [-158, 0, 0, 0],
        [129, 0.1, -70, 0],
        [123, 0, -53, 0],
        [63, 0, 0, 0],
        [63, 0.1, -33, 0],
        [-59, 0, 26, 0],
        [-58, -0.1, 32, 0],
        [-51, 0, 27, 0],
        [48, 0, 0, 0],
        [46, 0, -24, 0],
        [-38, 0, 16, 0],
        [-31, 0, 13, 0],
        [29, 0, 0, 0],
        [29, 0, -12, 0],
        [26, 0, 0, 0],
        [-22, 0, 0, 0],
        [21, 0, -10, 0],
        [17, -0.1, 0, 0],
        [16, 0, -8, 0],
        [-16, 0.1, 7, 0],
        [-15, 0, 9, 0],
        [-13, 0, 7, 0],
        [-12, 0, 6, 0],
        [11, 0, 0, 0],
        [-10, 0, 5, 0],
        [-8, 0, 3, 0],
        [7, 0, -3, 0],
        [-7, 0, 0, 0],
        [-7, 0, 3, 0],
        [-7, 0, 3, 0],
        [6, 0, 0, 0],
        [6, 0, -3, 0],
        [6, 0, -3, 0],
        [-6, 0, 3, 0],
        [-6, 0, 3, 0],
        [5, 0, 0, 0],
        [-5, 0, 3, 0],
        [-5, 0, 3, 0],
        [-5, 0, 3, 0],
        [4, 0, 0, 0],
        [4, 0, 0, 0],
        [4, 0, 0, 0],
        [-4, 0, 0, 0],
        [-4, 0, 0, 0],
        [-4, 0, 0, 0],
        [3, 0, 0, 0],
        [-3, 0, 0, 0],
        [-3, 0, 0, 0],
        [-3, 0, 0, 0],
        [-3, 0, 0, 0],
        [-3, 0, 0, 0],
        [-3, 0, 0, 0],
        [-3, 0, 0, 0]
    ]

    /** Earth heliocentric longitude series L0..L5. */
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
