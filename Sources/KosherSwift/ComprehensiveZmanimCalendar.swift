//
//  ComprehensiveZmanimCalendar.swift
//  KosherSwift
//
//  Created by Elyahu Jacobi on 12/21/23.
//

import Foundation

/**
 * <p>This class extends ZmanimCalendar and provides many more <em>zmanim</em> than available in the ZmanimCalendar. The basis
 * for most <em>zmanim</em> in this class are from the <em>sefer</em> <b><a href="https://hebrewbooks.org/9765">Yisroe
 * Vehazmanim</a></b> by <b><a href="https://en.wikipedia.org/wiki/Yisroel_Dovid_Harfenes">Rabbi Yisrael Dovid Harfenes</a></b>.
 * As an example of the number of different <em>zmanim</em> made available by this class, there are methods to return 18 different
 * calculations for <em>alos</em> (dawn), 18 for <em>plag hamincha</em> and 29 for <em>tzais</em> available in this API. The real
 * power of this API is the ease in calculating <em>zmanim</em> that are not part of the library. The methods for <em>zmanim</em>
 * calculations not present in this class or its superclass  ``ZmanimCalendar`` are contained in the ``AstronomicalCalendar``, the base class of the calendars in our API since they are generic methods for calculating time based on
 * degrees or time before or after ``getSunrise()`` and sunset and are of interest for calculation
 * beyond <em>zmanim</em> calculations. Here are some examples. <p>First create the Calendar for the location you would like to
 * calculate:
 *
 * ```
 * String locationName = "Lakewood, NJ";
 * double latitude = 40.0828; // Lakewood, NJ
 * double longitude = -74.222; // Lakewood, NJ
 * double elevation = 20; // optional elevation correction in Meters
 * // @link region="target_zone_link" substring="getAvailableZoneIds()" target="java.time.ZoneId#getAvailableZoneIds()"
 * ZoneId zoneId = ZoneId.of("America/New_York"); // set the zoneId to a valid ZoneId listed in getAvailableZoneIds()
 * // @end
 * GeoLocation location = new GeoLocation(locationName, latitude, longitude, elevation, zoneId);
 * ComprehensiveZmanimCalendar czc = new ComprehensiveZmanimCalendar(location);
 * // Optionally set the date or it will default to today's date
 * ZonedDateTime dateTime = ZonedDateTime.of(1969, Month.FEBRUARY.getValue(), 8, 0, 0, 0, 0, location.getZoneId());
 * czc.setZonedDateTime(dateTime);
 * ```
 *
 * <b>Note:</b> For locations such as Israel where the beginning and end of daylight savings time used to fluctuate from
 * year to year, if your version of Java does not have an <a href=
 * "https://www.oracle.com/java/technologies/tzdata-versions.html">up to date time zone database</a>, create a
 * ``java.time.ZoneId`` with the known start and end of DST.
 * To get <em>alos</em> calculated as 14° below the horizon (as calculated in the calendars published in Montreal),
 * add ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90) to the 14° offset to get the desired time:
 * ```
 * Instant alos14 = czc.getSunriseOffsetByDegrees(AstronomicalCalendar.GEOMETRIC_ZENITH + 14);
 * ```
 * To get <em>mincha gedola</em> calculated based on the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham
 * (MGA)</a> using a <em>shaah zmanis</em> based on the day starting 16.1° below the horizon (and ending 16.1° after sunset) the
 * following calculation can be used:
 *
 * ```
 * Instant minchaGedola = czc.getTimeOffset(czc.getAlos16point1Degrees(), czc.getShaahZmanis16Point1Degrees() * 6.5);
 * ```
 * or even simpler using the included convenience methods
 * ```
 * Instant minchaGedola = czc.getMinchaGedola(czc.getAlos16point1Degrees(), czc.getShaahZmanis16Point1Degrees());
 * ```
 * A little more complex example would be calculating <em>zmanim</em> that rely on a <em>shaah zmanis</em> that is
 * not present in this library. While a drop more complex, it is still rather easy. An example would be to calculate
 * the <a href="https://en.wikipedia.org/wiki/Israel_Isserlein">Trumas Hadeshen</a>'s <em>alos</em> to
 * <em>tzais</em> based <em>plag hamincha</em> as calculated in the Machzikei Hadass calendar in Manchester, England.
 * A number of this calendar's <em>zmanim</em> are calculated based on a day starting at <em>alos</em> of 12° before
 * sunrise and ending at <em>tzais</em> of 7.083° after sunset. Be aware that since the <em>alos</em> and <em>tzais</em>
 * do not use identical degree-based offsets, this leads to <em>chatzos</em> being at a time other than the
 * solar transit (solar midday). To calculate this <em>zman</em>, use the following steps. Note
 * that <em>plag hamincha</em> is 10.75 hours after the start of the day, and the following steps are all that it takes.
 * ```
 * Instant plag = czc.getPlagHamincha(czc.getSunriseOffsetByDegrees(AstronomicalCalendar.GEOMETRIC_ZENITH + 12),
 * 		czc.getSunsetOffsetByDegrees(AstronomicalCalendar.GEOMETRIC_ZENITH + ZmanimCalendar.ZENITH_7_POINT_083));
 * ```
 * Something a drop more challenging, but still simple, would be calculating a <em>zman</em> using the same "complex"
 * offset day used in the above-mentioned Manchester calendar, but for a <em>shaos zmaniyos</em> based <em>zman</em> not
 * supported by this library, such as calculating the point that one should be <em>makpid</em>
 * not to eat on <em>erev Shabbos</em> or <em>erev Yom Tov</em>. This is 9 <em>shaos zmaniyos</em> into the day.
 * <ol>
 * 	<li>Calculate the <em>shaah zmanis</em> `TimeInterval` for this day</li>
 * 	<li>Add 9 of these <em>shaos zmaniyos</em> to <em>alos</em> starting at 12°</li>
 * </ol>
 * ```
 * Duration shaahZmanis = czc.getTemporalHour(czc.getSunriseOffsetByDegrees(AstronomicalCalendar.GEOMETRIC_ZENITH} + 12),
 * 				czc.getSunsetOffsetByDegrees(AstronomicalCalendar.GEOMETRIC_ZENITH + ZmanimCalendar.ZENITH_7_POINT_083));
 * Instant sofZmanAchila = getTimeOffset(czc.getSunriseOffsetByDegrees(AstronomicalCalendar.GEOMETRIC_ZENITH} + 12),
 * 				shaahZmanis * 9);
 * ```
 * Calculating this <em>sof zman achila</em> according to the <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a>
 * is simplicity itself.
 * ```
 * Instant sofZmanAchila = czc.getTimeOffset(czc.getSunrise(), czc.getShaahZmanisGRA() * 9);
 * ```
 *
 * <h2>See documentation from the ``ZmanimCalendar`` parent class</h2>
 *
 * @author © Eliyahu Hershfeld 2004 - 2026
 */
public class ComprehensiveZmanimCalendar: ZmanimCalendar {

    /**
     * The zenith of 3.7° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°).
     * @see getTzaisGeonim3Point7Degrees()
     */
    public static let ZENITH_3_POINT_7 = AstronomicalCalendar.GEOMETRIC_ZENITH + 3.7

    /**
     * The zenith of 3.8° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°).
     * @see getTzaisGeonim3Point8Degrees()
     */
    public static let ZENITH_3_POINT_8 = AstronomicalCalendar.GEOMETRIC_ZENITH + 3.8

    /**
     * The zenith of 5.95° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°).
     * @see getTzaisGeonim5Point95Degrees()
     */
    public static let ZENITH_5_POINT_95 = AstronomicalCalendar.GEOMETRIC_ZENITH + 5.95

    /**
     * The zenith of 7.083° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°). This is often referred to as
     * 7°5' (7° and 5 minutes).
     *
     * @see getTzaisGeonim7Point083Degrees()
     * @see getBainHashmashosRT13Point5MinutesBefore7Point083Degrees()
     */
    public static let ZENITH_7_POINT_083 = AstronomicalCalendar.GEOMETRIC_ZENITH + 7 + (5.0 / 60)

    /**
     * The zenith of 10.2° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°).
     * @see getMisheyakir10Point2Degrees()
     */
    public static let ZENITH_10_POINT_2 = AstronomicalCalendar.GEOMETRIC_ZENITH + 10.2

    /**
     * The zenith of 11° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°).
     * @see getMisheyakir11Degrees()
     */
    public static let ZENITH_11_DEGREES = AstronomicalCalendar.GEOMETRIC_ZENITH + 11

    /**
     * The zenith of 11.5° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°).
     * @see getMisheyakir11Point5Degrees()
     */
    public static let ZENITH_11_POINT_5 = AstronomicalCalendar.GEOMETRIC_ZENITH + 11.5

    /**
     * The zenith of 12.85° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°).
     * @see getMisheyakir12Point85Degrees()
     */
    public static let ZENITH_12_POINT_85 = AstronomicalCalendar.GEOMETRIC_ZENITH + 12.85

    /**
     * The zenith of 13.24° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°).
     * @see getBainHashmashosRT13Point24Degrees
     */
    public static let ZENITH_13_POINT_24 = AstronomicalCalendar.GEOMETRIC_ZENITH + 13.24

    /**
     * The zenith of 19° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°).
     * @see getAlos19Degrees()
     * @see ZENITH_19_POINT_8
     */
    public static let ZENITH_19_DEGREES = AstronomicalCalendar.GEOMETRIC_ZENITH + 19

    /**
     * The zenith of 19.8° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°).
     * @see getTzais19Point8Degrees()
     * @see getAlos19Point8Degrees()
     * @see ZENITH_19_DEGREES
     */
    public static let ZENITH_19_POINT_8 = AstronomicalCalendar.GEOMETRIC_ZENITH + 19.8

    /**
     * The zenith of 26° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°).
     * @see getAlos26Degrees()
     * @see getTzais26Degrees()
     * @see getAlos120Minutes()
     * @see getTzais120Minutes()
     */
    public static let ZENITH_26_DEGREES = AstronomicalCalendar.GEOMETRIC_ZENITH + 26.0

    /**
     * The zenith of 4.42° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°).
     * @see getTzaisGeonim4Point42Degrees()
     */
    public static let ZENITH_4_POINT_42 = AstronomicalCalendar.GEOMETRIC_ZENITH + 4.42

    /**
     * The zenith of 4.66° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°).
     * @see getTzaisGeonim4Point66Degrees()
     */
    public static let ZENITH_4_POINT_66 = AstronomicalCalendar.GEOMETRIC_ZENITH + 4.66

    /**
     * The zenith of 4.8° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°).
     * @see getTzaisGeonim4Point8Degrees()
     */
    public static let ZENITH_4_POINT_8 = AstronomicalCalendar.GEOMETRIC_ZENITH + 4.8

    /**
     * The zenith of 16.9° below geometric zenith (90°).
     *
     * @see getAlosBaalHatanya()
     */
    public static let ZENITH_16_POINT_9 = AstronomicalCalendar.GEOMETRIC_ZENITH + 16.9

    /**
     * The zenith of 6° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°).
     * @see getTzaisBaalHatanya()
     */
    public static let ZENITH_6_DEGREES = AstronomicalCalendar.GEOMETRIC_ZENITH + 6

    /**
     * The zenith of 6.45° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°).
     * @see getTzaisGeonim6Point45Degrees()
     */
    public static let ZENITH_6_POINT_45 = AstronomicalCalendar.GEOMETRIC_ZENITH + 6.45

    /**
     * The zenith of 7.65° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°).
     * @see getMisheyakir7Point65Degrees()
     */
    public static let ZENITH_7_POINT_65 = AstronomicalCalendar.GEOMETRIC_ZENITH + 7.65

    /**
     * The zenith of 7.67° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°).
     * @see getTzaisGeonim7Point67Degrees()
     */
    public static let ZENITH_7_POINT_67 = AstronomicalCalendar.GEOMETRIC_ZENITH + 7.67

    /**
     * The zenith of 9.3° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°).
     * @see getTzaisGeonim9Point3Degrees()
     */
    public static let ZENITH_9_POINT_3 = AstronomicalCalendar.GEOMETRIC_ZENITH + 9.3

    /**
     * The zenith of 9.5° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°).
     * @see getMisheyakir9Point5Degrees()
     */
    public static let ZENITH_9_POINT_5 = AstronomicalCalendar.GEOMETRIC_ZENITH + 9.5

    /**
     * The zenith of 9.75° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°). This calculation is used for
     * calculating <em>alos</em> (dawn) and <em>tzais</em> (nightfall) according to some opinions.
     *
     * @see getTzaisGeonim9Point75Degrees()
     */
    public static let ZENITH_9_POINT_75 = AstronomicalCalendar.GEOMETRIC_ZENITH + 9.75

    /**
     * The zenith of 2.1° <b>above</b> ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°). This calculation is used for calculating
     * the start of <em>bain hashmashos</em> (twilight) of 13.5 minutes before sunset converted to degrees according to the Yereim.
     * As is traditional with degrees below the horizon, this is calculated without refraction and from the center of the sun. It
     * would be 0.833° less without this.
     *
     * @see getBainHashmashosYereim2Point1Degrees()
     */
    public static let ZENITH_MINUS_2_POINT_1 = AstronomicalCalendar.GEOMETRIC_ZENITH - 2.1

    /**
     * The zenith of 2.8° above ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°). This calculation is used for
     * calculating the start of <em>bain hashmashos</em> (twilight) of 16.875 minutes before sunset converted to degrees
     * according to the Yereim. As is traditional with degrees below the horizon, this is calculated without refraction
     * and from the center of the sun. It would be 0.833° less without this.
     *
     * @see getBainHashmashosYereim2Point8Degrees()
     */
    public static let ZENITH_MINUS_2_POINT_8 = AstronomicalCalendar.GEOMETRIC_ZENITH - 2.8

    /**
     * The zenith of 3.05° above ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°). This calculation is used for
     * calculating the start of <em>bain hashmashos</em> (twilight) of 18 minutes before sunset converted to degrees
     * according to the Yereim. As is traditional with degrees below the horizon, this is calculated without refraction
     * and from the center of the sun. It would be 0.833° less without this.
     *
     * @see getBainHashmashosYereim3Point05Degrees()
     */
    public static let ZENITH_MINUS_3_POINT_05 = AstronomicalCalendar.GEOMETRIC_ZENITH - 3.05

    /**
     * The offset in minutes (defaults to 40) after sunset used for <em>tzeit</em> based on calculations of
     * <em>Chacham</em> Yosef Harari-Raful of Yeshivat Ateret Torah.
     * @see getTzaisAteretTorah()
     * @see getAteretTorahSunsetOffset()
     * @see setAteretTorahSunsetOffset(double)
     */
    public var ateretTorahSunsetOffset = 40.0

    /**
     * A constructor that takes a ``GeoLocation`` as a parameter.
     * @param location the location
     * @see ZmanimCalendar/ZmanimCalendar(GeoLocation)
     */
    public required init(geoLocation: GeoLocation) {
        super.init(geoLocation: geoLocation)
    }

    /**
     * Default constructor will set a default ``GeoLocation/GeoLocation()``, a default
     * AstronomicalCalculator and default the calendar to the current date.
     *
     * @see AstronomicalCalendar/AstronomicalCalendar()
     * @see ComprehensiveZmanimCalendar(GeoLocation)
     */
    // init() is inherited from AstronomicalCalendar

    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) calculated using a 19.8° dip. This calculation
     * divides the day based on the opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen
     * Avraham (MGA)</a> that the day runs from dawn to dusk. Dawn for this calculation is when the sun is 19.8°
     * below the eastern geometric horizon before sunrise. Dusk for this is when the sun is 19.8° below the western
     * geometric horizon after sunset. This day is split into 12 equal parts with each part being a <em>shaah zmanis</em>.
     *
     * @return the `TimeInterval` of a <em>shaah zmanis</em>. If the calculation can't be computed such as northern and
     *         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not reach low
     *         enough below the horizon for this calculation, a `nil` will be returned. See detailed explanation on top
     *         of the ``AstronomicalCalendar`` documentation.
     */
    public func getShaahZmanis19Point8Degrees() -> TimeInterval? {
        return getTemporalHour(startOfDay: getAlos19Point8Degrees(), endOfDay: getTzais19Point8Degrees())
    }

    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) calculated using a 18° dip. This calculation divides
     * the day based on the opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham
     * (MGA)</a> that the day runs from dawn to dusk. Dawn for this calculation is when the sun is 18° below the
     * eastern geometric horizon before sunrise. Dusk for this is when the sun is 18° below the western geometric
     * horizon after sunset. This day is split into 12 equal parts with each part being a <em>shaah zmanis</em>.
     *
     * @return the `TimeInterval` of a <em>shaah zmanis</em>. If the calculation can't be computed such as northern and
     *         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not reach low
     *         enough below the horizon for this calculation, a `nil` will be returned. See detailed explanation on top
     *         of the ``AstronomicalCalendar`` documentation.
     */
    public func getShaahZmanis18Degrees() -> TimeInterval? {
        return getTemporalHour(startOfDay: getAlos18Degrees(), endOfDay: getTzais18Degrees())
    }

    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) calculated using a dip of 26°. This calculation divides the day based
     * on the opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> that the day runs from
     * dawn to dusk. Dawn for this calculation is when the sun is 26° below the eastern geometric horizon
     * before sunrise. Dusk for this is when the sun is 26° below the western geometric horizon after
     * sunset. This day is split into 12 equal parts with each part being a <em>shaah zmanis</em>. Since <em>zmanim</em> that use this
     * method are extremely late or early and at a point when the sky is a long time past the 18° point where the darkest point is
     * reached, <em>zmanim</em> that use this should only be used <em>lechumra</em>, such as delaying the start of nighttime
     * <em>mitzvos</em>.
     *
     * @return the `TimeInterval` of a <em>shaah zmanis</em>. If the calculation can't be computed such as northern and southern
     *         locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not reach low enough below
     *         the horizon for this calculation, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis120Minutes()
     */
    public func getShaahZmanis26Degrees() -> TimeInterval? {
        return getTemporalHour(startOfDay: getAlos26Degrees(), endOfDay: getTzais26Degrees())
    }

    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) calculated using a dip of 16.1°. This calculation divides the day based
     * on the opinion that the day runs from dawn to dusk. Dawn for this calculation is when the sun is 16.1° below the eastern
     * geometric horizon before sunrise and dusk is when the sun is 16.1° below the western geometric horizon after sunset. This day is
     * split into 12 equal parts with each part being a <em>shaah zmanis</em>.
     *
     * @return the `TimeInterval`  of a <em>shaah zmanis</em>. If the calculation can't be computed such as northern and
     *         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not reach low
     *         enough below the horizon for this calculation, a `nil` will be returned. See detailed explanation on top
     *         of the ``AstronomicalCalendar`` documentation.
     * @see getAlos16Point1Degrees()
     * @see getTzais16Point1Degrees()
     * @see getSofZmanShmaMGA16Point1Degrees()
     * @see getSofZmanTfilaMGA16Point1Degrees()
     * @see getMinchaGedola16Point1Degrees()
     * @see getMinchaKetana16Point1Degrees()
     * @see getPlagHamincha16Point1Degrees()
     */
    public func getShaahZmanis16Point1Degrees() -> TimeInterval? {
        return getTemporalHour(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzais16Point1Degrees())
    }

    /**
     * Method to return a <em>shaah zmanis</em> (solar hour) according to the opinion of the <a href=
     * "https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a>. This calculation divides the day based on the opinion
     * of the MGA that the day runs from dawn to dusk. Dawn for this calculation is 60 minutes before sunrise and dusk is 60 minutes
     * after sunset. This day is split into 12 equal parts with each part being a <em>shaah zmanis</em>. Alternate methods of
     * calculating a <em>shaah zmanis</em> are available in the subclass ``ComprehensiveZmanimCalendar``.
     *
     * @return the `TimeInterval` of a <em>shaah zmanis</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos60Minutes()
     * @see getTzais60Minutes()
     * @see getPlagHamincha60Minutes()
     */
    public func getShaahZmanis60Minutes() -> TimeInterval? {
        return getTemporalHour(startOfDay: getAlos60Minutes(), endOfDay: getTzais60Minutes())
    }

    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) according to the opinion of the <a href=
     * "https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on <em>alos</em> being 72 minutes <em>zmaniyos</em> before ``getSunrise()`` sunrise}. This calculation divides the day based
     * on the opinion of the MGA that the day runs from dawn to dusk. Dawn for this calculation is 72 minutes <em>zmaniyos</em>
     * before sunrise and dusk is 72 minutes <em>zmaniyos</em> after sunset. This day is split into 12 equal parts with each part
     * being a <em>shaah zmanis</em>. This is identical to 1/10th of the day from ``getSunrise()`` to ``getSunset()``.
     *
     * @return the `TimeInterval` of a <em>shaah zmanis</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos72Zmanis()
     * @see getTzais72Zmanis()
     */
    public func getShaahZmanis72MinutesZmanis() -> TimeInterval? {
        return getTemporalHour(startOfDay: getAlos72Zmanis(), endOfDay: getTzais72Zmanis())
    }

    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) calculated using a dip of 90 minutes. This calculation
     * divides the day based on the opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen
     * Avraham (MGA)</a> that the day runs from dawn to dusk. Dawn for this calculation is 90 minutes before sunrise
     * and dusk is 90 minutes after sunset. This day is split into 12 equal parts with each part being a <em>shaah zmanis</em>.
     *
     * @return the `TimeInterval` of a <em>shaah zmanis</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getShaahZmanis90Minutes() -> TimeInterval? {
        return getTemporalHour(startOfDay: getAlos90Minutes(), endOfDay: getTzais90Minutes())
    }

    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) according to the opinion of the <a href=
     * "https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on <em>alos</em> being 90 minutes <em>zmaniyos</em> before ``getSunrise()``. This calculation divides the day
     * based on the opinion of the MGA that the day runs from dawn to dusk. Dawn is calculated as 90 minutes <em>zmaniyos</em>
     * before sunrise and dusk is 90 minutes <em>zmaniyos</em> after sunset. This day is split into 12 equal parts with each part
     * being a <em>shaah zmanis</em>. This is 1/8th of the day from ``getSunrise()`` to sunset.
     *
     * @return the `TimeInterval` of a <em>shaah zmanis</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos90Zmanis()
     * @see getTzais90Zmanis()
     */
    public func getShaahZmanis90MinutesZmanis() -> TimeInterval? {
        return getTemporalHour(startOfDay: getAlos90Zmanis(), endOfDay: getTzais90Zmanis())
    }

    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) according to the opinion of the <a href=
     * "https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on <em>alos</em> being 96 minutes <em>zmaniyos</em> before ``getSunrise()``. This calculation divides the day based on the opinion of the
     * MGA that the day runs from dawn to dusk. Dawn is calculated as 96 minutes <em>zmaniyos</em> before sunrise and dusk is 96 minutes
     * <em>zmaniyos</em> after sunset. This day is split into 12 equal parts with each part being a <em>shaah zmanis</em>. This is
     * identical to 1/7.5th of the day from ``getSunrise()`` to sunset.
     *
     * @return the `TimeInterval` of a <em>shaah zmanis</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos96Zmanis()
     * @see getTzais96Zmanis()
     */
    public func getShaahZmanis96MinutesZmanis() -> TimeInterval? {
        return getTemporalHour(startOfDay: getAlos96Zmanis(), endOfDay: getTzais96Zmanis())
    }

    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) according to the opinion of the <em>Chacham</em> Yosef Harari-Raful
     * of Yeshivat Ateret Torah calculated with <em>alos</em> being 1/10th of sunrise to sunset day, or 72
     * minutes <em>zmaniyos</em> of such a day before ``getSunrise()``, and <em>tzais</em> is usually calculated as 40 minutes (configurable to any offset via ``setAteretTorahSunsetOffset()``) after sunset. This day is split into 12 equal parts with each part being a <em>shaah zmanis</em>. Note that with this
     * system, <em>chatzos</em> (midday) will not be the point that the sun is halfway across the sky.
     *
     * @return the `TimeInterval` of a <em>shaah zmanis</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos72Zmanis()
     * @see getTzaisAteretTorah()
     * @see getAteretTorahSunsetOffset()
     * @see setAteretTorahSunsetOffset(double)
     */
    public func getShaahZmanisAteretTorah() -> TimeInterval? {
        return getTemporalHour(startOfDay: getAlos72Zmanis(), endOfDay: getTzaisAteretTorah())
    }

    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) used by some <em>zmanim</em> according to the opinion of <a href=
     * "https://en.wikipedia.org/wiki/Yaakov_Moshe_Hillel">Rabbi Yaakov Moshe Hillel</a> as published in the <em>luach</em> of the
     * Bais Horaah of Yeshivat Chevrat Ahavat Shalom that is based on a day starting 72 minutes before sunrise in degrees <em>alos</em> 16.1° and ending 14 minutes after sunset in degrees <em>tzais</em> 3.8°. This day is split into 12 equal parts with each part being a <em>shaah
     * zmanis</em>. Note that with this system, <em>chatzos</em> (midday) will not be the point that the sun is halfway across the sky. These <em>shaos zmaniyos</em> are used for <em>Mincha Ketana</em> and <em>Plag
     * Hamincha</em>. The 14 minutes are based on 3/4 of an 18 minute <a href="https://en.wikipedia.org/wiki/Biblical_mile">mil</a>,
     * with half a minute added for Rav Yosi's <em>Bain Hashmashos</em>. Sources for an asymmetrical day-based calculation can be
     * seen in the documentation of ``getSofZmanShmaAlos16Point1DegreesToTzaisGeonim7Point083Degrees``.
     *
     * @return the `TimeInterval` of a <em>shaah zmanis</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getMinchaKetanaAhavatShalom()
     * @see getPlagAhavatShalom()
     * @see getShaahZmanisAlos16Point1DegreesToTzaisGeonim3Point7Degrees()
     * @see getShaahZmanisAlos16Point1DegreesToTzaisGeonim7Point083Degrees()
     */
    public func getShaahZmanisAlos16Point1DegreesToTzaisGeonim3Point8Degrees() -> TimeInterval? {
        return getTemporalHour(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzaisGeonim3Point8Degrees())
    }

    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) used by some <em>zmanim</em> according to the opinion of <a href=
     * "https://en.wikipedia.org/wiki/Yaakov_Moshe_Hillel">Rabbi Yaakov Moshe Hillel</a> as published in the <em>luach</em> of the
     * Bais Horaah of Yeshivat Chevrat Ahavat Shalom that is based on a day starting 72 minutes before sunrise in degrees <em>alos</em> 16.1° and ending 13.5 minutes after sunset in degrees <em>tzais</em> 3.7°. This day is split into 12 equal parts with each part being a <em>shaah
     * zmanis</em>. Note that with this system, <em>chatzos</em> (midday) will not be the point that the sun is halfway across the sky. These <em>shaos zmaniyos</em> are used for <em>Mincha Gedola</em> calculation.
     * Sources for an asymmetrical day-based calculation can be seen in the documentation of
     * ``getSofZmanShmaAlos16Point1DegreesToTzaisGeonim7Point083Degrees``.
     *
     * @return the `TimeInterval` of a <em>shaah zmanis</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getMinchaGedolaAhavatShalom()
     * @see getShaahZmanisAlos16Point1DegreesToTzaisGeonim3Point8Degrees()
     * @see getShaahZmanisAlos16Point1DegreesToTzaisGeonim7Point083Degrees()
     */
    public func getShaahZmanisAlos16Point1DegreesToTzaisGeonim3Point7Degrees() -> TimeInterval? {
        return getTemporalHour(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzaisGeonim3Point7Degrees())
    }

    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) used by some <em>zmanim</em> according to some opinions that is based
     * on a day starting  at <em>alos</em> 16.1° and ending <em>tzais</em> 8.083°. This day is split into 12 equal parts with each part being a <em>shaah
     * zmanis</em>. Note that with this system, <em>chatzos</em> (midday) will not be the point that the sun is halfway across the sky. Sources for an asymmetrical day-based calculation can be seen in the documentation
     * of ``getSofZmanShmaAlos16Point1DegreesToTzaisGeonim7Point083Degrees``.
     *
     * @return the `TimeInterval` of a <em>shaah zmanis</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanisAlos16Point1DegreesToTzaisGeonim3Point7Degrees()
     * @see getShaahZmanisAlos16Point1DegreesToTzaisGeonim3Point8Degrees()
     */
    public func getShaahZmanisAlos16Point1DegreesToTzaisGeonim7Point083Degrees() -> TimeInterval? {
        return getTemporalHour(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzaisGeonim7Point083Degrees())
    }

    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) calculated using a dip of 96 minutes. This calculation divides the
     * day based on the opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> that the day
     * runs from dawn to dusk. Dawn for this calculation is 96 minutes before sunrise and dusk is 96 minutes after sunset. This day
     * is split into 12 equal parts with each part being a <em>shaah zmanis</em>.
     *
     * @return the `TimeInterval` of a <em>shaah zmanis</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getShaahZmanis96Minutes() -> TimeInterval? {
        return getTemporalHour(startOfDay: getAlos96Minutes(), endOfDay: getTzais96Minutes())
    }

    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) calculated using a dip of 120 minutes. This calculation divides the
     * day based on the opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> that the day
     * runs from dawn to dusk. Dawn for this calculation is 120 minutes before sunrise and dusk is 120 minutes after sunset. This day
     * is split into 12 equal parts with each part being a <em>shaah zmanis</em>. Since <em>zmanim</em> that use this method are
     * extremely late or early and at a point when the sky is a long time past the 18° point where the darkest point is reached,
     * <em>zmanim</em> that use this should only be used <em>lechumra</em> only, such as delaying the start of nighttime
     * <em>mitzvos</em>.
     *
     * @return the `TimeInterval` of a <em>shaah zmanis</em>. If the calculation can't be computed such as inin the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis26Degrees()
     */
    public func getShaahZmanis120Minutes() -> TimeInterval? {
        return getTemporalHour(startOfDay: getAlos120Minutes(), endOfDay: getTzais120Minutes())
    }

    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) according to the opinion of the <a href=
     * "https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on <em>alos</em> being 120 minutes <em>zmaniyos</em> before ``getSunrise()``. This calculation divides the day
     * based on the opinion of the MGA that the day runs from dawn to dusk. Dawn for this calculation is 120 minutes <em>zmaniyos</em>
     * before sunrise and dusk is 120 minutes <em>zmaniyos</em> after sunset. This day is split into 12 equal parts with each part
     * being a <em>shaah zmanis</em>. This is identical to 1/6th of the day from ``getSunrise()`` to sunset. Since <em>zmanim</em> that use this method are extremely late or early and at a point when the sky is a long time
     * past the 18° point where the darkest point is reached, <em>zmanim</em> that use this should only be used <em>lechumra</em>
     * such as delaying the start of nighttime <em>mitzvos</em>.
     *
     * @return the `TimeInterval` of a <em>shaah zmanis</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos120Zmanis()
     * @see getTzais120Zmanis()
     */
    public func getShaahZmanis120MinutesZmanis() -> TimeInterval? {
        return getTemporalHour(startOfDay: getAlos120Zmanis(), endOfDay: getTzais120Zmanis())
    }

    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em> based on sunrise being 120
     * minutes <em>zmaniyos</em> or 1/6th of the day before sunrise. This is calculated as 10.75 hours after dawn. The formula used is 10.75 * ``getShaahZmanis120MinutesZmanis()`` after dawn. Since the <em>zman</em> based on an extremely early <em>alos</em> and a very late <em>tzais</em>,
     * it should only be used <em>lechumra</em>.
     *
     * - Warning: This method should be used <em>lechumra</em> only since it returns a very late time (often after <em>shkiah</em>),
     *         and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no current plan to remove this method
     *         from the API, and this deprecation is intended to alert developers of the danger of using it.
     * @return the `Date` of the time of <em>plag hamincha</em>. If the calculation can't be computed such as in the
     *         Arctic Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis120MinutesZmanis()
     * @see getAlos120Minutes()
     * @see getTzais120Minutes()
     * @see getPlagHamincha26Degrees()
     * @see getPlagHamincha120Minutes()
     */
    public func getPlagHamincha120MinutesZmanis() -> Date? {
        return getPlagHamincha(startOfDay: getAlos120Zmanis(), endOfDay: getTzais120Zmanis(), synchronous: true)
    }

    /**
     * This method <em>plag hamincha</em> according to the Magen Avraham with the day starting at . It should be used <em>lechumra</em> only. This is calculated as 10.75 * ``getShaahZmanis120Minutes()`` after ``getAlos120Minutes()``. Since the <em>zman</em> based on an extremely early
     * <em>alos</em> and a very late <em>tzais</em>, it returns a very late time (often after <em>shkiah</em> and can result in
     * <em>chillul Shabbos</em> etc.) and should only be used <em>lechumra</em>.
     *
     * - Warning: This method should be used <em>lechumra</em> only since it returns a very late time (often after <em>shkiah</em>),
     *         and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no current plan to remove this method
     *         from the API, and this deprecation is intended to alert developers of the danger of using it.
     * @return the `Date` of the time of <em>plag hamincha</em>. If the calculation can't be computed such as in the
     *         Arctic Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis120Minutes()
     * @see getPlagHamincha26Degrees()
     */
    public func getPlagHamincha120Minutes() -> Date? {
        return getPlagHamincha(startOfDay: getAlos120Minutes(), endOfDay: getTzais120Minutes(), synchronous: true)
    }

    /**
     * Method to return <em>alos</em> (dawn) calculated as 60 minutes before ``getSunriseBasedOnElevationSetting()`` (depends on
     * the ``isUseElevation()`` setting). This is the time to walk the distance of 4 <a href=
     * "https://en.wikipedia.org/wiki/Biblical_mile">mil</a> at 15 minutes a mil. This seems to be the opinion of the <a href=
     * "https://en.wikipedia.org/wiki/Yair_Bacharach">Chavas Yair</a> in the Mekor Chaim, Orach Chaim Ch. 90, though  the Mekor Chaim
     * in Ch. 58 and in the <a href="https://hebrewbooks.org/pdfpager.aspx?req=45193&pgnum=214">Chut Hashani Ch. 97</a> states that a
     * person walks 3 and a 1/3 mil in an hour, or an 18-minute mil. Also see the <a href=
     * "https://he.wikipedia.org/wiki/%D7%9E%D7%9C%D7%9B%D7%99%D7%90%D7%9C_%D7%A6%D7%91%D7%99_%D7%98%D7%A0%D7%A0%D7%91%D7%95%D7%99%D7%9D"
     * >Divrei Malkiel</a> <a href="https://hebrewbooks.org/pdfpager.aspx?req=803&pgnum=33">Vol. 4, Ch. 20, page 34</a>) who mentions
     * the 15 minute mil <em>lechumra</em> by baking matzos. Also see the <a href=
     * "https://en.wikipedia.org/wiki/Joseph_Colon_Trabotto">Maharik</a> <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=1142&pgnum=216">Ch. 173</a> where the questioner quoting the <a href=
     * "https://en.wikipedia.org/wiki/Eliezer_ben_Nathan">Ra'avan</a> is of the opinion that the time to walk a mil is 15 minutes (5
     * mil in a little over an hour). There are many who believe that there is a <em>ta'us sofer</em> (scribe's error) in the Ra'avan,
     * and it should 4 mil in a little over an hour, or an 18-minute mil. Time based offset calculations are based on the opinions
     * that the time of the <em>neshef</em> (time between dawn and sunrise) does not vary by the time of year or location but purely
     * depends on the time it takes to walk the distance of 4* mil. ``getTzaisGeonim9Point75Degrees()`` is a related
     * <em>zman</em> that is a degree-based calculation
     * based on 60 minutes.
     *
     * @return the `Date` representing the time. If the calculation can't be computed such as in the Arctic Circle
     *         where there is at least one day a year when the sun does not rise, and one where it does not set, a `nil`
     *         will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getTzais60Minutes()
     * @see getTzaisGeonim9Point75Degrees()
     * @see getPlagHamincha60Minutes()
     * @see getShaahZmanis60Minutes()
     */
    public func getAlos60Minutes() -> Date? {
        return AstronomicalCalendar.getTimeOffset(time: getSunriseBasedOnElevationSetting(), offset: -60 * 60.0)
    }

    /**
     * Method to return <em>alos</em> (dawn) calculated using 72 minutes <em>zmaniyos</em> or 1/10th of the day before sunrise. This
     * is based on an 18-minute <a href="https://en.wikipedia.org/wiki/Biblical_mile">mil</a> so the
     * time for 4 mil is 72 minutes which is 1/10th of a day (12 * 60 = 720) based on the day being from ``getSeaLevelSunrise()``
     * to sea level sunset or ``getSunrise()`` to ``getSunset()`` (depending on the
     * ``isUseElevation()`` setting). The actual calculation is ``getSunriseBasedOnElevationSetting()`` - (``getShaahZmanisGRA()`` * 1.2). This calculation is used in the calendars published by the <a href=
     * "https://en.wikipedia.org/wiki/Central_Rabbinical_Congress">Hisachdus Harabanim D'Artzos Habris Ve'Canada</a>.
     *
     * @return the `Date` representing the time. If the calculation can't be computed such as in the Arctic Circle where
     *         there is at least one day a year when the sun does not rise, and one where it does not set, a `nil` will
     *         be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanisGRA()
     */
    public func getAlos72Zmanis() -> Date? {
        return getZmanisBasedOffset(hours: -1.2)
    }

    /**
     * Method to return <em>alos</em> (dawn) calculated using 96 minutes before ``getSunriseBasedOnElevationSetting()``
     * (depends on the ``isUseElevation()`` setting) that is based on the time to walk the distance of 4 <a href=
     * "https://en.wikipedia.org/wiki/Biblical_mile">mil</a> at 24 minutes a mil. Time based offset calculations for <em>alos</em>
     * are based on the opinion that the time of the <em>Neshef</em> (time between dawn and sunrise) does not vary by the time of
     * year or location but purely depends on the time it takes to walk the distance of 4 mil.
     *
     * @return the `Date` representing the time. If the calculation can't be computed such as in the Arctic Circle
     *         where there is at least one day a year when the sun does not rise, and one where it does not set, a `nil`
     *         will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getAlos96Minutes() -> Date? {
        return AstronomicalCalendar.getTimeOffset(time: getSunriseBasedOnElevationSetting(), offset: -96 * 60.0)
    }

    /**
     * Method to return <em>alos</em> (dawn) calculated using 90 minutes <em>zmaniyos</em> or 1/8th of the day before ``getSunrise()`` or ``getSeaLevelSunrise()`` (depending on the ``isUseElevation()`` setting). This is based on a
     * 22.5-minute <a href="https://en.wikipedia.org/wiki/Biblical_mile">mil</a> so the time for 4 mil is 90 minutes which is 1/8th
     * of a day (12 * 60) / 8 = 90. The actual calculation used is ``getSunriseBasedOnElevationSetting()`` -
     * (``getShaahZmanisGRA()`` * 1.5).
     *
     * @return the `Date` representing the time. If the calculation can't be computed such as in the Arctic Circle where
     *         there is at least one day a year when the sun does not rise, and one where it does not set, a `nil` will
     *         be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanisGRA()
     */
    public func getAlos90Zmanis() -> Date? {
        return getZmanisBasedOffset(hours: -1.5)
    }

    /**
     * This method returns <em>alos</em> (dawn) calculated using 96 minutes <em>zmaniyos</em> or 1/7.5th of the day before ``getSunriseBasedOnElevationSetting()`` (depends on the ``isUseElevation()`` setting). This is based on a 24-minute
     * <a href="https://en.wikipedia.org/wiki/Biblical_mile">mil</a> so the time for 4 mil is 96 minutes which is 1/7.5th of a day
     * (12 * 60 / 7.5 = 96). The day is calculated from ``getSunriseBasedOnElevationSetting()`` to to ``getSunsetBasedOnElevationSetting()`` (depends on the ``isUseElevation()``. The actual calculation used is ``getSunriseBasedOnElevationSetting()`` - (``getShaahZmanisGRA()`` * 1.6).
     *
     * @return the `Date` representing the time. If the calculation can't be computed such as in the Arctic Circle where
     *         there is at least one day a year when the sun does not rise, and one where it does not set, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanisGRA()
     */
    public func getAlos96Zmanis() -> Date? {
        return getZmanisBasedOffset(hours: -1.6)
    }

    /**
     * Method to return <em>alos</em> (dawn) calculated using 90 minutes before ``getSunriseBasedOnElevationSetting()``
     * (depends on the ``isUseElevation()`` setting) based on the time to walk the distance of 4 <a href=
     * "https://en.wikipedia.org/wiki/Biblical_mile">mil</a> at 22.5 minutes a mil. Time-based offset calculations for <em>alos</em>
     * are based on the opinion that the time of the <em>Neshef</em> (time between dawn and sunrise) does not vary by the time of
     * year or location but purely depends on the time it takes to walk the distance of 4 mil.
     *
     * @return the `Date` representing the time. If the calculation can't be computed such as in the Arctic Circle where there
     *         is at least one day a year when the sun does not rise, and one where it does not set, a `nil` will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getAlos90Minutes() -> Date? {
        return AstronomicalCalendar.getTimeOffset(time: getSunriseBasedOnElevationSetting(), offset: -90 * 60.0)
    }

    /**
     * This method should be used <em>lechumra</em> only and returns <em>alos</em> (dawn) calculated using 120 minutes before ``getSunriseBasedOnElevationSetting()`` (that depends on the ``isUseElevation()`` setting) based on the time to walk the
     * distance of 5 <a href="https://en.wikipedia.org/wiki/Biblical_mile">mil</a> (<em>Ula</em>) at 24 minutes a mil. Time based
     * offset calculations for <em>alos</em> are based on the* opinions that the time of the <em>neshef</em> (time between dawn and
     * sunrise) does not vary by the time of year or location but purely depends on the time it takes to walk the distance of 5 mil
     * (<em>Ula</em>). Since this time is extremely early, it should only be used <em>lechumra</em>, such as not eating after this
     * time on a fast day, and not as the start time for <em>mitzvos</em> that can only be performed during the day.
     *
     * - Warning: This method should be used <em>lechumra</em> only (such as stopping to eat at this time on a fast day),
     *         since it returns a very early time, and if used <em>lekula</em> can result in doing <em>mitzvos hayom</em>
     *         too early according to most opinions. There is no current plan to remove this method from the API, and this
     *         deprecation is intended to alert developers of the danger of using it.
     * @return the `Date` representing the time. If the calculation can't be computed such as in the Arctic Circle where
     *         there is at least one day a year when the sun does not rise, and one where it does not set, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getTzais120Minutes()
     * @see getAlos26Degrees()
     */
    public func getAlos120Minutes() -> Date? {
        return AstronomicalCalendar.getTimeOffset(time: getSunriseBasedOnElevationSetting(), offset: -120 * 60.0)
    }

    /**
     * This method should be used <em>lechumra</em> only and  method returns <em>alos</em> (dawn) calculated using
     * 120 minutes <em>zmaniyos</em> or 1/6th of the day before ``getSunriseBasedOnElevationSetting()`` (depends on the ``isUseElevation()`` setting). This is based on a 24-minute <a href="https://en.wikipedia.org/wiki/Biblical_mile">mil</a> so
     * the time for 5 mil is 120 minutes which is 1/6th of a day (12 * 60 / 6 = 120). The day is calculated from ``getSunriseBasedOnElevationSetting()`` to ``getSunsetBasedOnElevationSetting()`` (depends on the ``isUseElevation()``.
     * The actual calculation used is ``getSunset()`` - (``getShaahZmanisGRA()`` * 2). Since this time is extremely early,
     * it should only be used <em>lechumra</em>, such as not eating after this time on a fast day, and not as the start time for
     * <em>mitzvos</em> that can only be performed during the day.
     *
     * - Warning: This method should be used <em>lechumra</em> only (such as stopping to eat at this time on a fast day),
     *         since it returns a very early time, and if used <em>lekula</em> can result in doing <em>mitzvos hayom</em>
     *         too early according to most opinions. There is no current plan to remove this method from the API, and this
     *         deprecation is intended to alert developers of the danger of using it.
     * @return the `Date` representing the time. If the calculation can't be computed such as in the Arctic Circle where there
     *         is at least one day a year when the sun does not rise, and one where it does not set, a `nil` will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos120Minutes()
     * @see getAlos26Degrees()
     */
    public func getAlos120Zmanis() -> Date? {
        return getZmanisBasedOffset(hours: -2.0)
    }

    /**
     * This method should be used <em>lechumra</em> only and returns <em>alos</em> (dawn) calculated when the sun is 26° below the eastern geometric horizon before sunrise. This calculation is based on the same
     * calculation of 120 minutes but uses a degree-based calculation instead of 120 exact minutes.
     * This calculation is based on the position of the sun 120 minutes before sunrise in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>, which
     * calculates to 26° below ``AstronomicalCalendar/GEOMETRIC_ZENITH``. Since this time is extremely early, it should
     * only be used <em>lechumra</em> only, such as not eating after this time on a fast day, and not as the start time for
     * <em>mitzvos</em> that can only be performed during the day.
     *
     * - Warning: This method should be used <em>lechumra</em> only (such as stopping to eat at this time on a fast day),
     *         since it returns a very early time, and if used <em>lekula</em> can result in doing <em>mitzvos hayom</em>
     *         too early according to most opinions. There is no current plan to remove this  method from the API, and this
     *         deprecation is intended to alert developers of the danger of using it.
     * @return the `Date` representing <em>alos</em>. If the calculation can't be computed such as northern
     *         and southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun
     *         may not reach low enough below the horizon for this calculation, a `nil` will be returned. See
     *         detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos120Minutes()
     * @see getTzais120Minutes()
     * @see getTzais26Degrees()
     */
    public func getAlos26Degrees() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_26_DEGREES)
    }

    /**
     * A method to return <em>alos</em> (dawn) calculated when the sun is 18° below the
     * eastern geometric horizon before sunrise.
     *
     * @return the `Date` representing <em>alos</em>. If the calculation can't be computed such as northern
     *         and southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun
     *         may not reach low enough below the horizon for this calculation, a `nil` will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see ASTRONOMICAL_ZENITH
     */
    public func getAlos18Degrees() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: AstronomicalCalendar.ASTRONOMICAL_ZENITH)
    }

    /**
     * A method to return <em>alos</em> (dawn) calculated when the sun is 19° below the
     * eastern geometric horizon before sunrise. This is the <a href="https://en.wikipedia.org/wiki/Maimonides"
     * >Rambam</a>'s <em>alos</em> according to Rabbi Moshe Kosower's <a href=
     * "https://www.worldcat.org/oclc/145454098">Maaglei Tzedek</a>, page 88, <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=33464&pgnum=13">Ayeles Hashachar Vol. I, page 12</a>, <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=55960&pgnum=258">Yom Valayla Shel Torah, Ch. 34, p. 222</a> and
     * Rabbi Yaakov Shakow's <a href="https://www.worldcat.org/oclc/1043573513">Luach Ikvei Hayom</a>.
     *
     * @return the `Date` representing <em>alos</em>. If the calculation can't be computed such as northern
     *         and southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun
     *         may not reach low enough below the horizon for this calculation, a `nil` will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getAlos19Degrees() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_19_DEGREES)
    }

    /**
     * Method to return <em>alos</em> (dawn) calculated when the sun is 19.8° below the
     * eastern geometric horizon before sunrise. This calculation is based on the same calculation of
     * 90 minutes before sunrise, but uses a degree-based calculation instead of 90 exact minutes.
     * This calculation is based on the position of the sun 90 minutes before sunrise in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>, which
     * calculates to 19.8° below ``AstronomicalCalendar/GEOMETRIC_ZENITH``.
     *
     * @return the `Date` representing <em>alos</em>. If the calculation can't be computed such as northern
     *         and southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun
     *         may not reach low enough below the horizon for this calculation, a `nil` will be returned. See
     *         detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos90Minutes()
     * @see getTzais19Point8Degrees()
     */
    public func getAlos19Point8Degrees() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_19_POINT_8)
    }

    /**
     * This method returns <em>misheyakir</em> based on the position of the sun 12.85°
     * below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°). This is based on the position of the sun slightly
     * later than 57 minutes before ``getSunrise()`` in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>. This
     * <em>zman</em> is mentioned for use <b><em>bish'as hadchak</em></b> in the Birur Halacha <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=50535&st=&pgnum=88">Tinyana</a> and <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=50537&st=&pgnum=31">Tlisa'ah</a> in  Orach Chaim siman 18 as 12.85°.
     * Actual calculations show it to be slightly more than 12.9°, but the Birur Halacha indicates that 12.85° is a
     * slight <em>chumra</em> (on a <em>bedieved</em> time) VS the 12.9° that 57 minutes calculates as (a difference of
     * about 14 seconds at the equinox/equilux in Jerusalem). The <em>zman</em> of 12.9° is also mentioned in the Piskei
     * Tshuvos siman 18, page 190 (where a typo indicates that this is the degree equivalent to 60 minutes before sunrise,
     * when in fact at that point the sun is about 13.5° below the horizon). The 57 minute based time is mentioned by the
     * Minchas Yitzchak <a href="https://hebrewbooks.org/pdfpager.aspx?req=1601&st=&pgnum=21">vol. 9, siman 9</a> as 15 minutes
     * before <em>alos hashachar</em> (though he is not clear what location he refers to, and does not mention a degree-based
     * conversion). The Kaf Hachaim <a href="https://hebrewbooks.org/pdfpager.aspx?req=8140&st=&pgnum=81">vol.1 siman 18, no.
     * 18</a> states that in Yerushalayim 60 fixed minutes are used year round. Calculations show that 60 fixed minutes in
     * Yerushalayim ranges from 13.5° at the spring equinox to 11.5° at the summer solstice. 57-minute
     * <em>misheyakir</em> range from 12.9° at the winter equinox to 11° at the summer solstice.
     * Analysis of the difference between 12.85° and 12.9°, shows that the maximum difference occurs at the summer
     * solstice. In Lakewood, NJ at a latitude of 40.096°, the maximum difference throughout the year is 23 seconds.
     * In the winter where there is the greatest need for very early <em>misheyakir</em> times, the difference is in the 16
     * second range. Going north to Montreal at latitude 45.5°, the maximum is 29 seconds and is about 18 seconds in the
     * winter. Moving farther north to the latitude of Vilnius at a latitude of 54.68°, things change. Firstly, around the
     * summer solstice it will not reach that far below the horizon. On the dates that both can be calculated, the maximum
     * difference can be pretty high on one or two days of the year (around Jul 8),  with about a week having over a two minute
     * difference between the two. Even at the latitude of Vilna, from Dec - March, the difference is about 22 seconds.
     *
     * - Warning: This method returns a very early <em>misheyakir</em> time that should only be used <b><em>bish'as
     *         hadchak</em></b>. <em>Lechatchila</em>, a later <em>zman</em> should be used. There is no current plan to remove
     *         this method from the API, and this deprecation is intended to notify developers to add an alert to users of
     *         the risk of using it.
     * @return The `Date` of <em>misheyakir</em>. If the calculation can't be computed such as northern and
     *         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may
     *         not reach low enough below the horizon for this calculation, a `nil` will be returned. See
     *         detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see ZENITH_12_POINT_85
     */
    public func getMisheyakir12Point85Degrees() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_12_POINT_85)
    }

    /**
     * This method returns <em>misheyakir</em> based on the position of the sun when it is 11.5° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°). This calculation is used for calculating
     * <em>misheyakir</em> according to some opinions. This calculation is based on the position of the sun 52 minutes
     * before ``getSunrise()`` in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>,
     * which calculates to 11.5° below ``AstronomicalCalendar/GEOMETRIC_ZENITH``.
     * @todo recalculate.
     * @return the `Date` of <em>misheyakir</em>. If the calculation can't be computed such as northern and
     *         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may
     *         not reach low enough below the horizon for this calculation, a `nil` will be returned. See
     *         detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see ZENITH_11_POINT_5
     */
    public func getMisheyakir11Point5Degrees() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_11_POINT_5)
    }

    /**
     * This method returns <em>misheyakir</em> based on the position of the sun when it is 11° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°). This calculation is used for calculating
     * <em>misheyakir</em> according to some opinions. This calculation is based on the position of the sun 48 minutes
     * before ``getSunrise()`` in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>,
     * which calculates to 11° below ``AstronomicalCalendar/GEOMETRIC_ZENITH``.
     *
     * @return If the calculation can't be computed such as northern and southern locations even south of the Arctic Circle and north
     *         of the Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a `nil`
     *         will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see ZENITH_11_DEGREES
     */
    public func getMisheyakir11Degrees() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_11_DEGREES)
    }

    /**
     * This method returns <em>misheyakir</em> based on the position of the sun when it is 10.2° below
     * ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°). This calculation is used for calculating
     * <em>misheyakir</em> according to some opinions. This calculation is based on the position of the sun 45 minutes
     * before ``getSunrise()`` in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox</a> which calculates
     * to 10.2° below ``AstronomicalCalendar/GEOMETRIC_ZENITH``.
     *
     * @return the `Date` of <em>misheyakir</em>. If the calculation can't be computed such as
     *         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
     *         the sun may not reach low enough below the horizon for this calculation, a `nil` will be returned
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see ZENITH_10_POINT_2
     */
    public func getMisheyakir10Point2Degrees() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_10_POINT_2)
    }

    /**
     * This method returns <em>misheyakir</em> based on the position of the sun when it is 7.65° below
     * ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°). The degrees are based on a 35/36 minute <em>zman</em> <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>, when the
     * <em>neshef</em> (twilight) is the shortest. This time is based on <a href=
     * "https://en.wikipedia.org/wiki/Moshe_Feinstein">Rabbi Moshe Feinstein</a> who writes in <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=14677&pgnum=7">Ohr Hachaim Vol. 4, Ch. 6</a> that <em>misheyakir</em> in New York
     * is 35-40 minutes before sunrise, something that is a drop less than 8°. <a href="https://en.wikipedia.org/wiki/Yisroel_Taplin"
     * >Rabbi Yisroel Taplin</a> in <a href="https://www.worldcat.org/oclc/889556744">Zmanei Yisrael</a> (page 117) notes that
     * <a href="https://en.wikipedia.org/wiki/Yaakov_Kamenetsky">Rabbi Yaakov Kamenetsky</a> stated that it is not less than 36
     * minutes before sunrise (maybe it is 40 minutes). Sefer Yisrael Vehazmanim (p. 7) quotes the Tamar Yifrach in the name of the
     * <a href="https://en.wikipedia.org/wiki/Joel_Teitelbaum">Satmar Rov</a> that one should be stringent not consider
     * <em>misheyakir</em> before 36 minutes. This is also the accepted <a href="https://en.wikipedia.org/wiki/Minhag">minhag</a> in
     * <a href="https://en.wikipedia.org/wiki/Lakewood_Township,_New_Jersey">Lakewood</a> that is used in the <a href=
     * "https://en.wikipedia.org/wiki/Beth_Medrash_Govoha">Yeshiva</a>. This follows the opinion of <a href=
     * "https://en.wikipedia.org/wiki/Shmuel_Kamenetsky">Rabbi Shmuel Kamenetsky</a> who provided the time of 35/36 minutes, but did
     * not provide a degree-based time. Since this <em>zman</em> depends on the level of light, Rabbi Yaakov Shakow presented this
     * degree-based calculations to Rabbi Shmuel Kamenetsky who agreed to them.
     *
     * @return the `Date` of <em>misheyakir</em>. If the calculation can't be computed such as
     *         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
     *         the sun may not reach low enough below the horizon for this calculation, a `nil` will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see ZENITH_7_POINT_65
     * @see getMisheyakir9Point5Degrees()
     */
    public func getMisheyakir7Point65Degrees() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_7_POINT_65)
    }

    /**
     * This method returns <em>misheyakir</em> based on the position of the sun when it is 9.5° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°). This calculation is based on <a href=
     * "https://en.wikipedia.org/wiki/Dovid_Kronglas">Rabbi Dovid Kronglass's</a> Calculation of 45 minutes in Baltimore
     * as mentioned in <a href="https://hebrewbooks.org/pdfpager.aspx?req=20287&pgnum=29">Divrei Chachamim No. 24</a>
     * brought down by the <a href="https://hebrewbooks.org/pdfpager.aspx?req=50535&pgnum=87">Birur Halacha, Tinyana, Ch.
     * 18</a>. This calculates to 9.5°. Also see <a href="https://en.wikipedia.org/wiki/Jacob_Isaac_Neiman">Rabbi Yaakov
     * Yitzchok Neiman</a> in Kovetz Eitz Chaim Vol. 9, p. 202 that the Vya'an Yosef did not want to rely on times earlier
     * than 45 minutes in New York. This <em>zman</em> is also used in the calendars published by Rabbi Hershel Edelstein.
     * As mentioned in Yisroel Vehazmanim, Rabbi Edelstein who was given the 45 minute <em>zman</em> by Rabbi Bick. The
     * calendars published by the <em><a href="https://en.wikipedia.org/wiki/Mizrahi_Jews">Edot Hamizrach</a></em> communities
     * also use this <em>zman</em>. This also follows the opinion of <a href="https://en.wikipedia.org/wiki/Shmuel_Kamenetsky"
     * >Rabbi Shmuel Kamenetsky</a> who provided the time of 36 and 45 minutes, but did not provide a degree-based time. Since
     * this <em>zman</em> depends on the level of light, Rabbi Yaakov Shakow presented these degree-based times to Rabbi Shmuel
     * Kamenetsky who agreed to them.
     *
     * @return the `Date` of <em>misheyakir</em>. If the calculation can't be computed such as
     *         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
     *         the sun may not reach low enough below the horizon for this calculation, a `nil` will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see ZENITH_9_POINT_5
     * @see getMisheyakir7Point65Degrees()
     */
    public func getMisheyakir9Point5Degrees() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_9_POINT_5)
    }

    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite Shema in the morning) according to the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on
     * <em>alos</em> being 19.8° before ``getSunrise()``. This
     * time is 3 <em>shaos zmaniyos</em> (solar hours) after dawn based on the opinion of the MGA that the day is calculated from dawn to nightfall
     * with both being 19.8° below sunrise or sunset. This returns the time of 3 *
     * ``getShaahZmanis19Point8Degrees()`` after dawn.
     *
     * @return the `Date` of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis19Point8Degrees()
     * @see getAlos19Point8Degrees()
     */
    public func getSofZmanShmaMGA19Point8Degrees() -> Date? {
        return getSofZmanShma(startOfDay: getAlos19Point8Degrees(), endOfDay: getTzais19Point8Degrees(), synchronous: true)
    }

    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite Shema in the morning) according to the opinion of
     * the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on <em>alos</em> being 16.1° before ``getSunrise()``. This time is 3 <em>shaos zmaniyos</em> (solar hours) after dawn based on
     * the opinion of the MGA that the day is calculated from dawn to nightfall with both being 16.1° below sunrise or sunset.
     * This returns the time of 3 * ``getShaahZmanis16Point1Degrees()`` after dawn.
     *
     * @return the `Date` of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis16Point1Degrees()
     * @see getAlos16Point1Degrees()
     */
    public func getSofZmanShmaMGA16Point1Degrees() -> Date? {
        return getSofZmanShma(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzais16Point1Degrees(), synchronous: true)
    }

    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite Shema in the morning) according to the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based
     * on <em>alos</em> being 18° before ``getSunrise()``. This time is 3
     * <em>shaos zmaniyos</em> (solar hours) after dawn
     * based on the opinion of the MGA that the day is calculated from dawn to nightfall with both being 18°
     * below sunrise or sunset. This returns the time of 3 * ``getShaahZmanis18Degrees()`` after
     * dawn.
     *
     * @return the `Date` of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis18Degrees()
     * @see getAlos18Degrees()
     */
    public func getSofZmanShmaMGA18Degrees() -> Date? {
        return getSofZmanShma(startOfDay: getAlos18Degrees(), endOfDay: getTzais18Degrees(), synchronous: true)
    }

    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite <em>Shema</em> in the morning) according
     * to the opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based
     * on <em>alos</em> being 72 minutes <em>zmaniyos</em>, or 1/10th of the day before
     * ``getSunrise()``. This time is 3 <em>shaos zmaniyos</em>
     * (solar hours) after dawn based on the opinion of the MGA that the day is calculated
     * from a dawn of 72 minutes <em>zmaniyos</em>, or 1/10th of the day before
     * sea level sunrise to nightfall of 72 minutes
     * <em>zmaniyos</em> after sea level sunset. This returns the time of 3 *
     * ``getShaahZmanis72MinutesZmanis()`` after dawn.
     *
     * @return the `Date` of the latest <em>zman krias shema</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a `nil`
     *         will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis72MinutesZmanis()
     * @see getAlos72Zmanis()
     * @see isUseAstronomicalChatzosForOtherZmanim()
     */
    public func getSofZmanShmaMGA72MinutesZmanis() -> Date? {
        return getSofZmanShma(startOfDay: getAlos72Zmanis(), endOfDay: getTzais72Zmanis(), synchronous: true)
    }

    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite <em>Shema</em> in the morning) according
     * to the opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on
     * <em>alos</em> being 90 minutes before ``getSunrise()``. This time is 3
     * <em>shaos zmaniyos</em> (solar hours) after dawn based on
     * the opinion of the MGA that the day is calculated from a dawn of 90 minutes before sunrise to
     * nightfall of 90 minutes after sunset. This returns the time of 3 *
     * ``getShaahZmanis90Minutes()`` after dawn.
     *
     * @return the `Date` of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year when the sun does not rise, and one where
     *         it does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis90Minutes()
     * @see getAlos90Minutes()
     * @see isUseAstronomicalChatzosForOtherZmanim()
     */
    public func getSofZmanShmaMGA90Minutes() -> Date? {
        return getSofZmanShma(startOfDay: getAlos90Minutes(), endOfDay: getTzais90Minutes(), synchronous: true)
    }

    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite Shema in the morning) according to the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based
     * on <em>alos</em> being 90 minutes <em>zmaniyos</em> before sunrise. This time is 3 <em>shaos zmaniyos</em> (solar hours) after
     * dawn based on the opinion of the MGA that the day is calculated from a dawn of 90 minutes <em>zmaniyos</em> before sunrise to nightfall
     * of 90 minutes <em>zmaniyos</em> after sunset. This returns the time of 3 * ``getShaahZmanis90MinutesZmanis()``
     * after dawn.
     *
     * @return the `Date` of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year when the sun does not rise, and one where
     *         it does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis90MinutesZmanis()
     * @see getAlos90Zmanis()
     * @see isUseAstronomicalChatzosForOtherZmanim()
     */
    public func getSofZmanShmaMGA90MinutesZmanis() -> Date? {
        return getSofZmanShma(startOfDay: getAlos90Zmanis(), endOfDay: getTzais90Zmanis(), synchronous: true)
    }

    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite Shema in the morning) according to the opinion of
     * the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on <em>alos</em> being 96 minutes before ``getSunrise()``. This time is 3 <em>shaos zmaniyos</em> (solar hours) after dawn based on the opinion
     * of the MGA that the day is calculated from a dawn of 96 minutes before sunrise to nightfall of 96 minutes after sunset. This returns the time of 3 * ``getShaahZmanis96Minutes()``
     * after dawn.
     *
     * @return the `Date` of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year when the sun does not rise, and one where
     *         it does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis96Minutes()
     * @see getAlos96Minutes()
     * @see isUseAstronomicalChatzosForOtherZmanim()
     */
    public func getSofZmanShmaMGA96Minutes() -> Date? {
        return getSofZmanShma(startOfDay: getAlos96Minutes(), endOfDay: getTzais96Minutes(), synchronous: true)
    }

    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite Shema in the morning) according to the opinion of the
     * <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on <em>alos</em> being 96 minutes <em>zmaniyos</em> before ``getSunrise()``. This time is 3 <em>shaos zmaniyos</em> (solar hours) after dawn based on the
     * opinion of the MGA that the day is calculated from a dawn of 96 minutes <em>zmaniyos</em> before
     * sunrise to nightfall of 96 minutes <em>zmaniyos</em> after sunset. This returns the time of 3 *
     * ``getShaahZmanis96MinutesZmanis()`` after dawn.
     *
     * @return the `Date` of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year when the sun does not rise, and one where
     *         it does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis96MinutesZmanis()
     * @see getAlos96Zmanis()
     * @see isUseAstronomicalChatzosForOtherZmanim()
     */
    public func getSofZmanShmaMGA96MinutesZmanis() -> Date? {
        return getSofZmanShma(startOfDay: getAlos96Zmanis(), endOfDay: getTzais96Zmanis(), synchronous: true)
    }

    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite <em>Shema</em> in the morning) calculated as 3 hours
     * (regular clock hours and not <em>shaos zmaniyos</em>) before ``getChatzosHayom()``. Generally known as part of the
     * "Komarno" <em>zmanim</em> after <a href="https://en.wikipedia.org/wiki/Komarno_(Hasidic_dynasty)#Rabbi_Yitzchak_Eisik_Safrin"
     * >Rav Yitzchak Eizik of Komarno</a>, a proponent of this calculation, it actually predates him a lot. It is the opinion of the
     * <em>Shach</em> in the Nekudas Hakesef (Yoreh Deah 184), <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=21638&st=&pgnum=30">Rav Moshe Lifshitz</a> in his commentary <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=21638&st=&pgnum=50">Lechem Mishneh on Brachos 1:2</a>. It is next brought down
     * about 100 years later by the <a href="https://en.wikipedia.org/wiki/Jacob_Emden">Yaavetz</a> (in his <em>siddur</em>,
     * <a href="https://hebrewbooks.org/pdfpager.aspx?req=7920&st=&pgnum=6">Mor Uktziah Orach
     * Chaim 1</a>, <a href="https://hebrewbooks.org/pdfpager.aspx?req=22309&st=&pgnum=30">Lechem Shamayim, Brachos 1:2</a> and
     * <a href="https://hebrewbooks.org/pdfpager.aspx?req=1408&st=&pgnum=69">She'elos Yaavetz vol. 1 no. 40</a>), Rav Yitzchak Eizik
     * of Komarno in the Ma'aseh Oreg on Mishnayos Brachos 11:2, Shevus Yaakov, Chasan Sofer and others. See Yisrael Vehazmanim
     * <a href="https://hebrewbooks.org/pdfpager.aspx?req=9765&st=&pgnum=83">vol. 1 7:3, page 55 - 62</a>. If the calculated time
     * is before sunrise (on short winter days), a `nil` will be returned.
     *
     * @return the `Date` of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year when the sun does not rise, and one where
     *         it does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getChatzosHayom()
     * @see getSofZmanTfila2HoursBeforeChatzos()
     * @see isUseAstronomicalChatzos()
     */
    public func getSofZmanShma3HoursBeforeChatzos() -> Date? {
        let sofZmanShma: Date? = AstronomicalCalendar.getTimeOffset(time: getChatzosHayom(), offset: -3 * 3600.0)
        let sunrise: Date? = getSunriseBasedOnElevationSetting()
        // On a short winter day, 3 hours before chatzos is before sunrise
        if sofZmanShma != nil && sunrise != nil && sofZmanShma!.isBefore(sunrise!) {
            return nil
        }
        return sofZmanShma
    }

    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite Shema in the morning) according to the opinion of the
     * <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on <em>alos</em> being 120 minutes or 1/6th of the day before ``getSunrise()``. This time is 3 <em>shaos zmaniyos</em> (solar hours) after dawn based on the
     * opinion of the MGA that the day is calculated from a dawn of 120 minutes before sunrise to nightfall of 120 minutes after sunset. This returns the time of 3 ``getShaahZmanis120Minutes()``
     * after dawn. This is an extremely early <em>zman</em> that is very much a <em>chumra</em>.
     *
     * @return the `Date` of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year when the sun does not rise, and one where
     *         it does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis120Minutes()
     * @see getAlos120Minutes()
     * @see isUseAstronomicalChatzosForOtherZmanim()
     */
    public func getSofZmanShmaMGA120Minutes() -> Date? {
        return getSofZmanShma(startOfDay: getAlos120Minutes(), endOfDay: getTzais120Minutes(), synchronous: true)
    }

    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite <em>Shema</em> in the morning) based on the opinion
     * that the day starts at <em>alos</em> 16.1° and ends at sea level sunset. This is the opinion of the <a href=
     * "https://hebrewbooks.org/40357">חידושי וכללות הרז״ה</a> in <a href="https://hebrewbooks.org/pdfpager.aspx?req=40357&pgnum=71"
     * >סימן ב׳ סע״ג וסע״ד</a> and <a href="https://hebrewbooks.org/pdfpager.aspx?req=40357&pgnum=93">סי׳ ז׳ סע״ב</a> and the <a href=
     * "https://hebrewbooks.org/14799">מנורה הטהורה</a> as mentioned by <span>ישראל והזמנים</span> <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=9765&pgnum=81">ח״א סי׳ ז׳ פ״ג או׳ ט״ז</a>. Also see <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=67890&pgnum=29">אשר לשלמה, מועד, סי׳ ה׳</a>. Three <em>shaos zmaniyos</em> are calculated
     * based on this day and added to <em>alos</em> to reach this time. This time is 3 <em>shaos
     * zmaniyos</em> (solar hours) after ``getAlos16Point1Degrees()`` based on the opinion that the day is calculated from
     * <em>alos</em> 16.1° to ``getSeaLevelSunset()``. <b>Note: </b> Based on this calculation <em>chatzos</em> will not be at
     * midday and ``isUseAstronomicalChatzosForOtherZmanim()`` will be ignored. Sources for an asymmetrical day-based
     * calculation can be seen in the documentation of ``getSofZmanShmaAlos16Point1DegreesToTzaisGeonim7Point083Degrees``.
     *
     * @return the `Date` of the latest <em>zman krias shema</em> based on this day. If the calculation can't
     *         be computed such as northern and southern locations even south of the Arctic Circle and north of the
     *         Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a `nil`
     *         will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos16Point1Degrees()
     * @see getSeaLevelSunset()
     */
    public func getSofZmanShmaAlos16Point1ToSunset() -> Date? {
        return getSofZmanShma(startOfDay: getAlos16Point1Degrees(), endOfDay: getSunsetBasedOnElevationSetting(), synchronous: false)
    }

    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite Shema in the morning) based on the opinion that the
     * day is an asymmetrical day that starts at <em>alos</em> 16.1° and ends at <em>tzais</em> 7.083°. 3 <em>shaos zmaniyos</em> (temporal hours) are calculated based on
     * this day and added to <em>alos</em> to reach this time. Sefer <a href=
     * "https://hebrewbooks.org/9765">Yisroel</a> <a href="https://hebrewbooks.org/9764">Vehazmanim</a> V. III in the explanation of
     * <a href="https://hebrewbooks.org/pdfpager.aspx?req=9764&st=&pgnum=260"><em>zman</em> no. 22 on page 1015</a> attributes the
     * origin of this <em>zman</em> to <a href="https://en.wikipedia.org/wiki/Jacob_al-Faraji">Rabbi Yaakov al-Faraji's</a> <a href=
     * "https://hebrewbooks.org/1151">שו״ת מהרי״ף</a> (who discusses <em>zmanim</em> in various places including chapters 6, 46, 47
     * and 49), <a href="https://en.wikipedia.org/wiki/Joseph_Schwarz_(geographer)">Rabbi Yehosef Schwarz</a> in the <a href=
     * "https://hebrewbooks.org/31703">דברי יוסף</a> in the name of <a href="https://en.wikipedia.org/wiki/Nathan_Adler"
     * >Rabbi Nosson Adler</a>, the <a href="https://en.wikipedia.org/wiki/Yosef_Hayyim">Ben Ish Chai</a> in <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=14054&st=&pgnum=108">שנה א׳ פ׳ ויקהל</a>, <a href=
     * "https://he.wikipedia.org/wiki/%D7%A0%D7%A1%D7%99%D7%9D_%D7%9B%D7%93%D7%95%D7%A8%D7%99_%D7%97%D7%96%D7%9F">Rabbi Nissim
     * Kaduri Chazan's</a> <a href="https://www.nli.org.il/he/books/NNL_ALEPH990019649990205171/NLI">מעשה נסים</a> (in the calendar at
     * the end), <a href="https://he.wikipedia.org/wiki/%D7%9E%D7%A6%D7%9C%D7%99%D7%97_%D7%9E%D7%90%D7%96%D7%95%D7%96">Rabbi Matzliach
     * Mazuz's</a> שו״ת איש מצליח, in Dr. Baruch (Berthold) Cohn's <em>luach</em> <a href=
     * "https://sammlungen.ub.uni-frankfurt.de/freimann/content/titleinfo/983088">Tabellen enthaltend die Zeitangaben für den Beginn
     * der Nacht und des Tages für die Breitengrade + 66 bis -38</a>, שו״ת תשובות והנהגות ח״א <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=20025&st=&pgnum=50">no. 55</a> and <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=20025&st=&pgnum=218">307</a> (<em>lechumra</em> in the name of the <a href=
     * "https://en.wikipedia.org/wiki/Yehoshua_Leib_Diskin">מהרי״ל דיסקין</a> and others) who calculate <em>shaos zmaniyos</em> based on
     * an asymmetrical day from an early <em>alos</em> to an early <em>tzais</em> <b>Note: </b> Based on this calculation
     * <em>chatzos</em> will not be at midday and ``isUseAstronomicalChatzosForOtherZmanim()`` will be ignored. There are many
     * variations of this type of zman, with varying start and end times. The Yisroel Vehazmanim gave this as a relatively common one.
     * Variations using this library are very simple. For example to calculate <em>sof zman krias shema</em> starting the day at the
     * Rambam's alos of 18° and ending it at 3.7°, use the following code.
     * ```
     * Instant sofZmanKS = czc.getSofZmanShma(czc.getAlos18Degrees(), czc.getTzaisGeonim3Point7Degrees(), false);
     * ```
     *
     * @return the `Date` of the latest <em>zman krias shema</em> based on this calculation. If the calculation can't be
     *         computed such as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
     *         the sun may not reach low enough below the horizon for this calculation, a `nil` will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos16Point1Degrees()
     * @see getTzaisGeonim7Point083Degrees()
     * @see getPlagAlos16Point1DegreesToTzaisGeonim7Point083Degrees()
     * @see getShaahZmanisAlos16Point1DegreesToTzaisGeonim7Point083Degrees()
     */
    public func getSofZmanShmaAlos16Point1DegreesToTzaisGeonim7Point083Degrees() -> Date? {
        return getSofZmanShma(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzaisGeonim7Point083Degrees(), synchronous: false)
    }

    /**
     * This method returns the latest <em>zman tfila</em> (time to recite the morning prayers) according to the opinion of the
     * <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on <em>alos</em> being 19.8° before ``getSunrise()``. This time is 4 ``getShaahZmanis19Point8Degrees()`` after
     * ``getAlos19Point8Degrees()`` based on the opinion that the day is calculated from dawn to nightfall with both being 19.8°
     * below sunrise or sunset.
     *
     * @return the `Date` of the latest <em>zman tfila</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis19Point8Degrees()
     * @see getAlos19Point8Degrees()
     * @see isUseAstronomicalChatzosForOtherZmanim()
     */
    public func getSofZmanTfilaMGA19Point8Degrees() -> Date? {
        return getSofZmanTfila(startOfDay: getAlos19Point8Degrees(), endOfDay: getTzais19Point8Degrees(), synchronous: true)
    }

    /**
     * This method returns the latest <em>zman tfila</em> (time to recite the morning prayers) according to the opinion of the
     * <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on * <em>alos</em> being 16.1° before ``getSunrise()``. This time is 4 ``getShaahZmanis16Point1Degrees()`` after
     * ``getAlos16Point1Degrees()`` based on the opinion that the day is calculated from dawn to nightfall with both being 16.1°
     * below sunrise or sunset.
     *
     * @return the `Date` of the latest <em>zman tfila</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis16Point1Degrees()
     * @see getAlos16Point1Degrees()
     */
    public func getSofZmanTfilaMGA16Point1Degrees() -> Date? {
        return getSofZmanTfila(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzais16Point1Degrees(), synchronous: true)
    }

    /**
     * This method returns the latest <em>zman tfila</em> (time to recite the morning prayers) according to the opinion of the
     * <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on <em>alos</em> being ``getAlos18Degrees()`` before ``getSunrise()``. This time is 4 ``getShaahZmanis18Degrees()`` after dawn based on the opinion that the day is calculated from dawn to nightfall with both being 18° below
     * sunrise and sunset.
     *
     * @return the `Date` of the latest <em>zman tfila</em>. If the calculation can't be computed such as northern and
     *         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not reach low
     *         enough below the horizon for this calculation, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis18Degrees()
     * @see getAlos18Degrees()
     */
    public func getSofZmanTfilaMGA18Degrees() -> Date? {
        return getSofZmanTfila(startOfDay: getAlos18Degrees(), endOfDay: getTzais18Degrees(), synchronous: true)
    }

    /**
     * This method returns the latest <em>zman tfila</em> (time to the morning prayers) according to the opinion of the
     * <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on <em>alos</em>
     * being ``getAlos72Zmanis()`` 72 minutes <em>zmaniyos</em> or a 10th of the day before ``getSunrise()``. This time
     * is 4 ``getShaahZmanis72MinutesZmanis()`` after ``getAlos72Zmanis()`` based on the opinion that the day is calculated
     * from a ``getAlos72Zmanis()`` before sunrise to ``getTzais72Zmanis()`` of 72 minutes <em>zmaniyos</em> after sunset.
     *
     * @return the `Date` of the latest <em>zman tfila</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a `nil`
     *         will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis72MinutesZmanis()
     * @see getAlos72Zmanis()
     */
    public func getSofZmanTfilaMGA72MinutesZmanis() -> Date? {
        return getSofZmanTfila(startOfDay: getAlos72Zmanis(), endOfDay: getTzais72Zmanis(), synchronous: true)
    }

    /**
     * This method returns the latest <em>zman tfila</em> (time to recite the morning prayers) according to the opinion of the
     * <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on <em>alos</em> being ``getAlos90Minutes()`` minutes before ``getSunrise()``. This time is 4 ``getShaahZmanis90Minutes()`` after ``getAlos90Minutes()`` based on the opinion that the day is calculated from a ``getAlos90Minutes()`` before sunrise to
     * ``getTzais90Minutes()`` after sunset.
     *
     * @return the `Date` of the latest <em>zman tfila</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a `nil`
     *         will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis90Minutes()
     * @see getAlos90Minutes()
     */
    public func getSofZmanTfilaMGA90Minutes() -> Date? {
        return getSofZmanTfila(startOfDay: getAlos90Minutes(), endOfDay: getTzais90Minutes(), synchronous: true)
    }

    /**
     * This method returns the latest <em>zman tfila</em> (time to the morning prayers) according to the opinion of the <a href=
     * "https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on <em>alos</em> being ``getAlos90Zmanis()`` 90 minutes <em>zmaniyos</em> or 1/8th of the day before ``getSunrise()``. This time is 4 ``getShaahZmanis90MinutesZmanis()`` after ``getAlos90Zmanis()`` based on the opinion that the day is calculated from a ``getAlos90Zmanis()`` to ``getTzais90Zmanis()``.
     *
     * @return the `Date` of the latest <em>zman tfila</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a `nil`
     *         will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis90MinutesZmanis()
     * @see getAlos90Zmanis()
     */
    public func getSofZmanTfilaMGA90MinutesZmanis() -> Date? {
        return getSofZmanTfila(startOfDay: getAlos90Zmanis(), endOfDay: getTzais90Zmanis(), synchronous: true)
    }

    /**
     * This method returns the latest <em>zman tfila</em> (time to recite the morning prayers) according to the opinion
     * of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on
     * <em>alos</em> being ``getAlos96Minutes()`` minutes before ``getSunrise()``. This time is 4
     * <em>shaos zmaniyos</em> (solar hours) after dawn based on
     * the opinion of the MGA that the day is calculated from a dawn of 96 minutes before
     * sunrise to nightfall of 96 minutes after sunset. This returns the time of 4 *
     * ``getShaahZmanis96Minutes()`` after dawn.
     *
     * @return the `Date` of the latest <em>zman tfila</em>. If the calculation can't be computed such as in the Arctic Circle
     *         where there is at least one day a year when the sun does not rise, and one where it does not set, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis96Minutes()
     * @see getAlos96Minutes()
     */
    public func getSofZmanTfilaMGA96Minutes() -> Date? {
        return getSofZmanTfila(startOfDay: getAlos96Minutes(), endOfDay: getTzais96Minutes(), synchronous: true)
    }

    /**
     * This method returns the latest <em>zman tfila</em> (time to the morning prayers) according to the opinion of the <a href=
     * "https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on <em>alos</em> being ``getAlos96Zmanis()`` 96 minutes <em>zmaniyos</em> before ``getSunrise()``. This time is 4 ``getShaahZmanis96MinutesZmanis()`` after ``getAlos96Zmanis()`` based on the opinion that the day is calculated from a
     * ``getAlos96Zmanis()`` before sunrise to ``getTzais96Zmanis()`` after sunset. This returns the time of 4 * ``getShaahZmanis96MinutesZmanis()`` after ``getAlos96Zmanis()``.
     *
     * @return the `Date` of the latest <em>zman tfila</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a `nil`
     *         will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis96MinutesZmanis()
     * @see getAlos96Zmanis()
     */
    public func getSofZmanTfilaMGA96MinutesZmanis() -> Date? {
        return getSofZmanTfila(startOfDay: getAlos96Zmanis(), endOfDay: getTzais96Zmanis(), synchronous: true)
    }

    /**
     * This method returns the latest <em>zman tfila</em> (time to recite the morning prayers) according to the opinion of the
     * <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on <em>alos</em> being ``getAlos120Minutes()`` before ``getSunrise()`` . This time is 4 ``getShaahZmanis120Minutes()`` after ``getAlos120Minutes()`` based on the opinion that the day is calculated from a ``getAlos120Minutes()``, 120 minutes before
     * sunrise to ``getTzais120Minutes()``, 120 minutes after sunset. This is an extremely early <em>zman</em> that is very
     * stringent <em>chumra</em>.
     *
     * @return the `Date` of the latest <em>zman tfila</em>. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year when the sun does not rise, and one where
     *         it does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis120Minutes()
     * @see getAlos120Minutes()
     */
    public func getSofZmanTfilaMGA120Minutes() -> Date? {
        return getSofZmanTfila(startOfDay: getAlos120Minutes(), endOfDay: getTzais120Minutes(), synchronous: true)
    }

    /**
     * This method returns the latest <em>zman tfila</em> (time to recite the morning prayers) calculated as 2 hours before ``getChatzosHayom()``. This is based on the opinions that calculate <em>sof zman krias shema</em> as ``getSofZmanShma3HoursBeforeChatzos()``. This returns the time of 2 hours before ``getChatzosHayom()``. If the calculated
     * time is before sunrise (on short winter days), a `nil` will be returned.
     *
     * @return the `Date` of the latest <em>zman tfila</em>. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year when the sun does not rise, and one where
     *         it does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getChatzosHayom()
     * @see getSofZmanShma3HoursBeforeChatzos()
     */
    public func getSofZmanTfila2HoursBeforeChatzos() -> Date? {
        let sofZmanTfila: Date? = AstronomicalCalendar.getTimeOffset(time: getChatzosHayom(), offset: -2 * 3600.0)
        let sunrise: Date? = getSunriseBasedOnElevationSetting()
        // On a short winter day, 2 hours before chatzos is before sunrise
        if sofZmanTfila != nil && sunrise != nil && sofZmanTfila!.isBefore(sunrise!) {
            return nil
        }
        return sofZmanTfila
    }

    /**
     * This method returns <em>mincha gedola</em> calculated as 30 minutes after <em>chatzos</em>
     * and not 1/2 of a <em>shaah zmanis</em> after <em>chatzos</em> as
     * calculated by ``getMinchaGedola``. Some use this time to delay the start of <em>mincha</em> in the winter when
     * 1/2 of a <em>shaah zmanis</em> is less than 30 minutes. See ``getMinchaGedolaGreaterThan30()`` for a convenience method that returns the later of the 2 calculations. One should not
     * use this time to start <em>mincha</em> before the standard <em>mincha gedola</em>. See Shulchan
     * Aruch <a href="https://hebrewbooks.org/pdfpager.aspx?req=49624&st=&pgnum=291">Orach Chayim 234:1</a> and the Shaar Hatziyon
     * <em>seif katan ches</em>. Since this calculation is a fixed 30 minutes of regular clock time after <em>chatzos</em>, even if
     * ``isUseAstronomicalChatzosForOtherZmanim()`` is `false`, this <em>mincha gedola</em> time will be affected by
     * ``isUseAstronomicalChatzos()`` and not by ``isUseAstronomicalChatzosForOtherZmanim()``. If the calculated time is
     * after sunset (on short Polar days), a `nil` will be returned.
     *
     * @return the `Date` of 30 minutes after <em>chatzos</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a `nil`
     *         will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @todo Consider adjusting this to calculate the time as half an hour after ``getChatzosHayom()`` that uses
     *         ``isUseAstronomicalChatzos()`` to determine the type of <em>chatzos</em> to utilize. that support it,
     *         based on ``isUseAstronomicalChatzos()``.
     * @see getMinchaGedolaGRA()
     * @see getMinchaGedolaGreaterThan30(Instant)
     * @see getChatzosHayom()
     * @see isUseAstronomicalChatzos()
     * @see isUseAstronomicalChatzosForOtherZmanim()
     */
    public func getMinchaGedola30Minutes() -> Date? {
        let minchaGedola30: Date? = AstronomicalCalendar.getTimeOffset(time: getChatzosHayom(), offset: 30 * 60.0)
        let sunset: Date? = getSunsetBasedOnElevationSetting()
        if minchaGedola30 != nil && sunset != nil && minchaGedola30!.isAfter(sunset!) { // very short polar day: 30 minutes after chatzos is already night
            return nil
        }
        return minchaGedola30
    }

    /**
     * This method returns the time of <em>mincha gedola</em> according to the Magen Avraham with the day starting 72
     * minutes before sunrise and ending 72 minutes after sunset. This is the earliest time to pray <em>mincha</em>. For
     * more information on this see the documentation on <em>mincha gedola</em>. This is
     * calculated as 6.5 solar hours after <em>alos</em>. The calculation used is 6.5 *
     * ``getShaahZmanis72Minutes()`` after <em>alos</em>. If ``isUseAstronomicalChatzosForOtherZmanim()`` is set to `true`, the calculation will be based on 0.5
     * half-day based <em>sha'ah zmanis</em> between
     * ``getChatzosHayom()`` and ``getTzais72Minutes()`` after ``getChatzosHayom()``.
     *
     * @see getAlos72Minutes()
     * @see getMinchaGedolaGRA()
     * @see getMinchaKetanaGRA()
     * @see getMinchaGedolaGRA()
     * @see getChatzosHayom()
     * @see isUseAstronomicalChatzosForOtherZmanim()
     * @return the `Date` of the time of <em>mincha gedola</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a `nil`
     *         will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getMinchaGedola72Minutes() -> Date? {
        if isUseAstronomicalChatzosForOtherZmanim() {
            return getHalfDayBasedZman(startOfHalfDay: getChatzosHayom(), endOfHalfDay: getTzais72Minutes(), hours: 0.5)
        } else {
            return getMinchaGedola(startOfDay: getAlos72Minutes(), endOfDay: getTzais72Minutes(), synchronous: true)
        }
    }

    /**
     * This method returns the time of <em>mincha gedola</em> according to the Magen Avraham with the day starting and ending 16.1°
     * below the horizon. This is the earliest time to pray <em>mincha</em>. For more information on <em>mincha gedola</em>, see
     * ``getMinchaGedolaGRA()``. This is calculated as 6.5 ``getShaahZmanis16Point1Degrees()`` after <em>alos</em>. If
     * ``isUseAstronomicalChatzosForOtherZmanim()`` is set to `true`, the calculation will be based on 0.5 half-day based <em>sha'ah zmanis</em> between ``getChatzosHayom()`` and
     * ``getAlos16Point1Degrees()`` after ``getChatzosHayom()``.
     * @return the `Date` of the time of <em>mincha gedola</em>. If the calculation can't be computed such as
     *         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
     *         the sun  may not reach low enough below the horizon for this calculation, a `nil` will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis16Point1Degrees()
     * @see getMinchaGedolaGRA()
     * @see getMinchaKetanaGRA()
     */
    public func getMinchaGedola16Point1Degrees() -> Date? {
        if isUseAstronomicalChatzosForOtherZmanim() {
            return getHalfDayBasedZman(startOfHalfDay: getChatzosHayom(), endOfHalfDay: getTzais16Point1Degrees(), hours: 0.5)
        } else {
            return getMinchaGedola(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzais16Point1Degrees(), synchronous: true)
        }
    }

    /**
     * This method returns the time of <em>mincha gedola</em> based on the opinion of <a href=
     * "https://en.wikipedia.org/wiki/Yaakov_Moshe_Hillel">Rabbi Yaakov Moshe Hillel</a> as published in the <em>luach</em> of the
     * Bais Horaah of Yeshivat Chevrat Ahavat Shalom that <em>mincha gedola</em> is calculated as half a <em>shaah zmanis</em> after
     * <em>chatzos</em> with <em>shaos zmaniyos</em> calculated based on a day starting at ``getAlos16Point1Degrees()`` and
     * ending at ``getTzaisGeonim3Point7Degrees()``. The later of this time or 30 clock minutes after <em>chatzos</em> is
     * returned. See ``getMinchaGedolaGreaterThan30()`` for a way to calculate the later of 30 minutes or this <em>mincha
     * gedola</em>. For more information about <em>mincha gedola</em> see the documentation on <em>mincha gedola</em>. Since calculation of this <em>zman</em> involves <em>chatzos</em> that is offset from the center of
     * the astronomical day, ``isUseAstronomicalChatzosForOtherZmanim()`` is N/A here. Sources for an asymmetrical day-based
     * calculation can be seen in the documentation of ``getSofZmanShmaAlos16Point1DegreesToTzaisGeonim7Point083Degrees``.
     * In Polar regions of very short winter days it is possible that Mincha Gedola will occur, but 30 minutes later will be after
     * sunset. In those cases, Mincha Gedola will be returned.
     * @return the `Date` of the <em>mincha gedola</em>. If the calculation can't be computed such as northern and
     *         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not
     *         reach low enough below the horizon for this calculation, a `nil` will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos16Point1Degrees()
     * @see getTzaisGeonim3Point7Degrees()
     * @see getShaahZmanisAlos16Point1DegreesToTzaisGeonim3Point7Degrees()
     * @see getMinchaGedolaGreaterThan30(Instant)
     */
    public func getMinchaGedolaAhavatShalom() -> Date? {
        let chatzos: Date? = getChatzosHayom()
        let shaahZmanis: TimeInterval? = getShaahZmanisAlos16Point1DegreesToTzaisGeonim3Point7Degrees()
        if chatzos == nil || shaahZmanis == nil {
            return nil
        }
        return getMinchaGedolaGreaterThan30(minchaGedola: AstronomicalCalendar.getTimeOffset(time: chatzos, offset: shaahZmanis! / 2))
    }

    /**
     * This is a convenience method that returns the later of the mincha gedola passed in and ``getMinchaGedola30Minutes()``. In the winter when 1/2 of a <em>shaah zmanis</em> is less
     * than 30 minutes ``getMinchaGedola30Minutes()`` will be returned, otherwise the mincha gedola passed in will be
     * returned. Since this calculation can be an offset of <em>chatzos</em> (if 30 clock minutes > 1/2 of a <em>shaah
     * zmanis</em>), even if ``isUseAstronomicalChatzosForOtherZmanim()`` is `false`, this <em>mincha</em> time
     * may be affected by ``isUseAstronomicalChatzos()``. In Polar regions of very short winter days it is possible that
     * Mincha Gedola will occur, but 30 minutes later will be after sunset. In those cases, Mincha Gedola will be returned.
     *
     * @param minchaGedola the mincha gedola to be compared to ``getMinchaGedola30Minutes()``.
     * @return the `Date` of the later of ``getMinchaGedolaGRA()`` and ``getMinchaGedola30Minutes()``.
     *         If the calculation can't be computed such as in the Arctic Circle where there is at least one day a year
     *         where the sun does not rise, and one where it does not set, a `nil` will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getMinchaGedolaGRA()
     * @see getMinchaGedola30Minutes()
     * @see isUseAstronomicalChatzos()
     *
     */
    public func getMinchaGedolaGreaterThan30(minchaGedola: Date?) -> Date? {
        if minchaGedola == nil {
            return nil
        }
        let minchaGedola30: Date? = getMinchaGedola30Minutes()
        // check for polar regions on a very short day where Mincha Gedola can occur, but 30 minutes later will be after sunset
        if minchaGedola30 == nil {
            return minchaGedola
        }
        return minchaGedola30!.isAfter(minchaGedola!) ? minchaGedola30 : minchaGedola
    }

    /**
     * This is a convenience method that returns the later of ``getMinchaGedolaGRA()`` and ``getMinchaGedola30Minutes()``.
     * In the winter when 1/2 of a <em>shaah zmanis</em> is less than 30 minutes ``getMinchaGedola30Minutes()`` will be returned, otherwise ``getMinchaGedolaGRA()`` will be returned. Since this
     * calculation can be an offset of <em>chatzos</em> (if 30 clock minutes > 1/2 of a <em>shaah zmanis</em>), even if ``isUseAstronomicalChatzosForOtherZmanim()`` is `false`, this <em>mincha</em> time may be affected by
     * ``isUseAstronomicalChatzos()``. In Polar regions of very short winter days it is possible that Mincha Gedola will occur,
     * but 30 minutes later will be after sunset. In those cases, Mincha Gedola will be returned.
     *
     * @return the `Date` of the later of ``getMinchaGedolaGRA()`` and ``getMinchaGedola30Minutes()``.
     *         If the calculation can't be computed such as in the Arctic Circle where there is at least one day a year
     *         where the sun does not rise, and one where it does not set, a `nil` will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     * @todo Consider adjusting this to calculate the time as 30 minutes after ``getChatzosHayom()`` that uses ``isUseAstronomicalChatzos()`` to determine the type of <em>chatzos</em> to utilize (if the calculator support astronomical <em>chatzos</em>),
     *         based on the ``isUseAstronomicalChatzos()`` setting.
     * @see getMinchaGedolaGRA()
     * @see getMinchaGedola30Minutes()
     * @see getMinchaGedolaGreaterThan30(Instant)
     * @see isUseAstronomicalChatzos()
     */
    public func getMinchaGedolaGRAGreaterThan30() -> Date? {
        return getMinchaGedolaGreaterThan30(minchaGedola: getMinchaGedolaGRA())
    }

    /**
     * This method returns the time of <em>mincha ketana</em> according to the Magen Avraham with the day starting and ending 16.1°
     * below the horizon. This is the preferred earliest time to pray <em>mincha</em> according to the opinion of the <a href=
     * "https://en.wikipedia.org/wiki/Maimonides">Rambam</a> and others. For more information on <em>mincha ketana</em> see the
     * documentation on ``getMinchaGedolaGRA()``. This is calculated as 9.5 ``getShaahZmanis16Point1Degrees()`` after
     * ``getAlos16Point1Degrees()``.
     *
     * @see getShaahZmanis16Point1Degrees()
     * @see getMinchaGedolaGRA()
     * @see getMinchaKetanaGRA()
     * @return the `Date` of the time of <em>mincha ketana</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getMinchaKetana16Point1Degrees() -> Date? {
        return getMinchaKetana(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzais16Point1Degrees(), synchronous: true)
    }

    /**
     * This method returns the time of <em>mincha ketana</em> based on the opinion of <a href=
     * "https://en.wikipedia.org/wiki/Yaakov_Moshe_Hillel">Rabbi Yaakov Moshe Hillel</a> as published in the <em>luach</em> of the
     * Bais Horaah of Yeshivat Chevrat Ahavat Shalom that <em>mincha ketana</em> is calculated as 2.5 <em>shaos zmaniyos</em> before
     * ``getTzaisGeonim3Point8Degrees()`` with <em>shaos zmaniyos</em> calculated based on a day starting at ``getAlos16Point1Degrees()`` and ending at ``getTzaisGeonim3Point8Degrees()``. <em>Mincha ketana</em> is the preferred
     * earliest time to pray <em>mincha</em> according to the opinion of the <a href="https://en.wikipedia.org/wiki/Maimonides"
     * >Rambam</a> and others. For more information on <em>mincha ketana</em> see the documentation on ``getMinchaKetanaGRA()``. If the calculated time is after sunset (on very short winter days), a `nil` will be returned.
     *
     * @return the `Date` of the time of <em>mincha ketana</em>. If the calculation can't be computed such as
     *         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where the
     *         sun may not reach low enough below the horizon for this calculation, a `nil` will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     *
     * @see getShaahZmanisAlos16Point1DegreesToTzaisGeonim3Point8Degrees()
     * @see getMinchaGedolaAhavatShalom()
     * @see getPlagAhavatShalom()
     */
    public func getMinchaKetanaAhavatShalom() -> Date? {
        let shaahZmanis: TimeInterval? = getShaahZmanisAlos16Point1DegreesToTzaisGeonim3Point8Degrees()
        if shaahZmanis == nil {
            return nil
        }
        let totalNanos = JavaMath.toLong(-(shaahZmanis! * 1_000_000_000) * 2.5)
        return nullIfAfterSunset(zman: AstronomicalCalendar.getTimeOffset(time: getTzaisGeonim3Point8Degrees(), offset: Double(totalNanos) / 1_000_000_000))
    }

    /**
     * This method returns the time of <em>mincha ketana</em> according to the Magen Avraham with the day starting 72 minutes before
     * sunrise and ending 72 minutes after sunset. This is the preferred earliest time to pray <em>mincha</em> according to the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Maimonides">Rambam</a> and others. For more information on this see the
     * documentation on ``getMinchaGedolaGRA()``. This is calculated as 9.5 ``getShaahZmanis72Minutes()`` after
     * <em>alos</em>.
     *
     * @see getShaahZmanis16Point1Degrees()
     * @see getMinchaGedolaGRA()
     * @see getMinchaKetanaGRA()
     * @return the `Date` of the time of <em>mincha ketana</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year when the sun does not rise, and one where it
     *         does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getMinchaKetana72Minutes() -> Date? {
        return getMinchaKetana(startOfDay: getAlos72Minutes(), endOfDay: getTzais72Minutes(), synchronous: true)
    }

    /**
     * This method returns the time of <em>plag hamincha</em> according to the Magen Avraham with the day starting 60
     * minutes before sunrise and ending 60 minutes after sunset. This is calculated as 10.75 ``getShaahZmanis60Minutes()``
     * after ``getAlos60Minutes()``.
     *
     * @return the `Date` of the time of <em>plag hamincha</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis60Minutes()
     * @see getAlos60Minutes()
     * @see getTzais60Minutes()
     */
    public func getPlagHamincha60Minutes() -> Date? {
        return getPlagHamincha(startOfDay: getAlos60Minutes(), endOfDay: getTzais60Minutes(), synchronous: true)
    }

    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em> according to the Magen
     * Avraham with the day starting 72 minutes before sunrise and ending 72 minutes after sunset. This is calculated
     * as 10.75 ``getShaahZmanis72Minutes()`` after ``getAlos72Minutes()``. Since <em>plag</em> by this calculation can
     * occur after sunset, it should only be used <em>lechumra</em>.
     *
     * - Warning: This method should be used <em>lechumra</em> only since it returns a very late time (often after <em>shkiah</em>),
     *         and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no current plan to remove this method
     *         from the API, and this deprecation is intended to alert developers of the danger of using it.
     * @return the `Date` of the time of <em>plag hamincha</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis72Minutes()
     */
    public func getPlagHamincha72Minutes() -> Date? {
        return getPlagHamincha(startOfDay: getAlos72Minutes(), endOfDay: getTzais72Minutes(), synchronous: true)
    }

    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em> according to the Magen
     * Avraham with the day starting 90 minutes before sunrise and ending 90 minutes after sunset. This is calculated as 10.75 *
     * ``getShaahZmanis90Minutes()`` after ``getAlos90Minutes()``. Since <em>plag</em> by this calculation can occur after
     * sunset, it should only be used <em>lechumra</em>.
     *
     * - Warning: This method should be used <em>lechumra</em> only since it returns a very late time (often after <em>shkiah</em>),
     *         and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no current plan to remove this method
     *         from the API, and this deprecation is intended to alert developers of the danger of using it.
     *
     * @return the `Date` of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year when the sun does not rise, and one where it
     *         does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis90Minutes()
     */
    public func getPlagHamincha90Minutes() -> Date? {
        return getPlagHamincha(startOfDay: getAlos90Minutes(), endOfDay: getTzais90Minutes(), synchronous: true)
    }

    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em> according to the Magen
     * Avraham with the day starting 96 minutes before sunrise and ending 96 minutes after sunset. This is calculated as 10.75
     * ``getShaahZmanis96Minutes()`` after ``getAlos96Minutes()``. Since <em>plag</em> by this calculation can occur after
     * <em>shkiah</em>, it should only be used <em>lechumra</em>.
     *
     * - Warning: This method should be used <em>lechumra</em> only since it returns a very late time (often after <em>shkiah</em>),
     *         and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no current plan to remove this method
     *         from the API, and this deprecation is intended to alert developers of the danger of using it.
     * @return the `Date` of the time of <em>plag hamincha</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis96Minutes()
     */
    public func getPlagHamincha96Minutes() -> Date? {
        return getPlagHamincha(startOfDay: getAlos96Minutes(), endOfDay: getTzais96Minutes(), synchronous: true)
    }

    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em>. This is calculated as
     * 10.75 * ``getAlos96Zmanis()`` after dawn. Since <em>plag</em> by this calculation can occur
     * after <em>shkiah</em>), it should only be used <em>lechumra</em>.
     *
     * - Warning: This method should be used <em>lechumra</em> only since it returns a very late time (often after
     *         <em>shkiah</em>), and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no
     *         current plan to remove this method from the API, and this deprecation is intended to alert developers
     *         of the danger of using it.
     * @return the `Date` of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year when the sun does not rise, and one where it
     *         does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getPlagHamincha96MinutesZmanis() -> Date? {
        return getPlagHamincha(startOfDay: getAlos96Zmanis(), endOfDay: getTzais96Zmanis(), synchronous: true)
    }

    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em>. This is calculated
     * as 10.75 hours after dawn. The formula used is 10.75 * ``getShaahZmanis90MinutesZmanis()`` after dawn. Since <em>plag</em> by this calculation can
     * occur after sunset, it should only be used <em>lechumra</em>.
     *
     * - Warning: This method should be used <em>lechumra</em> only since it returns a very late time (often after
     *         <em>shkiah</em>), and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no
     *         current plan to remove this method from the API, and this deprecation is intended to alert developers
     *         of the danger of using it.
     * @return the `Date` of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year when the sun does not rise, and one where it
     *         does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getPlagHamincha90MinutesZmanis() -> Date? {
        return getPlagHamincha(startOfDay: getAlos90Zmanis(), endOfDay: getTzais90Zmanis(), synchronous: true)
    }

    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em>. This is calculated as
     * 10.75 hours after ``getAlos72Zmanis()``. The formula used is 10.75 * ``getShaahZmanis72MinutesZmanis()`` after
     * dawn. Since <em>plag</em> by this calculation can occur after sunset, it should only be used
     * <em>lechumra</em>.
     *
     * - Warning: This method should be used <em>lechumra</em> only since it returns a very late time (often after
     *         <em>shkiah</em>), and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no
     *         current plan to remove this method from the API, and this deprecation is intended to alert developers
     *         of the danger of using it.
     * @return the `Date` of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year when the sun does not rise, and one where it
     *         does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getPlagHamincha72MinutesZmanis() -> Date? {
        return getPlagHamincha(startOfDay: getAlos72Zmanis(), endOfDay: getTzais72Zmanis(), synchronous: true)
    }

    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em> based on the opinion that the
     * day starts at ``getAlos16Point1Degrees()`` and ends at ``getTzais16Point1Degrees()``. This is calculated as 10.75 *
     * ``getShaahZmanis16Point1Degrees()`` after ``getAlos16Point1Degrees()``. Since <em>plag</em> by this calculation can
     * occur after <em>shkiah</em>, it should only be used <em>lechumra</em>.
     *
     * - Warning: This method should be used <em>lechumra</em> only since it returns a very late time (often after <em>shkiah</em>),
     *         and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no current plan to remove this method
     *         from the API, and this deprecation is intended to alert developers of the danger of using it.
     * @return the `Date` of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
     *         the sun may not reach low enough below the horizon for this calculation, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis16Point1Degrees()
     */
    public func getPlagHamincha16Point1Degrees() -> Date? {
        return getPlagHamincha(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzais16Point1Degrees(), synchronous: true)
    }

    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em> based on the opinion that the
     * day starts at ``getAlos19Point8Degrees()`` and ends at ``getTzais19Point8Degrees()``. This is calculated as 10.75 *
     * ``getShaahZmanis19Point8Degrees()`` after dawn. Since <em>plag</em> by this calculation
     * can occur after <em>shkiah</em>, it should only be used <em>lechumra</em>.
     *
     * - Warning: This method should be used <em>lechumra</em> only since it returns a very late time (often after
     *         <em>shkiah</em>), and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no
     *         current plan to remove this method from the API, and this deprecation is intended to alert developers
     *         of the danger of using it.
     * @return the `Date` of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
     *         the sun may not reach low enough below the horizon for this calculation, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis19Point8Degrees()
     */
    public func getPlagHamincha19Point8Degrees() -> Date? {
        return getPlagHamincha(startOfDay: getAlos19Point8Degrees(), endOfDay: getTzais19Point8Degrees(), synchronous: true)
    }

    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em> based on the
     * opinion that the day starts at ``getAlos26Degrees()`` and ends at ``getTzais26Degrees()``. This is calculated as
     * 10.75 * ``getShaahZmanis26Degrees()`` after ``getAlos26Degrees()``. Since the <em>zman</em> based on an extremely
     * early <em>alos</em> and a very late <em>tzais</em>, it should only be used <em>lechumra</em>.
     *
     * - Warning: This method should be used <em>lechumra</em> only since it returns a very late time (often after <em>shkiah</em>),
     *         and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no current plan to remove this method
     *         from the API, and this deprecation is intended to alert developers of the danger of using it.
     * @return the `Date` of the time of <em>plag hamincha</em>. If the calculation can't be computed such as northern and
     *         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not reach low
     *         enough below the horizon for this calculation, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis26Degrees()
     * @see getPlagHamincha120Minutes()
     */
    public func getPlagHamincha26Degrees() -> Date? {
        return getPlagHamincha(startOfDay: getAlos26Degrees(), endOfDay: getTzais26Degrees(), synchronous: true)
    }

    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em> based on the opinion that the
     * day starts at ``getAlos18Degrees()`` and ends at ``getTzais18Degrees()``. This is calculated as 10.75* ``getShaahZmanis18Degrees()`` after ``getAlos18Degrees()``. Since <em>plag</em> by this calculation can occur after sunset,
     * it should only be used <em>lechumra</em>.
     *
     * - Warning: This method should be used <em>lechumra</em> only since it returns a very late time (often after
     *         <em>shkiah</em>), and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no
     *         current plan to remove this method from the API, and this deprecation is intended to alert developers
     *         of the danger of using it.
     * @return the `Date` of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
     *         the sun may not reach low enough below the horizon for this calculation, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis18Degrees()
     */
    public func getPlagHamincha18Degrees() -> Date? {
        return getPlagHamincha(startOfDay: getAlos18Degrees(), endOfDay: getTzais18Degrees(), synchronous: true)
    }

    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em> based on the opinion that the
     * day starts at ``getAlos16Point1Degrees()`` and ends at ``getSunsetBasedOnElevationSetting``. This time is 10.75 *
     * <em>shaos zmaniyos</em> after ``getAlos16Point1Degrees()``. Since <em>plag</em> by this calculation can occur after
     * <em>shkiah</em>, it should only be used <em>lechumra</em>.
     *
     * - Warning: This method should be used <em>lechumra</em> only since it returns a very late time (often after <em>shkiah</em>),
     *         and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no current plan to remove this method
     *         from the API, and this deprecation is intended to alert developers of the danger of using it.
     * @return the `Date` of the <em>plag</em>. If the calculation can't be computed such as northern and southern locations
     *         even south of the Arctic Circle and north of the Antarctic Circle where the sun may not reach low enough below the
     *         horizon for this calculation, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getAlos16Point1Degrees()
     * @see getSeaLevelSunset()
     */
    public func getPlagAlosToSunset() -> Date? {
        return getPlagHamincha(startOfDay: getAlos16Point1Degrees(), endOfDay: getSunsetBasedOnElevationSetting(), synchronous: false)
    }

    /**
     * This method returns the time of <em>plag hamincha</em> based on the opinion that the day starts at ``getAlos16Point1Degrees()`` and ends at ``getTzaisGeonim7Point083Degrees()``. The time is 10.75 * ``getShaahZmanisAlos16Point1DegreesToTzaisGeonim7Point083Degrees()`` after ``getAlos16Point1Degrees()`` to reach this time.
     * Sources for an asymmetrical day-based calculation can be seen in the documentation of
     * ``getSofZmanShmaAlos16Point1DegreesToTzaisGeonim7Point083Degrees``.
     *
     * @return the `Date` of the <em>plag</em>. If the calculation can't be computed such as northern and southern locations
     *         even south of the Arctic Circle and north of the Antarctic Circle where the sun may not reach low enough below the
     *         horizon for this calculation, a `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos16Point1Degrees()
     * @see getTzaisGeonim7Point083Degrees()
     * @see getSofZmanShmaAlos16Point1DegreesToTzaisGeonim7Point083Degrees()
     */
    public func getPlagAlos16Point1DegreesToTzaisGeonim7Point083Degrees() -> Date? {
        return getPlagHamincha(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzaisGeonim7Point083Degrees(), synchronous: false)
    }

    /**
     * This method returns the time of <em>plag hamincha</em> (the earliest time that Shabbos can be started) based on the opinion of
     * <a href="https://en.wikipedia.org/wiki/Yaakov_Moshe_Hillel">Rabbi Yaakov Moshe Hillel</a> as published in the <em>luach</em>
     * of the Bais Horaah of Yeshivat Chevrat Ahavat Shalom that that <em>plag hamincha</em> is calculated as 1.25 * ``getShaahZmanisAlos16Point1DegreesToTzaisGeonim3Point8Degrees`` before ``getTzaisGeonim3Point8Degrees()``. Sources for an
     * asymmetrical day-based calculation can be seen in the documentation of
     * ``getSofZmanShmaAlos16Point1DegreesToTzaisGeonim7Point083Degrees``. If the calculated time is after sunset (on very short winter days), a `nil` will be returned.
     *
     * @return the `Date` of the <em>plag</em>. If the calculation can't be computed such as northern and
     *         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not
     *         reach low enough below the horizon for this calculation, a `nil` will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanisAlos16Point1DegreesToTzaisGeonim3Point8Degrees()
     * @see getMinchaGedolaAhavatShalom()
     * @see getMinchaKetanaAhavatShalom()
     */
    public func getPlagAhavatShalom() -> Date? {
        let shaahZmanis: TimeInterval? = getShaahZmanisAlos16Point1DegreesToTzaisGeonim3Point8Degrees()
        if shaahZmanis == nil {
            return nil
        }
        let totalNanos = JavaMath.toLong(-(shaahZmanis! * 1_000_000_000) * 1.25)
        return nullIfAfterSunset(zman: AstronomicalCalendar.getTimeOffset(time: getTzaisGeonim3Point8Degrees(), offset: Double(totalNanos) / 1_000_000_000))
    }

    /**
     * Method to return the beginning of <em>bain hashmashos</em> of Rabbeinu Tam calculated when the sun is
     * 13.24° below the western geometric horizon (90°)
     * after sunset. This calculation is based on the same calculation of <em>bain hashmashos</em> Rabbeinu Tam 58.5 minutes but uses a degree-based calculation instead of 58.5 exact
     * minutes. This calculation is based on the position of the sun 58.5 minutes after sunset in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>,
     * which calculates to 13.24° below ``AstronomicalCalendar/GEOMETRIC_ZENITH``.
     * NOTE: As per Yisrael Vehazmanim Vol. III page 1025, No. 50, a dip of slightly less than 13° should be used.
     * Calculations show that the proper dip to be 13.2456° (truncated to 13.24° that provides about 1.5 second
     * earlier (<em>lechumra</em>) time) below the horizon at that time. This makes a difference of 1 minute and 10
     * seconds in Jerusalem during the Equinox, and 1 minute 29 seconds during the solstice as compared to the proper
     * 13.24° versus 13°. For NY during the solstice, the difference is 1 minute 56 seconds.
     *
     * @todo recalculate the above based on equilux/equinox calculations.
     * @return the `Date` of the sun being 13.24° below ``AstronomicalCalendar/GEOMETRIC_ZENITH``
     *         (90°). If the calculation can't be computed such as northern and southern locations even south of the
     *         Arctic Circle and north of the Antarctic Circle where the sun may not reach low enough below the horizon
     *         for this calculation, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getBainHashmashosRT58Point5Minutes()
     */
    public func getBainHashmashosRT13Point24Degrees() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_13_POINT_24)
    }

    /**
     * This method returns the beginning of <em>Bain hashmashos</em> of Rabbeinu Tam calculated as a 58.5-minute offset after sunset.
     * <em>bain hashmashos</em> is 3/4 of a <a href="https://en.wikipedia.org/wiki/Biblical_mile">mil</a> before <em>tzais</em> or 3
     * 1/4 mil after sunset. With a mil calculated as 18 minutes, 3.25 * 18 = 58.5 minutes.
     *
     * @return the `Date` of 58.5 minutes after sunset. If the calculation can't be computed such as in the
     *         Arctic Circle where there is at least one day a year when the sun does not rise, and one where it does
     *         not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     *
     */
    public func getBainHashmashosRT58Point5Minutes() -> Date? {
        let totalNanos = JavaMath.toLong(58.5 * Double(AstronomicalCalendar.MINUTE_NANOS))
        return AstronomicalCalendar.getTimeOffset(time: getSunsetBasedOnElevationSetting(), offset: Double(totalNanos) / 1_000_000_000)
    }

    /**
     * This method returns the beginning of <em>bain hashmashos</em> based on the calculation of 13.5 minutes (3/4 of an 18-minute
     * <a href="https://en.wikipedia.org/wiki/Biblical_mile">mil</a>) before <em>shkiah</em> calculated as
     * ``getTzaisGeonim7Point083Degrees()``.
     *
     * @return the `Date` of the <em>bain hashmashos</em> of Rabbeinu Tam in this calculation. If the calculation can't be
     *         computed such as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
     *         the sun may not reach low enough below the horizon for this calculation, a `nil` will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getTzaisGeonim7Point083Degrees()
     */
    public func getBainHashmashosRT13Point5MinutesBefore7Point083Degrees() -> Date? {
        let totalNanos = JavaMath.toLong(-13.5 * Double(AstronomicalCalendar.MINUTE_NANOS))
        return AstronomicalCalendar.getTimeOffset(time: getTzaisGeonim7Point083Degrees(), offset: Double(totalNanos) / 1_000_000_000)
    }

    /**
     * This method returns the beginning of <em>bain hashmashos</em> of Rabbeinu Tam calculated according to the
     * opinion of the <em>Divrei Yosef</em> (see Yisrael Vehazmanim) calculated 5/18th (27.77%) of the time between
     * <em>alos</em> (calculated as 19.8° before sunrise) and sunrise. This is added to sunset to arrive at the time
     * for <em>bain hashmashos</em> of Rabbeinu Tam.
     *
     * @return the `Date` of <em>bain hashmashos</em> of Rabbeinu Tam for this calculation. If the calculation can't be
     *         computed such as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
     *         the sun may not reach low enough below the horizon for this calculation, a `nil` will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getBainHashmashosRT2Stars() -> Date? {
        let alos19Point8: Date? = getAlos19Point8Degrees()
        let sunrise: Date? = getSunriseBasedOnElevationSetting()
        if alos19Point8 == nil || sunrise == nil {
            return nil
        }
        let alosToSunrise: TimeInterval? = sunrise!.timeIntervalSince(alos19Point8!)
        let totalNanos = JavaMath.toLong((alosToSunrise! * 1_000_000_000) * (5 / 18.0))
        return AstronomicalCalendar.getTimeOffset(time: getSunsetBasedOnElevationSetting(), offset: Double(totalNanos) / 1_000_000_000)
    }

    /**
     * This method returns the beginning of <em>bain hashmashos</em> (twilight) according to the <a href=
     * "https://en.wikipedia.org/wiki/Eliezer_ben_Samuel">Yereim (Rabbi Eliezer of Metz)</a> calculated as 18 minutes or 3/4 of a
     * 24-minute <a href="https://en.wikipedia.org/wiki/Biblical_mile">mil</a> before sunset. According to the Yereim, <em>bain
     * hashmashos</em> starts 3/4 of a mil before sunset and <em>tzais</em> or nightfall starts at sunset. If the calculated time is before <em>plag hamincha</em>
     * (on very short winter days), a `nil` will be returned.
     *
     * @return the `Date` of 18 minutes before sunset. If the calculation can't be computed such as in the
     *         Arctic Circle where there is at least one day a year when the sun does not rise, and one where it does
     *         not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getBainHashmashosYereim3Point05Degrees()
     */
    public func getBainHashmashosYereim18Minutes() -> Date? {
        return nullIfBeforePlagHaminchaGRA(zman: AstronomicalCalendar.getTimeOffset(time: getSunsetBasedOnElevationSetting(), offset: -18 * 60.0))
    }

    /**
     * This method returns the beginning of <em>bain hashmashos</em> (twilight) according to the <a href=
     * "https://en.wikipedia.org/wiki/Eliezer_ben_Samuel">Yereim (Rabbi Eliezer of Metz)</a> calculated as the sun's
     * position 3.05° above the horizon <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>,
     * its position 18 minutes or 3/4 of an 24-minute <a href="https://en.wikipedia.org/wiki/Biblical_mile">mil</a> before sunset.
     * According to the Yereim, <em>bain hashmashos</em> starts 3/4 of a mil before sunset and <em>tzais</em> or nightfall starts at
     * sunset. Note that <em>lechumra</em> (of about 14 seconds) a refraction value of 0.5166° as opposed to the traditional 0.566°
     * is used. This is more inline with the actual refraction in <em>Eretz Yisrael</em> and is brought down by <a href=
     * "http://beinenu.com/rabbis/%D7%94%D7%A8%D7%91-%D7%99%D7%93%D7%99%D7%93%D7%99%D7%94-%D7%9E%D7%A0%D7%AA">Rabbi Yedidya Manet</a>
     * in his <a href="https://www.nli.org.il/en/books/NNL_ALEPH002542826/NLI">Zmanei HaHalacha Lema'aseh</a> (p. 11). That is the
     * first source that I am aware of that calculates degree-based Yereim <em>zmanim</em>. The 0.5166° refraction is also used by
     * the <a href="https://zmanim.online/">Luach Itim Lebinah</a>. Calculating the Yereim's <em>bain hashmashos</em> using 18-minute
     * based degrees is also suggested in the upcoming 8th edition of the zmanim Kehilchasam. For more details, see the article
     * <a href="https://kosherjava.com/2020/12/07/the-yereims-bein-hashmashos/">The Yereim's <em>Bain Hashmashos</em></a>.
     *
     * @todo recalculate based on equinox/equilux
     * @return the `Date` of the sun's position 3.05° minutes before sunset. If the calculation can't
     *         be computed such as in the Arctic Circle where there is at least one day a year when the sun does not
     *         rise, and one where it does not set, a `nil` will be returned. See detailed explanation on
     *         top of the ``AstronomicalCalendar`` documentation.
     * @see ZENITH_MINUS_3_POINT_05
     * @see getBainHashmashosYereim18Minutes()
     * @see getBainHashmashosYereim2Point8Degrees()
     * @see getBainHashmashosYereim2Point1Degrees()
     */
    public func getBainHashmashosYereim3Point05Degrees() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_MINUS_3_POINT_05)
    }

    /**
     * This method returns the beginning of <em>bain hashmashos</em> (twilight) according to the <a href=
     * "https://en.wikipedia.org/wiki/Eliezer_ben_Samuel">Yereim (Rabbi Eliezer of Metz)</a> calculated as 16.875 minutes or 3/4 of a
     * 22.5-minute <a href="https://en.wikipedia.org/wiki/Biblical_mile">mil</a> before sunset. According to the Yereim, <em>bain
     * hashmashos</em> starts 3/4 of a mil before sunset and <em>tzais</em> or nightfall starts at sunset. If the calculated time is before <em>plag hamincha</em>
     * (on very short winter days), a `nil` will be returned.
     *
     * @return the `Date` of 16.875 minutes before sunset. If the calculation can't be computed such as in the
     *         Arctic Circle where there is at least one day a year when the sun does not rise, and one where it does
     *         not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getBainHashmashosYereim2Point8Degrees()
     */
    public func getBainHashmashosYereim16Point875Minutes() -> Date? {
        let totalNanos = JavaMath.toLong(-16.875 * Double(AstronomicalCalendar.MINUTE_NANOS))
        return nullIfBeforePlagHaminchaGRA(zman: AstronomicalCalendar.getTimeOffset(time: getSunsetBasedOnElevationSetting(), offset: Double(totalNanos) / 1_000_000_000))
    }

    /**
     * This method returns the beginning of <em>bain hashmashos</em> (twilight) according to the <a href=
     * "https://en.wikipedia.org/wiki/Eliezer_ben_Samuel">Yereim (Rabbi Eliezer of Metz)</a> calculated as the sun's position 2.8°
     * above the horizon <a href="https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox /
     * equilux</a>, its position 16.875 minutes or 3/4 of an 22.5-minute <a href="https://en.wikipedia.org/wiki/Biblical_mile"
     * >mil</a> before sunset. According to the Yereim, <em>bain hashmashos</em> starts 3/4 of a mil before sunset and <em>tzais</em>
     * or nightfall starts at sunset. Details, including how the degrees were calculated can be seen in the documentation of
     * ``getBainHashmashosYereim3Point05Degrees()``.
     *
     * @return the `Date` of the sun's position 2.8° minutes before sunset. If the calculation can't
     *         be computed such as in the Arctic Circle where there is at least one day a year when the sun does not
     *         rise, and one where it does not set, a `nil` will be returned. See detailed explanation on
     *         top of the ``AstronomicalCalendar`` documentation.
     * @see ZENITH_MINUS_2_POINT_8
     * @see getBainHashmashosYereim16Point875Minutes()
     * @see getBainHashmashosYereim3Point05Degrees()
     * @see getBainHashmashosYereim2Point1Degrees()
     */
    public func getBainHashmashosYereim2Point8Degrees() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_MINUS_2_POINT_8)
    }

    /**
     * This method returns the beginning of <em>bain hashmashos</em> (twilight) according to the <a href=
     * "https://en.wikipedia.org/wiki/Eliezer_ben_Samuel">Yereim (Rabbi Eliezer of Metz)</a> calculated as 13.5 minutes or 3/4 of
     * an 18-minute <a href="https://en.wikipedia.org/wiki/Biblical_mile">mil</a> before sunset. According to the Yereim, <em>bain
     * hashmashos</em> starts 3/4 of a mil before sunset and <em>tzais</em> or nightfall starts at sunset. If the calculated time is before <em>plag hamincha</em>
     * (on very short winter days), a `nil` will be returned.
     *
     * @return the `Date` of 13.5 minutes before sunset. If the calculation can't be computed such as in the
     *         Arctic Circle where there is at least one day a year when the sun does not rise, and one where it does
     *         not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getBainHashmashosYereim2Point1Degrees()
     */
    public func getBainHashmashosYereim13Point5Minutes() -> Date? {
        let totalNanos = JavaMath.toLong(-13.5 * Double(AstronomicalCalendar.MINUTE_NANOS))
        return nullIfBeforePlagHaminchaGRA(zman: AstronomicalCalendar.getTimeOffset(time: getSunsetBasedOnElevationSetting(), offset: Double(totalNanos) / 1_000_000_000))
    }

    /**
     * Returns the time passed in, or `nil` if it is after sunset, as can happen
     * on very short winter days for <em>zmanim</em> calculated from a day that extends past sunset.
     *
     * @param zman the time to check
     * @return the time passed in, or `nil` if it is `nil` or after sunset
     */
    private func nullIfAfterSunset(zman: Date?) -> Date? {
        let sunset: Date? = getSunsetBasedOnElevationSetting()
        if zman != nil && sunset != nil && zman!.isAfter(sunset!) { // very short winter day
            return nil
        }
        return zman
    }

    /**
     * Returns the time passed in, or `nil` if it is before <em>plag hamincha</em>, as can
     * happen on very short winter days when a fixed offset before sunset reaches back into the morning.
     *
     * @param zman the time to check
     * @return the time passed in, or `nil` if it is `nil` or before <em>plag hamincha</em>
     */
    private func nullIfBeforePlagHaminchaGRA(zman: Date?) -> Date? {
        let plagHamincha: Date? = getPlagHaminchaGRA()
        if zman != nil && plagHamincha != nil && zman!.isBefore(plagHamincha!) { // very short winter day
            return nil
        }
        return zman
    }

    /**
     * This method returns the beginning of <em>bain hashmashos</em> according to the <a href=
     * "https://en.wikipedia.org/wiki/Eliezer_ben_Samuel">Yereim (Rabbi Eliezer of Metz)</a> calculated as the sun's position 2.1°
     * <b>above</b> the horizon <a href="https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the
     * equinox / equilux</a> in Yerushalayim, its position 13.5 minutes or 3/4 of an 18-minute <a href=
     * "https://en.wikipedia.org/wiki/Biblical_mile">mil</a> before sunset. According to the Yereim, <em>bain hashmashos</em> starts
     * 3/4 of a mil before sunset and <em>tzais</em> or nightfall starts at sunset. Details, including how the degrees were
     * calculated can be seen in the documentation of ``getBainHashmashosYereim3Point05Degrees()``.
     *
     * @return the `Date` of the sun's position 2.1° minutes before sunset. If the calculation can't be computed such as i
     *         the Arctic Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see ZENITH_MINUS_2_POINT_1
     * @see getBainHashmashosYereim13Point5Minutes()
     * @see getBainHashmashosYereim2Point8Degrees()
     * @see getBainHashmashosYereim3Point05Degrees()
     */
    public func getBainHashmashosYereim2Point1Degrees() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_MINUS_2_POINT_1)
    }

    /**
     * This method returns the <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> calculated at the sun's position
     * at 3.7° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°), calculated as the position of the
     * sun 13.5 minutes after sunset, the time it takes to walk 3/4 of a <a href="https://en.wikipedia.org/wiki/Biblical_mile">mil</a>
     * at 18 minutes a mil, or 13.5 minutes after sunset. The sun is 3.7° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` at this
     * time in Jerusalem <a href="https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox /
     * equilux</a>. This does not cover the 26.46 it takes to walk 49 amos (the <em>heref ayin</em> of <em>bain hashmashos</em> of
     * Rav Yosi) at the pace of an 18-minute mil. Rabbi Yedidya Manet in his <a href=
     * "https://www.nli.org.il/en/books/NNL_ALEPH002542826/NLI">Zmanei HaHalacha Lema'aseh</a> (5th edition, vol. I page 36, no. 22)
     * lists 3.65° as the value for this <em>tzais</em>, however it is based on sunset calculated using a refreaction value of 31′
     * (arcminutes) or 0.516° (page 16) based on his calculations of the refraction value in Israel at the autumn equinox (something
     * he himself questions in vol II, page 36). Even for Israel, most consider that refraction value too low. Regardless, the dip for
     * <em>tzais</em> must be based on sunset using a specific refraction model (and solar radius), and this library currently uses a
     * global average refraction value of 34′ (arcminutes) or 0.566°. Based on the global average refraction for sunset, this
     * <em>tzais</em> calculates as 3.7°.
     *
     * @return the `Date` representing the time when the sun is 3.7° below sea level.
     * - Warning: This method should be used <em>lechumra</em> only since it returns a very early time, and if used <em>lekula</em>
     *         can result in <em>chillul Shabbos</em> etc. There is no current plan to remove this method from the API, and this
     *         deprecation is intended to alert developers of the danger of using it.
     * @see ZENITH_3_POINT_7
     */
    public func getTzaisGeonim3Point7Degrees() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_3_POINT_7)
    }

    /**
     * This method returns the <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> calculated at the sun's position
     * at 3.8° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°), calculated as the position of the
     * sun 13.5 minutes after sunset, the time it takes to walk 3/4 of a <a href="https://en.wikipedia.org/wiki/Biblical_mile">mil</a>
     * at 18 minutes a mil, plus 30 seconds for the time it takes to walk 49 amos (the <em>heref ayin</em> of <em>bain hashmashos</em>
     * of Rav Yosi). With this being an 18-minutes mil, 49 amos would take 26.46, rounded to 30 seconds), for a total of 14 minutes
     * after sunset. The sun is 3.8° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` at this time in
     * Jerusalem <a href="https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>.
     *
     * @return the `Date` representing the time when the sun is 3.8° below sea level.
     * - Warning: This method should be used <em>lechumra</em> only since it returns a very early time, and if used <em>lekula</em>
     *         can result in <em>chillul Shabbos</em> etc. There is no current plan to remove this method from the API, and this
     *         deprecation is intended to alert developers of the danger of using it.
     * @see ZENITH_3_POINT_8
     */
    public func getTzaisGeonim3Point8Degrees() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_3_POINT_8)
    }

    /**
     * This method returns the <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> calculated at the sun's
     * position at 5.95° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°), calculated as the
     * position of the sun 24 minutes after sunset in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>. The 24 minutes
     * is based on the Baal Hatanya's calculation of 18 minutes (3/4 of a 24 minute mil) + 4 minutes for <em>shkiah amitis</em> +
     * 2 minutes for bain hashmashos of Rav Yosi. See Hazmanim Bahalacha vol II, ch. 50, no. 5, p. 512-513, ch. 47, and Yisrael
     * Vehazmanim <a href="https://hebrewbooks.org/pdfpager.aspx?req=9764&st=&pgnum=266">Vol III, ch. 13, no. 53, p. 1026</a>. Among
     * sources he mentions for this <em>zman</em> is <a href="https://en.wikipedia.org/wiki/Yehuda_(Leo)_Levi">Rabbi Yehuda (Leo)
     * Levi's</a> calculations in Jewish Chrononomy and other sources. Calculations show that the time is closer to 5.93° and was
     * seemingly rounded to 5.95°. Chabad calendars usually use the 6°-based ``getTzaisBaalHatanya()`` that is built on this
     * same calculation. Rabbi Yedidya Manet in his <a href="https://www.nli.org.il/en/books/NNL_ALEPH002542826/NLI">Zmanei HaHalacha
     * Lema'aseh</a> (5th edition, vol. I page 36, no. 24) lists 5.88° as the value for this <em>tzais</em>, however it is based on
     * sunset calculated using a refreaction value of 31′ (arcminutes) or 0.516° (page 16) based on his calculations of the refraction
     * value in Israel at the autumn equinox (something he himself questions in vol II, page 36). Even for Israel, most consider that
     * refraction value too low. Regardless, the dip for <em>tzais</em> must be based on sunset using a specific refraction model
     * (and solar radius), and this library currently uses a global average refraction value of 34′ (arcminutes) or 0.566°. Based on
     * the global average refraction for sunset, this <em>tzais</em> calculates as 5.93° (rounded by most calendars to 5.95°).
     *
     * @return the `Date` representing the time when the sun is 5.95° below sea level. If the calculation can't be computed
     *         such as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun
     *         may not reach low enough below the horizon for this calculation, a `nil` will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getTzaisBaalHatanya()
     */
    public func getTzaisGeonim5Point95Degrees() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_5_POINT_95)
    }

    /**
     * This method returns the <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> calculated as 3/4 of a <a href=
     * "https://en.wikipedia.org/wiki/Biblical_mile">mil</a> based on a 24-minute mil, or 18 minutes. It is the sun's position at
     * 4.66° below the western horizon. This is a very early <em>zman</em> and should not be relied on
     * without Rabbinical guidance. This does not cover the 35.28 seconds it takes to walk 49 amos (the <em>heref ayin</em> of
     * <em>bain hashmashos</em> of Rav Yosi) at the pace of a 24-minute mil. See ``getTzaisGeonim4Point8Degrees()`` for a time
     * that covers the <em>heref ayin</em>. Rabbi Yedidya Manet in his <a href=
     * "https://www.nli.org.il/en/books/NNL_ALEPH002542826/NLI">Zmanei HaHalacha Lema'aseh</a> (5th edition, vol. I page 36, no. 24)
     * lists 4.61° as the value for this <em>tzais</em>, however it is based on sunset calculated using a refreaction value of 31′
     * (arcminutes) or 0.516° (page 16) based on his calculations of the refraction value in Israel at the autumn equinox (something
     * he himself questions in vol II, page 36). Even for Israel, most consider that refraction value too low. Regardless, the dip for
     * <em>tzais</em> must be based on sunset using a specific refraction model (and solar radius), and this library currently uses a
     * global average refraction value of 34′ (arcminutes) or 0.566°. Based on the global average refraction for sunset, this
     * <em>tzais</em> calculates as 4.66°.
     *
     * @return the `Date` representing the time when the sun is 4.66° below sea level. If the calculation can't be computed
     *         such as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where the
     *         sun may not reach low enough below the horizon for this calculation, a `nil` will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     * - Warning: This method should be used <em>lechumra</em> only since it returns a very early time, and if used <em>lekula</em>
     *         can result in <em>chillul Shabbos</em> etc. There is no current plan to remove this method from the API, and this
     *         deprecation is intended to alert developers of the danger of using it.
     * @see ZENITH_4_POINT_66
     * @see getTzaisGeonim4Point8Degrees()
     */
    public func getTzaisGeonim4Point66Degrees() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_4_POINT_66)
    }

    /**
     * This method returns the <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> calculated as 3/4 of a <a href=
     * "https://en.wikipedia.org/wiki/Biblical_mile">mil</a>, based on a 22.5-minute mil, or 16.875 minutes. It is the sun's position
     * at 4.42° below the western horizon. This is a very early <em>zman</em> and should not be relied on
     * without Rabbinical guidance. This does not cover the 33.07 seconds it takes to walk 49 amos (the <em>heref ayin</em> of
     * <em>bain hashmashos</em> of Rav Yosi) at the pace of a 22.5 minute-mil. Rabbi Yedidya Manet in his <a href=
     * "https://www.nli.org.il/en/books/NNL_ALEPH002542826/NLI">Zmanei HaHalacha Lema'aseh</a> (5th edition, vol. I page 36, no. 23)
     * lists 4.37° as the value for this <em>tzais</em>, however it is based on sunset calculated using a refreaction value of 31′
     * (arcminutes) or 0.516° (page 16) based on his calculations of the refraction value in Israel at the autumn equinox (something
     * he himself questions in vol II, page 36). Even for Israel, most consider that refraction value too low. Regardless, the dip for
     * <em>tzais</em> must be based on sunset using a specific refraction model (and solar radius), and this library currently uses a
     * global average refraction value of 34′ (arcminutes) or 0.566°. Based on the global average refraction for sunset, this
     * <em>tzais</em> calculates as 4.42°.
     *
     * @return the `Date` representing the time when the sun is 4.42° below sea level. If the calculation
     *         can't be computed such as northern and southern locations even south of the Arctic Circle and north of
     *         the Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * - Warning: This method should be used <em>lechumra</em> only since it returns a very early time, and if used <em>lekula</em>
     *         can result in <em>chillul Shabbos</em> etc. There is no current plan to remove this method from the API, and this
     *         deprecation is intended to alert developers of the danger of using it.
     * @see ZENITH_4_POINT_42
     */
    public func getTzaisGeonim4Point42Degrees() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_4_POINT_42)
    }

    /**
     * This method returns the <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> calculated as the sun's
     * position below the horizon at a time of 18.6 minutes after sunset. This is calculated as 3/4 of a 24-minute <a href=
     * "https://en.wikipedia.org/wiki/Biblical_mile">mil</a>, plus 0.6 minutes for the time to walk 49 amos for <em>bain
     * hashmashos</em> of Rav Yosi (with this <em>zman</em> based on a 24-minute mil, 49 amos would take 35.28 seconds to walk), for
     * a total of 18.6 minutes after sunset. This calculates to the sun's position at 4.8° below the
     * western horizon. This is based on <a href=
     * "https://he.wikipedia.org/wiki/%D7%99%D7%97%D7%99%D7%90%D7%9C_%D7%9E%D7%99%D7%9B%D7%9C_%D7%A9%D7%9C%D7%96%D7%99%D7%A0%D7%92%D7%A8"
     * >Rav Yechiel Michel Shlezinger's</a> <em>sefer</em> <a href="https://www.nli.org.il/he/books/NNL_ALEPH997010042055805171/NLI"
     * >Aizehu Bain Hashmashos</a>, <a href="https://en.wikipedia.org/wiki/Yehuda_(Leo)_Levi">Rabbi Yehuda (Leo) Levi's</a>
     * calculations in <a href="https://www.nli.org.il/en/items/NNL_ALEPH990022548970205171/NLI">Zmanei Hayom BaHalacha</a> p. 37.
     * At this point, 3 medium sized stars are visible to a non-expert with good vision with effort. An expert knowing where to
     * look can see the 3 medium stars as early as 15 minutes after sunset. This is explained in detail in Hazmanim Bahalacha vol
     * II, ch. 41, no. 6 (p. 372-373, ch. 47, no. 11-12 (p. 491-493) where it is clear that medium sized stars would be visible as
     * early as 14 minutes after sunset (13.5 minutes for 3/4 of an 18 minute Mil, plus 0.5 minutes for <em>bain Hashmashos</em>
     * of Rav Yosi) to an expert. See more details on this earlier <em>zman</em> at ``getTzaisGeonim3Point8Degrees()``.
     * This is an early <em>zman</em> for <em>tzais</em>and should not be relied on without Rabbinical guidance.
     *
     * @return the `Date` representing the time when the sun is 4.8° below sea level. If the calculation can't be computed
     *         such as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where the
     *         sun may not reach low enough below the horizon for this calculation, a `nil` will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see ZENITH_4_POINT_8
     */
    public func getTzaisGeonim4Point8Degrees() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_4_POINT_8)
    }

    /**
     * This method returns the <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> as calculated by <a href=
     * "https://en.wikipedia.org/wiki/Yechiel_Michel_Tucazinsky">Rabbi Yechiel Michel Tucazinsky</a> as the position of
     * the sun no later than 31 minutes after sea-level sunset in Jerusalem (the Birur halacha shows that Rav Tucazinsky's
     * calculations for sunset, listed as 28 minutes in this case, were about 3 minutes later than reality), and at the height of
     * the summer solstice, this <em>zman</em>, calculations show that 30.75 minutes after <em>shkiah</em> computes to 6.45° below
     * ``AstronomicalCalendar/GEOMETRIC_ZENITH``. This calculation is found in the <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=50536&st=&pgnum=51">Birur Halacha Yoreh Deah 262</a> and it is the commonly used
     * <em>zman</em> in Israel. It is also used in the <a href="https://www.worldcat.org/oclc/243303103">Luach Itim Lebinah</a>. it
     * should be noted that this differs from the 6.1° / 6.2° calculation for Rabbi Tucazinsky's time as calculated by the
     * Hazmanim Bahalacha Vol II chapter 50:7 (page 515). Calculations show that 6.45° at the equinox is 26.5 minutes after
     * <em>shkiah</em> <a href="https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox /
     * equilux</a>.
     *
     * @return the `Date` representing the time when the sun is 6.45° below sea level. If the
     *         calculation can't be computed such as northern and southern locations even south of the Arctic Circle and
     *         north of the Antarctic Circle where the sun may not reach low enough below the horizon for this
     *         calculation, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see ZENITH_6_POINT_45
     */
    public func getTzaisGeonim6Point45Degrees() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_6_POINT_45)
    }

    /**
     * This method returns the <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> calculated when the sun's
     * position 7.083° (or 7° 5′) below the western horizon. This is often referred to as 7° 5′ or 7° and
     * 5′ minutes. This calculation is based on the observation of 3 medium-sized stars by Dr. Baruch (Berthold) Cohn in his
     * <em>luach</em> <a href="https://sammlungen.ub.uni-frankfurt.de/freimann/content/titleinfo/983088">Tabellen enthaltend die
     * Zeitangaben für den Beginn der Nacht und des Tages für die Breitengrade + 66 bis -38</a> published in Strasbourg, France in
     * 1899. This calendar was very popular in Europe, and many other calendars based their <em>tzais</em> time on it. <a href=
     * "https://en.wikipedia.org/wiki/David_Zvi_Hoffmann">Rav Dovid Tzvi Hoffman</a> in his <a href="https://hebrewbooks.org/1053"
     * >שו״ת מלמד להועיל</a> in an exchange of letters with Baruch Cohn in <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=1053&st=&pgnum=37">Orach Chaim 30</a> agreed to this <em>zman</em> (page 36), as
     * did the שו״ת בני ציון and the <a href="https://hebrewbooks.org/67373">תנובת שדה</a>. It is very close to the time of the <a href=
     * "https://hebrewbooks.org/22044">מקור חסד</a> of the Sefer chasidim. It is close to the position of the sun 30 minutes after
     * sunset in Jerusalem <a href="https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox /
     * equilux</a>, but not Exactly. The actual position of the sun 30 minutes after sunset in Jerusalem at the equilux is 7.205°
     * and 7.199° at the equinox. See Hazmanim Bahalacha vol 2, pages 520-521 for more details.
     *
     * @return the `Date` representing the time when the sun is 7.083° below sea level. If the calculation can't be
     *         computed such as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a `nil` will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see ZENITH_7_POINT_083
     */
    public func getTzaisGeonim7Point083Degrees() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_7_POINT_083)
    }

    /**
     * This method returns <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> calculated as 45 minutes
     * after sunset during the summer solstice in New York, when the <em>neshef</em> (twilight) is the longest. The sun's
     * position at this time computes to 7.67° below the western horizon. See <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=921&pgnum=149">Igros Moshe Even Haezer 4, Ch. 4</a> (regarding
     * <em>tzais</em> for <em>krias Shema</em>). It is also mentioned in Rabbi Heber's <a href=
     * "https://hebrewbooks.org/53000">Shaarei Zmanim</a> on in
     * <a href="https://hebrewbooks.org/pdfpager.aspx?req=53055&pgnum=101">chapter 10 (page 87)</a> and
     * <a href="https://hebrewbooks.org/pdfpager.aspx?req=53055&pgnum=122">chapter 12 (page 108)</a>. Also see the
     * time of 45 minutes in <a href="https://en.wikipedia.org/wiki/Simcha_Bunim_Cohen">Rabbi Simcha Bunim Cohen's</a> <a
     * href="https://www.worldcat.org/oclc/179728985">The radiance of Shabbos</a> as the earliest <em>zman</em> for New York.
     * This <em>zman</em> is also listed in the <a href="https://hebrewbooks.org/pdfpager.aspx?req=1927&pgnum=90">Divrei
     * Shalom Vol. III, chapter 75</a>, and <a href="https://hebrewbooks.org/pdfpager.aspx?req=892&pgnum=431">Bais Av"i
     * Vol. III, chapter 117</a>. This <em>zman</em> is also listed in the Divrei Shalom etc. chapter 177. Since this
     * <em>zman</em> depends on the level of light, Rabbi Yaakov Shakow presented this degree-based calculation to Rabbi
     * <a href="https://en.wikipedia.org/wiki/Shmuel_Kamenetsky">Rabbi Shmuel Kamenetsky</a> who agreed to it.
     * @todo add hyperlinks to source of Divrei Shalom once it is located.
     * @return the `Date` representing the time when the sun is 7.67° below sea level. If the
     *         calculation can't be computed such as northern and southern locations even south of the Arctic Circle and
     *         north of the Antarctic Circle where the sun may not reach low enough below the horizon for this
     *         calculation, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see ZENITH_7_POINT_67
     */
    public func getTzaisGeonim7Point67Degrees() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_7_POINT_67)
    }

    /**
     * This method returns the <em>tzais</em> (nightfall) based on the calculations used in the <a href=
     * "https://www.worldcat.org/oclc/243303103">Luach Itim Lebinah</a> as the stringent time for <em>tzais</em>. It is calculated
     * as the sun's position at 9.3° below the western horizon.
     *
     * @return the `Date` representing the time when the sun is 9.3° below sea level. If the calculation can't be
     *         computed such as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a `nil` will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getTzaisGeonim9Point3Degrees() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_9_POINT_3)
    }

    /**
     * This method returns the <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> calculated as 60 minutes after
     * sunset <a href="https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>,
     * the day that a solar hour is 60 minutes in New York. The sun's position at this time computes to 9.75° below the western horizon. This is the opinion of <a href="https://en.wikipedia.org/wiki/Yosef_Eliyahu_Henkin"
     * >Rabbi Eliyahu Henkin</a>. This also follows the opinion of <a href="https://en.wikipedia.org/wiki/Shmuel_Kamenetsky">Rabbi
     * Shmuel Kamenetsky</a>. Rabbi Yaakov Shakow presented these degree-based times to Rabbi Shmuel Kamenetsky who agreed to them.
     *
     * @todo recalculate based on equinox / equilux.
     * @return the `Date` representing the time when the sun is 9.75° below sea level. If the calculation can't be
     *         computed such as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a `nil` will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     *
     * @see getTzais60Minutes()
     */
    public func getTzaisGeonim9Point75Degrees() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_9_POINT_75)
    }

    /**
     * This method returns the <em>tzais</em> (nightfall) based on the opinion of the <a href=
     * "https://en.wikipedia.org/wiki/Yair_Bacharach">Chavas Yair</a> and <a href=
     * "https://he.wikipedia.org/wiki/%D7%9E%D7%9C%D7%9B%D7%99%D7%90%D7%9C_%D7%A6%D7%91%D7%99_%D7%98%D7%A0%D7%A0%D7%91%D7%95%D7%99%D7%9D"
     * >Divrei Malkiel</a> that the time to walk the distance of a <a href=
     * "https://en.wikipedia.org/wiki/Biblical_mile">mil</a> is 15 minutes, for a total of 60 minutes for 4 mil after ``getSunsetBasedOnElevationSetting()``(depends on the ``isUseElevation()`` setting). See detailed documentation explaining
     * the 60 minute concept at ``getAlos60Minutes()``.
     *
     * @return the `Date` representing 60 minutes after sea level sunset. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year when the sun does not rise, and one where it does not set,
     *         a `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     *
     * @see getAlos60Minutes()
     * @see getPlagHamincha60Minutes()
     * @see getShaahZmanis60Minutes()
     */
    public func getTzais60Minutes() -> Date? {
        return AstronomicalCalendar.getTimeOffset(time: getSunsetBasedOnElevationSetting(), offset: 60 * 60.0)
    }

    /**
     * This method returns <em>tzais</em> usually calculated as 40 minutes (configurable to any offset via ``setAteretTorahSunsetOffset()``) after sunset. Please note that <em>Chacham</em> Yosef Harari-Raful of Yeshivat Ateret
     * Torah who uses this time, does so only for calculating various other <em>zmanei hayom</em> such as <em>Sof Zman Krias
     * Shema</em> and <em>Plag Hamincha</em>. His calendars do not publish a <em>zman</em> for <em>Tzais</em>. It should also be
     * noted that <em>Chacham</em> Harari-Raful provided a 25 minute <em>zman</em> for Israel. This API uses 40 minutes year round in
     * any place on the globe by default. This offset can be changed by calling ``setAteretTorahSunsetOffset()``.
     *
     * @return the `Date` representing 40 minutes (configurable via ``setAteretTorahSunsetOffset``) after sea
     *         level sunset. If the calculation can't be computed such as in the Arctic Circle where there is at least one day a year
     *         where the sun does not rise, and one where it does not set, a `nil` will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAteretTorahSunsetOffset()
     * @see setAteretTorahSunsetOffset(double)
     */
    public func getTzaisAteretTorah() -> Date? {
        let totalNanos = JavaMath.toLong(getAteretTorahSunsetOffset() * Double(AstronomicalCalendar.MINUTE_NANOS))
        return AstronomicalCalendar.getTimeOffset(time: getSunsetBasedOnElevationSetting(), offset: Double(totalNanos) / 1_000_000_000)
    }

    /**
     * Returns the offset in minutes after sunset used to calculate <em>tzais</em> based on the calculations of <em>Chacham</em>
     * Yosef Harari-Raful of Yeshivat Ateret Torah calculations. The default value is 40 minutes. This affects most <em>zmanim</em>,
     * since almost all zmanim use subset as part of their calculation.
     *
     * @return the number of minutes after sunset for <em>Tzait</em>.
     * @see setAteretTorahSunsetOffset(double)
     */
    public func getAteretTorahSunsetOffset() -> Double {
        return ateretTorahSunsetOffset
    }

    /**
     * Allows setting the offset in minutes after sunset for the Ateret Torah <em>zmanim</em>. The default if unset is 40 minutes.
     * <em>Chacham</em> Yosef Harari-Raful of Yeshivat Ateret Torah uses 40 minutes globally with the exception of Israel where a
     * 25-minute offset is used. This 40-minute (or any other) offset can be overridden by this method. This offset impacts all
     * Ateret Torah <em>zmanim</em>.
     *
     * @param ateretTorahSunsetOffset the number of minutes after sunset to use as an offset for the Ateret Torah <em>tzais</em>
     * @see getAteretTorahSunsetOffset()
     */
    public func setAteretTorahSunsetOffset(ateretTorahSunsetOffset: Double) {
        self.ateretTorahSunsetOffset = ateretTorahSunsetOffset
    }

    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite Shema in the morning) based on the calculation of
     * <em>Chacham</em> Yosef Harari-Raful of Yeshivat Ateret Torah, that the day starts 1/10th of the day
     * before sunrise and is usually calculated as ending 40 minutes after sunset (configurable to any
     * offset via ``setAteretTorahSunsetOffset()``). <em>Shaos zmaniyos</em> are calculated based on this day and added to
     * <em>alos</em> to reach this time. This time is 3 <em>shaos zmaniyos</em> (temporal hours) after <em>alos</em> 72 <em>zmaniyos</em>. <b>Note: </b> Based on
     * this calculation <em>chatzos</em> will not be at midday.
     *
     * @return the `Date` of the latest <em>zman krias shema</em> based on this calculation. If the calculation can't be
     *         computed such as in the Arctic Circle where there is at least one day a year when the sun does not rise, and one where
     *         it does not set, a `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see getAlos72Zmanis()
     * @see getTzaisAteretTorah()
     * @see getAteretTorahSunsetOffset()
     * @see setAteretTorahSunsetOffset(double)
     * @see getShaahZmanisAteretTorah()
     */
    public func getSofZmanShmaAteretTorah() -> Date? {
        return getSofZmanShma(startOfDay: getAlos72Zmanis(), endOfDay: getTzaisAteretTorah(), synchronous: false)
    }

    /**
     * This method returns the latest <em>zman tfila</em> (time to recite the morning prayers) based on the calculation of
     * <em>Chacham</em> Yosef Harari-Raful of Yeshivat Ateret Torah, that the day starts 1/10th of the day
     * before sunrise and is usually calculated as ending 40 minutes after sunset (configurable to any
     * offset via ``setAteretTorahSunsetOffset()``). <em>shaos zmaniyos</em> are calculated based on this day and added to
     * ``getAlos72Zmanis()`` to reach this time. This time is 4 * ``getShaahZmanisAteretTorah()`` after ``getAlos72Zmanis()``. <b>Note: </b> Based on this calculation <em>chatzos</em> will not be at midday. Sources for an
     * asymmetrical day-based calculation can be seen in the documentation of
     * ``getSofZmanShmaAlos16Point1DegreesToTzaisGeonim7Point083Degrees``.
     *
     * @return the `Date` of the latest <em>zman tfila</em> based on this calculation. If the
     *         calculation can't be computed such as in the Arctic Circle where there is at least one day a year where
     *         the sun does not rise, and one where it does not set, a `nil` will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos72Zmanis()
     * @see getTzaisAteretTorah()
     * @see getShaahZmanisAteretTorah()
     * @see setAteretTorahSunsetOffset(double)
     */
    public func getSofZmanTfilaAteretTorah() -> Date? {
        return getSofZmanTfila(startOfDay: getAlos72Zmanis(), endOfDay: getTzaisAteretTorah(), synchronous: false)
    }

    /**
     * This method returns the time of <em>mincha gedola</em> based on the calculation of <em>Chacham</em> Yosef
     * Harari-Raful of Yeshivat Ateret Torah, that the day starts 1/10th of the day
     * before sunrise and is usually calculated as ending 40 minutes after sunset
     * (configurable to any offset via ``setAteretTorahSunsetOffset()``). This is the preferred earliest
     * time to pray <em>mincha</em> according to the opinion of the <a href="https://en.wikipedia.org/wiki/Maimonides"
     * >Rambam</a> and others. For more information on this see the documentation on <em>mincha gedola</em>. This is calculated as 6.5 solar hours after <em>alos</em>. The
     * calculation used is 6.5 * ``getShaahZmanisAteretTorah()`` after <em>alos</em>.
     *
     * @see getAlos72Zmanis()
     * @see getTzaisAteretTorah()
     * @see getShaahZmanisAteretTorah()
     * @see getMinchaGedolaGRA()
     * @see getMinchaKetanaAteretTorah()
     * @see getMinchaGedolaGRA()
     * @see getAteretTorahSunsetOffset()
     * @see setAteretTorahSunsetOffset(double)
     * @return the `Date` of the time of <em>mincha gedola</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year when the sun does not rise, and one where it
     *         does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getMinchaGedolaAteretTorah() -> Date? {
        return getMinchaGedola(startOfDay: getAlos72Zmanis(), endOfDay: getTzaisAteretTorah(), synchronous: false)
    }

    /**
     * This method returns the time of <em>mincha ketana</em> based on the calculation of
     * <em>Chacham</em> Yosef Harari-Raful of Yeshivat Ateret Torah, that the day starts
     * 1/10th of the day before sunrise and is usually calculated as ending
     * 40 minutes after sunset (configurable to any offset via
     * ``setAteretTorahSunsetOffset()``). This is the preferred earliest time to pray <em>mincha</em>
     * according to the opinion of the <a href="https://en.wikipedia.org/wiki/Maimonides">Rambam</a> and others.
     * For more information on this see the documentation on <em>mincha gedola</em>. This is
     * calculated as 9.5 solar hours after <em>alos</em>.
     * The calculation used is 9.5 * ``getShaahZmanisAteretTorah()`` after <em>alos</em>. If the calculated time is after sunset (on very short winter days), a `nil` will be returned.
     *
     * @see getAlos72Zmanis()
     * @see getTzaisAteretTorah()
     * @see getShaahZmanisAteretTorah()
     * @see getAteretTorahSunsetOffset()
     * @see setAteretTorahSunsetOffset(double)
     * @see getMinchaGedolaGRA()
     * @see getMinchaKetanaGRA()
     * @return the `Date` of the time of <em>mincha ketana</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year when the sun does not rise, and one where it
     *         does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getMinchaKetanaAteretTorah() -> Date? {
        return nullIfAfterSunset(zman: getMinchaKetana(startOfDay: getAlos72Zmanis(), endOfDay: getTzaisAteretTorah(), synchronous: false))
    }

    /**
     * This method returns the time of <em>plag hamincha</em> based on the calculation of <em>Chacham</em> Yosef Harari-Raful
     * of Yeshivat Ateret Torah, that the day starts 1/10th of the day before sunrise and is
     * usually calculated as ending 40 minutes after sunset (configurable to any offset
     * via ``setAteretTorahSunsetOffset()``). <em>shaos zmaniyos</em> are calculated based on this day and
     * added to <em>alos</em> to reach this time. This time is 10.75
     * <em>shaos zmaniyos</em> (temporal hours) after dawn. If the calculated time is after sunset (on very short winter days), a `nil` will be returned.
     *
     * @return the `Date` of the <em>plag</em>. If the calculation can't be computed such as in the Arctic Circle
     *         where there is at least one day a year when the sun does not rise, and one where it does not set, a `nil`
     *         will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos72Zmanis()
     * @see getTzaisAteretTorah()
     * @see getShaahZmanisAteretTorah()
     * @see setAteretTorahSunsetOffset(double)
     * @see getAteretTorahSunsetOffset()
     */
    public func getPlagHaminchaAteretTorah() -> Date? {
        return nullIfAfterSunset(zman: getPlagHamincha(startOfDay: getAlos72Zmanis(), endOfDay: getTzaisAteretTorah(), synchronous: false))
    }

    /**
     * Method to return <em>tzais</em> (dusk) calculated as 72 minutes zmaniyos, or 1/10th of the day after sea level sunset. This is the way that the <a href=
     * "https://en.wikipedia.org/wiki/Abraham_Cohen_Pimentel">Minchas Cohen</a> in Ma'amar 2:4 calculates Rebbeinu Tam's
     * time of <em>tzais</em>. It should be noted that this calculation results in the shortest time from sunset to
     * <em>tzais</em> being during the winter solstice, the longest at the summer solstice and 72 clock minutes at the
     * equinox. This does not match reality, since there is no direct relationship between the length of the day and
     * twilight. The shortest twilight is during the equinox, the longest is during the summer solstice, and in the
     * winter with the shortest daylight, the twilight period is longer than during the equinoxes.
     *
     * @return the `Date` representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set,
     *         a `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see getAlos72Zmanis()
     */
    public func getTzais72Zmanis() -> Date? {
        return getZmanisBasedOffset(hours: 1.2)
    }

    /**
     * Method to return <em>tzais</em> (dusk) calculated using 90 minutes zmaniyos or 1/8th of the day after sea level sunset. This time is known in Yiddish as the <em>achtel</em> (an eighth)
     * <em>zman</em> used in various <em>kehilos</em>.
     *
     * @return the `Date` representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set,
     *         a `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see getAlos90Zmanis()
     */
    public func getTzais90Zmanis() -> Date? {
        return getZmanisBasedOffset(hours: 1.5)
    }

    /**
     * Method to return <em>tzais</em> (dusk) calculated using 96 minutes <em>zmaniyos</em> or 1/7.5 of the day after
     * sea level sunset.
     *
     * @return the `Date` representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set,
     *         a `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see getAlos96Zmanis()
     */
    public func getTzais96Zmanis() -> Date? {
        return getZmanisBasedOffset(hours: 1.6)
    }

    /**
     * Method to return <em>tzais</em> (dusk) calculated as 90 minutes after ``getSunsetBasedOnElevationSetting`` (depends on
     * the ``isUseElevation()`` setting). This method returns <em>tzais</em> (nightfall) based on the opinion of the Magen
     * Avraham that the time to walk the distance of a <a href="https://en.wikipedia.org/wiki/Biblical_mile">mil</a> according to the
     * <a href="https://en.wikipedia.org/wiki/Maimonides">Rambam</a>'s opinion is 18 minutes, for a total of 90 minutes based on the
     * opinion of Ula who calculated <em>tzais</em> as 5 mil after elevation adjusted <em>shkiah</em> (sunset). A similar
     * calculation ``getTzais19Point8Degrees()`` uses solar position* calculations based on this time.
     *
     * @return the `Date` representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set,
     *         a `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see getTzais19Point8Degrees()
     * @see getAlos90Minutes()
     */
    public func getTzais90Minutes() -> Date? {
        return AstronomicalCalendar.getTimeOffset(time: getSunsetBasedOnElevationSetting(), offset: 90 * 60.0)
    }

    /**
     * This method should be used <em>lechumra</em> only and returns <em>tzais</em> (nightfall) based on the calculations of <a href=
     * "https://en.wikipedia.org/wiki/Avraham_Chaim_Naeh">Rav Chaim Naeh</a> that the time to walk the distance of a <a href=
     * "https://en.wikipedia.org/wiki/Biblical_mile">mil</a> according to the <a href="https://en.wikipedia.org/wiki/Maimonides"
     * >Rambam</a>'s opinion is 2/5 of an hour (24 minutes) for a total of 120* minutes based on the opinion of <em>Ula</em> who
     * calculated <em>tzais</em> as 5 mil after ``getSunsetBasedOnElevationSetting()`` (depends on the ``isUseElevation()``
     * setting). A similar calculation ``getTzais26Degrees()`` uses degree-based calculations based on this 120 minute
     * calculation Since the <em>zman</em> is extremely late and at a point that is long past the 18° point where the darkest point
     * is reached, it should only be used <em>lechumra</em>, such as delaying the start of nighttime <em>mitzvos</em>.
     *
     * - Warning: This method should be used <em>lechumra</em> only since it returns a very late time, and if used
     *         <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no current plan to remove this
     *         method from the API, and this deprecation is intended to alert developers of the danger of using it.
     * @return the `Date` representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set,
     *         a `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar``.
     *         documentation.
     * @see getTzais26Degrees()
     * @see getAlos120Minutes()
     */
    public func getTzais120Minutes() -> Date? {
        return AstronomicalCalendar.getTimeOffset(time: getSunsetBasedOnElevationSetting(), offset: 120 * 60.0)
    }

    /**
     * This method should be used <em>lechumra</em> only and returns <em>tzais</em> (dusk) calculated using 120 minutes
     * <em>zmaniyos</em> after sea level sunset. Since the <em>zman</em>
     * is extremely late and at a time when the sun is well below the 18° point (scientifically the darkest point) in
     * most places on the globe, it should only be used <em>lechumra</em>, such as delaying the start of nighttime
     * <em>mitzvos</em>.
     *
     * - Warning: This method should be used <em>lechumra</em> only since it returns a very late time, and if used
     *         <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no current plan to remove this
     *         method from the API, and this deprecation is intended to alert developers of the danger of using it.
     *
     * @return the `Date` representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set,
     *         a `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see getAlos120Zmanis()
     * @see getTzais120Minutes()
     * @see getTzais26Degrees()
     */
    public func getTzais120Zmanis() -> Date? {
        return getZmanisBasedOffset(hours: 2.0)
    }

    /**
     * This calculates the time of <em>tzais</em> at the point when the sun is 16.1° below the horizon. This is
     * the sun's dip below the horizon 72 minutes after sunset according Rabbeinu Tam's calculation of <em>tzais</em>
     * <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a> in
     * Jerusalem. The question of equinox VS equilux is complex, with Rabbi Meir Posen in the <a href=
     * "https://www.worldcat.org/oclc/956316270">Ohr Meir</a> of the opinion that the equilux should be used. See
     * Yisrael Vehazmanim vol I, 34:1:4. Rabbi Yedidya Manet in his <a href=
     * "https://www.nli.org.il/en/books/NNL_ALEPH002542826/NLI">Zmanei HaHalacha Lema'aseh</a> (4th edition part 2, pages
     * and 22 and 24) and Rabbi Yonah Mertzbuch (in a letter published by Rabbi Manet) are of the opinion that the
     * astronomical equinox should be used. The difference adds up to about 9 seconds, too trivial to make much of a
     * difference. For information on how this is calculated see the comments on ``getAlos16Point1Degrees()``.
     *
     * @return the `Date` representing the time. If the calculation can't be computed such as northern and
     *         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may
     *         not reach low enough below the horizon for this calculation, a `nil` will be returned. See
     *         detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getTzais72Minutes()
     * @see getAlos16Point1Degrees() for more information on this calculation.
     */
    public func getTzais16Point1Degrees() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ZmanimCalendar.ZENITH_16_POINT_1)
    }

    /**
     * This method should be used <em>lechumra</em> only and returns <em>tzais</em> based on when the sun is 26°
     * below the horizon. For information on how this is calculated see the comments on ``getAlos26Degrees()``.
     * Since the <em>zman</em> is extremely late and at a point when it is long past the 18° point where the
     * darkest point is reached, it should only be used <em>lechumra</em> such as delaying the start of nighttime
     * <em>mitzvos</em>.
     *
     * - Warning: This method should be used <em>lechumra</em> only since it returns a very late time, and if used
     *         <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no current plan to remove this
     *         method from the API, and this deprecation is intended to alert developers of the danger of using it.
     *
     * @return the `Date` representing the time. If the calculation can't be computed such as northern and
     *         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may
     *         not reach low enough below the horizon for this calculation, a `nil` will be returned. See
     *         detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getTzais120Minutes()
     * @see getAlos26Degrees()
     */
    public func getTzais26Degrees() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_26_DEGREES)
    }

    /**
     * For information on how this is calculated see the comments on ``getAlos18Degrees()``
     *
     * @return the `Date` representing the time. If the calculation can't be computed such as northern and
     *         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may
     *         not reach low enough below the horizon for this calculation, a `nil` will be returned. See
     *         detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos18Degrees()
     */
    public func getTzais18Degrees() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: AstronomicalCalendar.ASTRONOMICAL_ZENITH)
    }

    /**
     * For information on how this is calculated see the comments on ``getAlos19Point8Degrees()``.
     *
     * @return the `Date` representing the time. If the calculation can't be computed such as northern and
     *         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may
     *         not reach low enough below the horizon for this calculation, a `nil` will be returned. See
     *         detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getTzais90Minutes()
     * @see getAlos19Point8Degrees()
     */
    public func getTzais19Point8Degrees() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_19_POINT_8)
    }

    /**
     * A method to return <em>tzais</em> (dusk) calculated as 96 minutes after sunset or sea level sunset (depending on the ``isUseElevation()`` setting). For information on how
     * this is calculated see the comments on ``getAlos96Minutes()``.
     *
     * @return the `Date` representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set,
     *         a `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see getAlos96Minutes()
     */
    public func getTzais96Minutes() -> Date? {
        return AstronomicalCalendar.getTimeOffset(time: getSunsetBasedOnElevationSetting(), offset: 96 * 60.0)
    }

    /**
     * A method that returns the local time for fixed <em>chatzos</em>. This time is noon and adjusted from
     * standard time to account for the local longitude. The 360° of the globe divided by 24 calculates to 15°
     * per hour with 4 minutes per degree, so at a longitude of 0 , 15, 30 etc... <em>Chatzos</em> is at exactly 12:00
     * noon. This is the time of <em>chatzos</em> according to the <a href=
     * "https://en.wikipedia.org/wiki/Aruch_HaShulchan">Aruch Hashulchan</a> in <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=7705&pgnum=426">Orach Chaim 233:14</a> and <a href=
     * "https://en.wikipedia.org/wiki/Moshe_Feinstein">Rabbi Moshe Feinstein</a> in Igros Moshe <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=916&st=&pgnum=67">Orach Chaim 1:24</a> and <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=14675&pgnum=191">2:20</a>.
     * Lakewood, N.J., with a longitude of -74.222, is 0.778 away from the closest multiple of 15 at -75°. This
     * is multiplied by 4 to yield 3 minutes and 7 seconds for a <em>chatzos</em> of 11:56:53. This method is not tied
     * to the theoretical 15° time zones, but will adjust to the actual time zone and <a
     * href="https://en.wikipedia.org/wiki/Daylight_saving_time">Daylight saving time</a>. On very short polar days, fixed local
     * <em>chatzos</em> can fall before sunrise or after sunset; in those cases a `nil` is returned. Days without a sunrise
     * or sunset (polar day or night) are not affected.
     *
     * @return the Instant representing the local <em>chatzos</em>, or `nil` if it is before sunrise or after sunset.
     * @see GeoLocation/getLocalMeanTimeOffset(Instant)
     * @see getLocalMeanTime(LocalTime)
     */
    public func getFixedLocalChatzosHayom() -> Date? {
        let fixedLocalChatzos: Date? = getLocalMeanTime(hours: 12)
        if fixedLocalChatzos == nil {
            return nil
        }
        let sunrise: Date? = getSunriseBasedOnElevationSetting()
        let sunset: Date? = getSunsetBasedOnElevationSetting()
        if (sunrise != nil && fixedLocalChatzos!.isBefore(sunrise!)) || (sunset != nil && fixedLocalChatzos!.isAfter(sunset!)) {
            return nil // very short polar day: fixed local chatzos is outside the day
        }
        return fixedLocalChatzos
    }

    /**
     * Returns the latest time of <em>Kidush Levana</em> according to the <a
     * href="https://en.wikipedia.org/wiki/Yaakov_ben_Moshe_Levi_Moelin">Maharil's</a> opinion that it is calculated as
     * halfway between <em>molad</em> and <em>molad</em>. This adds half the 29 days, 12 hours and 793 chalakim time
     * between <em>molad</em> and <em>molad</em> (14 days, 18 hours, 22 minutes and 666 milliseconds) to the month's <em>molad</em>.
     * If the time of <em>sof zman Kiddush Levana</em> occurs during the day (between the <em>alos</em> and <em>tzais</em> passed in
     * as parameters), it returns the <em>alos</em> passed in. If a `nil` <em>alos</em> or <em>tzais</em> are passed to
     * this method, the non-daytime adjusted time will be returned.
     *
     * @param alos the beginning of the Jewish day. If <em>Kidush Levana</em> occurs during the day (starting at <em>alos</em> and
     *         ending at <em>tzais</em>), the time returned will be <em>alos</em>. If either the <em>alos</em> or <em>tzais</em>
     *         parameters are `nil`, no daytime adjustment will be made.
     * @param tzais the end of the Jewish day. If Kidush Levana occurs during the day (starting at <em>alos</em> and ending at
     *         <em>tzais</em>), the time returned will be <em>alos</em>. If either the <em>alos</em> or <em>tzais</em> parameter
     *         are `nil`, no daytime adjustment will be made.
     * @return the Instant representing the moment halfway between molad and molad. If the time occurs between
     *         <em>alos</em> and <em>tzais</em>, <em>alos</em> will be returned. If the <em>zman</em> will not occur on this day, a
     *         `nil` will be returned.
     * @see getSofZmanKidushLevanaBetweenMoldos()
     * @see getSofZmanKidushLevana15Days(Instant, Instant)
     * @see JewishCalendar/getSofZmanKidushLevanaBetweenMoldos()
     */
    public func getSofZmanKidushLevanaBetweenMoldos(alos: Date?, tzais: Date?) -> Date? {
        let jewishCalendar = JewishCalendar(localDate: getLocalDate())

        // Do not calculate for impossible dates, but account for extreme cases. In the extreme case of Rapa Iti in French
        // Polynesia on Dec 2027 when kiddush Levana 3 days can be said on <em>Rosh Chodesh</em>, the sof zman Kiddush Levana
        // will be on the 12th of the Teves. In the case of Anadyr, Russia on Jan, 2071, sof zman Kiddush Levana between the
        // moldos will occur is on the night of 17th of Shevat. See Rabbi Dovid Heber's Shaarei Zmanim chapter 4 (pages 28 and 32).
        if jewishCalendar.getJewishDayOfMonth() < 11 || jewishCalendar.getJewishDayOfMonth() > 16 {
            return nil
        }
        return getMoladBasedTime(moladBasedTime: jewishCalendar.getSofZmanKidushLevanaBetweenMoldos(), alos: alos, tzais: tzais, techila: false)
    }

    /**
     * Returns the Instant of the <em>molad</em> based time if it occurs on the current date. Since <em>Kiddush Levana</em>
     * can only be said during the day, there are parameters to limit it to between <em>alos</em> and <em>tzais</em>. If
     * the time occurs between <em>alos</em> and <em>tzais</em>, <em>tzais</em> will be returned.
     *
     * @param moladBasedTime the <em>molad</em> based time such as <em>molad</em>, <em>tchilas</em> and <em>sof zman Kiddush
     *         Levana</em>
     * @param alos optional start of day to limit <em>molad</em> times to the end of the night before or beginning of the next night.
     *         Ignored if either <em>alos</em> or <em>tzais</em> are `nil`.
     * @param tzais optional end of day to limit <em>molad</em> times to the end of the night before or beginning of the next night.
     *         Ignored if either <em>tzais</em> or <em>alos</em> are `nil`
     * @param techila is it the start of <em>Kiddush Levana</em> time or the end? If it is start roll it to the next <em>tzais</em>,
     *         and if it is the end, return the end of the previous night (<em>alos</em> passed in). Ignored if either
     *         <em>alos</em> or <em>tzais</em> are `nil`.
     * @return the <em>molad</em> based time. If the <em>zman</em> does not occur during the current date, `nil` will be
     *         returned.
     */
    private func getMoladBasedTime(moladBasedTime: Date?, alos: Date?, tzais: Date?, techila: Bool) -> Date? {
        let lastMidnight: Date? = getMidnightLastNight()
        let midnightTonight: Date? = getMidnightTonight()
        if(moladBasedTime!.isBefore(lastMidnight!) || moladBasedTime!.isAfter(midnightTonight!)){ // Invalid time, bailout
            return nil
        } else if(alos == nil || tzais == nil){ // Not enough info to adjust
           return moladBasedTime
        } else { // It's the daytime, get the next/prev night
            if moladBasedTime!.isAfter(alos!) && moladBasedTime!.isBefore(tzais!) {
                if techila {
                    return tzais
                } else {
                    return alos
                }
            } else { // It's the night, the provided time is valid
                return moladBasedTime
            }
        }
    }

    /**
     * Returns the latest time of Kiddush Levana according to the <a
     * href="https://en.wikipedia.org/wiki/Yaakov_ben_Moshe_Levi_Moelin">Maharil's</a> opinion that it is calculated as
     * halfway between <em>molad</em> and <em>molad</em>. This adds half the 29 days, 12 hours and 793 chalakim time between
     * <em>molad</em> and <em>molad</em> (14 days, 18 hours, 22 minutes and 666 milliseconds) to the month's <em>molad</em>.
     * The <em>sof zman Kiddush Levana</em> will be returned even if it occurs during the day. To limit the time to between
     * <em>tzais</em> and <em>alos</em>, see ``getSofZmanKidushLevanaBetweenMoldos()``.
     *
     * @return the Instant representing the moment halfway between molad and molad. If the <em>zman</em> will not occur on this
     *         day, a `nil` will be returned.
     * @see getSofZmanKidushLevanaBetweenMoldos(Instant, Instant)
     * @see getSofZmanKidushLevana15Days()
     * @see JewishCalendar/getSofZmanKidushLevanaBetweenMoldos()
     */
    public func getSofZmanKidushLevanaBetweenMoldos() -> Date? {
        return getSofZmanKidushLevanaBetweenMoldos(alos: nil, tzais: nil)
    }

    /**
     * Returns the latest time of <em>Kiddush Levana</em> calculated as 15 days after the <em>molad</em>. This is the
     * opinion brought down in the Shulchan Aruch (Orach Chaim 426). It should be noted that some opinions hold that the
     * <a href="https://en.wikipedia.org/wiki/Moses_Isserles">Rema</a> who brings down the opinion of the <a
     * href="https://en.wikipedia.org/wiki/Yaakov_ben_Moshe_Levi_Moelin">Maharil's</a> of calculating
     * halfway between <em>molad</em> and <em>molad</em> is of
     * the opinion that the Mechaber agrees to his opinion. Also see the Aruch Hashulchan. For additional details on the subject,
     * see Rabbi Dovid Heber's very detailed write-up in <em>Siman Daled</em> (chapter 4) of <a href=
     * "https://hebrewbooks.org/53000">Shaarei Zmanim</a>. If the time of <em>sof zman Kiddush Levana</em> occurs during
     * the day (between the <em>alos</em> and <em>tzais</em> passed in as parameters), it returns the <em>alos</em> passed in. If a
     * `nil` <em>alos</em> or <em>tzais</em> are passed to this method, the non-daytime adjusted time will be returned.
     *
     * @param alos the beginning of the Jewish day. If <em>Kidush Levana</em> occurs during the day (starting at <em>alos</em> and
     *         ending at <em>tzais</em>), the time returned will be <em>alos</em>. If either the <em>alos</em> or <em>tzais</em>
     *         parameters are `nil`, no daytime adjustment will be made.
     * @param tzais the end of the Jewish day. If <em>Kidush Levana</em> occurs during the day (starting at <em>alos</em> and ending
     *         at <em>tzais</em>), the time returned will be <em>alos</em>. If either the <em>alos</em> or <em>tzais</em> parameters
     *         are `nil`, no daytime adjustment will be made.
     * @return the Instant representing the moment 15 days after the molad. If the time occurs between <em>alos</em> and
     *         <em>tzais</em>, <em>alos</em> will be returned. If the <em>zman</em> will not occur on this day, a
     *         `nil` will be returned.
     * @see getSofZmanKidushLevanaBetweenMoldos(Instant, Instant)
     * @see JewishCalendar/getSofZmanKidushLevana15Days()
     */
    public func getSofZmanKidushLevana15Days(alos: Date?, tzais: Date?) -> Date? {
        let jewishCalendar = JewishCalendar(localDate: getLocalDate())

        // Do not calculate for impossible dates, but account for extreme cases. In the extreme case of Rapa Iti in
        // French Polynesia on Dec 2027 when kiddush Levana 3 days can be said on <em>Rosh Chodesh</em>, the sof zman Kiddush
        // Levana will be on the 12th of the Teves. in the case of Anadyr, Russia on Jan, 2071, sof zman kiddush levana will
        // occur after midnight on the 17th of Shevat. See Rabbi Dovid Heber's Shaarei Zmanim chapter 4 (pages 28 and 32).
        if jewishCalendar.getJewishDayOfMonth() < 11 || jewishCalendar.getJewishDayOfMonth() > 17 {
            return nil
        }
        return getMoladBasedTime(moladBasedTime: jewishCalendar.getSofZmanKidushLevana15Days(), alos: alos, tzais: tzais, techila: false)
    }

    /**
     * Returns the latest time of <em>Kiddush Levana</em> calculated as 15 days after the molad. This is the opinion of
     * the Shulchan Aruch (Orach Chaim 426). It should be noted that some opinions hold that the
     * <a href="https://en.wikipedia.org/wiki/Moses_Isserles">Rema</a> who brings down the opinion of the <a
     * href="https://en.wikipedia.org/wiki/Yaakov_ben_Moshe_Levi_Moelin">Maharil's</a> of calculating
     * halfway between <em>molad</em> and <em>molad</em> is of
     * the opinion that the Mechaber agrees to his opinion. Also see the Aruch Hashulchan. For additional details on the subject,
     * See Rabbi Dovid Heber's very detailed write-up in Siman Daled (chapter 4) of <a href="https://hebrewbooks.org/53000">Shaarei
     * Zmanim</a>. The <em>sof zman Kiddush Levana</em> will be returned even if it occurs during the day. To limit the time to
     * between <em>tzais</em> and <em>alos</em>, see ``getSofZmanKidushLevana15Days()``.
     *
     * @return the Instant representing the moment 15 days after the <em>molad</em>. If the <em>zman</em> will not occur on this day,
     *         a `nil` will be returned.
     * @see getSofZmanKidushLevana15Days(Instant, Instant)
     * @see getSofZmanKidushLevanaBetweenMoldos()
     * @see JewishCalendar/getSofZmanKidushLevana15Days()
     *
     */
    public func getSofZmanKidushLevana15Days() -> Date? {
        return getSofZmanKidushLevana15Days(alos: nil, tzais: nil)
    }

    /**
     * Returns the earliest time of <em>Kiddush Levana</em> according to <a href=
     * "https://en.wikipedia.org/wiki/Yonah_Gerondi">Rabbeinu Yonah</a>'s opinion that it can be said 3 days after the
     * <em>molad</em>. The time will be returned even if it occurs during the day when <em>Kiddush Levana</em> can't be said.
     * Use ``getTchilasZmanKidushLevana3Days()`` if you want to limit the time to night hours.
     *
     * @return the Instant representing the moment 3 days after the molad. If the <em>zman</em> will not occur on this day, a
     *         `nil` will be returned.
     * @see getTchilasZmanKidushLevana3Days(Instant, Instant)
     * @see getTchilasZmanKidushLevana7Days()
     * @see JewishCalendar/getTchilasZmanKidushLevana3Days()
     */
    public func getTchilasZmanKidushLevana3Days() -> Date? {
        return getTchilasZmanKidushLevana3Days(alos: nil, tzais: nil)
    }

    /**
     * Returns the earliest time of <em>Kiddush Levana</em> according to <a href=
     * "https://en.wikipedia.org/wiki/Yonah_Gerondi">Rabbeinu Yonah</a>'s opinion that it can be said 3 days after the <em>molad</em>.
     * If the time of <em>tchilas zman Kiddush Levana</em> occurs during the day (between <em>alos</em> and <em>tzais</em> passed to
     * this method) it will return the following <em>tzais</em>. If `nil` is passed for either <em>alos</em> or <em>tzais</em>, the
     * actual <em>tchilas zman Kiddush Levana</em> will be returned, regardless of if it is during the day or not.
     *
     * @param alos the beginning of the Jewish day. If Kidush Levana occurs during the day (starting at <em>alos</em> and ending at
     *         <em>tzais</em>), the time returned will be <em>tzais</em>. If either the <em>alos</em> or <em>tzais</em> parameters
     *         are `nil`, no daytime adjustment will be made.
     * @param tzais the end of the Jewish day. If <em>Kidush Levana</em> occurs during the day (starting at <em>alos</em> and ending
     *         at <em>tzais</em>), the time returned will be <em>tzais</em>. If either the <em>alos</em> or <em>tzais</em> parameters
     *         are `nil`, no daytime adjustment will be made.
     * @return the Instant representing the moment 3 days after the molad. If the time occurs between <em>alos</em> and
     *         <em>tzais</em>, <em>tzais</em> will be returned. If the <em>zman</em> will not occur on this day, a `nil`
     *         will be returned.
     * @see getTchilasZmanKidushLevana3Days()
     * @see getTchilasZmanKidushLevana7Days(Instant, Instant)
     * @see JewishCalendar/getTchilasZmanKidushLevana3Days()
     */
    public func getTchilasZmanKidushLevana3Days(alos: Date?, tzais: Date?) -> Date? {
        let jewishCalendar = JewishCalendar(localDate: getLocalDate())

        // Do not calculate for impossible dates, but account for extreme cases. Tchilas zman kiddush Levana 3 days for
        // the extreme case of Rapa Iti in French Polynesia on Dec 2027 when kiddush Levana 3 days can be said on the evening
        // of the 30th, the second night of Rosh Chodesh. The 3rd day after the <em>molad</em> will be on the 4th of the month.
        // In the case of Anadyr, Russia on Jan, 2071, when sof zman kiddush levana is on the 17th of the month, the 3rd day
        // from the molad will be on the 5th day of Shevat. See Rabbi Dovid Heber's Shaarei Zmanim chapter 4 (pages 28 and 32).
        if jewishCalendar.getJewishDayOfMonth() > 5 && jewishCalendar.getJewishDayOfMonth() < 30 {
            return nil
        }

        var zman: Date? = getMoladBasedTime(moladBasedTime: jewishCalendar.getTchilasZmanKidushLevana3Days(), alos: alos, tzais: tzais, techila: true)

        // Get the following month's zman kiddush Levana for the extreme case of Rapa Iti in French Polynesia on Dec 2027 when kiddush
        // Levana can be said on Rosh Chodesh (the evening of the 30th). See Rabbi Dovid Heber's Shaarei Zmanim chapter 4 (page 32)
        if zman == nil && jewishCalendar.getJewishDayOfMonth() == 30 {
            jewishCalendar.plusMonths(months: 1)
            zman = getMoladBasedTime(moladBasedTime: jewishCalendar.getTchilasZmanKidushLevana3Days(), alos: nil, tzais: nil, techila: true)
        }

        return zman
    }

    /**
     * Returns the point in time of <em>Molad</em> as a `Date` Object. For the traditional day of week, hour,
     * minute and chalakim, ``JewishCalendar/getMoladAsInstant()`` and the not yet completed
     * ``com.kosherjava.zmanim.hebrewcalendar.HebrewDateFormatter`` that will have formatting for this.
     *
     * @return the Instant representing the moment of the molad. If the <em>molad</em> does not occur on this day, a
     *         `nil` will be returned.
     * @see getTchilasZmanKidushLevana3Days()
     * @see getTchilasZmanKidushLevana7Days(Instant, Instant)
     * @see JewishCalendar/getMoladAsInstant()
     */
    public func getZmanMolad() -> Date? {
        let jewishCalendar = JewishCalendar(localDate: getLocalDate())

        // Optimize to not calculate for impossible dates, but account for extreme cases. The molad in the extreme case of Rapa
        // Iti in French Polynesia on Dec 2027 occurs on the night of the 27th of Kislev. In the case of Anadyr, Russia on
        // Jan 2071, the molad will be on the 2nd day of Shevat. See Rabbi Dovid Heber's Shaarei Zmanim chapter 4 (pages 28 and 32).
        if jewishCalendar.getJewishDayOfMonth() > 2 && jewishCalendar.getJewishDayOfMonth() < 27 {
            return nil
        }
        var molad: Date? = getMoladBasedTime(moladBasedTime: jewishCalendar.getMoladAsDate(), alos: nil, tzais: nil, techila: true)

        // deal with molad that happens on the end of the previous month
        if molad == nil && jewishCalendar.getJewishDayOfMonth() > 26 {
            jewishCalendar.plusMonths(months: 1)
            molad = getMoladBasedTime(moladBasedTime: jewishCalendar.getMoladAsDate(), alos: nil, tzais: nil, techila: true)
        }
        return molad
    }

    /**
     * Returns the earliest time of <em>Kiddush Levana</em> according to the opinions that it should not be said until 7
     * days after the <em>molad</em>. If the time of <em>tchilas zman Kiddush Levana</em> occurs during the day (between
     * <em>alos</em> and <em>tzais</em>) it
     * return the next <em>tzais</em>.
     *
     * @param alos the beginning of the Jewish day. If <em>Kidush Levana</em> occurs during the day (starting at <em>alos</em> and
     *         ending at <em>tzais</em>), the time returned will be <em>tzais</em>. If either the <em>alos</em> or <em>tzais</em>
     *         parameters are `nil`, no daytime adjustment will be made.
     * @param tzais the end of the Jewish day. If <em>Kidush Levana</em> occurs during the day (starting at <em>alos</em> and ending
     *         at <em>tzais</em>), the time returned will be <em>tzais</em>. If either the <em>alos</em> or <em>tzais</em> parameters
     *         are `nil`, no daytime adjustment will be made.
     * @return the Instant representing the moment 7 days after the molad. If the time occurs between <em>alos</em> and
     *         <em>tzais</em>, <em>tzais</em> will be returned. If the <em>zman</em> will not occur on this day, a
     *         `nil` will be returned.
     * @see getTchilasZmanKidushLevana3Days(Instant, Instant)
     * @see getTchilasZmanKidushLevana7Days()
     * @see JewishCalendar/getTchilasZmanKidushLevana7Days()
     */
    public func getTchilasZmanKidushLevana7Days(alos: Date?, tzais: Date?) -> Date? {
        let jewishCalendar = JewishCalendar(localDate: getLocalDate())

        // Optimize to not calculate for impossible dates, but account for extreme cases. Tchilas zman kiddush Levana 7 days for
        // the extreme case of Rapa Iti in French Polynesia on Jan 2028 (when kiddush Levana 3 days can be said on the evening
        // of the 30th, the second night of Rosh Chodesh), the 7th day after the molad will be on the 4th of the month.
        // In the case of Anadyr, Russia on Jan, 2071, when sof zman kiddush levana is on the 17th of the month, the 7th day
        // from the molad will be on the 9th day of Shevat. See Rabbi Dovid Heber's Shaarei Zmanim chapter 4 (pages 28 and 32).
        if jewishCalendar.getJewishDayOfMonth() < 4 || jewishCalendar.getJewishDayOfMonth() > 9 {
            return nil
        }

        return getMoladBasedTime(moladBasedTime: jewishCalendar.getTchilasZmanKidushLevana7Days(), alos: alos, tzais: tzais, techila: true)
    }

    /**
     * Returns the earliest time of <em>Kiddush Levana</em> according to the opinions that it should not be said until 7
     * days after the <em>molad</em>. The time will be returned even if it occurs during the day when <em>Kiddush Levana</em>
     * can't be recited. Use ``getTchilasZmanKidushLevana7Days()`` if you want to limit the time to night hours.
     *
     * @return the Instant representing the moment 7 days after the molad regardless of it is day or night. If the <em>zman</em>
     *         will not occur on this day, a `nil` will be returned.
     * @see getTchilasZmanKidushLevana7Days(Instant, Instant)
     * @see JewishCalendar/getTchilasZmanKidushLevana7Days()
     * @see getTchilasZmanKidushLevana3Days()
     */
    public func getTchilasZmanKidushLevana7Days() -> Date? {
        return getTchilasZmanKidushLevana7Days(alos: nil, tzais: nil)
    }

    /**
     * This method returns the latest time one is allowed eating <em>chametz</em> on <em>Erev Pesach</em> according to
     * the opinion of the <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a>. This time is identical to the <em>Sof zman tfilah</em> GRA and is provided as a convenience method for those who are
     * unaware how this <em>zman</em> is calculated. This time is 4 hours into the day based on the opinion of the
     * <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a> that the day is calculated from sunrise to sunset.
     * This returns the time 4 * ``getShaahZmanisGRA()`` after sea level sunrise. If it
     * is not <em>erev Pesach</em>, a `nil` will be returned.
     * @return the `Date` one is allowed eating <em>chametz</em> on <em>Erev Pesach</em>. If it is not <em>erev
     *         Pesach</em> or the calculation can't be computed such as in the Arctic Circle where there is at least one
     *         day a year when the sun does not rise, and one where it does not set, a `nil` will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanisGRA()
     * @see getSofZmanTfilaGRA()
     * @see getSofZmanAchilasChametz(Instant, Instant, boolean)
     */
    public func getSofZmanAchilasChametzGRA() -> Date? {
        return getSofZmanAchilasChametz(startOfDay: getSunriseBasedOnElevationSetting(), endOfDay: getSunsetBasedOnElevationSetting(), synchronous: true)
    }

    /**
     * This method returns the latest time one is allowed eating <em>chametz</em> on <em>Erev Pesach</em> according to the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on <em>alos</em>
     * being 72 minutes before ``getSunrise()``. This time is identical to the
     * <em>Sof zman tfilah</em> MGA 72 minutes. This time is 4 <em>shaos zmaniyos</em> (temporal hours) after dawn based on the
     * opinion of the MGA that the day is calculated from a dawn of 72 minutes before sunrise to nightfall of 72 minutes after sunset. This returns the time of 4 * ``getShaahZmanis72Minutes()``
     * after dawn. If it is not <em>erev Pesach</em>, a `nil` will be returned.
     *
     * @return the `Date` of the latest time of eating <em>chametz</em>. If it is not <em>erev Pesach</em> or the
     *         calculation can't be computed such as in the Arctic Circle where there is at least one day a year when the sun does
     *         not rise, and one where it does not set, a `nil` will be returned. See detailed explanation on top of
     *         the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis72Minutes()
     * @see getAlos72Minutes()
     * @see getSofZmanTfilaMGA72Minutes()
     * @see getSofZmanAchilasChametz(Instant, Instant, boolean)
     */
    public func getSofZmanAchilasChametzMGA72Minutes() -> Date? {
        return getSofZmanAchilasChametz(startOfDay: getAlos72Minutes(), endOfDay: getTzais72Minutes(), synchronous: true)
    }

    /**
     * This method returns the latest time one is allowed eating <em>chametz</em> on <em>Erev Pesach</em> according to the opinion
     * of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on <em>alos</em> being 72 zmaniyos minutes before ``getSunrise()``. This time is identical to the
     * <em>Sof zman tfilah</em> MGA 72 minutes zmanis. This time is 4 <em>shaos zmaniyos</em> (temporal hours) after dawn based on the
     * opinion of the MGA that the day is calculated from a dawn of 72 minutes zmanis before sunrise to
     * nightfall of 72 minutes zmanis after sunset. This returns the time of 4 * ``getShaahZmanis72MinutesZmanis()`` after dawn. If it is not <em>erev Pesach</em>, a `nil`
     * will be
     * returned.
     *
     * @return the `Date` of the latest time of eating <em>chametz</em>. If it is not <em>erev Pesach</em> or the
     *         calculation can't be computed such as in the Arctic Circle where there is at least one day a year when the sun does
     *         not rise, and one where it does not set, a `nil` will be returned. See detailed explanation on top of
     *         the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis72MinutesZmanis()
     * @see getAlos72Zmanis()
     * @see getSofZmanTfilaMGA72MinutesZmanis()
     * @see getSofZmanAchilasChametz(Instant, Instant, boolean)
     */
    public func getSofZmanAchilasChametzMGA72MinutesZmanis() -> Date? {
        return getSofZmanAchilasChametz(startOfDay: getAlos72Zmanis(), endOfDay: getTzais72Zmanis(), synchronous: true)
    }

    /**
     * This method returns the latest time one is allowed eating <em>chametz</em> on <em>Erev Pesach</em> according to the opinion of
     * the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on <em>alos</em> being 16.1° before ``getSunrise()``. This time is 4 ``getShaahZmanis16Point1Degrees()``
     * after ``getAlos16Point1Degrees()`` based on the opinion of the MGA that the day is calculated from dawn to nightfall with
     * both being 16.1° below sunrise or sunset. This returns the time of 4 ``getShaahZmanis16Point1Degrees()`` after dawn. If it is not <em>erev Pesach</em>, a `nil` will be returned.
     *
     * @return the `Date` of the latest time of eating <em>chametz</em>. If it is not <em>erev Pesach</em> or the
     *         calculation can't be computed such as northern and southern locations even south of the Arctic Circle and north of
     *         the Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis16Point1Degrees()
     * @see getAlos16Point1Degrees()
     * @see getSofZmanTfilaMGA16Point1Degrees()
     * @see getSofZmanAchilasChametz(Instant, Instant, boolean)
     */
    public func getSofZmanAchilasChametzMGA16Point1Degrees() -> Date? {
        return getSofZmanAchilasChametz(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzais16Point1Degrees(), synchronous: true)
    }

    /**
     * This method returns the latest time for burning <em>chametz</em> on <em>Erev Pesach</em> according to the opinion of the
     * <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a>. This returns the time 5 * ``getShaahZmanisGRA()`` after
     * ``getSeaLevelSunrise()``. If it is not  <em>erev Pesach</em>, a `nil` will be returned.
     * @return the `Date` of the latest time for burning <em>chametz</em> on <em>Erev Pesach</em>. If it is not
     *         <em>erev Pesach</em> or the calculation can't be computed such as in the Arctic Circle where there is at least
     *         one day a year when the sun does not rise, and one where it does not set, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanisGRA()
     * @see getSofZmanBiurChametz(Instant, Instant, boolean)
     */
    public func getSofZmanBiurChametzGRA() -> Date? {
        return getSofZmanBiurChametz(startOfDay: getSunriseBasedOnElevationSetting(), endOfDay: getSunsetBasedOnElevationSetting(), synchronous: true)
    }

    /**
     * This method returns the latest time for burning <em>chametz</em> on <em>Erev Pesach</em> according to the opinion of the
     * <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on <em>alos</em> being 72 minutes before ``getSunrise()``. This time is 5 <em>shaos zmaniyos</em> (temporal hours) after dawn based on the
     * opinion of the MGA that the day is calculated from a dawn of 72 minutes before sunrise to nightfall of 72 minutes after sunset. This returns the time of 5 * ``getShaahZmanis72Minutes()``
     * after dawn. If it is not  <em>erev Pesach</em>, a `nil` will be returned.
     * @return the `Date` of the latest time for burning <em>chametz</em> on <em>Erev Pesach</em>. If it is not
     *         <em>erev Pesach</em> or the calculation can't be computed such as in the Arctic Circle where there is at
     *         least one day a year when the sun does not rise, and one where it does not set, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis72Minutes()
     * @see getAlos72Minutes()
     * @see getSofZmanBiurChametz(Instant, Instant, boolean)
     */
    public func getSofZmanBiurChametzMGA72Minutes() -> Date? {
        return getSofZmanBiurChametz(startOfDay: getAlos72Minutes(), endOfDay: getTzais72Minutes(), synchronous: true)
    }

    /**
     * This method returns the latest time for burning <em>chametz</em> on <em>Erev Pesach</em> according to the opinion of the
     * <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on <em>alos</em> being 72 minutes zmanis before ``getSunrise()``. This time is 5 <em>shaos zmaniyos</em> (temporal hours) after dawn based on the
     * opinion of the MGA that the day is calculated from a dawn of 72 minutes zmanis before sunrise to
     * nightfall of 72 minutes zmanis after sunset. This returns the time of 5 * ``getShaahZmanis72MinutesZmanis()`` after dawn. If it is not  <em>erev Pesach</em>, a
     * `nil` will be returned.
     * @return the `Date` of the latest time for burning <em>chametz</em> on <em>Erev Pesach</em>. If it is not
     *         <em>erev Pesach</em> or the calculation can't be computed such as in the Arctic Circle where there is at
     *         least one day a year when the sun does not rise, and one where it does not set, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis72MinutesZmanis()
     * @see getAlos72Zmanis()
     * @see getSofZmanBiurChametz(Instant, Instant, boolean)
     */
    public func getSofZmanBiurChametzMGA72MinutesZmanis() -> Date? {
        return getSofZmanBiurChametz(startOfDay: getAlos72Zmanis(), endOfDay: getTzais72Zmanis(), synchronous: true)
    }

    /**
     * This method returns the latest time for burning <em>chametz</em> on <em>Erev Pesach</em> according to the opinion
     * of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on <em>alos</em>
     * being 16.1° before ``getSunrise()``. This time is 5
     * <em>shaos zmaniyos</em> (solar hours) after dawn based on the opinion of the MGA that the day is calculated from dawn to nightfall with both being 16.1°
     * below sunrise or sunset. This returns the time of 5 ``getShaahZmanis16Point1Degrees()`` after
     * dawn. If it is not  <em>erev Pesach</em>, a `nil` will be returned.
     * @return the `Date` of the latest time for burning <em>chametz</em> on <em>Erev Pesach</em>. If it is not
     *         <em>erev Pesach</em> or the calculation can't be computed such as northern and southern locations even south
     *         of the Arctic Circle and north of the Antarctic Circle where the sun may not reach low enough below the
     *         horizon for this calculation, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis16Point1Degrees()
     * @see getAlos16Point1Degrees()
     * @see getSofZmanBiurChametz(Instant, Instant, boolean)
     */
    public func getSofZmanBiurChametzMGA16Point1Degrees() -> Date? {
        return getSofZmanBiurChametz(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzais16Point1Degrees(), synchronous: true)
    }

    /**
     * A method that returns the <a href="https://en.wikipedia.org/wiki/Shneur_Zalman_of_Liadi">Baal Hatanya</a>'s a <em>shaah
     * zmanis</em> (temporal hour). This forms the base for the Baal Hatanya's day based
     * calculations that are calculated as a 1.583° dip below the horizon after sunset. According to the Baal Hatanya, <em>shkiah
     * amiti</em>, true (halachic) sunset, is when the top of the sun's disk disappears from view at an elevation similar to the
     * mountains of Eretz Yisrael. This time is calculated as the point at which the center of the sun's disk is 1.583° below the
     * horizon. A method that returns a <em>shaah zmanis</em> (temporal hour) calculated
     * based on the <a href="https://en.wikipedia.org/wiki/Shneur_Zalman_of_Liadi">Baal Hatanya</a>'s <em>netz amiti</em> and
     * <em>shkiah amiti</em> using a dip of 1.583° below the sea level horizon. This calculation divides the day based on the opinion
     * of the Baal Hatanya that the day runs from netz amiti to <em>shkiah amiti</em>. The calculations are based on a day from sea level <em>netz amiti</em>
     * to sea level <em>shkiah amiti</em>. The day is split into 12 equal parts with each one being a
     * <em>shaah zmanis</em>. This method is similar to ``getTemporalHour``, but all calculations are based on a sea level
     * sunrise and sunset.
     * @return the `TimeInterval` of a <em>shaah zmanis</em> calculated from <em>netz amiti</em> (sunrise) to <em>shkiah amiti</em> ("real" sunset). If the calculation
     *         can't be computed such as in the Arctic Circle where there is at least one day a year when the sun does not rise, and
     *         one where it does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getTemporalHour(Instant, Instant)
     * @see getSunriseBaalHatanya()
     * @see getSunsetBaalHatanya()
     * @see ZmanimCalendar/ZENITH_1_POINT_583
     */
    public func getShaahZmanisBaalHatanya() -> TimeInterval? {
        return getTemporalHour(startOfDay: getSunriseBaalHatanya(), endOfDay: getSunsetBaalHatanya())
    }

    /**
     * Returns the <a href="https://en.wikipedia.org/wiki/Shneur_Zalman_of_Liadi">Baal Hatanya</a>'s <em>alos</em> (dawn) calculated
     * as the time when the sun is 16.9° below the eastern geometric horizon before
     * ``getSunrise()``. It is based on the calculation that the time between dawn and <em>netz amiti</em> (sunrise) is 72
     * minutes, the time that is takes to walk 4 mil at 18 minutes a mil (<a href="https://en.wikipedia.org/wiki/Maimonides"
     * >Rambam</a> and others). The sun's position at 72 minutes before <em>netz amiti</em> (sunrise)
     * in Jerusalem <a href="https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox /
     * equilux</a> is 16.9° below ``AstronomicalCalendar/GEOMETRIC_ZENITH``.
     *
     * @return The `Date` of dawn. If the calculation can't be computed such as northern and southern
     *         locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not reach
     *         low enough below the horizon for this calculation, a `nil` will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getAlosBaalHatanya() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_16_POINT_9)
    }

    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite Shema in the morning). This time is 3 <em>shaos zmaniyos</em> (solar hours) after <em>netz amiti</em> (sunrise) based on the opinion of the Baal Hatanya that the day is calculated from sunrise to sunset. This returns the time
     * 3 * ``getShaahZmanisBaalHatanya()`` after <em>netz amiti</em> (sunrise).
     *
     * @see getSofZmanShma(Instant, Instant)
     * @see getShaahZmanisBaalHatanya()
     * @return the `Date` of the latest <em>zman shema</em> according to the Baal Hatanya. If the calculation
     *         can't be computed such as in the Arctic Circle where there is at least one day a year when the sun does
     *         not rise, and one where it does not set, a `nil` will be returned. See detailed explanation on
     *         top of the ``AstronomicalCalendar`` documentation.
     */
    public func getSofZmanShmaBaalHatanya() -> Date? {
        return getSofZmanShma(startOfDay: getSunriseBaalHatanya(), endOfDay: getSunsetBaalHatanya(), synchronous: true)
    }

    /**
     * This method returns the latest <em>zman tfilah</em> (time to recite the morning prayers). This time is 4 hours into the day
     * based on the opinion of the Baal Hatanya that the day is calculated from sunrise to sunset. This returns the time 4 *
     * ``getShaahZmanisBaalHatanya()`` after <em>netz amiti</em> (sunrise).
     *
     * @see getSofZmanTfila(Instant, Instant)
     * @see getShaahZmanisBaalHatanya()
     * @return the `Date` of the latest <em>zman tfilah</em>. If the calculation can't be computed such as in
     *         the Arctic Circle where there is at least one day a year when the sun does not rise, and one where it does
     *         not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getSofZmanTfilaBaalHatanya() -> Date? {
        return getSofZmanTfila(startOfDay: getSunriseBaalHatanya(), endOfDay: getSunsetBaalHatanya(), synchronous: true)
    }

    /**
     * This method returns the latest time one is allowed eating <em>chametz</em> on <em>Erev Pesach</em> according to the opinion
     * of the Baal Hatanya. This time is identical to the <em>Sof zman tfilah</em> Baal Hatanya.
     * This time is 4 hours into the day based on the opinion of the Baal Hatanya that the day is calculated from sunrise to sunset.
     * This returns the time 4 ``getShaahZmanisBaalHatanya()`` after <em>netz amiti</em> (sunrise). If it is not  <em>erev Pesach</em>, a `nil` will be returned.
     * @return the `Date` one is allowed eating <em>chametz</em> on <em>Erev Pesach</em>. If it is not <em>erev
     *         Pesach</em> or the  calculation can't be computed such as in the Arctic Circle where there is at least one
     *         day a year when the sun does not rise, and one where it does not set, a `nil` will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanisBaalHatanya()
     * @see getSofZmanTfilaBaalHatanya()
     * @see getSofZmanAchilasChametz(Instant, Instant, boolean)
     */
    public func getSofZmanAchilasChametzBaalHatanya() -> Date? {
        return getSofZmanAchilasChametz(startOfDay: getSunriseBaalHatanya(), endOfDay: getSunsetBaalHatanya(), synchronous: true)
    }

    /**
     * This method returns the latest time for burning <em>chametz</em> on <em>Erev Pesach</em> according to the opinion of the Baal
     * Hatanya. This time is 5 hours into the day based on the opinion of the Baal Hatanya that the day is calculated from sunrise
     * to sunset. This returns the time 5 * ``getShaahZmanisBaalHatanya()`` after <em>netz amiti</em> (sunrise). If it is not  <em>erev Pesach</em>, a `nil` will be returned.
     * @return the `Date` of the latest time for burning <em>chametz</em> on <em>Erev Pesach</em>.  If it is not
     *         <em>erev Pesach</em> or the  calculation can't be computed such as in the Arctic Circle where there is at
     *         least one day a year when the sun does not rise, and one where it does not set, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanisBaalHatanya()
     * @see getSofZmanBiurChametz(Instant, Instant, boolean)
     */
    public func getSofZmanBiurChametzBaalHatanya() -> Date? {
        return getSofZmanBiurChametz(startOfDay: getSunriseBaalHatanya(), endOfDay: getSunsetBaalHatanya(), synchronous: true)
    }

    /**
     * This method returns the time of <em>mincha gedola</em>. <em>Mincha gedola</em> is the earliest time one can pray
     * <em>mincha</em>. The <a href="https://en.wikipedia.org/wiki/Maimonides">Rambam</a> is of the opinion that it is
     * better to delay <em>mincha</em> until <em>mincha ketana</em> while the
     * <a href="https://en.wikipedia.org/wiki/Asher_ben_Jehiel">Ra"sh</a>,
     * <a href="https://en.wikipedia.org/wiki/Jacob_ben_Asher">Tur</a>, <a href=
     * "https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a> and others are of the opinion that <em>mincha</em> can be prayed
     * <em>lechatchila</em> starting at <em>mincha gedola</em>. This is calculated as 6.5 sea level solar hours after <em>netz amiti</em> (sunrise). This calculation is based
     * on the opinion of the Baal Hatanya that the day is calculated from sunrise to sunset. This returns the time 6.5
     * * ``getShaahZmanisBaalHatanya()`` after <em>netz amiti</em> ("real" sunrise).
     * @todo Consider adjusting this to calculate the time as 30 clock or <em>zmaniyos </em> minutes after either astronomical <em>chatzos</em> or <em>chatzos</em> as half a day for calculators that support it, based on ``isUseAstronomicalChatzos()``.
     * @see getMinchaGedola(Instant, Instant)
     * @see getShaahZmanisBaalHatanya()
     * @see getMinchaKetanaBaalHatanya()
     * @return the `Date` of the time of <em>mincha gedola</em> according to the Baal Hatanya. If the calculation
     *         can't be computed such as in the Arctic Circle where there is at least one day a year when the sun does not rise,
     *         and one where it does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getMinchaGedolaBaalHatanya() -> Date? {
        return getMinchaGedola(startOfDay: getSunriseBaalHatanya(), endOfDay: getSunsetBaalHatanya(), synchronous: true)
    }

    /**
     * This method returns the time of <em>mincha ketana</em>. This is the preferred earliest time to pray <em>mincha</em> in the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Maimonides">Rambam</a> and others. For more information on this see the
     * documentation on <em>mincha gedola</em>. This is calculated as 9.5 sea level solar hours after <em>netz amiti</em> (sunrise).
     * This calculation is calculated based on the opinion of the Baal Hatanya that the day is calculated from sunrise to sunset.
     * This returns the time 9.5 * ``getShaahZmanisBaalHatanya()`` after <em>netz amiti</em>.
     *
     * @see getMinchaKetana(Instant, Instant)
     * @see getShaahZmanisBaalHatanya()
     * @see getMinchaGedolaBaalHatanya()
     * @return the `Date` of the time of <em>mincha ketana</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year when the sun does not rise, and one where it
     *         does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getMinchaKetanaBaalHatanya() -> Date? {
        return getMinchaKetana(startOfDay: getSunriseBaalHatanya(), endOfDay: getSunsetBaalHatanya(), synchronous: true)
    }

    /**
     * This method returns the time of <em>plag hamincha</em>. This is calculated as 10.75 hours after sunrise. This calculation
     * is based on the opinion of the Baal Hatanya that the day is calculated from sunrise to sunset. This returns the time
     * 10.75 * ``getShaahZmanisBaalHatanya()`` after <em>netz amiti</em> (sunrise). See
     * <a href="https://www.chabad.org/library/article_cdo/aid/3209349/jewish/About-Our-Zmanim-Calculations.htm">About Our
     * <em>Zmanim</em> Calculations @ Chabad.org</a> for more details on this calculation.
     *
     * @see getPlagHamincha(Instant, Instant)
     * @return the `Date` of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year when the sun does not rise, and one where it
     *         does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getPlagHaminchaBaalHatanya() -> Date? {
        return getPlagHamincha(startOfDay: getSunriseBaalHatanya(), endOfDay: getSunsetBaalHatanya(), synchronous: true)
    }

    /**
     * A method that returns <em>tzais</em> (nightfall) when the sun is 6° below the western geometric horizon (90°) after sunset.  This <em>tzais</em> / nightfall based on the opinion of the  <a href=
     * "https://en.wikipedia.org/wiki/Shneur_Zalman_of_Liadi">Baal Hatanya</a>. This calculation is based on the position of the sun
     * about 24 minutes after sunset in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>, which is 6°
     * below ``AstronomicalCalendar/GEOMETRIC_ZENITH``. See <a href=
     * "https://www.chabad.org/library/article_cdo/aid/3209349/jewish/About-Our-Zmanim-Calculations.htm">About Our <em>Zmanim</em>
     * Calculations @ Chabad.org</a> that is based on <em>shkiah amitis</em> as 1.583° below the horizon calculated around the equinox / equilux that computes 3.516 minutes after sunset. To this, 18 minutes of 3/4 of a
     * 24-minute mil and two minutes for <em>bain hashmashos</em> of Rav Yosi is added. This calculation computes the sun being
     * 5.83° below the horizon (very close to the slightly later ``getTzaisGeonim5Point95Degrees()`` that was calculated based
     * on 4 fixed minutes) and it is rounded up to 6°.
     *
     * @return The `Date` of nightfall. If the calculation can't be computed such as northern and southern
     *         locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not reach
     *         low enough below the horizon for this calculation, a `nil` will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getTzaisGeonim5Point95Degrees()
     * @see getSunsetBaalHatanya()
     */
    public func getTzaisBaalHatanya() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ComprehensiveZmanimCalendar.ZENITH_6_DEGREES)
    }

    /**
     * This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion of the
     * calculation of <em>sof zman krias shema</em> (latest time to recite <em>Shema</em> in the morning) according to the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> that the
     * day is calculated from dawn to nightfall, but calculated using the first half of the day only. The half a day starts
     * at <em>alos</em> defined as 18° and ends at fixed local chatzos. <em>Sof Zman Shema</em> is 3 <em>shaos zmaniyos</em> (solar hours) after <em>alos</em> or half of this half-day.
     * If fixed local <em>chatzos</em> is before sunrise or after sunset (on very short polar days), a `nil` will be returned.
     *
     * @return the `Date` of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos18Degrees()
     * @see getFixedLocalChatzosHayom()
     * @see getHalfDayBasedZman(Instant, Instant, double)
     */
    public func getSofZmanShmaMGA18DegreesToFixedLocalChatzos() -> Date? {
        return getHalfDayBasedZman(startOfHalfDay: getAlos18Degrees(), endOfHalfDay: getFixedLocalChatzosHayom(), hours: 3)
    }

    /**
     * This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion of the
     * calculation of <em>sof zman krias shema</em> (latest time to recite <em>Shema</em> in the morning) according to the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> that the day is calculated
     * from dawn to nightfall, but calculated using the first half of the day only. The half a day starts at <em>alos</em> defined
     * as 16.1° and ends at fixed local chatzos. <em>Sof Zman
     * Shema</em> is 3 <em>shaos zmaniyos</em> (solar hours) after this <em>alos</em> or half of this half-day. If fixed local
     * <em>chatzos</em> is before sunrise or after sunset (on very short polar days), a `nil` will be returned.
     *
     * @return the `Date` of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a `nil` will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos16Point1Degrees()
     * @see getFixedLocalChatzosHayom()
     * @see getHalfDayBasedZman(Instant, Instant, double)
     */
    public func getSofZmanShmaMGA16Point1DegreesToFixedLocalChatzos() -> Date? {
        return getHalfDayBasedZman(startOfHalfDay: getAlos16Point1Degrees(), endOfHalfDay: getFixedLocalChatzosHayom(), hours: 3)
    }

    /**
     * This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion of the
     * calculation of <em>sof zman krias shema</em> (latest time to recite <em>Shema</em> in the morning) according to the opinion of
     * the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> that the day is calculated from dawn to
     * nightfall, but calculated using the first half of the day only. The half a day starts at <em>alos</em> defined as 90 minutes before sunrise and ends at fixed local chatzos. <em>Sof
     * Zman Shema</em> is 3 <em>shaos zmaniyos</em> (solar hours) after this <em>alos</em> or half of this half-day. If fixed local
     * <em>chatzos</em> is before sunrise or after sunset (on very short polar days), a `nil` will be returned.
     *
     * @return the `Date` of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos90Minutes()
     * @see getFixedLocalChatzosHayom()
     * @see getHalfDayBasedZman(Instant, Instant, double)
     */
    public func getSofZmanShmaMGA90MinutesToFixedLocalChatzos() -> Date? {
        return getHalfDayBasedZman(startOfHalfDay: getAlos90Minutes(), endOfHalfDay: getFixedLocalChatzosHayom(), hours: 3)
    }

    /**
     * This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion of the
     * calculation of <em>sof zman krias shema</em> (latest time to recite <em>Shema</em> in the morning) according to the opinion of
     * the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> that the day is calculated from dawn to
     * nightfall, but calculated using the first half of the day only. The half a day starts at <em>alos</em> defined as 72 minutes before sunrise and ends at ``getFixedLocalChatzosHayom()``. <em>Sof Zman Shema</em> is 3
     * <em>shaos zmaniyos</em> (solar hours) after this <em>alos</em> or half of this half-day. If fixed local <em>chatzos</em> is
     * before sunrise or after sunset (on very short polar days), a `nil` will be returned.
     *
     * @return the `Date` of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos72Minutes()
     * @see getFixedLocalChatzosHayom()
     * @see getHalfDayBasedZman(Instant, Instant, double)
     */
    public func getSofZmanShmaMGA72MinutesToFixedLocalChatzos() -> Date? {
        return getHalfDayBasedZman(startOfHalfDay: getAlos72Minutes(), endOfHalfDay: getFixedLocalChatzosHayom(), hours: 3)
    }

    /**
     * This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion of the
     * calculation of <em>sof zman krias shema</em> (latest time to recite <em>Shema</em> in the morning) according to the opinion
     * of the <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a> that the day is calculated from sunrise to sunset, but
     * calculated using the first half of the day only. The half a day starts at ``getSunrise()`` and
     * ends at fixed local chatzos. <em>Sof zman Shema</em> is 3 <em>shaos zmaniyos</em> (solar
     * hours) after sunrise or half of this half-day. If fixed local <em>chatzos</em> is before sunrise or after sunset (on very
     * short polar days), a `nil` will be returned.
     *
     * @return the `Date` of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getSunrise()
     * @see getFixedLocalChatzosHayom()
     * @see getHalfDayBasedZman(Instant, Instant, double)
     */
    public func getSofZmanShmaGRASunriseToFixedLocalChatzos() -> Date? {
        return getHalfDayBasedZman(startOfHalfDay: getSunriseBasedOnElevationSetting(), endOfHalfDay: getFixedLocalChatzosHayom(), hours: 3)
    }

    /**
     * This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion of the
     * calculation of <em>sof zman tfila</em> (<em>zman tfilah</em> (the latest time to recite the morning prayers))
     * according to the opinion of the <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a> that the day is
     * calculated from sunrise to sunset, but calculated using the first half of the day only. The half a day starts at
     * ``getSunrise()`` and ends at fixed local chatzos. <em>Sof zman
     * tefila</em> is 4 <em>shaos zmaniyos</em> (solar hours) after sunrise or 2/3 of this half-day. If fixed local
     * <em>chatzos</em> is before sunrise or after sunset (on very short polar days), a `nil` will be returned.
     *
     * @return the `Date` of the latest <em>zman tfila</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getSunrise()
     * @see getFixedLocalChatzosHayom()
     * @see getHalfDayBasedZman(Instant, Instant, double)
     */
    public func getSofZmanTfilaGRASunriseToFixedLocalChatzos() -> Date? {
        return getHalfDayBasedZman(startOfHalfDay: getSunriseBasedOnElevationSetting(), endOfHalfDay: getFixedLocalChatzosHayom(), hours: 4)
    }

    /**
     * This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion of
     * the calculation of <em>mincha gedola</em>, the earliest time one can pray <em>mincha</em> according to the <a href=
     * "https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a> calculated as 30 minutes after fixed local chatzos. If fixed local <em>chatzos</em> is before sunrise or after sunset, or the calculated time is after sunset (on
     * very short polar days), a `nil` will be returned.
     *
     * @return the `Date` of the time of <em>mincha gedola</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getMinchaGedolaGRA()
     * @see getFixedLocalChatzosHayom()
     * @see getMinchaKetanaGRAFixedLocalChatzosToSunset
     */
    public func getMinchaGedolaGRAFixedLocalChatzos30Minutes() -> Date? {
        let minchaGedola30: Date? = AstronomicalCalendar.getTimeOffset(time: getFixedLocalChatzosHayom(), offset: 30 * 60.0)
        let sunset: Date? = getSunsetBasedOnElevationSetting()
        if minchaGedola30 != nil && sunset != nil && minchaGedola30!.isAfter(sunset!) { // very short polar day
            return nil
        }
        return minchaGedola30
    }

    /**
     * This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion
     * of the calculation of <em>mincha ketana</em> (the preferred time to recite the <em>mincha prayers</em> according to
     * the opinion of the <a href="https://en.wikipedia.org/wiki/Maimonides">Rambam</a> and others) calculated according
     * to the <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a> that is 3.5 <em>shaos zmaniyos</em> (solar
     * hours) after fixed local chatzos. If fixed local <em>chatzos</em> is before sunrise
     * or after sunset (on very short polar days), a `nil` will be returned.
     *
     * @return the `Date` of the time of <em>mincha ketana</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getMinchaGedolaGRA()
     * @see getFixedLocalChatzosHayom()
     * @see getMinchaGedolaGRAFixedLocalChatzos30Minutes
     * @see getHalfDayBasedZman(Instant, Instant, double)
     */
    public func getMinchaKetanaGRAFixedLocalChatzosToSunset() -> Date? {
        return getHalfDayBasedZman(startOfHalfDay: getFixedLocalChatzosHayom(), endOfHalfDay: getSunsetBasedOnElevationSetting(), hours: 3.5)
    }

    /**
     * This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion
     * of the calculation of <em>plag hamincha</em>. This method returns <em>plag hamincha</em> calculated according to the
     * <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a> that the day ends at sunset and is 4.75 <em>shaos
     * zmaniyos</em> (solar hours) after fixed local chatzos. If fixed local <em>chatzos</em>
     * is before sunrise or after sunset (on very short polar days), a `nil` will be returned.
     *
     * @return the `Date` of the time of <em>plag hamincha</em>. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year when the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getPlagHaminchaGRA()
     * @see getFixedLocalChatzosHayom()
     * @see getMinchaKetanaGRAFixedLocalChatzosToSunset
     * @see getMinchaGedolaGRAFixedLocalChatzos30Minutes
     * @see getHalfDayBasedZman(Instant, Instant, double)
     */
    public func getPlagHaminchaGRAFixedLocalChatzosToSunset() -> Date? {
        return getHalfDayBasedZman(startOfHalfDay: getFixedLocalChatzosHayom(), endOfHalfDay: getSunsetBasedOnElevationSetting(), hours: 4.75)
    }

    /**
     * Method to return <em>tzais</em> (dusk) calculated as 50 minutes after sunset or sea level sunset (depending on the ``isUseElevation()`` setting). This method returns
     * <em>tzais</em> (nightfall) based on the opinion of Rabbi Moshe Feinstein for the New York area. This time should
     * not be used for latitudes other than ones similar to the latitude of the NY area.
     *
     * @return the `Date` representing the time. If the calculation can't be computed such as in the Arctic Circle where
     *         there is at least one day a year when the sun does not rise, and one where it does not set, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getTzais50Minutes() -> Date? {
        return AstronomicalCalendar.getTimeOffset(time: getSunsetBasedOnElevationSetting(), offset: 50 * 60.0)
    }

    /**
     * A method for calculating <em>samuch lemincha ketana</em>, / near <em>mincha ketana</em> time that is half an hour before
     * ``getMinchaKetanaGRA()`` or is 9 * <em>shaos zmaniyos</em> (solar hours) after the start of
     * the day, calculated according to the <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a> using a day starting at
     * sunrise and ending at sunset. This is the time that eating or other activity can't begin prior to praying <em>mincha</em>.
     * The calculation used is 9 * ``getShaahZmanisGRA()`` after ``getSunrise()`` or elevation adjusted sunrise (depending on the ``isUseElevation()`` setting). See the
     * <a href="https://hebrewbooks.org/pdfpager.aspx?req=60387&st=&pgnum=294">Mechaber and Mishna Berurah 232</a> and <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=60388&pgnum=34">249:2</a>.
     *
     * @see getShaahZmanisGRA()
     * @see getSamuchLeMinchaKetana(Instant, Instant, boolean)
     * @see isUseAstronomicalChatzosForOtherZmanim()
     * @return the `Date` of the time of <em>samuch lemincha ketana</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getSamuchLeMinchaKetanaGRA() -> Date? {
        return getSamuchLeMinchaKetana(startOfDay: getSunriseBasedOnElevationSetting(), endOfDay: getSunsetBasedOnElevationSetting(), synchronous: true)
    }

    /**
     *
     * A method for calculating <em>samuch lemincha ketana</em>, / near <em>mincha ketana</em> time that is half an hour before
     * ``getMinchaKetanaGRA()`` or is 9 * <em>shaos zmaniyos</em> (solar hours) after the start of the day, calculated based
     * on a day from   and ending  a day starting at <em>alos</em> 16.1° and ending
     * at <em>tzais</em> 16.1°. This is the time that eating or other activity can't begin prior to
     * praying <em>mincha</em>.  The calculation used is 9 * ``getShaahZmanis16Point1Degrees()`` after <em>alos</em> 16.1°. See the <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=60387&st=&pgnum=294">Mechaber and Mishna Berurah 232</a> and <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=60388&pgnum=34">249:2</a>.
     *
     * @see getSamuchLeMinchaKetana(Instant, Instant, boolean)
     * @see getShaahZmanis16Point1Degrees()
     * @return the `Date` of the time of <em>samuch lemincha ketana</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a `nil` will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getSamuchLeMinchaKetana16Point1Degrees() -> Date? {
        return getSamuchLeMinchaKetana(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzais16Point1Degrees(), synchronous: true)
    }

    /**
     * A method for calculating <em>samuch lemincha ketana</em>, / near <em>mincha ketana</em> time that is half an hour before
     * ``getMinchaKetanaGRA()`` or is 9 * <em>shaos zmaniyos</em> (solar hours) after the start of the day, calculated based
     * on a day from   and ending  a day starting at <em>alos</em> 72 minutes and ending at <em>tzais</em> 72 minutes. This is the time that eating or other activity can't begin prior to praying
     * <em>mincha</em>. The calculation used is 9 * ``getShaahZmanis72Minutes()`` after <em>alos</em> 72 minutes. See the <a href="https://hebrewbooks.org/pdfpager.aspx?req=60387&st=&pgnum=294">Mechaber and Mishna Berurah
     * 232</a> and <a href="https://hebrewbooks.org/pdfpager.aspx?req=60388&pgnum=34">249:2</a>.
     *
     * @see getSamuchLeMinchaKetana(Instant, Instant, boolean)
     * @see getShaahZmanis72Minutes()
     * @return the `Date` of the time of <em>samuch lemincha ketana</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a `nil` will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getSamuchLeMinchaKetana72Minutes() -> Date? {
        return getSamuchLeMinchaKetana(startOfDay: getAlos72Minutes(), endOfDay: getTzais72Minutes(), synchronous: true)
    }

    /**
     * A method that returns sunset calculated as the time when the sun is directly due west (azimuth 270°) in <a href=
     * "https://en.wikipedia.org/wiki/Polar_regions_of_Earth">Polar regions</a> on days that there are no sunset. If there is sunset that day, a `nil` will be returned.
     * <p>In Polar regions (the <a href="https://en.wikipedia.org/wiki/Arctic">Arctic</a> or <a href=
     * "https://en.wikipedia.org/wiki/Antarctic">Antarctic</a> circles), there are days of no sunrise or sunset, and there are
     * <em>halachic</em> opinions that during these periods, sunset (the day-night boundary) is reached when the sun is directly due
     * west (azimuth 270°). Sunrise in this opinion is when the sun is directly due east (azimuth 90°) returned by ``getPolarSunriseBenIshChai()``. This is the opinion of <a href="https://en.wikipedia.org/wiki/Joseph_Schwarz_(geographer)">Rabbi Yehosef
     * Schwarz</a> in his <a href="https://hebrewbooks.org/pdfpager.aspx?req=31703&pgnum=134">דברי יוסף – דרך מבוא השמש</a> and <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=159&pgnum=83">דברי יוסף – תשובות, שאלה ח׳</a>. This is brought down <em>lehalacha</em>
     * by The <a href="https://en.wikipedia.org/wiki/Yosef_Hayyim">Ben Ish Chai</a> in the <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=1401&pgnum=461">רב פעלים – חלק ב׳, סוד ישרים ס׳ ד׳</a>. This time is close to six hours
     * after astronomical <em>chatzos hayom</em>, but depending on the time of year and location in the
     *  Arctic / Antarctic, it can be up to 46 minutes before or after this time.
     *
     * @return Sunset calculated as the time the sun is directly due west (azimuth 270°) in Polar regions on days that there is no
     *         sunset. If there is sunset that day, a `nil` will be returned. While unlikely, it is theoretically possible
     *         for a `nil` to be returned by the code even in Polar regions.
     * @see getPolarSunriseBenIshChai()
     * @see getTimeAtAzimuth90Or270(double)
     * @see com.kosherjava.zmanim.util.AstronomicalCalculator#getTimeAtAzimuth(LocalDate, GeoLocation, double)
     */
    public func getPolarSunsetBenIshChai() -> Date? {
        if getSunsetBasedOnElevationSetting() == nil {
            return getTimeAtAzimuth90Or270(azimuth: 270)
        }
        return nil
    }

    /**
     * A method that returns sunrise calculated as the time when the sun is directly due east (azimuth 90°) in <a href=
     * "https://en.wikipedia.org/wiki/Polar_regions_of_Earth">Polar regions</a> on days that there are no sunrise. If there is sunrise that day, a `nil` will be returned.
     * <p>In Polar regions (the <a href="https://en.wikipedia.org/wiki/Arctic">Arctic</a> or <a href=
     * "https://en.wikipedia.org/wiki/Antarctic">Antarctic</a> circles), there are days of no sunrise or sunset, and there are
     * <em>halachic</em> opinions that during these periods, sunrise is reached when the sun is directly due east (azimuth 90°).
     * The day-night boundary (sunset) in these opinions is when the sun is directly due west (azimuth 270°) returned by
     * ``getPolarSunsetBenIshChai()``. This is the opinion of <a href=
     * "https://en.wikipedia.org/wiki/Joseph_Schwarz_(geographer)">Rabbi Yehosef Schwarz</a> in his <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=31703&pgnum=134">דברי יוסף – דרך מבוא השמש</a> and <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=159&pgnum=83">דברי יוסף – תשובות, שאלה ח׳</a>. This is brought down <em>lehalacha</em>
     * by The <a href="https://en.wikipedia.org/wiki/Yosef_Hayyim">Ben Ish Chai</a> in the <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=1401&pgnum=461">רב פעלים – חלק ב׳, סוד ישרים ס׳ ד׳</a>. This time is close to six hours
     * before astronomical <em>chatzos hayom</em>, but depending on the time of year and location in the
     *  Arctic / Antarctic, it can be up to 46 minutes before or after this time.
     *  <p>All Polar zmanim can be calculated using the Ben Ish Chai's start and end of day using the following sample code.
     * ```
     * String locationName = "Thule, Greenland";
     * double latitude =  79.997;
     * double longitude = -69.258;
     * ZoneId zoneId = ZoneId.of("America/Thule");
     * GeoLocation location = new GeoLocation(locationName, latitude, longitude, 0, zoneId);
     * ComprehensiveZmanimCalendar czc = new ComprehensiveZmanimCalendar(location);
     * Instant sofZmanKriasShema = czc.getSofZmanShma(czc.getPolarSunriseBenIshChai(), czc.getPolarSunsetBenIshChai());
     * Instant sofZmanTefila = czc.getSofZmanTfila(czc.getPolarSunriseBenIshChai(), czc.getPolarSunsetBenIshChai());
     * Instant minchaGedola = czc.getMinchaGedola(czc.getPolarSunriseBenIshChai(), czc.getPolarSunsetBenIshChai());
     * ```
     * Dedicated methods for these zmanim may be added at a future point.
     * @return Sunrise calculated as the easternmost solar position (azimuth 90°) in Polar regions on days that there is no sunrise.
     *         If there is sunrise that day, a `nil` will be returned. While unlikely, it is theoretically possible for a
     *         `nil` to be returned by the code even in Polar regions.
     * @see getPolarSunsetBenIshChai()
     * @see getTimeAtAzimuth90Or270(double)
     * @see com.kosherjava.zmanim.util.AstronomicalCalculator#getTimeAtAzimuth(LocalDate, GeoLocation, double)
     */
    public func getPolarSunriseBenIshChai() -> Date? {
        if getSunriseBasedOnElevationSetting() == nil {
            return getTimeAtAzimuth90Or270(azimuth: 90)
        }
        return nil
    }

    /**
     * A method that returns <em>Plag Hamincha</em> in <a href="https://en.wikipedia.org/wiki/Polar_regions_of_Earth">Polar
     * regions</a> on days that there are no sunrise and sunset, calculated 10.75 <em>shaaos zmaniyos</em> of a day calculated starting at
     * ``getPolarSunriseBenIshChai()`` and ending at ``getPolarSunsetBenIshChai()``. This is the opinion of <a href=
     * "https://en.wikipedia.org/wiki/Joseph_Schwarz_(geographer)">Rabbi Yehosef Schwarz</a> in his <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=31703&pgnum=134">דברי יוסף – דרך מבוא השמש</a> and <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=159&pgnum=83">דברי יוסף – תשובות, שאלה ח׳</a>. This is brought down <em>lehalacha</em>
     * by The <a href="https://en.wikipedia.org/wiki/Yosef_Hayyim">Ben Ish Chai</a> in the <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=1401&pgnum=461">רב פעלים – חלק ב׳, סוד ישרים ס׳ ד׳</a>.
     *
     * @return <em>Plag Hamincha</em> according to the Ben Ish Chai in Polar regions on days that there is no sunrise or sunset.
     *         If there is sunrise or sunset that day, a `nil` will be returned.
     * @see getPolarSunriseBenIshChai()
     * @see getPolarSunsetBenIshChai()
     * @see getPlagHamincha(Instant, Instant, boolean)
     */
    public func getPolarPlagHaminchaBenIshChai() -> Date? {
        return getPlagHamincha(startOfDay: getPolarSunriseBenIshChai(), endOfDay: getPolarSunsetBenIshChai(), synchronous: true)
    }

    /**
     * In Polar regions during the period where the sun is above the horizon 24-hours a day, <a href=
     * "https://en.wikipedia.org/wiki/Moshe_Sternbuch">Rav Moshe Sternbuch</a> in <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=19963&st=&pgnum=316">מועדים וזמנים ח״ב ס׳ קנ״ה הע׳ א׳</a> (<span>ח״ד ס׳ ת״א
     * הע׳ א׳</span> in the new edition) and in תשובות והנהגות <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=20025&st=&pgnum=224">ח״א ס׳ שט״ו,</a> and <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=69067&st=&pgnum=135">ח״ה ס׳ פ״ד</a> ruled that during the Polar summer night-based
     * <em>mitzvos</em> are not applicable, and during the Polar winter, day-based mitzvos are not applicable. Despite this, the day
     * of the calendar week changes when the sun is at its lowest position (an instantaneous set and rise) at ``getChatzosHalayla()`` in the Polar summer and when it is at its highest position in the Polar winter that occurs at ``getChatzosHayom()``. Rabbi Dovid Heber the author of the <a href="https://hebrewbooks.org/53000">שערי זמנים</a> who <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=53000&st=&pgnum=111">discusses the Moadim Uzmanim's opinion</a> clarified to me
     * that in the Polar winter this really only applies when there is no <em>alos hashachar</em>. The lack of <em>alos
     * hashachar</em> only occurs in Antarctica and in uninhabited extreme northern regions. This means almost every northern
     * inhabited location has an <em>alos hashachar</em> and "day" even on December 21st. This method considers <em>alos</em> to be
     * ``getAlos16Point1Degrees()``.
     * <p> It should be noted that in the <span>מועדים וזמנים</span> linked above that was published in 1961, Rav Moshe
     * Sternbuch mentions that [<span>ולתפלה, היום מתהלק, עד י״ב שעות שחרית,  ומאז מנחה, ומעריב מתפלל סמוך ללילה כרבי יהודה כנל״ד ...</span>].
     * This comment (in () in the original, and [] in the new edition published in 2023) was not brought down in the
     * <span>תשובות והנהגות</span> vol. 1 that was published in 1977 nor in vol. 5. published in 2009. His grandson Rav Yonah Sternbuch
     * confirmed that it is not a retraction. The Moadim Uzmanim lists the end of Shacharis as 12 hours after the start of the day
     * (either ``getChatzosHalayla()``  in the Polar summer, or ``getChatzosHayom()`` in the Polar winter). At this point
     * the time for <em>mincha</em> starts. The time for <em>maariv</em> in this opinion starts at ``getPolarPlagHaminchaTeshuvosVehanhagos()`` and ends at the end of the Polar day (the value returned by this method). Regarding
     * the time for Krias Shema, the מועדים וזמנים states that <span>ורק אני מסתפק בענין ק״ש שתלוי בעצם בשכיבה וקימה ולא ביום ולילה, אולי יש דין ק״ש יום
     * ולילה גם במקומות אלו...</span>.
     * <p>FIXME:
     * <ul>
     *   <li>Research if an earlier alos such as 18° should be used.</li>
     *   <li>Consider logic for day with EITHER an <em>alos</em> or a sunset (the day of transit into 24-hour day/night.</li>
     * </ul>
     * @return the time of the Jewish calendar transition to the next day in Polar regions according to Rav Moshe Sternbuch.
     * @see getPolarPlagHaminchaTeshuvosVehanhagos()
     */
    public func getPolarStartOfDayTeshuvosVehanhagos() -> Date? {
        if getSunriseBasedOnElevationSetting() == nil && getSunsetBasedOnElevationSetting() == nil {
            guard let chatzosHayom = getChatzosHayom(), let chatzosHalayla = getChatzosHalayla() else {
                return nil // the calculator can't calculate astronomical chatzos
            }
            let chatzosHayomSolarElevation = getAstronomicalCalculator().getSolarElevation(date: chatzosHayom, geoLocation: getGeoLocation())
            let chatzosHalaylaSolarElevation = getAstronomicalCalculator().getSolarElevation(date: chatzosHalayla, geoLocation: getGeoLocation())
            let sunriseElevation = getAstronomicalCalculator().getSolarRadius() + getAstronomicalCalculator().getRefraction()
            if chatzosHayomSolarElevation < (0 - sunriseElevation) && chatzosHalaylaSolarElevation < (0 - sunriseElevation) && getAlos16Point1Degrees() == nil && getSunriseBasedOnElevationSetting() == nil { // Polar winter in either hemisphere no alos 16.1 or sunrise
                return chatzosHayom // the "sunrise" as the closest to the horizon
            } else if chatzosHayomSolarElevation > (0 - sunriseElevation) && chatzosHalaylaSolarElevation > (0 - sunriseElevation) { // Polar summer when both are above the horizon
                return chatzosHalayla
            }
        }
        return nil
    }

    /**
     * In Polar regions during the period where the sun is above the horizon 24-hours a day, <a href=
     * "https://en.wikipedia.org/wiki/Moshe_Sternbuch">Rav Moshe Sternbuch</a> in <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=19963&st=&pgnum=316">מועדים וזמנים ח״ב ס׳ קנ״ה הע׳ א׳</a> (<span>ח״ד ס׳ ת״א
     * הע׳ א׳</span> in the new edition) mentions the concept of zmanim based on his ``getPolarStartOfDayTeshuvosVehanhagos()``.
     * This calculates ``getPlagHamincha()`` as 10.75 <em>sha'os zmaniyos</em> starting 24 hours prior
     * to the current start/end of the current day. This will be very close to 2.5 clock hours before the start/end of the day.
     * @return <em>plag hamincha</em> as 2.5 hours prior to the start of the next day.
     *
     * @see getPolarStartOfDayTeshuvosVehanhagos() for more details on this opinion.
     * @see getPlagHamincha(Instant, Instant, boolean)
     */
    public func getPolarPlagHaminchaTeshuvosVehanhagos() -> Date? {
        let polarStartOfDay: Date? = getPolarStartOfDayTeshuvosVehanhagos()
        if polarStartOfDay == nil {
            return nil
        } else {
            let yesterday: Date? = polarStartOfDay!.addingTimeInterval(-86400)
            return getPlagHamincha(startOfDay: yesterday, endOfDay: polarStartOfDay, synchronous: true)
        }

    }

    /// True if the other calendar is the same class with the same date, location, calculator and settings.
    public override func equals(_ other: AstronomicalCalendar) -> Bool {
        guard super.equals(other), let that = other as? ComprehensiveZmanimCalendar else {
            return false
        }
        return ateretTorahSunsetOffset == that.ateretTorahSunsetOffset
    }

    override func copyState(to copy: AstronomicalCalendar) {
        super.copyState(to: copy)
        if let copy = copy as? ComprehensiveZmanimCalendar {
            copy.ateretTorahSunsetOffset = ateretTorahSunsetOffset
        }
    }

    override func getFormattableValues() -> [(String, ZmanimFormatter.Value)] {
        return super.getFormattableValues() + [
            ("getAlos120Minutes", .date(getAlos120Minutes())),
            ("getAlos120Zmanis", .date(getAlos120Zmanis())),
            ("getAlos18Degrees", .date(getAlos18Degrees())),
            ("getAlos19Degrees", .date(getAlos19Degrees())),
            ("getAlos19Point8Degrees", .date(getAlos19Point8Degrees())),
            ("getAlos26Degrees", .date(getAlos26Degrees())),
            ("getAlos60Minutes", .date(getAlos60Minutes())),
            ("getAlos72Zmanis", .date(getAlos72Zmanis())),
            ("getAlos90Minutes", .date(getAlos90Minutes())),
            ("getAlos90Zmanis", .date(getAlos90Zmanis())),
            ("getAlos96Minutes", .date(getAlos96Minutes())),
            ("getAlos96Zmanis", .date(getAlos96Zmanis())),
            ("getAlosBaalHatanya", .date(getAlosBaalHatanya())),
            ("getBainHashmashosRT13Point24Degrees", .date(getBainHashmashosRT13Point24Degrees())),
            ("getBainHashmashosRT13Point5MinutesBefore7Point083Degrees", .date(getBainHashmashosRT13Point5MinutesBefore7Point083Degrees())),
            ("getBainHashmashosRT2Stars", .date(getBainHashmashosRT2Stars())),
            ("getBainHashmashosRT58Point5Minutes", .date(getBainHashmashosRT58Point5Minutes())),
            ("getBainHashmashosYereim13Point5Minutes", .date(getBainHashmashosYereim13Point5Minutes())),
            ("getBainHashmashosYereim16Point875Minutes", .date(getBainHashmashosYereim16Point875Minutes())),
            ("getBainHashmashosYereim18Minutes", .date(getBainHashmashosYereim18Minutes())),
            ("getBainHashmashosYereim2Point1Degrees", .date(getBainHashmashosYereim2Point1Degrees())),
            ("getBainHashmashosYereim2Point8Degrees", .date(getBainHashmashosYereim2Point8Degrees())),
            ("getBainHashmashosYereim3Point05Degrees", .date(getBainHashmashosYereim3Point05Degrees())),
            ("getFixedLocalChatzosHayom", .date(getFixedLocalChatzosHayom())),
            ("getMinchaGedola16Point1Degrees", .date(getMinchaGedola16Point1Degrees())),
            ("getMinchaGedola30Minutes", .date(getMinchaGedola30Minutes())),
            ("getMinchaGedola72Minutes", .date(getMinchaGedola72Minutes())),
            ("getMinchaGedolaAhavatShalom", .date(getMinchaGedolaAhavatShalom())),
            ("getMinchaGedolaAteretTorah", .date(getMinchaGedolaAteretTorah())),
            ("getMinchaGedolaBaalHatanya", .date(getMinchaGedolaBaalHatanya())),
            ("getMinchaGedolaGRAFixedLocalChatzos30Minutes", .date(getMinchaGedolaGRAFixedLocalChatzos30Minutes())),
            ("getMinchaGedolaGRAGreaterThan30", .date(getMinchaGedolaGRAGreaterThan30())),
            ("getMinchaKetana16Point1Degrees", .date(getMinchaKetana16Point1Degrees())),
            ("getMinchaKetana72Minutes", .date(getMinchaKetana72Minutes())),
            ("getMinchaKetanaAhavatShalom", .date(getMinchaKetanaAhavatShalom())),
            ("getMinchaKetanaAteretTorah", .date(getMinchaKetanaAteretTorah())),
            ("getMinchaKetanaBaalHatanya", .date(getMinchaKetanaBaalHatanya())),
            ("getMinchaKetanaGRAFixedLocalChatzosToSunset", .date(getMinchaKetanaGRAFixedLocalChatzosToSunset())),
            ("getMisheyakir10Point2Degrees", .date(getMisheyakir10Point2Degrees())),
            ("getMisheyakir11Degrees", .date(getMisheyakir11Degrees())),
            ("getMisheyakir11Point5Degrees", .date(getMisheyakir11Point5Degrees())),
            ("getMisheyakir12Point85Degrees", .date(getMisheyakir12Point85Degrees())),
            ("getMisheyakir7Point65Degrees", .date(getMisheyakir7Point65Degrees())),
            ("getMisheyakir9Point5Degrees", .date(getMisheyakir9Point5Degrees())),
            ("getPlagAhavatShalom", .date(getPlagAhavatShalom())),
            ("getPlagAlos16Point1DegreesToTzaisGeonim7Point083Degrees", .date(getPlagAlos16Point1DegreesToTzaisGeonim7Point083Degrees())),
            ("getPlagAlosToSunset", .date(getPlagAlosToSunset())),
            ("getPlagHamincha120Minutes", .date(getPlagHamincha120Minutes())),
            ("getPlagHamincha120MinutesZmanis", .date(getPlagHamincha120MinutesZmanis())),
            ("getPlagHamincha16Point1Degrees", .date(getPlagHamincha16Point1Degrees())),
            ("getPlagHamincha18Degrees", .date(getPlagHamincha18Degrees())),
            ("getPlagHamincha19Point8Degrees", .date(getPlagHamincha19Point8Degrees())),
            ("getPlagHamincha26Degrees", .date(getPlagHamincha26Degrees())),
            ("getPlagHamincha60Minutes", .date(getPlagHamincha60Minutes())),
            ("getPlagHamincha72Minutes", .date(getPlagHamincha72Minutes())),
            ("getPlagHamincha72MinutesZmanis", .date(getPlagHamincha72MinutesZmanis())),
            ("getPlagHamincha90Minutes", .date(getPlagHamincha90Minutes())),
            ("getPlagHamincha90MinutesZmanis", .date(getPlagHamincha90MinutesZmanis())),
            ("getPlagHamincha96Minutes", .date(getPlagHamincha96Minutes())),
            ("getPlagHamincha96MinutesZmanis", .date(getPlagHamincha96MinutesZmanis())),
            ("getPlagHaminchaAteretTorah", .date(getPlagHaminchaAteretTorah())),
            ("getPlagHaminchaBaalHatanya", .date(getPlagHaminchaBaalHatanya())),
            ("getPlagHaminchaGRAFixedLocalChatzosToSunset", .date(getPlagHaminchaGRAFixedLocalChatzosToSunset())),
            ("getPolarPlagHaminchaBenIshChai", .date(getPolarPlagHaminchaBenIshChai())),
            ("getPolarPlagHaminchaTeshuvosVehanhagos", .date(getPolarPlagHaminchaTeshuvosVehanhagos())),
            ("getPolarStartOfDayTeshuvosVehanhagos", .date(getPolarStartOfDayTeshuvosVehanhagos())),
            ("getPolarSunriseBenIshChai", .date(getPolarSunriseBenIshChai())),
            ("getPolarSunsetBenIshChai", .date(getPolarSunsetBenIshChai())),
            ("getSamuchLeMinchaKetana16Point1Degrees", .date(getSamuchLeMinchaKetana16Point1Degrees())),
            ("getSamuchLeMinchaKetana72Minutes", .date(getSamuchLeMinchaKetana72Minutes())),
            ("getSamuchLeMinchaKetanaGRA", .date(getSamuchLeMinchaKetanaGRA())),
            ("getShaahZmanis120Minutes", .duration(getShaahZmanis120Minutes())),
            ("getShaahZmanis120MinutesZmanis", .duration(getShaahZmanis120MinutesZmanis())),
            ("getShaahZmanis16Point1Degrees", .duration(getShaahZmanis16Point1Degrees())),
            ("getShaahZmanis18Degrees", .duration(getShaahZmanis18Degrees())),
            ("getShaahZmanis19Point8Degrees", .duration(getShaahZmanis19Point8Degrees())),
            ("getShaahZmanis26Degrees", .duration(getShaahZmanis26Degrees())),
            ("getShaahZmanis60Minutes", .duration(getShaahZmanis60Minutes())),
            ("getShaahZmanis72MinutesZmanis", .duration(getShaahZmanis72MinutesZmanis())),
            ("getShaahZmanis90Minutes", .duration(getShaahZmanis90Minutes())),
            ("getShaahZmanis90MinutesZmanis", .duration(getShaahZmanis90MinutesZmanis())),
            ("getShaahZmanis96Minutes", .duration(getShaahZmanis96Minutes())),
            ("getShaahZmanis96MinutesZmanis", .duration(getShaahZmanis96MinutesZmanis())),
            ("getShaahZmanisAlos16Point1DegreesToTzaisGeonim3Point7Degrees", .duration(getShaahZmanisAlos16Point1DegreesToTzaisGeonim3Point7Degrees())),
            ("getShaahZmanisAlos16Point1DegreesToTzaisGeonim3Point8Degrees", .duration(getShaahZmanisAlos16Point1DegreesToTzaisGeonim3Point8Degrees())),
            ("getShaahZmanisAlos16Point1DegreesToTzaisGeonim7Point083Degrees", .duration(getShaahZmanisAlos16Point1DegreesToTzaisGeonim7Point083Degrees())),
            ("getShaahZmanisAteretTorah", .duration(getShaahZmanisAteretTorah())),
            ("getShaahZmanisBaalHatanya", .duration(getShaahZmanisBaalHatanya())),
            ("getSofZmanAchilasChametzBaalHatanya", .date(getSofZmanAchilasChametzBaalHatanya())),
            ("getSofZmanAchilasChametzGRA", .date(getSofZmanAchilasChametzGRA())),
            ("getSofZmanAchilasChametzMGA16Point1Degrees", .date(getSofZmanAchilasChametzMGA16Point1Degrees())),
            ("getSofZmanAchilasChametzMGA72Minutes", .date(getSofZmanAchilasChametzMGA72Minutes())),
            ("getSofZmanAchilasChametzMGA72MinutesZmanis", .date(getSofZmanAchilasChametzMGA72MinutesZmanis())),
            ("getSofZmanBiurChametzBaalHatanya", .date(getSofZmanBiurChametzBaalHatanya())),
            ("getSofZmanBiurChametzGRA", .date(getSofZmanBiurChametzGRA())),
            ("getSofZmanBiurChametzMGA16Point1Degrees", .date(getSofZmanBiurChametzMGA16Point1Degrees())),
            ("getSofZmanBiurChametzMGA72Minutes", .date(getSofZmanBiurChametzMGA72Minutes())),
            ("getSofZmanBiurChametzMGA72MinutesZmanis", .date(getSofZmanBiurChametzMGA72MinutesZmanis())),
            ("getSofZmanKidushLevana15Days", .date(getSofZmanKidushLevana15Days())),
            ("getSofZmanKidushLevanaBetweenMoldos", .date(getSofZmanKidushLevanaBetweenMoldos())),
            ("getSofZmanShma3HoursBeforeChatzos", .date(getSofZmanShma3HoursBeforeChatzos())),
            ("getSofZmanShmaAlos16Point1DegreesToTzaisGeonim7Point083Degrees", .date(getSofZmanShmaAlos16Point1DegreesToTzaisGeonim7Point083Degrees())),
            ("getSofZmanShmaAlos16Point1ToSunset", .date(getSofZmanShmaAlos16Point1ToSunset())),
            ("getSofZmanShmaAteretTorah", .date(getSofZmanShmaAteretTorah())),
            ("getSofZmanShmaBaalHatanya", .date(getSofZmanShmaBaalHatanya())),
            ("getSofZmanShmaGRASunriseToFixedLocalChatzos", .date(getSofZmanShmaGRASunriseToFixedLocalChatzos())),
            ("getSofZmanShmaMGA120Minutes", .date(getSofZmanShmaMGA120Minutes())),
            ("getSofZmanShmaMGA16Point1Degrees", .date(getSofZmanShmaMGA16Point1Degrees())),
            ("getSofZmanShmaMGA16Point1DegreesToFixedLocalChatzos", .date(getSofZmanShmaMGA16Point1DegreesToFixedLocalChatzos())),
            ("getSofZmanShmaMGA18Degrees", .date(getSofZmanShmaMGA18Degrees())),
            ("getSofZmanShmaMGA18DegreesToFixedLocalChatzos", .date(getSofZmanShmaMGA18DegreesToFixedLocalChatzos())),
            ("getSofZmanShmaMGA19Point8Degrees", .date(getSofZmanShmaMGA19Point8Degrees())),
            ("getSofZmanShmaMGA72MinutesToFixedLocalChatzos", .date(getSofZmanShmaMGA72MinutesToFixedLocalChatzos())),
            ("getSofZmanShmaMGA72MinutesZmanis", .date(getSofZmanShmaMGA72MinutesZmanis())),
            ("getSofZmanShmaMGA90Minutes", .date(getSofZmanShmaMGA90Minutes())),
            ("getSofZmanShmaMGA90MinutesToFixedLocalChatzos", .date(getSofZmanShmaMGA90MinutesToFixedLocalChatzos())),
            ("getSofZmanShmaMGA90MinutesZmanis", .date(getSofZmanShmaMGA90MinutesZmanis())),
            ("getSofZmanShmaMGA96Minutes", .date(getSofZmanShmaMGA96Minutes())),
            ("getSofZmanShmaMGA96MinutesZmanis", .date(getSofZmanShmaMGA96MinutesZmanis())),
            ("getSofZmanTfila2HoursBeforeChatzos", .date(getSofZmanTfila2HoursBeforeChatzos())),
            ("getSofZmanTfilaAteretTorah", .date(getSofZmanTfilaAteretTorah())),
            ("getSofZmanTfilaBaalHatanya", .date(getSofZmanTfilaBaalHatanya())),
            ("getSofZmanTfilaGRASunriseToFixedLocalChatzos", .date(getSofZmanTfilaGRASunriseToFixedLocalChatzos())),
            ("getSofZmanTfilaMGA120Minutes", .date(getSofZmanTfilaMGA120Minutes())),
            ("getSofZmanTfilaMGA16Point1Degrees", .date(getSofZmanTfilaMGA16Point1Degrees())),
            ("getSofZmanTfilaMGA18Degrees", .date(getSofZmanTfilaMGA18Degrees())),
            ("getSofZmanTfilaMGA19Point8Degrees", .date(getSofZmanTfilaMGA19Point8Degrees())),
            ("getSofZmanTfilaMGA72MinutesZmanis", .date(getSofZmanTfilaMGA72MinutesZmanis())),
            ("getSofZmanTfilaMGA90Minutes", .date(getSofZmanTfilaMGA90Minutes())),
            ("getSofZmanTfilaMGA90MinutesZmanis", .date(getSofZmanTfilaMGA90MinutesZmanis())),
            ("getSofZmanTfilaMGA96Minutes", .date(getSofZmanTfilaMGA96Minutes())),
            ("getSofZmanTfilaMGA96MinutesZmanis", .date(getSofZmanTfilaMGA96MinutesZmanis())),
            ("getTchilasZmanKidushLevana3Days", .date(getTchilasZmanKidushLevana3Days())),
            ("getTchilasZmanKidushLevana7Days", .date(getTchilasZmanKidushLevana7Days())),
            ("getTzais120Minutes", .date(getTzais120Minutes())),
            ("getTzais120Zmanis", .date(getTzais120Zmanis())),
            ("getTzais16Point1Degrees", .date(getTzais16Point1Degrees())),
            ("getTzais18Degrees", .date(getTzais18Degrees())),
            ("getTzais19Point8Degrees", .date(getTzais19Point8Degrees())),
            ("getTzais26Degrees", .date(getTzais26Degrees())),
            ("getTzais50Minutes", .date(getTzais50Minutes())),
            ("getTzais60Minutes", .date(getTzais60Minutes())),
            ("getTzais72Zmanis", .date(getTzais72Zmanis())),
            ("getTzais90Minutes", .date(getTzais90Minutes())),
            ("getTzais90Zmanis", .date(getTzais90Zmanis())),
            ("getTzais96Minutes", .date(getTzais96Minutes())),
            ("getTzais96Zmanis", .date(getTzais96Zmanis())),
            ("getTzaisAteretTorah", .date(getTzaisAteretTorah())),
            ("getTzaisBaalHatanya", .date(getTzaisBaalHatanya())),
            ("getTzaisGeonim3Point7Degrees", .date(getTzaisGeonim3Point7Degrees())),
            ("getTzaisGeonim3Point8Degrees", .date(getTzaisGeonim3Point8Degrees())),
            ("getTzaisGeonim4Point42Degrees", .date(getTzaisGeonim4Point42Degrees())),
            ("getTzaisGeonim4Point66Degrees", .date(getTzaisGeonim4Point66Degrees())),
            ("getTzaisGeonim4Point8Degrees", .date(getTzaisGeonim4Point8Degrees())),
            ("getTzaisGeonim5Point95Degrees", .date(getTzaisGeonim5Point95Degrees())),
            ("getTzaisGeonim6Point45Degrees", .date(getTzaisGeonim6Point45Degrees())),
            ("getTzaisGeonim7Point083Degrees", .date(getTzaisGeonim7Point083Degrees())),
            ("getTzaisGeonim7Point67Degrees", .date(getTzaisGeonim7Point67Degrees())),
            ("getTzaisGeonim9Point3Degrees", .date(getTzaisGeonim9Point3Degrees())),
            ("getTzaisGeonim9Point75Degrees", .date(getTzaisGeonim9Point75Degrees())),
            ("getZmanMolad", .date(getZmanMolad())),
        ]
    }

    // MARK: - KosherSwift additions that are not in KosherJava


    /**
     * This method returns <em>misheyakir</em> as 6 zmaniyot minutes after ``getAlos72Zmanis()``. This is how Rabbi Ovadiah
     * Yosef calculates this zman as implemented in the Ohr Hachaim calendar.
     *
     * @return the `Date` of <em>misheyakir</em>. If the calculation can't be computed such as in the Arctic Circle where
     *         there is at least one day a year where the sun does not rise, and one where it does not set, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
      */
    public func getMisheyakir66MinutesZmanis() -> Date? {
        guard let shaahZmanit = getShaahZmanisGRA() else { return nil } // incalculable (e.g. no sunrise in the Arctic)
        return AstronomicalCalendar.getTimeOffset(time: getAlos72Zmanis(), offset: 6 * (shaahZmanit / 60))
    }

    /**
     * This method returns <em>misheyakir</em> as 12 zmaniyot minutes after ``getAlos72Zmanis()``.
     *
     * @return the `Date` of <em>misheyakir</em>. If the calculation can't be computed such as in the Arctic Circle where
     *         there is at least one day a year where the sun does not rise, and one where it does not set, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
      */
    public func getMisheyakir60MinutesZmanis() -> Date? {
        guard let shaahZmanit = getShaahZmanisGRA() else { return nil } // incalculable (e.g. no sunrise in the Arctic)
        return AstronomicalCalendar.getTimeOffset(time: getAlos72Zmanis(), offset: 12 * (shaahZmanit / 60))
    }

    /**
     * Method to return a <em>shaah zmanis</em> (solar hour) according to the opinion of the <a href=
     * "https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a>, with the day starting at
     * ``getAlos72Zmanis()`` (72 zmaniyos minutes before sunrise) and ending at ``getTzais72Zmanis()`` (72 zmaniyos minutes
     * after sunset). This is the same as ``getShaahZmanis72MinutesZmanis()``.
     *
     * @return the length of a <em>shaah zmanis</em> in seconds. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year where the sun does not rise, and one where it does not set, a
     *         `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
      */
    public func getShaahZmanisMGAZmanis() -> TimeInterval? {
        return getTemporalHour(startOfDay: getAlos72Zmanis(), endOfDay: getTzais72Zmanis())
    }

    /**
     * Method to return <em>tzais</em> (dusk) calculated as 13.5 minutes zmaniyos after sunset.
     * - Warning: This zman is EXTREMELY early! It is so early that it was removed from KosherJava since it caused a
     *   situation that the developer, Eliyahu Hershfeld, was uncomfortable with. The situation was in Canada where a user
     *   using his phone saw that this time was listed as the time for nightfall, and he figured that he could end shabbos
     *   then. While there are no poskim that write to do that! The earliest time that I have found to end shabbos is 20
     *   regular minutes after sunset and that is only in Israel and the surrounding areas. Every where else was
     *   recommended 30 minutes at the bare minimum. Therefore, someone who wants to use/include this time has an
     *   obligation to make sure that it does not get used for shabbos by dimming it or showing another time.
     * @return the `Date` representing the time. If the calculation can't be computed such as in the Arctic Circle where
     *         there is at least one day a year where the sun does not rise, and one where it does not set, a `nil` will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos72Zmanis()
      */
    public func getTzais13Point5MinutesZmanis() -> Date? {
        guard let shaahZmanit = getShaahZmanisGRA() else { return nil } // incalculable (e.g. no sunrise in the Arctic)
        return AstronomicalCalendar.getTimeOffset(time: getSunsetBasedOnElevationSetting(), offset: 13.5 * (shaahZmanit / 60))
    }

    /**
     * This method returns <em>tzais</em> calculated as however many minutes you pass in the parameter after sunset.
     * @param minutes the amount of minutes tzais is after sunset
     * @return the `Date` representing however many minutes after sunset. If the calculation can't be computed such as in
     *         the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
     *         not set, a `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
      */
    public func getTzaisAteretTorah(minutes: Double) -> Date? {
        return AstronomicalCalendar.getTimeOffset(time: getSunsetBasedOnElevationSetting(), offset: minutes * 60)
    }

    // MARK: - Helper methods. These methods are not included in KosherJava, however, I added them because of convenience
    
    /**
     * This method returns the time of <em>plag hamincha</em> according to the Yalkut Yosef. This is calculated as -1.25 GRA hours before
     * ``getTzais13Point5MinutesZmanis()``.
     *
     * @return the `Date` of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     *
      */
    public func getPlagHaminchaYalkutYosef() -> Date? {
        guard let shaahZmanit = getShaahZmanisGRA() else { return nil } // incalculable (e.g. no sunrise in the Arctic)
        let dakahZmanit = shaahZmanit / 60
        return AstronomicalCalendar.getTimeOffset(time: getTzais13Point5MinutesZmanis(), offset: -(shaahZmanit + (15 * dakahZmanit)))
    }
    
    /**
     * The Yalkut Yosef holds that the time for Plag Hamincha is calculated by taking 1.25 "seasonal hours" (Sha'ot Zmaniot) from tzait hacochavim.
     * This is how Rabbi Leeor Dahan calculates Plag Hamincha in his Amudei Horaah calendar, adjusting for the distance from the equator for tzait hacochavim.
     * @return the time for Plag Hamincha as calculated by the Amudei Horaah calendar according to the Yalkut Yosef.
      */
    public func getPlagHaminchaYalkutYosefAmudeiHoraah() -> Date? {
        guard let shaahZmanit = getTemporalHour(startOfDay: getSunriseBasedOnElevationSetting(), endOfDay: getSunsetBasedOnElevationSetting()) else {
            return nil // incalculable (e.g. no sunrise in the Arctic)
        }
        let dakahZmanit = shaahZmanit / 60
        return AstronomicalCalendar.getTimeOffset(time: getTzaisAmudeiHoraah(), offset: -(shaahZmanit + (15 * dakahZmanit)))
    }
    
    /**
     * This method returns the time of alot hashachar (dawn) calculated by the Amudei Horaah calendar. While normally this is calculated as 72 zmaniyot
     * minutes before sunrise, Rabbi Leeor Dahan says that the zmanim need to be adjusted for more northern/southern locations. He calculates the time as
     * zmaniyot minutes/seconds, however, he adjusts it based on the location's distance from the equator at 16.04 degrees (72 zmaniyot minutes in Israel).
     * <p>
     * For example: If you wanted to calculate when alot is for NY, USA, you would first calculate the amount of regular minutes there are in an equinox
     * day between sunrise and 16.04 degrees before sunrise. In NY, this would lead you to around 80 minutes. You would then minus 80 zmaniyot minutes to
     * the time of sunrise to get the time of alot.
     * <p>
     * This is how Rabbi Leeor Dahan calculates the zmanim for alot and tzait in the Amudei Horaah calendar.
     *
     * @return the time of alot hashachar (dawn) calculated by the Amudei Horaah calendar by adjusting the zman based off of degrees. This zman
     * should NOT be used in Israel.
      */
    public func getAlosAmudeiHoraah() -> Date? {
        return getAmudeiHoraahBeforeSunrise(degrees: 16.04, fraction: 1)
    }

    /**
     * This method returns the time of misheyakir l'kulah calculated by the Amudei Horaah calendar.
     * Rabbi Leeor Dahan calculates this zman for as 11/12th of the time between alot and sunrise, which is 66 zmaniyot minutes.
     * - Warning: This is an extremely early zman! It should only be used by workers that need to run to work or similar circumstances. Ideally, do not show this zman without providing another,
     * @return the time of misheyakir calculated by the Amudei Horaah calendar by adjusting the zman based off of degrees.
      */
    public func getMisheyakir66AmudeiHoraah() -> Date? {
        return getAmudeiHoraahBeforeSunrise(degrees: 16.04, fraction: 11.0 / 12.0) // 66 / 72
    }

    /**
     * This method returns the time of misheyakir calculated by the Amudei Horaah calendar.
     * Rabbi Leeor Dahan calculates this zman for as 5/6 of the time between alot and sunrise in the Amudei Horaah calendar, which is 60 zmaniyot minutes.
     * @return the time of misheyakir calculated by the Amudei Horaah calendar by adjusting the zman based off of degrees.
      */
    public func getMisheyakir60AmudeiHoraah() -> Date? {
        return getAmudeiHoraahBeforeSunrise(degrees: 16.04, fraction: 5.0 / 6.0) // 60 / 72
    }
    
    public func getSofZmanShmaMGA72MinutesZmanisAmudeiHoraah() -> Date? {
        return getSofZmanShma(startOfDay: getAlosAmudeiHoraah(), endOfDay: getTzais72ZmanisAmudeiHoraah())
    }

    public func getSofZmanAchilatChametzAmudeiHoraah() -> Date? {
        return getSofZmanTfila(startOfDay: getAlosAmudeiHoraah(), endOfDay: getTzais72ZmanisAmudeiHoraah())
    }

    public func getSofZmanBiurChametzMGAAmudeiHoraah() -> Date? {
        let alos = getAlosAmudeiHoraah()
        guard let shaahZmanit = getTemporalHour(startOfDay: alos, endOfDay: getTzais72ZmanisAmudeiHoraah()) else {
            return nil // incalculable (e.g. no sunrise in the Arctic)
        }
        return AstronomicalCalendar.getTimeOffset(time: alos, offset: shaahZmanit * 5)
    }
    
    /**
     * This method calculates the time for Nightfall according to the opinion of the Amudei Horaah Calendar. This is calculated as 13.5 adjusted zmaniyot minutes after sunset. This zman is calculated based on 3.7&deg which is the where the sun is after sunset at 13.5 minutes in Israel on the equinox. Based on that degree, the 13.5 zmaniyot minutes are adjusted from the distance of the equator.
     * @return the Date representing 13.5 minutes zmaniyot after sunset adjusted to the users location based on the equator using degrees based in Israel.
      */
    public func getTzaisAmudeiHoraah() -> Date? {
        return getAmudeiHoraahAfterSunset(degrees: 3.7)
    }

    /**
     * This method calculates the more stringent (l'chumra) time for Nightfall according to the Amudei Horaah Calendar. This is calculated as 20 adjusted zmaniyot minutes after sunset, based on 5.075&deg which is where the sun is 20 minutes after sunset in Israel on the equinox. Like ``getTzaisAmudeiHoraah()``, the zmaniyot minutes are then adjusted for the distance from the equator.
     * @return the Date representing 20 minutes zmaniyot after sunset adjusted to the users location based on the equator using degrees based in Israel.
      */
    public func getTzaisAmudeiHoraahLChumra() -> Date? {
        return getAmudeiHoraahAfterSunset(degrees: 5.075)
    }

    /**
     * This method calculates 72 zmaniyot minutes after sunset according to the Amudei Horaah Calendar. Based on 16.04&deg which is where the sun is 72 zmaniyot minutes after sunset in Israel on the equinox, the 72 zmaniyot minutes are adjusted for the distance from the equator. This is the nightfall counterpart of ``getAlosAmudeiHoraah()``.
     * @return the Date representing 72 zmaniyot minutes after sunset adjusted to the users location based on the equator using degrees based in Israel.
      */
    public func getTzais72ZmanisAmudeiHoraah() -> Date? {
        return getAmudeiHoraahAfterSunset(degrees: 16.04)
    }
    
    public func getTzaisShabbosAmudeiHoraah() -> Date? {
        let tzait = getSunsetOffsetByDegrees(offsetZenith: AstronomicalCalendar.GEOMETRIC_ZENITH + 7.165)
        if let tzait = tzait, let twentyMinutes = getTzaisAteretTorah(minutes: 20) {
            if twentyMinutes > tzait { // if shabbat ends before 20 minutes after sunset, use 20 minutes
                return twentyMinutes
            }
            if let solarMidnight = getSolarMidnight(), solarMidnight < tzait { // if chatzot is before when shabbat ends, just use chatzot
                return solarMidnight
            }
        }
        return tzait
    }
    
    /// The earlier of ``getTzaisAteretTorah()`` or ``getTzaisShabbosAmudeiHoraah()``. For display only, not for calculating zmanim.
    public func getTzaisShabbosAmudeiHoraahLesserThan40() -> Date? {
        guard let ateretTorah = getTzaisAteretTorah(), let amudeiHoraah = getTzaisShabbosAmudeiHoraah() else { return nil }
        return min(ateretTorah, amudeiHoraah)
    }

    /// The earlier of ``getTzais72Minutes()`` or ``getTzais72ZmanisAmudeiHoraah()``. For display only, not for calculating zmanim.
    public func getTzais72ZmanisAmudeiHoraahLkulah() -> Date? {
        guard let regular = getTzais72Minutes(), let amudeiHoraah = getTzais72ZmanisAmudeiHoraah() else { return nil }
        return min(regular, amudeiHoraah)
    }
    
    /**
     Calculates how long the sun takes to reach the given degrees below the horizon on the equinox (March 17), as a
     percentage of a shaah zmanis. Rabbi Leeor Dahan's Amudei Horaah calendar takes the number of zmaniyot minutes this
     is in Israel (e.g. 16.04° is 72 zmaniyot minutes) and applies the same percentage everywhere else.
     - Returns: the percentage, or nil if it can't be calculated.
      */
    public func getEquinoxPercentOfShaahZmanis(degrees: Double, sunset: Bool) -> Double? {
        // a separate calendar on the equinox, so this calendar's date is never touched
        let equinoxCalendar = ComprehensiveZmanimCalendar(geoLocation: geoLocation.copy())
        equinoxCalendar.astronomicalCalculator = astronomicalCalculator
        equinoxCalendar.setLocalDate(localDate: LocalDate(year: getLocalDate().year, month: 3, day: 17))
        let percentage = equinoxCalendar.getPercentOfShaahZmanisFromDegrees(degrees: degrees, sunset: sunset)
        return percentage == Double.leastNonzeroMagnitude ? nil : percentage
    }

    /// `fraction` scales the offset, e.g. 11/12 for 66 zmaniyot minutes out of 72.
    public func getAmudeiHoraahBeforeSunrise(degrees: Double, fraction: Double) -> Date? {
        guard let percentage = getEquinoxPercentOfShaahZmanis(degrees: degrees, sunset: false) else { return nil }
        let sunrise = getSunriseBasedOnElevationSetting()
        guard let shaahZmanit = getTemporalHour(startOfDay: sunrise, endOfDay: getSunsetBasedOnElevationSetting()) else {
            return nil // incalculable (e.g. no sunrise in the Arctic)
        }
        return AstronomicalCalendar.getTimeOffset(time: sunrise, offset: -(percentage * shaahZmanit * fraction))
    }

    public func getAmudeiHoraahAfterSunset(degrees: Double) -> Date? {
        guard let percentage = getEquinoxPercentOfShaahZmanis(degrees: degrees, sunset: true) else { return nil }
        let sunset = getSunsetBasedOnElevationSetting()
        guard let shaahZmanit = getTemporalHour(startOfDay: getSunriseBasedOnElevationSetting(), endOfDay: sunset) else {
            return nil // incalculable (e.g. no sunrise in the Arctic)
        }
        return AstronomicalCalendar.getTimeOffset(time: sunset, offset: percentage * shaahZmanit)
    }
}
