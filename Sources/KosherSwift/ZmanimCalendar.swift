//
//  ZmanimCalendar.swift
//  KosherSwift
//
//  Created by Elyahu Jacobi on 12/21/23.
//

import Foundation

/**
 * The ZmanimCalendar is a specialized calendar that can calculate sunrise, sunset and Jewish <em>zmanim</em> (religious times)
 * for prayers and other Jewish religious duties. This class contains the main functionality of the <em>Zmanim</em> library. For
 * a much more extensive list of <em>zmanim</em>, use the ``ComprehensiveZmanimCalendar`` that extends this class. See
 * documentation for the ``ComprehensiveZmanimCalendar`` and ``AstronomicalCalendar`` for simple examples on using the API.
 * <strong>Elevation based <em>zmanim</em> (even sunrise and sunset) should not be used <em>lekula</em> without the guidance
 * of a <em>posek</em></strong>. According to Rabbi Dovid Yehudah Bursztyn in his <a href="https://www.worldcat.org/oclc/1158574217"
 * >Zmanim Kehilchasam, 7th edition</a> chapter 2, section 7 (pages 181-182) and section 9 (pages 186-187), no <em>zmanim</em>
 * besides sunrise and sunset should use elevation. However, Rabbi Yechiel Avrahom Zilber in the <a href=
 * "https://hebrewbooks.org/51654">Birur Halacha Vol. 6</a> Ch. 58 Pages <a href=
 * "https://hebrewbooks.org/pdfpager.aspx?req=51654&amp;pgnum=42">34</a> and <a href=
 * "https://hebrewbooks.org/pdfpager.aspx?req=51654&amp;pgnum=50">42</a> is of the opinion that elevation should be accounted for
 * in <em>zmanim</em> calculations. Related to this, Rabbi Yaakov Karp in <a href="https://www.worldcat.org/oclc/919472094"
 * >Shimush Zekeinim</a>, Ch. 1, page 17 states that obstructing horizons should be factored into <em>zmanim</em> calculations. The
 * setting defaults to false (elevation will not be used for <em>zmanim</em> calculations besides sunrise and sunset), unless the
 * setting is changed to true in ``setUseElevation()``. This will impact sunrise and sunset-based <em>zmanim</em> such as
 * ``getSunrise()``, ``getSunset()``, ``getSofZmanShmaGRA()``, <em>alos</em>-based
 * <em>zmanim</em> such as ``getSofZmanShmaMGA72Minutes()`` that are based on a fixed offset of sunrise or sunset and
 * <em>zmanim</em> based on a percentage of the day such as ``ComprehensiveZmanimCalendar/getSofZmanShmaMGA90MinutesZmanis()``
 * that are based on sunrise and sunset. Even when set to true it will not impact <em>zmanim</em> that are a degree-based offset of
 * sunrise and sunset, such as ``ComprehensiveZmanimCalendar/getSofZmanShmaMGA16Point1Degrees()`` or ``ComprehensiveZmanimCalendar/getSofZmanShmaBaalHatanya()`` since these <em>zmanim</em> are not linked to sunrise or sunset times
 * (the calculations are based on the astronomical definition of sunrise and sunset calculated in a vacuum with the solar radius
 * above the horizon), and are therefore not impacted by the use of elevation. For additional information on the <em>halachic</em>
 * impact of elevation on <em>zmanim</em> see:
 * <ul>
 * <li><a href="https://www.nli.org.il/en/books/NNL_ALEPH002542826/NLI">Zmanei Halacha Lema'aseh</a> 4th edition by <a href=
 * "http://beinenu.com/rabbis/%D7%94%D7%A8%D7%91-%D7%99%D7%93%D7%99%D7%93%D7%99%D7%94-%D7%9E%D7%A0%D7%AA">Rabbi Yedidya Manat</a>.
 * See section 1, pages 11-12 for a very concise write-up, with details in section 2, pages 37 - 63 and 133 - 151.</li>
 * <li><a href="https://www.worldcat.org/oclc/1158574217">Zmanim Kehilchasam</a> 7th edition, by Rabbi Dovid Yehuda Burstein,  vol 1,
 * chapter 2, pages 95 - 188.</li>
 * <li><a href="https://www.worldcat.org/oclc/36089452">Hazmanim Bahalacha</a> by Rabbi Chaim Benish , perek 7, pages 53 - 63.</li>
 * </ul>
 *
 * <p><b>Note:</b> It is important to read the technical notes on top of the ``AstronomicalCalculator`` documentation
 * before using this code.
 * <p>I would like to thank <a href="https://www.worldcat.org/search?q=au%3AShakow%2C+Yaakov">Rabbi Yaakov Shakow</a>, the
 * author of Luach Ikvei Hayom who spent a considerable amount of time reviewing, correcting and making suggestions on the
 * documentation in this library.
 * <h2>Disclaimer:</h2> I did my best to get accurate results, but please double-check before relying on these
 * <em>zmanim</em> for <em>halacha lema'aseh</em>.
 *
 * @author © Eliyahu Hershfeld 2004 - 2026
 */
public class ZmanimCalendar: AstronomicalCalendar {

    /**
     * Is elevation factored in for some <em>zmanim</em> (see ``isUseElevation()`` for additional information).
     * @see isUseElevation()
     * @see setUseElevation(boolean)
     */
    public var useElevation = false

    /**
     * Is elevation above sea level calculated for times besides sunrise and sunset. According to Rabbi Dovid Yehuda Bursztyn in
     * his <a href="https://www.worldcat.org/oclc/659793988">Zmanim Kehilchasam (second edition published in 2007)</a> chapter 2
     * (pages 186-187) no <em>zmanim</em> besides sunrise and sunset should use elevation. However, Rabbi Yechiel Avrahom Zilber
     * in the <a href="https://hebrewbooks.org/51654">Birur Halacha Vol. 6</a> Ch. 58 Pages <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=51654&amp;pgnum=42">34</a> and <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=51654&amp;pgnum=50">42</a> is of the opinion that elevation should be accounted
     * for in <em>zmanim</em> calculations. Related to this, Rabbi Yaakov Karp in <a href=
     * "https://www.worldcat.org/oclc/919472094">Shimush Zekeinim</a>, Ch. 1, page 17 states that obstructing horizons should be
     * factored into <em>zmanim</em> calculations.The setting defaults to false (elevation will not be used for <em>zmanim</em>
     * calculations), unless the setting is changed to true in ``setUseElevation()``. This will impact sunrise and
     * sunset based <em>zmanim</em> such as  ``getSofZmanShmaGRA()``, alos based <em>zmanim</em> such as ``getSofZmanShmaMGA72Minutes()`` that are based on a fixed offset of sunrise or sunset and <em>zmanim</em> based on a
     * percentage of the day such as ``ComprehensiveZmanimCalendar/getSofZmanShmaMGA90MinutesZmanis()`` that are based on
     * sunrise and sunset. It will not impact <em>zmanim</em> that are a degree based offset of sunrise and sunset, such as ``ComprehensiveZmanimCalendar/getSofZmanShmaMGA16Point1Degrees()`` or ``ComprehensiveZmanimCalendar/getSofZmanShmaBaalHatanya()``.
     *
     * @return if the use of elevation is active
     *
     * @see setUseElevation(boolean)
     */
    public func isUseElevation() -> Bool {
        return useElevation
    }

    /**
     * Sets whether elevation above sea level is factored into <em>zmanim</em> calculations for times besides sunrise and sunset.
     * See ``isUseElevation()`` for more details.
     * @see isUseElevation()
     *
     * @param useElevation set to true to use elevation in <em>zmanim</em> calculations
     */
    public func setUseElevation(useElevation: Bool) {
        self.useElevation = useElevation
    }

    /**
     * Is astronomical <em>chatzos</em> used for <em>zmanim</em> calculations. The default value of `true` will
     * keep the standard astronomical <em>chatzos</em> calculation, while setting it to `false` will use half of
     * a solar day / night calculation for <em>chatzos</em>.
     * @see isUseAstronomicalChatzos()
     * @see isUseAstronomicalChatzosForOtherZmanim()
     * @see setUseAstronomicalChatzos(boolean)
     * @see getChatzosHayom()
     * @see getChatzosHalayla()
     * @see getSunTransit()
     * @see getChatzosHayomAsHalfDay()
     */
    public var useAstronomicalChatzos = true

    /**
     * Is astronomical <em>chatzos</em> used for ``getChatzosHayom()`` and ``getChatzosHalayla()``
     * for enhanced accuracy. For example as the day lengthens, the second half of the day is longer than the first and astronomical
     * <em>chatzos</em> would be a drop earlier than half of the time between sunrise and sunset.
     *
     * @todo In the future, if this is set to true, the following may change to enhance accuracy. <em>Sof zman Shma</em> GRA would be calculated as 3 <em>shaos zmaniyos</em> after sunrise, but the <em>shaos
     * zmaniyos</em> would be calculated a a 6th of the time between sunrise and <em>chatzos</em>, as opposed to a 12th of the
     * time between sunrise and sunset. <em>mincha gedola</em> will be calculated as half a
     * <em>shaah zmanis</em> of afternoon hours (a 6th of the time between <em>chatzos</em> and sunset after astronomical
     * <em>chatzos</em> as opposed to 6.5 <em>shaos zmaniyos</em> after sunrise. <em>Plag hamincha</em> would be calculated as 4.75 <em>shaos zmaniyos</em> after astronomical <em>chatzos</em> as opposed to 10.75
     * <em>shaos zmaniyos</em> after sunrise. Etc.
     *
     * @return if the use of astronomical <em>chatzos</em> is active.
     * @see isUseAstronomicalChatzos()
     * @see setUseAstronomicalChatzos(boolean)
     * @see getChatzosHayom()
     * @see getChatzosHalayla()
     * @see getSunTransit()
     * @see getChatzosHayomAsHalfDay()
     * @see isUseAstronomicalChatzosForOtherZmanim()
     */
    public func isUseAstronomicalChatzos() -> Bool {
        return useAstronomicalChatzos
    }

    /**
     * Sets if astronomical <em>chatzos</em> should be used in calculations of other <em>zmanim</em> for enhanced accuracy.
     * @param useAstronomicalChatzos set to true to use astronomical in <em>chatzos</em> in <em>zmanim</em> calculations.
     * @see isUseAstronomicalChatzos()
     * @see getChatzosHayom()
     * @see getChatzosHalayla()
     * @see getSunTransit()
     * @see getChatzosHayomAsHalfDay()
     * @see setUseAstronomicalChatzosForOtherZmanim(boolean)
     */
    public func setUseAstronomicalChatzos(useAstronomicalChatzos: Bool) {
        self.useAstronomicalChatzos = useAstronomicalChatzos
    }

    /**
     * Is astronomical <em>chatzos</em> used for <em>zmanim</em> calculations besides <em>chatzos</em> itself for enhanced
     * accuracy. The default value of `false` will keep the standard start to end of day calculations, while setting
     * it to `true` will use half of a solar day calculation for <em>zmanim</em>.
     * @see isUseAstronomicalChatzosForOtherZmanim()
     * @see setUseAstronomicalChatzosForOtherZmanim(boolean)
     * @see isUseAstronomicalChatzos()
     * @see setUseAstronomicalChatzos(boolean)
     * @see getChatzosHayom()
     * @see getChatzosHalayla()
     */
    public var useAstronomicalChatzosForOtherZmanim = false

    /**
     * Is astronomical <em>chatzos</em> used for <em>zmanim</em> calculations besides <em>chatzos</em> itself for enhanced
     * accuracy. For example as the day is lengthening (as we approach spring season), the second half of the day is longer than
     * the first and astronomical <em>chatzos</em> would be a drop earlier than half of the time between sunrise and sunset.
     * Conversely, the second half of the day would be shorter in the autumn as the days start getting shorter.
     *
     * @todo In the future, if this is set to true, the following may change to enhance accuracy. <em>Sof zman Shma</em> GRA would be calculated as 3 <em>shaos zmaniyos</em> after sunrise, but the <em>shaos
     * zmaniyos</em> would be calculated a a 6th of the time between sunrise and <em>chatzos</em>, as opposed to a 12th of the
     * time between sunrise and sunset. <em>mincha gedola GRA</em> will be calculated as half a
     * <em>shaah zmanis</em> of afternoon hours (a 6th of the time between <em>chatzos</em> and sunset after astronomical
     * <em>chatzos</em> as opposed to 6.5 <em>shaos zmaniyos</em> after sunrise. <em>Plag hamincha</em> would be calculated as 4.75 <em>shaos zmaniyos</em> after astronomical <em>chatzos</em> as opposed to 10.75
     * <em>shaos zmaniyos</em> after sunrise. Etc.
     *
     * @return if the use of astronomical <em>chatzos</em> is active.
     * @see setUseAstronomicalChatzosForOtherZmanim(boolean)
     * @see isUseAstronomicalChatzos()
     * @see setUseAstronomicalChatzos(boolean)
     */
    public func isUseAstronomicalChatzosForOtherZmanim() -> Bool {
        return useAstronomicalChatzosForOtherZmanim
    }

    /**
     * Sets if astronomical <em>chatzos</em> should be used in calculations of other <em>zmanim</em> for enhanced accuracy.
     * @param useAstronomicalChatzosForOtherZmanim set to true to use astronomical in <em>chatzos</em> in <em>zmanim</em> calculations.
     * @see isUseAstronomicalChatzos()
     */
    public func setUseAstronomicalChatzosForOtherZmanim(useAstronomicalChatzosForOtherZmanim: Bool) {
        self.useAstronomicalChatzosForOtherZmanim = useAstronomicalChatzosForOtherZmanim
    }

    /**
     * The zenith of 16.1° below geometric zenith (90°).
     * @see getAlos16Point1Degrees()
     * @see ComprehensiveZmanimCalendar/getTzais16Point1Degrees()
     * @see ComprehensiveZmanimCalendar/getSofZmanShmaMGA16Point1Degrees()
     * @see ComprehensiveZmanimCalendar/getSofZmanTfilaMGA16Point1Degrees()
     * @see ComprehensiveZmanimCalendar/getMinchaGedola16Point1Degrees()
     * @see ComprehensiveZmanimCalendar/getMinchaKetana16Point1Degrees()
     * @see ComprehensiveZmanimCalendar/getPlagHamincha16Point1Degrees()
     *
     * @see ComprehensiveZmanimCalendar/getSofZmanShmaAlos16Point1DegreesToTzaisGeonim7Point083Degrees()
     * @see ComprehensiveZmanimCalendar/getPlagAlos16Point1DegreesToTzaisGeonim7Point083Degrees()
     * @see ComprehensiveZmanimCalendar/getSofZmanShmaAlos16Point1ToSunset()
     * @see ComprehensiveZmanimCalendar/getShaahZmanis16Point1Degrees()
     * @see ComprehensiveZmanimCalendar/getShaahZmanisAlos16Point1DegreesToTzaisGeonim3Point7Degrees()
     * @see ComprehensiveZmanimCalendar/getShaahZmanisAlos16Point1DegreesToTzaisGeonim3Point8Degrees()
     * @see ComprehensiveZmanimCalendar/getShaahZmanisAlos16Point1DegreesToTzaisGeonim7Point083Degrees()
     *
     */
    public static let ZENITH_16_POINT_1 = AstronomicalCalendar.GEOMETRIC_ZENITH + 16.1

    /**
     * The zenith of 8.5° below geometric zenith (90°).
     * @see getTzaisGeonim8Point5Degrees()
     */
    public static let ZENITH_8_POINT_5 = AstronomicalCalendar.GEOMETRIC_ZENITH + 8.5

    /**
     * The zenith of 1.583° below ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°).
     * @see getSunriseBaalHatanya()
     * @see getSunsetBaalHatanya()
     */
    public static let ZENITH_1_POINT_583 = AstronomicalCalendar.GEOMETRIC_ZENITH + 1.583

    /**
     * The default <em>Shabbos</em> candle lighting offset is 18 minutes. This can be changed via the
     * ``setCandleLightingOffset()`` and retrieved by the ``getCandleLightingOffset()``.
     */
    public var candleLightingOffset = 18.0

    /**
     * This method will return sea level sunrise if ``isUseElevation()`` is false (the default),
     * or elevation adjusted ``getSunrise()`` if it is true. This allows relevant <em>zmanim</em> in this and
     * extending classes (such as the ``ComprehensiveZmanimCalendar``) to automatically adjust to the elevation setting.
     *
     * @return ``getSeaLevelSunrise()`` if ``isUseElevation()`` is false (the default), or elevation adjusted
     *         ``getSunrise()`` if it is true.
     * @see getSunrise()
     */
    public func getSunriseBasedOnElevationSetting() -> Date? {
        if isUseElevation() {
            return super.getSunrise()
        }
        return getSeaLevelSunrise()
    }

    /**
     * This method will return sea level sunset if ``isUseElevation()`` is false (the default), or
     * elevation adjusted ``getSunset()`` if it is true. This allows relevant <em>zmanim</em>in this and extending classes (such
     * as the ``ComprehensiveZmanimCalendar``) to automatically adjust to the elevation setting.
     *
     * @return ``getSeaLevelSunset()`` if ``isUseElevation()`` is false (the default), or elevation adjusted
     *         ``getSunset()`` if it is true.
     * @see getSunset()
     */
    public func getSunsetBasedOnElevationSetting() -> Date? {
        if isUseElevation() {
            return super.getSunset()
        }
        return getSeaLevelSunset()
    }

    /**
     * A method that returns <em>tzais</em> (nightfall) when the sun is 8.5° below the ``AstronomicalCalendar/GEOMETRIC_ZENITH`` (90°) after sunset, a time that Rabbi Meir Posen in his the <em><a
     * href="https://www.worldcat.org/oclc/29283612">Ohr Meir</a></em> calculated that 3 small stars are visible, which is later than
     * the required 3 medium stars. This calculation is based on the sun's position below the horizon 36 minutes after sunset in Jerusalem <a href="https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/"
     * >around the equinox / equilux</a>, which is 8.5° below ``AstronomicalCalendar/GEOMETRIC_ZENITH``.
     *
     * @return The `Date` of nightfall. If the calculation can't be computed such as northern and southern locations
     *         even south of the Arctic Circle and north of the Antarctic Circle where the sun may not reach low enough below the
     *         horizon for this calculation, a `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * ComprehensiveZmanimCalendar#getTzaisGeonim8Point5Degrees() that returns an identical time to this generic <em>tzais</em>
     */
    public func getTzaisGeonim8Point5Degrees() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ZmanimCalendar.ZENITH_8_POINT_5)
    }

    /**
     * Returns <em>alos</em> (dawn) based on the time when the sun is 16.1° below the eastern ``AstronomicalCalendar/GEOMETRIC_ZENITH`` before sunrise. This is based on the calculation that the time
     * between dawn and sunrise (and sunset to nightfall) is 72 minutes, the time that is takes to walk 4 <a href=
     * "https://en.wikipedia.org/wiki/Biblical_mile">mil</a> at 18 minutes a mil (<a href="https://en.wikipedia.org/wiki/Maimonides"
     * >Rambam</a> and others). The sun's position below the horizon 72 minutes before sunrise in Jerusalem on
     * the <a href="https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a> is
     * 16.1° below ``AstronomicalCalendar/GEOMETRIC_ZENITH``.
     *
     * @see ComprehensiveZmanimCalendar/getTzais16Point1Degrees()
     *
     * @return The `Date` of dawn. If the calculation can't be computed such as northern and southern
     *         locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not reach
     *         low enough below the horizon for this calculation, a `nil` will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getAlos16Point1Degrees() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ZmanimCalendar.ZENITH_16_POINT_1)
    }

    /**
     * Method to return <em>alos</em> (dawn) calculated as 72 minutes before sunrise or sea level sunrise (depending on the ``isUseElevation()`` setting). This time
     * is based on the time to walk the distance of 4 <a href="https://en.wikipedia.org/wiki/Biblical_mile">mil</a> at 18 minutes a mil. The
     * 72-minute time (but not the concept of fixed minutes) is based on the opinion that the time of the <em>Neshef</em>
     * (twilight between dawn and sunrise) does not vary by the time of year or location but depends on the time it takes
     * to walk the distance of 4 mil.
     *
     * @return the `Date` representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
     *         a `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     */
    public func getAlos72Minutes() -> Date? {
        return AstronomicalCalendar.getTimeOffset(time: getSunriseBasedOnElevationSetting(), offset: -72 * 60.0)
    }

    /**
     * This method returns Astronomical <em>chatzos hayom</em> if the
     * calculator class used supports it and
     * isUseAstronomicalChatzos() is set to `true` or the halfway point between sunrise and sunset if it does not support it, or it is not configured to use it. There are currently
     * four calculators available in the API. The default NOAA calculator, the SPA calculator
     * and the Meeus calculator calculate it as astronomical <em>chatzos</em>, while the USNO calculator calculates <em>chatzos</em>
     * as halfway between sunrise and sunset (identical to six <em>shaos zmaniyos</em> after sunrise). See <a href=
     * "https://kosherjava.com/2020/07/02/definition-of-chatzos/">The Definition of <em>Chatzos</em></a> for a detailed explanation of
     * the ways to calculate <em>Chatzos</em>. Since half-day <em>chatzos</em> can be `nil` in the Arctic on a day when
     * either sunrise or sunset did not happen and astronomical <em>chatzos</em> can be calculated even in the Arctic, if half-day
     * <em>chatzos</em> calculates as `nil` and astronomical <em>chatzos</em> is supported by the calculator, astronomical
     * <em>chatzos</em> will be returned to avoid returning a `nil`.
     *
     * @see getSunTransit()
     * @see getChatzosHayomAsHalfDay()
     * @see isUseAstronomicalChatzos()
     * @see setUseAstronomicalChatzos(boolean)
     * @return the `Date` of <em>chatzos</em>. If the calculation can't be computed such as in the Arctic Circle
     *         where there is at least one day where the sun does not rise, and one where it does not set, and the calculator does not
     *         support astronomical calculations (that will never report a `nil`) a `nil` will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getChatzosHayom() -> Date? {
        if isUseAstronomicalChatzos() {
            return getSunTransit() // can be null if the calculator does not support astronomical chatzos
        } else {
            let halfDayChatzos: Date? = getChatzosHayomAsHalfDay()
            if halfDayChatzos == nil {
                return getSunTransit() // can be null if the calculator does not support astronomical chatzos
            } else {
                return halfDayChatzos
            }
        }
    }

    /**
     * A method that returns <em>chatzos halayla</em> at the <b>end of the day</b> (the last <em>zman</em> of the day
     * returned by the calendar, that may actually be after midnight of the day it is being calculated for). For example, if
     * calculating it for the date of <em>Erev Pesach</em>, the calculation will be for <em>Lail Pesach</em> to allow you to use the
     * <em>zman</em> as <em>sof zman achilas afikoman</em>. Astronomical <em>chatzos halayla</em> will be
     * returned if the calculator class used supports it and isUseAstronomicalChatzos() is set to `true`. Otherwise the halfway point between sunset and the following day's sunrise, if it does not support it, or it is not configured to
     * use it. There are currently four calculators available in the API.
     * The default NOAA calculator, the SPA calculator and the Meeus calculator calculate it as astronomical <em>chatzos halayla</em>, while the USNO calculator calculates <em>chatzos halayla</em> as halfway between sunset
     * and the following day's sunrise (identical to six <em>shaos zmaniyos</em> after sunset). See <a href=
     * "https://kosherjava.com/2020/07/02/definition-of-chatzos/">The Definition of <em>Chatzos</em></a> for a detailed explanation
     * of the ways to calculate <em>Chatzos</em>. Since half-night <em>chatzos</em> can be `nil` in the Arctic on a day
     * when either sunset or the following day's sunrise did not happen and astronomical <em>chatzos halayla</em> can be calculated
     * even in the Arctic, if half-day <em>chatzos</em> calculates as `nil` and astronomical <em>chatzos</em> is
     * supported by the calculator, astronomical <em>chatzos</em> will be returned to avoid returning a `nil`.
     *
     * @see getSolarMidnight()
     * @see getChatzos(Instant, Instant)
     * @see isUseAstronomicalChatzos()
     * @see setUseAstronomicalChatzos(boolean)
     * @return the `Date` of <em>chatzos halayla</em> at the <b>end of the current day</b>. If the calculation can't be
     *         computed such as in the Arctic Circle where there is at least one day where the sun does not rise, and one where it
     *         does not set, and the calculator does not support astronomical calculations (that will never report a
     *         `nil`) a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getChatzosHalayla() -> Date? {
        if isUseAstronomicalChatzos() {
            return getSolarMidnight() // can be null if the calculator does not support astronomical chatzos
        } else {
            let clonedCalendar = self.copy()
            clonedCalendar.setLocalDate(localDate: getLocalDate().plusDays(1))
            let halfNightChatzos: Date? = getChatzos(begin: getSeaLevelSunset(), end: clonedCalendar.getSeaLevelSunrise())
            if halfNightChatzos == nil {
                return getSolarMidnight() // can be null if the calculator does not support astronomical chatzos
            } else {
                return halfNightChatzos
            }
        }
    }

    /**
     * A method that returns <em>chatzos</em> (<em>hayom</em> or <em>layla</em>) calculated as halfway between the begin and end
     * times passed in. If sunrise and sunset (or sunset and the following sunrise for <em>chatzos halayla</em>) are passed in,
     * the <em>zman</em> returned will be close to, but not exactly, when the Sun is <a href=
     * "https://en.wikipedia.org/wiki/Transit_%28astronomy%29">transiting</a> the <a href=
     * "https://en.wikipedia.org/wiki/Meridian_%28astronomy%29">celestial meridian</a> due to changes in declination (the
     * lengthening or shortening day). See <a href="https://kosherjava.com/2020/07/02/definition-of-chatzos/">The Definition of
     * <em>Chatzos</em></a> for a detailed explanation of the ways to calculate <em>Chatzos</em>. This method is a convenience
     * method that calls the parent class's ``getSunTransit()``. A practical example of using this would be
     * calculating <em>chatzos halayla</em> for the end of <em>zman achilas afikoman</em> on <em>Pesach</em> night, where
     * <a href="https://en.wikipedia.org/wiki/Shlomo_Zalman_Auerbach">Rav Shlomo Zalman Auerbach</a> in the Halichos Shlomo,
     * Moadim Nisan - Av, ch. 9, no. 44, pages 289-292, questioned the common practice of considering <em>chatzos halayla</em> as
     * astronomical <em>chatzos halayla</em>, and felt that for this it should be at <em>chatzi halayla</em>, halfway between sunset
     * and <em>alos</em> or <em>bedieved</em> from an early <em>tzais</em> that is lower (degree-wise) than <em>alos</em> the next
     * morning, thus making this <em>zman</em> significantly earlier. <a href="https://en.wikipedia.org/wiki/Moshe_Sternbuch">Rav
     * Moshe Sternbuch</a> in <a href="https://hebrewbooks.org/pdfpager.aspx?req=69091&pgnum=15">Teshuvos Vehanhagos v. VII, ch 1, p.
     * 3</a>, agreed to this calculation for <em>chatzos halayla</em> on <em>Pesach</em> night.
     *
     * @param begin the beginning of day or night for calculating <em>chatzos</em>. For <em>chatzos hayom</em>, this can be sea level
     *         sunrise, or any arbitrary sunrise or <em>alos</em> used as the beginning of the day, and for <em>chatzos halayla</em>
     *         this can be sea level sunset, or any arbitrary sunset or <em>tzais</em> used as the beginning of the night.
     * @param end the end of day or night for calculating <em>chatzos</em>. For <em>chatzos hayom</em>, this can be sea level sunset,
     *         or any arbitrary sunset or <em>tzais</em> used as the end of day, and for <em>chatzos halayla</em> this can be sea
     *         level sunrise, or any arbitrary sunrise or <em>alos</em> used as the end of the night.
     * @return the `Date` representing <em>chatzos</em>. If the calculation can't be computed such as in the
     *         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
     *         not set, `nil` will be returned. See detailed explanation on top of the page.
     * @see getSunTransit(Instant, Instant)
     * @see getChatzosHayomAsHalfDay()
     * @see getChatzosHayom()
     * @see getChatzosHalayla()
     */
    public func getChatzos(begin: Date?, end: Date?) -> Date? {
        return getSunTransit(startOfDay: begin, endOfDay: end)
    }

    /**
     * Returns <em>chatzos</em> calculated as halfway between sunrise and sunset. Many are of the opinion that
     * <em>chatzos</em> is calculated as the midpoint between sea level sunrise and
     * sea level sunset, despite it not being the most accurate way to calculate it. A day
     * starting at <em>alos</em> and ending at <em>tzais</em> using the same time or degree offset will also return
     * the same time. In reality due to lengthening or shortening of day, this is not necessarily the exact midpoint of
     * the day, but it is very close. There are currently four calculators available in the API. The default NOAA calculator, the
     * SPA calculator and the Meeus calculator calculate <em>chatzos</em> as astronomical <em>chatzos</em>, which is slightly
     * more accurate, while the USNO calculator calculates it as halfway
     * between sunrise and sunset (identical to six <em>shaos zmaniyos</em> after sunrise). This method allows you to use any
     * calculator and still calculate <em>chatzos</em> as six <em>shaos zmaniyos</em> after sunrise. See <a href=
     * "https://kosherjava.com/2020/07/02/definition-of-chatzos/">The Definition of <em>Chatzos</em></a> for a detailed explanation
     * of the ways to calculate <em>Chatzos</em>.
     *
     * @return the `Date` of the latest <em>chatzos</em>. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
     *         it does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see com.kosherjava.zmanim.util.NOAACalculator#getUTCNoon(LocalDate, GeoLocation)
     * @see com.kosherjava.zmanim.util.SunTimesCalculator#getUTCNoon(LocalDate, GeoLocation)
     * @see com.kosherjava.zmanim.util.AstronomicalCalculator#getUTCNoon(LocalDate, GeoLocation)
     * @see getSunTransit(Instant, Instant)
     * @see getChatzosHayom()
     * @see getChatzosHalayla()
     * @see getChatzos(Instant, Instant)
     * @see getSunTransit()
     * @see isUseAstronomicalChatzos()
     */
    public func getChatzosHayomAsHalfDay() -> Date? {
        return getChatzos(begin: getSeaLevelSunrise(), end: getSeaLevelSunset())
    }

    /**
     * A generic method for calculating the latest <em>zman krias shema</em> (time to recite shema in the morning) that is 3 *
     * <em>shaos zmaniyos</em> (temporal hours) after the start of the day, calculated using the start and end of the day passed
     * to this method. The time from the start of day to the end of day are divided into 12 <em>shaos zmaniyos</em> (temporal
     * hours), and the latest <em>zman krias shema</em> is calculated as 3 of those <em>shaos zmaniyos</em> after the beginning of
     * the day. If ``isUseAstronomicalChatzosForOtherZmanim()`` is `true`, the 3 <em>shaos zmaniyos</em> will be
     * based on 1/6 of the time between sunrise and astronomical <em>chatzos</em>. As an example, passing
     * sunrise and sunset or sea level sunrise and sea level sunset to this method (or ``getSunriseBasedOnElevationSetting()`` and
     * ``getSunsetBasedOnElevationSetting()`` that is driven off the ``isUseElevation()`` setting) will return <em>sof zman
     * krias shema</em> according to the opinion of the <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a>. In cases where
     * the start and end dates are not synchronous such as in #getSofZmanShmaAlos16Point1ToTzaisGeonim7Point083Degrees() `false` should be passed to the synchronous parameter
     * to ensure that ``isUseAstronomicalChatzosForOtherZmanim()`` will not be used.
     *
     * @param startOfDay the start of day for calculating <em>zman krias shema</em>. This can be sunrise or any <em>alos</em> passed
     *         to this method.
     * @param endOfDay the end of day for calculating <em>zman krias shema</em>. This can be sunset or any <em>tzais</em> passed to
     *         this method.
     * @param synchronous If the <em>zman</em> has a synchronous start and end of the day. If this is `false`, using a
     *         ``isUseAstronomicalChatzosForOtherZmanim()`` makes no sense and will be ignored even if set to true, since by
     *         definition <em>chatzos</em> will not be the middle of the day for the <em>zman</em>.
     * @see isUseAstronomicalChatzosForOtherZmanim()
     * @return the `Date` of the latest <em>zman shema</em> based on the start and end of day times passed to this
     *         method. If the calculation can't be computed such as in the Arctic Circle where there is at least one day
     *         a year where the sun does not rise, and one where it does not set, a `nil` will be returned. See
     *         detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getSofZmanShma(startOfDay: Date?, endOfDay: Date?, synchronous: Bool) -> Date? {
        if isUseAstronomicalChatzosForOtherZmanim() && synchronous {
            return getHalfDayBasedZman(startOfHalfDay: startOfDay, endOfHalfDay: getChatzosHayom(), hours: 3)
        } else {
            return getShaahZmanisBasedZman(startOfDay: startOfDay, endOfDay: endOfDay, hours: 3)
        }
    }

    /**
     * A generic method for calculating the latest <em>zman krias shema</em> that calls ``getSofZmanShma()``
     * passing `false` to the synchronous parameter since there is no way to know if the start and end of the day are
     * synchronous. Passing true when they are not synchronous is too much of a risk. See information on that method for more details.
     * @param startOfDay the start of day for calculating <em>zman krias shema</em>. This can be sunrise or any <em>alos</em> passed
     *         to this method.
     * @param endOfDay the end of day for calculating <em>zman krias shema</em>. This can be sunset or any <em>tzais</em> passed to
     *         this method.
     * @return the `Date` of the latest <em>zman shema</em> based on the start and end of day times passed to this
     *         method. If the calculation can't be computed such as in the Arctic Circle where there is at least one day
     *         a year where the sun does not rise, and one where it does not set, a `nil` will be returned. See
     *         detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getSofZmanShma(Instant, Instant, boolean)
     */
    public func getSofZmanShma(startOfDay: Date?, endOfDay: Date?) -> Date? {
        return getSofZmanShma(startOfDay: startOfDay, endOfDay: endOfDay, synchronous: false)
    }

    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite shema in the morning) that is 3 *
     * <em>shaos zmaniyos</em> (solar hours) after sunrise or
     * sea level sunrise (depending on the ``isUseElevation()`` setting), according
     * to the <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a>.
     *  The day is calculated from sea level sunrise to sea level sunset or from sunrise to sunset (depending on the
     *  ``isUseElevation()`` setting).
     *
     * @see getSofZmanShma(Instant, Instant)
     * @see getShaahZmanisGRA()
     * @see isUseElevation()
     * @see ComprehensiveZmanimCalendar/getSofZmanShmaBaalHatanya()
     * @return the `Date` of the latest <em>zman shema</em> according to the GRA. If the calculation can't be
     *         computed such as in the Arctic Circle where there is at least one day a year where the sun does not rise,
     *         and one where it does not set, a `nil` will be returned. See the detailed explanation on top
     *         of the ``AstronomicalCalendar`` documentation.
     */
    public func getSofZmanShmaGRA() -> Date? {
        return getSofZmanShma(startOfDay: getSunriseBasedOnElevationSetting(), endOfDay: getSunsetBasedOnElevationSetting(), synchronous: true)
    }

    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite Shema in the morning) according to the opinion of
     * the <a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a> based on <em>alos</em> being 72 minutes before sunrise. This time is 3 <em>shaos zmaniyos</em> (solar hours) after dawn based on the opinion
     * of the MGA that the day is calculated from a dawn of 72 minutes before sunrise to
     * nightfall of 72 minutes after sunset. This returns the time of 3 * ``getShaahZmanis72Minutes()`` after dawn.
     *
     * @return the `Date` of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
     *         it does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see isUseAstronomicalChatzosForOtherZmanim()
     * @see getShaahZmanis72Minutes()
     * @see getAlos72Minutes()
     * @see getSofZmanShmaMGA72Minutes()
     * @see getSofZmanShma(Instant, Instant, boolean)
     */
    public func getSofZmanShmaMGA72Minutes() -> Date? {
        return getSofZmanShma(startOfDay: getAlos72Minutes(), endOfDay: getTzais72Minutes(), synchronous: true)
    }

    /**
     * This method returns the <em>tzais</em> (nightfall) based on the opinion of <em>Rabbeinu Tam</em> that <em>tzais hakochavim</em>
     * is calculated as 72 minutes after sunset, the time it takes to walk 4 <a href=
     * "https://en.wikipedia.org/wiki/Biblical_mile">mil</a> at 18 minutes a mil. According to the <a href=
     * "https://en.wikipedia.org/wiki/Samuel_Loew">Machtzis Hashekel</a> in Orach Chaim 235:3, the <a href=
     * "https://en.wikipedia.org/wiki/Joseph_ben_Meir_Teomim">Pri Megadim</a> in Orach Chaim 261:2 (see the Biur Halacha) and others
     * (see Hazmanim Bahalacha 17:3 and 17:5) the 72 minutes are standard clock minutes any time of the year in any location.
     * Depending on the ``isUseElevation()`` setting, a 72-minute offset from  either sunset or
     * sea level sunset is used.
     *
     * @return the `Date` representing 72 minutes after sunset. If the calculation can't be
     *         computed such as in the Arctic Circle where there is at least one day a year where the sun does not rise,
     *         and one where it does not set, a `nil` will be returned See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see ComprehensiveZmanimCalendar/getTzais16Point1Degrees()
     */
    public func getTzais72Minutes() -> Date? {
        return AstronomicalCalendar.getTimeOffset(time: getSunsetBasedOnElevationSetting(), offset: 72 * 60.0)
    }

    /**
     * A method to return candle lighting time, calculated as ``getCandleLightingOffset()`` minutes before sea level sunset
     * (``getSeaLevelSunset()``). This will return the time for any day of the week, since it can be used to calculate
     * candle lighting time for <em>Yom Tov</em> (mid-week holidays) as well. Elevation adjustments are intentionally not
     * performed by this method, but you can calculate it by passing the elevation adjusted sunset to
     * ``AstronomicalCalendar/getTimeOffset(time:offset:)``. Candles can't be lit before <em>plag hamincha</em>
     * (``getPlagHaminchaGRA()``), so if the calculated time is before it (on very short winter days), <em>plag hamincha</em>
     * is returned instead. (KosherJava returns `null` in that case.)
     *
     * @return candle lighting time, or <em>plag hamincha</em> if that is later. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
     *         not set, a `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see getSeaLevelSunset()
     * @see getCandleLightingOffset()
     * @see setCandleLightingOffset(candleLightingOffset:)
     */
    public func getCandleLighting() -> Date? {
        let totalNanos = JavaMath.toLong(-getCandleLightingOffset() * Double(AstronomicalCalendar.MINUTE_NANOS))
        let candleLighting = AstronomicalCalendar.getTimeOffset(time: getSeaLevelSunset(), offset: Double(totalNanos) / 1_000_000_000)
        if let candleLighting = candleLighting, let plagHamincha = getPlagHaminchaGRA(), candleLighting < plagHamincha {
            return plagHamincha // very short winter day: candles can't be lit before plag hamincha
        }
        return candleLighting
    }

    /**
     * A generic method for calculating the latest <em>zman tfilah</em> (time to recite the morning prayers) that is 4 * <em>shaos
     * zmaniyos</em> (temporal hours) after the start of the day, calculated using the start and end of the day passed to this method.
     * The time from the start of day to the end of day are divided into 12 <em>shaos zmaniyos</em> (temporal hours), and <em>sof
     * zman tfila</em> is calculated as 4 of those <em>shaos zmaniyos</em> after the beginning of the day. As an example, passing
     * ``getSunriseBasedOnElevationSetting()`` and ``getSunsetBasedOnElevationSetting()`` (depends on the ``isUseElevation()`` elevation setting) to this method will return <em>zman tfilah</em> according to the opinion of the <a href=
     * "https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a>. This method's synchronous parameter indicates if the start and end of day
     * for the calculation are synchronous, having the same offset. This is typically the case, but some <em>zmanim</em> calculations
     * are based on a start and end at different offsets from the real start and end of the day, such as starting the day at
     * <em>alos</em> and an ending it at <em>tzais Geonim</em> or some other variant. If the day is not synchronous a half-day based calculations will be bypassed. It would be illogical to use a
     * half-day based calculation that start/end at <em>chatzos</em> when the two "halves" of the day are not equal, and the halfway
     * point between them is not at <em>chatzos</em>.
     *
     * @param startOfDay the start of day for calculating <em>zman tfilah</em>. This can be sunrise or any <em>alos</em> passed
     *         to this method.
     * @param endOfDay the end of day for calculating <em>zman tfilah</em>. This can be sunset or any <em>tzais</em> passed
     *         to this method.
     * @param synchronous If the <em>zman</em> has a synchronous start and end of the day. If this is `false`, using a
     *         ``isUseAstronomicalChatzosForOtherZmanim()`` makes no sense and will be ignored even if set to true, since by
     *         definition <em>chatzos</em> will not be the middle of the day for the <em>zman</em>.
     * @return the `Date` of the latest <em>zman tfilah</em> based on the start and end of day times passed to this
     *         method. If the calculation can't be computed such as in the Arctic Circle where there is at least one day a year where
     *         the sun does not rise, and one where it does not set, a `nil` will be returned. See detailed explanation
     *         on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getSofZmanTfila(startOfDay: Date?, endOfDay: Date?, synchronous: Bool) -> Date? {
        if isUseAstronomicalChatzosForOtherZmanim() && synchronous {
            return getHalfDayBasedZman(startOfHalfDay: startOfDay, endOfHalfDay: getChatzosHayom(), hours: 4)
        } else {
            return getShaahZmanisBasedZman(startOfDay: startOfDay, endOfDay: endOfDay, hours: 4)
        }
    }

    /**
     * A generic method for calculating <em>sof zman biur chametz</em> or the latest time one is allowed burning
     * <em>chametz</em> on <em>Erev Pesach</em> that is 5 * <em>shaos zmaniyos</em> (temporal hours) after the start of the
     * day, calculated using the start and end of the day passed to this method. If the date is not <em>erev Pesach</em>, a
     * `nil` will be returned. The time from the start of day to the end of day is divided into 12 <em>shaos zmaniyos</em>
     * (temporal hours), and <em>sof zman biur chametz</em> is calculated as 5 of those <em>shaos zmaniyos</em> after the
     * beginning of the day. As an example, passing sunrise and sunset to this
     * method will return <em>sof zman biur chametz</em> according to the opinion of the <a href=
     * "https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a>. This method's synchronous parameter indicates if the start
     * and end of day for the calculation are synchronous, having the same offset. This is typically the case, but some
     * <em>zmanim</em> calculations are based on a start and end at different offsets from the real start and end of the day,
     * such as starting the day at <em>alos</em> and an ending it at <em>tzais Geonim</em> or some other variant. If the day
     * is not synchronous a half-day based calculations will be bypassed.
     * It would be illogical to use a half-day based calculation that start/end at <em>chatzos</em> when the two "halves" of
     * the day are not equal, and the halfway point between them is not at <em>chatzos</em>.
     *
     * @param startOfDay the start of day for calculating <em>sof zman biur chametz</em>. This can be sunrise or any <em>alos</em>
     *         passed to this method.
     * @param endOfDay the end of day for calculating <em>sof zman biur chametz</em>. This can be sunset or any <em>tzais</em>
     *         passed to this method.
     * @param synchronous If the <em>zman</em> has a synchronous start and end of the day. If this is `false`, using a
     *         ``isUseAstronomicalChatzosForOtherZmanim()`` makes no sense and will be ignored even if set to true, since by
     *         definition <em>chatzos</em> will not be the middle of the day for the <em>zman</em>.
     * @return the `Date` of the <em>sof zman biur chametz</em> based on the start and end of day times passed
     *         to this method. If the date is not <em>Erev Pesach</em> or if the calculation can't be computed such as in the
     *         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
     *         a `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     */
    public func getSofZmanBiurChametz(startOfDay: Date?, endOfDay: Date?, synchronous: Bool) -> Date? {
        let jewishCalendar = JewishCalendar(localDate: getLocalDate())
        if jewishCalendar.getJewishMonth() == JewishCalendar.NISSAN && jewishCalendar.getJewishDayOfMonth() == 14 {
            if isUseAstronomicalChatzosForOtherZmanim() && synchronous {
                return getHalfDayBasedZman(startOfHalfDay: startOfDay, endOfHalfDay: getChatzosHayom(), hours: 5)
            } else {
                return getShaahZmanisBasedZman(startOfDay: startOfDay, endOfDay: endOfDay, hours: 5)
            }
        } else {
            return nil
        }
    }

    /**
     * A generic method for calculating <em>sof zman achilas chametz</em> or the latest time one is allowed eating
     * <em>chametz</em> on <em>Erev Pesach</em> that is 4 * <em>shaos zmaniyos</em> (temporal hours) after the start of the
     * day, calculated using the start and end of the day passed to this method. If the date is not <em>erev Pesach</em>, a
     * `nil` will be returned. The time from the start of day to the end of day is divided into 12 <em>shaos zmaniyos</em>
     * (temporal hours), and <em>sof zman achilas chametz</em> is calculated as 4 of those <em>shaos zmaniyos</em> after the
     * beginning of the day. As an example, passing sunrise and sunset to this
     * method will return <em>sof zman achilas chametz</em> according to the opinion of the <a href=
     * "https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a>. This method's synchronous parameter indicates if the start
     * and end of day for the calculation are synchronous, having the same offset. This is typically the case, but some
     * <em>zmanim</em> calculations are based on a start and end at different offsets from the real start and end of the day,
     * such as starting the day at <em>alos</em> and an ending it at <em>tzais Geonim</em> or some other variant. If the day
     * is not synchronous a half-day based calculations will be bypassed.
     * It would be illogical to use a half-day based calculation that start/end at <em>chatzos</em> when the two "halves" of
     * the day are not equal, and the halfway point between them is not at <em>chatzos</em>.
     *
     * @param startOfDay the start of day for calculating <em>sof zman achilas chametz</em>. This can be sunrise or any <em>alos</em>
     *         passed to this method.
     * @param endOfDay the end of day for calculating <em>sof zman achilas chametz</em>. This can be sunset or any <em>tzais</em>
     *         passed to this method.
     * @param synchronous If the <em>zman</em> has a synchronous start and end of the day. If this is `false`, using a ``isUseAstronomicalChatzosForOtherZmanim()`` makes no sense and will be ignored even if set to true, since by definition
     *         <em>chatzos</em> will not be the middle of the day for the <em>zman</em>.
     * @return the `Date` of the <em>sof zman achilas chametz</em> based on the start and end of day times passed
     *         to this method. If the date is not <em>Erev Pesach</em> or if the calculation can't be computed such as in the
     *         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
     *         a `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     */
    public func getSofZmanAchilasChametz(startOfDay: Date?, endOfDay: Date?, synchronous: Bool) -> Date? {
        let jewishCalendar = JewishCalendar(localDate: getLocalDate())
        if jewishCalendar.getJewishMonth() == JewishCalendar.NISSAN && jewishCalendar.getJewishDayOfMonth() == 14 {
            return getSofZmanTfila(startOfDay: startOfDay, endOfDay: endOfDay, synchronous: synchronous)
        } else {
            return nil
        }
    }

    /**
     * A generic method for calculating the latest <em>zman tfila</em> that calls ``getSofZmanTfila()``
     * passing `false` to the synchronous parameter since there is no way to know if the start and end of the day are
     * synchronous. Passing true when they are not synchronous is too much of a risk. See information on that method for more details.
     * @param startOfDay the start of day for calculating <em>zman tfilah</em>. This can be sunrise or any <em>alos</em> passed
     *         to this method.
     * @param endOfDay the end of day for calculating <em>zman tfilah</em>. This can be sunset or any <em>tzais</em> passed to
     *         this method.
     * @return the `Date` of the latest <em>zman tfilah</em> based on the start and end of day times passed to this
     *         method. If the calculation can't be computed such as in the Arctic Circle where there is at least one day
     *         a year where the sun does not rise, and one where it does not set, a `nil` will be returned. See
     *         detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getSofZmanShma(Instant, Instant, boolean)
     */
    public func getSofZmanTfila(startOfDay: Date?, endOfDay: Date?) -> Date? {
        return getSofZmanTfila(startOfDay: startOfDay, endOfDay: endOfDay, synchronous: false)
    }

    /**
     * This method returns the latest <em>zman tfila</em> (time to recite the morning prayers) that is 4 *
     * <em>shaos zmaniyos</em>(solar hours) after sunrise or
     * sea level sunrise (depending on the ``isUseElevation()`` setting), according
     * to the <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a>.
     * The day is calculated from sea level sunrise to sea level sunset or from sunrise to sunset (depending on the
     * ``isUseElevation()`` setting).
     *
     * @see getSofZmanTfila(Instant, Instant)
     * @see getShaahZmanisGRA()
     * @see ComprehensiveZmanimCalendar/getSofZmanTfilaBaalHatanya()
     * @return the `Date` of the latest <em>zman tfilah</em>. If the calculation can't be computed such as in
     *         the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getSofZmanTfilaGRA() -> Date? {
        return getSofZmanTfila(startOfDay: getSunriseBasedOnElevationSetting(), endOfDay: getSunsetBasedOnElevationSetting(), synchronous: true)
    }

    /**
     * This method returns the latest <em>zman tfila</em> (time to recite the morning prayers) that is 4 * <em>shaos zmaniyos</em> (solar hours) after ``getAlos72Minutes()``, according to the
     * <em><a href="https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a></em>. The day is calculated
     * from 72 minutes before ``getSunriseBasedOnElevationSetting()`` to 72 minutes after ``getSunsetBasedOnElevationSetting()``. The use of elevation depends on the ``isUseElevation()`` setting).
     *
     * @return the `Date` of the latest <em>zman tfila</em>. If the calculation can't be computed such as in
     *         the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getSofZmanTfila(Instant, Instant, boolean)
     * @see getShaahZmanis72Minutes()
     * @see getAlos72Minutes()
     */
    public func getSofZmanTfilaMGA72Minutes() -> Date? {
        return getSofZmanTfila(startOfDay: getAlos72Minutes(), endOfDay: getTzais72Minutes(), synchronous: true)
    }

    /**
     * A generic method for calculating <em>mincha gedola</em> (the earliest time to recite the <em>mincha</em> prayers) that
     * is 6.5 * <em>shaos zmaniyos</em> (temporal hours) after the start of the day, calculated using the start and end of the
     * day passed to this method. The time from the start of day to the end of day are divided into 12 <em>shaos zmaniyos</em>
     * (temporal hours), and <em>mincha gedola</em> is calculated as 6.5 of those <em>shaos zmaniyos</em> after the beginning
     * of the day. As an example, passing sunrise and sunset or
     * sea level sunrise and sea level sunset (depending on the ``isUseElevation()`` elevation setting) to this method will return <em>mincha gedola</em> according to the opinion of the
     * <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a>. Alternatively, this method uses ``isUseAstronomicalChatzosForOtherZmanim()`` to control if the time is based on 6.5 <em>shaos zmaniyos</em> into the day
     * mentioned above, or as half an hour <em>zmaniyos</em> based on the second half of the day after <em>chatzos</em> (astronomical <em>chatzos</em> if supported by the calculator and configured or <em>chatzos</em> as half a day if not. This
     * method's synchronous parameter indicates if the start and end of day for the calculation are synchronous, having the same
     * offset. This is typically the case, but some <em>zmanim</em> calculations are based on a start and end at different offsets
     * from the real start and end of the day, such as starting the day at <em>alos</em> and an ending it at <em>tzais Geonim</em>
     * or some other variant. If the day is not synchronous a half-day based calculations will be bypassed. It would be illogical to use a half-day based calculation that start/end at <em>chatzos</em>
     * when the two "halves" of the day are not equal, and the halfway point between them is not at <em>chatzos</em>.
     *
     * @param startOfDay the start of day for calculating <em>Mincha gedola</em>. This can be sunrise or any <em>alos</em> passed
     *         to this method.
     * @param endOfDay the end of day for calculating <em>Mincha gedola</em>. This can be sunset or any <em>tzais</em> passed
     *         to this method.
     * @param synchronous If the <em>zman</em> has a synchronous start and end of the day. If this is `false`, using a
     *         ``isUseAstronomicalChatzosForOtherZmanim()`` makes no sense and will be ignored even if set to true, since by
     *         definition <em>chatzos</em> will not be the middle of the day for the <em>zman</em>.
     * @return the `Date` of the time of <em>Mincha gedola</em> based on the start and end of day times
     *         passed to this method. If the calculation can't be computed such as in the Arctic Circle where there is
     *         at least one day a year where the sun does not rise, and one where it does not set, a `nil` will
     *         be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getSunTransit()
     * @see getChatzosHayomAsHalfDay()
     * @see getChatzosHayom()
     * @see getChatzosHalayla()
     * @see isUseAstronomicalChatzos()
     * @see isUseAstronomicalChatzosForOtherZmanim()
     */
    public func getMinchaGedola(startOfDay: Date?, endOfDay: Date?, synchronous: Bool) -> Date? {
        if isUseAstronomicalChatzosForOtherZmanim() && synchronous {
            return getHalfDayBasedZman(startOfHalfDay: getChatzosHayom(), endOfHalfDay: endOfDay, hours: 0.5)
        } else {
            return getShaahZmanisBasedZman(startOfDay: startOfDay, endOfDay: endOfDay, hours: 6.5)
        }
    }

    /**
     * A generic method for calculating <em>mincha gedola</em> that calls ``getMinchaGedola()`` passing
     * `false` to the synchronous parameter since there is no way to know if the start and end of the day are
     * synchronous. Passing true when they are not synchronous is too much of a risk. See information on that method for more
     * details.
     * @param startOfDay the start of day for calculating <em>Mincha gedola</em>. This can be sunrise or any <em>alos</em> passed
     *         to this method.
     * @param endOfDay the end of day for calculating <em>Mincha gedola</em>. This can be sunset or any <em>tzais</em> passed to
     *         this method.
     * @return the `Date` of the latest <em>Mincha gedola</em> based on the start and end of day times passed to this
     *         method. If the calculation can't be computed such as in the Arctic Circle where there is at least one day
     *         a year where the sun does not rise, and one where it does not set, a `nil` will be returned. See
     *         detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getMinchaGedola(Instant, Instant, boolean)
     */
    public func getMinchaGedola(startOfDay: Date?, endOfDay: Date?) -> Date? {
        return getMinchaGedola(startOfDay: startOfDay, endOfDay: endOfDay, synchronous: false)
    }

    /**
     * This method returns the latest <em>mincha gedola</em>,the earliest time one can pray <em>mincha</em> that is 6.5 *
     * <em>shaos zmaniyos</em> (solar hours) after sunrise or
     * sea level sunrise (depending on the ``isUseElevation()`` setting), according
     * to the <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a>. <em>Mincha gedola</em> is the earliest
     * time one can pray <em>mincha</em>. The Ramba"m is of the opinion that it is better to delay <em>mincha</em> until
     * <em>mincha ketana GRA</em> while the Ra"sh, Tur, GRA and others are of the
     * opinion that <em>mincha</em> can be prayed <em>lechatchila</em> starting at <em>mincha gedola</em>.
     * The day is calculated from sea level sunrise to sea level sunset or sunrise to sunset (depending on the ``isUseElevation()``
     * setting).
     * @todo Consider adjusting this to calculate the time as half an hour <em>zmaniyos</em> after ``getChatzosHayom()``
     *         that uses ``isUseAstronomicalChatzos()`` to determine the type of <em>chatzos</em> to utilize (if the
     *         calculator support astronomical <em>chatzos</em>),
     *         based on the ``isUseAstronomicalChatzos()`` setting.
     * @see getMinchaGedola(Instant, Instant)
     * @see getShaahZmanisGRA()
     * @see getMinchaKetanaGRA()
     * @see ComprehensiveZmanimCalendar/getMinchaGedolaBaalHatanya()
     * @return the `Date` of the time of mincha gedola. If the calculation can't be computed such as in the
     *         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
     *         not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getMinchaGedolaGRA() -> Date? {
        return getMinchaGedola(startOfDay: getSunriseBasedOnElevationSetting(), endOfDay: getSunsetBasedOnElevationSetting(), synchronous: true)
    }

    /**
     * A generic method for calculating <em>samuch lemincha ketana</em>, / near <em>mincha ketana</em> time that is half
     * an hour before ``getMinchaKetana()``  or 9 * <em>shaos zmaniyos</em> (temporal hours) after the
     * start of the day, calculated using the start and end of the day passed to this method.
     * The time from the start of day to the end of day are divided into 12 <em>shaos zmaniyos</em> (temporal hours), and
     * <em>samuch lemincha ketana</em> is calculated as 9 of those <em>shaos zmaniyos</em> after the beginning of the day.
     * For example, passing sunrise and sunset or sea level sunrise and sea level sunset (depending on the ``isUseElevation()`` elevation
     * setting) to this method will return <em>samuch lemincha ketana</em> according to the opinion of the
     * <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a>. See the <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=60387&st=&pgnum=294">Mechaber and Mishna Berurah 232</a> and <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=60388&pgnum=34">249:2</a>.
     *
     * @param startOfDay the start of day for calculating <em>samuch lemincha ketana</em>. This can be sunrise or any <em>alos</em>
     *         passed to this method.
     * @param endOfDay the end of day for calculating <em>samuch lemincha ketana</em>. This can be sunset or any <em>tzais</em>
     *         passed to this method.
     * @param synchronous If the <em>zman</em> has a synchronous start and end of the day. If this is `false`, using a
     *         ``isUseAstronomicalChatzosForOtherZmanim()`` makes no sense and will be ignored even if set to true, since by
     *         definition <em>chatzos</em> will not be the middle of the day for the <em>zman</em>.
     * @return the `Date` of the time of <em>Mincha ketana</em> based on the start and end of day times
     *         passed to this method. If the calculation can't be computed such as in the Arctic Circle where there is
     *         at least one day a year where the sun does not rise, and one where it does not set, a `nil` will
     *         be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see ComprehensiveZmanimCalendar/getSamuchLeMinchaKetanaGRA()
     * @see ComprehensiveZmanimCalendar/getSamuchLeMinchaKetana16Point1Degrees()
     * @see ComprehensiveZmanimCalendar/getSamuchLeMinchaKetana72Minutes()
     */
    public func getSamuchLeMinchaKetana(startOfDay: Date?, endOfDay: Date?, synchronous: Bool) -> Date? {
        if isUseAstronomicalChatzosForOtherZmanim() && synchronous {
            return getHalfDayBasedZman(startOfHalfDay: getChatzosHayom(), endOfHalfDay: endOfDay, hours: 3)
        } else {
            return getShaahZmanisBasedZman(startOfDay: startOfDay, endOfDay: endOfDay, hours: 9)
        }
    }

    /**
     * A generic method for calculating <em>samuch lemincha ketana</em> that calls ``getSamuchLeMinchaKetana()``
     * passing `false` to the synchronous parameter since there is no way to know if the start and end of the day are
     * synchronous. Passing true when they are not synchronous is too much of a risk. See information on that method for more details.
     * @param startOfDay the start of day for calculating <em>samuch lemincha ketana</em>. This can be sunrise or any <em>alos</em>
     *         passed to this method.
     * @param endOfDay the end of day for calculating <em>samuch lemincha ketana</em>. This can be sunset or any <em>tzais</em>
     *         passed to this method.
     * @return the `Date` of the time of <em>samuch lemincha ketana</em> based on the start and end of day times
     *         passed to this method. If the calculation can't be computed such as in the Arctic Circle where there is
     *         at least one day a year where the sun does not rise, and one where it does not set, a `nil` will
     *         be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getSamuchLeMinchaKetana(Instant, Instant, boolean)
     */
    public func getSamuchLeMinchaKetana(startOfDay: Date?, endOfDay: Date?) -> Date? {
        return getSamuchLeMinchaKetana(startOfDay: startOfDay, endOfDay: endOfDay, synchronous: false)
    }

    /**
     * A generic method for calculating <em>mincha ketana</em>, (the preferred time to recite the mincha prayers in
     * the opinion of the <em><a href="https://en.wikipedia.org/wiki/Maimonides">Rambam</a></em> and others) that is
     * 9.5 * <em>shaos zmaniyos</em> (temporal hours) after the start of the day, calculated using the start and end
     * of the day passed to this method.
     * The time from the start of day to the end of day are divided into 12 <em>shaos zmaniyos</em> (temporal hours), and
     * <em>mincha ketana</em> is calculated as 9.5 of those <em>shaos zmaniyos</em> after the beginning of the day. As an
     * example, passing sunrise and sunset or sea level sunrise and sea level sunset (depending on the ``isUseElevation()``
     * elevation setting) to this method will return <em>mincha ketana</em> according to the opinion of the
     * <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a>. This method's synchronous parameter indicates if the start
     * and end of day for the calculation are synchronous, having the same offset. This is typically the case, but some
     * <em>zmanim</em> calculations are based on a start and end at different offsets from the real start and end of the day,
     * such as starting the day at <em>alos</em> and an ending it at <em>tzais Geonim</em> or some other variant. If the day
     * is not synchronous a half-day based calculations will be bypassed.
     * It would be illogical to use a half-day based calculation that start/end at <em>chatzos</em> when the two "halves" of
     * the day are not equal, and the halfway point between them is not at <em>chatzos</em>.
     *
     * @param startOfDay the start of day for calculating <em>Mincha ketana</em>. This can be sunrise or any <em>alos</em> passed
     *         to this method.
     * @param endOfDay the end of day for calculating <em>Mincha ketana</em>. This can be sunset or any <em>tzais</em> passed to
     *         this method.
     * @param synchronous If the <em>zman</em> has a synchronous start and end of the day. If this is `false`, using a
     *         ``isUseAstronomicalChatzosForOtherZmanim()`` makes no sense and will be ignored even if set to true, since by
     *         definition <em>chatzos</em> will not be the middle of the day for the <em>zman</em>.
     * @return the `Date` of the time of <em>Mincha ketana</em> based on the start and end of day times
     *         passed to this method. If the calculation can't be computed such as in the Arctic Circle where there is
     *         at least one day a year where the sun does not rise, and one where it does not set, a `nil` will
     *         be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getMinchaKetana(startOfDay: Date?, endOfDay: Date?, synchronous: Bool) -> Date? {
        if isUseAstronomicalChatzosForOtherZmanim() && synchronous {
            return getHalfDayBasedZman(startOfHalfDay: getChatzosHayom(), endOfHalfDay: endOfDay, hours: 3.5)
        } else {
            return getShaahZmanisBasedZman(startOfDay: startOfDay, endOfDay: endOfDay, hours: 9.5)
        }
    }

    /**
     * A generic method for calculating <em>mincha ketana</em> that calls ``getMinchaKetana()`` passing
     * `false` to the synchronous parameter since there is no way to know if the start and end of the day are synchronous.
     * Passing true when they are not synchronous is too much of a risk. See information on that method for more details.
     * @param startOfDay the start of day for calculating <em>Mincha ketana</em>. This can be sunrise or any <em>alos</em> passed
     *         to this method.
     * @param endOfDay the end of day for calculating <em>Mincha ketana</em>. This can be sunset or any <em>tzais</em> passed to
     *         this method.
     * @return the `Date` of the time of <em>Mincha ketana</em> based on the start and end of day times
     *         passed to this method. If the calculation can't be computed such as in the Arctic Circle where there is
     *         at least one day a year where the sun does not rise, and one where it does not set, a `nil` will
     *         be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getMinchaKetana(Instant, Instant, boolean)
     */
    public func getMinchaKetana(startOfDay: Date?, endOfDay: Date?) -> Date? {
        return getMinchaKetana(startOfDay: startOfDay, endOfDay: endOfDay, synchronous: false)
    }

    /**
     * This method returns <em>mincha ketana</em>,the preferred earliest time to pray <em>mincha</em> in the
     * opinion of the <em><a href="https://en.wikipedia.org/wiki/Maimonides">Rambam</a></em> and others, that is 9.5
     * * <em>shaos zmaniyos</em> (solar hours) after sunrise or
     * sea level sunrise (depending on the ``isUseElevation()`` setting), according
     * to the <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a>. For more information on this see the
     * documentation on <em>mincha gedola</em>.
     * The day is calculated from sea level sunrise to sea level sunset or from sunrise to sunset (depending on the ``isUseElevation()``
     * setting.
     *
     * @see getMinchaKetana(Instant, Instant)
     * @see getShaahZmanisGRA()
     * @see getMinchaGedolaGRA()
     * @see ComprehensiveZmanimCalendar/getMinchaKetanaBaalHatanya()
     * @return the `Date` of the time of mincha ketana. If the calculation can't be computed such as in the
     *         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
     *         not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getMinchaKetanaGRA() -> Date? {
        return getMinchaKetana(startOfDay: getSunriseBasedOnElevationSetting(), endOfDay: getSunsetBasedOnElevationSetting(), synchronous: true)
    }

    /**
     * A generic method for calculating <em>plag hamincha</em> (the earliest time that Shabbos can be started) that is
     * 10.75 hours after the start of the day, (or 1.25 hours before the end of the day) based on the start and end of
     * the day passed to the method.
     * The time from the start of day to the end of day are divided into 12 <em>shaos zmaniyos</em> (temporal hours), and
     * <em>plag hamincha</em> is calculated as 10.75 of those <em>shaos zmaniyos</em> after the beginning of the day. As an
     * example, passing sunrise and sunset or sea level sunrise and sea level sunset (depending on the ``isUseElevation()`` elevation
     * setting) to this method will return <em>plag mincha</em> according to the opinion of the
     * <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a>. This method's synchronous parameter indicates if the start
     * and end of day for the calculation are synchronous, having the same offset. This is typically the case, but some
     * <em>zmanim</em> calculations are based on a start and end at different offsets from the real start and end of the day,
     * such as starting the day at <em>alos</em> and an ending it at <em>tzais Geonim</em> or some other variant. If the day
     * is not synchronous a half-day based calculations will be bypassed. It
     * would be illogical to use a half-day based calculation that start/end at <em>chatzos</em> when the two "halves" of the
     * day are not equal, and the halfway point between them is not at <em>chatzos</em>.
     *
     * @param startOfDay the start of day for calculating <em>plag hamincha</em>. This can be sunrise or any <em>alos</em> passed to
     *         this method.
     * @param endOfDay the end of day for calculating <em>plag hamincha</em>. This can be sunset or any <em>tzais</em> passed to
     *         this method.
     * @param synchronous If the <em>zman</em> has a synchronous start and end of the day. If this is `false`, using a
     *         ``isUseAstronomicalChatzosForOtherZmanim()`` makes no sense and will be ignored even if set to true, since by
     *         definition <em>chatzos</em> will not be the middle of the day for the <em>zman</em>.
     * @return the `Date` of the time of <em>plag hamincha</em> based on the start and end of day times
     *         passed to this method. If the calculation can't be computed such as in the Arctic Circle where there is
     *         at least one day a year where the sun does not rise, and one where it does not set, a `nil`
     *         will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getPlagHamincha(startOfDay: Date?, endOfDay: Date?, synchronous: Bool) -> Date? {
        if isUseAstronomicalChatzosForOtherZmanim() && synchronous {
            return getHalfDayBasedZman(startOfHalfDay: getChatzosHayom(), endOfHalfDay: endOfDay, hours: 4.75)
        } else {
            return getShaahZmanisBasedZman(startOfDay: startOfDay, endOfDay: endOfDay, hours: 10.75)
        }
    }

    /**
     * A generic method for calculating <em>plag hamincha</em> that calls ``getPlagHamincha()`` passing
     * `false` to the synchronous parameter since there is no way to know if the start and end of the day are synchronous.
     * Passing true when they are not synchronous is too much of a risk. See information on that method for more details.
     * @param startOfDay the start of day for calculating <em>plag hamincha</em>. This can be sunrise or any <em>alos</em> passed to
     *         this method.
     * @param endOfDay the end of day for calculating <em>plag hamincha</em>. This can be sunset or any <em>tzais</em> passed to this
     *         method.
     * @return the `Date` of the time of <em>plag hamincha</em> based on the start and end of day times
     *         passed to this method. If the calculation can't be computed such as in the Arctic Circle where there is
     *         at least one day a year where the sun does not rise, and one where it does not set, a `nil`
     *         will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getPlagHamincha(Instant, Instant, boolean)
     */
    public func getPlagHamincha(startOfDay: Date?, endOfDay: Date?) -> Date? {
        return getPlagHamincha(startOfDay: startOfDay, endOfDay: endOfDay, synchronous: false)
    }

    /**
     * This method returns <em>plag hamincha</em>, that is 10.75 * <em>shaos zmaniyos</em>
     * (solar hours) after sunrise or sea level sunrise (depending on
     * the ``isUseElevation()`` setting), according to the <a href="https://en.wikipedia.org/wiki/Vilna_Gaon"
     * >GRA</a>. <em>Plag hamincha</em> is the earliest time that <em>Shabbos</em> can be started.
     * The day is calculated from sea level sunrise to sea level sunset or sunrise to sunset (depending on the ``isUseElevation()``
     *
     * @see getPlagHamincha(Instant, Instant, boolean)
     * @see getPlagHamincha(Instant, Instant)
     * @see ComprehensiveZmanimCalendar/getPlagHaminchaBaalHatanya()
     * @return the `Date` of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getPlagHaminchaGRA() -> Date? {
        return getPlagHamincha(startOfDay: getSunriseBasedOnElevationSetting(), endOfDay: getSunsetBasedOnElevationSetting(), synchronous: true)
    }

    /**
     * A method that returns a <em>shaah zmanis</em> (temporal hour) according to
     * the opinion of the <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a>. This calculation divides the day
     * based on the opinion of the <em>GRA</em> that the day runs from sea level sunrise to
     * sea level sunset or sunrise to sunset (depending
     * on the ``isUseElevation()`` setting). The day is split into 12 equal parts with each one being a <em>shaah zmanis</em>.
     * This method is similar to ``getTemporalHour()``, but can account for elevation.
     *
     * @return the `TimeInterval` of a <em>shaah zmanis</em> calculated from sunrise to sunset. If the calculation can't be
     *         computed such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
     *         where it does not set, a `nil` will be returned. See  detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getTemporalHour(Instant, Instant)
     * @see getSeaLevelSunrise()
     * @see getSeaLevelSunset()
     * @see ComprehensiveZmanimCalendar/getShaahZmanisBaalHatanya()
     */
    public func getShaahZmanisGRA() -> TimeInterval? {
        return getTemporalHour(startOfDay: getSunriseBasedOnElevationSetting(), endOfDay: getSunsetBasedOnElevationSetting())
    }

    /**
     * A utility method to return <em>alos</em> (dawn) or <em>tzais</em> (dusk) based on a fractional day offset. As an
     * example passing 1.5 to this method as done in the ``ComprehensiveZmanimCalendar/getTzais90Zmanis()`` will return
     * the time 90 minutes <em>zmaniyos</em> after ``getSunsetBasedOnElevationSetting()``, a <em>zman</em> known as
     * the <em>achtel zman</em> or 1/8th of the length of the day (12 * 60 = 720-minute day / 8 = 90 or 1.5 hours
     * <em>zmaniyos</em>) after sunset.
     * @param hours the number of <em>shaos zmaniyos</em> (temporal hours) before sunrise or after sunset that defines dawn
     *        or dusk. If a negative number is passed in, it will return the time of <em>alos</em> (dawn) (subtracting the
     *        time from sunrise) and if a positive number is passed in, it will return the time of <em>tzais</em> (dusk)
     *        (adding the time to sunset). If 0 is passed in, a `nil` will be returned (since we can't tell if it
     *        is sunrise or sunset based).
     * @return the `Date` representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
     *         a `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation. A `nil` will also be returned if 0 is passed in, since we can't tell if it is a
     *         sunrise or sunset based <em>zman</em>.
     * @see <a href="{@docRoot}/search.html?q=ComprehensiveZmanimCalendar%20Zmanis()">ComprehensiveZmanimCalendar...Zmanis()</a>
     * based <em>zmanim</em>.
     */
    public func getZmanisBasedOffset(hours: Double) -> Date? {
        let shaahZmanis: TimeInterval? = getShaahZmanisGRA()
        if shaahZmanis == nil || hours == 0 {
            return nil
        }

        let totalNanos = JavaMath.toLong((shaahZmanis! * 1_000_000_000) * hours)
        let offsetDuration: TimeInterval? = Double(totalNanos) / 1_000_000_000

        if hours > 0 {
            return AstronomicalCalendar.getTimeOffset(time: getSunsetBasedOnElevationSetting(), offset: offsetDuration)
        } else {
            return AstronomicalCalendar.getTimeOffset(time: getSunriseBasedOnElevationSetting(), offset: offsetDuration)
        }
    }

    /**
     * A method that returns a <em>shaah zmanis</em> (temporal hour) according to the opinion of the <em><a href=
     * "https://en.wikipedia.org/wiki/Avraham_Gombiner">Magen Avraham (MGA)</a></em> based on a 72-minute <em>alos</em>
     * and <em>tzais</em>. This calculation divides the day that runs from dawn to dusk (for <em>sof zman krias shema</em> and
     * <em>tfila</em>). Dawn for this calculation is 72 minutes before sunrise or sea level sunrise (depending on the ``isUseElevation()`` elevation setting) and dusk is 72 minutes after sunset or sea level sunset (depending on the ``isUseElevation()`` elevation
     * setting). This day is split into 12 equal parts with each part being a <em>shaah zmanis</em>. Alternate methods of calculating
     * a <em>shaah zmanis</em> according to the Magen Avraham (MGA) are available in the subclass ``ComprehensiveZmanimCalendar``.
     *
     * @return the `TimeInterval` of a <em>shaah zmanis</em>. If the calculation can't be computed
     *         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
     *         where it does not set, a `nil` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getShaahZmanis72Minutes() -> TimeInterval? {
        return getTemporalHour(startOfDay: getAlos72Minutes(), endOfDay: getTzais72Minutes())
    }

    /**
     * Default constructor will set a default ``GeoLocation/GeoLocation()``, a default
     * AstronomicalCalculator and default the calendar to the current date.
     *
     * @see AstronomicalCalendar/AstronomicalCalendar()
     */
    // init() is inherited from AstronomicalCalendar

    /**
     * A constructor that takes a ``GeoLocation`` as a parameter.
     *
     * @param location the location
     */
    public required init(geoLocation: GeoLocation) {
        super.init(geoLocation: geoLocation)
    }

    /**
     * A constructor that takes a ``GeoLocation`` as a parameter. This is the same as ``init(geoLocation:)``.
     *
     * @param location the location
      */
    public convenience init(location: GeoLocation) {
        self.init(geoLocation: location)
    }

    /**
     * A method to get the offset in minutes before sea level sunset which
     * is used in calculating candle lighting time. The default time used is 18 minutes before sea level sunset. Some
     * calendars use 15 minutes, while the custom in Jerusalem is to use a 40-minute offset. Please check the local custom
     * for candle lighting time.
     *
     * @return Returns the currently set candle lighting offset in minutes.
     * @see getCandleLighting()
     * @see setCandleLightingOffset(double)
     */
    public func getCandleLightingOffset() -> Double {
        return candleLightingOffset
    }

    /**
     * A method to set the offset in minutes before sea level sunset that is
     * used in calculating candle lighting time. The default time used is 18 minutes before sunset. Some calendars use 15
     * minutes, while the custom in Jerusalem is to use a 40-minute offset.
     *
     * @param candleLightingOffset The candle lighting offset to set in minutes.
     * @see getCandleLighting()
     * @see getCandleLightingOffset()
     */
    public func setCandleLightingOffset(candleLightingOffset: Double) {
        self.candleLightingOffset = candleLightingOffset
    }

    /**
     * This is a utility method to determine if the current Instant passed in has a <em>melacha</em> (work) prohibition.
     * Since there are many opinions on the time of <em>tzais</em>, the <em>tzais</em> for the current day has to be passed to this
     * class. Sunset is the classes current day's elevation adjusted sunset that observes the
     * ``isUseElevation()`` settings. The ``JewishCalendar/getInIsrael()`` will be set by the inIsrael parameter. Since there
     * is no consensus on the day boundaries in polar regions, if a boundary needed for the date (sunset on <em>erev Shabbos</em> or
     * <em>Yom Tov</em>, <em>tzais</em> on <em>Shabbos</em> or <em>Yom Tov</em>) can't be determined, `nil` is returned rather
     * than guessing, and a ``KosherSwiftWarnings`` warning is reported (KosherJava throws an IllegalStateException).
     *
     * @param currentTime the current time
     * @param tzais the time of tzais
     * @param inIsrael whether to use Israel holiday scheme or not
     * @return true if <em>melacha</em> is prohibited or false if it is not.
     * @return `nil` if sunset (on <em>erev Shabbos</em> or <em>Yom Tov</em>) or <em>tzais</em> (on <em>Shabbos</em>
     *         or <em>Yom Tov</em>) is needed but can't be determined, such as in polar regions.
     * @see JewishCalendar/isAssurBemelacha()
     * @see JewishCalendar/hasCandleLighting()
     * @see JewishCalendar/setInIsrael(boolean)
     */
    public func isAssurBemelacha(currentTime: Date, tzais: Date?, inIsrael: Bool) -> Bool? {
        let jewishCalendar = JewishCalendar(localDate: getLocalDate())

        jewishCalendar.setInIsrael(inIsrael: inIsrael)

        let needsSunset = jewishCalendar.hasCandleLighting() // erev shabbos, YT or YT sheni
        let needsTzais = jewishCalendar.isAssurBemelacha() // shabbos or YT
        let sunset: Date? = needsSunset ? getSunsetBasedOnElevationSetting() : nil

        let noSunset = needsSunset && sunset == nil
        let noTzais = needsTzais && tzais == nil
        if noSunset || (noTzais && (sunset == nil || currentTime.isBefore(sunset!))) { // tzais is irrelevant once past shkiah on erev Shabbos/Yom Tov
            let missing = noSunset && noTzais ? "sunset and tzais" : noSunset ? "sunset" : "tzais"
            KosherSwiftWarnings.report("\(missing) can't be determined for \(getLocalDate()) at \(getGeoLocation().getLocationName()), "
                                       + "so whether melacha is prohibited can't be determined; returning nil")
            return nil
        }

        if needsSunset && !currentTime.isBefore(sunset!) { // after shkiah
            return true
        }
        return needsTzais && !currentTime.isAfter(tzais!) // before tzais
    }

    /**
     * A method that returns the <a href="https://en.wikipedia.org/wiki/Shneur_Zalman_of_Liadi">Baal Hatanya</a>'s <em>netz amiti</em>
     * (sunrise) without ``AstronomicalCalculator/getElevationAdjustment()``. This forms the base for the Baal Hatanya's
     * dawn-based calculations that are calculated as a dip below the horizon before sunrise. According to the Baal Hatanya, <em>netz
     * amiti</em>, or true (halachic) sunrise, is when the top of the sun's disk is visible at an elevation similar to the mountains
     * of Eretz Yisrael. The time is calculated as the point at which the center of the sun's disk is 1.583° below the horizon. This
     * degree-based calculation can be found in Rabbi Shalom DovBer Levine's commentary on The <a href=
     * "https://www.chabadlibrary.org/books/pdf/Seder-Hachnosas-Shabbos.pdf">Baal Hatanya's Seder Hachnasas Shabbos</a>. From an
     * elevation of 546 meters, the top of <a href="https://en.wikipedia.org/wiki/Mount_Carmel">Har Hacarmel</a>, the sun disappears
     * when it is 1° 35' or 1.583° below the sea level horizon. This in turn is based on the Gemara <a href=
     * "https://hebrewbooks.org/shas.aspx?mesechta=2&daf=35">Shabbos 35a</a>. There are other opinions brought down by Rabbi Levine,
     * including Rabbi Yosef Yitzchok Feigelstock who calculates it as the degrees below the horizon 4 minutes after sunset in
     * Yerushalayim (on the equinox). That is brought down as 1.583°. This is identical to the 1° 35' <em>zman</em> and is probably a
     * typo and should be 1.683°. These calculations are used by most <a href="https://en.wikipedia.org/wiki/Chabad">Chabad</a>
     * calendars that use the Baal Hatanya's <em>zmanim</em>. See
     * <a href="https://www.chabad.org/library/article_cdo/aid/3209349/jewish/About-Our-Zmanim-Calculations.htm">About Our
     * <em>Zmanim</em> Calculations @ Chabad.org</a>.
     *
     * Note: <em>netz amiti</em> is used only for calculating certain <em>zmanim</em>, and is intentionally unpublished. For
     * practical purposes, daytime <em>mitzvos</em> like <em>shofar</em> and <em>lulav</em> should not be done until after the
     * published time for <em>netz</em> / sunrise.
     *
     * @return the `Date` representing the exact sea level <em>netz amiti</em> (sunrise) time. If the calculation can't
     *         be computed such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
     *         where it does not set, a `nil` will be returned. See detailed explanation on top of the page.
     * @see getSunrise()
     * @see getSeaLevelSunrise()
     * @see getSunsetBaalHatanya()
     * @see ZENITH_1_POINT_583
     */
    public func getSunriseBaalHatanya() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ZmanimCalendar.ZENITH_1_POINT_583)
    }

    /**
     * A method that returns the <a href="https://en.wikipedia.org/wiki/Shneur_Zalman_of_Liadi">Baal Hatanya</a>'s <em>shkiah
     * amiti</em> (sunset) without elevation adjustment. This forms
     * the base for the Baal Hatanya's dusk-based calculations that are calculated as a dip below the horizon after sunset. According
     * to the Baal Hatanya, <em>shkiah amiti</em>, true (<em>halachic</em>) sunset, is when the top of the sun's disk disappears from
     * view at an elevation similar to the mountains of <em>Eretz Yisrael</em>. This time is calculated as the point at which the
     * center of the sun's disk is 1.583° below the horizon.
     *
     * Note: <em>shkiah amiti</em> is used only for calculating certain <em>zmanim</em>, and is intentionally unpublished. For
     * practical purposes, all daytime mitzvos should be completed before the published time for <em>shkiah</em> / sunset. For further
     * explanation of the calculations used for the Baal Hatanya's <em>zmanim</em> in this library, see <a href=
     * "https://www.chabad.org/library/article_cdo/aid/3209349/jewish/About-Our-Zmanim-Calculations.htm">About Our <em>Zmanim</em>
     * Calculations @ Chabad.org</a>.
     *
     * @return the `Date` representing the exact sea level <em>shkiah amiti</em> (sunset) time. If the calculation can't
     *         be computed such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
     *         where it does not set, a `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getSunset()
     * @see getSeaLevelSunset()
     * @see getSunriseBaalHatanya()
     * @see ZENITH_1_POINT_583
     */
    public func getSunsetBaalHatanya() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ZmanimCalendar.ZENITH_1_POINT_583)
    }

    /**
     * A generic utility method for calculating any <em>shaah zmanis</em> (temporal hour) based <em>zman</em> with the day
     * defined as the start and end of day (or night) and the number of <em>shaos zmaniyos</em> passed to the method. This
     * simplifies the code in other methods such as ``getPlagHamincha()`` and cuts down on code replication.
     * As an example, passing sunrise and sunset or sea level sunrise and sea level sunset (depending on the ``isUseElevation()`` elevation setting) and 10.75 hours to this method will return <em>plag mincha</em> according to the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a>.
     *
     * @param startOfDay the start of day for calculating the <em>zman</em>. This can be sunrise or any <em>alos</em> passed to
     *         this method.
     * @param endOfDay the end of day for calculating the <em>zman</em>. This can be sunset or any <em>tzais</em> passed to this
     *         method.
     * @param hours the number of <em>shaos zmaniyos</em> (temporal hours) to offset from the start of day
     * @return the `Date` of the time of <em>zman</em> with the <em>shaos zmaniyos</em> (temporal hours)
     *         in the day offset from the start of day passed to this method. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
     *         where it does not set, a `nil` will be  returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getShaahZmanisBasedZman(startOfDay: Date?, endOfDay: Date?, hours: Double) -> Date? {
        let shaahZmanis: TimeInterval? = getTemporalHour(startOfDay: startOfDay, endOfDay: endOfDay)
        if shaahZmanis == nil { //defensive, should not be needed
            return nil
        }

        let totalNanos = JavaMath.toLong((shaahZmanis! * 1_000_000_000) * hours)
        return AstronomicalCalendar.getTimeOffset(time: startOfDay, offset: Double(totalNanos) / 1_000_000_000)
    }

    /**
     * A utility method that returns the percentage of a <em>shaah zmanis</em> after sunset (or before sunrise) for a given degree
     * offset. For the <a href="https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">equilux</a> where there
     * is a 720-minute day, passing 16.1° for the location of Jerusalem will return about 1.2. This will work for any location or
     * date, but will typically only be of interest at the equinox/equilux to calculate the percentage of a <em>shaah zmanis</em> for
     * those who want to use the <a href="https://en.wikipedia.org/wiki/Abraham_Cohen_Pimentel">Minchas Cohen</a> in Ma'amar 2:4 and
     * the <a href="https://en.wikipedia.org/wiki/Hezekiah_da_Silva">Pri Chadash</a> who calculate <em>tzais</em> as a percentage of
     * the day after sunset. While the Minchas Cohen only applies this to 72 minutes or a 1/10 of the day around the world (based on
     * the equinox / equilux in Israel), this method allows calculations for any degree level for any location.
     *
     * @param degrees the number of degrees below the horizon after sunset.
     * @param sunset if `true` the calculation is in degrees after sunset, otherwise it is degrees before sunrise.
     * @return the `double` percentage of a <em>sha'ah zmanis</em> for a given set of degrees below the astronomical horizon
     *         for the current calendar.  If the calculation can't be computed a ``Double/MIN_VALUE`` will be returned. See detailed
     *         explanation on top of the page.
     */
    public func getPercentOfShaahZmanisFromDegrees(degrees: Double, sunset: Bool) -> Double {
        let seaLevelSunrise: Date? = getSeaLevelSunrise()
        let seaLevelSunset: Date? = getSeaLevelSunset()
        var twilight: Date?
        if sunset {
            twilight = getSunsetOffsetByDegrees(offsetZenith: AstronomicalCalendar.GEOMETRIC_ZENITH + degrees)
        } else {
            twilight = getSunriseOffsetByDegrees(offsetZenith: AstronomicalCalendar.GEOMETRIC_ZENITH + degrees)
        }
        if seaLevelSunrise == nil || seaLevelSunset == nil || twilight == nil {
            return Double.leastNonzeroMagnitude
        }
        let shaahZmanis = Double(JavaMath.toEpochMilli(seaLevelSunset!) - JavaMath.toEpochMilli(seaLevelSunrise!)) / 12.0
        var riseSetToTwilight: Int64
        if sunset {
            riseSetToTwilight = JavaMath.toEpochMilli(twilight!) - JavaMath.toEpochMilli(seaLevelSunset!)
        } else {
            riseSetToTwilight = JavaMath.toEpochMilli(seaLevelSunrise!) - JavaMath.toEpochMilli(twilight!)
        }
        return Double(riseSetToTwilight) / shaahZmanis
    }

    /**
     * A utility method to calculate <em>zmanim</em> based on <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe
     * Feinstein</a> and others as calculated in <a href="https://en.wikipedia.org/wiki/Mesivtha_Tifereth_Jerusalem">MTJ</a>, <a href=
     * "https://en.wikipedia.org/wiki/Mesivtha_Tifereth_Jerusalem">Yeshiva of Staten Island</a>, and Camp Yeshiva
     * of Staten Island and other calendars. The day is split in two, from <em>alos</em> / sunrise to <em>chatzos</em>, and the
     * second half of the day, from <em>chatzos</em> to sunset / <em>tzais</em>. Morning based times are calculated. based on the first
     * 6 hours of the day, and afternoon times based on the second half of the day. As an example, passing 0.5, a start of
     * <em>chatzos</em> and an end of day as sunset will return the time of <em>mincha gedola</em> GRA as half an hour <em>zmanis</em>
     * based on the second half of the day. Some <em>zmanim</em> calculations can be based on subtracting <em>shaos zmaniyos</em>
     * from the end of the day, and that is supported by passing a negative hour to this method.
     *
     * @param startOfHalfDay The start of the half day. This would be <em>alos</em> or sunrise for morning based times such as
     *         <em>sof zman krias shema</em> and <em>chatzos</em> for afternoon based times such as <em>mincha gedola</em>.
     * @param endOfHalfDay The end of the half day. This would be <em>chatzos</em> for morning based times  such as <em>sof zman
     *         krias shema</em>  and sunset or <em>tzais</em> for afternoon based times such as <em>mincha gedola</em>.
     * @param hours The number of <em>shaos zmaniyos</em> (hours) to offset the beginning of the first or second half of the day. For
     *         example, 3 for <em>sof zman Shma</em>, 0.5 for <em>mincha gedola</em> (half an hour after <em>chatzos</em>) and 4.75
     *         for <em>plag hamincha</em>. If the number of hours is negative, it will subtract the number of <em>shaos zmaniyos</em>
     *         from the end of the day.
     * @return the `Date` of <em>zman</em> based on calculation of the first or second half of the day. If the
     *         calculation can't be computed such as in the Arctic Circle where there is at least one day a year where the
     *         sun does not rise, and one where it does not set, a `nil` will be returned. See detailed explanation
     *         on top of the ``AstronomicalCalendar`` documentation.
     * @see ComprehensiveZmanimCalendar/getFixedLocalChatzosHayom()
     */
    public func getHalfDayBasedZman(startOfHalfDay: Date?, endOfHalfDay: Date?, hours: Double) -> Date? {
        if startOfHalfDay == nil || endOfHalfDay == nil {
            return nil
        }
        let shaahZmanis: TimeInterval? = getHalfDayBasedShaahZmanis(startOfHalfDay: startOfHalfDay, endOfHalfDay: endOfHalfDay)
        if shaahZmanis == nil { //defensive, should not be needed
            return nil
        }

        let totalNanos = JavaMath.toLong((shaahZmanis! * 1_000_000_000) * hours)
        let offsetDuration: TimeInterval? = Double(totalNanos) / 1_000_000_000

        if hours >= 0 { // forward from start of day
            return AstronomicalCalendar.getTimeOffset(time: startOfHalfDay, offset: offsetDuration)
        } else { // subtract from end of day
            return AstronomicalCalendar.getTimeOffset(time: endOfHalfDay, offset: offsetDuration)
        }
    }

    /**
     * A utility method to calculate the length of a <em>sha'ah zmanis</em> based on 1/6 of a 6-hour day.
     * @param startOfHalfDay The start of the half-day. This would be <em>alos</em> or sunrise for the first half of the day, or
     *         <em>chatzos</em> for the second half of the day.
     * @param endOfHalfDay The end of the half-day. This would be <em>chatzos</em> for the first half of the day, or sunset or
     *         <em>tzais</em> for the second half of the day.
     * @return The `TimeInterval` of a <em>shaah zmanis</em> based on 1/6 of a half-day. If the calculation can't be computed
     *         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
     *         not set, a `nil` will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see getHalfDayBasedZman(Instant, Instant, double)
     * @see isUseAstronomicalChatzosForOtherZmanim()
     * @todo Consider adjusting various shaah zmanis times to use this.
     */
    public func getHalfDayBasedShaahZmanis(startOfHalfDay: Date?, endOfHalfDay: Date?) -> TimeInterval? {
        if startOfHalfDay == nil || endOfHalfDay == nil {
            return nil
        }
        return endOfHalfDay!.timeIntervalSince(startOfHalfDay!) / 6
    }

    /// True if the other calendar is the same class with the same date, location, calculator and settings.
    public override func equals(_ other: AstronomicalCalendar) -> Bool {
        guard super.equals(other), let that = other as? ZmanimCalendar else {
            return false
        }
        return useElevation == that.useElevation
            && useAstronomicalChatzos == that.useAstronomicalChatzos
            && useAstronomicalChatzosForOtherZmanim == that.useAstronomicalChatzosForOtherZmanim
            && candleLightingOffset == that.candleLightingOffset
    }

    override func copyState(to copy: AstronomicalCalendar) {
        super.copyState(to: copy)
        if let copy = copy as? ZmanimCalendar {
            copy.useElevation = useElevation
            copy.useAstronomicalChatzos = useAstronomicalChatzos
            copy.useAstronomicalChatzosForOtherZmanim = useAstronomicalChatzosForOtherZmanim
            copy.candleLightingOffset = candleLightingOffset
        }
    }

    override func getFormattableValues() -> [(String, ZmanimFormatter.Value)] {
        return super.getFormattableValues() + [
            ("getAlos16Point1Degrees", .date(getAlos16Point1Degrees())),
            ("getAlos72Minutes", .date(getAlos72Minutes())),
            ("getCandleLighting", .date(getCandleLighting())),
            ("getChatzosHalayla", .date(getChatzosHalayla())),
            ("getChatzosHayom", .date(getChatzosHayom())),
            ("getChatzosHayomAsHalfDay", .date(getChatzosHayomAsHalfDay())),
            ("getMinchaGedolaGRA", .date(getMinchaGedolaGRA())),
            ("getMinchaKetanaGRA", .date(getMinchaKetanaGRA())),
            ("getPlagHaminchaGRA", .date(getPlagHaminchaGRA())),
            ("getShaahZmanis72Minutes", .duration(getShaahZmanis72Minutes())),
            ("getShaahZmanisGRA", .duration(getShaahZmanisGRA())),
            ("getSofZmanShmaGRA", .date(getSofZmanShmaGRA())),
            ("getSofZmanShmaMGA72Minutes", .date(getSofZmanShmaMGA72Minutes())),
            ("getSofZmanTfilaGRA", .date(getSofZmanTfilaGRA())),
            ("getSofZmanTfilaMGA72Minutes", .date(getSofZmanTfilaMGA72Minutes())),
            ("getTzais72Minutes", .date(getTzais72Minutes())),
            ("getTzaisGeonim8Point5Degrees", .date(getTzaisGeonim8Point5Degrees())),
        ]
    }
}
