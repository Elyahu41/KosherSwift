//
//  ComplexZmanimCalendar.swift
//  KosherSwift
//
//  Created by Elyahu Jacobi on 12/21/23.
//

import Foundation

/**
 * This class extends ZmanimCalendar and provides many more <em>zmanim</em> than available in the ZmanimCalendar. The basis
 * for most <em>zmanim</em> in this class are from the <em>sefer</em> <b><a href="https://hebrewbooks.org/9765">Yisroel
 * Vehazmanim</a></b> by <b><a href="https://en.wikipedia.org/wiki/Yisroel_Dovid_Harfenes">Rabbi Yisrael Dovid Harfenes</a></b>.
 * As an example of the number of different <em>zmanim</em> made available by this class, there are methods to return 18
 * different calculations for <em>alos</em> (dawn), 18 for <em>plag hamincha</em> and 29 for <em>tzais</em> available in this
 * API. The real power of this API is the ease in calculating <em>zmanim</em> that are not part of the library. The methods for
 * <em>zmanim</em> calculations not present in this class or it's superclass  ``ZmanimCalendar`` are contained in the
 * ``AstronomicalCalendar``, the base class of the calendars in our API since they are generic methods for calculating
 * time based on degrees or time before or after ``getSunrise()``  and ``getSunset()`` sunset and are of interest
 * for calculation beyond <em>zmanim</em> calculations. Here are some examples.
 * First create the Calendar for the location you would like to calculate:
 * let locationName = &quot;Lakewood, NJ&quot;;
 * let latitude = 40.0828; // Lakewood, NJ
 * let longitude = -74.222; // Lakewood, NJ
 * let elevation = 20; // optional elevation correction in Meters
 * // the String parameter in getTimeZone() has to be a valid timezone listed in
 * // ``TimeZone.knownTimeZoneIdentifiers``
 * let timeZone = TimeZone(identifier:&quot;America/New_York&quot;);
 * let location = GeoLocation(locationName, latitude, longitude, elevation, timeZone);
 * let czc = new ComplexZmanimCalendar(location);
 * // Optionally set the date or it will default to today's date
 * To get <em>alos</em> calculated as 14&deg; below the horizon (as calculated in the calendars published in Montreal),
 * add `` AstronomicalCalendar#GEOMETRIC_ZENITH`` (90) to the 14&deg; offset to get the desired time:
 * Date alos14 = czc.getSunriseOffsetByDegrees(`` AstronomicalCalendar#GEOMETRIC_ZENITH`` + 14);
 * To get <em>mincha gedola</em> calculated based on the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> using a <em>shaah zmanis</em> based on the day starting
 * 16.1&deg; below the horizon (and ending 16.1&deg; after sunset) the following calculation can be used:
 * or even simpler using the included convenience methods
 * Date minchaGedola = czc.getMinchaGedola(czc.getAlos16point1Degrees(), czc.getShaahZmanis16Point1Degrees());</pre>
 * A little more complex example would be calculating <em>zmanim</em> that rely on a <em>shaah zmanis</em> that is
 * not present in this library. While a drop more complex, it is still rather easy. An example would be to calculate
 * the <a href="https://en.wikipedia.org/wiki/Israel_Isserlein">Trumas Hadeshen</a>'s <em>alos</em> to
 * <em>tzais</em> based <em>plag hamincha</em> as calculated in the Machzikei Hadass calendar in Manchester, England.
 * A number of this calendar's <em>zmanim</em> are calculated based on a day starting at <em>alos</em> of 12&deg; before
 * sunrise and ending at <em>tzais</em> of 7.083&deg; after sunset. Be aware that since the <em>alos</em> and <em>tzais</em>
 * do not use identical degree-based offsets, this leads to <em>chatzos</em> being at a time other than the
 * ``getSunTransit()`` solar transit(solar midday). To calculate this <em>zman</em>, use the following steps. Note
 * that <em>plag hamincha</em> is 10.75 hours after the start of the day, and the following steps are all that it takes.
 * Date plag = czc.getPlagHamincha(czc.getSunriseOffsetByDegrees(``AstronomicalCalendar#GEOMETRIC_ZENITH`` + 12),
 *                 czc.getSunsetOffsetByDegrees(``AstronomicalCalendar#GEOMETRIC_ZENITH`` + ZENITH_7_POINT_083));
 * Something a drop more challenging, but still simple, would be calculating a <em>zman</em> using the same "complex"
 * offset day used in the above mentioned Manchester calendar, but for a <em>shaos zmaniyos</em> based <em>zman</em> not
 * supported by this library, such as calculating the point that one should be <em>makpid</em>
 * not to eat on <em>erev Shabbos</em> or <em>erev Yom Tov</em>. This is 9 <em>shaos zmaniyos</em> into the day.
 * Calculate the <em>shaah zmanis</em> in milliseconds for this day.
 * Add 9 of these <em>shaos zmaniyos</em> to <em>alos</em> starting at 12&deg;
 * Calculating this <em>sof zman achila</em> according to the <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a>
 * is simplicity itself. Keep in mind that Swift does not use milliseconds for their date objects. If you get in a situation where you only have TimeIntervals (seconds), just multiply that amount by 1000 to get milliseconds.
 *
 * @author &copy; Eliyahu Hershfeld 2004 - 2023
 */
public class ComplexZmanimCalendar : ZmanimCalendar {
    
    /**
     * The zenith of 3.7&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for
     * calculating <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> that <em>tzais</em> is the
     * time it takes to walk 3/4 of a <em>Mil</em> at 18 minutes a <em>Mil</em>, or 13.5 minutes after sunset. The sun
     * is 3.7&deg; below ``GEOMETRIC_ZENITH`` at this time in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>.
     *
     * @see getTzaisGeonim3Point7Degrees()
     */
    public static let ZENITH_3_POINT_7 = Double(GEOMETRIC_ZENITH + 3.7);
    
    /**
     * The zenith of 3.8&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for
     * calculating <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> that <em>tzais</em> is the
     * time it takes to walk 3/4 of a <em>Mil</em> at 18 minutes a <em>Mil</em>, or 13.5 minutes after sunset. The sun
     * is 3.8&deg; below ``GEOMETRIC_ZENITH`` at this time in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>.
     *
     * @see getTzaisGeonim3Point8Degrees()
     */
    public static let ZENITH_3_POINT_8 = Double(GEOMETRIC_ZENITH + 3.8);
    
    /**
     * The zenith of 5.95&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for
     * calculating <em>tzais</em> (nightfall) according to some opinions. This calculation is based on the position of
     * the sun 24 minutes after sunset in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>,
     * which calculates to 5.95&deg; below ``GEOMETRIC_ZENITH``.
     *
     * @see getTzaisGeonim5Point95Degrees()
     */
    public static let ZENITH_5_POINT_95 = Double(GEOMETRIC_ZENITH + 5.95);
    
    /**
     * The zenith of 7.083&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This is often referred to as
     * 7&deg;5' or 7&deg; and 5 minutes. This calculation is used for calculating <em>alos</em> (dawn) and
     * <em>tzais</em> (nightfall) according to some opinions. This calculation is based on observation of 3 medium sized
     * stars by Dr. Baruch Cohen in his calendar published in in 1899 in Strasbourg, France. This calculates to
     * 7.0833333&deg; below ``GEOMETRIC_ZENITH``. The <a href="https://hebrewbooks.org/1053">Sh"Ut
     * Melamed Leho'il</a> in Orach Chaim 30 agreed to this <em>zman</em>, as did the Sh"Ut Bnei Tziyon, Tenuvas Sadeh and
     * it is very close to the time of the <a href="https://hebrewbooks.org/22044">Mekor Chesed</a> of the Sefer chasidim.
     * It is close to the position of the sun 30 minutes after sunset in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>, but not
     * Exactly. The actual position of the sun 30 minutes after sunset in Jerusalem at the equilux is 7.205&deg; and
     * 7.199&deg; at the equinox. See Hazmanim Bahalacha vol 2, pages 520-521 for details.
     * @todo Hyperlink the proper sources.
     *
     * @see getTzaisGeonim7Point083Degrees()
     * @see getBainHashmashosRT13Point5MinutesBefore7Point083Degrees()
     */
    public static let ZENITH_7_POINT_083 = Double(GEOMETRIC_ZENITH + 7 + (5.0 / 60));
    
    /**
     * The zenith of 10.2&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for
     * calculating <em>misheyakir</em> according to some opinions. This calculation is based on the position of the sun
     * 45 minutes before ``getSunrise()`` in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a> which
     * calculates to 10.2&deg; below ``GEOMETRIC_ZENITH``.
     *
     * @see getMisheyakir10Point2Degrees()
     */
    public static let ZENITH_10_POINT_2 = Double(GEOMETRIC_ZENITH + 10.2);
    
    /**
     * The zenith of 11&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for
     * calculating <em>misheyakir</em> according to some opinions. This calculation is based on the position of the sun
     * 48 minutes before ``getSunrise()`` in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>, which
     * calculates to 11&deg; below ``GEOMETRIC_ZENITH``.
     *
     * @see getMisheyakir11Degrees()
     */
    public static let ZENITH_11_DEGREES = Double(GEOMETRIC_ZENITH + 11);
    
    /**
     * The zenith of 11.5&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for
     * calculating <em>misheyakir</em> according to some opinions. This calculation is based on the position of the sun
     * 52 minutes before ``getSunrise`` in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>, which
     * calculates to 11.5&deg; below ``GEOMETRIC_ZENITH``.
     *
     * @see getMisheyakir11Point5Degrees()
     */
    public static let ZENITH_11_POINT_5 = Double(GEOMETRIC_ZENITH + 11.5);
    
    /**
     * The zenith of 13.24&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for
     * calculating Rabbeinu Tam's <em>bain hashmashos</em> according to some opinions.
     * NOTE: See comments on ``getBainHashmashosRT13Point24Degrees`` for additional details about the degrees.
     *
     * @see getBainHashmashosRT13Point24Degrees
     *
     */
    public static let ZENITH_13_POINT_24 = Double(GEOMETRIC_ZENITH + 13.24);
    
    /**
     * The zenith of 19&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for
     * calculating <em>alos</em> according to some opinions.
     *
     * @see getAlos19Degrees()
     * @see ZENITH_19_POINT_8
     */
    public static let ZENITH_19_DEGREES = Double(GEOMETRIC_ZENITH + 19);
    
    /**
     * The zenith of 19.8&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for
     * calculating <em>alos</em> (dawn) and <em>tzais</em> (nightfall) according to some opinions. This calculation is
     * based on the position of the sun 90 minutes after sunset in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a> which
     * calculates to 19.8&deg; below ``GEOMETRIC_ZENITH``.
     *
     * @see getTzais19Point8Degrees()
     * @see getAlos19Point8Degrees()
     * @see getAlos90()
     * @see getTzais90()
     * @see ZENITH_19_DEGREES
     */
    public static let ZENITH_19_POINT_8 = Double(GEOMETRIC_ZENITH + 19.8);
    
    /**
     * The zenith of 26&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for
     * calculating <em>alos</em> (dawn) and <em>tzais</em> (nightfall) according to some opinions. This calculation is
     * based on the position of the sun ``getAlos120() 120 minutes`` after sunset in Jerusalem o<a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a> which
     * calculates to 26&deg; below ``GEOMETRIC_ZENITH``. Since the level of darkness when the sun is
     * 26&deg; and at a point when the level of darkness is long past the 18&deg; point where the darkest point is reached,
     * it should only be used <em>lechumra</em> such as delaying the start of nighttime <em>mitzvos</em> or avoiding eating
     * this early on a fast day.
     *
     * @see getAlos26Degrees()
     * @see getTzais26Degrees()
     * @see getAlos120()
     * @see getTzais120()
     */
    public static let ZENITH_26_DEGREES = Double(GEOMETRIC_ZENITH + 26.0);
    
    /**
     * The zenith of 4.37&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for
     * calculating <em>tzais</em> (nightfall) according to some opinions. This calculation is based on the position of
     * the sun ``getTzaisGeonim4Point37Degrees()`` 16 7/8 minutes after sunset (3/4 of a 22.5-minute <em>Mil</em>)
     * in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>,
     * which calculates to 4.37&deg; below ``GEOMETRIC_ZENITH``.
     *
     * @see getTzaisGeonim4Point37Degrees()
     */
    public static let ZENITH_4_POINT_37 = Double(GEOMETRIC_ZENITH + 4.37);
    
    /**
     * The zenith of 4.61&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for
     * calculating <em>tzais</em> (nightfall) according to some opinions. This calculation is based on the position of
     * the sun ``getTzaisGeonim4Point37Degrees()`` 18 minutes after sunset (3/4 of a 24-minute <em>Mil</em>) in
     * Jerusalem <a href="https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox
     * / equilux</a>, which calculates to 4.61&deg; below ``GEOMETRIC_ZENITH``.
     * @todo add documentation links
     *
     * @see getTzaisGeonim4Point61Degrees()
     */
    public static let ZENITH_4_POINT_61 = Double(GEOMETRIC_ZENITH + 4.61);
    
    /**
     * The zenith of 4.8&deg; below ``GEOMETRIC_ZENITH`` (90&deg;).
     * @todo Add more documentation.
     * @see getTzaisGeonim4Point8Degrees()
     */
    public static let ZENITH_4_POINT_8 = Double(GEOMETRIC_ZENITH + 4.8);
            
    /**
     * The zenith of 5.88&deg; below ``GEOMETRIC_ZENITH`` (90&deg;).
     * @todo Add more documentation.
     */
    public static let ZENITH_5_POINT_88 = Double(GEOMETRIC_ZENITH + 5.88);
    
    /**
     * The zenith of 1.583&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for
     * calculating <em>netz amiti</em> (sunrise) and <em>shkiah amiti</em> (sunset) based on the opinion of the
     * <a href="https://en.wikipedia.org/wiki/Shneur_Zalman_of_Liadi">Baal Hatanya</a>.
     *
     * @see getSunriseBaalHatanya()
     * @see getSunsetBaalHatanya()
     */
    public static let ZENITH_1_POINT_583 = Double(GEOMETRIC_ZENITH + 1.583);
    
    /**
     * The zenith of 16.9&deg; below geometric zenith (90&deg;). This calculation is used for determining <em>alos</em>
     * (dawn) based on the opinion of the Baal Hatanya. It is based on the calculation that the time between dawn
     * and <em>netz amiti</em> (sunrise) is 72 minutes, the time that is takes to walk 4 <em>mil</em> at 18 minutes
     * a <em>mil</em> (<a href="https://en.wikipedia.org/wiki/Maimonides">Rambam</a> and others). The sun's position at 72
     * minutes before ``getSunriseBaalHatanya <em>netz amiti</em> (sunrise)`` in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a> is
     * 16.9&deg; below ``GEOMETRIC_ZENITH``.
     *
     * @see getAlosBaalHatanya()
     */
    public static let ZENITH_16_POINT_9 = Double(GEOMETRIC_ZENITH + 16.9);
    
    /**
     * The zenith of 6&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for
     * calculating <em>tzais</em> / nightfall based on the opinion of the Baal Hatanya. This calculation is based on the
     * position of the sun 24 minutes after ``getSunset()`` in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>, which
     * is 6&deg; below ``GEOMETRIC_ZENITH``.
     *
     * @see getTzaisBaalHatanya()
     */
    public static let ZENITH_6_DEGREES = Double(GEOMETRIC_ZENITH + 6);
    
    /**
     * The zenith of 6.45&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for
     * calculating <em>tzais</em> (nightfall) according to some opinions. This is based on the calculations of <a href=
     * "https://en.wikipedia.org/wiki/Yechiel_Michel_Tucazinsky">Rabbi Yechiel Michel Tucazinsky</a> of the position of
     * the sun no later than ``getTzaisGeonim6Point45Degrees() 31 minutes`` after sunset in Jerusalem, and at the
     * height of the summer solstice, this <em>zman</em> is 28 minutes after <em>shkiah</em>. This computes to 6.45&deg;
     * below ``GEOMETRIC_ZENITH``. This calculation is found in the <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=50536&st=&pgnum=51">Birur Halacha Yoreh Deah 262</a> it the commonly
     * used <em>zman</em> in Israel. It should be noted that this differs from the 6.1&deg;/6.2&deg; calculation for
     * Rabbi Tucazinsky's time as calculated by the Hazmanim Bahalacha Vol II chapter 50:7 (page 515).
     *
     * @see getTzaisGeonim6Point45Degrees()
     */
    public static let ZENITH_6_POINT_45 = Double(GEOMETRIC_ZENITH + 6.45);
    
    /**
     * The zenith of 7.65&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for
     * calculating <em>misheyakir</em> according to some opinions.
     *
     * @see getMisheyakir7Point65Degrees()
     */
    public static let ZENITH_7_POINT_65 = Double(GEOMETRIC_ZENITH + 7.65);
    
    /**
     * The zenith of 7.67&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for
     * calculating <em>tzais</em> according to some opinions.
     *
     * @see getTzaisGeonim7Point67Degrees()
     */
    public static let ZENITH_7_POINT_67 = Double(GEOMETRIC_ZENITH + 7.67);
    
    /**
     * The zenith of 9.3&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for
     * calculating <em>tzais</em> (nightfall) according to some opinions.
     *
     * @see getTzaisGeonim9Point3Degrees()
     */
    public static let ZENITH_9_POINT_3 = Double(GEOMETRIC_ZENITH + 9.3);
    
    /**
     * The zenith of 9.5&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for
     * calculating <em>misheyakir</em> according to some opinions.
     *
     * @see getMisheyakir9Point5Degrees()
     */
    public static let ZENITH_9_POINT_5 = Double(GEOMETRIC_ZENITH + 9.5);
    
    /**
     * The zenith of 9.75&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for
     * calculating <em>alos</em> (dawn) and <em>tzais</em> (nightfall) according to some opinions.
     *
     * @see getTzaisGeonim9Point75Degrees()
     */
    public static let ZENITH_9_POINT_75 = Double(GEOMETRIC_ZENITH + 9.75);
    
    /**
     * The zenith of 2.1&deg; above ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for
     * calculating the start of <em>bain hashmashos</em> (twilight) of 13.5 minutes before sunset converted to degrees
     * according to the Yereim. As is traditional with degrees below the horizon, this is calculated without refraction
     * and from the center of the sun. It would be 0.833&deg; less without this.
     *
     * @see getBainHashmashosYereim2Point1Degrees()
     */
    public static let ZENITH_MINUS_2_POINT_1 = Double(GEOMETRIC_ZENITH - 2.1);
    
    /**
     * The zenith of 2.8&deg; above ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for
     * calculating the start of <em>bain hashmashos</em> (twilight) of 16.875 minutes before sunset converted to degrees
     * according to the Yereim. As is traditional with degrees below the horizon, this is calculated without refraction
     * and from the center of the sun. It would be 0.833&deg; less without this.
     *
     * @see getBainHashmashosYereim2Point8Degrees()
     */
    public static let ZENITH_MINUS_2_POINT_8 = Double(GEOMETRIC_ZENITH - 2.8);
    
    /**
     * The zenith of 3.05&deg; above ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for
     * calculating the start of <em>bain hashmashos</em> (twilight) of 18 minutes before sunset converted to degrees
     * according to the Yereim. As is traditional with degrees below the horizon, this is calculated without refraction
     * and from the center of the sun. It would be 0.833&deg; less without this.
     *
     * @see getBainHashmashosYereim3Point05Degrees()
     */
    public static let ZENITH_MINUS_3_POINT_05 = Double(GEOMETRIC_ZENITH - 3.05);
    
    /**
     * The offset in minutes (defaults to 40) after sunset used for <em>tzeit</em> based on calculations of
     * <em>Chacham</em> Yosef Harari-Raful of Yeshivat Ateret Torah.
     * @see getTzaisAteretTorah()
     * @see getAteretTorahSunsetOffset()
     * @see setAteretTorahSunsetOffset(double)
     */
    public var ateretTorahSunsetOffset = Double(40);
    
    /**
     * A constructor that takes a ``GeoLocation`` as a parameter.
     *
     * @param location the ``GeoLocation`` object
     *
     * @see  ZmanimCalendar#ZmanimCalendar(GeoLocation)
     */
    public override init(location:GeoLocation) {
        super.init(location: location)
    }
    
    /**
     * Default constructor will set a default ``GeoLocation()``, a default
     * `` AstronomicalCalculator#getDefault()`` and default the ``workingDate`` to the current date.
     *
     * @see  AstronomicalCalendar#AstronomicalCalendar()
     */
    public override init() {
        super.init();
    }
    
    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) calculated using a 19.8&deg; dip. This calculation
     * divides the day based on the opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen
     * Avraham (MGA)</a> that the day runs from dawn to dusk. Dawn for this calculation is when the sun is 19.8&deg;
     * below the eastern geometric horizon before sunrise. Dusk for this is when the sun is 19.8&deg; below the western
     * geometric horizon after sunset. This day is split into 12 equal parts with each part being a <em>shaah zmanis</em>.
     *
     * @return the <code>long</code> millisecond length of a <em>shaah zmanis</em>. If the calculation can't be computed
     *         such as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a ``Int64.min``
     *         will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getShaahZmanis19Point8Degrees() -> Int64 {
        return getTemporalHour(startOfDay: getAlos19Point8Degrees(), endOfDay: getTzais19Point8Degrees());
    }
    
    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) calculated using a 18&deg; dip. This calculation divides
     * the day based on the opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham
     * (MGA)</a> that the day runs from dawn to dusk. Dawn for this calculation is when the sun is 18&deg; below the
     * eastern geometric horizon before sunrise. Dusk for this is when the sun is 18&deg; below the western geometric
     * horizon after sunset. This day is split into 12 equal parts with each part being a <em>shaah zmanis</em>.
     *
     * @return the <code>long</code> millisecond length of a <em>shaah zmanis</em>. If the calculation can't be computed
     *         such as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a ``Int64.min``
     *         will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getShaahZmanis18Degrees() -> Int64 {
        return getTemporalHour(startOfDay: getAlos18Degrees(), endOfDay: getTzais18Degrees());
    }
    
    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) calculated using a dip of 26&deg;. This calculation
     * divides the day based on the opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen
     * Avraham (MGA)</a> that the day runs from dawn to dusk. Dawn for this calculation is when the sun is
     * ``getAlos26Degrees()`` 26&deg; below the eastern geometric horizon before sunrise. Dusk for this is when
     * the sun is ``getTzais26Degrees()`` 26&deg; below the western geometric horizon after sunset. This day is
     * split into 12 equal parts with each part being a <em>shaah zmanis</em>. Since <em>zmanim</em> that use this
     * method are extremely late or early and at a point when the sky is a long time past the 18&deg; point where the
     * darkest point is reached, <em>zmanim</em> that use this should only be used <em>lechumra</em>, such as
     * delaying the start of nighttime <em>mitzvos</em>.
     *
     * @return the <code>long</code> millisecond length of a <em>shaah zmanis</em>. If the calculation can't be computed
     *         such as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a ``Int64.min``
     *         will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis120Minutes()
     */
    public func getShaahZmanis26Degrees() -> Int64 {
        return getTemporalHour(startOfDay: getAlos26Degrees(), endOfDay: getTzais26Degrees());
    }
    
    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) calculated using a dip of 16.1&deg;. This calculation
     * divides the day based on the opinion that the day runs from dawn to dusk. Dawn for this calculation is when the
     * sun is 16.1&deg; below the eastern geometric horizon before sunrise and dusk is when the sun is 16.1&deg; below
     * the western geometric horizon after sunset. This day is split into 12 equal parts with each part being a
     * <em>shaah zmanis</em>.
     *
     * @return the <code>long</code> millisecond length of a <em>shaah zmanis</em>. If the calculation can't be computed
     *         such as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a ``Int64.min``
     *         will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     *
     * @see getAlos16Point1Degrees()
     * @see getTzais16Point1Degrees()
     * @see getSofZmanShmaMGA16Point1Degrees()
     * @see getSofZmanTfilaMGA16Point1Degrees()
     * @see getMinchaGedola16Point1Degrees()
     * @see getMinchaKetana16Point1Degrees()
     * @see getPlagHamincha16Point1Degrees()
     */
    
    public func getShaahZmanis16Point1Degrees() -> Int64 {
        return getTemporalHour(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzais16Point1Degrees());
    }
    
    /**
     * Method to return a <em>shaah zmanis</em> (solar hour) according to the opinion of the <a href=
     * "https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a>. This calculation
     * divides the day based on the opinion of the MGA that the day runs from dawn to dusk. Dawn for this calculation is
     * 60 minutes before sunrise and dusk is 60 minutes after sunset. This day is split into 12 equal parts with each
     * part being a <em>shaah zmanis</em>. Alternate methods of calculating a <em>shaah zmanis</em> are available in the
     * subclass `` ComplexZmanimCalendar``
     *
     * @return the <code>long</code> millisecond length of a <em>shaah zmanis</em>. If the calculation can't be computed
     *         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
     *         where it does not set, a ``Int64.min`` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     *
     * @see getAlos60()
     * @see getTzais60()
     * @see getPlagHamincha60Minutes()
     */
    public func getShaahZmanis60Minutes() -> Int64 {
        return getTemporalHour(startOfDay: getAlos60(), endOfDay: getTzais60());
    }
    
    /**
     * Method to return a <em>shaah zmanis</em> (solar hour) according to the opinion of the <a href=
     * "https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a>. This calculation divides the day
     * based on the opinion of the MGA that the day runs from dawn to dusk. Dawn for this calculation is 72 minutes
     * before sunrise and dusk is 72 minutes after sunset. This day is split into 12 equal parts with each part
     * being a <em>shaah zmanis</em>. Alternate methods of calculating a <em>shaah zmanis</em> are available in the
     * subclass `` ComplexZmanimCalendar``
     *
     * @return the <code>long</code> millisecond length of a <em>shaah zmanis</em>. If the calculation can't be computed
     *         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
     *         where it does not set, a ``Int64.min`` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getShaahZmanis72Minutes() -> Int64 {
        return getShaahZmanisMGA();
    }
    
    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) according to the opinion of the <a href=
     * "https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based on <em>alos</em> being
     * ``getAlos72Zmanis()`` 72 minutes <em>zmaniyos</em> before ``getSunrise()`` This calculation
     * divides the day based on the opinion of the MGA that the day runs from dawn to dusk. Dawn for this calculation
     * is 72 minutes <em>zmaniyos</em> before sunrise and dusk is 72 minutes <em>zmaniyos</em> after sunset. This day
     * is split into 12 equal parts with each part being a <em>shaah zmanis</em>. This is identical to 1/10th of the day
     * from ``getSunrise()`` to ``getSunset()``
     *
     * @return the <code>long</code> millisecond length of a <em>shaah zmanis</em>. If the calculation can't be computed
     *         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
     *         where it does not set, a ``Int64.min`` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getAlos72Zmanis()
     * @see getTzais72Zmanis()
     */
    public func getShaahZmanis72MinutesZmanis() -> Int64 {
        return getTemporalHour(startOfDay: getAlos72Zmanis(), endOfDay: getTzais72Zmanis());
    }
    
    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) calculated using a dip of 90 minutes. This calculation
     * divides the day based on the opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen
     * Avraham (MGA)</a> that the day runs from dawn to dusk. Dawn for this calculation is 90 minutes before sunrise
     * and dusk is 90 minutes after sunset. This day is split into 12 equal parts with each part being a <em>shaah zmanis</em>.
     *
     * @return the <code>long</code> millisecond length of a <em>shaah zmanis</em>. If the calculation can't be computed
     *         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
     *         where it does not set, a ``Int64.min`` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getShaahZmanis90Minutes() -> Int64 {
        return getTemporalHour(startOfDay: getAlos90(), endOfDay: getTzais90());
    }
    
    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) according to the opinion of the <a href=
     * "https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based on <em>alos</em> being
     * ``getAlos90Zmanis()`` 90 minutes <em>zmaniyos</em> before ``getSunrise()`` This calculation divides
     * the day based on the opinion of the MGA that the day runs from dawn to dusk. Dawn for this calculation is 90 minutes
     * <em>zmaniyos</em> before sunrise and dusk is 90 minutes <em>zmaniyos</em> after sunset. This day is split into 12 equal
     * parts with each part being a <em>shaah zmanis</em>. This is 1/8th of the day from ``getSunrise()`` to
     * ``getSunset()``
     *
     * @return the <code>long</code> millisecond length of a <em>shaah zmanis</em>. If the calculation can't be computed
     *         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
     *         where it does not set, a ``Int64.min`` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getAlos90Zmanis()
     * @see getTzais90Zmanis()
     */
    public func getShaahZmanis90MinutesZmanis() -> Int64 {
        return getTemporalHour(startOfDay: getAlos90Zmanis(), endOfDay: getTzais90Zmanis());
    }
    
    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) according to the opinion of the <a href=
     * "https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based on <em>alos</em> being ``
     * ``getAlos96Zmanis()``  96 minutes <em>zmaniyos</em> before ``getSunrise()`` This calculation divides the
     * day based on the opinion of the MGA that the day runs from dawn to dusk. Dawn for this calculation is 96 minutes
     * <em>zmaniyos</em> before sunrise and dusk is 96 minutes <em>zmaniyos</em> after sunset. This day is split into 12
     * equal parts with each part being a <em>shaah zmanis</em>. This is identical to 1/7.5th of the day from
     * ``getSunrise()`` to ``getSunset()``
     *
     * @return the <code>long</code> millisecond length of a <em>shaah zmanis</em>. If the calculation can't be computed
     *         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
     *         where it does not set, a ``Int64.min`` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getAlos96Zmanis()
     * @see getTzais96Zmanis()
     */
    public func getShaahZmanis96MinutesZmanis() -> Int64 {
        return getTemporalHour(startOfDay: getAlos96Zmanis(), endOfDay: getTzais96Zmanis());
    }
    
    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) according to the opinion of the
     * <em>Chacham</em> Yosef Harari-Raful of Yeshivat Ateret Torah calculated with <em>alos</em> being 1/10th
     * of sunrise to sunset day, or ``getAlos72Zmanis()`` 72 minutes <em>zmaniyos</em> of such a day before
     * ``getSunrise()``, and <em>tzais</em> is usually calculated as ``getTzaisAteretTorah()`` 40
     * minutes (configurable to any offset via ``setAteretTorahSunsetOffset(double)``) after ``getSunset()``
     * This day is split into 12 equal parts with each part being a <em>shaah zmanis</em>. Note that with this
     * system, <em>chatzos</em> (mid-day) will not be the point that the sun is ``getSunTransit()`` halfway across
     * the sky
     *
     * @return the <code>long</code> millisecond length of a <em>shaah zmanis</em>. If the calculation can't be computed
     *         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
     *         where it does not set, a ``Int64.min`` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getAlos72Zmanis()
     * @see getTzaisAteretTorah()
     * @see getAteretTorahSunsetOffset()
     * @see setAteretTorahSunsetOffset(double)
     */
    public func getShaahZmanisAteretTorah() -> Int64 {
        return getTemporalHour(startOfDay: getAlos72Zmanis(), endOfDay: getTzaisAteretTorah());
    }
    
    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) used by some <em>zmanim</em> according to the opinion of
     * <a href="https://en.wikipedia.org/wiki/Yaakov_Moshe_Hillel">Rabbi Yaakov Moshe Hillel</a> as published in the
     * <em>luach</em> of the Bais Horaah of Yeshivat Chevrat Ahavat Shalom that is based on a day starting 72 minutes before
     * sunrise in degrees ``getAlos16Point1Degrees()`` <em>alos</em> 16.1&deg; and ending 14 minutes after sunset in
     * degrees ``getTzaisGeonim3Point8Degrees()`` <em>tzais</em> 3.8&deg; This day is split into 12 equal parts with
     * each part being a <em>shaah zmanis</em>. Note that with this system, <em>chatzos</em> (mid-day) will not be the point
     * that the sun is ``getSunTransit()`` halfway across the sky These <em>shaos zmaniyos</em> are used for <em>Mincha
     * Ketana</em> and <em>Plag Hamincha</em>. The 14 minutes are based on 3/4 of an 18 minute <em>mil</em>, with half a minute
     * added for Rav Yosi.
     *
     * @return the <code>long</code> millisecond length of a <em>shaah zmanis</em>. If the calculation can't be computed
     *         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
     *         where it does not set, a ``Int64.min`` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     *
     * @see getMinchaKetanaAhavatShalom()
     * @see getPlagAhavatShalom()
     */
    public func getShaahZmanisAlos16Point1ToTzais3Point8() -> Int64 {
        return getTemporalHour(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzaisGeonim3Point8Degrees());
    }
    
    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) used by some <em>zmanim</em> according to the opinion of
     * <a href="https://en.wikipedia.org/wiki/Yaakov_Moshe_Hillel">Rabbi Yaakov Moshe Hillel</a> as published in the
     * <em>luach</em> of the Bais Horaah of Yeshivat Chevrat Ahavat Shalom that is based on a day starting 72 minutes before
     * sunrise in degrees ``getAlos16Point1Degrees()`` <em>alos</em> 16.1&deg; and ending 13.5 minutes after sunset in
     * degrees ``getTzaisGeonim3Point7Degrees()`` <em>tzais</em> 3.7&deg; This day is split into 12 equal parts with
     * each part being a <em>shaah zmanis</em>. Note that with this system, <em>chatzos</em> (mid-day) will not be the point
     * that the sun is ``getSunTransit()`` halfway across the sky These <em>shaos zmaniyos</em> are used for <em>Mincha
     * Gedola</em> calculation.
     *
     * @return the <code>long</code> millisecond length of a <em>shaah zmanis</em>. If the calculation can't be computed
     *         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
     *         where it does not set, a ``Int64.min`` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     *
     * @see getMinchaGedolaAhavatShalom()
     */
    public func getShaahZmanisAlos16Point1ToTzais3Point7() -> Int64 {
        return getTemporalHour(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzaisGeonim3Point7Degrees());
    }
    
    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) calculated using a dip of 96 minutes. This calculation
     * divides the day based on the opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen
     * Avraham (MGA)</a> that the day runs from dawn to dusk. Dawn for this calculation is 96 minutes before sunrise
     * and dusk is 96 minutes after sunset. This day is split into 12 equal parts with each part being a <em>shaah
     * zmanis</em>.
     *
     * @return the <code>long</code> millisecond length of a <em>shaah zmanis</em>. If the calculation can't be computed
     *         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
     *         where it does not set, a ``Int64.min`` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getShaahZmanis96Minutes() -> Int64 {
        return getTemporalHour(startOfDay: getAlos96(), endOfDay: getTzais96());
    }
    
    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) calculated using a dip of 120 minutes. This calculation
     * divides the day based on the opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen
     * Avraham (MGA)</a> that the day runs from dawn to dusk. Dawn for this calculation is 120 minutes before sunrise and
     * dusk is 120 minutes after sunset. This day is split into 12 equal parts with each part being a <em>shaah zmanis</em>.
     * Since <em>zmanim</em> that use this method are extremely late or early and at a point when the sky is a long time
     * past the 18&deg; point where the darkest point is reached, <em>zmanim</em> that use this should only be used
     * <em>lechumra</em> only, such as delaying the start of nighttime <em>mitzvos</em>.
     *
     * @return the <code>long</code> millisecond length of a <em>shaah zmanis</em>. If the calculation can't be computed
     *         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
     *         where it does not set, a ``Int64.min`` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis26Degrees()
     */
    public func getShaahZmanis120Minutes() -> Int64 {
        return getTemporalHour(startOfDay: getAlos120(), endOfDay: getTzais120());
    }
    
    /**
     * Method to return a <em>shaah zmanis</em> (temporal hour) according to the opinion of the <a href=
     * "https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based on <em>alos</em> being
     * ``getAlos120Zmanis()`` 120 minutes <em>zmaniyos</em> before ``getSunrise()`` This calculation divides
     * the day based on the opinion of the MGA that the day runs from dawn to dusk. Dawn for this calculation is
     * 120 minutes <em>zmaniyos</em> before sunrise and dusk is 120 minutes <em>zmaniyos</em> after sunset. This day is
     * split into 12 equal parts with each part being a <em>shaah zmanis</em>. This is identical to 1/6th of the day from
     * ``getSunrise()`` to``getSunset()`` Since <em>zmanim</em> that use this method are
     * extremely late or early and at a point when the sky is a long time past the 18&deg; point where the darkest point
     * is reached, <em>zmanim</em> that use this should only be used <em>lechumra</em> such as delaying the start of
     * nighttime <em>mitzvos</em>.
     *
     * @return the <code>long</code> millisecond length of a <em>shaah zmanis</em>. If the calculation can't be computed
     *         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
     *         where it does not set, a ``Int64.min`` will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getAlos120Zmanis()
     * @see getTzais120Zmanis()
     */
    public func getShaahZmanis120MinutesZmanis() -> Int64 {
        return getTemporalHour(startOfDay: getAlos120Zmanis(), endOfDay: getTzais120Zmanis());
    }
    
    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em> based on sunrise
     * being 120 minutes <em>zmaniyos</em> or 1/6th of the day before sunrise. This is calculated as 10.75 hours after
     * ``getAlos120Zmanis()`` dawn The formula used is 10.75 x ``getShaahZmanis120MinutesZmanis()`` after
     * ``getAlos120Zmanis()`` dawn. Since the <em>zman</em> based on an extremely early <em>alos</em> and a very
     * late <em>tzais</em>, it should only be used <em>lechumra</em>.
     *
     * //@Deprecated This method should be used <em>lechumra</em> only since it returns a very late time (often after
     *         <em>shkiah</em>), and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no
     *         current plan to remove this method from the API, and this deprecation is intended to alert developers
     *         of the danger of using it.
     *
     * @return the <code>Date</code> of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     *
     * @see getShaahZmanis120MinutesZmanis()
     * @see getAlos120()
     * @see getTzais120()
     * @see getPlagHamincha26Degrees()
     * @see getPlagHamincha120Minutes()
     */
    ////@Deprecated // (forRemoval=false) // add back once Java 9 is the minimum supported version
    public func getPlagHamincha120MinutesZmanis() -> Date? {
        return getPlagHamincha(startOfDay: getAlos120Zmanis(), endOfDay: getTzais120Zmanis(), synchronous: true);
    }
    
    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em> according to the
     * Magen Avraham with the day starting 120 minutes before sunrise and ending 120 minutes after sunset. This is
     * calculated as 10.75 hours after ``getAlos120()`` dawn 120 minutes The formula used is 10.75
     * ``getShaahZmanis120Minutes()`` after ``getAlos120()`` Since the <em>zman</em> based on an extremely early
     * <em>alos</em> and a very late <em>tzais</em>, it should only be used <em>lechumra</em>.
     *
     * //@Deprecated This method should be used <em>lechumra</em> only since it returns a very late time (often after
     *         <em>shkiah</em>), and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no
     *         current plan to remove this method from the API, and this deprecation is intended to alert developers
     *         of the danger of using it.
     *
     * @return the <code>Date</code> of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     *
     * @see getShaahZmanis120Minutes()
     * @see getPlagHamincha26Degrees()
     */
    ////@Deprecated // (forRemoval=false) // add back once Java 9 is the minimum supported version
    public func getPlagHamincha120Minutes() -> Date? {
        return getPlagHamincha(startOfDay: getAlos120(), endOfDay: getTzais120(), synchronous: true);
    }
    
    /**
     * Method to return <em>alos</em> (dawn) calculated as 60 minutes before sunrise. This is the time to walk the
     * distance of 4 <em>Mil</em> at 15 minutes a <em>Mil</em>. This seems to be the opinion of the <a href=
     * "https://en.wikipedia.org/wiki/Yair_Bacharach">Chavas Yair</a> in the Mekor Chaim, Orach Chaim Ch.
     * 90, though  the Mekor Chaim in Ch. 58 and in the <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=45193&pgnum=214">Chut Hashani Cha 97</a> states that
     * a a person walks 3 and a 1/3 <em>mil</em> in an hour, or an 18-minute <em>mil</em>. Also see the <a href=
     * "https://he.wikipedia.org/wiki/%D7%9E%D7%9C%D7%9B%D7%99%D7%90%D7%9C_%D7%A6%D7%91%D7%99_%D7%98%D7%A0%D7%A0%D7%91%D7%95%D7%99%D7%9D"
     * >Divrei Malkiel</a> <a href="https://hebrewbooks.org/pdfpager.aspx?req=803&pgnum=33">Vol. 4, Ch. 20, page 34</a>) who
     * mentions the 15 minute <em>mil</em> lechumra by baking matzos. Also see the <a href=
     * "https://en.wikipedia.org/wiki/Joseph_Colon_Trabotto">Maharik</a> <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=1142&pgnum=216">Ch. 173</a> where the questioner quoting the
     * <a href="https://en.wikipedia.org/wiki/Eliezer_ben_Nathan">Ra'avan</a> is of the opinion that the time to walk a
     * <em>mil</em> is 15 minutes (5 <em>mil</em> in a little over an hour). There are many who believe that there is a
     * <em>ta'us sofer</em> (scribe's error) in the Ra'avan, and it should 4 <em>mil</em> in a little over an hour, or an
     * 18-minute <em>mil</em>. Time based offset calculations are based on the opinion of the
     * <em><a href="https://en.wikipedia.org/wiki/Rishonim">Rishonim</a></em> who stated that the time of the <em>neshef</em>
     * (time between dawn and sunrise) does not vary by the time of year or location but purely depends on the time it takes to
     * walk the distance of 4x <em>mil</em>. ``getTzaisGeonim9Point75Degrees()`` is a related <em>zman</em> that is a
     * degree-based calculation based on 60 minutes.
     *
     * @return the <code>Date</code> representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
     *         a <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     *
     * @see getTzais60()
     * @see getPlagHamincha60Minutes()
     * @see getShaahZmanis60Minutes()
     */
    public func getAlos60() -> Date? {
        return ComplexZmanimCalendar.getTimeOffset(time: getSunrise(), offset: -60 * ComplexZmanimCalendar.MINUTE_MILLIS);
    }
    
    /**
     * Method to return <em>alos</em> (dawn) calculated using 72 minutes <em>zmaniyos</em> or 1/10th of the day before
     * sunrise. This is based on an 18-minute <em>Mil</em> so the time for 4 <em>Mil</em> is 72 minutes which is 1/10th
     * of a day (12 x 60 = 720) based on the a day being from ``getSeaLevelSunrise()`` to
     * ``getSeaLevelSunrise()`` or ``getSunrise()`` to ``getSunset()``
     * (depending on the ``isUseElevation()`` setting).
     * The actual calculation is ``getSeaLevelSunrise()`` - (``getShaahZmanisGra()`` * 1.2). This calculation
     * is used in the calendars published by the <a href=
     * "https://en.wikipedia.org/wiki/Central_Rabbinical_Congress">Hisachdus Harabanim D'Artzos Habris Ve'Canada</a>.
     *
     * @return the <code>Date</code> representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
     *         a <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see getShaahZmanisGra()
     */
    public func getAlos72Zmanis() -> Date? {
        return getZmanisBasedOffset(hours: -1.2);
    }
    
    /**
     * Method to return <em>alos</em> (dawn) calculated using 96 minutes before before ``getSunrise()`` or
     * ``getSeaLevelSunrise()`` (depending on the ``isUseElevation()`` setting) that is based
     * on the time to walk the distance of 4 <em>Mil</em> at 24 minutes a <em>Mil</em>. Time based offset
     * calculations for <em>alos</em> are based on the opinion of the <em><a href="https://en.wikipedia.org/wiki/Rishonim"
     * >Rishonim</a></em> who stated that the time of the <em>Neshef</em> (time between dawn and sunrise) does not vary
     * by the time of year or location but purely depends on the time it takes to walk the distance of 4 <em>Mil</em>.
     *
     * @return the <code>Date</code> representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
     *         a <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     */
    public func getAlos96() -> Date? {
        return ComplexZmanimCalendar.getTimeOffset(time: getElevationAdjustedSunrise(), offset: -96 * ComplexZmanimCalendar.MINUTE_MILLIS);
    }
    
    /**
     * Method to return <em>alos</em> (dawn) calculated using 90 minutes <em>zmaniyos</em> or 1/8th of the day before
     * ``getSunrise()`` or ``getSeaLevelSunrise()`` (depending on the
     * ``isUseElevation()`` setting). This is based on a 22.5-minute <em>Mil</em> so the time for 4 <em>Mil</em> is 90
     * minutes which is 1/8th of a day (12 x 60) / 8 = 90
     * The day is calculated from ``getSeaLevelSunrise()`` to ``getSeaLevelSunrise`` or ``getSunrise()`` to ``getSunset()`` (depending on the ``isUseElevation()``)
     * The actual calculation used is ``getSunrise()`` - (``getShaahZmanisGra()`` * 1.5).
     *
     * @return the <code>Date</code> representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
     *         a <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see getShaahZmanisGra()
     */
    public func getAlos90Zmanis() -> Date? {
        return getZmanisBasedOffset(hours: -1.5);
    }
    
    /**
     * This method returns <em>alos</em> (dawn) calculated using 96 minutes <em>zmaniyos</em> or 1/7.5th of the day before
     * ``getSunrise()`` or ``getSeaLevelSunrise()`` (depending on the
     * ``isUseElevation()`` setting). This is based on a 24-minute <em>Mil</em> so the time for 4 <em>Mil</em> is 96
     * minutes which is 1/7.5th of a day (12 x 60 / 7.5 = 96).
     * The day is calculated from ``getSeaLevelSunrise()`` to ``getSeaLevelSunrise()`` or ``getSunrise()`` to ``getSunset()`` (depending on the ``isUseElevation()``)
     * The actual calculation used is ``getSunrise()`` - (``getShaahZmanisGra()`` * 1.6).
     *
     * @return the <code>Date</code> representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
     *         a <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see getShaahZmanisGra()
     */
    public func getAlos96Zmanis() -> Date? {
        return getZmanisBasedOffset(hours: -1.6);
    }
    
    /**
     * Method to return <em>alos</em> (dawn) calculated using 90 minutes before ``getSeaLevelSunrise()`` sea level
     * sunrise based on the time to walk the distance of 4 <em>Mil</em> at 22.5 minutes a <em>Mil</em>. Time based
     * offset calculations for <em>alos</em> are based on the opinion of the <em><a href=
     * "https://en.wikipedia.org/wiki/Rishonim">Rishonim</a></em> who stated that the time of the <em>Neshef</em>
     * (time between dawn and sunrise) does not vary by the time of year or location but purely depends on the time it
     * takes to walk the distance of 4 <em>Mil</em>.
     *
     * @return the <code>Date</code> representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
     *         a <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     */
    public func getAlos90() -> Date? {
        return ComplexZmanimCalendar.getTimeOffset(time: getElevationAdjustedSunrise(), offset: -90 * ComplexZmanimCalendar.MINUTE_MILLIS);
    }
    
    /**
     * This method should be used <em>lechumra</em> only and returns <em>alos</em> (dawn) calculated using 120 minutes
     * before ``getSeaLevelSunrise()`` (no adjustment for elevation is made) based on the time
     * to walk the distance of 5 <em>Mil</em>(<em>Ula</em>) at 24 minutes a <em>Mil</em>. Time based offset calculations
     * for <em>alos</em> are based on the* opinion of the <em><a href="https://en.wikipedia.org/wiki/Rishonim">Rishonim</a>
     * </em> who stated that the time of the <em>neshef</em> (time between dawn and sunrise) does not vary by the time of
     * year or location but purely depends on the time it takes to walk the distance of 5 <em>Mil</em>(<em>Ula</em>). Since
     * this time is extremely early, it should only be used <em>lechumra</em>, such as not eating after this time on a fast
     * day, and not as the start time for <em>mitzvos</em> that can only be performed during the day.
     *
     * //@Deprecated This method should be used <em>lechumra</em> only (such as stopping to eat at this time on a fast day),
     *         since it returns a very early time, and if used <em>lekula</em> can result in doing <em>mitzvos hayom</em>
     *         too early according to most opinions. There is no current plan to remove this method from the API, and this
     *         deprecation is intended to alert developers of the danger of using it.
     *
     * @return the <code>Date</code> representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
     *         a <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     *
     * @see getTzais120()
     * @see getAlos26Degrees()
     */
    ////@Deprecated // (forRemoval=false) // add back once Java 9 is the minimum supported version
    public func getAlos120() -> Date? {
        return ComplexZmanimCalendar.getTimeOffset(time: getElevationAdjustedSunrise(), offset: -120 * ComplexZmanimCalendar.MINUTE_MILLIS);
    }
    
    /**
     * This method should be used <em>lechumra</em> only and  method returns <em>alos</em> (dawn) calculated using
     * 120 minutes <em>zmaniyos</em> or 1/6th of the day before ``getSunrise()`` or
     * ``getSeaLevelSunrise()`` (depending on the ``isUseElevation()`` setting). This is based
     * on a 24-minute <em>Mil</em> so the time for 5 <em>Mil</em> is 120 minutes which is 1/6th of a day (12 x 60 /
     * 6 = 120). The day is calculated from ``getSeaLevelSunrise()`` to
     * ``getSeaLevelSunrise()`` or ``getSunrise()`` to ``getSunset()`` (depending
     * on the ``isUseElevation()`` The actual calculation used is ``getSunrise()`` - (
     *``getShaahZmanisGra()`` x 2). Since this time is extremely early, it should only be used <em>lechumra</em>, such
     * as not eating after this time on a fast day, and not as the start time for <em>mitzvos</em> that can only be
     * performed during the day.
     *
     * //@Deprecated This method should be used <em>lechumra</em> only (such as stopping to eat at this time on a fast day),
     *         since it returns a very early time, and if used <em>lekula</em> can result in doing <em>mitzvos hayom</em>
     *         too early according to most opinions. There is no current plan to remove this method from the API, and this
     *         deprecation is intended to alert developers of the danger of using it.
     *
     * @return the <code>Date</code> representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
     *         a <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see getAlos120()
     * @see getAlos26Degrees()
     */
    ////@Deprecated // (forRemoval=false) // add back once Java 9 is the minimum supported version
    public func getAlos120Zmanis() -> Date? {
        return getZmanisBasedOffset(hours: -2.0);
    }
    
    /**
     * This method should be used <em>lechumra</em> only and returns <em>alos</em> (dawn) calculated when the sun is
     * ``ZENITH_26_DEGREES 26&deg;`` below the eastern geometric horizon before sunrise. This calculation is based on the same
     * calculation of ``getAlos120()`` 120 minutes but uses a degree-based calculation instead of 120 exact minutes. This
     * calculation is based on the position of the sun 120 minutes before sunrise in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>, which
     * calculates to 26&deg; below ``GEOMETRIC_ZENITH``. Since this time is extremely early, it should
     * only be used <em>lechumra</em> only, such as not eating after this time on a fast day, and not as the start time for
     * <em>mitzvos</em> that can only be performed during the day.
     *
     * //@Deprecated This method should be used <em>lechumra</em> only (such as stopping to eat at this time on a fast day),
     *         since it returns a very early time, and if used <em>lekula</em> can result in doing <em>mitzvos hayom</em>
     *         too early according to most opinions. There is no current plan to remove this  method from the API, and this
     *         deprecation is intended to alert developers of the danger of using it.
     *
     * @return the <code>Date</code> representing <em>alos</em>. If the calculation can't be computed such as northern
     *         and southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun
     *         may not reach low enough below the horizon for this calculation, a <code>nil</code> will be returned. See
     *         detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see ZENITH_26_DEGREES
     * @see getAlos120()
     * @see getTzais120()
     * @see getTzais26Degrees()
     */
    ////@Deprecated // (forRemoval=false) // add back once Java 9 is the minimum supported version
    public func getAlos26Degrees() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_26_DEGREES);
    }
    
    /**
     * A method to return <em>alos</em> (dawn) calculated when the sun is ``ASTRONOMICAL_ZENITH`` 18&deg; below the
     * eastern geometric horizon before sunrise.
     *
     * @return the <code>Date</code> representing <em>alos</em>. If the calculation can't be computed such as northern
     *         and southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun
     *         may not reach low enough below the horizon for this calculation, a <code>nil</code> will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see ASTRONOMICAL_ZENITH
     */
    public func getAlos18Degrees() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ASTRONOMICAL_ZENITH);
    }
    
    /**
     * A method to return <em>alos</em> (dawn) calculated when the sun is ``ZENITH_19_DEGREES`` 19&deg; below the
     * eastern geometric horizon before sunrise. This is the <a href="https://en.wikipedia.org/wiki/Maimonides"
     * >Rambam</a>'s <em>alos</em> according to Rabbi Moshe Kosower's <a href=
     * "https://www.worldcat.org/oclc/145454098">Maaglei Tzedek</a>, page 88, <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=33464&pgnum=13">Ayeles Hashachar Vol. I, page 12</a>, <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=55960&pgnum=258">Yom Valayla Shel Torah, Ch. 34, p. 222</a> and
     * Rabbi Yaakov Shakow's <a href="https://www.worldcat.org/oclc/1043573513">Luach Ikvei Hayom</a>.
     *
     * @return the <code>Date</code> representing <em>alos</em>. If the calculation can't be computed such as northern
     *         and southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun
     *         may not reach low enough below the horizon for this calculation, a <code>nil</code> will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see ASTRONOMICAL_ZENITH
     */
    public func getAlos19Degrees() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_19_DEGREES);
    }
    
    /**
     * Method to return <em>alos</em> (dawn) calculated when the sun is ``ZENITH_19_POINT_8`` 19.8&deg; below the
     * eastern geometric horizon before sunrise. This calculation is based on the same calculation of
     * ``getAlos90()`` 90 minutes but uses a degree-based calculation instead of 90 exact minutes. This calculation
     * is based on the position of the sun 90 minutes before sunrise in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>, which
     * calculates to 19.8&deg; below ``GEOMETRIC_ZENITH``.
     *
     * @return the <code>Date</code> representing <em>alos</em>. If the calculation can't be computed such as northern
     *         and southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun
     *         may not reach low enough below the horizon for this calculation, a <code>nil</code> will be returned. See
     *         detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see ZENITH_19_POINT_8
     * @see getAlos90()
     */
    public func getAlos19Point8Degrees() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_19_POINT_8);
    }
    
    /**
     * Method to return <em>alos</em> (dawn) calculated when the sun is ``ZENITH_16_POINT_1`` 16.1&deg; below the
     * eastern geometric horizon before sunrise. This calculation is based on the same calculation of
     * ``getAlos72()`` 72 minutes but uses a degree-based calculation instead of 72 exact minutes. This calculation
     * is based on the position of the sun 72 minutes before sunrise in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>, which
     * calculates to 16.1&deg; below ``GEOMETRIC_ZENITH``.
     *
     * @return the <code>Date</code> representing <em>alos</em>. If the calculation can't be computed such as northern
     *         and southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun
     *         may not reach low enough below the horizon for this calculation, a <code>nil</code> will be returned. See
     *         detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see ZENITH_16_POINT_1
     * @see getAlos72()
     */
    public func getAlos16Point1Degrees() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_16_POINT_1);
    }
    
    /**
     * This method returns <em>misheyakir</em> based on the position of the sun when it is ``ZENITH_11_DEGREES``
     * 11.5&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for calculating
     * <em>misheyakir</em> according to some opinions. This calculation is based on the position of the sun 52 minutes
     * before ``getSunrise()`` sunrise in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>,
     * which calculates to 11.5&deg; below ``GEOMETRIC_ZENITH``.
     * @todo recalculate.
     *
     * @return the <code>Date</code> of <em>misheyakir</em>. If the calculation can't be computed such as northern and
     *         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may
     *         not reach low enough below the horizon for this calculation, a <code>nil</code> will be returned. See
     *         detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see ZENITH_11_POINT_5
     */
    public func getMisheyakir11Point5Degrees() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_11_POINT_5);
    }
    
    /**
     * This method returns <em>misheyakir</em> based on the position of the sun when it is ``ZENITH_11_DEGREES``
     * 11&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for calculating
     * <em>misheyakir</em> according to some opinions. This calculation is based on the position of the sun 48 minutes
     * before ``getSunrise``  in Jerusalem d<a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>,
     * which calculates to 11&deg; below ``GEOMETRIC_ZENITH``.
     *
     * @return If the calculation can't be computed such as northern and southern locations even south of the Arctic
     *         Circle and north of the Antarctic Circle where the sun may not reach low enough below the horizon for
     *         this calculation, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see ZENITH_11_DEGREES
     */
    public func getMisheyakir11Degrees() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_11_DEGREES);
    }
    
    /**
     * This method returns <em>misheyakir</em> based on the position of the sun when it is ``ZENITH_10_POINT_2``
     * 10.2&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is used for calculating
     * <em>misheyakir</em> according to some opinions. This calculation is based on the position of the sun 45 minutes
     * before ``getSunrise()`` in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox</a> which calculates
     * to 10.2&deg; below ``GEOMETRIC_ZENITH``.
     *
     * @return the <code>Date</code> of <em>misheyakir</em>. If the calculation can't be computed such as
     *         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
     *         the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be returned
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see ZENITH_10_POINT_2
     */
    public func getMisheyakir10Point2Degrees() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_10_POINT_2);
    }
    
    /**
     * This method returns <em>misheyakir</em> based on the position of the sun when it is ``ZENITH_7_POINT_65``
     * 7.65&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). The degrees are based on a 35/36 minute
     * <em>zman</em> <a href="https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the
     * equinox / equilux</a>, when the <em>neshef</em> (twilight) is the shortest. This time is based on <a href=
     * "https://en.wikipedia.org/wiki/Moshe_Feinstein">Rabbi Moshe Feinstein</a> who writes in <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=14677&pgnum=7">Ohr Hachaim Vol. 4, Ch. 6</a>)
     * that <em>misheyakir</em> in New York is 35-40 minutes before sunrise, something that is a drop less than 8&deg;.
     * <a href="https://en.wikipedia.org/wiki/Yisroel_Taplin">Rabbi Yisroel Taplin</a> in <a href=
     * "https://www.worldcat.org/oclc/889556744">Zmanei Yisrael</a> (page 117) notes that <a href=
     * "https://en.wikipedia.org/wiki/Yaakov_Kamenetsky">Rabbi Yaakov Kamenetsky</a> stated that it is not less than 36
     * minutes before sunrise (maybe it is 40 minutes). Sefer Yisrael Vehazmanim (p. 7) quotes the Tamar Yifrach
     * in the name of the <a href="https://en.wikipedia.org/wiki/Joel_Teitelbaum">Satmar Rov</a> that one should be stringent
     * not consider <em>misheyakir</em> before 36 minutes. This is also the accepted <a href=
     * "https://en.wikipedia.org/wiki/Minhag">minhag</a> in <a href=
     * "https://en.wikipedia.org/wiki/Lakewood_Township,_New_Jersey">Lakewood</a> that is used in the <a href=
     * "https://en.wikipedia.org/wiki/Beth_Medrash_Govoha">Yeshiva</a>. This follows the opinion of <a href=
     * "https://en.wikipedia.org/wiki/Shmuel_Kamenetsky">Rabbi Shmuel Kamenetsky</a> who provided the time of 35/36 minutes,
     * but did not provide a degree-based time. Since this <em>zman</em> depends on the level of light, Rabbi Yaakov Shakow
     * presented this degree-based calculations to Rabbi Kamenetsky who agreed to them.
     *
     * @return the <code>Date</code> of <em>misheyakir</em>. If the calculation can't be computed such as
     *         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
     *         the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     *
     * @see ZENITH_7_POINT_65
     * @see getMisheyakir9Point5Degrees()
     */
    public func getMisheyakir7Point65Degrees() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_7_POINT_65);
    }
    
    /**
     * This method returns <em>misheyakir</em> based on the position of the sun when it is ``ZENITH_9_POINT_5``
     * 9.5&deg; below ``GEOMETRIC_ZENITH`` (90&deg;). This calculation is based on Rabbi Dovid Kronglass's
     * Calculation of 45 minutes in Baltimore as mentioned in <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=20287&pgnum=29">Divrei Chachamim No. 24</a> brought down by the <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=50535&pgnum=87">Birur Halacha, Tinyana, Ch. 18</a>. This calculates to
     * 9.5&deg;. Also see <a href="https://en.wikipedia.org/wiki/Jacob_Isaac_Neiman">Rabbi Yaakov Yitzchok Neiman</a> in Kovetz
     * Eitz Chaim Vol. 9, p. 202 that the Vya'an Yosef did not want to rely on times earlier than 45 minutes in New York. This
     * <em>zman</em> is also used in the calendars published by Rabbi Hershel Edelstein. As mentioned in Yisroel Vehazmanim,
     * Rabbi Edelstein who was given the 45 minute <em>zman</em> by Rabbi Bick. The calendars published by the <em><a href=
     * "https://en.wikipedia.org/wiki/Mizrahi_Jews">Edot Hamizrach</a></em> communities also use this <em>zman</em>. This also
     * follows the opinion of <a href="https://en.wikipedia.org/wiki/Shmuel_Kamenetsky">Rabbi Shmuel Kamenetsky</a> who provided
     * the time of 36 and 45 minutes, but did not provide a degree-based time. Since this <em>zman</em> depends on the level of
     * light, Rabbi Yaakov Shakow presented these degree-based times to Rabbi Shmuel Kamenetsky who agreed to them.
     *
     * @return the <code>Date</code> of <em>misheyakir</em>. If the calculation can't be computed such as
     *         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
     *         the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     *
     * @see ZENITH_9_POINT_5
     * @see getMisheyakir7Point65Degrees()
     */
    public func getMisheyakir9Point5Degrees() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_9_POINT_5);
    }
    
    /**
     * This method returns <em>misheyakir</em> as 6 zmaniyot minutes after ``getAlos72Zmanis()``. This is how Rabbi Ovadiah Yosef calculates this zman as implemented in the Ohr Hachaim calendar.
     *
     * @return the <code>Date</code> of <em>misheyakir</em>. If the calculation can't be computed such as
     *         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
     *         the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     *
     */
    public func getMisheyakir66MinutesZmanit() -> Date? {
        let shaahZmanit = getShaahZmanisGra()
        let dakahZmanit = shaahZmanit / 60
        return ComplexZmanimCalendar.getTimeOffset(time: getAlos72Zmanis(), offset: 6 * Double(dakahZmanit))
    }
    
    /**
     * This method returns <em>misheyakir</em> as 12 zmaniyot minutes after ``getAlos72Zmanis()``.
     *
     * @return the <code>Date</code> of <em>misheyakir</em>. If the calculation can't be computed such as
     *         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
     *         the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     *
     */
    public func getMisheyakir60MinutesZmanit() -> Date? {
        let shaahZmanit = getShaahZmanisGra()
        let dakahZmanit = shaahZmanit / 60
        return ComplexZmanimCalendar.getTimeOffset(time: getAlos72Zmanis(), offset: 12 * Double(dakahZmanit))
    }
    
    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite Shema in the morning) according to the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based on
     * <em>alos</em> being ``getAlos19Point8Degrees()`` 19.8&deg; before ``getSunrise()`` This
     * time is 3 ``getShaahZmanis19Point8Degrees()`` <em>shaos zmaniyos</em> (solar hours) after
     * ``getAlos19Point8Degrees()`` dawn based on the opinion of the MGA that the day is calculated from dawn to nightfall
     * with both being 19.8&deg; below sunrise or sunset. This returns the time of 3 x
     * ``getShaahZmanis19Point8Degrees()`` after ``getAlos19Point8Degrees()`` dawn
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis19Point8Degrees()
     * @see getAlos19Point8Degrees()
     */
    public func getSofZmanShmaMGA19Point8Degrees() -> Date? {
        return getSofZmanShma(startOfDay: getAlos19Point8Degrees(), endOfDay: getTzais19Point8Degrees(), synchronous: true);
    }
    
    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite Shema in the morning) according to the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based
     * on <em>alos</em> being ``getAlos16Point1Degrees()`` 16.1&deg; before ``getSunrise()`` This time
     * is 3 ``getShaahZmanis16Point1Degrees()`` <em>shaos zmaniyos</em> (solar hours) after
     * ``getAlos16Point1Degrees()`` dawn based on the opinion of the MGA that the day is calculated from
     * dawn to nightfall with both being 16.1&deg; below sunrise or sunset. This returns the time of
     * 3 * ``getShaahZmanis16Point1Degrees()`` after ``getAlos16Point1Degrees() dawn``
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis16Point1Degrees()
     * @see getAlos16Point1Degrees()
     */
    public func getSofZmanShmaMGA16Point1Degrees() -> Date? {
        return getSofZmanShma(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzais16Point1Degrees(), synchronous: true);
    }
    
    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite Shema in the morning) according to the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based
     * on <em>alos</em> being ``getAlos18Degrees()`` 18&deg; before ``getSunrise()`` This time is 3
     * ``getShaahZmanis18Degrees()`` <em>shaos zmaniyos</em> (solar hours) after ``getAlos18Degrees()`` dawn
     * based on the opinion of the MGA that the day is calculated from dawn to nightfall with both being 18&deg;
     * below sunrise or sunset. This returns the time of 3 x ``getShaahZmanis18Degrees()`` after
     * ``getAlos18Degrees()`` dawn
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis18Degrees()
     * @see getAlos18Degrees()
     */
    public func getSofZmanShmaMGA18Degrees() -> Date? {
        return getSofZmanShma(startOfDay: getAlos18Degrees(), endOfDay: getTzais18Degrees(), synchronous: true);
    }
    
    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite Shema in the morning) according to the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based on
     * <em>alos</em> being ``getAlos72()`` 72 minutes before ``getSunrise()`` This time is 3 ``
     *getShaahZmanis72Minutes() <em>shaos zmaniyos</em> (solar hours) after ``getAlos72()`` dawn based on the opinion
     * of the MGA that the day is calculated from a ``getAlos72()`` dawn of 72 minutes before sunrise to
     * ``getTzais72()`` nightfall of 72 minutes after sunset. This returns the time of 3 x ``
     * ``getShaahZmanis72Minutes()`` after ``getAlos72()`` dawn. This class returns an identical time to
     *``getSofZmanShmaMGA()`` and is repeated here for clarity.
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
     *         it does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see isUseAstronomicalChatzosForOtherZmanim()
     * @see getShaahZmanis72Minutes()
     * @see getAlos72()
     * @see getSofZmanShmaMGA()
     */
    public func getSofZmanShmaMGA72Minutes() -> Date? {
        return getSofZmanShmaMGA();
    }
    
    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite <em>Shema</em> in the morning) according
     * to the opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based
     * on <em>alos</em> being ``getAlos72Zmanis()`` 72 minutes <em>zmaniyos</em>, or 1/10th of the day before
     * ``getSunrise()`` This time is 3 ``getShaahZmanis90MinutesZmanis()`` <em>shaos zmaniyos</em>
     * (solar hours) after ``getAlos72Zmanis()`` dawn based on the opinion of the MGA that the day is calculated
     * from a ``getAlos72Zmanis()`` dawn of 72 minutes <em>zmaniyos</em>, or 1/10th of the day before
     * ``getSeaLevelSunrise()`` sea level sunrise to ``getTzais72Zmanis()`` nightfall of 72 minutes
     * <em>zmaniyos</em> after ``getSeaLevelSunset()`` This returns the time of 3 x
     * ``getShaahZmanis72MinutesZmanis()`` after ``getAlos72Zmanis()`` dawn
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
     *         it does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis72MinutesZmanis()
     * @see getAlos72Zmanis()
     * @see isUseAstronomicalChatzosForOtherZmanim()
     */
    public func getSofZmanShmaMGA72MinutesZmanis() -> Date? {
        return getSofZmanShma(startOfDay: getAlos72Zmanis(), endOfDay: getTzais72Zmanis(), synchronous: true);
    }
    
    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite <em>Shema</em> in the morning) according
     * to the opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based on
     * <em>alos</em> being ``getAlos90()`` 90 minutes before ``getSunrise()`` This time is 3
     * ``getShaahZmanis90Minutes()`` <em>shaos zmaniyos</em> (solar hours) after ``getAlos90()`` dawn based on
     * the opinion of the MGA that the day is calculated from a ``getAlos90()`` dawn of 90 minutes before sunrise to
     * ``getTzais90()`` nightfall of 90 minutes after sunset. This returns the time of 3 x
     * ``getShaahZmanis90Minutes()`` after ``getAlos90()`` dawn
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
     *         it does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis90Minutes()
     * @see getAlos90()
     * @see isUseAstronomicalChatzosForOtherZmanim()
     */
    public func getSofZmanShmaMGA90Minutes() -> Date? {
        return getSofZmanShma(startOfDay: getAlos90(), endOfDay: getTzais90(), synchronous: true);
    }
    
    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite Shema in the morning) according to the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based
     * on <em>alos</em> being ``getAlos90Zmanis()`` 90 minutes <em>zmaniyos</em> before ``getSunrise()``
     * sunrise This time is 3 ``getShaahZmanis90MinutesZmanis()``<em>shaos zmaniyos</em> (solar hours) after
     * ``getAlos90Zmanis()`` dawn based on the opinion of the MGA that the day is calculated from a ``
     * ``getAlos90Zmanis()`` dawn of 90 minutes <em>zmaniyos</em> before sunrise to ``getTzais90Zmanis()`` nightfall
     * of 90 minutes <em>zmaniyos</em> after sunset. This returns the time of 3 x ``getShaahZmanis90MinutesZmanis()``
     * after ``getAlos90Zmanis()`` dawn
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
     *         it does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis90MinutesZmanis()
     * @see getAlos90Zmanis()
     * @see isUseAstronomicalChatzosForOtherZmanim()
     */
    public func getSofZmanShmaMGA90MinutesZmanis() -> Date? {
        return getSofZmanShma(startOfDay: getAlos90Zmanis(), endOfDay: getTzais90Zmanis(), synchronous: true);
    }
    
    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite Shema in the morning) according to the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based
     * on <em>alos</em> being ``getAlos96()`` 96 minutes before ``getSunrise()`` This time is 3
     * ``getShaahZmanis96Minutes()`` <em>shaos zmaniyos</em> (solar hours) after ``getAlos96()`` dawn based on
     * the opinion of the MGA that the day is calculated from a ``getAlos96()`` of 96 minutes before
     * sunrise to ``getTzais96()`` of 96 minutes after sunset. This returns the time of 3 * ``
     * ``getShaahZmanis96Minutes()`` after ``getAlos96()`` dawn
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
     *         it does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis96Minutes()
     * @see getAlos96()
     * @see isUseAstronomicalChatzosForOtherZmanim()
     */
    public func getSofZmanShmaMGA96Minutes() -> Date? {
        return getSofZmanShma(startOfDay: getAlos96(), endOfDay: getTzais96(), synchronous: true);
    }
    
    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite Shema in the morning) according to the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based
     * on <em>alos</em> being ``getAlos90Zmanis()`` 96 minutes <em>zmaniyos</em> before ``getSunrise()``
     * sunrise This time is 3 ``getShaahZmanis96MinutesZmanis()`` <em>shaos zmaniyos</em> (solar hours) after
     * ``getAlos96Zmanis()`` dawn based on the opinion of the MGA that the day is calculated from a ``
     *getAlos96Zmanis() dawn of 96 minutes <em>zmaniyos</em> before sunrise to ``getTzais90Zmanis()`` nightfall
     * of 96 minutes <em>zmaniyos</em> after sunset. This returns the time of 3 x ``getShaahZmanis96MinutesZmanis()``
     * after ``getAlos96Zmanis()`` dawn
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
     *         it does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis96MinutesZmanis()
     * @see getAlos96Zmanis()
     * @see isUseAstronomicalChatzosForOtherZmanim()
     */
    public func getSofZmanShmaMGA96MinutesZmanis() -> Date? {
        return getSofZmanShma(startOfDay: getAlos96Zmanis(), endOfDay: getTzais96Zmanis(), synchronous: true);
    }
    
    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite <em>Shema</em> in the morning) calculated
     * as 3 hours (regular clock hours and not <em>sha'os zmaniyos</em>) before ``ZmanimCalendar#getChatzos()``
     * Generally known as part of the "Komarno" <em>zmanim</em> after <a href=
     * "https://en.wikipedia.org/wiki/Komarno_(Hasidic_dynasty)#Rabbi_Yitzchak_Eisik_Safrin">Rav Yitzchak Eizik of
     * Komarno</a>, a proponent of this calculation, it actually predates him a lot. It is the opinion of the
     * <em>Shach</em> in the Nekudas Hakesef (Yoreh Deah 184), <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=21638&st=&pgnum=30">Rav Moshe Lifshitz</a> in his commentary
     * <a href="https://hebrewbooks.org/pdfpager.aspx?req=21638&st=&pgnum=50">Lechem Mishneh on Brachos 1:2</a>. It is
     * next brought down about 100 years later by the <a href="https://en.wikipedia.org/wiki/Jacob_Emden">Yaavetz</a>
     * (in his <em>siddur</em>, <a href="https://hebrewbooks.org/pdfpager.aspx?req=7920&st=&pgnum=6">Mor Uktziah Orach
     * Chaim 1</a>, <a href="https://hebrewbooks.org/pdfpager.aspx?req=22309&st=&pgnum=30">Lechem Shamayim, Brachos 1:2</a>
     * and <a href="https://hebrewbooks.org/pdfpager.aspx?req=1408&st=&pgnum=69">She'elos Yaavetz vol. 1 no. 40</a>),
     * Rav Yitzchak Eizik of Komarno in the Ma'aseh Oreg on Mishnayos Brachos 11:2, Shevus Yaakov, Chasan Sofer and others.
     * See Yisrael Vehazmanim <a href="https://hebrewbooks.org/pdfpager.aspx?req=9765&st=&pgnum=83">vol. 1 7:3, page 55 -
     * 62</a>. A variant of this calculation ``getSofZmanShmaFixedLocal()`` uses ``getFixedLocalChatzos()`` fixed
     * local <em>chatzos</em> for calculating this type of <em>zman</em>.
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
     *         it does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see  ZmanimCalendar#getChatzos()
     * @see getSofZmanShmaFixedLocal()
     * @see getSofZmanTfila2HoursBeforeChatzos()
     * @see isUseAstronomicalChatzos()
     */
    public func getSofZmanShma3HoursBeforeChatzos() -> Date? {
        return ComplexZmanimCalendar.getTimeOffset(time: getChatzos(), offset: -180 * ComplexZmanimCalendar.MINUTE_MILLIS);
    }
    
    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite Shema in the morning) according to the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based
     * on <em>alos</em> being ``getAlos120()`` 120 minutes or 1/6th of the day before ``getSunrise()``
     * This time is 3 ``getShaahZmanis120Minutes()`` <em>shaos zmaniyos</em> (solar hours) after ``getAlos120()
     * dawn based on the opinion of the MGA that the day is calculated from a ``getAlos120()`` dawn of 120 minutes
     * before sunrise to ``getTzais120()`` nightfall of 120 minutes after sunset. This returns the time of 3
     * ``getShaahZmanis120Minutes()`` after ``getAlos120()`` dawn.
     *
     * - Warning: This is an extremely early <em>zman</em> that is very much a <em>chumra</em>.
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
     *         it does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis120Minutes()
     * @see getAlos120()
     * @see isUseAstronomicalChatzosForOtherZmanim()
     */
    public func getSofZmanShmaMGA120Minutes() -> Date? {
        return getSofZmanShma(startOfDay: getAlos120(), endOfDay: getTzais120(), synchronous: true);
    }
    
    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite <em>Shema</em> in the morning) based
     * on the opinion that the day starts at ``getAlos16Point1Degrees()`` <em>alos</em> 16.1&deg; and ends at
     * ``getSeaLevelSunset()`` This is the opinion of the <a href=
     * "https://hebrewbooks.org/40357">\u05D7\u05D9\u05D3\u05D5\u05E9\u05D9
     * \u05D5\u05DB\u05DC\u05DC\u05D5\u05EA \u05D4\u05E8\u05D6\u05F4\u05D4</a> and the <a href=
     * "https://hebrewbooks.org/14799">\u05DE\u05E0\u05D5\u05E8\u05D4 \u05D4\u05D8\u05D4\u05D5\u05E8\u05D4</a> as
     * mentioned by Yisrael Vehazmanim <a href="https://hebrewbooks.org/pdfpager.aspx?req=9765&pgnum=81">vol 1, sec. 7,
     * ch. 3 no. 16</a>. Three <em>shaos zmaniyos</em> are calculated based on this day and added to ``
     *getAlos16Point1Degrees() <em>alos</em> to reach this time. This time is 3 <em>shaos zmaniyos</em> (solar hours)
     * after ``getAlos16Point1Degrees()`` dawn based on the opinion that the day is calculated from a ``
     *getAlos16Point1Degrees() <em>alos</em> 16.1&deg; to ``getSeaLevelSunset()``
     * <b>Note: </b> Based on this calculation <em>chatzos</em> will not be at midday and ``
     *isUseAstronomicalChatzosForOtherZmanim() will be ignored.
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em> based on this day. If the calculation can't
     *         be computed such as northern and southern locations even south of the Arctic Circle and north of the
     *         Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a nil
     *         will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos16Point1Degrees()
     * @see getSeaLevelSunset()
     */
    public func getSofZmanShmaAlos16Point1ToSunset() -> Date? {
        return getSofZmanShma(startOfDay: getAlos16Point1Degrees(), endOfDay: getElevationAdjustedSunset(), synchronous: false);
    }
    
    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite Shema in the morning) based on the
     * opinion that the day starts at ``getAlos16Point1Degrees()`` <em>alos</em> 16.1&deg; and ends at
     * ``getTzaisGeonim7Point083Degrees()`` <em>tzais</em> 7.083&deg; 3 <em>shaos zmaniyos</em> are calculated
     * based on this day and added to ``getAlos16Point1Degrees()`` <em>alos</em> to reach this time. This time is 3
     * <em>shaos zmaniyos</em> (temporal hours) after ``getAlos16Point1Degrees()`` <em>alos</em> 16.1&deg; based on
     * the opinion that the day is calculated from a ``getAlos16Point1Degrees()`` <em>alos</em> 16.1&deg; to
     * ``getTzaisGeonim7Point083Degrees()`` <em>tzais</em> 7.083&deg;``
     * <b>Note: </b> Based on this calculation <em>chatzos</em> will not be at midday and ``
     *isUseAstronomicalChatzosForOtherZmanim() will be ignored.
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em> based on this calculation. If the
     *         calculation can't be computed such as northern and southern locations even south of the Arctic Circle and
     *         north of the Antarctic Circle where the sun may not reach low enough below the horizon for this
     *         calculation, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getAlos16Point1Degrees()
     * @see getTzaisGeonim7Point083Degrees()
     */
    public func getSofZmanShmaAlos16Point1ToTzaisGeonim7Point083Degrees() -> Date? {
        return getSofZmanShma(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzaisGeonim7Point083Degrees(), synchronous: false);
    }
    
    /**
     * This method returns the latest <em>zman tfila</em> (time to recite the morning prayers) according to the opinion
     * of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based on
     * <em>alos</em> being ``getAlos19Point8Degrees()`` 19.8&deg; before ``getSunrise()`` This time
     * is 4 ``getShaahZmanis19Point8Degrees()`` <em>shaos zmaniyos</em> (solar hours) after
     *``getAlos19Point8Degrees()`` dawn based on the opinion of the MGA that the day is calculated from dawn to
     * nightfall with both being 19.8&deg; below sunrise or sunset. This returns the time of 4 x
     * ``getShaahZmanis19Point8Degrees()`` after ``getAlos19Point8Degrees()`` dawn
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     *
     * @see getShaahZmanis19Point8Degrees()
     * @see getAlos19Point8Degrees()
     * @see isUseAstronomicalChatzosForOtherZmanim()
     */
    public func getSofZmanTfilaMGA19Point8Degrees() -> Date? {
        return getSofZmanTfila(startOfDay: getAlos19Point8Degrees(), endOfDay: getTzais19Point8Degrees(), synchronous: true);
    }
    
    /**
     * This method returns the latest <em>zman tfila</em> (time to recite the morning prayers) according to the opinion
     * of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based on
     * <em>alos</em> being ``getAlos16Point1Degrees()`` 16.1&deg; before ``getSunrise()`` This time
     * is 4 ``getShaahZmanis16Point1Degrees()`` <em>shaos zmaniyos</em> (solar hours) after
     * ``getAlos16Point1Degrees()`` dawn based on the opinion of the MGA that the day is calculated from dawn to
     * nightfall with both being 16.1&deg; below sunrise or sunset. This returns the time of 4 x
     * ``getShaahZmanis16Point1Degrees()`` after ``getAlos16Point1Degrees()`` dawn
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     *
     * @see getShaahZmanis16Point1Degrees()
     * @see getAlos16Point1Degrees()
     */
    public func getSofZmanTfilaMGA16Point1Degrees() -> Date? {
        return getSofZmanTfila(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzais16Point1Degrees(), synchronous: true);
    }
    
    /**
     * This method returns the latest <em>zman tfila</em> (time to recite the morning prayers) according to the opinion
     * of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based on
     * <em>alos</em> being ``getAlos18Degrees()`` 18&deg; before ``getSunrise()`` This time is 4
     * ``getShaahZmanis18Degrees()`` <em>shaos zmaniyos</em> (solar hours) after ``getAlos18Degrees()`` dawn
     * based on the opinion of the MGA that the day is calculated from dawn to nightfall with both being 18&deg;
     * below sunrise or sunset. This returns the time of 4 x ``getShaahZmanis18Degrees()`` after
     * ``getAlos18Degrees()`` dawn
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     *
     * @see getShaahZmanis18Degrees()
     * @see getAlos18Degrees()
     */
    public func getSofZmanTfilaMGA18Degrees() -> Date? {
        return getSofZmanTfila(startOfDay: getAlos18Degrees(), endOfDay: getTzais18Degrees(), synchronous: true);
    }
    
    /**
     * This method returns the latest <em>zman tfila</em> (time to recite the morning prayers) according to the opinion
     * of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based on
     * <em>alos</em> being ``getAlos72()`` 72 minutes before ``getSunrise()`` This time is 4
     * ``getShaahZmanis72Minutes()`` <em>shaos zmaniyos</em> (solar hours) after ``getAlos72()`` dawn based on
     * the opinion of the MGA that the day is calculated from a ``getAlos72()`` dawn of 72 minutes before
     * sunrise to ``getTzais72()`` nightfall of 72 minutes after sunset. This returns the time of 4 x
     * ``getShaahZmanis72Minutes()`` after ``getAlos72()`` dawn. This class returns an identical time to
     * ``getSofZmanTfilaMGA()`` and is repeated here for clarity.
     *
     * @return the <code>Date</code> of the latest <em>zman tfila</em>. If the calculation can't be computed such as in
     *         the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis72Minutes()
     * @see getAlos72()
     * @see getSofZmanShmaMGA()
     */
    public func getSofZmanTfilaMGA72Minutes() -> Date? {
        return getSofZmanTfilaMGA();
    }
    
    /**
     * This method returns the latest <em>zman tfila</em> (time to the morning prayers) according to the opinion of the
     * <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based on <em>alos</em>
     * being ``getAlos72Zmanis()`` 72 minutes <em>zmaniyos</em> before ``getSunrise()`` This time is 4
     * ``getShaahZmanis72MinutesZmanis()`` <em>shaos zmaniyos</em> (solar hours) after ``getAlos72Zmanis()`` dawn
     * based on the opinion of the MGA that the day is calculated from a ``getAlos72Zmanis()`` dawn of 72
     * minutes <em>zmaniyos</em> before sunrise to ``getTzais72Zmanis()`` nightfall of 72 minutes <em>zmaniyos</em>
     * after sunset. This returns the time of 4 x ``getShaahZmanis72MinutesZmanis()`` after ``getAlos72Zmanis()`` dawn
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
     *         it does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis72MinutesZmanis()
     * @see getAlos72Zmanis()
     */
    public func getSofZmanTfilaMGA72MinutesZmanis() -> Date? {
        return getSofZmanTfila(startOfDay: getAlos72Zmanis(), endOfDay: getTzais72Zmanis(), synchronous: true);
    }
    
    /**
     * This method returns the latest <em>zman tfila</em> (time to recite the morning prayers) according to the opinion
     * of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based on
     * <em>alos</em> being ``getAlos90()`` 90 minutes before ``getSunrise()`` This time is 4
     * ``getShaahZmanis90Minutes()`` <em>shaos zmaniyos</em> (solar hours) after ``getAlos90()`` dawn based on
     * the opinion of the MGA that the day is calculated from a ``getAlos90()`` dawn of 90 minutes before sunrise to
     * ``getTzais90()`` nightfall of 90 minutes after sunset. This returns the time of 4 x
     * ``getShaahZmanis90Minutes()`` after ``getAlos90()``dawn
     *
     * @return the <code>Date</code> of the latest <em>zman tfila</em>. If the calculation can't be computed such as in
     *         the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis90Minutes()
     * @see getAlos90()
     */
    public func getSofZmanTfilaMGA90Minutes() -> Date? {
        return getSofZmanTfila(startOfDay: getAlos90(), endOfDay: getTzais90(), synchronous: true);
    }
    
    /**
     * This method returns the latest <em>zman tfila</em> (time to the morning prayers) according to the opinion of the
     * <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based on <em>alos</em>
     * being ``getAlos90Zmanis()`` 90 minutes <em>zmaniyos</em> before ``getSunrise()`` This time is
     * 4 ``getShaahZmanis90MinutesZmanis()`` <em>shaos zmaniyos</em> (solar hours) after ``getAlos90Zmanis()``
     * dawn based on the opinion of the MGA that the day is calculated from a ``getAlos90Zmanis()`` dawn
     * of 90 minutes <em>zmaniyos</em> before sunrise to ``getTzais90Zmanis()`` nightfall of 90 minutes
     * <em>zmaniyos</em> after sunset. This returns the time of 4 x ``getShaahZmanis90MinutesZmanis()`` after
     * ``getAlos90Zmanis()`` dawn
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
     *         it does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis90MinutesZmanis()
     * @see getAlos90Zmanis()
     */
    public func getSofZmanTfilaMGA90MinutesZmanis() -> Date? {
        return getSofZmanTfila(startOfDay: getAlos90Zmanis(), endOfDay: getTzais90Zmanis(), synchronous: true);
    }
    
    /**
     * This method returns the latest <em>zman tfila</em> (time to recite the morning prayers) according to the opinion
     * of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based on
     * <em>alos</em> being ``getAlos96()`` 96 minutes before ``getSunrise()`` This time is 4
     * ``getShaahZmanis96Minutes()`` <em>shaos zmaniyos</em> (solar hours) after ``getAlos96()`` dawn based on
     * the opinion of the MGA that the day is calculated from a ``getAlos96()`` dawn of 96 minutes before
     * sunrise to ``getTzais96()`` nightfall of 96 minutes after sunset. This returns the time of 4 *
     * ``getShaahZmanis96Minutes() after ``getAlos96() dawn``
     *
     * @return the <code>Date</code> of the latest <em>zman tfila</em>. If the calculation can't be computed such as in
     *         the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis96Minutes()
     * @see getAlos96()
     */
    public func getSofZmanTfilaMGA96Minutes() -> Date? {
        return getSofZmanTfila(startOfDay: getAlos96(), endOfDay: getTzais96(), synchronous: true);
    }
    
    /**
     * This method returns the latest <em>zman tfila</em> (time to the morning prayers) according to the opinion of the
     * <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based on <em>alos</em>
     * being ``getAlos96Zmanis()`` 96 minutes <em>zmaniyos</em> before ``getSunrise()`` This time is
     * 4 ``getShaahZmanis96MinutesZmanis()`` <em>shaos zmaniyos</em> (solar hours) after ``getAlos96Zmanis()``
     * dawn based on the opinion of the MGA that the day is calculated from a ``getAlos96Zmanis()`` dawn
     * of 96 minutes <em>zmaniyos</em> before sunrise to ``getTzais96Zmanis()`` nightfall of 96 minutes
     * <em>zmaniyos</em> after sunset. This returns the time of 4 * ``getShaahZmanis96MinutesZmanis() after
     * ``getAlos96Zmanis() dawn``
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
     *         it does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis90MinutesZmanis()
     * @see getAlos90Zmanis()
     */
    public func getSofZmanTfilaMGA96MinutesZmanis() -> Date? {
        return getSofZmanTfila(startOfDay: getAlos96Zmanis(), endOfDay: getTzais96Zmanis(), synchronous: true);
    }
    
    /**
     * This method returns the latest <em>zman tfila</em> (time to recite the morning prayers) according to the opinion
     * of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based on
     * <em>alos</em> being ``getAlos120()`` 120 minutes before ``getSunrise()`` . This time is 4
     * ``getShaahZmanis120Minutes()`` <em>shaos zmaniyos</em> (solar hours) after ``getAlos120()`` dawn
     * based on the opinion of the MGA that the day is calculated from a ``getAlos120()`` dawn of 120
     * minutes before sunrise to ``getTzais120()`` nightfall of 120 minutes after sunset. This returns the time of
     * 4 * ``getShaahZmanis120Minutes() after ``getAlos120() dawn`` This is an extremely early <em>zman</em>
     * that is very much a <em>chumra</em>.
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
     *         it does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis120Minutes()
     * @see getAlos120()
     */
    public func getSofZmanTfilaMGA120Minutes() -> Date? {
        return getSofZmanTfila(startOfDay: getAlos120(), endOfDay: getTzais120(), synchronous: true);
    }
    
    /**
     * This method returns the latest <em>zman tfila</em> (time to recite the morning prayers) calculated as 2 hours
     * before ``ZmanimCalendar#getChatzos()`` This is based on the opinions that calculate
     * <em>sof zman krias shema</em> as ``getSofZmanShma3HoursBeforeChatzos()`` This returns the time of 2 hours
     * before ``ZmanimCalendar#getChatzos()``
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
     *         it does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see  ZmanimCalendar#getChatzos()
     * @see getSofZmanShma3HoursBeforeChatzos()
     */
    public func getSofZmanTfila2HoursBeforeChatzos() -> Date? {
        return ComplexZmanimCalendar.getTimeOffset(time: getChatzos(), offset: -120 * ComplexZmanimCalendar.MINUTE_MILLIS);
    }
    
    /**
     * This method returns <em>mincha gedola</em> calculated as 30 minutes after ``getChatzos()`` <em>chatzos</em>
     * and not 1/2 of a ``getShaahZmanisGra()`` <em>shaah zmanis</em> after ``getChatzos()`` <em>chatzos</em> as
     * calculated by ``getMinchaGedola()`` Some use this time to delay the start of <em>mincha</em> in the winter when
     * 1/2 of a ``getShaahZmanisGra()`` <em>shaah zmanis</em> is less than 30 minutes. See
     * ``getMinchaGedolaGreaterThan30()`` for a convenience method that returns the later of the 2 calculations. One
     * should not use this time to start <em>mincha</em> before the standard ``getMinchaGedola()`` <em>mincha gedola</em>``
     * See Shulchan Aruch <a href="https://hebrewbooks.org/pdfpager.aspx?req=49624&st=&pgnum=291">Orach Chayim 234:1</a> and
     * the Shaar Hatziyon <em>seif katan ches</em>. Since this calculation is a fixed 30 minutes of regular clock time after
     * <em>chatzos</em>, even if ``isUseAstronomicalChatzosForOtherZmanim()`` is <code>false</code>, this <em>mincha
     * gedola</em> time will be affected by ``isUseAstronomicalChatzos()`` and not by
     * ``isUseAstronomicalChatzosForOtherZmanim()``
     *
     * @return the <code>Date</code> of 30 minutes after <em>chatzos</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getMinchaGedola()
     * @see getMinchaGedolaGreaterThan30()
     * @see getChatzos()
     * @see isUseAstronomicalChatzos()
     * @see isUseAstronomicalChatzosForOtherZmanim()
     */
    public func getMinchaGedola30Minutes() -> Date? {
        return ComplexZmanimCalendar.getTimeOffset(time: getChatzos(), offset: ComplexZmanimCalendar.MINUTE_MILLIS * 30);
    }
    
    /**
     * This method returns the time of <em>mincha gedola</em> according to the Magen Avraham with the day starting 72
     * minutes before sunrise and ending 72 minutes after sunset. This is the earliest time to pray <em>mincha</em>. For
     * more information on this see the documentation on ``getMinchaGedola()`` <em>mincha gedola</em> This is
     * calculated as 6.5 ``getTemporalHour()`` solar hours after <em>alos</em>. The calculation used is 6.5 x
     * ``getShaahZmanis72Minutes()`` after ``getAlos72()`` <em>alos</em> If
     * ``isUseAstronomicalChatzosForOtherZmanim()`` is set to <code>true</code>, the calculation will be based on 0.5
     * ``getHalfDayBasedShaahZmanis(Date, Date)`` half-day based <em>sha'ah zmanis</em> between ``getChatzos()``
     * and ``getTzais72()`` after ``getChatzos()``
     *
     * @see getAlos72()
     * @see getMinchaGedola()
     * @see getMinchaKetana()
     * @see  ZmanimCalendar#getMinchaGedola()
     * @see getChatzos()
     * @see isUseAstronomicalChatzosForOtherZmanim()
     * @return the <code>Date</code> of the time of <em>mincha gedola</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getMinchaGedola72Minutes() -> Date? {
        if (isUseAstronomicalChatzosForOtherZmanim()) {
            return getHalfDayBasedZman(startOfHalfDay: getChatzos(), endOfHalfDay: getTzais72(), hours: 0.5);
        } else {
            return getMinchaGedola(startOfDay: getAlos72(), endOfDay: getTzais72(), synchronous: true);
        }
    }
    
    /**
     * This method returns the time of <em>mincha gedola</em> according to the Magen Avraham with the day starting and
     * ending 16.1&deg; below the horizon. This is the earliest time to pray <em>mincha</em>. For more information on
     * this see the documentation on ``getMinchaGedola()`` <em>mincha gedola</em> This is calculated as 6.5
     * ``getTemporalHour()`` solar hours after <em>alos</em>. The calculation used is 6.5 x
     * ``getShaahZmanis16Point1Degrees()`` after ``getAlos16Point1Degrees()`` <em>alos</em> If
     *``isUseAstronomicalChatzosForOtherZmanim()`` is set to <code>true</code>, the calculation will be based on 0.5
     * ``getHalfDayBasedShaahZmanis(Date, Date)`` half-day based <em>sha'ah zmanis</em> between ``getChatzos()``
     * and ``getAlos16Point1Degrees()`` after ``getChatzos()``
     * @see getShaahZmanis16Point1Degrees()
     * @see getMinchaGedola()
     * @see getMinchaKetana()
     * @return the <code>Date</code> of the time of <em>mincha gedola</em>. If the calculation can't be computed such as
     *         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
     *         the sun  may not reach low enough below the horizon for this calculation, a <code>nil</code> will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getMinchaGedola16Point1Degrees() -> Date? {
        if (isUseAstronomicalChatzosForOtherZmanim()) {
            return getHalfDayBasedZman(startOfHalfDay: getChatzos(), endOfHalfDay: getTzais16Point1Degrees(), hours: 0.5);
        } else {
            return getMinchaGedola(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzais16Point1Degrees(), synchronous: true);
        }
        
    }
    
    /**
     * This method returns the time of <em>mincha gedola</em> based on the opinion of <a href=
     * "https://en.wikipedia.org/wiki/Yaakov_Moshe_Hillel">Rabbi Yaakov Moshe Hillel</a> as published in the <em>luach</em>
     * of the Bais Horaah of Yeshivat Chevrat Ahavat Shalom that <em>mincha gedola</em> is calculated as half a <em>shaah
     * zmanis</em> after <em>chatzos</em> with <em>shaos zmaniyos</em> calculated based on a day starting 72 minutes befoe sunrise
     * ``getAlos16Point1Degrees()`` <em>alos</em> 16.1&deg; and ending 13.5 minutes after sunset ``
     * ``getTzaisGeonim3Point7Degrees()`` <em>tzais</em> 3.7&deg; <em>Mincha gedola</em> is the earliest time to pray <em>mincha</em>.
     * The later of this time or 30 clock minutes after <em>chatzos</em> is returned. See ``getMinchaGedolaGreaterThan30()``
     * (though that calculation is based on <em>mincha gedola</em> GRA).
     * For more information about <em>mincha gedola</em> see the documentation on ``getMinchaGedola()`` <em>mincha gedola</em>``
     * Since calculation of this <em>zman</em> involves <em>chatzos</em> that is offset from the center of the astronomical day,
     * ``isUseAstronomicalChatzosForOtherZmanim()`` is N/A here.
     * @return the <code>Date</code> of the <em>mincha gedola</em>. If the calculation can't be computed such as northern and
     *         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not
     *         reach low enough below the horizon for this calculation, a <code>nil</code> will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     *
     * @see getAlos16Point1Degrees()
     * @see getTzaisGeonim3Point7Degrees()
     * @see getShaahZmanisAlos16Point1ToTzais3Point7()
     * @see getMinchaGedolaGreaterThan30()
     */
    public func getMinchaGedolaAhavatShalom() -> Date? {
        if (getMinchaGedola30Minutes() == nil || getMinchaGedola() == nil) {
            return nil;
        } else {
            if getMinchaGedola30Minutes()!.timeIntervalSince1970 > ComplexZmanimCalendar.getTimeOffset(time: getChatzos(), offset: getShaahZmanisAlos16Point1ToTzais3Point7() / 2)!.timeIntervalSince1970 {
                return getMinchaGedola30Minutes()
            } else {
                return ComplexZmanimCalendar.getTimeOffset(time: getChatzos(), offset: getShaahZmanisAlos16Point1ToTzais3Point7() / 2)
            }
        }
    }
    
    /**
     * FIXME check for syncronous
     * This is a convenience method that returns the later of ``getMinchaGedola()`` and
     * ``getMinchaGedola30Minutes()`` In the winter when 1/2 of a ``getShaahZmanisGra()`` <em>shaah zmanis</em> is
     * less than 30 minutes ``getMinchaGedola30Minutes()`` will be returned, otherwise ``getMinchaGedola()``
     * will be returned. Since this calculation can be an offset of <em>chatzos</em> (if 30 clock minutes > 1/2 of a <em>shaah
     * zmanis</em>), even if ``isUseAstronomicalChatzosForOtherZmanim()`` is <code>false</code>, this <em>mincha</em> time
     * may be affected by ``isUseAstronomicalChatzos()``
     *
     * @return the <code>Date</code> of the later of ``getMinchaGedola()`` and ``getMinchaGedola30Minutes()``
     *         If the calculation can't be computed such as in the Arctic Circle where there is at least one day a year
     *         where the sun does not rise, and one where it does not set, a <code>nil</code> will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getMinchaGedola()
     * @see getMinchaGedola30Minutes()
     * @see isUseAstronomicalChatzos()
     *
     */
    public func getMinchaGedolaGreaterThan30() -> Date? {
        if (getMinchaGedola30Minutes() == nil || getMinchaGedola() == nil) {
            return nil;
        } else {
            if getMinchaGedola30Minutes()!.timeIntervalSince1970 > getMinchaGedola()!.timeIntervalSince1970 {
                return getMinchaGedola30Minutes()
            } else {
                return getMinchaGedola()
            }
        }
    }
    
    /**
     * This method returns the time of <em>mincha ketana</em> according to the Magen Avraham with the day starting and
     * ending 16.1&deg; below the horizon. This is the preferred earliest time to pray <em>mincha</em> according to the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Maimonides">Rambam</a> and others. For more information on
     * this see the documentation on ``getMinchaGedola()`` <em>mincha gedola</em> This is calculated as 9.5
     * ``getTemporalHour()`` solar hours after <em>alos</em>. The calculation used is 9.5 x
     * ``getShaahZmanis16Point1Degrees()`` after ``getAlos16Point1Degrees()`` <em>alos</em>``
     *
     * @see getShaahZmanis16Point1Degrees()
     * @see getMinchaGedola()
     * @see getMinchaKetana()
     * @return the <code>Date</code> of the time of <em>mincha ketana</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getMinchaKetana16Point1Degrees() -> Date? {
        return getMinchaKetana(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzais16Point1Degrees(), synchronous: true);
    }
    
    /**
     * This method returns the time of <em>mincha ketana</em> based on the opinion of <a href=
     * "https://en.wikipedia.org/wiki/Yaakov_Moshe_Hillel">Rabbi Yaakov Moshe Hillel</a> as published in the <em>luach</em>
     * of the Bais Horaah of Yeshivat Chevrat Ahavat Shalom that <em>mincha ketana</em> is calculated as 2.5 <em>shaos
     * zmaniyos</em> before ``getTzaisGeonim3Point8Degrees()`` <em>tzais</em> 3.8&deg; with <em>shaos zmaniyos</em>
     * calculated based on a day starting at ``getAlos16Point1Degrees()`` <em>alos</em> 16.1&deg; and ending at
     * <em>tzais</em> 3.8&deg;. <em>Mincha ketana</em> is the preferred earliest time to pray <em>mincha</em> according to
     * the opinion of the <a href="https://en.wikipedia.org/wiki/Maimonides">Rambam</a> and others. For more information
     * on this see the documentation on ``getMinchaKetana()`` <em>mincha ketana</em>``
     *
     * @return the the <code>Date</code> of the time of <em>mincha ketana</em>. If the calculation can't be computed such as
     *         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where the
     *         sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     *
     * @see getShaahZmanisAlos16Point1ToTzais3Point8()
     * @see getMinchaGedolaAhavatShalom()
     * @see getPlagAhavatShalom()
     */
    public func getMinchaKetanaAhavatShalom() -> Date? {
        return ComplexZmanimCalendar.getTimeOffset(
            time: getTzaisGeonim3Point8Degrees(),
            offset: -Double(getShaahZmanisAlos16Point1ToTzais3Point8()) * 2.5);
    }
    
    /**
     * This method returns the time of <em>mincha ketana</em> according to the Magen Avraham with the day
     * starting 72 minutes before sunrise and ending 72 minutes after sunset. This is the preferred earliest time to pray
     * <em>mincha</em> according to the opinion of the <a href="https://en.wikipedia.org/wiki/Maimonides">Rambam</a>
     * and others. For more information on this see the documentation on ``getMinchaGedola()`` <em>mincha gedola</em>``
     * This is calculated as 9.5  ``getShaahZmanis72Minutes()`` after <em>alos</em>. The calculation used is 9.5 x
     * ``getShaahZmanis72Minutes()`` after ``getAlos72()`` <em>alos</em>``
     *
     * @see getShaahZmanis16Point1Degrees()
     * @see getMinchaGedola()
     * @see getMinchaKetana()
     * @return the <code>Date</code> of the time of <em>mincha ketana</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a<code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getMinchaKetana72Minutes() -> Date? {
        return getMinchaKetana(startOfDay: getAlos72(), endOfDay: getTzais72(), synchronous: true);
    }
    
    /**
     * This method returns the time of <em>plag hamincha</em> according to the Magen Avraham with the day starting 60
     * minutes before sunrise and ending 60 minutes after sunset. This is calculated as 10.75 hours after
     * ``getAlos60()`` dawn. The formula used is 10.75 ``getShaahZmanis60Minutes()`` after ``getAlos60()``
     *
     * @return the <code>Date</code> of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     *
     * @see getShaahZmanis60Minutes()
     * @see getAlos60()
     * @see getTzais60()
     */
    public func getPlagHamincha60Minutes() -> Date? {
        return getPlagHamincha(startOfDay: getAlos60(), endOfDay: getTzais60(), synchronous: true);
    }
    
    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em> according to the
     * Magen Avraham with the day starting 72 minutes before sunrise and ending 72 minutes after sunset. This is calculated
     * as 10.75 hours after ``getAlos72()`` dawn. The formula used is 10.75 ``getShaahZmanis72Minutes()`` after
     * ``getAlos72()`` Since <em>plag</em> by this calculation can occur after sunset, it should only be used
     * <em>lechumra</em>.
     *
     * //@Deprecated This method should be used <em>lechumra</em> only since it returns a very late time (often after
     *         <em>shkiah</em>), and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no
     *         current plan to remove this method from the API, and this deprecation is intended to alert developers
     *         of the danger of using it.
     *
     * @return the <code>Date</code> of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     *
     * @see getShaahZmanis72Minutes()
     */
    //@Deprecated // (forRemoval=false) // add back once Java 9 is the minimum supported version
    public func getPlagHamincha72Minutes() -> Date? {
        return getPlagHamincha(startOfDay: getAlos72(), endOfDay: getTzais72(), synchronous: true);
    }
    
    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em> according to the
     * Magen Avraham with the day starting 90 minutes before sunrise and ending 90 minutes after sunset. This is calculated
     * as 10.75 hours after ``getAlos90()`` dawn. The formula used is 10.75 ``getShaahZmanis90Minutes()`` after
     * ``getAlos90()`` Since <em>plag</em> by this calculation can occur after sunset, it should only be used
     * <em>lechumra</em>.
     *
     * //@Deprecated This method should be used <em>lechumra</em> only since it returns a very late time (often after
     *         <em>shkiah</em>), and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no
     *         current plan to remove this method from the API, and this deprecation is intended to alert developers
     *         of the danger of using it.
     *
     * @return the <code>Date</code> of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     *
     * @see getShaahZmanis90Minutes()
     */
    //@Deprecated // (forRemoval=false) // add back once Java 9 is the minimum supported version
    public func getPlagHamincha90Minutes() -> Date? {
        return getPlagHamincha(startOfDay: getAlos90(), endOfDay: getTzais90(), synchronous: true);
    }
    
    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em> according to the Magen
     * Avraham with the day starting 96 minutes before sunrise and ending 96 minutes after sunset. This is calculated as 10.75
     * hours after ``getAlos96()`` dawn. The formula used is 10.75 ``getShaahZmanis96Minutes()`` after
     * ``getAlos96()`` Since <em>plag</em> by this calculation can occur after sunset, it should only be used
     * <em>lechumra</em>.
     *
     * //@Deprecated This method should be used <em>lechumra</em> only since it returns a very late time (often after
     *         <em>shkiah</em>), and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no
     *         current plan to remove this method from the API, and this deprecation is intended to alert developers
     *         of the danger of using it.
     *
     * @return the <code>Date</code> of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanis96Minutes()
     */
    //@Deprecated // (forRemoval=false) // add back once Java 9 is the minimum supported version
    public func getPlagHamincha96Minutes() -> Date? {
        return getPlagHamincha(startOfDay: getAlos96(), endOfDay: getTzais96(), synchronous: true);
    }
    
    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em>. This is calculated
     * as 10.75 hours after ``getAlos96Zmanis()`` dawn The formula used is 10.75 x ``
     *``getShaahZmanis96MinutesZmanis()`` after ``getAlos96Zmanis()`` dawn. Since <em>plag</em> by this calculation can
     * occur after sunset, it should only be used <em>lechumra</em>.
     *
     * //@Deprecated This method should be used <em>lechumra</em> only since it returns a very late time (often after
     *         <em>shkiah</em>), and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no
     *         current plan to remove this method from the API, and this deprecation is intended to alert developers
     *         of the danger of using it.
     *
     * @return the <code>Date</code> of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    //@Deprecated // (forRemoval=false) // add back once Java 9 is the minimum supported version
    public func getPlagHamincha96MinutesZmanis() -> Date? {
        return getPlagHamincha(startOfDay: getAlos96Zmanis(), endOfDay: getTzais96Zmanis(), synchronous: true);
    }
    
    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em>. This is calculated
     * as 10.75 hours after ``getAlos90Zmanis()`` dawn. The formula used is 10.75 x
     *``getShaahZmanis90MinutesZmanis()`` after ``getAlos90Zmanis()`` dawn. Since <em>plag</em> by this calculation can
     * occur after sunset, it should only be used <em>lechumra</em>.
     *
     * //@Deprecated This method should be used <em>lechumra</em> only since it returns a very late time (often after
     *         <em>shkiah</em>), and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no
     *         current plan to remove this method from the API, and this deprecation is intended to alert developers
     *         of the danger of using it.
     *
     * @return the <code>Date</code> of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    //@Deprecated // (forRemoval=false) // add back once Java 9 is the minimum supported version
    public func getPlagHamincha90MinutesZmanis() -> Date? {
        return getPlagHamincha(startOfDay: getAlos90Zmanis(), endOfDay: getTzais90Zmanis(), synchronous: true);
    }
    
    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em>. This is calculated as
     * 10.75 hours after ``getAlos72Zmanis()`` The formula used is 10.75 x ``getShaahZmanis72MinutesZmanis()`` after
     * ``getAlos72Zmanis()`` dawn. Since <em>plag</em> by this calculation can occur after sunset, it should only be used
     * <em>lechumra</em>.
     *
     * //@Deprecated This method should be used <em>lechumra</em> only since it returns a very late time (often after
     *         <em>shkiah</em>), and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no
     *         current plan to remove this method from the API, and this deprecation is intended to alert developers
     *         of the danger of using it.
     *
     * @return the <code>Date</code> of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    //@Deprecated // (forRemoval=false) // add back once Java 9 is the minimum supported version
    public func getPlagHamincha72MinutesZmanis() -> Date? {
        return getPlagHamincha(startOfDay: getAlos72Zmanis(), endOfDay: getTzais72Zmanis(), synchronous: true);
    }
    
    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em> based on the
     * opinion that the day starts at ``getAlos16Point1Degrees()`` <em>alos</em> 16.1&deg; and ends at
     *``getTzais16Point1Degrees()`` <em>tzais</em> 16.1&deg; This is calculated as 10.75 hours <em>zmaniyos</em>
     * after ``getAlos16Point1Degrees()`` dawn. The formula used is 10.75 x ``getShaahZmanis16Point1Degrees()``
     * after ``getAlos16Point1Degrees()`` Since <em>plag</em> by this calculation can occur after sunset, it
     * should only be used <em>lechumra</em>.
     *
     * //@Deprecated This method should be used <em>lechumra</em> only since it returns a very late time (often after
     *         <em>shkiah</em>), and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no
     *         current plan to remove this method from the API, and this deprecation is intended to alert developers
     *         of the danger of using it.
     *
     * @return the <code>Date</code> of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
     *         the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     *
     * @see getShaahZmanis16Point1Degrees()
     */
    //@Deprecated // (forRemoval=false) // add back once Java 9 is the minimum supported version
    public func getPlagHamincha16Point1Degrees() -> Date? {
        return getPlagHamincha(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzais16Point1Degrees(), synchronous: true);
    }
    
    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em> based on the
     * opinion that the day starts at ``getAlos19Point8Degrees()`` <em>alos</em> 19.8&deg; and ends at ``
     *getTzais19Point8Degrees() <em>tzais</em> 19.8&deg; This is calculated as 10.75 hours <em>zmaniyos</em>
     * after ``getAlos19Point8Degrees()`` dawn. The formula used is 10.75 x
     *``getShaahZmanis19Point8Degrees()`` after ``getAlos19Point8Degrees()`` Since <em>plag</em> by this
     * calculation can occur after sunset, it should only be used <em>lechumra</em>.
     *
     * //@Deprecated This method should be used <em>lechumra</em> only since it returns a very late time (often after
     *         <em>shkiah</em>), and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no
     *         current plan to remove this method from the API, and this deprecation is intended to alert developers
     *         of the danger of using it.
     *
     * @return the <code>Date</code> of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
     *         the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     *
     * @see getShaahZmanis19Point8Degrees()
     */
    //@Deprecated // (forRemoval=false) // add back once Java 9 is the minimum supported version
    public func getPlagHamincha19Point8Degrees() -> Date? {
        return getPlagHamincha(startOfDay: getAlos19Point8Degrees(), endOfDay: getTzais19Point8Degrees(), synchronous: true);
    }
    
    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em> based on the
     * opinion that the day starts at ``getAlos26Degrees()`` <em>alos</em> 26&deg; and ends at
     *``getTzais26Degrees()`` <em>tzais</em> 26&deg; This is calculated as 10.75 hours <em>zmaniyos</em> after
     *``getAlos26Degrees()`` dawn The formula used is 10.75 x ``getShaahZmanis26Degrees()`` after
     *``getAlos26Degrees()`` Since the <em>zman</em> based on an extremely early <em>alos</em> and a very late
     * <em>tzais</em>, it should only be used <em>lechumra</em>.
     *
     * //@Deprecated This method should be used <em>lechumra</em> only since it returns a very late time (often after
     *         <em>shkiah</em>), and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no
     *         current plan to remove this method from the API, and this deprecation is intended to alert developers
     *         of the danger of using it.
     *
     * @return the <code>Date</code> of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
     *         the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     *
     * @see getShaahZmanis26Degrees()
     * @see getPlagHamincha120Minutes()
     */
    //@Deprecated // (forRemoval=false) // add back once Java 9 is the minimum supported version
    public func getPlagHamincha26Degrees() -> Date? {
        return getPlagHamincha(startOfDay: getAlos26Degrees(), endOfDay: getTzais26Degrees(), synchronous: true);
    }
    
    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em> based on the
     * opinion that the day starts at ``getAlos18Degrees()`` <em>alos</em> 18&deg; and ends at
     *``getTzais18Degrees()`` <em>tzais</em> 18&deg; This is calculated as 10.75 hours <em>zmaniyos</em> after
     *``getAlos18Degrees()`` dawn. The formula used is 10.75 x ``getShaahZmanis18Degrees()`` after
     *``getAlos18Degrees()`` Since <em>plag</em> by this calculation can occur after sunset, it should only be used
     * <em>lechumra</em>.
     *
     * //@Deprecated This method should be used <em>lechumra</em> only since it returns a very late time (often after
     *         <em>shkiah</em>), and if used <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no
     *         current plan to remove this method from the API, and this deprecation is intended to alert developers
     *         of the danger of using it.
     *
     * @return the <code>Date</code> of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
     *         the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     *
     * @see getShaahZmanis18Degrees()
     */
    //@Deprecated // (forRemoval=false) // add back once Java 9 is the minimum supported version
    public func getPlagHamincha18Degrees() -> Date? {
        return getPlagHamincha(startOfDay: getAlos18Degrees(), endOfDay: getTzais18Degrees(), synchronous: true);
    }
    
    /**
     * This method should be used <em>lechumra</em> only and returns the time of <em>plag hamincha</em> based on the opinion
     * that the day starts at ``getAlos16Point1Degrees()`` <em>alos</em> 16.1&deg; and ends at ``getSunset()``
     * 10.75 <em>shaos zmaniyos</em> are calculated based on this day and added to ``getAlos16Point1Degrees()``
     * <em>alos</em> to reach this time. This time is 10.75 <em>shaos zmaniyos</em> (temporal hours) after
     * ``getAlos16Point1Degrees()`` dawn based on the opinion that the day is calculated from a ``getAlos16Point1Degrees()``
     * dawn of 16.1 degrees before sunrise to ``getSeaLevelSunset()`` This returns the time of 10.75 x
     * the calculated <em>shaah zmanis</em> after ``getAlos16Point1Degrees()`` dawn. Since <em>plag</em> by this
     * calculation can occur after sunset, it should only be used <em>lechumra</em>.
     *
     *
     * @return the <code>Date</code> of the <em>plag</em>. If the calculation can't be computed such as northern and southern
     *         locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not reach
     *         low enough below the horizon for this calculation, a <code>nil</code> will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     *
     * @see getAlos16Point1Degrees()
     * @see getSeaLevelSunset()
     */
    //@Deprecated // (forRemoval=false) // add back once Java 9 is the minimum supported version
    public func getPlagAlosToSunset() -> Date? {
        return getPlagHamincha(startOfDay: getAlos16Point1Degrees(), endOfDay: getElevationAdjustedSunset(), synchronous: false);
    }
    
    /**
     * This method returns the time of <em>plag hamincha</em> based on the opinion that the day starts at
     * ``getAlos16Point1Degrees() <em>alos</em> 16.1&deg; and ends at ``getTzaisGeonim7Point083Degrees()
     * <em>tzais</em>`` 10.75 <em>shaos zmaniyos</em> are calculated based on this day and added to ``
     *getAlos16Point1Degrees() <em>alos</em> to reach this time. This time is 10.75 <em>shaos zmaniyos</em> (temporal
     * hours) after ``getAlos16Point1Degrees() dawn based on the opinion that the day is calculated from a
     * ``getAlos16Point1Degrees() dawn of 16.1 degrees before sunrise to
     * ``getTzaisGeonim7Point083Degrees() <em>tzais</em> . This returns the time of 10.75 * the calculated
     * <em>shaah zmanis</em> after ``getAlos16Point1Degrees() dawn``
     *
     * @return the <code>Date</code> of the <em>plag</em>. If the calculation can't be computed such as northern and
     *         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not
     *         reach low enough below the horizon for this calculation, a <code>nil</code> will be returned. See
     *         detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     *
     * @see getAlos16Point1Degrees()
     * @see getTzaisGeonim7Point083Degrees()
     */
    public func getPlagAlos16Point1ToTzaisGeonim7Point083Degrees() -> Date? {
        return getPlagHamincha(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzaisGeonim7Point083Degrees(), synchronous: false);
    }
    
    /**
     * This method returns the time of <em>plag hamincha</em> (the earliest time that Shabbos can be started) based on the
     * opinion of <a href="https://en.wikipedia.org/wiki/Yaakov_Moshe_Hillel">Rabbi Yaakov Moshe Hillel</a> as published in
     * the <em>luach</em> of the Bais Horaah of Yeshivat Chevrat Ahavat Shalom that that <em>plag hamincha</em> is calculated
     * as 1.25 <em>shaos zmaniyos</em> before ``getTzaisGeonim3Point8Degrees() <em>tzais</em> 3.8&deg; with <em>shaos
     * zmaniyos</em> calculated based on a day starting at ``getAlos16Point1Degrees() <em>alos</em> 16.1&deg; and
     * ending at <em>tzais</em> 3.8&deg;.
     *
     * @return the <code>Date</code> of the <em>plag</em>. If the calculation can't be computed such as northern and
     *         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not
     *         reach low enough below the horizon for this calculation, a <code>nil</code> will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     *
     * @see getShaahZmanisAlos16Point1ToTzais3Point8()
     * @see getMinchaGedolaAhavatShalom()
     * @see getMinchaKetanaAhavatShalom()
     */
    public func getPlagAhavatShalom() -> Date? {
        return ComplexZmanimCalendar.getTimeOffset(time: getTzaisGeonim3Point8Degrees(), offset: -Double(getShaahZmanisAlos16Point1ToTzais3Point8()) * 1.25);
    }
    
    /**
     * Method to return the beginning of <em>bain hashmashos</em> of Rabbeinu Tam calculated when the sun is
     * ``ZENITH_13_POINT_24`` 13.24&deg; below the western ``GEOMETRIC_ZENITH``  (90&deg;)
     * after sunset. This calculation is based on the same calculation of ``getBainHashmashosRT58Point5Minutes()``
     * <em>bain hashmashos</em> Rabbeinu Tam 58.5 minutes but uses a degree-based calculation instead of 58.5 exact
     * minutes. This calculation is based on the position of the sun 58.5 minutes after sunset in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>,
     * which calculates to 13.24&deg; below ``GEOMETRIC_ZENITH``.
     * NOTE: As per Yisrael Vehazmanim Vol. III page 1028, No. 50, a dip of slightly less than 13&deg; should be used.
     * Calculations show that the proper dip to be 13.2456&deg; (truncated to 13.24 that provides about 1.5 second
     * earlier (<em>lechumra</em>) time) below the horizon at that time. This makes a difference of 1 minute and 10
     * seconds in Jerusalem during the Equinox, and 1 minute 29 seconds during the solstice as compared to the proper
     * 13.24&deg; versus 13&deg;. For NY during the solstice, the difference is 1 minute 56 seconds.
     * @todo recalculate the above based on equilux/equinox calculations.
     *
     * @return the <code>Date</code> of the sun being 13.24&deg; below ``GEOMETRIC_ZENITH``
     *         (90&deg;). If the calculation can't be computed such as northern and southern locations even south of the
     *         Arctic Circle and north of the Antarctic Circle where the sun may not reach low enough below the horizon
     *         for this calculation, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     *
     * @see ZENITH_13_POINT_24
     * @see getBainHashmashosRT58Point5Minutes()
     */
    public func getBainHashmashosRT13Point24Degrees() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_13_POINT_24);
    }
    
    /**
     * This method returns the beginning of <em>Bain hashmashos</em> of Rabbeinu Tam calculated as a 58.5
     * minute offset after sunset. <em>bain hashmashos</em> is 3/4 of a <em>Mil</em> before <em>tzais</em> or 3 1/4
     * <em>Mil</em> after sunset. With a <em>Mil</em> calculated as 18 minutes, 3.25 * 18 = 58.5 minutes.
     *
     * @return the <code>Date</code> of 58.5 minutes after sunset. If the calculation can't be computed such as in the
     *         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
     *         not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     *
     */
    public func getBainHashmashosRT58Point5Minutes() -> Date? {
        return ComplexZmanimCalendar.getTimeOffset(time: getElevationAdjustedSunset(), offset: 58.5 * ComplexZmanimCalendar.MINUTE_MILLIS);
    }
    
    /**
     * This method returns the beginning of <em>bain hashmashos</em> based on the calculation of 13.5 minutes (3/4 of an
     * 18-minute <em>Mil</em>) before <em>shkiah</em> calculated as ``getTzaisGeonim7Point083Degrees() 7.083&deg;``.
     *
     * @return the <code>Date</code> of the <em>bain hashmashos</em> of Rabbeinu Tam in this calculation. If the
     *         calculation can't be computed such as northern and southern locations even south of the Arctic Circle and
     *         north of the Antarctic Circle where the sun may not reach low enough below the horizon for this
     *         calculation, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getTzaisGeonim7Point083Degrees()
     */
    public func getBainHashmashosRT13Point5MinutesBefore7Point083Degrees() -> Date? {
        return ComplexZmanimCalendar.getTimeOffset(
            time: getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_7_POINT_083),
            offset: -13.5 * ComplexZmanimCalendar.MINUTE_MILLIS);
    }
    
    /**
     * This method returns the beginning of <em>bain hashmashos</em> of Rabbeinu Tam calculated according to the
     * opinion of the <em>Divrei Yosef</em> (see Yisrael Vehazmanim) calculated 5/18th (27.77%) of the time between
     * <em>alos</em> (calculated as 19.8&deg; before sunrise) and sunrise. This is added to sunset to arrive at the time
     * for <em>bain hashmashos</em> of Rabbeinu Tam.
     *
     * @return the <code>Date</code> of <em>bain hashmashos</em> of Rabbeinu Tam for this calculation. If the
     *         calculation can't be computed such as northern and southern locations even south of the Arctic Circle and
     *         north of the Antarctic Circle where the sun may not reach low enough below the horizon for this
     *         calculation, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getBainHashmashosRT2Stars() -> Date?  {
        let alos19Point8 = getAlos19Point8Degrees();
        let sunrise = getElevationAdjustedSunrise();
        if (alos19Point8 == nil || sunrise == nil) {
            return nil;
        }
        return ComplexZmanimCalendar.getTimeOffset(time: getElevationAdjustedSunset(), offset: ((sunrise!.timeIntervalSince1970 - alos19Point8!.timeIntervalSince1970) * 1000) * (5 / 18));
    }
    
    /**
     * This method returns the beginning of <em>bain hashmashos</em> (twilight) according to the <a href=
     * "https://en.wikipedia.org/wiki/Eliezer_ben_Samuel">Yereim (Rabbi Eliezer of Metz)</a> calculated as 18 minutes
     * or 3/4 of a 24-minute <em>Mil</em> before sunset. According to the Yereim, <em>bain hashmashos</em> starts 3/4
     * of a <em>Mil</em> before sunset and <em>tzais</em> or nightfall starts at sunset.
     *
     * @return the <code>Date</code> of 18 minutes before sunset. If the calculation can't be computed such as in the
     *         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
     *         not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see getBainHashmashosYereim3Point05Degrees()
     */
    public func getBainHashmashosYereim18Minutes() -> Date?  {
        return ComplexZmanimCalendar.getTimeOffset(time: getElevationAdjustedSunset(), offset: -18 * ComplexZmanimCalendar.MINUTE_MILLIS);
    }
    
    /**
     * This method returns the beginning of <em>bain hashmashos</em> (twilight) according to the <a href=
     * "https://en.wikipedia.org/wiki/Eliezer_ben_Samuel">Yereim (Rabbi Eliezer of Metz)</a> calculated as the sun's
     * position 3.05&deg; above the horizon <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>,
     * its position 18 minutes or 3/4 of an 24-minute <em>mil</em> before sunset. According to the Yereim, <em>bain
     * hashmashos</em> starts 3/4 of a <em>Mil</em> before sunset and <em>tzais</em> or nightfall starts at sunset.
     * Note that <em>lechumra</em> (of about 14 seconds) a refraction value of 0.5166&deg; as opposed to the traditional
     * 0.566&deg; is used. This is more inline with the actual refraction in <em>Eretz Yisrael</em> and is brought down
     * by <a href=
     * "http://beinenu.com/rabbis/%D7%94%D7%A8%D7%91-%D7%99%D7%93%D7%99%D7%93%D7%99%D7%94-%D7%9E%D7%A0%D7%AA">Rabbi
     * Yedidya Manet</a> in his <a href="https://www.nli.org.il/en/books/NNL_ALEPH002542826/NLI">Zmanei Halacha
     * Lema’aseh</a> (p. 11). That is the first source that I am aware of that calculates degree-based Yereim
     * <em>zmanim</em>. The 0.5166&deg; refraction is also used by the <a href="https://zmanim.online/">Luach Itim
     * Lebinah</a>. Calculating the Yereim's <em>bain hashmashos</em> using 18-minute based degrees is also suggested
     * in the upcoming 8th edition of the zmanim Kehilchasam. For more details, see the article <a href=
     * "https://kosherjava.com/2020/12/07/the-yereims-bein-hashmashos/">The Yereim’s <em>Bein Hashmashos</em></a>.
     *
     * @todo recalculate based on equinox/equilux
     * @return the <code>Date</code> of the sun's position 3.05&deg; minutes before sunset. If the calculation can't
     *         be computed such as in the Arctic Circle where there is at least one day a year where the sun does not
     *         rise, and one where it does not set, a <code>nil</code> will be returned. See detailed explanation on
     *         top of the ``AstronomicalCalendar`` documentation.
     *
     * @see ZENITH_MINUS_3_POINT_05
     * @see getBainHashmashosYereim18Minutes()
     * @see getBainHashmashosYereim2Point8Degrees()
     * @see getBainHashmashosYereim2Point1Degrees()
     */
    public func getBainHashmashosYereim3Point05Degrees() -> Date?  {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_MINUS_3_POINT_05);
    }
    
    /**
     * This method returns the beginning of <em>bain hashmashos</em> (twilight) according to the <a href=
     * "https://en.wikipedia.org/wiki/Eliezer_ben_Samuel">Yereim (Rabbi Eliezer of Metz)</a> calculated as 16.875
     * minutes or 3/4 of a 22.5-minute <em>Mil</em> before sunset. According to the Yereim, <em>bain hashmashos</em>
     * starts 3/4 of a <em>Mil</em> before sunset and <em>tzais</em> or nightfall starts at sunset.
     *
     * @return the <code>Date</code> of 16.875 minutes before sunset. If the calculation can't be computed such as in the
     *         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
     *         not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     *
     * @see getBainHashmashosYereim2Point8Degrees()
     */
    public func getBainHashmashosYereim16Point875Minutes() -> Date?  {
        return ComplexZmanimCalendar.getTimeOffset(time: getElevationAdjustedSunset(), offset: -16.875 * ComplexZmanimCalendar.MINUTE_MILLIS);
    }
    
    /**
     * This method returns the beginning of <em>bain hashmashos</em> (twilight) according to the <a href=
     * "https://en.wikipedia.org/wiki/Eliezer_ben_Samuel">Yereim (Rabbi Eliezer of Metz)</a> calculated as the sun's
     * position 2.8&deg; above the horizon <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>,
     * its position 16.875 minutes or 3/4 of an 18-minute <em>Mil</em> before sunset. According to the Yereim, <em>bain
     * hashmashos</em> starts 3/4 of a <em>Mil</em> before sunset and <em>tzais</em> or nightfall starts at sunset.
     * Details, including how the degrees were calculated can be seen in the documentation of
     * ``getBainHashmashosYereim3Point05Degrees()``
     *
     * @return the <code>Date</code> of the sun's position 2.8&deg; minutes before sunset. If the calculation can't
     *         be computed such as in the Arctic Circle where there is at least one day a year where the sun does not
     *         rise, and one where it does not set, a <code>nil</code> will be returned. See detailed explanation on
     *         top of the ``AstronomicalCalendar`` documentation.
     *
     * @see ZENITH_MINUS_2_POINT_8
     * @see getBainHashmashosYereim16Point875Minutes()
     * @see getBainHashmashosYereim3Point05Degrees()
     * @see getBainHashmashosYereim2Point1Degrees()
     */
    public func getBainHashmashosYereim2Point8Degrees() -> Date?  {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_MINUS_2_POINT_8);
    }
    
    /**
     * This method returns the beginning of <em>bain hashmashos</em> (twilight) according to the <a href=
     * "https://en.wikipedia.org/wiki/Eliezer_ben_Samuel">Yereim (Rabbi Eliezer of Metz)</a> calculated as 13.5 minutes
     * or 3/4 of an 18-minute <em>Mil</em> before sunset. According to the Yereim, <em>bain hashmashos</em> starts 3/4 of
     * a <em>Mil</em> before sunset and <em>tzais</em> or nightfall starts at sunset.
     *
     * @return the <code>Date</code> of 13.5 minutes before sunset. If the calculation can't be computed such as in the
     *         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
     *         not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     *
     * @see getBainHashmashosYereim2Point1Degrees()
     */
    public func getBainHashmashosYereim13Point5Minutes() -> Date?  {
        return ComplexZmanimCalendar.getTimeOffset(time: getElevationAdjustedSunset(), offset: -13.5 * ComplexZmanimCalendar.MINUTE_MILLIS);
    }
    
    /**
     * This method returns the beginning of <em>bain hashmashos</em> according to the <a href=
     * "https://en.wikipedia.org/wiki/Eliezer_ben_Samuel">Yereim (Rabbi Eliezer of Metz)</a> calculated as the sun's
     * position 2.1&deg; above the horizon <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a> in
     * Yerushalayim, its position 13.5 minutes or 3/4 of an 18-minute <em>Mil</em> before sunset. According to the Yereim,
     * <em>bain hashmashos</em> starts 3/4 of a <em>mil</em> before sunset and <em>tzais</em> or nightfall starts at sunset.
     * Details, including how the degrees were calculated can be seen in the documentation of
     * ``getBainHashmashosYereim3Point05Degrees()``
     *
     * @return the <code>Date</code> of the sun's position 2.1&deg; minutes before sunset. If the calculation can't be
     *         computed such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and
     *         one where it does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     *
     * @see ZENITH_MINUS_2_POINT_1
     * @see getBainHashmashosYereim13Point5Minutes()
     * @see getBainHashmashosYereim2Point8Degrees()
     * @see getBainHashmashosYereim3Point05Degrees()
     */
    public func getBainHashmashosYereim2Point1Degrees() -> Date?  {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_MINUS_2_POINT_1);
    }
    
    /**
     * This method returns the <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> calculated at the
     * sun's position at ``ZENITH_3_POINT_7`` 3.7&deg; below the western horizon.
     *
     * @return the <code>Date</code> representing the time when the sun is 3.7&deg; below sea level.
     * @see ZENITH_3_POINT_7
     */
    public func getTzaisGeonim3Point7Degrees() -> Date?  {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_3_POINT_7);
    }
    
    /**
     * This method returns the <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> calculated at the
     * sun's position at ``ZENITH_3_POINT_8`` 3.8&deg; below the western horizon.
     *
     * @return the <code>Date</code> representing the time when the sun is 3.8&deg; below sea level.
     * @see ZENITH_3_POINT_8
     */
    public func getTzaisGeonim3Point8Degrees() -> Date?  {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_3_POINT_8);
    }
    
    /**
     * This method returns the <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> calculated at the
     * sun's position at ``ZENITH_5_POINT_95`` 5.95&deg; below the western horizon.
     *
     * @return the <code>Date</code> representing the time when the sun is 5.95&deg; below sea level. If the calculation
     *         can't be computed such as northern and southern locations even south of the Arctic Circle and north of
     *         the Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a
     *         <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see ZENITH_5_POINT_95
     */
    public func getTzaisGeonim5Point95Degrees() -> Date?  {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_5_POINT_95);
    }
    
    /**
     * This method returns the <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> calculated as 3/4
     * of a <em><a href= "https://en.wikipedia.org/wiki/Biblical_and_Talmudic_units_of_measurement" >mil</a></em> based
     * on a 24-minute Mil, or 18 minutes. It is the sun's position at ``ZENITH_4_POINT_61`` 4.61&deg; below the
     * western horizon. This is a very early <em>zman</em> and should not be relied on without Rabbinical guidance.
     *
     * @return the <code>Date</code> representing the time when the sun is 4.61&deg; below sea level. If the calculation
     *         can't be computed such as northern and southern locations even south of the Arctic Circle and north of
     *         the Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a
     *         <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see ZENITH_4_POINT_61
     */
    public func getTzaisGeonim4Point61Degrees() -> Date?  {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_4_POINT_61);
    }
    
    /**
     * This method returns the <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> calculated as 3/4
     * of a <a href= "https://en.wikipedia.org/wiki/Biblical_and_Talmudic_units_of_measurement" >Mil</a>, based on a 22.5
     * minute Mil, or 16 7/8 minutes. It is the sun's position at ``ZENITH_4_POINT_37`` 4.37&deg; below the western
     * horizon. This is a very early <em>zman</em> and should not be relied on without Rabbinical guidance.
     *
     * @return the <code>Date</code> representing the time when the sun is 4.37&deg; below sea level. If the calculation
     *         can't be computed such as northern and southern locations even south of the Arctic Circle and north of
     *         the Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a
     *         <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see ZENITH_4_POINT_37
     */
    public func getTzaisGeonim4Point37Degrees() -> Date?  {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_4_POINT_37);
    }
    
    /**
     * This method returns the <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> calculated as 3/4
     * of a 24-minute <em><a href= "https://en.wikipedia.org/wiki/Biblical_and_Talmudic_units_of_measurement" >Mil</a></em>,
     * based on a <em>Mil</em> being 24 minutes, and is calculated as 18 + 2 + 4 for a total of 24 minutes. It is the
     * sun's position at ``ZENITH_5_POINT_88`` 5.88&deg; below the western horizon. This is a very early
     * <em>zman</em> and should not be relied on without Rabbinical guidance.
     *
     * @todo Additional detailed documentation needed.
     * @return the <code>Date</code> representing the time when the sun is 5.88&deg; below sea level. If the calculation
     *         can't be computed such as northern and southern locations even south of the Arctic Circle and north of
     *         the Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a
     *         <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see ZENITH_5_POINT_88
     */
    public func getTzaisGeonim5Point88Degrees() -> Date?  {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_5_POINT_88);
    }
    
    /**
     * This method returns the <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> calculated as 3/4
     * of a <a href= "https://en.wikipedia.org/wiki/Biblical_and_Talmudic_units_of_measurement" >Mil</a> based on the
     * sun's position at ``ZENITH_4_POINT_8`` 4.8&deg; below the western horizon. This is based on Rabbi Leo Levi's
     * calculations. This is the This is a very early <em>zman</em> and should not be relied on without Rabbinical guidance.
     * @todo Additional documentation needed.
     *
     * @return the <code>Date</code> representing the time when the sun is 4.8&deg; below sea level. If the calculation
     *         can't be computed such as northern and southern locations even south of the Arctic Circle and north of
     *         the Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a
     *         <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see ZENITH_4_POINT_8
     */
    public func getTzaisGeonim4Point8Degrees() -> Date?  {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_4_POINT_8);
    }
    
    
    /**
     * This method returns the <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> as calculated by
     * <a href="https://en.wikipedia.org/wiki/Yechiel_Michel_Tucazinsky">Rabbi Yechiel Michel Tucazinsky</a>. It is
     * based on of the position of the sun no later than ``getTzaisGeonim6Point45Degrees() 31 minutes after sunset
     * in Jerusalem the height of the summer solstice and is 28 minutes after <em>shkiah</em> <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>. This
     * computes to 6.45&deg; below the western horizon.
     * @todo Additional documentation details needed.
     *
     * @return the <code>Date</code> representing the time when the sun is 6.45&deg; below sea level. If the
     *         calculation can't be computed such as northern and southern locations even south of the Arctic Circle and
     *         north of the Antarctic Circle where the sun may not reach low enough below the horizon for this
     *         calculation, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see ZENITH_6_POINT_45
     */
    public func getTzaisGeonim6Point45Degrees() -> Date?  {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_6_POINT_45);
    }
    
    /**
     * This method returns the <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> calculated when the
     * sun's position ``ZENITH_7_POINT_083`` 7.083&deg; (or 7&deg; 5\u2032) below the western horizon. This is often
     * referred to as 7&deg;5' or 7&deg; and 5 minutes. This calculation is based on the observation of 3 medium sized
     * stars by Dr. Baruch (Berthold) Cohn in his <em>luach</em> <a href=
     * "https://sammlungen.ub.uni-frankfurt.de/freimann/content/titleinfo/983088">Tabellen enthaltend die Zeitangaben für
     * den Beginn der Nacht und des Tages für die Breitengrade + 66 bis -38</a> published in Strasbourg, France in 1899.
     * This calendar was very popular in Europe, and many other calendars based their time on it. <a href=
     * "https://en.wikipedia.org/wiki/David_Zvi_Hoffmann">Rav Dovid Tzvi Hoffman</a> in his
     * <a href="https://hebrewbooks.org/1053">Sh"Ut Melamed Leho'il</a> in an exchange of letters with Baruch Cohn in <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=1053&st=&pgnum=37">Orach Chaim 30</a> agreed to this <em>zman</em> (page 36),
     * as did the Sh"Ut Bnei Tziyon and the Tenuvas Sadeh. It is very close to the time of the <a href=
     * "https://hebrewbooks.org/22044">Mekor Chesed</a> of the Sefer chasidim. It is close to the position of the sun 30 minutes
     * after sunset in Jerusalem <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>, but not
     * Exactly. The actual position of the sun 30 minutes after sunset in Jerusalem at the equilux is 7.205&deg; and 7.199&deg;
     * at the equinox. See Hazmanim Bahalacha vol 2, pages 520-521 for more details.
     *
     * @return the <code>Date</code> representing the time when the sun is 7.083&deg; below sea level. If the
     *         calculation can't be computed such as northern and southern locations even south of the Arctic Circle and
     *         north of the Antarctic Circle where the sun may not reach low enough below the horizon for this
     *         calculation, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see ZENITH_7_POINT_083
     */
    public func getTzaisGeonim7Point083Degrees() -> Date?  {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_7_POINT_083);
    }
    
    /**
     * This method returns <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> calculated as 45 minutes
     * after sunset during the summer solstice in New York, when the <em>neshef</em> (twilight) is the longest. The sun's
     * position at this time computes to ``ZENITH_7_POINT_67`` 7.75&deg; below the western horizon. See <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=921&pgnum=149">Igros Moshe Even Haezer 4, Ch. 4</a> (regarding
     * <em>tzais</em> for <em>krias Shema</em>). It is also mentioned in Rabbi Heber's <a href=
     * "https://hebrewbooks.org/53000">Shaarei Zmanim</a> on in
     * <a href="https://hebrewbooks.org/pdfpager.aspx?req=53055&pgnum=101">chapter 10 (page 87)</a> and
     * <a href="https://hebrewbooks.org/pdfpager.aspx?req=53055&pgnum=122">chapter 12 (page 108)</a>. Also see the
     * time of 45 minutes in <a href="https://en.wikipedia.org/wiki/Simcha_Bunim_Cohen">Rabbi Simcha Bunim Cohen's</a> <a
     * href="https://www.worldcat.org/oclc/179728985">The radiance of Shabbos</a> as the earliest <em>zman</em> for New York.
     * This <em>zman</em> is also listed in the <a href="https://hebrewbooks.org/pdfpager.aspx?req=1927&pgnum=90">Divrei
     * Shalom Vol. III, chapter 75</a>, and <a href="https://hebrewbooks.org/pdfpager.aspx?req=892&pgnum=431">Bais Av"i
     * Vol. III, chapter 117</a>. This <em>zman</em> is also listed in the Divrei Shalom etc. chapter 177 (FIXME - could not
     * be located). Since this <em>zman</em> depends on the level of light, Rabbi Yaakov Shakow presented this degree-based
     * calculation to Rabbi <a href="https://en.wikipedia.org/wiki/Shmuel_Kamenetsky">Rabbi Shmuel Kamenetsky</a> who agreed
     * to it.
     * @todo add hyperlinks to source of Divrei Shalom once it is located.
     * @return the <code>Date</code> representing the time when the sun is 7.67&deg; below sea level. If the
     *         calculation can't be computed such as northern and southern locations even south of the Arctic Circle and
     *         north of the Antarctic Circle where the sun may not reach low enough below the horizon for this
     *         calculation, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     * @see ZENITH_7_POINT_67
     */
    public func getTzaisGeonim7Point67Degrees() -> Date?  {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_7_POINT_67);
    }
    
    /**
     * This method returns the <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> calculated at the
     * sun's position at ``ZENITH_8_POINT_5`` 8.5&deg; below the western horizon.
     *
     * @return the <code>Date</code> representing the time when the sun is 8.5&deg; below sea level. If the calculation
     *         can't be computed such as northern and southern locations even south of the Arctic Circle and north of
     *         the Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a
     *         <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see ZENITH_8_POINT_5
     */
    public func getTzaisGeonim8Point5Degrees() -> Date?  {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_8_POINT_5);
    }
    
    /**
     * This method returns the <em>tzais</em> (nightfall) based on the calculations used in the <a href=
     * "https://www.worldcat.org/oclc/243303103">Luach Itim Lebinah</a> as the stringent time for <em>tzais</em>.  It is
     * calculated at the sun's position at ``ZENITH_9_POINT_3`` 9.3&deg; below the western horizon.
     *
     * @return the <code>Date</code> representing the time when the sun is 9.3&deg; below sea level. If the calculation
     *         can't be computed such as northern and southern locations even south of the Arctic Circle and north of
     *         the Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a
     *         <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     */
    public func getTzaisGeonim9Point3Degrees() -> Date?  {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_9_POINT_3);
    }
    
    /**
     * This method returns the <em>tzais</em> (nightfall) based on the opinion of the <em>Geonim</em> calculated as 60
     * minutes after sunset <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a>, the
     * day that a solar hour is 60 minutes in New York. The sun's position at this time computes to
     * ``ZENITH_9_POINT_75 9.75&deg; below the western horizon. This is the opinion of <a href=
     * "https://en.wikipedia.org/wiki/Yosef_Eliyahu_Henkin">Rabbi Eliyahu Henkin</a>.  This also follows the opinion of
     * <a href="https://en.wikipedia.org/wiki/Shmuel_Kamenetsky">Rabbi Shmuel Kamenetsky</a>. Rabbi Yaakov Shakow presented
     * these degree-based times to Rabbi Shmuel Kamenetsky who agreed to them.
     *
     * @todo recalculate based on equinox / equilux.
     * @return the <code>Date</code> representing the time when the sun is 9.75&deg; below sea level. If the calculation
     *         can't be computed such as northern and southern locations even south of the Arctic Circle and north of
     *         the Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a
     *         <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     *
     * @see getTzais60()
     */
    public func getTzaisGeonim9Point75Degrees() -> Date?  {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_9_POINT_75);
    }
    
    /**
     * This method returns the <em>tzais</em> (nightfall) based on the opinion of the <a href=
     * "https://en.wikipedia.org/wiki/Yair_Bacharach">Chavas Yair</a> and <a href=
     * "https://he.wikipedia.org/wiki/%D7%9E%D7%9C%D7%9B%D7%99%D7%90%D7%9C_%D7%A6%D7%91%D7%99_%D7%98%D7%A0%D7%A0%D7%91%D7%95%D7%99%D7%9D"
     * >Divrei Malkiel</a> that the time to walk the distance of a <em>Mil</em> is 15 minutes for a total of 60 minutes
     * for 4 <em>Mil</em> after ``getSeaLevelSunset()`` See detailed documentation explaining the
     * 60 minute concept at ``getAlos60()``
     *
     * @return the <code>Date</code> representing 60 minutes after sea level sunset. If the calculation can't be
     *         computed such as in the Arctic Circle where there is at least one day a year where the sun does not rise,
     *         and one where it does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     *
     * @see getAlos60()
     * @see getPlagHamincha60Minutes()
     * @see getShaahZmanis60Minutes()
     */
    public func getTzais60() -> Date?  {
        return ComplexZmanimCalendar.getTimeOffset(time: getElevationAdjustedSunset(), offset: 60 * ComplexZmanimCalendar.MINUTE_MILLIS);
    }
    
    /**
     * This method returns <em>tzais</em> usually calculated as 40 minutes (configurable to any offset via
     * ``setAteretTorahSunsetOffset(ateretTorahSunsetOffset:)``) after sunset. Please note that <em>Chacham</em> Yosef Harari-Raful
     * of Yeshivat Ateret Torah who uses this time, does so only for calculating various other <em>zmanai hayom</em>
     * such as <em>Sof Zman Krias Shema</em> and <em>Plag Hamincha</em>. His calendars do not publish a <em>zman</em>
     * for <em>Tzais</em>. It should also be noted that <em>Chacham</em> Harari-Raful provided a 25 minute <em>zman</em>
     * for Israel. This API uses 40 minutes year round in any place on the globe by default. This offset can be change
     *  by calling ``setAteretTorahSunsetOffset(ateretTorahSunsetOffset:)``
     *
     * @return the <code>Date</code> representing 40 minutes (configurable via ``setAteretTorahSunsetOffset(ateretTorahSunsetOffset:)``)
     *         after sea level sunset. If the calculation can't be computed such as in the Arctic Circle where there is
     *         at least one day a year where the sun does not rise, and one where it does not set, a <code>nil</code> will
     *         be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAteretTorahSunsetOffset()
     * @see setAteretTorahSunsetOffset(double)
     */
    public func getTzaisAteretTorah() -> Date?  {
        return ComplexZmanimCalendar.getTimeOffset(time: getElevationAdjustedSunset(), offset: getAteretTorahSunsetOffset() * ComplexZmanimCalendar.MINUTE_MILLIS);
    }
    
    /**
     * This method returns <em>tzais</em> calculated as however many minutes you pass in the parameter after sunset.
     * @param minutes the amount of minutes tzais is after sunset
     * @return the <code>Date</code> representing however many minutes
     *         after sunset. If the calculation can't be computed such as in the Arctic Circle where there is
     *         at least one day a year where the sun does not rise, and one where it does not set, a <code>nil</code> will
     *         be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getTzaisAteretTorah(minutes:Double) -> Date?  {
        return ComplexZmanimCalendar.getTimeOffset(time: getElevationAdjustedSunset(), offset: minutes * ComplexZmanimCalendar.MINUTE_MILLIS);
    }
    
    /**
     * Returns the offset in minutes after sunset used to calculate <em>tzais</em> based on the calculations of
     * <em>Chacham</em> Yosef Harari-Raful of Yeshivat Ateret Torah calculations. The default value is 40 minutes.
     * This affects most <em>zmanim</em>, since almost all zmanim use subset as part of their calculation.
     *
     * @return the number of minutes after sunset for <em>Tzait</em>.
     * @see setAteretTorahSunsetOffset(double)
     */
    public func getAteretTorahSunsetOffset() -> Double {
        return ateretTorahSunsetOffset;
    }
    
    /**
     * Allows setting the offset in minutes after sunset for the Ateret Torah <em>zmanim</em>. The default if unset is
     * 40 minutes. <em>Chacham</em> Yosef Harari-Raful of Yeshivat Ateret Torah uses 40 minutes globally with the exception
     * of Israel where a 25 minute offset is used. This 40 minute (or any other) offset can be overridden by this method.
     * This offset impacts all Ateret Torah <em>zmanim</em>.
     *
     * @param ateretTorahSunsetOffset
     *            the number of minutes after sunset to use as an offset for the Ateret Torah <em>tzais</em>
     * @see getAteretTorahSunsetOffset()
     */
    public func setAteretTorahSunsetOffset(ateretTorahSunsetOffset:Double) {
        self.ateretTorahSunsetOffset = ateretTorahSunsetOffset;
    }
    
    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite Shema in the morning) based on the
     * calculation of <em>Chacham</em> Yosef Harari-Raful of Yeshivat Ateret Torah, that the day starts
     * ``getAlos72Zmanis()`` 1/10th of the day before sunrise and is usually calculated as ending
     * ``getTzaisAteretTorah()`` 40 minutes after sunset (configurable to any offset via
     * ``setAteretTorahSunsetOffset(ateretTorahSunsetOffset:)``). <em>shaos zmaniyos</em> are calculated based on this day and added
     * to ``getAlos72Zmanis()`` <em>alos</em> to reach this time. This time is 3
     * ``getShaahZmanisAteretTorah()`` <em>shaos zmaniyos</em> (temporal hours) after
     * ``getAlos72Zmanis()`` <em>alos</em> 72 <em>zmaniyos</em> <b>Note: </b> Based on this calculation <em>chatzos</em> will not be at midday.
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em> based on this calculation. If the
     *         calculation can't be computed such as in the Arctic Circle where there is at least one day a year where
     *         the sun does not rise, and one where it does not set, a <code>nil</code> will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos72Zmanis()
     * @see getTzaisAteretTorah()
     * @see getAteretTorahSunsetOffset()
     * @see setAteretTorahSunsetOffset(double)
     * @see getShaahZmanisAteretTorah()
     */
    public func getSofZmanShmaAteretTorah() -> Date?  {
        return getSofZmanShma(startOfDay: getAlos72Zmanis(), endOfDay: getTzaisAteretTorah(), synchronous: false);
    }
    
    /**
     * This method returns the latest <em>zman tfila</em> (time to recite the morning prayers) based on the calculation
     * of <em>Chacham</em> Yosef Harari-Raful of Yeshivat Ateret Torah, that the day starts ``getAlos72Zmanis()``
     * 1/10th of the day before sunrise and is usually calculated as ending ``getTzaisAteretTorah()`` 40 minutes
     * after sunset (configurable to any offset via ``setAteretTorahSunsetOffset(ateretTorahSunsetOffset:)``). <em>shaos zmaniyos</em>
     * are calculated based on this day and added to ``getAlos72Zmanis()`` <em>alos</em> to reach this time. This time
     * is 4 x ``getShaahZmanisAteretTorah()`` <em>shaos zmaniyos</em> (temporal hours) after
     * ``getAlos72Zmanis()`` <em>alos</em> 72 zmaniyos``
     * <b>Note: </b> Based on this calculation <em>chatzos</em> will not be at midday.
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em> based on this calculation. If the
     *         calculation can't be computed such as in the Arctic Circle where there is at least one day a year where
     *         the sun does not rise, and one where it does not set, a <code>nil</code> will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos72Zmanis()
     * @see getTzaisAteretTorah()
     * @see getShaahZmanisAteretTorah()
     * @see setAteretTorahSunsetOffset(double)
     */
    public func getSofZmanTfilaAteretTorah() -> Date?  {
        return getSofZmanTfila(startOfDay: getAlos72Zmanis(), endOfDay: getTzaisAteretTorah(), synchronous: false);
    }
    
    /**
     * This method returns the time of <em>mincha gedola</em> based on the calculation of <em>Chacham</em> Yosef
     * Harari-Raful of Yeshivat Ateret Torah, that the day starts ``getAlos72Zmanis()`` 1/10th of the day
     * before sunrise and is usually calculated as ending ``getTzaisAteretTorah()`` 40 minutes after sunset
     * (configurable to any offset via ``setAteretTorahSunsetOffset(ateretTorahSunsetOffset:))``. This is the preferred earliest
     * time to pray <em>mincha</em> according to the opinion of the <a href="https://en.wikipedia.org/wiki/Maimonides"
     * >Rambam</a> and others. For more information on this see the documentation on ``getMinchaGedola()`` <em>mincha
     * gedola</em> This is calculated as 6.5 ``getShaahZmanisAteretTorah()``  solar hours after <em>alos</em>. The
     * calculation used is 6.5 x ``getShaahZmanisAteretTorah()`` after ``getAlos72Zmanis()`` <em>alos</em>``
     *
     * @see getAlos72Zmanis()
     * @see getTzaisAteretTorah()
     * @see getShaahZmanisAteretTorah()
     * @see getMinchaGedola()
     * @see getMinchaKetanaAteretTorah()
     * @see  ZmanimCalendar#getMinchaGedola()
     * @see getAteretTorahSunsetOffset()
     * @see setAteretTorahSunsetOffset(double)
     *
     * @return the <code>Date</code> of the time of <em>mincha gedola</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getMinchaGedolaAteretTorah() -> Date?  {
        return getMinchaGedola(startOfDay: getAlos72Zmanis(), endOfDay: getTzaisAteretTorah(), synchronous: false);
    }
    
    /**
     * This method returns the time of <em>mincha ketana</em> based on the calculation of
     * <em>Chacham</em> Yosef Harari-Raful of Yeshivat Ateret Torah, that the day starts
     * ``getAlos72Zmanis() 1/10th of the day before sunrise and is usually calculated as ending
     * ``getTzaisAteretTorah() 40 minutes after sunset (configurable to any offset via
     * ``setAteretTorahSunsetOffset(double)). This is the preferred earliest time to pray <em>mincha</em>
     * according to the opinion of the <a href="https://en.wikipedia.org/wiki/Maimonides">Rambam</a> and others.
     * For more information on this see the documentation on ``getMinchaGedola() <em>mincha gedola</em>`` This is
     * calculated as 9.5 ``getShaahZmanisAteretTorah() solar hours after ``getAlos72Zmanis() <em>alos</em>``
     * The calculation used is 9.5 x ``getShaahZmanisAteretTorah()`` after ``getAlos72Zmanis()`` <em>alos</em>``
     *
     * @see getAlos72Zmanis()
     * @see getTzaisAteretTorah()
     * @see getShaahZmanisAteretTorah()
     * @see getAteretTorahSunsetOffset()
     * @see setAteretTorahSunsetOffset(double)
     * @see getMinchaGedola()
     * @see getMinchaKetana()
     * @return the <code>Date</code> of the time of <em>mincha ketana</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getMinchaKetanaAteretTorah() -> Date?  {
        return getMinchaKetana(startOfDay: getAlos72Zmanis(), endOfDay: getTzaisAteretTorah(), synchronous: false);
    }
    
    /**
     * This method returns the time of <em>plag hamincha</em> based on the calculation of <em>Chacham</em> Yosef Harari-Raful
     * of Yeshivat Ateret Torah, that the day starts ``getAlos72Zmanis() 1/10th of the day before sunrise and is
     * usually calculated as ending ``getTzaisAteretTorah() 40 minutes after sunset (configurable to any offset
     * via ``setAteretTorahSunsetOffset(double)). <em>shaos zmaniyos</em> are calculated based on this day and
     * added to ``getAlos72Zmanis() <em>alos</em> to reach this time. This time is 10.75
     * ``getShaahZmanisAteretTorah() <em>shaos zmaniyos</em> (temporal hours) after ``getAlos72Zmanis()
     * dawn``
     *
     * @return the <code>Date</code> of the <em>plag</em>. If the calculation can't be computed such as in the Arctic Circle
     *         where there is at least one day a year where the sun does not rise, and one where it does not set, a nil
     *         will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos72Zmanis()
     * @see getTzaisAteretTorah()
     * @see getShaahZmanisAteretTorah()
     * @see setAteretTorahSunsetOffset(double)
     * @see getAteretTorahSunsetOffset()
     */
    public func getPlagHaminchaAteretTorah() -> Date?  {
        return getPlagHamincha(startOfDay: getAlos72Zmanis(), endOfDay: getTzaisAteretTorah(), synchronous: false);
    }
    
    /**
     * Method to return <em>tzais</em> (dusk) calculated as 13.5 minutes zmaniyos after sunset.
     * - Warning: This zman is EXTREMELY early! It is so early that it was removed from KosherJava since it caused a situation the developer, Eliyahu Hershfeld, was uncomfortable with. The situation was in Canada where a user using his phone saw that this time was listed as the time for nightfall, and he figured that he could end shabbos then. Whie there are no poskim that write to do that! The earliest time that I have found to end shabbos is 20 regular minutes after sunset and that is only in Israel and the surrounding areas. Every where else was recommended 30 minutes at the bare minimum. Therefore, someone who wants to use/include this time has an obligation to make sure that it does not get used for shabbos by dimming it or showing another time.
     * @return the <code>Date</code> representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
     *         a <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see getAlos72Zmanis()
     */
    public func getTzais13Point5MinutesZmanis() -> Date?  {
        let shaahZmanit = getShaahZmanisGra()
        let dakahZmanit = shaahZmanit / 60
        return ComplexZmanimCalendar.getTimeOffset(time: getElevationAdjustedSunset(), offset: (13 * dakahZmanit) + (dakahZmanit / 2))
        //return getZmanisBasedOffset(hours: 0.225);
    }
    
    /**
     * Method to return <em>tzais</em> (dusk) calculated as 72 minutes zmaniyos, or 1/10th of the day after
     * ``getSeaLevelSunset()`` This is the way that the <a href=
     * "https://en.wikipedia.org/wiki/Abraham_Cohen_Pimentel">Minchas Cohen</a> in Ma'amar 2:4 calculates Rebbeinu Tam's
     * time of <em>tzeis</em>. It should be noted that this calculation results in the shortest time from sunset to
     * <em>tzais</em> being during the winter solstice, the longest at the summer solstice and 72 clock minutes at the
     * equinox. This does not match reality, since there is no direct relationship between the length of the day and
     * twilight. The shortest twilight is during the equinox, the longest is during the the summer solstice, and in the
     * winter with the shortest daylight, the twilight period is longer than during the equinoxes.
     *
     * @return the <code>Date</code> representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
     *         a <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see getAlos72Zmanis()
     */
    public func getTzais72Zmanis() -> Date?  {
        return getZmanisBasedOffset(hours: 1.2);
    }
    
    /**
     * A utility method to return <em>alos</em> (dawn) or <em>tzais</em> (dusk) based on a fractional day offset.
     * @param hours the number of <em>shaaos zmaniyos</em> (temporal hours) before sunrise or after sunset that defines dawn
     *        or dusk. If a negative number is passed in, it will return the time of <em>alos</em> (dawn) (subtracting the
     *        time from sunrise) and if a positive number is passed in, it will return the time of <em>tzais</em> (dusk)
     *        (adding the time to sunset). If 0 is passed in, a <code>nil</code> will be returned (since we can't tell if it
     *        is sunrise or sunset based).
     * @return the <code>Date</code> representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
     *         a <code>nil</code> will be returned. A <code>nil</code> will also be returned if 0 is passed in, since we can't
     *         tell if it is sunrise or sunset based. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     */
    private func getZmanisBasedOffset(hours:Double) -> Date?  {
        let shaahZmanis = getShaahZmanisGra();
        if (shaahZmanis == Int64.min || hours == 0) {
            return nil;
        }
        
        if (hours > 0) {
            return ComplexZmanimCalendar.getTimeOffset(time: getElevationAdjustedSunset(), offset: Double(shaahZmanis) * hours);
        } else {
            return ComplexZmanimCalendar.getTimeOffset(time: getElevationAdjustedSunrise(), offset: Double(shaahZmanis) * hours);
        }
    }
    
    /**
     * Method to return <em>tzais</em> (dusk) calculated using 90 minutes zmaniyos or 1/8th of the day after ``
     *getSeaLevelSunset() sea level sunset`` This time is known in Yiddish as the <em>achtel</em> (an eighth)
     * <em>zman</em>.
     *
     * @return the <code>Date</code> representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
     *         a <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see getAlos90Zmanis()
     */
    public func getTzais90Zmanis() -> Date?  {
        return getZmanisBasedOffset(hours: 1.5);
    }
    
    /**
     * Method to return <em>tzais</em> (dusk) calculated using 96 minutes <em>zmaniyos</em> or 1/7.5 of the day after
     * ``getSeaLevelSunset()``
     *
     * @return the <code>Date</code> representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
     *         a <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see getAlos96Zmanis()
     */
    public func getTzais96Zmanis() -> Date?  {
        return getZmanisBasedOffset(hours: 1.6);
    }
    
    /**
     * Method to return <em>tzais</em> (dusk) calculated as 90 minutes after sea level sunset. This method returns
     * <em>tzais</em> (nightfall) based on the opinion of the Magen Avraham that the time to walk the distance of a
     * <em>Mil</em> according to the <a href="https://en.wikipedia.org/wiki/Maimonides">Rambam</a>'s opinion
     * is 18 minutes for a total of 90 minutes based on the opinion of Ula who calculated <em>tzais</em> as 5
     * <em>Mil</em> after sea level <em>shkiah</em> (sunset). A similar calculation ``getTzais19Point8Degrees()
     * uses solar position calculations based on this time.
     *
     * @return the <code>Date</code> representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
     *         a <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see getTzais19Point8Degrees()
     * @see getAlos90()
     */
    public func getTzais90() -> Date?  {
        return ComplexZmanimCalendar.getTimeOffset(time: getElevationAdjustedSunset(), offset: 90 * ComplexZmanimCalendar.MINUTE_MILLIS);
    }
    
    /**
     * This method should be used <em>lechumra</em> only and returns <em>tzais</em> (nightfall) based on the calculations
     * of <a href="https://en.wikipedia.org/wiki/Avraham_Chaim_Naeh">Rav Chaim Naeh</a> that the time to walk the
     * distance of a <em>Mil</em> according to the <a href="https://en.wikipedia.org/wiki/Maimonides">Rambam</a>'s opinion
     * is 2/5 of an hour (24 minutes) for a total of 120 minutes based on the opinion of <em>Ula</em> who calculated
     * <em>tzais</em> as 5 <em>Mil</em> after sea level <em>shkiah</em> (sunset). A similar calculation ``
     *getTzais26Degrees() uses degree-based calculations based on this 120 minute calculation. Since the <em>zman</em>
     * is extremely late and at a point that is long past the 18&deg; point where the darkest point is
     * reached, it should only be used <em>lechumra</em>, such as delaying the start of nighttime <em>mitzvos</em>.
     *
     * //@Deprecated This method should be used <em>lechumra</em> only since it returns a very late time, and if used
     *         <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no current plan to remove this
     *         method from the API, and this deprecation is intended to alert developers of the danger of using it.
     *
     * @return the <code>Date</code> representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
     *         a <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see getTzais26Degrees()
     * @see getAlos120()
     */
    ////@Deprecated // (forRemoval=false) // add back once Java 9 is the minimum supported version
    public func getTzais120() -> Date?  {
        return ComplexZmanimCalendar.getTimeOffset(time: getElevationAdjustedSunset(), offset: 120 * ComplexZmanimCalendar.MINUTE_MILLIS);
    }
    
    /**
     * This method should be used <em>lechumra</em> only and returns <em>tzais</em> (dusk) calculated using 120 minutes
     * <em>zmaniyos</em> after ``getSeaLevelSunset()`` Since the <em>zman</em>
     * is extremely late and at a point when the it is long past the 18&deg; point where the darkest point is
     * reached, it should only be used <em>lechumra</em>, such as delaying the start of nighttime <em>mitzvos</em>.
     *
     * //@Deprecated This method should be used <em>lechumra</em> only since it returns a very late time, and if used
     *         <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no current plan to remove this
     *         method from the API, and this deprecation is intended to alert developers of the danger of using it.
     *
     * @return the <code>Date</code> representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
     *         a <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see getAlos120Zmanis()
     * @see getTzais120()
     * @see getTzais26Degrees()
     */
    ////@Deprecated // (forRemoval=false) // add back once Java 9 is the minimum supported version
    public func getTzais120Zmanis() -> Date?  {
        return getZmanisBasedOffset(hours: 2.0);
    }
    
    /**
     * This calculates the time of <em>tzais</em> at the point when the sun is 16.1&deg; below the horizon. This is
     * the sun's dip below the horizon 72 minutes after sunset according Rabbeinu Tam's calculation of <em>tzais</em>
     * <a href=
     * "https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/">around the equinox / equilux</a> in
     * Jerusalem. The question of equinox VS equilux is complex, with Rabbi Meir Posen in the <a href=
     * "https://www.worldcat.org/oclc/956316270">Ohr Meir</a> of the opinion that the equilux should be used. See
     * Yisrael Vehazmanim vol I, 34:1:4. Rabbi Yedidya Manet in his <a href=
     * "https://www.nli.org.il/en/books/NNL_ALEPH002542826/NLI">Zmanei Halacha Lema'aseh</a> (4th edition part 2, pages
     * and 22 and 24) and Rabbi Yonah Metzbuch (in a letter published by Rabbi Manet) are of the opinion that the
     * astronomical equinox should be used. The difference adds up to about 9 seconds, too trivial to make much of a
     * difference. For information on how this is calculated see the comments on ``getAlos16Point1Degrees()``
     *
     * @return the <code>Date</code> representing the time. If the calculation can't be computed such as northern and
     *         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may
     *         not reach low enough below the horizon for this calculation, a <code>nil</code> will be returned. See
     *         detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getTzais72()
     * @see getAlos16Point1Degrees() for more information on this calculation.
     */
    public func getTzais16Point1Degrees() -> Date?  {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_16_POINT_1);
    }
    
    /**
     * This method should be used <em>lechumra</em> only and returns <em>tzais</em> based on when the sun is 26&deg;
     * below the horizon.For information on how this is calculated see the comments on ``getAlos26Degrees()``
     * Since the <em>zman</em> is extremely late and at a point when it is long past the 18&deg; point where the
     * darkest point is reached, it should only be used <em>lechumra</em> such as delaying the start of nighttime
     * <em>mitzvos</em>.
     *
     * //@Deprecated This method should be used <em>lechumra</em> only since it returns a very late time, and if used
     *         <em>lekula</em> can result in <em>chillul Shabbos</em> etc. There is no current plan to remove this
     *         method from the API, and this deprecation is intended to alert developers of the danger of using it.
     *
     * @return the <code>Date</code> representing the time. If the calculation can't be computed such as northern and
     *         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may
     *         not reach low enough below the horizon for this calculation, a <code>nil</code> will be returned. See
     *         detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getTzais120()
     * @see getAlos26Degrees()
     */
    ////@Deprecated // (forRemoval=false) // add back once Java 9 is the minimum supported version
    public func getTzais26Degrees() -> Date?  {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_26_DEGREES);
    }
    
    /**
     * For information on how this is calculated see the comments on ``getAlos18Degrees()
     *
     * @return the <code>Date</code> representing the time. If the calculation can't be computed such as northern and
     *         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may
     *         not reach low enough below the horizon for this calculation, a <code>nil</code> will be returned. See
     *         detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos18Degrees()
     */
    public func getTzais18Degrees() -> Date?  {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ASTRONOMICAL_ZENITH);
    }
    
    /**
     * For information on how this is calculated see the comments on ``getAlos19Point8Degrees
     *
     * @return the <code>Date</code> representing the time. If the calculation can't be computed such as northern and
     *         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may
     *         not reach low enough below the horizon for this calculation, a <code>nil</code> will be returned. See
     *         detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getTzais90()
     * @see getAlos19Point8Degrees()
     */
    public func getTzais19Point8Degrees() -> Date?  {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_19_POINT_8);
    }
    
    /**
     * A method to return <em>tzais</em> (dusk) calculated as 96 minutes after sea level sunset. For information on how
     * this is calculated see the comments on ``getAlos96()``
     *
     * @return the <code>Date</code> representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
     *         a <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     * @see getAlos96()
     */
    public func getTzais96() -> Date?  {
        return ComplexZmanimCalendar.getTimeOffset(time: getElevationAdjustedSunset(), offset: 96 * ComplexZmanimCalendar.MINUTE_MILLIS);
    }
    
    /**
     * A method that returns the local time for fixed <em>chatzos</em>. This time is noon and midnight adjusted from
     * standard time to account for the local latitude. The 360&deg; of the globe divided by 24 calculates to 15&deg;
     * per hour with 4 minutes per degree, so at a longitude of 0 , 15, 30 etc... <em>Chatzos</em> is at exactly 12:00
     * noon. This is the time of <em>chatzos</em> according to the <a href=
     * "https://en.wikipedia.org/wiki/Aruch_HaShulchan">Aruch Hashulchan</a> in <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=7705&pgnum=426">Orach Chaim 233:14</a> and <a href=
     * "https://en.wikipedia.org/wiki/Moshe_Feinstein">Rabbi Moshe Feinstein</a> in Igros Moshe <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=916&st=&pgnum=67">Orach Chaim 1:24</a> and <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=14675&pgnum=191">2:20</a>.
     * Lakewood, N.J., with a longitude of -74.222, is 0.778 away from the closest multiple of 15 at -75&deg;. This
     * is multiplied by 4 to yield 3 minutes and 7 seconds for a <em>chatzos</em> of 11:56:53. This method is not tied
     * to the theoretical 15&deg; timezones, but will adjust to the actual timezone and <a
     * href="https://en.wikipedia.org/wiki/Daylight_saving_time">Daylight saving time</a>.
     *
     * @return the Date representing the local <em>chatzos</em>
     * @see  GeoLocation#getLocalMeanTimeOffset()
     * @see  AstronomicalCalendar#getLocalMeanTime(double)
     */
    public func getFixedLocalChatzos() -> Date?  {
        return getLocalMeanTime(hours: 12.0);
    }
    
    /**
     * Returns the latest time of <em>Kidush Levana</em> according to the <a
     * href="https://en.wikipedia.org/wiki/Yaakov_ben_Moshe_Levi_Moelin">Maharil's</a> opinion that it is calculated as
     * halfway between <em>molad</em> and <em>molad</em>. This adds half the 29 days, 12 hours and 793 chalakim time
     * between <em>molad</em> and <em>molad</em> (14 days, 18 hours, 22 minutes and 666 milliseconds) to the month's <em>molad</em>.
     * If the time of <em>sof zman Kiddush Levana</em> occurs during the day (between the <em>alos</em> and <em>tzais</em> passed in
     * as parameters), it returns the <em>alos</em> passed in. If a <code>nil</code> <em>alos</em> or <em>tzais</em> are passed to
     * this method, the non-daytime adjusted time will be returned.
     *
     * @param alos
     *            the beginning of the Jewish day. If <em>Kidush Levana</em> occurs during the day (starting at <em>alos</em> and
     *            ending at <em>tzais</em>), the time returned will be <em>alos</em>. If either the <em>alos</em> or <em>tzais</em>
     *            parameters are nil, no daytime adjustment will be made.
     * @param tzais
     *            the end of the Jewish day. If Kidush Levana occurs during the day (starting at <em>alos</em> and ending at
     *            <em>tzais</em>), the time returned will be <em>alos</em>. If either the <em>alos</em> or <em>tzais</em> parameter
     *            are nil, no daytime adjustment will be made.
     * @return the Date representing the moment halfway between molad and molad. If the time occurs between
     *         <em>alos</em> and <em>tzais</em>, <em>alos</em> will be returned. If the <em>zman</em> will not occur on this day, a
     *         <code>nil</code> will be returned.
     * @see getSofZmanKidushLevanaBetweenMoldos()
     * @see getSofZmanKidushLevana15Days(Date, Date)
     * @see  JewishCalendar#getSofZmanKidushLevanaBetweenMoldos()
     */
    public func getSofZmanKidushLevanaBetweenMoldos(alos:Date?, tzais:Date?) -> Date? {
        let jewishCalendar = JewishCalendar();
        var gregorianCalendar = Calendar(identifier: .gregorian)
        gregorianCalendar.timeZone = getGeoLocation().getTimeZone()
        jewishCalendar.setGregorianDate(year: gregorianCalendar.component(.year, from: workingDate), month: gregorianCalendar.component(.month, from: workingDate), dayOfMonth: gregorianCalendar.component(.day, from: workingDate));
        
        // Do not calculate for impossible dates, but account for extreme cases. In the extreme case of Rapa Iti in French
        // Polynesia on Dec 2027 when kiddush Levana 3 days can be said on <em>Rosh Chodesh</em>, the sof zman Kiddush Levana
        // will be on the 12th of the Teves. In the case of Anadyr, Russia on Jan, 2071, sof zman Kiddush Levana between the
        // moldos will occur is on the night of 17th of Shevat. See Rabbi Dovid Heber's Shaarei Zmanim chapter 4 (pages 28 and 32).
        if (jewishCalendar.getJewishDayOfMonth() < 11 || jewishCalendar.getJewishDayOfMonth() > 16) {
            return nil;
        }
        return getMoladBasedTime(moladBasedTime: jewishCalendar.getSofZmanKidushLevanaBetweenMoldos(), alos: alos, tzais: tzais, techila: false);
    }
    
    /**
     * Returns the Date of the <em>molad</em> based time if it occurs on the current date. Since <em>Kiddush Levana</em>
     * can only be said during the day, there are parameters to limit it to between <em>alos</em> and <em>tzais</em>. If
     * the time occurs between <em>alos</em> and <em>tzais</em>, <em>tzais</em> will be returned.
     *
     * @param moladBasedTime
     *            the <em>molad</em> based time such as <em>molad</em>, <em>tchilas</em> and <em>sof zman Kiddush Levana</em>
     * @param alos
     *            optional start of day to limit <em>molad</em> times to the end of the night before or beginning of the next night.
     *            Ignored if either <em>alos</em> or <em>tzais</em> are nil.
     * @param tzais
     *            optional end of day to limit <em>molad</em> times to the end of the night before or beginning of the next night.
     *            Ignored if either <em>tzais</em> or <em>alos</em> are nil
     * @param techila
     *            is it the start of <em>Kiddush Levana</em> time or the end? If it is start roll it to the next <em>tzais</em>, and
     *            and if it is the end, return the end of the previous night (<em>alos</em> passed in). Ignored if either
     *            <em>alos</em> or <em>tzais</em> are nil.
     * @return the <em>molad</em> based time. If the <em>zman</em> does not occur during the current date, <code>nil</code> will be
     *         returned.
     */
    private func getMoladBasedTime(moladBasedTime:Date, alos:Date?, tzais:Date?, techila:Bool) -> Date? {
        let lastMidnight = getMidnightLastNight();
        let midnightTonight = getMidnightTonight();
        if (!(moladBasedTime.compare(lastMidnight) == .orderedAscending || moladBasedTime.compare(midnightTonight) == .orderedDescending)){
            if (alos != nil || tzais != nil) {
                if (techila && !(moladBasedTime.compare(tzais!) == .orderedAscending || moladBasedTime.compare(alos!) == .orderedDescending)){
                    return tzais;
                } else {
                    return alos;
                }
            }
            return moladBasedTime;
        }
        return nil;
    }
    
    /**
     * Returns the latest time of Kiddush Levana according to the <a
     * href="https://en.wikipedia.org/wiki/Yaakov_ben_Moshe_Levi_Moelin">Maharil's</a> opinion that it is calculated as
     * halfway between <em>molad</em> and <em>molad</em>. This adds half the 29 days, 12 hours and 793 chalakim time between
     * <em>molad</em> and <em>molad</em> (14 days, 18 hours, 22 minutes and 666 milliseconds) to the month's <em>molad</em>.
     * The <em>sof zman Kiddush Levana</em> will be returned even if it occurs during the day. To limit the time to between
     * <em>tzais</em> and <em>alos</em>, see ``getSofZmanKidushLevanaBetweenMoldos(alos:tzais:)``
     *
     * @return the Date representing the moment halfway between molad and molad. If the time occurs between
     *         <em>alos</em> and <em>tzais</em>, <em>alos</em> will be returned. If the <em>zman</em> will not occur on this
     *         day, a <code>nil</code> will be returned.
     * @see getSofZmanKidushLevanaBetweenMoldos(Date, Date)
     * @see getSofZmanKidushLevana15Days()
     * @see  JewishCalendar#getSofZmanKidushLevanaBetweenMoldos()
     */
    public func getSofZmanKidushLevanaBetweenMoldos() -> Date? {
        return getSofZmanKidushLevanaBetweenMoldos(alos: nil, tzais: nil);
    }
    
    /**
     * Returns the latest time of <em>Kiddush Levana</em> calculated as 15 days after the <em>molad</em>. This is the
     * opinion brought down in the Shulchan Aruch (Orach Chaim 426). It should be noted that some opinions hold that the
     * <a href="https://en.wikipedia.org/wiki/Moses_Isserles">Rema</a> who brings down the opinion of the <a
     * href="https://en.wikipedia.org/wiki/Yaakov_ben_Moshe_Levi_Moelin">Maharil's</a> of calculating
     * ``getSofZmanKidushLevanaBetweenMoldos(alos:tzais:)`` half way between <em>molad</em> and <em>molad</em> is of
     * the opinion that the Mechaber agrees to his opinion. Also see the Aruch Hashulchan. For additional details on the subject,
     * see Rabbi Dovid Heber's very detailed write-up in <em>Siman Daled</em> (chapter 4) of <a href=
     * "https://hebrewbooks.org/53000">Shaarei Zmanim</a>. If the time of <em>sof zman Kiddush Levana</em> occurs during
     * the day (between the <em>alos</em> and <em>tzais</em> passed in as parameters), it returns the <em>alos</em> passed in. If a
     * nil <em>alos</em> or <em>tzais</em> are passed to this method, the non-daytime adjusted time will be returned.
     *
     * @param alos
     *            the beginning of the Jewish day. If <em>Kidush Levana</em> occurs during the day (starting at <em>alos</em> and
     *            ending at <em>tzais</em>), the time returned will be <em>alos</em>. If either the <em>alos</em> or <em>tzais</em>
     *            parameters are nil, no daytime adjustment will be made.
     * @param tzais
     *            the end of the Jewish day. If <em>Kidush Levana</em> occurs during the day (starting at <em>alos</em> and ending at
     *            <em>tzais</em>), the time returned will be <em>alos</em>. If either the <em>alos</em> or <em>tzais</em> parameters
     *            are nil, no daytime adjustment will be made.
     *
     * @return the Date representing the moment 15 days after the molad. If the time occurs between <em>alos</em> and
     *         <em>tzais</em>, <em>alos</em> will be returned. If the <em>zman</em> will not occur on this day, a
     *         <code>nil</code> will be returned.
     *
     * @see getSofZmanKidushLevanaBetweenMoldos(Date, Date)
     * @see  JewishCalendar#getSofZmanKidushLevana15Days()
     */
    public func getSofZmanKidushLevana15Days(alos:Date?, tzais:Date?) -> Date? {
        let jewishCalendar = JewishCalendar();
        var gregorianCalendar = Calendar(identifier: .gregorian)
        gregorianCalendar.timeZone = getGeoLocation().getTimeZone()
        jewishCalendar.setGregorianDate(year: gregorianCalendar.component(.year, from: workingDate), month: gregorianCalendar.component(.month, from: workingDate), dayOfMonth: gregorianCalendar.component(.day, from: workingDate));
        // Do not calculate for impossible dates, but account for extreme cases. In the extreme case of Rapa Iti in
        // French Polynesia on Dec 2027 when kiddush Levana 3 days can be said on <em>Rosh Chodesh</em>, the sof zman Kiddush
        // Levana will be on the 12th of the Teves. in the case of Anadyr, Russia on Jan, 2071, sof zman kiddush levana will
        // occur after midnight on the 17th of Shevat. See Rabbi Dovid Heber's Shaarei Zmanim chapter 4 (pages 28 and 32).
        if (jewishCalendar.getJewishDayOfMonth() < 11 || jewishCalendar.getJewishDayOfMonth() > 17) {
            return nil;
        }
        return getMoladBasedTime(moladBasedTime: jewishCalendar.getSofZmanKidushLevana15Days(), alos: alos, tzais: tzais, techila: false);
    }
    
    /**
     * Returns the latest time of <em>Kiddush Levana</em> calculated as 15 days after the molad. This is the opinion of
     * the Shulchan Aruch (Orach Chaim 426). It should be noted that some opinions hold that the
     * <a href="https://en.wikipedia.org/wiki/Moses_Isserles">Rema</a> who brings down the opinion of the <a
     * href="https://en.wikipedia.org/wiki/Yaakov_ben_Moshe_Levi_Moelin">Maharil's</a> of calculating
     * ``getSofZmanKidushLevanaBetweenMoldos(alos:tzais:)`` half way between <em>molad</em> and <em>molad</em> is of
     * the opinion that the Mechaber agrees to his opinion. Also see the Aruch Hashulchan. For additional details on the subject,
     * See Rabbi Dovid Heber's very detailed write-up in Siman Daled (chapter 4) of <a href="https://hebrewbooks.org/53000">Shaarei
     * Zmanim</a>. The <em>sof zman Kiddush Levana</em> will be returned even if it occurs during the day. To limit the time to
     * between <em>tzais</em> and <em>alos</em>, see ``getSofZmanKidushLevana15Days(alos:tzais:)``
     *
     * @return the Date representing the moment 15 days after the <em>molad</em>. If the time occurs between
     *         <em>alos</em> and <em>tzais</em>, <em>alos</em> will be returned. If the <em>zman</em> will not occur on this day, a
     *         <code>nil</code> will be returned.
     *
     * @see getSofZmanKidushLevana15Days(Date, Date)
     * @see getSofZmanKidushLevanaBetweenMoldos()
     * @see  JewishCalendar#getSofZmanKidushLevana15Days()
     *
     */
    public func getSofZmanKidushLevana15Days() -> Date? {
        return getSofZmanKidushLevana15Days(alos: nil, tzais: nil);
    }
    
    /**
     * Returns the earliest time of <em>Kiddush Levana</em> according to <a href=
     * "https://en.wikipedia.org/wiki/Yonah_Gerondi">Rabbeinu Yonah</a>'s opinion that it can be said 3 days after the
     * <em>molad</em>. The time will be returned even if it occurs during the day when <em>Kiddush Levana</em> can't be said.
     * Use ``getTchilasZmanKidushLevana3Days(alos:tzais:)`` if you want to limit the time to night hours.
     *
     * @return the Date representing the moment 3 days after the molad. If the <em>zman</em> will not occur on this day, a
     *         <code>nil</code> will be returned.
     * @see getTchilasZmanKidushLevana3Days(Date, Date)
     * @see getTchilasZmanKidushLevana7Days()
     * @see  JewishCalendar#getTchilasZmanKidushLevana3Days()
     */
    public func getTchilasZmanKidushLevana3Days() -> Date? {
        return getTchilasZmanKidushLevana3Days(alos: nil, tzais: nil);
    }
    
    /**
     * Returns the earliest time of <em>Kiddush Levana</em> according to <a href=
     * "https://en.wikipedia.org/wiki/Yonah_Gerondi">Rabbeinu Yonah</a>'s opinion that it can be said 3 days after the <em>molad</em>.
     * If the time of <em>tchilas zman Kiddush Levana</em> occurs during the day (between <em>alos</em> and <em>tzais</em> passed to
     * this method) it will return the following <em>tzais</em>. If nil is passed for either <em>alos</em> or <em>tzais</em>, the actual
     * <em>tchilas zman Kiddush Levana</em> will be returned, regardless of if it is during the day or not.
     *
     * @param alos
     *            the beginning of the Jewish day. If Kidush Levana occurs during the day (starting at <em>alos</em> and ending
     *            at <em>tzais</em>), the time returned will be <em>tzais</em>. If either the <em>alos</em> or <em>tzais</em> parameters
     *            are nil, no daytime adjustment will be made.
     * @param tzais
     *            the end of the Jewish day. If <em>Kidush Levana</em> occurs during the day (starting at <em>alos</em> and ending at
     *            <em>tzais</em>), the time returned will be <em>tzais</em>. If either the <em>alos</em> or <em>tzais</em> parameters
     *            are nil, no daytime adjustment will be made.
     *
     * @return the Date representing the moment 3 days after the molad. If the time occurs between <em>alos</em> and
     *         <em>tzais</em>, <em>tzais</em> will be returned. If the <em>zman</em> will not occur on this day, a
     *         <code>nil</code> will be returned.
     * @see getTchilasZmanKidushLevana3Days()
     * @see getTchilasZmanKidushLevana7Days(Date, Date)
     * @see  JewishCalendar#getTchilasZmanKidushLevana3Days()
     */
    public func getTchilasZmanKidushLevana3Days(alos:Date?, tzais:Date?) -> Date? {
        let jewishCalendar = JewishCalendar();
        var gregorianCalendar = Calendar(identifier: .gregorian)
        gregorianCalendar.timeZone = getGeoLocation().getTimeZone()
        jewishCalendar.setGregorianDate(year: gregorianCalendar.component(.year, from: workingDate), month: gregorianCalendar.component(.month, from: workingDate), dayOfMonth: gregorianCalendar.component(.day, from: workingDate));
        
        // Do not calculate for impossible dates, but account for extreme cases. Tchilas zman kiddush Levana 3 days for
        // the extreme case of Rapa Iti in French Polynesia on Dec 2027 when kiddush Levana 3 days can be said on the evening
        // of the 30th, the second night of Rosh Chodesh. The 3rd day after the <em>molad</em> will be on the 4th of the month.
        // In the case of Anadyr, Russia on Jan, 2071, when sof zman kiddush levana is on the 17th of the month, the 3rd day
        // from the molad will be on the 5th day of Shevat. See Rabbi Dovid Heber's Shaarei Zmanim chapter 4 (pages 28 and 32).
        if (jewishCalendar.getJewishDayOfMonth() > 5 && jewishCalendar.getJewishDayOfMonth() < 30) {
            return nil;
        }
        
        var zman = getMoladBasedTime(moladBasedTime: jewishCalendar.getTchilasZmanKidushLevana3Days(), alos: alos, tzais: tzais, techila: true);
        
        //Get the following month's zman kiddush Levana for the extreme case of Rapa Iti in French Polynesia on Dec 2027 when
        // kiddush Levana can be said on Rosh Chodesh (the evening of the 30th). See Rabbi Dovid Heber's Shaarei Zmanim chapter 4 (page 32)
        if (zman == nil && jewishCalendar.getJewishDayOfMonth() == 30) {
            jewishCalendar.forward()
            zman = getMoladBasedTime(moladBasedTime: jewishCalendar.getTchilasZmanKidushLevana3Days(), alos: nil, tzais: nil, techila: true);
        }
        
        return zman;
    }
    
    /**
     * Returns the point in time of <em>Molad</em> as a <code>Date</code> Object. For the traditional day of week, hour,
     * minute and chalakim, ``JewishCalendar#getMoladAsDate`` and the not yet completed
     * ``HebrewDateFormatter`` that will have formatting for this.
     *
     * @return the Date representing the moment of the molad. If the <em>molad</em> does not occur on this day, a
     *         <code>nil</code> will be returned.
     *
     * @see getTchilasZmanKidushLevana3Days()
     * @see getTchilasZmanKidushLevana7Days(Date, Date)
     * @see  JewishCalendar#getMoladAsDate()
     */
    public func getZmanMolad() -> Date? {
        let jewishCalendar = JewishCalendar();
        var gregorianCalendar = Calendar(identifier: .gregorian)
        gregorianCalendar.timeZone = getGeoLocation().getTimeZone()
        jewishCalendar.setGregorianDate(year: gregorianCalendar.component(.year, from: workingDate), month: gregorianCalendar.component(.month, from: workingDate), dayOfMonth: gregorianCalendar.component(.day, from: workingDate));
        
        // Optimize to not calculate for impossible dates, but account for extreme cases. The molad in the extreme case of Rapa
        // Iti in French Polynesia on Dec 2027 occurs on the night of the 27th of Kislev. In the case of Anadyr, Russia on
        // Jan 2071, the molad will be on the 2nd day of Shevat. See Rabbi Dovid Heber's Shaarei Zmanim chapter 4 (pages 28 and 32).
        if (jewishCalendar.getJewishDayOfMonth() > 2 && jewishCalendar.getJewishDayOfMonth() < 27) {
            return nil;
        }
        var molad = getMoladBasedTime(moladBasedTime: jewishCalendar.getMoladAsDate(), alos: nil, tzais: nil, techila: true);
        
        // deal with molad that happens on the end of the previous month
        if (molad == nil && jewishCalendar.getJewishDayOfMonth() > 26) {
            jewishCalendar.forward()
            molad = getMoladBasedTime(moladBasedTime: jewishCalendar.getMoladAsDate(), alos: nil, tzais: nil, techila: true);
        }
        return molad;
    }
    
    /**
     * Used by Molad based <em>zmanim</em> to determine if <em>zmanim</em> occur during the current day.
     * @see getMoladBasedTime(Date, Date, Date, boolean)
     * @return previous midnight
     */
    private func getMidnightLastNight() -> Date {
        var gregorianCalendar = Calendar(identifier: .gregorian)
        gregorianCalendar.timeZone = getGeoLocation().getTimeZone()
        let comp = DateComponents(calendar: gregorianCalendar,
                                  timeZone: getGeoLocation().getTimeZone(),
                                  year: gregorianCalendar.component(.year, from: workingDate),
                                  month: gregorianCalendar.component(.month, from: workingDate),
                                  day: gregorianCalendar.component(.day, from: workingDate),
                                  hour: 0,
                                  minute: 0,
                                  second: 0)
        return gregorianCalendar.date(from: comp)!;
    }
    
    /**
     * Used by Molad based <em>zmanim</em> to determine if <em>zmanim</em> occur during the current day.
     * @see getMoladBasedTime(Date, Date, Date, boolean)
     * @return following midnight
     */
    private func getMidnightTonight() -> Date {
        var gregorianCalendar = Calendar(identifier: .gregorian)
        gregorianCalendar.timeZone = getGeoLocation().getTimeZone()
        let comp = DateComponents(calendar: gregorianCalendar,
                                  timeZone: getGeoLocation().getTimeZone(),
                                  year: gregorianCalendar.component(.year, from: workingDate),
                                  month: gregorianCalendar.component(.month, from: workingDate),
                                  day: gregorianCalendar.component(.day, from: workingDate) + 1,//roll to tonight
                                  hour: 0,
                                  minute: 0,
                                  second: 0)
        return gregorianCalendar.date(from: comp)!;
    }
    
    /**
     * Returns the earliest time of <em>Kiddush Levana</em> according to the opinions that it should not be said until 7
     * days after the <em>molad</em>. If the time of <em>tchilas zman Kiddush Levana</em> occurs during the day (between
     * `` ZmanimCalendar#getAlos72()`` <em>alos</em> and `` ZmanimCalendar#getTzais72()`` <em>tzais</em>) it
     * return the next <em>tzais</em>.
     *
     * @param alos
     *            the beginning of the Jewish day. If <em>Kidush Levana</em> occurs during the day (starting at <em>alos</em>
     *            and ending at <em>tzais</em>), the time returned will be <em>tzais</em>. If either the <em>alos</em> or
     *            <em>tzais</em> parameters are nil, no daytime adjustment will be made.
     * @param tzais
     *            the end of the Jewish day. If <em>Kidush Levana</em> occurs during the day (starting at <em>alos</em> and
     *            ending at <em>tzais</em>), the time returned will be <em>tzais</em>. If either the <em>alos</em> or
     *            <em>tzais</em> parameters are nil, no daytime adjustment will be made.
     *
     * @return the Date representing the moment 7 days after the molad. If the time occurs between <em>alos</em> and
     *         <em>tzais</em>, <em>tzais</em> will be returned. If the <em>zman</em> will not occur on this day, a
     *         <code>nil</code> will be returned.
     * @see getTchilasZmanKidushLevana3Days(Date, Date)
     * @see getTchilasZmanKidushLevana7Days()
     * @see  JewishCalendar#getTchilasZmanKidushLevana7Days()
     */
    public func getTchilasZmanKidushLevana7Days(alos:Date?, tzais:Date?) -> Date? {
        let jewishCalendar = JewishCalendar(workingDate: workingDate, timezone: geoLocation.timeZone)
        
        // Optimize to not calculate for impossible dates, but account for extreme cases. Tchilas zman kiddush Levana 7 days for
        // the extreme case of Rapa Iti in French Polynesia on Jan 2028 (when kiddush Levana 3 days can be said on the evening
        // of the 30th, the second night of Rosh Chodesh), the 7th day after the molad will be on the 4th of the month.
        // In the case of Anadyr, Russia on Jan, 2071, when sof zman kiddush levana is on the 17th of the month, the 7th day
        // from the molad will be on the 9th day of Shevat. See Rabbi Dovid Heber's Shaarei Zmanim chapter 4 (pages 28 and 32).
        if (jewishCalendar.getJewishDayOfMonth() < 4 || jewishCalendar.getJewishDayOfMonth() > 9) {
            return nil;
        }
        
        return getMoladBasedTime(moladBasedTime: jewishCalendar.getTchilasZmanKidushLevana7Days(), alos: alos, tzais: tzais, techila: true);
    }
    
    /**
     * Returns the earliest time of <em>Kiddush Levana</em> according to the opinions that it should not be said until 7
     * days after the <em>molad</em>. The time will be returned even if it occurs during the day when <em>Kiddush Levana</em>
     * can't be recited. Use ``getTchilasZmanKidushLevana7Days(alos:tzais:)`` if you want to limit the time to night hours.
     *
     * @return the Date representing the moment 7 days after the molad regardless of it is day or night. If the <em>zman</em>
     *         will not occur on this day, a <code>nil</code> will be returned.
     * @see getTchilasZmanKidushLevana7Days(Date, Date)
     * @see  JewishCalendar#getTchilasZmanKidushLevana7Days()
     * @see getTchilasZmanKidushLevana3Days()
     */
    public func getTchilasZmanKidushLevana7Days() -> Date? {
        return getTchilasZmanKidushLevana7Days(alos: nil, tzais: nil);
    }
    
    /**
     * This method returns the latest time one is allowed eating <em>chametz</em> on <em>Erev Pesach</em> according to
     * the opinion of the<a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a>. This time is identical to the ``
     *getSofZmanTfilaGRA() <em>Sof zman tfilah</em> GRA} and is provided as a convenience method for those who are
     * unaware how this <em>zman</em> is calculated. This time is 4 hours into the day based on the opinion of the
     * <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a> that the day is calculated from sunrise to sunset.
     * This returns the time 4 x ``getShaahZmanisGra()`` after ``getSeaLevelSunrise()`` If it
     * is not <em>erev Pesach</em>, a nil will be returned.
     *
     * @see  ZmanimCalendar#getShaahZmanisGra()
     * @see  ZmanimCalendar#getSofZmanTfilaGRA()
     * @return the <code>Date</code> one is allowed eating <em>chametz</em> on <em>Erev Pesach</em>. If it is not <em>erev
     *         Pesach</em> or the calculation can't be computed such as in the Arctic Circle where there is at least one
     *         day a year where the sun does not rise, and one where it does not set, a <code>nil</code> will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @todo in v 3.0.0 enable the calendar check for erev pesach and return <code>nil</code> in all other cases.
     */
    public func getSofZmanAchilasChametzGRA() -> Date? {
        let jewishCalendar = JewishCalendar(workingDate: workingDate, timezone: geoLocation.timeZone)
        if (jewishCalendar.getJewishMonth() == JewishCalendar.NISSAN && jewishCalendar.getJewishDayOfMonth() == 14) {
            return getSofZmanTfilaGRA();
        } else {
            return nil;
        }
    }
    
    /**
     * This method returns the latest time one is allowed eating <em>chametz</em> on <em>Erev Pesach</em> according to the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based on <em>alos</em>
     * being ``getAlos72()`` 72 minutes before ``getSunrise()`` This time is identical to the
     * ``getSofZmanTfilaMGA72Minutes()`` <em>Sof zman tfilah</em> MGA 72 minutes This time is 4 ``getShaahZmanisMGA()``
     * <em>shaos zmaniyos</em> (temporal hours) after ``getAlos72()`` dawn based on the opinion of the MGA that the day is
     * calculated from a ``getAlos72()`` dawn of 72 minutes before sunrise to ``getTzais72()`` nightfall of 72 minutes
     * after sunset. This returns the time of 4 x ``getShaahZmanisMGA()``after ``getAlos72()`` dawn If it is not
     * <em>erev Pesach</em>, a nil will be returned.
     *
     * @return the <code>Date</code> of the latest time of eating <em>chametz</em>. If it is not <em>erev Pesach</em> or the
     *         calculation can't be computed such as in the Arctic Circle where there is at least one day a year where the sun does
     *         not rise, and one where it does not set), a <code>nil</code> will be returned. See detailed explanation on top of
     *         the ``AstronomicalCalendar`` documentation.
     * @todo in v 3.0.0 enable the calendar check for erev pesach and return <code>nil</code> in all other cases.
     * @see getShaahZmanisMGA()
     * @see getAlos72()
     * @see getSofZmanTfilaMGA72Minutes()
     */
    public func getSofZmanAchilasChametzMGA72Minutes() -> Date? {
        let jewishCalendar = JewishCalendar(workingDate: workingDate, timezone: geoLocation.timeZone)
        if (jewishCalendar.getJewishMonth() == JewishCalendar.NISSAN && jewishCalendar.getJewishDayOfMonth() == 14) {
            return getSofZmanTfilaMGA72Minutes();
        } else {
            return nil;
        }
    }
    
    /**
     * This method returns the latest time one is allowed eating <em>chametz</em> on <em>Erev Pesach</em> according to the
     * opinion of the<a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based on <em>alos</em>
     * being ``getAlos16Point1Degrees()`` 16.1&deg; before ``getSunrise()`` This time is 4
     * ``getShaahZmanis16Point1Degrees()`` <em>shaos zmaniyos</em> (solar hours) after ``getAlos16Point1Degrees()`` dawn
     * based on the opinion of the MGA that the day is calculated from dawn to nightfall with both being 16.1&deg;
     * below sunrise or sunset. This returns the time of 4 ``getShaahZmanis16Point1Degrees()`` after
     * ``getAlos16Point1Degrees()`` dawn. If it is not <em>erev Pesach</em>, a nil will be returned.
     *
     * @return the <code>Date</code> of the latest time of eating <em>chametz</em>. If it is not <em>erev Pesach</em> or the
     *         calculation can't be computed such as northern and southern locations even south of the Arctic Circle and north
     *         of the Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a
     *         <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @todo in v 3.0.0 enable the calendar check for erev pesach and return <code>nil</code> in all other cases.
     * @see getShaahZmanis16Point1Degrees()
     * @see getAlos16Point1Degrees()
     * @see getSofZmanTfilaMGA16Point1Degrees()
     */
    public func getSofZmanAchilasChametzMGA16Point1Degrees() -> Date? {
        let jewishCalendar = JewishCalendar(workingDate: workingDate, timezone: geoLocation.timeZone)
        if (jewishCalendar.getJewishMonth() == JewishCalendar.NISSAN && jewishCalendar.getJewishDayOfMonth() == 14) {
            return getSofZmanTfilaMGA16Point1Degrees();
        } else {
            return nil;
        }
    }
    
    /**
     * FIXME adjust for syncronous
     * This method returns the latest time for burning <em>chametz</em> on <em>Erev Pesach</em> according to the opinion
     * of the <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a>. This time is 5 hours into the day based on the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a> that the day is calculated from
     * sunrise to sunset. This returns the time 5 x ``getShaahZmanisGra()`` after ``getSeaLevelSunrise()`` If it is not  <em>erev Pesach</em>, a nil will be returned.
     * @todo in v 3.0.0 enable the calendar check for erev pesach and return <code>nil</code> in all other cases.
     * @see  ZmanimCalendar#getShaahZmanisGra()
     * @return the <code>Date</code> of the latest time for burning <em>chametz</em> on <em>Erev Pesach</em>. If it is not
     *         <em>erev Pesach</em> or the calculation can't be computed such as in the Arctic Circle where there is at least
     *         one day a year where the sun does not rise, and one where it does not set, a <code>nil</code> will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getSofZmanBiurChametzGRA() -> Date? {
        let jewishCalendar = JewishCalendar(workingDate: workingDate, timezone: geoLocation.timeZone)
        if (jewishCalendar.getJewishMonth() == JewishCalendar.NISSAN && jewishCalendar.getJewishDayOfMonth() == 14) {
            return ComplexZmanimCalendar.getTimeOffset(time: getElevationAdjustedSunrise(), offset: getShaahZmanisGra() * 5);
        } else {
            return nil;
        }
    }
    
    /**
     * FIXME adjust for syncronous
     * This method returns the latest time for burning <em>chametz</em> on <em>Erev Pesach</em> according to the opinion of
     * the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based on <em>alos</em>
     * being ``getAlos72()`` 72 minutes before ``getSunrise()``  This time is 5
     * ``getShaahZmanisMGA()`` <em>shaos zmaniyos</em> (temporal hours) after ``getAlos72()`` dawn based on the opinion of
     * the MGA that the day is calculated from a ``getAlos72()`` dawn of 72 minutes before sunrise to ``
     * ``getTzais72()`` nightfall of 72 minutes after sunset. This returns the time of 5 x ``getShaahZmanisMGA()`` after
     * ``getAlos72()`` dawn. If it is not  <em>erev Pesach</em>, a nil will be returned.
     * @todo in v 3.0.0 enable the calendar check for erev pesach and return <code>nil</code> in all other cases.
     * @return the <code>Date</code> of the latest time for burning <em>chametz</em> on <em>Erev Pesach</em>. If it is not
     *         <em>erev Pesach</em> or the calculation can't be computed such as in the Arctic Circle where there is at
     *         least one day a year where the sun does not rise, and one where it does not set), a <code>nil</code> will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanisMGA()
     * @see getAlos72()
     */
    public func getSofZmanBiurChametzMGA72Minutes() -> Date? {
        let jewishCalendar = JewishCalendar(workingDate: workingDate, timezone: geoLocation.timeZone)
        if (jewishCalendar.getJewishMonth() == JewishCalendar.NISSAN && jewishCalendar.getJewishDayOfMonth() == 14) {
            return ComplexZmanimCalendar.getTimeOffset(time: getAlos72(), offset: getShaahZmanisMGA() * 5);
        } else {
            return nil;
        }
    }
    
    /**
     * FIXME adjust for syncronous
     * This method returns the latest time for burning <em>chametz</em> on <em>Erev Pesach</em> according to the opinion of
     * the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based on <em>alos</em>
     * being ``getAlos72()`` 72 minutes before ``getSunrise()``  This time is 5
     * ``getShaahZmanisMGA()`` <em>shaos zmaniyos</em> (temporal hours) after ``getAlos72()`` dawn based on the opinion of
     * the MGA that the day is calculated from a ``getAlos72()`` dawn of 72 minutes before sunrise to ``
     * ``getTzais72()`` nightfall of 72 minutes after sunset. This returns the time of 5 x ``getShaahZmanisMGA()`` after
     * ``getAlos72()`` dawn. If it is not  <em>erev Pesach</em>, a nil will be returned.
     * @todo in v 3.0.0 enable the calendar check for erev pesach and return <code>nil</code> in all other cases.
     * @return the <code>Date</code> of the latest time for burning <em>chametz</em> on <em>Erev Pesach</em>. If it is not
     *         <em>erev Pesach</em> or the calculation can't be computed such as in the Arctic Circle where there is at
     *         least one day a year where the sun does not rise, and one where it does not set), a <code>nil</code> will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getShaahZmanisMGA()
     * @see getAlos72()
     */
    public func getSofZmanBiurChametzMGA72MinutesZmanis() -> Date? {
        let jewishCalendar = JewishCalendar(workingDate: workingDate, timezone: geoLocation.timeZone)
        if (jewishCalendar.getJewishMonth() == JewishCalendar.NISSAN && jewishCalendar.getJewishDayOfMonth() == 14) {
            return ComplexZmanimCalendar.getTimeOffset(time: getAlos72Zmanis(), offset: getShaahZmanisMGA() * 5);
        } else {
            return nil;
        }
    }
    
    /**
     * FIXME adjust for syncronous
     * This method returns the latest time for burning <em>chametz</em> on <em>Erev Pesach</em> according to the opinion
     * of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> based on <em>alos</em>
     * being ``getAlos16Point1Degrees()`` 16.1&deg; before ``getSunrise()`` This time is 5
     * ``getShaahZmanis16Point1Degrees()`` <em>shaos zmaniyos</em> (solar hours) after ``getAlos16Point1Degrees()``
     * dawn based on the opinion of the MGA that the day is calculated from dawn to nightfall with both being 16.1&deg;
     * below sunrise or sunset. This returns the time of 5 ``getShaahZmanis16Point1Degrees()`` after
     * ``getAlos16Point1Degrees()`` dawn. If it is not  <em>erev Pesach</em>, a nil will be returned.
     * @todo in v 3.0.0 enable the calendar check for erev pesach and return <code>nil</code> in all other cases.
     * @return the <code>Date</code> of the latest time for burning <em>chametz</em> on <em>Erev Pesach</em>. If it is not
     *         <em>erev Pesach</em> or the calculation can't be computed such as northern and southern locations even south
     *         of the Arctic Circle and north of the Antarctic Circle where the sun may not reach low enough below the
     *         horizon for this calculation, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     *
     * @see getShaahZmanis16Point1Degrees()
     * @see getAlos16Point1Degrees()
     */
    public func getSofZmanBiurChametzMGA16Point1Degrees() -> Date? {
        let jewishCalendar = JewishCalendar(workingDate: workingDate, timezone: geoLocation.timeZone)
        if (jewishCalendar.getJewishMonth() == JewishCalendar.NISSAN && jewishCalendar.getJewishDayOfMonth() == 14) {
            return ComplexZmanimCalendar.getTimeOffset(time: getAlos16Point1Degrees(), offset: getShaahZmanis16Point1Degrees() * 5);
        } else {
            return nil;
        }
    }
    
    /**
     * A method that returns the <a href="https://en.wikipedia.org/wiki/Shneur_Zalman_of_Liadi">Baal Hatanya</a>'s
     * <em>netz amiti</em> (sunrise) without ``AstronomicalCalculator#getElevationAdjustment(double)``
     * elevation adjustment This forms the base for the Baal Hatanya's dawn-based calculations that are
     * calculated as a dip below the horizon before sunrise.
     *
     * According to the Baal Hatanya, <em>netz amiti</em>, or true (halachic) sunrise, is when the top of the sun's
     * disk is visible at an elevation similar to the mountains of Eretz Yisrael. The time is calculated as the point at which
     * the center of the sun's disk is 1.583&deg; below the horizon. This degree-based calculation can be found in Rabbi Shalom
     * DovBer Levine's commentary on The <a href="https://www.chabadlibrary.org/books/pdf/Seder-Hachnosas-Shabbos.pdf">Baal
     * Hatanya's Seder Hachnasas Shabbos</a>. From an elevation of 546 meters, the top of <a href=
     * "https://en.wikipedia.org/wiki/Mount_Carmel">Har Hacarmel</a>, the sun disappears when it is 1&deg; 35' or 1.583&deg;
     * below the sea level horizon. This in turn is based on the Gemara <a href=
     * "https://hebrewbooks.org/shas.aspx?mesechta=2&daf=35">Shabbos 35a</a>. There are other opinions brought down by
     * Rabbi Levine, including Rabbi Yosef Yitzchok Feigelstock who calculates it as the degrees below the horizon 4 minutes after
     * sunset in Yerushalayim (on the equinox). That is brought down as 1.583&deg;. This is identical to the 1&deg; 35' <em>zman</em>
     * and is probably a typo and should be 1.683&deg;. These calculations are used by most <a href=
     * "https://en.wikipedia.org/wiki/Chabad">Chabad</a> calendars that use the Baal Hatanya's <em>zmanim</em>. See
     * <a href="https://www.chabad.org/library/article_cdo/aid/3209349/jewish/About-Our-Zmanim-Calculations.htm">About Our
     * <em>Zmanim</em> Calculations @ Chabad.org</a>.
     *
     * Note: <em>netz amiti</em> is used only for calculating certain <em>zmanim</em>, and is intentionally unpublished. For
     * practical purposes, daytime <em>mitzvos</em> like <em>shofar</em> and <em>lulav</em> should not be done until after the
     * published time for <em>netz</em> / sunrise.
     *
     * @return the <code>Date</code> representing the exact sea-level <em>netz amiti</em> (sunrise) time. If the calculation can't be
     *         computed such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
     *         where it does not set, a <code>nil</code> will be returned. See detailed explanation on top of the page.
     *
     * @see getSunrise()
     * @see getSeaLevelSunrise()
     * @see getSunsetBaalHatanya()
     * @see ZENITH_1_POINT_583
     */
    private func getSunriseBaalHatanya() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_1_POINT_583);
    }
    
    /**
     * A method that returns the <a href="https://en.wikipedia.org/wiki/Shneur_Zalman_of_Liadi">Baal Hatanya</a>'s
     * <em>shkiah amiti</em> (sunset) without ``AstronomicalCalculator#getElevationAdjustment(double)``
     * elevation adjustment This forms the base for the Baal Hatanya's dusk-based calculations that are calculated
     * as a dip below the horizon after sunset.
     *
     * According to the Baal Hatanya, <em>shkiah amiti</em>, true (<em>halachic</em>) sunset, is when the top of the
     * sun's disk disappears from view at an elevation similar to the mountains of <em>Eretz Yisrael</em>.
     * This time is calculated as the point at which the center of the sun's disk is 1.583 degrees below the horizon.
     *
     * Note: <em>shkiah amiti</em> is used only for calculating certain <em>zmanim</em>, and is intentionally unpublished. For
     * practical purposes, all daytime mitzvos should be completed before the published time for <em>shkiah</em> / sunset.
     *
     * For further explanation of the calculations used for the Baal Hatanya's <em>zmanim</em> in this library, see
     * <a href="https://www.chabad.org/library/article_cdo/aid/3209349/jewish/About-Our-Zmanim-Calculations.htm">About Our
     * <em>Zmanim</em> Calculations @ Chabad.org</a>.
     *
     * @return the <code>Date</code> representing the exact sea-level <em>shkiah amiti</em> (sunset) time. If the calculation
     *         can't be computed such as in the Arctic Circle where there is at least one day a year where the sun does not
     *         rise, and one where it does not set, a <code>nil</code> will be returned. See detailed explanation on top of
     *         the ``AstronomicalCalendar`` documentation.
     *
     * @see getSunset()
     * @see getSeaLevelSunset()
     * @see getSunriseBaalHatanya()
     * @see ZENITH_1_POINT_583
     */
    private func getSunsetBaalHatanya() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_1_POINT_583);
    }
    
    /**
     * A method that returns the <a href="https://en.wikipedia.org/wiki/Shneur_Zalman_of_Liadi">Baal Hatanya</a>'s
     * a <em>shaah zmanis</em> (``getTemporalHour(Date, Date)`` temporal hour). This forms the base for the
     * Baal Hatanya's  day  based calculations that are calculated as a 1.583&deg; dip below the horizon after sunset.
     * According to the Baal Hatanya, <em>shkiah amiti</em>, true (halachic) sunset, is when the top of the
     * sun's disk disappears from view at an elevation similar to the mountains of Eretz Yisrael.
     * This time is calculated as the point at which the center of the sun's disk is 1.583 degrees below the horizon.
     * A method that returns a <em>shaah zmanis</em> (``getTemporalHour(Date, Date)`` temporal hour) calculated
     * based on the <a href="https://en.wikipedia.org/wiki/Shneur_Zalman_of_Liadi">Baal Hatanya</a>'s <em>netz
     * amiti</em> and <em>shkiah amiti</em> using a dip of 1.583&deg; below the sea level horizon. This calculation divides
     * the day based on the opinion of the Baal Hatanya that the day runs from ``getSunriseBaalHatanya()`` netz amiti
     * to ``getSunsetBaalHatanya()`` <em>shkiah amiti</em> The calculations are based on a day from ``
     *getSunriseBaalHatanya() sea level <em>netz amiti</em> to ``getSunsetBaalHatanya()`` sea level <em>shkiah amiti</em>``
     * The day is split into 12 equal parts with each one being a <em>shaah zmanis</em>. This method is similar to ``
     *getTemporalHour}, but all calculations are based on a sea level sunrise and sunset.
     * @return the <code>long</code> millisecond length of a <em>shaah zmanis</em> calculated from
     *         ``getSunriseBaalHatanya()`` <em>netz amiti</em> (sunrise)} to ``getSunsetBaalHatanya()`` <em>shkiah amiti</em>
     *         ("real" sunset) If the calculation can't be computed such as in the Arctic Circle where there is at least one day a
     *         year where the sun does not rise, and one where it does not set, ``Int64.min`` will be returned. See
     *         detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     *
     * @see getTemporalHour(Date, Date)
     * @see getSunriseBaalHatanya()
     * @see getSunsetBaalHatanya()
     * @see ZENITH_1_POINT_583
     */
    public func getShaahZmanisBaalHatanya() -> Int64 {
        return getTemporalHour(startOfDay: getSunriseBaalHatanya(), endOfDay: getSunsetBaalHatanya());
    }
    
    /**
     * Returns the <a href="https://en.wikipedia.org/wiki/Shneur_Zalman_of_Liadi">Baal Hatanya</a>'s <em>alos</em>
     * (dawn) calculated as the time when the sun is 16.9&deg; below the eastern ``GEOMETRIC_ZENITH`` geometric horizon
     * before ``getSunrise()`` For more information the source of 16.9&deg; see ``ZENITH_16_POINT_9``
     *
     * @see ZENITH_16_POINT_9
     * @return The <code>Date</code> of dawn. If the calculation can't be computed such as northern and southern
     *         locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not reach
     *         low enough below the horizon for this calculation, a <code>nil</code> will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getAlosBaalHatanya() -> Date? {
        return getSunriseOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_16_POINT_9);
    }
    
    /**
     * This method returns the latest <em>zman krias shema</em> (time to recite Shema in the morning). This time is 3
     * ``getShaahZmanisBaalHatanya()`` <em>shaos zmaniyos</em> (solar hours) after ``getSunriseBaalHatanya()``
     * <em>netz amiti</em> (sunrise)} based on the opinion of the Baal Hatanya that the day is calculated from
     * sunrise to sunset. This returns the time 3 x ``getShaahZmanisBaalHatanya()`` after ``getSunriseBaalHatanya()``
     * <em>netz amiti</em> (sunrise)``
     *
     * @see  ZmanimCalendar#getSofZmanShma(Date, Date)
     * @see getShaahZmanisBaalHatanya()
     * @return the <code>Date</code> of the latest <em>zman shema</em> according to the Baal Hatanya. If the calculation
     *         can't be computed such as in the Arctic Circle where there is at least one day a year where the sun does
     *         not rise, and one where it does not set, a <code>nil</code> will be returned. See detailed explanation on
     *         top of the ``AstronomicalCalendar`` documentation.
     */
    public func getSofZmanShmaBaalHatanya() -> Date? {
        return getSofZmanShma(startOfDay: getSunriseBaalHatanya(), endOfDay: getSunsetBaalHatanya(), synchronous: true);
    }
    
    /**
     * This method returns the latest <em>zman tfilah</em> (time to recite the morning prayers). This time is 4
     * hours into the day based on the opinion of the Baal Hatanya that the day is
     * calculated from sunrise to sunset. This returns the time 4 x ``getShaahZmanisBaalHatanya()`` after
     * ``getSunriseBaalHatanya()`` <em>netz amiti</em> (sunrise)``
     *
     * @see  ZmanimCalendar#getSofZmanTfila(Date, Date)
     * @see getShaahZmanisBaalHatanya()
     * @return the <code>Date</code> of the latest <em>zman tfilah</em>. If the calculation can't be computed such as in
     *         the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
     *         not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getSofZmanTfilaBaalHatanya() -> Date? {
        return getSofZmanTfila(startOfDay: getSunriseBaalHatanya(), endOfDay: getSunsetBaalHatanya(), synchronous: true);
    }
    
    /**
     * This method returns the latest time one is allowed eating <em>chametz</em> on <em>Erev Pesach</em> according to the
     * opinion of the Baal Hatanya. This time is identical to the ``getSofZmanTfilaBaalHatanya()`` <em>Sof zman
     * tfilah</em> Baal Hatanya This time is 4 hours into the day based on the opinion of the Baal Hatanya that the day
     * is calculated from sunrise to sunset. This returns the time 4 ``getShaahZmanisBaalHatanya()`` after
     * ``getSunriseBaalHatanya()`` <em>netz amiti</em> (sunrise) If it is not  <em>erev Pesach</em>, a nil will be
     * returned.
     * @todo in v 3.0.0 enable the calendar check for erev pesach and return <code>nil</code> in all other cases.
     * @see getShaahZmanisBaalHatanya()
     * @see getSofZmanTfilaBaalHatanya()
     * @return the <code>Date</code> one is allowed eating <em>chametz</em> on <em>Erev Pesach</em>. If it is not <em>erev
     *         Pesach</em> or the  calculation can't be computed such as in the Arctic Circle where there is at least one
     *         day a year where the sun does not rise, and one where it does not set, a <code>nil</code> will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getSofZmanAchilasChametzBaalHatanya() -> Date? {
        let jewishCalendar = JewishCalendar(workingDate: workingDate, timezone: geoLocation.timeZone)
        if (jewishCalendar.getJewishMonth() == JewishCalendar.NISSAN && jewishCalendar.getJewishDayOfMonth() == 14) {
            return getSofZmanTfilaBaalHatanya();
        } else {
            return nil;
        }
    }
    
    /**
     * This method returns the latest time for burning <em>chametz</em> on <em>Erev Pesach</em> according to the opinion of
     * the Baal Hatanya. This time is 5 hours into the day based on the opinion of the Baal Hatanya that the day is calculated
     * from sunrise to sunset. This returns the time 5 x ``getShaahZmanisBaalHatanya()`` after
     * ``getSunriseBaalHatanya()`` <em>netz amiti</em> (sunrise). If it is not  <em>erev Pesach</em>, a nil will be returned.
     * @todo in v 3.0.0 enable the calendar check for erev pesach and return <code>nil</code> in all other cases.
     * @see getShaahZmanisBaalHatanya()
     * @return the <code>Date</code> of the latest time for burning <em>chametz</em> on <em>Erev Pesach</em>.  If it is not
     *         <em>erev Pesach</em> or the  calculation can't be computed such as in the Arctic Circle where there is at
     *         least one day a year where the sun does not rise, and one where it does not set, a <code>nil</code> will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getSofZmanBiurChametzBaalHatanya() -> Date? {
        let jewishCalendar = JewishCalendar(workingDate: workingDate, timezone: geoLocation.timeZone)
        if (jewishCalendar.getJewishMonth() == JewishCalendar.NISSAN && jewishCalendar.getJewishDayOfMonth() == 14) {
            return ComplexZmanimCalendar.getTimeOffset(time: getSunriseBaalHatanya(), offset: getShaahZmanisBaalHatanya() * 5);
        } else {
            return nil;
        }
    }
    
    /**
     * This method returns the time of <em>mincha gedola</em>. <em>Mincha gedola</em> is the earliest time one can pray
     * <em>mincha</em>. The <a href="https://en.wikipedia.org/wiki/Maimonides">Rambam</a> is of the opinion that it is
     * better to delay <em>mincha</em> until ``getMinchaKetanaBaalHatanya()`` <em>mincha ketana</em> while the
     * <a href="https://en.wikipedia.org/wiki/Asher_ben_Jehiel">Ra"sh</a>,
     * <a href="https://en.wikipedia.org/wiki/Jacob_ben_Asher">Tur</a>, <a href=
     * "https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a> and others are of the opinion that <em>mincha</em> can be prayed
     * <em>lechatchila</em> starting at <em>mincha gedola</em>. This is calculated as 6.5 ``getShaahZmanisBaalHatanya()
     * sea level solar hours} after ``getSunriseBaalHatanya()`` <em>netz amiti</em> (sunrise) This calculation is based
     * on the opinion of the Baal Hatanya that the day is calculated from sunrise to sunset. This returns the time 6.5
     * * ``getShaahZmanisBaalHatanya()`` after ``getSunriseBaalHatanya()`` <em>netz amiti</em> ("real" sunrise)
     * @todo Consider adjusting this to calculate the time as 30 clock or <em>zmaniyos </em> minutes after either ``
     *        getSunTransit() astronomical <em>chatzos</em> or ``getChatzosAsHalfDay()`` <em>chatzos</em> as half a day}
     *         for `` AstronomicalCalculator`` calculators that support it, based on ``isUseAstronomicalChatzos()``
     * @see getMinchaGedola(Date, Date)
     * @see getShaahZmanisBaalHatanya()
     * @see getMinchaKetanaBaalHatanya()
     * @return the <code>Date</code> of the time of <em>mincha gedola</em> according to the Baal Hatanya. If the calculation
     *         can't be computed such as in the Arctic Circle where there is at least one day a year where the sun does not rise,
     *         and one where it does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getMinchaGedolaBaalHatanya() -> Date? {
        return getMinchaGedola(startOfDay: getSunriseBaalHatanya(), endOfDay: getSunsetBaalHatanya(), synchronous: true);
    }
    
    /**
     * FIXME syncronous
     * This is a convenience method that returns the later of ``getMinchaGedolaBaalHatanya()`` and
     * ``getMinchaGedola30Minutes()`` In the winter when 1/2 of a ``getShaahZmanisBaalHatanya()``
     * <em>shaah zmanis</em> is less than 30 minutes ``getMinchaGedola30Minutes()`` will be returned, otherwise
     * ``getMinchaGedolaBaalHatanya()`` will be returned.
     * @todo Consider adjusting this to calculate the time as 30 clock or <em>zmaniyos </em> minutes after either
     *        getSunTransit() astronomical <em>chatzos</em> or ``getChatzosAsHalfDay()`` <em>chatzos</em> as half a day
     *         for ``AstronomicalCalculator`` calculators that support it, based on ``isUseAstronomicalChatzos()``
     * @return the <code>Date</code> of the later of ``getMinchaGedolaBaalHatanya()`` and ``getMinchaGedola30Minutes()``
     *         If the calculation can't be computed such as in the Arctic Circle where there is at least one day a year
     *         where the sun does not rise, and one where it does not set, a <code>nil</code> will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getMinchaGedolaBaalHatanyaGreaterThan30() -> Date? {
        if (getMinchaGedola30Minutes() == nil || getMinchaGedolaBaalHatanya() == nil) {
            return nil;
        } else {
            if getMinchaGedola30Minutes()!.timeIntervalSince1970 > getMinchaGedolaBaalHatanya()!.timeIntervalSince1970 {
                return getMinchaGedola30Minutes()
            } else {
                return getMinchaGedolaBaalHatanya()
            }
        }
    }
    
    /**
     * This method returns the time of <em>mincha ketana</em>. This is the preferred earliest time to pray
     * <em>mincha</em> in the opinion of the <a href="https://en.wikipedia.org/wiki/Maimonides">Rambam</a> and others.
     * For more information on this see the documentation on ``getMinchaGedolaBaalHatanya()`` <em>mincha gedola</em>``
     * This is calculated as 9.5 ``getShaahZmanisBaalHatanya()``  sea level solar hours} after ``getSunriseBaalHatanya()``
     * <em>netz amiti</em> (sunrise) This calculation is calculated based on the opinion of the Baal Hatanya that the
     * day is calculated from sunrise to sunset. This returns the time 9.5 x ``getShaahZmanisBaalHatanya()`` after
     *``getSunriseBaalHatanya()`` <em>netz amiti</em> (sunrise)
     *
     * @see getMinchaKetana(Date, Date)
     * @see getShaahZmanisBaalHatanya()
     * @see getMinchaGedolaBaalHatanya()
     * @return the <code>Date</code> of the time of <em>mincha ketana</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getMinchaKetanaBaalHatanya() -> Date? {
        return getMinchaKetana(startOfDay: getSunriseBaalHatanya(), endOfDay: getSunsetBaalHatanya(), synchronous: true);
    }
    
    /**
     * This method returns the time of <em>plag hamincha</em>. This is calculated as 10.75 hours after sunrise. This
     * calculation is based on the opinion of the Baal Hatanya that the day is calculated
     * from sunrise to sunset. This returns the time 10.75 x ``getShaahZmanisBaalHatanya()`` after
     * ``getSunriseBaalHatanya()`` <em>netz amiti</em> (sunrise)``
     *
     * @see getPlagHamincha(Date, Date)
     * @return the <code>Date</code> of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     */
    public func getPlagHaminchaBaalHatanya() -> Date? {
        return getPlagHamincha(startOfDay: getSunriseBaalHatanya(), endOfDay: getSunsetBaalHatanya(), synchronous: true);
    }
    
    /**
     * A method that returns <em>tzais</em> (nightfall) when the sun is 6&deg; below the western geometric horizon
     * (90&deg;) after ``getSunset()`` sunset. For information on the source of this calculation see
     * ``ZENITH_6_DEGREES``
     *
     * @return The <code>Date</code> of nightfall. If the calculation can't be computed such as northern and southern
     *         locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not reach
     *         low enough below the horizon for this calculation, a <code>nil</code> will be returned. See detailed
     *         explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see ZENITH_6_DEGREES
     */
    public func getTzaisBaalHatanya() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.ZENITH_6_DEGREES);
    }
    
    /**
     * This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion of the
     * calculation of <em>sof zman krias shema</em> (latest time to recite <em>Shema</em> in the morning) according to the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> that the
     * day is calculated from dawn to nightfall, but calculated using the first half of the day only. The half a day starts
     * at <em>alos</em> defined as ``getAlos18Degrees()`` 18&deg; and ends at ``getFixedLocalChatzos()`` fixed local
     * chatzos <em>Sof Zman Shema</em> is 3 <em>shaos zmaniyos</em> (solar hours) after <em>alos</em> or half of this half-day.
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos18Degrees()
     * @see getFixedLocalChatzos()
     * @see  ZmanimCalendar#getHalfDayBasedZman(Date, Date, double)
     */
    public func getSofZmanShmaMGA18DegreesToFixedLocalChatzos() -> Date? {
        return getHalfDayBasedZman(startOfHalfDay: getAlos18Degrees(), endOfHalfDay: getFixedLocalChatzos(), hours: 3);
    }
    
    /**
     * This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion of the
     * calculation of <em>sof zman krias shema</em> (latest time to recite <em>Shema</em> in the morning) according to the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> that the
     * day is calculated from dawn to nightfall, but calculated using the first half of the day only. The half a day starts
     * at <em>alos</em> defined as ``getAlos16Point1Degrees()`` 16.1&deg; and ends at ``getFixedLocalChatzos()`` fixed local
     * chatzos <em>Sof Zman Shema</em> is 3 <em>shaos zmaniyos</em> (solar hours) after this <em>alos</em> or half of this half-day.
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos16Point1Degrees()
     * @see getFixedLocalChatzos()
     * @see getHalfDayBasedZman(Date, Date, double)
     */
    public func getSofZmanShmaMGA16Point1DegreesToFixedLocalChatzos() -> Date? {
        return getHalfDayBasedZman(startOfHalfDay: getAlos16Point1Degrees(), endOfHalfDay: getFixedLocalChatzos(), hours: 3);
    }
    
    /**
     * This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion of the
     * calculation of <em>sof zman krias shema</em> (latest time to recite <em>Shema</em> in the morning) according to the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> that the
     * day is calculated from dawn to nightfall, but calculated using the first half of the day only. The half a day starts
     * at <em>alos</em> defined as ``getAlos90()`` 90 minutes before sunrise} and ends at ``getFixedLocalChatzos()``
     * fixed local chatzos <em>Sof Zman Shema</em> is 3 <em>shaos zmaniyos</em> (solar hours) after this <em>alos</em> or
     * half of this half-day.
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos90()
     * @see getFixedLocalChatzos()
     * @see getHalfDayBasedZman(Date, Date, double)
     */
    public func getSofZmanShmaMGA90MinutesToFixedLocalChatzos() -> Date? {
        return getHalfDayBasedZman(startOfHalfDay: getAlos90(), endOfHalfDay: getFixedLocalChatzos(), hours: 3);
    }
    
    /**
     * This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion of the
     * calculation of <em>sof zman krias shema</em> (latest time to recite <em>Shema</em> in the morning) according to the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a> that the
     * day is calculated from dawn to nightfall, but calculated using the first half of the day only. The half a day starts
     * at <em>alos</em> defined as ``getAlos72()`` 72 minutes before sunrise and ends at ``getFixedLocalChatzos()``
     * fixed local chatzos <em>Sof Zman Shema</em> is 3 <em>shaos zmaniyos</em> (solar hours) after this <em>alos</em> or
     * half of this half-day.
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getAlos72()
     * @see getFixedLocalChatzos()
     * @see getHalfDayBasedZman(Date, Date, double)
     */
    public func getSofZmanShmaMGA72MinutesToFixedLocalChatzos() -> Date? {
        return getHalfDayBasedZman(startOfHalfDay: getAlos72(), endOfHalfDay: getFixedLocalChatzos(), hours: 3);
    }
    
    /**
     * This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion of the
     * calculation of <em>sof zman krias shema</em> (latest time to recite <em>Shema</em> in the morning) according to the
     * opinion of the <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a> that the day is calculated from
     * sunrise to sunset, but calculated using the first half of the day only. The half a day starts at ``getSunrise()``
     * sunrise and ends at ``getFixedLocalChatzos()`` fixed local chatzos <em>Sof zman Shema</em> is 3 <em>shaos
     * zmaniyos</em> (solar hours) after sunrise or half of this half-day.
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getSunrise()
     * @see getFixedLocalChatzos()
     * @see getHalfDayBasedZman(Date, Date, double)
     */
    public func getSofZmanShmaGRASunriseToFixedLocalChatzos() -> Date? {
        return getHalfDayBasedZman(startOfHalfDay: getSunrise(), endOfHalfDay: getFixedLocalChatzos(), hours: 3);
    }
    
    /**
     * This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion of the
     * calculation of <em>sof zman tfila</em> (<em>zman tfilah</em> (the latest time to recite the morning prayers))
     * according to the opinion of the <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a> that the day is
     * calculated from sunrise to sunset, but calculated using the first half of the day only. The half a day starts at
     * ``getSunrise()`` and ends at ``getFixedLocalChatzos()`` fixed local chatzos <em>Sof zman tefila</em>
     * is 4 <em>shaos zmaniyos</em> (solar hours) after sunrise or 2/3 of this half-day.
     *
     * @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     * @see getSunrise()
     * @see getFixedLocalChatzos()
     * @see getHalfDayBasedZman(Date, Date, double)
     */
    public func getSofZmanTfilaGRASunriseToFixedLocalChatzos() -> Date? {
        return getHalfDayBasedZman(startOfHalfDay: getSunrise(), endOfHalfDay: getFixedLocalChatzos(), hours: 4);
    }
    
    /**
     * This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion of
     * the calculation of <em>mincha gedola</em>, the earliest time one can pray <em>mincha</em> <a href=
     * "https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a>that is 30 minutes after ``getFixedLocalChatzos()`` fixed
     * local chatzos
     *
     * @return the <code>Date</code> of the time of <em>mincha gedola</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     *
     * @see getMinchaGedola()
     * @see getFixedLocalChatzos()
     * @see getMinchaKetanaGRAFixedLocalChatzosToSunset
     */
    public func getMinchaGedolaGRAFixedLocalChatzos30Minutes() -> Date? {
        return ComplexZmanimCalendar.getTimeOffset(time: getFixedLocalChatzos(), offset: ComplexZmanimCalendar.MINUTE_MILLIS * 30);
    }
    
    /**
     * This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion
     * of the calculation of <em>mincha ketana</em> (the preferred time to recite the <em>mincha prayers</em> according to
     * the opinion of the <a href="https://en.wikipedia.org/wiki/Maimonides">Rambam</a> and others) calculated according
     * to the <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a> that is 3.5 <em>shaos zmaniyos</em> (solar
     * hours) after ``getFixedLocalChatzos()`` fixed local chatzos
     *
     * @return the <code>Date</code> of the time of <em>mincha gedola</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     *
     * @see getMinchaGedola()
     * @see getFixedLocalChatzos()
     * @see getMinchaGedolaGRAFixedLocalChatzos30Minutes
     * @see  ZmanimCalendar#getHalfDayBasedZman(Date, Date, double)
     */
    public func getMinchaKetanaGRAFixedLocalChatzosToSunset() -> Date? {
        return getHalfDayBasedZman(startOfHalfDay: getFixedLocalChatzos(), endOfHalfDay: getSunset(), hours: 3.5);
    }
    
    /**
     * This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion
     * of the calculation of <em>plag hamincha</em>. This method returns <em>plag hamincha</em> calculated according to the
     * <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a> that the day ends at sunset and is 4.75 <em>shaos
     * zmaniyos</em> (solar hours) after ``getFixedLocalChatzos()`` fixed local chatzos
     *
     * @return the <code>Date</code> of the time of <em>mincha gedola</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     *
     * @see getPlagHamincha()
     * @see getFixedLocalChatzos()
     * @see getMinchaKetanaGRAFixedLocalChatzosToSunset
     * @see getMinchaGedolaGRAFixedLocalChatzos30Minutes
     * @see  ZmanimCalendar#getHalfDayBasedZman(Date, Date, double)
     */
    public func getPlagHaminchaGRAFixedLocalChatzosToSunset() -> Date? {
        return getHalfDayBasedZman(startOfHalfDay: getFixedLocalChatzos(), endOfHalfDay: getSunset(), hours: 4.75);
    }
    
    /**
     * Method to return <em>tzais</em> (dusk) calculated as 50 minutes after sea level sunset. This method returns
     * <em>tzais</em> (nightfall) based on the opinion of Rabbi Moshe Feinstein for the New York area. This time should
     * not be used for latitudes different than the NY area.
     *
     * @return the <code>Date</code> representing the time. If the calculation can't be computed such as in the Arctic
     *         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
     *         a <code>nil</code> will be returned. See detailed explanation on top of the ``AstronomicalCalendar``
     *         documentation.
     */
    public func getTzais50() -> Date? {
        return ComplexZmanimCalendar.getTimeOffset(time: getElevationAdjustedSunset(), offset: 50 * ComplexZmanimCalendar.MINUTE_MILLIS);
    }
    
    /**
     * A method for calculating <em>samuch lemincha ketana</em>, / near <em>mincha ketana</em> time that is half an hour before
     * ``getMinchaKetana()`` or is 9 x ``getShaahZmanisGra()``<em>shaos zmaniyos</em> (solar hours) after
     * ``getSunrise()``  or ``getSeaLevelSunrise()`` (depending on the ``isUseElevation``
     * setting), calculated according to the <a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a> using a day starting at
     * sunrise and ending at sunset. This is the time that eating or other activity can't begin prior to praying <em>mincha</em>.
     * The calculation used is 9 x ``getShaahZmanis16Point1Degrees()`` after ``getAlos16Point1Degrees()`` <em>alos</em>
     * 16.1&deg; See the <a href="https://hebrewbooks.org/pdfpager.aspx?req=60387&st=&pgnum=294">Mechaber and Mishna Berurah
     * 232</a> for details.
     *
     * @see getShaahZmanisGra()
     * @see getSamuchLeMinchaKetana16Point1Degrees()
     * @see isUseAstronomicalChatzosForOtherZmanim()
     * @return the <code>Date</code> of the time of <em>samuch lemincha ketana</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be
     *         returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getSamuchLeMinchaKetanaGRA() -> Date? {
        return getSamuchLeMinchaKetana(startOfDay: getElevationAdjustedSunrise(), endOfDay: getElevationAdjustedSunset(), synchronous: true);
    }
    
    /**
     * A method for calculating <em>samuch lemincha ketana</em>, / near <em>mincha ketana</em> time that is half an hour
     * before ``getMinchaGedola16Point1Degrees()`` or 9 x <em>shaos zmaniyos</em> (temporal hours) after the start of
     * the day, calculated using a day starting and ending 16.1&deg; below the horizon. This is the time that eating or other
     * activity can't begin prior to praying <em>mincha</em>. The calculation used is 9 x
     * ``getShaahZmanis16Point1Degrees()`` after ``getAlos16Point1Degrees()`` <em>alos</em> 16.1&deg; See the <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=60387&st=&pgnum=294">Mechaber and Mishna Berurah 232</a>.
     *
     * @see getShaahZmanis16Point1Degrees()
     * @return the <code>Date</code> of the time of <em>samuch lemincha ketana</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getSamuchLeMinchaKetana16Point1Degrees() -> Date? {
        return getSamuchLeMinchaKetana(startOfDay: getAlos16Point1Degrees(), endOfDay: getTzais16Point1Degrees(), synchronous: true);
    }
    
    /**
     * A method for calculating <em>samuch lemincha ketana</em>, / near <em>mincha ketana</em> time that is half an hour before
     * ``getMinchaKetana72Minutes()``  or 9 x <em>shaos zmaniyos</em> (temporal hours) after the start of the day,
     * calculated using a day starting 72 minutes before sunrise and ending 72 minutes after sunset. This is the time that eating
     * or other activity can't begin prior to praying <em>mincha</em>. The calculation used is 9 x
     * ``getShaahZmanis16Point1Degrees()`` after ``getAlos16Point1Degrees()`` <em>alos</em> 16.1&deg; See the <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=60387&st=&pgnum=294">Mechaber and Mishna Berurah 232</a>.
     *
     * @see getShaahZmanis16Point1Degrees()
     * @return the <code>Date</code> of the time of <em>samuch lemincha ketana</em>. If the calculation can't be computed such
     *         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
     *         where the sun may not reach low enough below the horizon for this calculation, a <code>nil</code> will be returned.
     *         See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
     */
    public func getSamuchLeMinchaKetana72Minutes() -> Date? {
        return getSamuchLeMinchaKetana(startOfDay: getAlos72(), endOfDay: getTzais72(), synchronous: true);
    }
    
    // these methods are not included in KosherJava, however, I am adding them because of convenience
    
    /**
     This method returns chatzos as a half way point between sunrise and sunset unless the location is in a place that does not have sunrise of sunset. Then it will return UTCNoon which is an astronomical chatzos.
     */
    public func getChatzosIfHalfDayNil() -> Date? {
        if getSunTransit(startOfDay: getElevationAdjustedSunrise(), endOfDay: getElevationAdjustedSunset()) == nil {
            return getSunTransit()
        } else {
            return getSunTransit(startOfDay: getElevationAdjustedSunrise(), endOfDay: getElevationAdjustedSunset())
        }
    }
    
    /**
     * This method returns the time of <em>plag hamincha</em> according to the Yalkut Yosef. This is calculated as -1.25 hours before
     * ``getTzais13Point5Zmanis()`` dawn.
     *
     * @return the <code>Date</code> of the time of <em>plag hamincha</em>. If the calculation can't be computed such as
     *         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
     *         does not set, a <code>nil</code> will be returned. See detailed explanation on top of the
     *         ``AstronomicalCalendar`` documentation.
     *
     */
    public func getPlagHaminchaYalkutYosef() -> Date? {
        let shaahZmanit = getShaahZmanisGra()
        let dakahZmanit = shaahZmanit / 60
        return ComplexZmanimCalendar.getTimeOffset(time: getTzais13Point5MinutesZmanis(), offset: -(shaahZmanit + (15 * dakahZmanit)))
    }
    
    /**
     * Yalkut Yosef holds that the time for Plag Hamincha is calculated by taking 1.25 "seasonal hours" (Sha'ot Zmaniot) from tzait hacochavim.
     * This is how Rabbi Dahan calculates Plag Hamincha in his Amudei Horaah calendar with his own algorithm for tzait hacochavim.
     * Note: The Amudei Horaah calendar provides both the Yalkut Yosef and Halacha Berurah times for Plag Hamincha. (No elevation adjustment is used)
     * @return the time for Plag Hamincha as calculated by the Amudei Horaah calendar and Yalkut Yosef.
     */
    public func getPlagHaminchaYalkutYosefAmudeiHoraah() -> Date? {
        let shaahZmanit = getTemporalHour(startOfDay: getSeaLevelSunrise(), endOfDay: getSeaLevelSunset())
        let dakahZmanit = shaahZmanit / 60
        return ComplexZmanimCalendar.getTimeOffset(time: getTzaisAmudeiHoraah(), offset: -(shaahZmanit + (15 * dakahZmanit)));
    }
    
    /**
     * This method returns the time of alot hashachar (dawn) calculated by the Amudei Horaah calendar. While normally this is calculated as 72 zmaniyot
     * minutes before sunrise, Rabbi Dahan says that the zmanim need to be adjusted for more northern/southern locations. He calculates the time as
     * zmaniyot minutes/seconds, however, he adjusts it based on the location and 16.04 degrees (72 zmaniyot minutes in Israel).
     * <p>
     * For example: If you wanted to calculate when alot is for NY, USA, you would first calculate the amount of regular minutes there are in an equinox
     * day between sunrise and 16.04 degrees before sunrise. In NY, this would lead you to around 80 minutes. You would then minus 80 zmaniyot minutes to
     * the time of sunrise to get the time of alot.
     * <p>
     * This is how Rabbi Dahan calculates the zmanim for alot and tzait in the Amudei Horaah calendar.
     *
     * - Warning: This zman should NOT be used in Israel.
     *
     * @return the time of alot hashachar (dawn) calculated by the Amudei Horaah calendar by adjusting the zman based off of degrees. This zman
     * should NOT be used in Israel.
     */
    public func getAlosAmudeiHoraah() -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = geoLocation.timeZone
        let temp = workingDate
        workingDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: workingDate), month: 3, day: 17))!

        let percentage = getPercentOfShaahZmanisFromDegrees(degrees: 16.04, sunset: false)
        if (percentage == (-Double.greatestFiniteMagnitude)) {
            return nil;
        }
        workingDate = temp//reset

        let shaahZmanit = Double(getTemporalHour(startOfDay: getSeaLevelSunrise(), endOfDay: getSeaLevelSunset()));
        return ComplexZmanimCalendar.getTimeOffset(time: getSeaLevelSunrise(), offset: -(percentage * shaahZmanit));
    }
    
    /**
     * This method returns the time of misheyakir calculated by the Amudei Horaah calendar.
     * Rabbi Dahan calculates this zman for as 5/6 of the time between alot and sunrise in the Amudei Horaah calendar.
     * Warning: This zman should NOT be used in Israel.
     * @return the time of misheyakir calculated by the Amudei Horaah calendar by adjusting the zman based off of degrees.
     */
    public func getMisheyakirAmudeiHoraah() -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = geoLocation.timeZone
        let temp = workingDate
        workingDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: workingDate), month: 3, day: 17))!

        let percentage = getPercentOfShaahZmanisFromDegrees(degrees: 16.04, sunset: false)
        if (percentage == (-Double.greatestFiniteMagnitude)) {
            return nil;
        }
        workingDate = temp//reset

        let shaahZmanit = Double(getTemporalHour(startOfDay: getSeaLevelSunrise(), endOfDay: getSeaLevelSunset()));
        return ComplexZmanimCalendar.getTimeOffset(time: getSeaLevelSunrise(), offset: -(percentage * shaahZmanit) * 5 / 6);
    }
    
    // These methods are similar to the ones in the base class, but they use the Amudei Horaah zmanim instead of the regular zmanim
    public func getSofZmanShmaMGA72MinutesZmanisAmudeiHoraah() -> Date? {
        return getSofZmanShma(startOfDay: getAlosAmudeiHoraah(), endOfDay: getTzais72ZmanisAmudeiHoraah());
    }

    public func getSofZmanAchilatChametzAmudeiHoraah() -> Date? {
        return getSofZmanTfila(startOfDay: getAlosAmudeiHoraah(), endOfDay: getTzais72ZmanisAmudeiHoraah());
    }

    public func getSofZmanBiurChametzMGAAmudeiHoraah() -> Date? {
        let shaahZmanit = getTemporalHour(startOfDay: getAlosAmudeiHoraah(), endOfDay: getTzais72ZmanisAmudeiHoraah());
        return ComplexZmanimCalendar.getTimeOffset(time: getAlosAmudeiHoraah(), offset: shaahZmanit * 5);
    }
    
    /**
         * This method calculates the time for Nightfall according to the opinion of the Amudei Horaah Calendar. This is calculated as 13.5
         * adjusted zmaniyot minutes after sunset. This is based on the calculation of the 3.77&deg which is the time at 13.5 minutes in Netanya, Israel
         * on the equinox. Why Netanya and not Jerusalem? Because Netanya is the mid point between Israel and Iraq. Therefore, Rabbi Dahan equates them.
         * @return the Date representing 13.5 minutes zmaniyot after sunset adjusted to the users location using degrees based on Netanya, Israel. This zman
         * should NOT be used in Israel.
         */
    public func getTzaisAmudeiHoraah() -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = geoLocation.timeZone
        let temp = workingDate
        workingDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: workingDate), month: 3, day: 17))!

        let percentage = getPercentOfShaahZmanisFromDegrees(degrees: 3.77, sunset: true)
        if (percentage == (-Double.greatestFiniteMagnitude)) {
            return nil;
        }
        workingDate = temp//reset

        let shaahZmanit = Double(getTemporalHour(startOfDay: getSeaLevelSunrise(), endOfDay: getSeaLevelSunset()));
        return ComplexZmanimCalendar.getTimeOffset(time: getSeaLevelSunset(), offset: percentage * shaahZmanit);
    }
    
    public func getTzaisAmudeiHoraahLChumra() -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = geoLocation.timeZone
        let temp = workingDate
        workingDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: workingDate), month: 3, day: 17))!

        let percentage = getPercentOfShaahZmanisFromDegrees(degrees: 5.135, sunset: true)
        if (percentage == (-Double.greatestFiniteMagnitude)) {
            return nil;
        }
        workingDate = temp//reset

        let shaahZmanit = Double(getTemporalHour(startOfDay: getSeaLevelSunrise(), endOfDay: getSeaLevelSunset()));
        return ComplexZmanimCalendar.getTimeOffset(time: getSeaLevelSunset(), offset: percentage * shaahZmanit);
    }
    
    public func getTzais72ZmanisAmudeiHoraah() -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = geoLocation.timeZone
        let temp = workingDate
        workingDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: workingDate), month: 3, day: 17))!

        let percentage = getPercentOfShaahZmanisFromDegrees(degrees: 16.01, sunset: true)
        if (percentage == (-Double.greatestFiniteMagnitude)) {
            return nil;
        }
        workingDate = temp//reset

        let shaahZmanit = Double(getTemporalHour(startOfDay: getSeaLevelSunrise(), endOfDay: getSeaLevelSunset()));
        return ComplexZmanimCalendar.getTimeOffset(time: getSeaLevelSunset(), offset: percentage * shaahZmanit);
    }
    
    public func getTzaisShabbatAmudeiHoraah() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.GEOMETRIC_ZENITH + 7.14)
    }
    
    /**
     This is only for display purposes, it should not be used to calculate zmanim.
     - Returns: The earlier of ``getTzaisAteretTorah()`` or ``getTzaisShabbatAmudeiHoraah()``
     */
    public func getTzaisShabbatAmudeiHoraahLesserThan40() -> Date? {
        if getTzaisAteretTorah() == nil || getTzaisShabbatAmudeiHoraah() == nil {
            return nil
        }
        if getTzaisShabbatAmudeiHoraah()?.compare(getTzaisAteretTorah()!) == .orderedDescending {
            return getTzaisAteretTorah()
        } else {
            return getTzaisShabbatAmudeiHoraah()
        }
    }
    
    /**
     This is only for display purposes, it should not be used to calculate zmanim.
     - Returns: The earlier of ``getTzais72()`` or ``getTzais72ZmanitAmudeiHoraah()``
     */
    public func getTzais72ZmanisAmudeiHoraahLkulah() -> Date? {
        if getTzais72() == nil || getTzais72ZmanisAmudeiHoraah() == nil {
            return nil
        }
        if getTzais72()?.compare(getTzais72ZmanisAmudeiHoraah()!) == .orderedDescending {
            return getTzais72ZmanisAmudeiHoraah()
        } else {
            return getTzais72()
        }
    }
}
