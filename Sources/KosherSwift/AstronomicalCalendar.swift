//
//  AstronomicalCalendar.swift
//  KosherSwift
//
//  Created by Elyahu Jacobi on 12/21/23.
//

import Foundation

/**
 * A Swift calendar that calculates astronomical times such as ``getSunrise()`` sunrise, ``getSunset()`` sunset and
 * twilight times. This class contains a ``LocalDate`` (see ``getLocalDate()``) that sets the day being calculated. The
 * calculation engine used to calculate the astronomical times can be changed to a different implementation by subclassing
 * ``AstronomicalCalculator`` and setting it with ``setAstronomicalCalculator(astronomicalCalculator:)``. A number of
 * different calculation engine implementations are included in the util package.
 *
 * <b>Note:</b> There are times when the algorithms can't calculate proper values for sunrise, sunset and twilight. This
 * is usually caused by trying to calculate times for areas either very far North or South, where sunrise / sunset never
 * happen on that date. This is common when calculating deep twilight angles at high northern latitudes, such as London.
 * The sun never reaches this dip at certain times of the year. When the calculations encounter this condition a `nil`
 * will be returned when a `Date` or a `TimeInterval` duration is expected. The reason that errors are not thrown in these
 * cases is because the lack of a rise/set or twilight is not an exception, but an expected condition in many parts of the
 * world.
 *
 * Here is a simple example of how to use the API to calculate sunrise. First create the AstronomicalCalendar for the
 * location you would like to calculate sunrise or sunset times for:
 *
 * ```
 * let location = GeoLocation(locationName: "Lakewood, NJ", latitude: 40.0828, longitude: -74.2094, elevation: 20,
 *                            timeZone: TimeZone(identifier: "America/New_York")!)
 * let ac = AstronomicalCalendar(geoLocation: location)
 * ```
 *
 * To get the time of sunrise, first set the date you want (if not set, the date will default to today):
 *
 * ```
 * ac.setLocalDate(localDate: LocalDate(year: 1969, month: 2, day: 8))
 * let sunrise = ac.getSunrise()
 * ```
 *
 * Setting ``workingDate`` to a `Date` also works: the calendar uses the date it falls on in the location's time zone.
 *
 * @author &copy; Eliyahu Hershfeld 2004 - 2026
 */
public class AstronomicalCalendar {

    /**
     * 90&deg; below the vertical. Used as a basis for most calculations since the location of the sun is 90&deg; below
     * the horizon at sunrise and sunset.
     * <b>Note </b>: it is important to note that for sunrise and sunset the adjusted zenith (see
     * ``AstronomicalCalculator``) is required to account for the radius of the sun and refraction. The adjusted zenith
     * should not be used for calculations above or below 90&deg; since they are usually calculated as an offset to 90&deg;.
     */
    public static let GEOMETRIC_ZENITH = 90.0

    /** Sun's zenith at civil twilight (96&deg;). */
    public static let CIVIL_ZENITH = 96.0

    /** Sun's zenith at nautical twilight (102&deg;). */
    public static let NAUTICAL_ZENITH = 102.0

    /** Sun's zenith at astronomical twilight (108&deg;). */
    public static let ASTRONOMICAL_ZENITH = 108.0

    /** constant for nanoseconds in a minute (60,000,000,000) */
    public static let MINUTE_NANOS: Int64 = 60_000_000_000

    /** constant for nanoseconds in an hour (3,600,000,000,000) */
    public static let HOUR_NANOS: Int64 = 3_600_000_000_000

    /** constant for seconds in a minute (60) */
    public static let MINUTE_SECONDS: TimeInterval = 60

    /** constant for seconds in an hour (3,600) */
    public static let HOUR_SECONDS: TimeInterval = 3600

    /** The ``LocalDate`` encapsulated by this class to track the current date used by the class. */
    private var localDate: LocalDate

    /** the ``GeoLocation`` used for calculations. */
    public var geoLocation: GeoLocation

    /** the internal ``AstronomicalCalculator`` used for calculating solar based times. */
    public var astronomicalCalculator: AstronomicalCalculator

    /**
     * A `Date` on the day being calculated. Setting it sets the date (see ``setLocalDate(localDate:)``) to the day it
     * falls on in the location's time zone; reading it returns noon of the calculation date in the location's time zone.
     * Only the day matters: the time of day of a `Date` that is set is ignored.
     */
    public var workingDate: Date {
        get {
            return localDate.atTime(seconds: 12 * 3600, timeZone: geoLocation.getTimeZone())
        }
        set {
            localDate = LocalDate(date: newValue, timeZone: geoLocation.getTimeZone())
        }
    }

    /**
     * The getSunrise method returns a `Date` representing the elevation adjusted sunrise time (see
     * ``AstronomicalCalculator/getElevationAdjustment(elevation:)``). The zenith used for the calculation uses the
     * ``GEOMETRIC_ZENITH`` of 90&deg; plus the elevation adjustment. This is adjusted by the ``AstronomicalCalculator`` to
     * add approximately 50/60 of a degree to account for 34 arcminutes of refraction and 16 arcminutes for the sun's radius
     * for a total of 90.83333&deg;. See documentation for the specific implementation of the ``AstronomicalCalculator``
     * that you are using.
     *
     * @return the `Date` representing the exact sunrise time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year where the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the page.
     * @see getSeaLevelSunrise()
     */
    public func getSunrise() -> Date? {
        let sunrise = getUTCSunrise(zenith: AstronomicalCalendar.GEOMETRIC_ZENITH)
        if sunrise.isNaN {
            return nil
        }
        return getDateFromTime(time: sunrise, solarEvent: .sunrise)
    }

    /**
     * A method that returns the sunrise without ``AstronomicalCalculator/getElevationAdjustment(elevation:)`` elevation
     * adjustment. Non-sunrise and sunset calculations such as dawn and dusk, depend on the amount of visible light,
     * something that is not affected by elevation. This method returns sunrise calculated at sea level. This forms the
     * base for dawn calculations that are calculated as a dip below the horizon before sunrise.
     *
     * @return the `Date` representing the exact sea-level sunrise time. If the calculation can't be computed such as in
     *         the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
     *         not set, a `nil` will be returned. See detailed explanation on top of the page.
     * @see getSunrise()
     * @see getUTCSeaLevelSunrise(zenith:)
     * @see getSeaLevelSunset()
     */
    public func getSeaLevelSunrise() -> Date? {
        let sunrise = getUTCSeaLevelSunrise(zenith: AstronomicalCalendar.GEOMETRIC_ZENITH)
        if sunrise.isNaN {
            return nil
        }
        return getDateFromTime(time: sunrise, solarEvent: .sunrise)
    }

    /**
     * A method that returns the beginning of <a href="https://en.wikipedia.org/wiki/Twilight#Civil_twilight">civil
     * twilight</a> (dawn) using a zenith of ``CIVIL_ZENITH`` 96&deg;.
     *
     * @return The `Date` of the beginning of civil twilight using a zenith of 96&deg;. If the calculation can't be
     *         computed, `nil` will be returned. See detailed explanation on top of the page.
     */
    public func getBeginCivilTwilight() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: AstronomicalCalendar.CIVIL_ZENITH)
    }

    /**
     * A method that returns the beginning of <a href="https://en.wikipedia.org/wiki/Twilight#Nautical_twilight">nautical
     * twilight</a> using a zenith of ``NAUTICAL_ZENITH`` 102&deg;.
     *
     * @return The `Date` of the beginning of nautical twilight using a zenith of 102&deg;. If the calculation can't be
     *         computed `nil` will be returned. See detailed explanation on top of the page.
     */
    public func getBeginNauticalTwilight() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: AstronomicalCalendar.NAUTICAL_ZENITH)
    }

    /**
     * A method that returns the beginning of <a href="https://en.wikipedia.org/wiki/Twilight#Astronomical_twilight">
     * astronomical twilight</a> using a zenith of ``ASTRONOMICAL_ZENITH`` 108&deg;.
     *
     * @return The `Date` of the beginning of astronomical twilight using a zenith of 108&deg;. If the calculation can't be
     *         computed, `nil` will be returned. See detailed explanation on top of the page.
     */
    public func getBeginAstronomicalTwilight() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: AstronomicalCalendar.ASTRONOMICAL_ZENITH)
    }

    /**
     * The getSunset method returns a `Date` representing the elevation adjusted sunset time (see
     * ``AstronomicalCalculator/getElevationAdjustment(elevation:)``). The zenith used for the calculation uses the
     * ``GEOMETRIC_ZENITH`` of 90&deg; plus the elevation adjustment. This is adjusted by the ``AstronomicalCalculator`` to
     * add approximately 50/60 of a degree to account for 34 arcminutes of refraction and 16 arcminutes for the sun's radius
     * for a total of 90.83333&deg;. See documentation for the specific implementation of the ``AstronomicalCalculator``
     * that you are using. Note: In certain cases the calculated sunset will occur before sunrise. This will typically
     * happen when a timezone other than the local timezone is used (calculating Los Angeles sunset using a GMT timezone
     * for example). In this case the sunset date will be incremented to the following date.
     *
     * @return the `Date` representing the exact sunset time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year where the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the page.
     * @see getSeaLevelSunset()
     */
    public func getSunset() -> Date? {
        let sunset = getUTCSunset(zenith: AstronomicalCalendar.GEOMETRIC_ZENITH)
        if sunset.isNaN {
            return nil
        }
        return getDateFromTime(time: sunset, solarEvent: .sunset)
    }

    /**
     * A method that returns the sunset without ``AstronomicalCalculator/getElevationAdjustment(elevation:)`` elevation
     * adjustment. Non-sunrise and sunset calculations such as dawn and dusk, depend on the amount of visible light,
     * something that is not affected by elevation. This method returns sunset calculated at sea level. This forms the
     * base for dusk calculations that are calculated as a dip below the horizon after sunset.
     *
     * @return the `Date` representing the exact sea-level sunset time. If the calculation can't be computed such as in
     *         the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
     *         not set, a `nil` will be returned. See detailed explanation on top of the page.
     * @see getSunset()
     * @see getUTCSeaLevelSunset(zenith:)
     */
    public func getSeaLevelSunset() -> Date? {
        let sunset = getUTCSeaLevelSunset(zenith: AstronomicalCalendar.GEOMETRIC_ZENITH)
        if sunset.isNaN {
            return nil
        }
        return getDateFromTime(time: sunset, solarEvent: .sunset)
    }

    /**
     * A method that returns the end of <a href="https://en.wikipedia.org/wiki/Twilight#Civil_twilight">civil twilight</a>
     * using a zenith of ``CIVIL_ZENITH`` 96&deg;.
     *
     * @return The `Date` of the end of civil twilight using a zenith of 96&deg;. If the calculation can't be computed,
     *         `nil` will be returned. See detailed explanation on top of the page.
     */
    public func getEndCivilTwilight() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: AstronomicalCalendar.CIVIL_ZENITH)
    }

    /**
     * A method that returns the end of nautical twilight using a zenith of ``NAUTICAL_ZENITH`` 102&deg;.
     *
     * @return The `Date` of the end of nautical twilight using a zenith of 102&deg;. If the calculation can't be
     *         computed, `nil` will be returned. See detailed explanation on top of the page.
     */
    public func getEndNauticalTwilight() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: AstronomicalCalendar.NAUTICAL_ZENITH)
    }

    /**
     * A method that returns the end of astronomical twilight using a zenith of ``ASTRONOMICAL_ZENITH`` 108&deg;.
     *
     * @return the `Date` of the end of astronomical twilight using a zenith of 108&deg;. If the calculation can't be
     *         computed, `nil` will be returned. See detailed explanation on top of the page.
     */
    public func getEndAstronomicalTwilight() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: AstronomicalCalendar.ASTRONOMICAL_ZENITH)
    }

    /**
     * A utility method that returns a date offset by the offset time passed in. Please note that the level of light
     * during twilight is not affected by elevation, so if this is being used to calculate an offset before sunrise or
     * after sunset with the intent of getting a rough "level of light" calculation, the sunrise or sunset time passed to
     * this method should be sea level sunrise and sunset.
     *
     * @param time the start time
     * @param offset the offset in seconds to add to the time (negative for an earlier time)
     * @return the `Date` with the offset added to it, or `nil` if either the time or the offset is `nil` (or the offset
     *         is NaN or infinite)
     */
    public static func getTimeOffset(time: Date?, offset: TimeInterval?) -> Date? {
        guard let time = time, let offset = offset, offset.isFinite else {
            return nil
        }
        return time.addingTimeInterval(offset)
    }

    /**
     * A utility method that returns the time of an offset by degrees below or above the horizon of ``getSunrise()``
     * sunrise. Note that the degree offset is from the vertical, so for a calculation of 14&deg; before sunrise, an offset
     * of 14 + ``GEOMETRIC_ZENITH`` = 104 would have to be passed as a parameter.
     *
     * @param offsetZenith the degrees before ``getSunrise()`` to use in the calculation. For time after sunrise use
     *            negative numbers. Note that the degree offset is from the vertical, so for a calculation of 14&deg;
     *            before sunrise, an offset of 14 + ``GEOMETRIC_ZENITH`` = 104 would have to be passed as a parameter.
     * @return The `Date` of the offset after (or before) ``getSunrise()``. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a `nil` will be returned. See detailed explanation on top of the page.
     */
    public func getSunriseOffsetByDegrees(offsetZenith: Double) -> Date? {
        let dawn = getUTCSunrise(zenith: offsetZenith)
        return dawn.isNaN ? nil : getDateFromTime(time: dawn, solarEvent: .sunrise)
    }

    /**
     * A utility method that returns the time of an offset by degrees below or above the horizon of ``getSunset()``
     * sunset. Note that the degree offset is from the vertical, so for a calculation of 14&deg; after sunset, an offset of
     * 14 + ``GEOMETRIC_ZENITH`` = 104 would have to be passed as a parameter.
     *
     * @param offsetZenith the degrees after ``getSunset()`` to use in the calculation. For time before sunset use negative
     *            numbers. Note that the degree offset is from the vertical, so for a calculation of 14&deg; after sunset,
     *            an offset of 14 + ``GEOMETRIC_ZENITH`` = 104 would have to be passed as a parameter.
     * @return The `Date` of the offset after (or before) ``getSunset()``. If the calculation can't be computed such as in
     *         the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
     *         not set, a `nil` will be returned. See detailed explanation on top of the page.
     */
    public func getSunsetOffsetByDegrees(offsetZenith: Double) -> Date? {
        let sunset = getUTCSunset(zenith: offsetZenith)
        return sunset.isNaN ? nil : getDateFromTime(time: sunset, solarEvent: .sunset)
    }

    /**
     * The default constructor will set a default ``GeoLocation`` (Greenwich), a default ``AstronomicalCalculator``
     * (the ``NOAACalculator``), and default the date to today in the location's time zone.
     */
    public convenience init() {
        self.init(geoLocation: GeoLocation())
    }

    /**
     * A constructor that takes in <a href="https://en.wikipedia.org/wiki/Geolocation">geolocation</a> information as a
     * parameter. The default ``AstronomicalCalculator`` used for solar calculations is the ``NOAACalculator``, and the
     * date defaults to today in the location's time zone.
     *
     * @param geoLocation The location information used for calculating astronomical sun times.
     * @see setAstronomicalCalculator(astronomicalCalculator:) for changing the calculator class.
     */
    public required init(geoLocation: GeoLocation) {
        self.localDate = LocalDate.now(timeZone: geoLocation.getTimeZone())
        self.geoLocation = geoLocation
        self.astronomicalCalculator = AstronomicalCalculator.getDefault()
    }

    /**
     * A method that returns the sunrise in UTC time without correction for time zone offset from GMT and without using
     * daylight savings time.
     *
     * @param zenith the degrees below the horizon. For time after sunrise use negative numbers.
     * @return The time in the format: 18.75 for 18:45:00 UTC/GMT. If the calculation can't be computed such as in the
     *         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does not
     *         set, `Double.nan` will be returned. See detailed explanation on top of the page.
     */
    public func getUTCSunrise(zenith: Double) -> Double {
        return getAstronomicalCalculator().getCachedUTCSunrise(localDate: getAdjustedLocalDate(), geoLocation: getGeoLocation(),
                                                               zenith: zenith, adjustForElevation: true)
    }

    /**
     * A method that returns the sunrise in UTC time without correction for time zone offset from GMT and without using
     * daylight savings time. Non-sunrise and sunset calculations such as dawn and dusk, depend on the amount of visible
     * light, something that is not affected by elevation. This method returns UTC sunrise calculated at sea level. This
     * forms the base for dawn calculations that are calculated as a dip below the horizon before sunrise.
     *
     * @param zenith the degrees below the horizon. For time after sunrise use negative numbers.
     * @return The time in the format: 18.75 for 18:45:00 UTC/GMT. If the calculation can't be computed, `Double.nan`
     *         will be returned. See detailed explanation on top of the page.
     * @see getUTCSunrise(zenith:)
     * @see getUTCSeaLevelSunset(zenith:)
     */
    public func getUTCSeaLevelSunrise(zenith: Double) -> Double {
        return getAstronomicalCalculator().getCachedUTCSunrise(localDate: getAdjustedLocalDate(), geoLocation: getGeoLocation(),
                                                               zenith: zenith, adjustForElevation: false)
    }

    /**
     * A method that returns the sunset in UTC time without correction for time zone offset from GMT and without using
     * daylight savings time.
     *
     * @param zenith the degrees below the horizon. For time after sunset use negative numbers.
     * @return The time in the format: 18.75 for 18:45:00 UTC/GMT. If the calculation can't be computed, `Double.nan`
     *         will be returned. See detailed explanation on top of the page.
     * @see getUTCSeaLevelSunset(zenith:)
     */
    public func getUTCSunset(zenith: Double) -> Double {
        return getAstronomicalCalculator().getCachedUTCSunset(localDate: getAdjustedLocalDate(), geoLocation: getGeoLocation(),
                                                              zenith: zenith, adjustForElevation: true)
    }

    /**
     * A method that returns the sunset in UTC time without correction for elevation, time zone offset from GMT and without
     * using daylight savings time. Non-sunrise and sunset calculations such as dawn and dusk, depend on the amount of
     * visible light, something that is not affected by elevation. This method returns UTC sunset calculated at sea level.
     * This forms the base for dusk calculations that are calculated as a dip below the horizon after sunset.
     *
     * @param zenith the degrees below the horizon. For time before sunset use negative numbers.
     * @return The time in the format: 18.75 for 18:45:00 UTC/GMT. If the calculation can't be computed, `Double.nan`
     *         will be returned. See detailed explanation on top of the page.
     * @see getUTCSunset(zenith:)
     * @see getUTCSeaLevelSunrise(zenith:)
     */
    public func getUTCSeaLevelSunset(zenith: Double) -> Double {
        return getAstronomicalCalculator().getCachedUTCSunset(localDate: getAdjustedLocalDate(), geoLocation: getGeoLocation(),
                                                              zenith: zenith, adjustForElevation: false)
    }

    /**
     * A method that returns a sea-level based temporal (solar) hour. The day from ``getSeaLevelSunrise()`` sea-level
     * sunrise to ``getSeaLevelSunset()`` sea-level sunset is split into 12 equal parts with each one being a temporal
     * hour.
     *
     * @see getSeaLevelSunrise()
     * @see getSeaLevelSunset()
     * @see getTemporalHour(startOfDay:endOfDay:)
     *
     * @return the length of a temporal hour in seconds. If the calculation can't be computed, `nil` will be returned. See
     *         detailed explanation on top of the page.
     */
    public func getTemporalHour() -> TimeInterval? {
        return getTemporalHour(startOfDay: getSeaLevelSunrise(), endOfDay: getSeaLevelSunset())
    }

    /**
     * A utility method that will allow the calculation of a temporal (solar) hour based on the sunrise and sunset passed
     * as parameters to this method. An example of the use of this method would be the calculation of a elevation adjusted
     * temporal hour by passing in ``getSunrise()`` sunrise and ``getSunset()`` sunset as parameters.
     *
     * @param startOfDay The start of the day.
     * @param endOfDay The end of the day.
     * @return the length of the temporal hour in seconds. If the calculation can't be computed `nil` will be returned.
     *         See detailed explanation on top of the page.
     * @see getTemporalHour()
     */
    public func getTemporalHour(startOfDay: Date?, endOfDay: Date?) -> TimeInterval? {
        guard let startOfDay = startOfDay, let endOfDay = endOfDay else {
            return nil
        }
        return endOfDay.timeIntervalSince(startOfDay) / 12
    }

    /**
     * A method that returns <a href="https://en.wikipedia.org/wiki/Transit_(astronomy)">sundial or solar noon</a>. It
     * occurs when the Sun is <a href="https://en.wikipedia.org/wiki/Transit_%28astronomy%29">transiting</a> the
     * <a href="https://en.wikipedia.org/wiki/Meridian_%28astronomy%29">celestial meridian</a>. The calculations used by
     * this class depend on the ``AstronomicalCalculator`` used. If this calendar instance is set to use the
     * ``NOAACalculator`` (the default) it will calculate astronomical noon. If the calendar instance is to use the
     * ``SunTimesCalculator``, that does not have code to calculate astronomical noon, the sun transit is calculated as
     * halfway between sea level sunrise and sea level sunset, which can be slightly off the real transit time due to
     * changes in declination (the lengthening or shortening day). See
     * <a href="https://kosherjava.com/2020/07/02/definition-of-chatzos/">The Definition of Chatzos</a> for details on the
     * proper definition of solar noon / midday.
     *
     * @return the `Date` representing Sun's transit. If the calculation can't be computed such as when using the
     *         ``SunTimesCalculator`` in the Arctic Circle where there is at least one day a year where the sun does not
     *         rise, and one where it does not set, `nil` will be returned. See detailed explanation on top of the page.
     * @see getSunTransit(startOfDay:endOfDay:)
     * @see getTemporalHour()
     * @see NOAACalculator/getUTCNoon(localDate:geoLocation:)
     * @see SunTimesCalculator/getUTCNoon(localDate:geoLocation:)
     */
    public func getSunTransit() -> Date? {
        let noon = getAstronomicalCalculator().getCachedUTCNoon(localDate: getAdjustedLocalDate(), geoLocation: getGeoLocation())
        return getDateFromTime(time: noon, solarEvent: .noon)
    }

    /**
     * A method that returns solar midnight at the end of the current day (that may actually be after midnight of the day
     * it is being calculated for). It occurs when the Sun is
     * <a href="https://en.wikipedia.org/wiki/Transit_%28astronomy%29">transiting</a> the lower
     * <a href="https://en.wikipedia.org/wiki/Meridian_%28astronomy%29">celestial meridian</a>, or when the sun is at its
     * <a href="https://en.wikipedia.org/wiki/Nadir">nadir</a>. The calculations used by this class depend on the
     * ``AstronomicalCalculator`` used. If this calendar instance is set to use the ``NOAACalculator`` (the default) it
     * will calculate astronomical midnight. If the calendar instance is to use the ``SunTimesCalculator``, that does not
     * have code to calculate astronomical noon, midnight is calculated as 12 hours after halfway between sea level sunrise
     * and sea level sunset of that day. This can be slightly off the real transit time due to changes in declination (the
     * lengthening or shortening day). See <a href="https://kosherjava.com/2020/07/02/definition-of-chatzos/">The
     * Definition of Chatzos</a> for details on the proper definition of solar noon / midday.
     *
     * @return the `Date` representing Sun's lower transit at the end of the current day. If the calculation can't be
     *         computed such as when using the ``SunTimesCalculator`` in the Arctic Circle where there is at least one day
     *         a year where the sun does not rise, and one where it does not set, `nil` will be returned. See detailed
     *         explanation on top of the page.
     * @see getSunTransit()
     * @see NOAACalculator/getUTCMidnight(localDate:geoLocation:)
     * @see SunTimesCalculator/getUTCMidnight(localDate:geoLocation:)
     */
    public func getSolarMidnight() -> Date? {
        let midnight = getAstronomicalCalculator().getCachedUTCMidnight(localDate: getAdjustedLocalDate(), geoLocation: getGeoLocation())
        return getDateFromTime(time: midnight, solarEvent: .midnight)
    }

    /**
     * A method that returns sundial or solar noon. It occurs when the Sun is
     * <a href="https://en.wikipedia.org/wiki/Transit_%28astronomy%29">transiting</a> the
     * <a href="https://en.wikipedia.org/wiki/Meridian_%28astronomy%29">celestial meridian</a>. In this class it is
     * calculated as halfway between the sunrise and sunset passed to this method. This time can be slightly off the real
     * transit time due to changes in declination (the lengthening or shortening day).
     *
     * @param startOfDay the start of day for calculating the sun's transit. This can be sea level sunrise, visual sunrise
     *            (or any arbitrary start of day) passed to this method.
     * @param endOfDay the end of day for calculating the sun's transit. This can be sea level sunset, visual sunset (or any
     *            arbitrary end of day) passed to this method.
     *
     * @return the `Date` representing Sun's transit. If the calculation can't be computed such as in the Arctic Circle
     *         where there is at least one day a year where the sun does not rise, and one where it does not set, `nil`
     *         will be returned. See detailed explanation on top of the page.
     */
    public func getSunTransit(startOfDay: Date?, endOfDay: Date?) -> Date? {
        guard let temporalHour = getTemporalHour(startOfDay: startOfDay, endOfDay: endOfDay) else {
            return nil
        }
        return AstronomicalCalendar.getTimeOffset(time: startOfDay, offset: temporalHour * 6)
    }

    /**
     * An enum to indicate what type of solar event is being calculated, used to resolve which day a UTC time of day
     * belongs to.
     */
    public enum SolarEvent {
        /** SUNRISE A solar event related to sunrise */
        case sunrise
        /** SUNSET A solar event related to sunset */
        case sunset
        /** NOON A solar event related to noon */
        case noon
        /** MIDNIGHT A solar event related to midnight */
        case midnight
    }

    /**
     * Returns the time that the sun is due east (an azimuth of 90&deg;) or due west (270&deg;) on the calendar's date.
     * This is useful for a <a href="https://en.wikipedia.org/wiki/Bein_hashmashos">bein hashmashos</a> calculation or
     * the time of <em>Hanetz</em> as it rises over the eastern horizon.
     *
     * @param azimuth the azimuth of the sun, either 90 or 270. Other values are not supported.
     * @return the `Date` that the sun is at the azimuth, or `nil` when it never is on this date, such as in the
     *         tropics when the sun's declination is greater than the latitude.
     * @see AstronomicalCalculator/getTimeAtAzimuth(localDate:geoLocation:azimuth:)
     */
    public func getTimeAtAzimuth90Or270(azimuth: Double) -> Date? {
        let rawAzimuth = getAstronomicalCalculator().getTimeAtAzimuth(localDate: getAdjustedLocalDate(), geoLocation: getGeoLocation(),
                                                                       azimuth: azimuth)
        return getDateFromTime(time: rawAzimuth, solarEvent: azimuth == 90 ? .sunrise : .sunset)
    }

    /**
     * A method that returns a `Date` from the time passed in as a parameter.
     *
     * @param time The time to be set as the time for the `Date`. The time expected is in the format: 18.75 for 6:45:00 PM,
     *            in UTC.
     * @param solarEvent the type of `SolarEvent`, used to resolve the day of the UTC time.
     * @return The `Date` object representation of the time double, or `nil` if the time is NaN.
     */
    public func getDateFromTime(time: Double, solarEvent: SolarEvent) -> Date? {
        if time.isNaN {
            return nil
        }
        var date = getAdjustedLocalDate()
        let localTimeHours = (getGeoLocation().getLongitude() / 15) + time

        // The calculator gives only the UTC time of day, a number from 0 to 24. It doesn't say which UTC day the event is
        // on, so start from the calculation date and correct it.
        //
        // localTimeHours is that time in local mean time, which is UTC plus the longitude's hours. It can come out below 0
        // or above 24, which means the event is really on the day before or the day after the date. Each event has a
        // window of local mean time that belongs to the date, and these checks move the date by a day when the event
        // falls outside it.
        //
        // - Sunrise belongs to the date from 18:00 the evening before through 18:00 of the date. After 18:00 it is really
        //   the evening before (an Arctic sunrise just after midnight, say), so go back a day. At -6:00 or earlier the UTC
        //   time wrapped around midnight, so go forward a day.
        // - Sunset belongs from 06:00 of the date through 06:00 the next morning. Before 06:00 go forward a day. At 30:00,
        //   which is 06:00 the next morning, or later the UTC time wrapped the other way, so go back a day.
        // - Solar midnight is the one after the date's noon, so one before 12:00 moves forward a day.
        // - Solar noon belongs between 0:00 and 24:00. Before 0:00 go forward a day, and after 24:00 go back a day.
        if solarEvent == .sunrise && localTimeHours > 18 {
            date = date.minusDays(1)
        } else if solarEvent == .sunrise && localTimeHours <= -6 {
            date = date.plusDays(1)
        } else if solarEvent == .sunset && localTimeHours < 6 {
            date = date.plusDays(1)
        } else if solarEvent == .sunset && localTimeHours >= 30 {
            date = date.minusDays(1)
        } else if solarEvent == .midnight && localTimeHours < 12 {
            date = date.plusDays(1)
        } else if solarEvent == .noon {
            if localTimeHours < 0 {
                date = date.plusDays(1)
            } else if localTimeHours > 24 {
                date = date.minusDays(1)
            }
        }
        // KosherJava rounds the time to whole nanoseconds; the computed time is in UTC fractional hours
        let nanos = JavaMath.round(time * Double(AstronomicalCalendar.HOUR_NANOS))
        let seconds = Double(nanos / 1_000_000_000) + Double(nanos % 1_000_000_000) / 1_000_000_000
        return Date(timeIntervalSince1970: Double(date.epochDay) * 86400 + seconds)
    }

    /**
     * Returns the sun's elevation (number of degrees) below the horizon before sunrise that matches the offset minutes
     * on passed in as a parameter. For example passing in 72 minutes for a calendar set to the equinox in Jerusalem
     * returns a value close to 16.1&deg;.
     *
     * - Warning: This method is slow and inefficient and should NEVER be used in a loop. This method should be replaced
     *   by calls to ``AstronomicalCalculator/getSolarElevation(date:geoLocation:)``. That method will efficiently return
     *   the solar elevation (the sun's position in degrees below (or above) the horizon) at the given time even in the
     *   arctic when there is no sunrise.
     *
     * @param minutes minutes before sunrise
     * @return the degrees below the horizon before ``getSeaLevelSunrise()`` that match the offset in minutes passed in as
     *         a parameter. If the calculation can't be computed (no sunrise occurs on this day) `Double.nan` will be
     *         returned.
     * @see getSunsetSolarDipFromOffset(minutes:)
     */
    public func getSunriseSolarDipFromOffset(minutes: Double) -> Double {
        if minutes == 0.0 {
            return 0.0
        }
        if minutes.isNaN {
            return Double.nan
        }
        guard let seaLevelSunrise = getSeaLevelSunrise() else {
            return Double.nan
        }
        let offsetNanos = JavaMath.toLong(-minutes * Double(AstronomicalCalendar.MINUTE_NANOS))
        guard let offsetByTime = AstronomicalCalendar.getTimeOffset(time: seaLevelSunrise, offset: Double(offsetNanos) / 1_000_000_000) else {
            return Double.nan
        }
        let offsetByTimeMilli = JavaMath.toEpochMilli(offsetByTime)
        var degrees = 0.0
        let incrementor = 0.0001
        var offsetByDegrees: Date?
        repeat {
            if minutes > 0.0 {
                degrees += incrementor
            } else {
                degrees -= incrementor
            }
            offsetByDegrees = getSunriseOffsetByDegrees(offsetZenith: AstronomicalCalendar.GEOMETRIC_ZENITH + degrees)
            if offsetByDegrees == nil || abs(degrees) > 30.0 {
                return Double.nan
            }
        } while (minutes > 0.0 && JavaMath.toEpochMilli(offsetByDegrees!) > offsetByTimeMilli) ||
            (minutes < 0.0 && JavaMath.toEpochMilli(offsetByDegrees!) < offsetByTimeMilli)
        return degrees
    }

    /**
     * Returns the sun's elevation (number of degrees) below the horizon after sunset that matches the offset minutes
     * passed in as a parameter. For example passing in 72 minutes for a calendar set to the equinox in Jerusalem returns a
     * value close to 16.1&deg;.
     *
     * - Warning: This method is slow and inefficient and should NEVER be used in a loop. This method should be replaced
     *   by calls to ``AstronomicalCalculator/getSolarElevation(date:geoLocation:)``.
     *
     * @param minutes minutes after sunset
     * @return the degrees below the horizon after sunset that match the offset in minutes passed in as a parameter. If the
     *         calculation can't be computed (no sunset occurs on this day) `Double.nan` will be returned.
     * @see getSunriseSolarDipFromOffset(minutes:)
     */
    public func getSunsetSolarDipFromOffset(minutes: Double) -> Double {
        if minutes == 0.0 {
            return 0.0
        }
        if minutes.isNaN {
            return Double.nan
        }
        guard let seaLevelSunset = getSeaLevelSunset() else {
            return Double.nan
        }
        let offsetNanos = JavaMath.toLong(minutes * Double(AstronomicalCalendar.MINUTE_NANOS))
        guard let offsetByTime = AstronomicalCalendar.getTimeOffset(time: seaLevelSunset, offset: Double(offsetNanos) / 1_000_000_000) else {
            return Double.nan
        }
        let offsetByTimeMilli = JavaMath.toEpochMilli(offsetByTime)
        var degrees = 0.0
        let incrementor = 0.0001
        var offsetByDegrees: Date?
        repeat {
            if minutes > 0.0 {
                degrees += incrementor
            } else {
                degrees -= incrementor
            }
            offsetByDegrees = getSunsetOffsetByDegrees(offsetZenith: AstronomicalCalendar.GEOMETRIC_ZENITH + degrees)
            if offsetByDegrees == nil || abs(degrees) > 30.0 {
                return Double.nan
            }
        } while (minutes > 0.0 && JavaMath.toEpochMilli(offsetByDegrees!) < offsetByTimeMilli) ||
            (minutes < 0.0 && JavaMath.toEpochMilli(offsetByDegrees!) > offsetByTimeMilli)
        return degrees
    }

    /**
     * A method that returns <a href="https://en.wikipedia.org/wiki/Local_mean_time">local mean time (LMT)</a> for the
     * local wall-clock time passed to this method. This time is adjusted from standard time to account for the local
     * longitude. The 360&deg; of the globe divided by 24 calculates to 15&deg; per hour with 4 minutes per degree, so at a
     * longitude of 0 , 15, 30 etc... noon is at exactly 12:00 PM. Lakewood, NJ, with a longitude of -74.222, is 0.7906
     * away from the closest multiple of 15 at -75&deg;. This is multiplied by 4 clock minutes (per degree) to yield 3
     * minutes and 7 seconds for a noon time of 11:56:53 AM. This method is not tied to the theoretical 15&deg; time
     * zones, but will adjust to the actual time zone and
     * <a href="https://en.wikipedia.org/wiki/Daylight_saving_time">Daylight saving time</a> to return LMT.
     *
     * @param hours the local wall-clock time in hours (such as 12.0 for noon and 0 for midnight) to calculate as LMT. It
     *            must be at least 0 and less than 24; other values return `nil` (KosherJava takes a `LocalTime`).
     * @return the `Date` representing the local mean time (LMT) for the time passed in. In Lakewood, NJ, passing noon will
     *         return 11:56:50 AM.
     * @see GeoLocation/getLocalMeanTimeOffset(date:)
     */
    public func getLocalMeanTime(hours: Double) -> Date? {
        guard hours >= 0 && hours < 24 else {
            print("Hours must be between 0 and 23.9999...")
            return nil
        }
        // a LocalTime holds whole nanoseconds
        let timeNanos = JavaMath.toLong(hours * Double(AstronomicalCalendar.HOUR_NANOS))
        let localMeanTime = Date(timeIntervalSince1970: Double(getAdjustedLocalDate().epochDay) * 86400 + Double(timeNanos) / 1_000_000_000)
        let totalNanos = JavaMath.toLong(getGeoLocation().getLongitude() * 4 * Double(AstronomicalCalendar.MINUTE_NANOS))
        return AstronomicalCalendar.getTimeOffset(time: localMeanTime, offset: -Double(totalNanos) / 1_000_000_000)
    }

    /**
     * Adjusts the ``LocalDate`` to deal with edge cases where the location crosses the antimeridian.
     *
     * @see GeoLocation/getAntimeridianAdjustment(date:)
     * @return the adjusted ``LocalDate``
     */
    public func getAdjustedLocalDate() -> LocalDate {
        let offset = getGeoLocation().getAntimeridianAdjustment(date: getMidnightLastNight())
        return offset == 0 ? localDate : localDate.plusDays(offset)
    }

    /**
     * Used by Molad based <em>zmanim</em> to determine if <em>zmanim</em> occur during the current day.
     * @return midnight at the start of the current day in the location's time zone
     */
    public func getMidnightLastNight() -> Date {
        return localDate.atStartOfDay(timeZone: getGeoLocation().getTimeZone())
    }

    /**
     * Used by Molad based <em>zmanim</em> to determine if <em>zmanim</em> occur during the current day.
     * @return midnight at the end of the current day (the start of the next day) in the location's time zone
     */
    public func getMidnightTonight() -> Date {
        return localDate.plusDays(1).atStartOfDay(timeZone: getGeoLocation().getTimeZone())
    }

    /**
     * Returns an XML formatted representation of the class using the default output of the
     * ``ZmanimFormatter/toXML(astronomicalCalendar:)`` method.
     * @return an XML formatted representation of the class. It returns the default output of the
     *         ``ZmanimFormatter/toXML(astronomicalCalendar:)`` method.
     * @see ZmanimFormatter/toXML(astronomicalCalendar:)
     */
    public func toString() -> String {
        return ZmanimFormatter.toXML(astronomicalCalendar: self)
    }

    /**
     * Returns a JSON formatted representation of the class using the default output of the
     * ``ZmanimFormatter/toJSON(astronomicalCalendar:)`` method.
     * @return a JSON formatted representation of the class. It returns the default output of the
     *         ``ZmanimFormatter/toJSON(astronomicalCalendar:)`` method.
     * @see ZmanimFormatter/toJSON(astronomicalCalendar:)
     */
    public func toJSON() -> String {
        return ZmanimFormatter.toJSON(astronomicalCalendar: self)
    }

    /**
     * The values of this class's public getters that take no parameters and return a `Date` or a duration, by method name.
     * This is what Java's reflection finds for ``ZmanimFormatter/toXML(astronomicalCalendar:)``; subclasses add their own.
     */
    func getFormattableValues() -> [(String, ZmanimFormatter.Value)] {
        return [
            ("getBeginAstronomicalTwilight", .date(getBeginAstronomicalTwilight())),
            ("getBeginCivilTwilight", .date(getBeginCivilTwilight())),
            ("getBeginNauticalTwilight", .date(getBeginNauticalTwilight())),
            ("getEndAstronomicalTwilight", .date(getEndAstronomicalTwilight())),
            ("getEndCivilTwilight", .date(getEndCivilTwilight())),
            ("getEndNauticalTwilight", .date(getEndNauticalTwilight())),
            ("getSeaLevelSunrise", .date(getSeaLevelSunrise())),
            ("getSeaLevelSunset", .date(getSeaLevelSunset())),
            ("getSolarMidnight", .date(getSolarMidnight())),
            ("getSunTransit", .date(getSunTransit())),
            ("getSunrise", .date(getSunrise())),
            ("getSunset", .date(getSunset())),
            ("getTemporalHour", .duration(getTemporalHour())),
        ]
    }

    /// True if the other calendar is the same class with the same date, location and calculator.
    public func equals(_ other: AstronomicalCalendar) -> Bool {
        if self === other {
            return true
        }
        return type(of: self) == type(of: other)
            && localDate == other.localDate
            && geoLocation.equals(other.geoLocation)
            && astronomicalCalculator.equals(other.astronomicalCalculator)
    }

    /**
     * A method that returns the currently set ``GeoLocation`` which contains location information used for the
     * astronomical calculations.
     *
     * @return Returns the geoLocation.
     */
    public func getGeoLocation() -> GeoLocation {
        return geoLocation
    }

    /**
     * Sets the ``GeoLocation`` `geoLocation` used for calculations. The date is not changed, even if the new
     * location is in a different time zone.
     *
     * @param geoLocation The geoLocation to set.
     */
    public func setGeoLocation(geoLocation: GeoLocation) {
        self.geoLocation = geoLocation
    }

    /**
     * A method that returns the currently set AstronomicalCalculator.
     *
     * @return Returns the astronomicalCalculator.
     * @see setAstronomicalCalculator(astronomicalCalculator:)
     */
    public func getAstronomicalCalculator() -> AstronomicalCalculator {
        return astronomicalCalculator
    }

    /**
     * A method to set the ``AstronomicalCalculator`` used for astronomical calculations. The Zmanim package ships with a
     * number of different implementations of the ``AstronomicalCalculator`` based on different algorithms, including
     * the default ``NOAACalculator`` based on <a href="https://noaa.gov">NOAA's</a> implementation of Jean Meeus's
     * algorithms, the more accurate ``SPACalculator``, the ``MeeusCalculator`` and the legacy ``SunTimesCalculator``.
     *
     * @param astronomicalCalculator The astronomicalCalculator to set.
     */
    public func setAstronomicalCalculator(astronomicalCalculator: AstronomicalCalculator) {
        self.astronomicalCalculator = astronomicalCalculator
    }

    /**
     * Returns the ``LocalDate`` that the zmanim are calculated for.
     *
     * @return the date
     */
    public func getLocalDate() -> LocalDate {
        return localDate
    }

    /**
     * Sets the ``LocalDate`` that the zmanim are calculated for.
     *
     * @param localDate the date to set
     */
    public func setLocalDate(localDate: LocalDate) {
        self.localDate = localDate
    }

    /**
     * A method that creates a copy of the object. The ``GeoLocation`` and ``AstronomicalCalculator`` are copied too.
     * The copy is the same class as this calendar; subclasses copy their own settings in `copyState(to:)`.
     *
     * @return a copy of the calendar
     */
    public func copy() -> AstronomicalCalendar {
        let copy = type(of: self).init(geoLocation: geoLocation.copy())
        copyState(to: copy)
        return copy
    }

    /// Copies this calendar's date and calculator into another calendar, for ``copy()``.
    func copyState(to copy: AstronomicalCalendar) {
        copy.localDate = localDate
        copy.geoLocation = geoLocation.copy()
        copy.astronomicalCalculator = astronomicalCalculator.copy()
    }
}
