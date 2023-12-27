//
//  JewishCalendar.swift
//  KosherSwift
//
//  Created by Elyahu Jacobi on 12/19/23.
//

import Foundation

/**
 This class is a recreated port of KosherJava's JewishCalendar class. Note how not every method could be ported over as I have decided to rely on the built in hebrew calendar in swift. However, most methods that are not too technical are available. Most notably, the hebrew months are in a different order in swift, and the swift calendar class does not remember time itself, it just contains tools to create new dates. Therefore, the working date is the main basis for this classes day calculations. This calendar is not time sensitive, just date sensitive.
 
 * This open source Java code was originally ported by <a href="http://www.facebook.com/avromf">Avrom Finkelstien</a> from his C++ code. It was refactored to fit the KosherJava Zmanim API with simplification of the code, enhancements and some bug fixing. The class allows setting whether the holiday and <em>parsha</em> scheme follows the Israel scheme or outside Israel scheme. The default is the outside Israel scheme.
 * The parsha code was ported by Y. Paritcher from his <a href="https://github.com/yparitcher/libzmanim">libzmanim</a> code.
 * @author &copy; Y. Paritcher 2019 - 2022
 * @author &copy; Avrom Finkelstien 2002
 * @author &copy; Eliyahu Hershfeld 2011 - 2023
 * @author &copy; Elyahu Jacobi 2023
 */
public class JewishCalendar {
    
    /**
     * In Swift the value for the month of Nissan is always 8 as swift uses Tishrei as the 1st month.
     *
     * Value of the month field indicating Nissan, the first numeric month of the year in the Jewish calendar. With the
     * year starting at ``TISHREI``, it would actually be the 7th (or 8th in a {@link #isJewishLeapYear() leap
     * year}) month of the year.
     *
     */
    public static let NISSAN = 8;
    
    /**
     * In Swift the value for the month of Iyar is always 9 as swift uses Tishrei as the 1st month.
     *
     * Value of the month field indicating Iyar, the second numeric month of the year in the Jewish calendar. With the
     * year starting at ``TISHREI``, it would actually be the 8th (or 9th in a {@link #isJewishLeapYear() leap
     * year}) month of the year.
     */
    public static let IYAR = 9;
    
    /**
     * In Swift the value for the month of Sivan is always 10 as swift uses Tishrei as the 1st month.
     *
     * Value of the month field indicating Sivan, the third numeric month of the year in the Jewish calendar. With the
     * year starting at ``TISHREI``, it would actually be the 9th (or 10th in a {@link #isJewishLeapYear() leap
     * year}) month of the year.
     */
    public static let SIVAN = 10;
    
    /**
     * In Swift the value for the month of Tammuz is always 11 as swift uses Tishrei as the 1st month.
     *
     * Value of the month field indicating Tammuz, the fourth numeric month of the year in the Jewish calendar. With the
     * year starting at ``TISHREI``, it would actually be the 10th (or 11th in a ``isJewishLeapYear()``) month of the year.
     */
    public static let TAMMUZ = 11;
    
    /**
     * In Swift the value for the month of Av is always 12 as swift uses Tishrei as the 1st month.
     *
     * Value of the month field indicating Av, the fifth numeric month of the year in the Jewish calendar. With the year
     * starting at ``TISHREI``, it would actually be the 11th (or 12th in a ``isJewishLeapYear()``)
     * month of the year.
     */
    public static let AV = 12;
    
    /**
     * In Swift the value for the month of Elul is always 13 as swift uses Tishrei as the 1st month.
     *
     * Value of the month field indicating Elul, the sixth numeric month of the year in the Jewish calendar. With the
     * year starting at ``TISHREI``, it would actually be the 12th (or 13th in a ``isJewishLeapYear()``) month of the year.
     */
    public static let ELUL = 13;
    
    /**
     * In Swift the value for the month of Tishrei (Tishri) is always 1 as swift uses Tishrei as the 1st month.
     *
     * Value of the month field indicating Tishrei, the seventh numeric month of the year in the Jewish calendar. With
     * the year starting at this month, it would actually be the 1st month of the year.
     */
    public static let TISHREI = 1;
    
    /**
     * In Swift the value for the month of Cheshvan is always 2 as swift uses Tishrei as the 1st month.
     *
     * Value of the month field indicating Cheshvan/marcheshvan, the eighth numeric month of the year in the Jewish
     * calendar. With the year starting at ``TISHREI``, it would actually be the 2nd month of the year.
     */
    public static let CHESHVAN = 2;
    
    /**
     * In Swift the value for the month of Kislev is always 3 as swift uses Tishrei as the 1st month.
     *
     * Value of the month field indicating Kislev, the ninth numeric month of the year in the Jewish calendar. With the
     * year starting at ``TISHREI``, it would actually be the 3rd month of the year.
     */
    public static let KISLEV = 3;
    
    /**
     * In Swift the value for the month of Teves is always 4 as swift uses Tishrei as the 1st month.
     *
     * Value of the month field indicating Teves, the tenth numeric month of the year in the Jewish calendar. With the
     * year starting at ``TISHREI``, it would actually be the 4th month of the year.
     */
    public static let TEVES = 4;
    
    /**
     * In Swift the value for the month of Shevat is always 5 as swift uses Tishrei as the 1st month.
     *
     * Value of the month field indicating Shevat, the eleventh numeric month of the year in the Jewish calendar. With
     * the year starting at ``TISHREI``, it would actually be the 5th month of the year.
     */
    public static let SHEVAT = 5;
    
    /**
     * In Swift, this month is ONLY used on jewish leap years. Meaning: If you use the getJewishMonth method in Adar on a non leap year,
     * it will return the number 7, since Adar (the 6th month) is not used. Even though there is no Adar II on non leap years,
     * that is the way swift's hebrew calendar class is designed.
     *
     * Value of the month field indicating Adar (or Adar I in a ``isJewishLeapYear()``), the twelfth
     * numeric month of the year in the Jewish calendar. With the year starting at ``TISHREI``, it would actually
     * be the 6th month of the year.
     *
     */
    public static let ADAR = 6;
    
    /**
     * In Swift, Adar II is ALWAYS the 7th month and it will be returned on NON leap years during the month of Adar. Please keep this in mind.
     *
     * Value of the month field indicating Adar II, the leap (intercalary or embolismic) thirteenth (Undecimber) numeric
     * month of the year added in Jewish ``isJewishLeapYear()``). The leap years are years 3, 6, 8, 11,
     * 14, 17 and 19 of a 19 year cycle. With the year starting at ``TISHREI``, it would actually be the 7th month
     * of the year.
     */
    public static let ADAR_II = 7;
    
    
    /** The 14th day of Nissan, the day before Pesach (Passover).*/
    public static let EREV_PESACH = 0
    /** The holiday of Pesach (Passover) on the 15th (and 16th out of Israel) day of Nissan.*/
    public static let PESACH = 1
    /** Chol Hamoed (interim days) of Pesach (Passover)*/
    public static let CHOL_HAMOED_PESACH = 2
    /**Pesach Sheni, the 14th day of Iyar, a minor holiday.*/
    public static let PESACH_SHENI = 3
    /**Erev Shavuos (the day before Shavuos), the 5th of Sivan*/
    public static let EREV_SHAVUOS = 4
    /**Shavuos (Pentecost), the 6th of Sivan*/
    public static let SHAVUOS = 5
    /** The fast of the 17th day of Tamuz*/
    public static let SEVENTEEN_OF_TAMMUZ = 6
    /** The fast of the 9th of Av*/
    public static let TISHA_BEAV = 7
    /** The 15th day of Av, a minor holiday*/
    public static let TU_BEAV = 8
    /**Erev Rosh Hashana (the day before Rosh Hashana), the 29th of Elul*/
    public static let EREV_ROSH_HASHANA = 9
    /** Rosh Hashana, the first of Tishrei.*/
    public static let ROSH_HASHANA = 10
    /** The fast of Gedalyah, the 3rd of Tishrei.*/
    public static let FAST_OF_GEDALYAH = 11
    /** The 9th day of Tishrei, the day before of Yom Kippur.*/
    public static let EREV_YOM_KIPPUR = 12
    /** The holiday of Yom Kippur, the 10th day of Tishrei*/
    public static let YOM_KIPPUR = 13
    /** The 14th day of Tishrei, the day before of Succos/Sukkos (Tabernacles).*/
    public static let EREV_SUCCOS = 14
    /** The holiday of Succos/Sukkos (Tabernacles), the 15th (and 16th out of Israel) day of Tishrei */
    public static let SUCCOS = 15
    /** Chol Hamoed (interim days) of Succos/Sukkos (Tabernacles)*/
    public static let CHOL_HAMOED_SUCCOS = 16
    /** Hoshana Rabba, the 7th day of Succos/Sukkos that occurs on the 21st of Tishrei. */
    public static let HOSHANA_RABBA = 17
    /** Shmini Atzeres, the 8th day of Succos/Sukkos is an independent holiday that occurs on the 22nd of Tishrei. */
    public static let SHEMINI_ATZERES = 18
    /** Simchas Torah, the 9th day of Succos/Sukkos, or the second day of Shmini Atzeres that is celebrated
     *  out of Israel on the 23rd of Tishrei.
     */
    public static let SIMCHAS_TORAH = 19
    
    // public static final int EREV_CHANUKAH = 20;// probably remove this
    
    /** The holiday of Chanukah. 8 days starting on the 25th day Kislev.*/
    public static let CHANUKAH = 21
    /** The fast of the 10th day of Teves.*/
    public static let TENTH_OF_TEVES = 22
    /** Tu Bishvat on the 15th day of Shevat, a minor holiday.*/
    public static let TU_BESHVAT = 23
    /** The fast of Esther, usually on the 13th day of Adar (or Adar II on leap years). It is earlier on some years.*/
    public static let FAST_OF_ESTHER = 24
    /** The holiday of Purim on the 14th day of Adar (or Adar II on leap years).*/
    public static let PURIM = 25
    /** The holiday of Shushan Purim on the 15th day of Adar (or Adar II on leap years).*/
    public static let SHUSHAN_PURIM = 26
    /** The holiday of Purim Katan on the 14th day of Adar I on a leap year when Purim is on Adar II, a minor holiday.*/
    public static let PURIM_KATAN = 27
    /**
     * Rosh Chodesh, the new moon on the first day of the Jewish month, and the 30th day of the previous month in the
     * case of a month with 30 days.
     */
    public static let ROSH_CHODESH = 28
    /** Yom HaShoah, Holocaust Remembrance Day, usually held on the 27th of Nisan. If it falls on a Friday, it is moved
     * to the 26th, and if it falls on a Sunday it is moved to the 28th. A modern holiday.
     */
    public static let YOM_HASHOAH = 29
    /**
     * Yom HaZikaron, Israeli Memorial Day, held a day before Yom Ha'atzmaut.  A modern holiday.
     */
    public static let YOM_HAZIKARON = 30
    /** Yom Ha'atzmaut, Israel Independence Day, the 5th of Iyar, but if it occurs on a Friday or Saturday, the holiday is
     * moved back to Thursday, the 3rd of 4th of Iyar, and if it falls on a Monday, it is moved forward to Tuesday the
     * 6th of Iyar.  A modern holiday.*/
    public static let YOM_HAATZMAUT = 31
    /**
     * Yom Yerushalayim or Jerusalem Day, on 28 Iyar. A modern holiday.
     */
    public static let YOM_YERUSHALAYIM = 32
    /** The 33rd day of the Omer, the 18th of Iyar, a minor holiday.*/
    public static let LAG_BAOMER = 33
    /** The holiday of Purim Katan on the 15th day of Adar I on a leap year when Purim is on Adar II, a minor holiday.*/
    public static let SHUSHAN_PURIM_KATAN = 34
    /** The day following the last day of Pesach, Shavuos and Sukkos.*/
    public static let ISRU_CHAG = 35;
    /**
     * The day before <em>Rosh Chodesh</em> (moved to Thursday if <em>Rosh Chodesh</em> is on a Friday or <em>Shabbos</em>) in most months.
     * This constant is not actively in use.
     * @see #isYomKippurKatan()
     */
    public static let YOM_KIPPUR_KATAN = 36;
    
    /**
     * the Jewish epoch using the RD (Rata Die/Fixed Date or Reingold Dershowitz) day used in Calendrical Calculations.
     * Day 1 is January 1, 0001 Gregorian
     */
    static let JEWISH_EPOCH:Int64 = -1373429;
    
    /** The number  of <em>chalakim</em> (18) in a minute.*/
    public static let CHALAKIM_PER_MINUTE = 18;
    /** The number  of <em>chalakim</em> (1080) in an hour.*/
    public static let CHALAKIM_PER_HOUR = 1080;
    /** The number of <em>chalakim</em> (25,920) in a 24 hour day .*/
    public static let CHALAKIM_PER_DAY:Int64 = 25920; // 24 * 1080
    /** The number  of <em>chalakim</em> in an average Jewish month. A month has 29 days, 12 hours and 793
     * <em>chalakim</em> (44 minutes and 3.3 seconds) for a total of 765,433 <em>chalakim</em>*/
    public static let CHALAKIM_PER_MONTH:Int64 = 765433; // (29 * 24 + 12) * 1080 + 793
    /**
     * Days from the beginning of Sunday till molad BaHaRaD. Calculated as 1 day, 5 hours and 204 chalakim = (24 + 5) *
     * 1080 + 204 = 31524
     */
    public static let CHALAKIM_MOLAD_TOHU:Int64 = 31524;
    
    /** the internal count of <em>molad</em> hours.*/
    public var moladHours:Int = 0;
    /** the internal count of <em>molad</em> minutes.*/
    public var moladMinutes:Int = 0;
    /** the internal count of <em>molad</em> <em>chalakim</em>.*/
    public var moladChalakim:Int = 0;
    
    /**
     * A short year where both ``CHESHVAN`` and ``KISLEV`` are 29 days.
     *
     * @see #getCheshvanKislevKviah()
     * @see HebrewDateFormatter#getFormattedKviah(int)
     */
    public static let CHASERIM = 0;
    
    /**
     * An ordered year where ``CHESHVAN`` is 29 days and ``KISLEV`` is 30 days.
     *
     * @see #getCheshvanKislevKviah()
     * @see HebrewDateFormatter#getFormattedKviah(int)
     */
    public static let KESIDRAN = 1;
    
    /**
     * A long year where both ``CHESHVAN`` and ``KISLEV`` are 30 days.
     *
     * @see #getCheshvanKislevKviah()
     * @see HebrewDateFormatter#getFormattedKviah(int)
     */
    public static let SHELAIMIM = 2;
    
    
    /**
     * Is the calendar set to Israel, where some holidays have different rules.
     * @see #getInIsrael()
     * @see #setInIsrael(boolean)
     */
    public var inIsrael: Bool = false
    
    /**
     * Is the calendar set to use modern Israeli holidays such as Yom Haatzmaut.
     * @see #isUseModernHolidays()
     * @see #setUseModernHolidays(boolean)
     */
    public var useModernHolidays: Bool = false
    
    /**
     * Is the calendar set to have Purim <em>demukafim</em>, where Purim is celebrated on Shushan Purim.
     * @see #getIsMukafChoma()
     * @see #setIsMukafChoma(boolean)
     */
    public var isMukafChoma: Bool = false
    
    /**
     * List of <em>parshiyos</em> or special <em>Shabasos</em>. {@link #NONE} indicates a week without a <em>parsha</em>, while the enum for
     * the <em>parsha</em> of {@link #VZOS_HABERACHA} exists for consistency, but is not currently used. The special <em>Shabasos</em> of
     * Shekalim, Zachor, Para, Hachodesh, as well as Shabbos Shuva, Shira, Hagadol, Chazon and Nachamu are also represented in this collection
     * of <em>parshiyos</em>.
     * @see #getSpecialShabbos()
     * @see #getParshah()
     */
    public enum Parsha {
        /**NONE A week without any <em>parsha</em> such as <em>Shabbos Chol Hamoed</em> */case NONE
        /**BERESHIS*/case BERESHIS
        /**NOACH*/case NOACH
        /**LECH_LECHA*/case LECH_LECHA
        /**VAYERA*/case VAYERA
        /**CHAYEI_SARA*/case CHAYEI_SARA
        /**TOLDOS*/case TOLDOS
        /**VAYETZEI*/case VAYETZEI
        /**VAYISHLACH*/case VAYISHLACH
        /**VAYESHEV*/case VAYESHEV
        /**MIKETZ*/case MIKETZ
        /**VAYIGASH*/case VAYIGASH
        /**VAYECHI*/case VAYECHI
        /**SHEMOS*/case SHEMOS
        /**VAERA*/case VAERA
        /**BO*/case BO
        /**BESHALACH*/case BESHALACH
        /**YISRO*/case YISRO
        /**MISHPATIM*/case MISHPATIM
        /**TERUMAH*/case TERUMAH
        /**TETZAVEH*/case TETZAVEH
        /**KI_SISA*/case KI_SISA
        /**VAYAKHEL*/case VAYAKHEL
        /**PEKUDEI*/case PEKUDEI
        /**VAYIKRA*/case VAYIKRA
        /**TZAV*/case TZAV
        /**SHMINI*/case SHMINI
        /**TAZRIA*/case TAZRIA
        /**METZORA*/case METZORA
        /**ACHREI_MOS*/case ACHREI_MOS
        /**KEDOSHIM*/case KEDOSHIM
        /**EMOR*/case EMOR
        /**BEHAR*/case BEHAR
        /**BECHUKOSAI*/case BECHUKOSAI
        /**BAMIDBAR*/case BAMIDBAR
        /**NASSO*/case NASSO
        /**BEHAALOSCHA*/case BEHAALOSCHA
        /**SHLACH*/case SHLACH
        /**KORACH*/case KORACH
        /**CHUKAS*/case CHUKAS
        /**BALAK*/case BALAK
        /**PINCHAS*/case PINCHAS
        /**MATOS*/case MATOS
        /**MASEI*/case MASEI
        /**DEVARIM*/case DEVARIM
        /**VAESCHANAN*/case VAESCHANAN
        /**EIKEV*/case EIKEV
        /**REEH*/case REEH
        /**SHOFTIM*/case SHOFTIM
        /**KI_SEITZEI*/case KI_SEITZEI
        /**KI_SAVO*/case KI_SAVO
        /**NITZAVIM*/case NITZAVIM
        /**VAYEILECH*/case VAYEILECH
        /**HAAZINU*/case HAAZINU
        /**VZOS_HABERACHA*/case VZOS_HABERACHA
        /**The double parsha of Vayakhel &amp; Peudei*/case VAYAKHEL_PEKUDEI
        /**The double <em>parsha</em> of Tazria &amp; Metzora*/case TAZRIA_METZORA
        /**The double <em>parsha</em> of Achrei Mos &amp; Kedoshim*/case ACHREI_MOS_KEDOSHIM
        /**The double <em>parsha</em>of Behar &amp; Bechukosai*/case BEHAR_BECHUKOSAI
        /**The double <em>parsha</em> of Chukas &amp; Balak*/case CHUKAS_BALAK
        /**The double<em>parsha</em> of Matos &amp; Masei*/case MATOS_MASEI
        /**The double <em>parsha</em> of Nitzavim &amp; Vayelech*/case NITZAVIM_VAYEILECH
        /**The special <em>parsha</em> of Shekalim*/case SHKALIM
        /** The special <em>parsha</em> of Zachor*/case ZACHOR
        /**The special <em>parsha</em> of Para*/case PARA
        /** The special <em>parsha</em> of Hachodesh*/case HACHODESH
        /**<em>Shabbos</em> Shuva*/case SHUVA
        /**<em>Shabbos</em> Shira*/case SHIRA
        /**<em>Shabbos</em> Hagadol*/case HAGADOL
        /**<em>Shabbos</em> Chazon*/case CHAZON
        /**<em>Shabbos</em> Nachamu*/case NACHAMU
    };
    
    /**
     An array of <em>parshiyos</em> in the 17 possible combinations.
     */
    public static let parshalist = [
        [Parsha.NONE, Parsha.VAYEILECH, Parsha.HAAZINU, Parsha.NONE, Parsha.BERESHIS, Parsha.NOACH, Parsha.LECH_LECHA, Parsha.VAYERA, Parsha.CHAYEI_SARA, Parsha.TOLDOS, Parsha.VAYETZEI, Parsha.VAYISHLACH, Parsha.VAYESHEV, Parsha.MIKETZ, Parsha.VAYIGASH, Parsha.VAYECHI, Parsha.SHEMOS, Parsha.VAERA, Parsha.BO, Parsha.BESHALACH, Parsha.YISRO, Parsha.MISHPATIM, Parsha.TERUMAH, Parsha.TETZAVEH, Parsha.KI_SISA, Parsha.VAYAKHEL_PEKUDEI, Parsha.VAYIKRA, Parsha.TZAV, Parsha.NONE, Parsha.SHMINI, Parsha.TAZRIA_METZORA, Parsha.ACHREI_MOS_KEDOSHIM, Parsha.EMOR, Parsha.BEHAR_BECHUKOSAI, Parsha.BAMIDBAR, Parsha.NASSO, Parsha.BEHAALOSCHA, Parsha.SHLACH, Parsha.KORACH, Parsha.CHUKAS, Parsha.BALAK, Parsha.PINCHAS, Parsha.MATOS_MASEI, Parsha.DEVARIM, Parsha.VAESCHANAN, Parsha.EIKEV, Parsha.REEH, Parsha.SHOFTIM, Parsha.KI_SEITZEI, Parsha.KI_SAVO, Parsha.NITZAVIM_VAYEILECH],
        [Parsha.NONE, Parsha.VAYEILECH, Parsha.HAAZINU, Parsha.NONE, Parsha.BERESHIS, Parsha.NOACH, Parsha.LECH_LECHA, Parsha.VAYERA, Parsha.CHAYEI_SARA, Parsha.TOLDOS, Parsha.VAYETZEI, Parsha.VAYISHLACH, Parsha.VAYESHEV, Parsha.MIKETZ, Parsha.VAYIGASH, Parsha.VAYECHI, Parsha.SHEMOS, Parsha.VAERA, Parsha.BO, Parsha.BESHALACH, Parsha.YISRO, Parsha.MISHPATIM, Parsha.TERUMAH, Parsha.TETZAVEH, Parsha.KI_SISA, Parsha.VAYAKHEL_PEKUDEI, Parsha.VAYIKRA, Parsha.TZAV, Parsha.NONE, Parsha.SHMINI, Parsha.TAZRIA_METZORA, Parsha.ACHREI_MOS_KEDOSHIM, Parsha.EMOR, Parsha.BEHAR_BECHUKOSAI, Parsha.BAMIDBAR, Parsha.NONE, Parsha.NASSO, Parsha.BEHAALOSCHA, Parsha.SHLACH, Parsha.KORACH, Parsha.CHUKAS_BALAK, Parsha.PINCHAS, Parsha.MATOS_MASEI, Parsha.DEVARIM, Parsha.VAESCHANAN, Parsha.EIKEV, Parsha.REEH, Parsha.SHOFTIM, Parsha.KI_SEITZEI, Parsha.KI_SAVO, Parsha.NITZAVIM_VAYEILECH],
        [Parsha.NONE, Parsha.HAAZINU, Parsha.NONE, Parsha.NONE, Parsha.BERESHIS, Parsha.NOACH, Parsha.LECH_LECHA, Parsha.VAYERA, Parsha.CHAYEI_SARA, Parsha.TOLDOS, Parsha.VAYETZEI, Parsha.VAYISHLACH, Parsha.VAYESHEV, Parsha.MIKETZ, Parsha.VAYIGASH, Parsha.VAYECHI, Parsha.SHEMOS, Parsha.VAERA, Parsha.BO, Parsha.BESHALACH, Parsha.YISRO, Parsha.MISHPATIM, Parsha.TERUMAH, Parsha.TETZAVEH, Parsha.KI_SISA, Parsha.VAYAKHEL_PEKUDEI, Parsha.VAYIKRA, Parsha.TZAV, Parsha.NONE, Parsha.NONE, Parsha.SHMINI, Parsha.TAZRIA_METZORA, Parsha.ACHREI_MOS_KEDOSHIM, Parsha.EMOR, Parsha.BEHAR_BECHUKOSAI, Parsha.BAMIDBAR, Parsha.NASSO, Parsha.BEHAALOSCHA, Parsha.SHLACH, Parsha.KORACH, Parsha.CHUKAS, Parsha.BALAK, Parsha.PINCHAS, Parsha.MATOS_MASEI, Parsha.DEVARIM, Parsha.VAESCHANAN, Parsha.EIKEV, Parsha.REEH, Parsha.SHOFTIM, Parsha.KI_SEITZEI, Parsha.KI_SAVO, Parsha.NITZAVIM],
        [Parsha.NONE, Parsha.HAAZINU, Parsha.NONE, Parsha.NONE, Parsha.BERESHIS, Parsha.NOACH, Parsha.LECH_LECHA, Parsha.VAYERA, Parsha.CHAYEI_SARA, Parsha.TOLDOS, Parsha.VAYETZEI, Parsha.VAYISHLACH, Parsha.VAYESHEV, Parsha.MIKETZ, Parsha.VAYIGASH, Parsha.VAYECHI, Parsha.SHEMOS, Parsha.VAERA, Parsha.BO, Parsha.BESHALACH, Parsha.YISRO, Parsha.MISHPATIM, Parsha.TERUMAH, Parsha.TETZAVEH, Parsha.KI_SISA, Parsha.VAYAKHEL, Parsha.PEKUDEI, Parsha.VAYIKRA, Parsha.TZAV, Parsha.NONE, Parsha.SHMINI, Parsha.TAZRIA_METZORA, Parsha.ACHREI_MOS_KEDOSHIM, Parsha.EMOR, Parsha.BEHAR_BECHUKOSAI, Parsha.BAMIDBAR, Parsha.NASSO, Parsha.BEHAALOSCHA, Parsha.SHLACH, Parsha.KORACH, Parsha.CHUKAS, Parsha.BALAK, Parsha.PINCHAS, Parsha.MATOS_MASEI, Parsha.DEVARIM, Parsha.VAESCHANAN, Parsha.EIKEV, Parsha.REEH, Parsha.SHOFTIM, Parsha.KI_SEITZEI, Parsha.KI_SAVO, Parsha.NITZAVIM],
        [Parsha.NONE, Parsha.NONE, Parsha.HAAZINU, Parsha.NONE, Parsha.NONE, Parsha.BERESHIS, Parsha.NOACH, Parsha.LECH_LECHA, Parsha.VAYERA, Parsha.CHAYEI_SARA, Parsha.TOLDOS, Parsha.VAYETZEI, Parsha.VAYISHLACH, Parsha.VAYESHEV, Parsha.MIKETZ, Parsha.VAYIGASH, Parsha.VAYECHI, Parsha.SHEMOS, Parsha.VAERA, Parsha.BO, Parsha.BESHALACH, Parsha.YISRO, Parsha.MISHPATIM, Parsha.TERUMAH, Parsha.TETZAVEH, Parsha.KI_SISA, Parsha.VAYAKHEL_PEKUDEI, Parsha.VAYIKRA, Parsha.TZAV, Parsha.NONE, Parsha.SHMINI, Parsha.TAZRIA_METZORA, Parsha.ACHREI_MOS_KEDOSHIM, Parsha.EMOR, Parsha.BEHAR_BECHUKOSAI, Parsha.BAMIDBAR, Parsha.NASSO, Parsha.BEHAALOSCHA, Parsha.SHLACH, Parsha.KORACH, Parsha.CHUKAS, Parsha.BALAK, Parsha.PINCHAS, Parsha.MATOS_MASEI, Parsha.DEVARIM, Parsha.VAESCHANAN, Parsha.EIKEV, Parsha.REEH, Parsha.SHOFTIM, Parsha.KI_SEITZEI, Parsha.KI_SAVO, Parsha.NITZAVIM],
        [Parsha.NONE, Parsha.NONE, Parsha.HAAZINU, Parsha.NONE, Parsha.NONE, Parsha.BERESHIS, Parsha.NOACH, Parsha.LECH_LECHA, Parsha.VAYERA, Parsha.CHAYEI_SARA, Parsha.TOLDOS, Parsha.VAYETZEI, Parsha.VAYISHLACH, Parsha.VAYESHEV, Parsha.MIKETZ, Parsha.VAYIGASH, Parsha.VAYECHI, Parsha.SHEMOS, Parsha.VAERA, Parsha.BO, Parsha.BESHALACH, Parsha.YISRO, Parsha.MISHPATIM, Parsha.TERUMAH, Parsha.TETZAVEH, Parsha.KI_SISA, Parsha.VAYAKHEL_PEKUDEI, Parsha.VAYIKRA, Parsha.TZAV, Parsha.NONE, Parsha.SHMINI, Parsha.TAZRIA_METZORA, Parsha.ACHREI_MOS_KEDOSHIM, Parsha.EMOR, Parsha.BEHAR_BECHUKOSAI, Parsha.BAMIDBAR, Parsha.NASSO, Parsha.BEHAALOSCHA, Parsha.SHLACH, Parsha.KORACH, Parsha.CHUKAS, Parsha.BALAK, Parsha.PINCHAS, Parsha.MATOS_MASEI, Parsha.DEVARIM, Parsha.VAESCHANAN, Parsha.EIKEV, Parsha.REEH, Parsha.SHOFTIM, Parsha.KI_SEITZEI, Parsha.KI_SAVO, Parsha.NITZAVIM_VAYEILECH],
        [Parsha.NONE, Parsha.VAYEILECH, Parsha.HAAZINU, Parsha.NONE, Parsha.BERESHIS, Parsha.NOACH, Parsha.LECH_LECHA, Parsha.VAYERA, Parsha.CHAYEI_SARA, Parsha.TOLDOS, Parsha.VAYETZEI, Parsha.VAYISHLACH, Parsha.VAYESHEV, Parsha.MIKETZ, Parsha.VAYIGASH, Parsha.VAYECHI, Parsha.SHEMOS, Parsha.VAERA, Parsha.BO, Parsha.BESHALACH, Parsha.YISRO, Parsha.MISHPATIM, Parsha.TERUMAH, Parsha.TETZAVEH, Parsha.KI_SISA, Parsha.VAYAKHEL, Parsha.PEKUDEI, Parsha.VAYIKRA, Parsha.TZAV, Parsha.SHMINI, Parsha.TAZRIA, Parsha.METZORA, Parsha.NONE, Parsha.ACHREI_MOS, Parsha.KEDOSHIM, Parsha.EMOR, Parsha.BEHAR, Parsha.BECHUKOSAI, Parsha.BAMIDBAR, Parsha.NONE, Parsha.NASSO, Parsha.BEHAALOSCHA, Parsha.SHLACH, Parsha.KORACH, Parsha.CHUKAS_BALAK, Parsha.PINCHAS, Parsha.MATOS_MASEI, Parsha.DEVARIM, Parsha.VAESCHANAN, Parsha.EIKEV, Parsha.REEH, Parsha.SHOFTIM, Parsha.KI_SEITZEI, Parsha.KI_SAVO, Parsha.NITZAVIM_VAYEILECH],
        [Parsha.NONE, Parsha.VAYEILECH, Parsha.HAAZINU, Parsha.NONE, Parsha.BERESHIS, Parsha.NOACH, Parsha.LECH_LECHA, Parsha.VAYERA, Parsha.CHAYEI_SARA, Parsha.TOLDOS, Parsha.VAYETZEI, Parsha.VAYISHLACH, Parsha.VAYESHEV, Parsha.MIKETZ, Parsha.VAYIGASH, Parsha.VAYECHI, Parsha.SHEMOS, Parsha.VAERA, Parsha.BO, Parsha.BESHALACH, Parsha.YISRO, Parsha.MISHPATIM, Parsha.TERUMAH, Parsha.TETZAVEH, Parsha.KI_SISA, Parsha.VAYAKHEL, Parsha.PEKUDEI, Parsha.VAYIKRA, Parsha.TZAV, Parsha.SHMINI, Parsha.TAZRIA, Parsha.METZORA, Parsha.NONE, Parsha.NONE, Parsha.ACHREI_MOS, Parsha.KEDOSHIM, Parsha.EMOR, Parsha.BEHAR, Parsha.BECHUKOSAI, Parsha.BAMIDBAR, Parsha.NASSO, Parsha.BEHAALOSCHA, Parsha.SHLACH, Parsha.KORACH, Parsha.CHUKAS, Parsha.BALAK, Parsha.PINCHAS, Parsha.MATOS_MASEI, Parsha.DEVARIM, Parsha.VAESCHANAN, Parsha.EIKEV, Parsha.REEH, Parsha.SHOFTIM, Parsha.KI_SEITZEI, Parsha.KI_SAVO, Parsha.NITZAVIM],
        [Parsha.NONE, Parsha.HAAZINU, Parsha.NONE, Parsha.NONE, Parsha.BERESHIS, Parsha.NOACH, Parsha.LECH_LECHA, Parsha.VAYERA, Parsha.CHAYEI_SARA, Parsha.TOLDOS, Parsha.VAYETZEI, Parsha.VAYISHLACH, Parsha.VAYESHEV, Parsha.MIKETZ, Parsha.VAYIGASH, Parsha.VAYECHI, Parsha.SHEMOS, Parsha.VAERA, Parsha.BO, Parsha.BESHALACH, Parsha.YISRO, Parsha.MISHPATIM, Parsha.TERUMAH, Parsha.TETZAVEH, Parsha.KI_SISA, Parsha.VAYAKHEL, Parsha.PEKUDEI, Parsha.VAYIKRA, Parsha.TZAV, Parsha.SHMINI, Parsha.TAZRIA, Parsha.METZORA, Parsha.ACHREI_MOS, Parsha.NONE, Parsha.KEDOSHIM, Parsha.EMOR, Parsha.BEHAR, Parsha.BECHUKOSAI, Parsha.BAMIDBAR, Parsha.NASSO, Parsha.BEHAALOSCHA, Parsha.SHLACH, Parsha.KORACH, Parsha.CHUKAS, Parsha.BALAK, Parsha.PINCHAS, Parsha.MATOS, Parsha.MASEI, Parsha.DEVARIM, Parsha.VAESCHANAN, Parsha.EIKEV, Parsha.REEH, Parsha.SHOFTIM, Parsha.KI_SEITZEI, Parsha.KI_SAVO, Parsha.NITZAVIM],
        [Parsha.NONE, Parsha.HAAZINU, Parsha.NONE, Parsha.NONE, Parsha.BERESHIS, Parsha.NOACH, Parsha.LECH_LECHA, Parsha.VAYERA, Parsha.CHAYEI_SARA, Parsha.TOLDOS, Parsha.VAYETZEI, Parsha.VAYISHLACH, Parsha.VAYESHEV, Parsha.MIKETZ, Parsha.VAYIGASH, Parsha.VAYECHI, Parsha.SHEMOS, Parsha.VAERA, Parsha.BO, Parsha.BESHALACH, Parsha.YISRO, Parsha.MISHPATIM, Parsha.TERUMAH, Parsha.TETZAVEH, Parsha.KI_SISA, Parsha.VAYAKHEL, Parsha.PEKUDEI, Parsha.VAYIKRA, Parsha.TZAV, Parsha.SHMINI, Parsha.TAZRIA, Parsha.METZORA, Parsha.ACHREI_MOS, Parsha.NONE, Parsha.KEDOSHIM, Parsha.EMOR, Parsha.BEHAR, Parsha.BECHUKOSAI, Parsha.BAMIDBAR, Parsha.NASSO, Parsha.BEHAALOSCHA, Parsha.SHLACH, Parsha.KORACH, Parsha.CHUKAS, Parsha.BALAK, Parsha.PINCHAS, Parsha.MATOS, Parsha.MASEI, Parsha.DEVARIM, Parsha.VAESCHANAN, Parsha.EIKEV, Parsha.REEH, Parsha.SHOFTIM, Parsha.KI_SEITZEI, Parsha.KI_SAVO, Parsha.NITZAVIM_VAYEILECH],
        [Parsha.NONE, Parsha.NONE, Parsha.HAAZINU, Parsha.NONE, Parsha.NONE, Parsha.BERESHIS, Parsha.NOACH, Parsha.LECH_LECHA, Parsha.VAYERA, Parsha.CHAYEI_SARA, Parsha.TOLDOS, Parsha.VAYETZEI, Parsha.VAYISHLACH, Parsha.VAYESHEV, Parsha.MIKETZ, Parsha.VAYIGASH, Parsha.VAYECHI, Parsha.SHEMOS, Parsha.VAERA, Parsha.BO, Parsha.BESHALACH, Parsha.YISRO, Parsha.MISHPATIM, Parsha.TERUMAH, Parsha.TETZAVEH, Parsha.KI_SISA, Parsha.VAYAKHEL, Parsha.PEKUDEI, Parsha.VAYIKRA, Parsha.TZAV, Parsha.SHMINI, Parsha.TAZRIA, Parsha.METZORA, Parsha.NONE, Parsha.ACHREI_MOS, Parsha.KEDOSHIM, Parsha.EMOR, Parsha.BEHAR, Parsha.BECHUKOSAI, Parsha.BAMIDBAR, Parsha.NASSO, Parsha.BEHAALOSCHA, Parsha.SHLACH, Parsha.KORACH, Parsha.CHUKAS, Parsha.BALAK, Parsha.PINCHAS, Parsha.MATOS_MASEI, Parsha.DEVARIM, Parsha.VAESCHANAN, Parsha.EIKEV, Parsha.REEH, Parsha.SHOFTIM, Parsha.KI_SEITZEI, Parsha.KI_SAVO, Parsha.NITZAVIM_VAYEILECH],
        [Parsha.NONE, Parsha.NONE, Parsha.HAAZINU, Parsha.NONE, Parsha.NONE, Parsha.BERESHIS, Parsha.NOACH, Parsha.LECH_LECHA, Parsha.VAYERA, Parsha.CHAYEI_SARA, Parsha.TOLDOS, Parsha.VAYETZEI, Parsha.VAYISHLACH, Parsha.VAYESHEV, Parsha.MIKETZ, Parsha.VAYIGASH, Parsha.VAYECHI, Parsha.SHEMOS, Parsha.VAERA, Parsha.BO, Parsha.BESHALACH, Parsha.YISRO, Parsha.MISHPATIM, Parsha.TERUMAH, Parsha.TETZAVEH, Parsha.KI_SISA, Parsha.VAYAKHEL, Parsha.PEKUDEI, Parsha.VAYIKRA, Parsha.TZAV, Parsha.SHMINI, Parsha.TAZRIA, Parsha.METZORA, Parsha.NONE, Parsha.ACHREI_MOS, Parsha.KEDOSHIM, Parsha.EMOR, Parsha.BEHAR, Parsha.BECHUKOSAI, Parsha.BAMIDBAR, Parsha.NONE, Parsha.NASSO, Parsha.BEHAALOSCHA, Parsha.SHLACH, Parsha.KORACH, Parsha.CHUKAS_BALAK, Parsha.PINCHAS, Parsha.MATOS_MASEI, Parsha.DEVARIM, Parsha.VAESCHANAN, Parsha.EIKEV, Parsha.REEH, Parsha.SHOFTIM, Parsha.KI_SEITZEI, Parsha.KI_SAVO, Parsha.NITZAVIM_VAYEILECH],
        [Parsha.NONE, Parsha.VAYEILECH, Parsha.HAAZINU, Parsha.NONE, Parsha.BERESHIS, Parsha.NOACH, Parsha.LECH_LECHA, Parsha.VAYERA, Parsha.CHAYEI_SARA, Parsha.TOLDOS, Parsha.VAYETZEI, Parsha.VAYISHLACH, Parsha.VAYESHEV, Parsha.MIKETZ, Parsha.VAYIGASH, Parsha.VAYECHI, Parsha.SHEMOS, Parsha.VAERA, Parsha.BO, Parsha.BESHALACH, Parsha.YISRO, Parsha.MISHPATIM, Parsha.TERUMAH, Parsha.TETZAVEH, Parsha.KI_SISA, Parsha.VAYAKHEL_PEKUDEI, Parsha.VAYIKRA, Parsha.TZAV, Parsha.NONE, Parsha.SHMINI, Parsha.TAZRIA_METZORA, Parsha.ACHREI_MOS_KEDOSHIM, Parsha.EMOR, Parsha.BEHAR_BECHUKOSAI, Parsha.BAMIDBAR, Parsha.NASSO, Parsha.BEHAALOSCHA, Parsha.SHLACH, Parsha.KORACH, Parsha.CHUKAS, Parsha.BALAK, Parsha.PINCHAS, Parsha.MATOS_MASEI, Parsha.DEVARIM, Parsha.VAESCHANAN, Parsha.EIKEV, Parsha.REEH, Parsha.SHOFTIM, Parsha.KI_SEITZEI, Parsha.KI_SAVO, Parsha.NITZAVIM_VAYEILECH],
        [Parsha.NONE, Parsha.HAAZINU, Parsha.NONE, Parsha.NONE, Parsha.BERESHIS, Parsha.NOACH, Parsha.LECH_LECHA, Parsha.VAYERA, Parsha.CHAYEI_SARA, Parsha.TOLDOS, Parsha.VAYETZEI, Parsha.VAYISHLACH, Parsha.VAYESHEV, Parsha.MIKETZ, Parsha.VAYIGASH, Parsha.VAYECHI, Parsha.SHEMOS, Parsha.VAERA, Parsha.BO, Parsha.BESHALACH, Parsha.YISRO, Parsha.MISHPATIM, Parsha.TERUMAH, Parsha.TETZAVEH, Parsha.KI_SISA, Parsha.VAYAKHEL_PEKUDEI, Parsha.VAYIKRA, Parsha.TZAV, Parsha.NONE, Parsha.SHMINI, Parsha.TAZRIA_METZORA, Parsha.ACHREI_MOS_KEDOSHIM, Parsha.EMOR, Parsha.BEHAR, Parsha.BECHUKOSAI, Parsha.BAMIDBAR, Parsha.NASSO, Parsha.BEHAALOSCHA, Parsha.SHLACH, Parsha.KORACH, Parsha.CHUKAS, Parsha.BALAK, Parsha.PINCHAS, Parsha.MATOS_MASEI, Parsha.DEVARIM, Parsha.VAESCHANAN, Parsha.EIKEV, Parsha.REEH, Parsha.SHOFTIM, Parsha.KI_SEITZEI, Parsha.KI_SAVO, Parsha.NITZAVIM],
        [Parsha.NONE, Parsha.VAYEILECH, Parsha.HAAZINU, Parsha.NONE, Parsha.BERESHIS, Parsha.NOACH, Parsha.LECH_LECHA, Parsha.VAYERA, Parsha.CHAYEI_SARA, Parsha.TOLDOS, Parsha.VAYETZEI, Parsha.VAYISHLACH, Parsha.VAYESHEV, Parsha.MIKETZ, Parsha.VAYIGASH, Parsha.VAYECHI, Parsha.SHEMOS, Parsha.VAERA, Parsha.BO, Parsha.BESHALACH, Parsha.YISRO, Parsha.MISHPATIM, Parsha.TERUMAH, Parsha.TETZAVEH, Parsha.KI_SISA, Parsha.VAYAKHEL, Parsha.PEKUDEI, Parsha.VAYIKRA, Parsha.TZAV, Parsha.SHMINI, Parsha.TAZRIA, Parsha.METZORA, Parsha.NONE, Parsha.ACHREI_MOS, Parsha.KEDOSHIM, Parsha.EMOR, Parsha.BEHAR, Parsha.BECHUKOSAI, Parsha.BAMIDBAR, Parsha.NASSO, Parsha.BEHAALOSCHA, Parsha.SHLACH, Parsha.KORACH, Parsha.CHUKAS, Parsha.BALAK, Parsha.PINCHAS, Parsha.MATOS_MASEI, Parsha.DEVARIM, Parsha.VAESCHANAN, Parsha.EIKEV, Parsha.REEH, Parsha.SHOFTIM, Parsha.KI_SEITZEI, Parsha.KI_SAVO, Parsha.NITZAVIM_VAYEILECH],
        [Parsha.NONE, Parsha.VAYEILECH, Parsha.HAAZINU, Parsha.NONE, Parsha.BERESHIS, Parsha.NOACH, Parsha.LECH_LECHA, Parsha.VAYERA, Parsha.CHAYEI_SARA, Parsha.TOLDOS, Parsha.VAYETZEI, Parsha.VAYISHLACH, Parsha.VAYESHEV, Parsha.MIKETZ, Parsha.VAYIGASH, Parsha.VAYECHI, Parsha.SHEMOS, Parsha.VAERA, Parsha.BO, Parsha.BESHALACH, Parsha.YISRO, Parsha.MISHPATIM, Parsha.TERUMAH, Parsha.TETZAVEH, Parsha.KI_SISA, Parsha.VAYAKHEL, Parsha.PEKUDEI, Parsha.VAYIKRA, Parsha.TZAV, Parsha.SHMINI, Parsha.TAZRIA, Parsha.METZORA, Parsha.NONE, Parsha.ACHREI_MOS, Parsha.KEDOSHIM, Parsha.EMOR, Parsha.BEHAR, Parsha.BECHUKOSAI, Parsha.BAMIDBAR, Parsha.NASSO, Parsha.BEHAALOSCHA, Parsha.SHLACH, Parsha.KORACH, Parsha.CHUKAS, Parsha.BALAK, Parsha.PINCHAS, Parsha.MATOS, Parsha.MASEI, Parsha.DEVARIM, Parsha.VAESCHANAN, Parsha.EIKEV, Parsha.REEH, Parsha.SHOFTIM, Parsha.KI_SEITZEI, Parsha.KI_SAVO, Parsha.NITZAVIM],
        [Parsha.NONE, Parsha.NONE, Parsha.HAAZINU, Parsha.NONE, Parsha.NONE, Parsha.BERESHIS, Parsha.NOACH, Parsha.LECH_LECHA, Parsha.VAYERA, Parsha.CHAYEI_SARA, Parsha.TOLDOS, Parsha.VAYETZEI, Parsha.VAYISHLACH, Parsha.VAYESHEV, Parsha.MIKETZ, Parsha.VAYIGASH, Parsha.VAYECHI, Parsha.SHEMOS, Parsha.VAERA, Parsha.BO, Parsha.BESHALACH, Parsha.YISRO, Parsha.MISHPATIM, Parsha.TERUMAH, Parsha.TETZAVEH, Parsha.KI_SISA, Parsha.VAYAKHEL, Parsha.PEKUDEI, Parsha.VAYIKRA, Parsha.TZAV, Parsha.SHMINI, Parsha.TAZRIA, Parsha.METZORA, Parsha.NONE, Parsha.ACHREI_MOS, Parsha.KEDOSHIM, Parsha.EMOR, Parsha.BEHAR, Parsha.BECHUKOSAI, Parsha.BAMIDBAR, Parsha.NASSO, Parsha.BEHAALOSCHA, Parsha.SHLACH, Parsha.KORACH, Parsha.CHUKAS, Parsha.BALAK, Parsha.PINCHAS, Parsha.MATOS_MASEI, Parsha.DEVARIM, Parsha.VAESCHANAN, Parsha.EIKEV, Parsha.REEH, Parsha.SHOFTIM, Parsha.KI_SEITZEI, Parsha.KI_SAVO, Parsha.NITZAVIM_VAYEILECH]
    ];
    
    /**
     * Return the type of year for <em>parsha</em> calculations. The algorithm follows the
     * <a href="http://hebrewbooks.org/pdfpager.aspx?req=14268&amp;st=&amp;pgnum=222">Luach Arba'ah Shearim</a> in the Tur Ohr Hachaim.
     * @return the type of year for <em>parsha</em> calculations.
     */
    private func getParshaYearType() -> Int {
        var roshHashanaDayOfWeek = (getJewishCalendarElapsedDays(year: getJewishYear()) + 1) % 7; // plus one to the original Rosh Hashana of year 1 to get a week starting on Sunday
        if (roshHashanaDayOfWeek == 0) {
            roshHashanaDayOfWeek = 7; // convert 0 to 7 for Shabbos for readability
        }
        if (isJewishLeapYear()) {
            switch (roshHashanaDayOfWeek) {
            case 2:
                if (isKislevShort()) { //BaCh
                    if (getInIsrael()) {
                        return 14;
                    }
                    return 6;
                }
                if (isCheshvanLong()) { //BaSh
                    if (getInIsrael()) {
                        return 15;
                    }
                    return 7;
                }
                break;
            case 3: //Gak
                if (getInIsrael()) {
                    return 15;
                }
                return 7;
            case 5:
                if (isKislevShort()) { //HaCh
                    return 8;
                }
                if (isCheshvanLong()) { //HaSh
                    return 9;
                }
                break;
            case 7:
                if (isKislevShort()) { //ZaCh
                    return 10;
                }
                if (isCheshvanLong()) { //ZaSh
                    if (getInIsrael()) {
                        return 16;
                    }
                    return 11;
                }
                break;
            default:
                return -1
            }
        } else { //not a leap year
            switch (roshHashanaDayOfWeek) {
            case 2:
                if (isKislevShort()) { //BaCh
                    return 0;
                }
                if (isCheshvanLong()) { //BaSh
                    if (getInIsrael()) {
                        return 12;
                    }
                    return 1;
                }
                break;
            case 3: //GaK
                if (getInIsrael()) {
                    return 12;
                }
                return 1;
            case 5:
                if (isCheshvanLong()) { //HaSh
                    return 3;
                }
                if (!isKislevShort()) { //Hak
                    if (getInIsrael()) {
                        return 13;
                    }
                    return 2;
                }
                break;
            case 7:
                if (isKislevShort()) { //ZaCh
                    return 4;
                }
                if (isCheshvanLong()) { //ZaSh
                    return 5;
                }
                break;
            default:
                return -1
            }
        }
        return -1; //keep the compiler happy
    }
    
    /**
     * Returns this week's ``Parsha`` if it is <em>Shabbos</em>. It returns {@link Parsha#NONE} if the date
     * is a weekday or if there is no <em>parsha</em> that week (for example <em>Yom Tov</em> that falls on a <em>Shabbos</em>).
     *
     * @return the current <em>parsha</em>.
     */
    public func getParshah() -> Parsha {
        if (getDayOfWeek() != 7) {
            return .NONE;
        }
        
        let yearType = getParshaYearType();
        let roshHashanaDayOfWeek = getJewishCalendarElapsedDays(year: getJewishYear()) % 7;
        let day = roshHashanaDayOfWeek + getDaysSinceStartOfJewishYear();
        
        if (yearType >= 0) { // negative year should be impossible, but let's cover all bases
            return JewishCalendar.parshalist[yearType][day/7];
        }
        return .NONE; //keep the compiler happy
    }
    
    /**
     * Returns the upcoming ``Parsha`` regardless of if it is the weekday or <em>Shabbos</em> (where next
     * Shabbos's <em>Parsha</em> will be returned. This is unlike {@link #getParshah()} that returns {@link Parsha#NONE} if
     * the date is not <em>Shabbos</em>. If the upcoming <em>Shabbos</em> is a <em>Yom Tov</em> and has no <em>Parsha</em>, the
     * following week's <em>Parsha</em> will be returned.
     *
     * @return the upcoming <em>parsha</em>.
     */
    public func getUpcomingParshah() -> Parsha {
        let clone = JewishCalendar(workingDate: workingDate, inIsrael: inIsrael, useModernHolidays: useModernHolidays)
        let daysToShabbos = (7 - getDayOfWeek() + 7) % 7;
        if (getDayOfWeek() != 7) {
            clone.workingDate.addTimeInterval(TimeInterval(86400 * daysToShabbos))
        } else {
            clone.forward()
        }
        while (clone.getParshah() == .NONE) { //Yom Kippur / Sukkos or Pesach with 2 potential non-parsha Shabbosim in a row
            clone.forward()
        }
        return clone.getParshah();
    }
    
    /**
     * Returns a ``Parsha`` enum if the <em>Shabbos</em> is one of the four <em>parshiyos</em> of {@link
     * Parsha#SHKALIM <em>Shkalim</em>}, {@link Parsha#ZACHOR <em>Zachor</em>}, {@link Parsha#PARA <em>Para</em>}, {@link
     * Parsha#HACHODESH <em>Hachdesh</em>}, or five other special <em>Shabbasos</em> of {@link Parsha#HAGADOL <em>Hagadol</em>},
     * {@link Parsha#CHAZON <em>Chazon</em>}, {@link Parsha#NACHAMU <em>Nachamu</em>}, {@link Parsha#SHUVA <em>Shuva</em>},
     * {@link Parsha#SHIRA <em>Shira</em>}, or {@link Parsha#NONE Parsha.NONE} for a regular <em>Shabbos</em> (or any weekday).
     *
     * @return one of the four <em>parshiyos</em> of {@link    Parsha#SHKALIM <em>Shkalim</em>}, {@link Parsha#ZACHOR <em>Zachor</em>},
     *         {@link Parsha#PARA <em>Para</em>}, {@link Parsha#HACHODESH <em>Hachdesh</em>}, or five other special <em>Shabbasos</em>
     *         of {@link Parsha#HAGADOL <em>Hagadol</em>}, {@link Parsha#CHAZON <em>Chazon</em>}, {@link Parsha#NACHAMU <em>Nachamu</em>},
     *         {@link Parsha#SHUVA <em>Shuva</em>}, {@link Parsha#SHIRA <em>Shira</em>}, or {@link Parsha#NONE Parsha.NONE} for a regular
     *         <em>Shabbos</em> (or any weekday).
     */
    public func getSpecialShabbos() -> Parsha {
        if (getDayOfWeek() == 7) {
            if ((getJewishMonth() == JewishCalendar.SHEVAT && !isJewishLeapYear()) || (getJewishMonth() == JewishCalendar.ADAR && isJewishLeapYear())) {
                if (getJewishDayOfMonth() == 25 || getJewishDayOfMonth() == 27 || getJewishDayOfMonth() == 29) {
                    return Parsha.SHKALIM;
                }
            }
            if ((getJewishMonth() == JewishCalendar.ADAR && !isJewishLeapYear()) || getJewishMonth() == JewishCalendar.ADAR_II) {
                if (getJewishDayOfMonth() == 1) {
                    return Parsha.SHKALIM;
                }
                if (getJewishDayOfMonth() == 8 || getJewishDayOfMonth() == 9 || getJewishDayOfMonth() == 11 || getJewishDayOfMonth() == 13) {
                    return Parsha.ZACHOR;
                }
                if (getJewishDayOfMonth() == 18 || getJewishDayOfMonth() == 20 || getJewishDayOfMonth() == 22 || getJewishDayOfMonth() == 23) {
                    return Parsha.PARA;
                }
                if (getJewishDayOfMonth() == 25 || getJewishDayOfMonth() == 27 || getJewishDayOfMonth() == 29) {
                    return Parsha.HACHODESH;
                }
            }
            if (getJewishMonth() == JewishCalendar.NISSAN) {
                if(getJewishDayOfMonth() == 1) {
                    return Parsha.HACHODESH;
                }
                if(getJewishDayOfMonth() >= 8 && getJewishDayOfMonth() <= 14) {
                    return Parsha.HAGADOL;
                }
            }
            if (getJewishMonth() == JewishCalendar.AV) {
                if(getJewishDayOfMonth() >= 4 && getJewishDayOfMonth() <= 9) {
                    return Parsha.CHAZON;
                }
                if(getJewishDayOfMonth() >= 10 && getJewishDayOfMonth() <= 16) {
                    return Parsha.NACHAMU;
                }
            }
            if (getJewishMonth() == JewishCalendar.TISHREI) {
                if(getJewishDayOfMonth() >= 3 && getJewishDayOfMonth() <= 8) {
                    return Parsha.SHUVA;
                }
                
            }
            if (getParshah() == Parsha.BESHALACH) {
                return Parsha.SHIRA;
            }
        }
        return Parsha.NONE;
    }
    
    /**
     * Is this calendar set to return modern Israeli national holidays. By default this value is false. The holidays
     * are: <em>Yom HaShoah</em>, <em>Yom Hazikaron</em>, <em>Yom Ha'atzmaut</em> and <em>Yom Yerushalayim</em>.
     *
     * @return the useModernHolidays true if set to return modern Israeli national holidays
     *
     * @see #setUseModernHolidays(boolean)
     */
    public func isUseModernHolidays() -> Bool {
        return useModernHolidays
    }
    
    /**
     * Sets the calendar to return modern Israeli national holidays. By default, this value is false. The holidays are:
     * <em>Yom HaShoah</em>, <em>Yom Hazikaron</em>, <em>Yom Ha'atzmaut</em> and <em>Yom Yerushalayim</em>.
     *
     * @param useModernHolidays
     *            the useModernHolidays to set
     *
     * @see #isUseModernHolidays()
     */
    public func setUseModernHolidays(useModernHolidays:Bool) {
        self.useModernHolidays = useModernHolidays;
    }
    
    /**
     * Sets whether to use Israel holiday scheme or not. Default is false.
     *
     * @param inIsrael
     *            set to true for calculations for Israel
     *
     * @see #getInIsrael()
     */
    public func setInIsrael(inIsrael:Bool) {
        self.inIsrael = inIsrael;
    }
    
    /**
     * Gets whether Israel holiday scheme is used or not. The default (if not set) is false.
     *
     * @return if the calendar is set to Israel
     *
     * @see #setInIsrael(boolean)
     */
    public func getInIsrael() -> Bool {
        return inIsrael;
    }
    
    /**
     * Returns if the city is set as a city surrounded by a wall from the time of Yehoshua, and Shushan Purim
     * should be celebrated as opposed to regular Purim.
     * @return if the city is set as a city surrounded by a wall from the time of Yehoshua, and Shushan Purim
     *         should be celebrated as opposed to regular Purim.
     * @see #setIsMukafChoma(boolean)
     */
    public func getIsMukafChoma() -> Bool{
        return isMukafChoma
    }
    
    /**
     * Sets if the location is surrounded by a wall from the time of Yehoshua, and Shushan Purim should be
     * celebrated as opposed to regular Purim. This should be set for Yerushalayim, Shushan and other cities.
     * @param isMukafChoma is the city surrounded by a wall from the time of Yehoshua.
     *
     * @see #getIsMukafChoma()
     */
    public func setIsMukafChoma(isMukafChoma: Bool) {
        self.isMukafChoma = isMukafChoma;
    }
    
    /**
     * The internal date object that all the calculations are dependant on. Change this date to effect all the other methods of the class. By default the date is set to the system's current time with the system's current timezone.
     */
    public var workingDate:Date = Date()
    
    /**
     * By default the date is set to the system's current time with the system's current timezone. However, if you are using this class for a working date in another time zone. You must set the timezone as well as the date can change.
     */
    public var timeZone:TimeZone = TimeZone.current
    
    /**
     * Resets this date to the current system date.
     */
    public func resetDate() {
        workingDate = Date()
    }
    
    /**
     * forwards the internal date of the jewish calendar by one day
     */
    public func forward() {
        workingDate = Date(timeIntervalSince1970: workingDate.timeIntervalSince1970 + 86400)
    }
    
    /**
     * backtracks the internal date of the jewish calendar by one day
     */
    public func back() {
        workingDate = Date(timeIntervalSince1970: workingDate.timeIntervalSince1970 + (-86400))
    }
    
    public init() {}
    
    /**
     * A constructor that initializes the date to the Date parameter. useModernHolidays and inIsrael will be set to false
     *
     * @param date
     *            the <code>Date</code> to set the calendar to
     */
    public init(workingDate:Date) {
        self.workingDate = workingDate
    }
    
    /**
     * A constructor that initializes the timezone to the timezone parameter. useModernHolidays and inIsrael will be set to false
     *
     * @param date
     *            the <code>Timezone</code> to keep track of
     */
    public init(timezone:TimeZone) {
        self.timeZone = timezone
    }
    
    /**
     * A constructor that initializes the date to the Date parameter with a timezone. useModernHolidays and inIsrael will be set to false
     *
     * @param date
     *            the <code>Date</code> to set the date to
     * @param timezone
     *            the <code>Timezone</code> to keep track of
     */
    public init(workingDate:Date, timezone:TimeZone) {
        self.workingDate = workingDate
        self.timeZone = timezone
    }
    
    /**
     * A constructor that initializes the date to the Date parameter.
     *
     * @param date the <code>Date</code> to set the calendar to
     * @param inIsrael a bool to determine whether or not the methods should use in Israel calculations
     * @param shouldUseModernHolidays a bool to determine to use modern holidays in the methods or not
     */
    public init(workingDate:Date, inIsrael:Bool, useModernHolidays:Bool) {
        self.workingDate = workingDate
        self.inIsrael = inIsrael
        self.useModernHolidays = useModernHolidays
    }
    
    /**
     * A constructor that initializes the date to the Date parameter.
     *
     * @param date the <code>Date</code> to set the calendar to
     * @param inIsrael a bool to determine whether or not the methods should use in Israel calculations
     * @param shouldUseModernHolidays a bool to determine to use modern holidays in the methods or not
     */
    public init(workingDate:Date, timezone:TimeZone, inIsrael:Bool, useModernHolidays:Bool) {
        self.workingDate = workingDate
        self.inIsrael = inIsrael
        self.useModernHolidays = useModernHolidays
        self.timeZone = timezone
    }
    
    /**
     * A constructor that initializes the date to the Date parameter. useModernHolidays and inIsrael will be set to false
     *
     * @param date the <code>Date</code> to set the calendar to
     * @param isInIsrael a bool to determine whether or not the methods should use in Israel calculations
     * @param shouldUseModernHolidays a bool to determine to use modern holidays in the methods or not
     */
    public init(jewishYear:Int, jewishMonth:Int, jewishDayOfMonth:Int) {//Test this
        var hebrewCalendar = Calendar(identifier: .hebrew)
        hebrewCalendar.timeZone = timeZone
        workingDate = hebrewCalendar.date(from: DateComponents(calendar: hebrewCalendar, year: jewishYear, month: jewishMonth, day: jewishDayOfMonth))!
    }
    
    /**
     * A constructor that initializes the date to the Date parameter. useModernHolidays and inIsrael will be set to false
     *
     * @param jewishYear
     * @param jewishMonth
     * @param jewishDayOfMonth
     * @param isInIsrael a bool to determine whether or not the methods should use in Israel calculations
     */
    public init(jewishYear:Int, jewishMonth:Int, jewishDayOfMonth:Int, isInIsrael:Bool) {//Test this
        var hebrewCalendar = Calendar(identifier: .hebrew)
        hebrewCalendar.timeZone = timeZone
        workingDate = hebrewCalendar.date(from: DateComponents(calendar: hebrewCalendar, year: jewishYear, month: jewishMonth, day: jewishDayOfMonth))!
        inIsrael = isInIsrael
    }
    
    /**
     * sets the Jewish month.
     *
     * @param month
     *            the Jewish month from 1 to 12 (or 13 years in a leap year). The month count starts with 1 for Nisan
     *            and goes to 13 for Adar II
     */
    public func setJewishMonth(month:Int) {
        var hebrewCalendar = Calendar(identifier: .hebrew)
        hebrewCalendar.timeZone = timeZone
        workingDate = hebrewCalendar.date(bySetting: .month, value: month, of: workingDate)!
    }
    
    /**
     * sets the Jewish year.
     *
     * @param year
     *            the Jewish year
     */
    public func setJewishYear(year:Int) {
        var hebrewCalendar = Calendar(identifier: .hebrew)
        hebrewCalendar.timeZone = timeZone
        workingDate = hebrewCalendar.date(bySetting: .year, value: year, of: workingDate)!
    }
    
    /**
     * sets the Jewish day of month.
     *
     * @param dayOfMonth
     *            the Jewish day of month
     */
    public func setJewishDayOfMonth(dayOfMonth:Int) {
        var hebrewCalendar = Calendar(identifier: .hebrew)
        hebrewCalendar.timeZone = timeZone
        workingDate = hebrewCalendar.date(bySetting: .day, value: dayOfMonth, of: workingDate)!
    }
    
    /**
     * Returns the Jewish month 1-12 (or 13 years in a leap year). The month count starts with 1 for Nisan and goes to
     * 13 for Adar II
     *
     * @return the Jewish month from 1 to 12 (or 13 years in a leap year). The month count starts with 1 for Nisan and
     *         goes to 13 for Adar II
     */
    public func getJewishMonth() -> Int {
        var hebrewCalendar = Calendar(identifier: .hebrew)
        hebrewCalendar.timeZone = timeZone
        return hebrewCalendar.component(.month, from: workingDate);
    }
    
    /**
     * Returns the Jewish day of month.
     *
     * @return the Jewish day of the month
     */
    public func getJewishDayOfMonth() -> Int {
        var hebrewCalendar = Calendar(identifier: .hebrew)
        hebrewCalendar.timeZone = timeZone
        return hebrewCalendar.component(.day, from: workingDate);
    }
    
    /**
     * Returns the Jewish year.
     *
     * @return the Jewish year
     */
    public func getJewishYear() -> Int {
        var hebrewCalendar = Calendar(identifier: .hebrew)
        hebrewCalendar.timeZone = timeZone
        return hebrewCalendar.component(.year, from: workingDate);
    }
    
    /**
     * Forward the Jewish date by the number of months passed in.
     * @param amount the number of months to roll the month forward
     */
    private func forwardJewishMonth(amount:Int) {
        var hebrewCalendar = Calendar(identifier: .hebrew)
        hebrewCalendar.timeZone = timeZone
        workingDate = hebrewCalendar.date(byAdding: .month, value: amount, to: workingDate)!
    }
    
    /**
     * Returns the Gregorian month (between 0-11).
     *
     * @return the Gregorian month (between 0-11).
     */
    public func getGregorianMonth() -> Int {
        var gregCalendar = Calendar(identifier: .gregorian)
        gregCalendar.timeZone = timeZone
        return gregCalendar.component(.month, from: workingDate)
    }
    
    /**
     * Returns the Gregorian day of the month.
     *
     * @return the Gregorian day of the mont
     */
    public func getGregorianDayOfMonth() -> Int {
        var gregCalendar = Calendar(identifier: .gregorian)
        gregCalendar.timeZone = timeZone
        return gregCalendar.component(.day, from: workingDate)
    }
    
    /**
     * Returns the Gregotian year.
     *
     * @return the Gregorian year
     */
    public func getGregorianYear() -> Int {
        var gregCalendar = Calendar(identifier: .gregorian)
        gregCalendar.timeZone = timeZone
        return gregCalendar.component(.year, from: workingDate)
    }
    
    /**
     * Sets the Gregorian month.
     *
     * @param month
     *            the Gregorian month
     *
     */
    public func setGregorianMonth(month:Int) {
        var gregCalendar = Calendar(identifier: .gregorian)
        gregCalendar.timeZone = timeZone
        workingDate = gregCalendar.date(bySetting: .month, value: month, of: workingDate)!
    }
    
    /**
     * sets the Gregorian year.
     *
     * @param year
     *            the Gregorian year.
     */
    public func setGregorianYear(year:Int) {
        var gregCalendar = Calendar(identifier: .gregorian)
        gregCalendar.timeZone = timeZone
        workingDate = gregCalendar.date(bySetting: .year, value: year, of: workingDate)!
    }
    
    /**
     * sets the Gregorian Day of month.
     *
     * @param dayOfMonth
     *            the Gregorian Day of month.
     */
    public func setGregorianDayOfMonth(dayOfMonth:Int) {
        var gregCalendar = Calendar(identifier: .gregorian)
        gregCalendar.timeZone = timeZone
        workingDate = gregCalendar.date(bySetting: .day, value: dayOfMonth, of: workingDate)!
    }
    
    /**
     * Sets the Gregorian Date, and updates the Jewish date accordingly.
     *
     * @param year
     *            the Gregorian year
     * @param month
     *            the Gregorian month. Swift expects 1 for January
     * @param dayOfMonth
     *            the Gregorian day of month. If this is &gt; the number of days in the month/year, the last valid date of
     *            the month will be set
     */
    public func setGregorianDate(year:Int, month:Int, dayOfMonth:Int) {
        var gregCalendar = Calendar(identifier: .gregorian)
        gregCalendar.timeZone = timeZone
        workingDate = gregCalendar.date(from: DateComponents(year: year, month: month, day: dayOfMonth))!
    }
    
    /**
     * Sets the Jewish Date and updates the Gregorian date accordingly.
     *
     * @param year
     *            the Jewish year. The year can't be negative
     * @param month
     *            the Jewish month starting with Nisan. A value of 1 is expected for Nissan ... 12 for Adar and 13 for
     *            Adar II. Use the constants {@link #NISSAN} ... {@link #ADAR} (or {@link #ADAR_II} for a leap year Adar
     *            II) to avoid any confusion.
     * @param dayOfMonth
     *            the Jewish day of month. valid values are 1-30. If the day of month is set to 30 for a month that only
     *            has 29 days, the day will be set as 29.
     */
    public func setJewishDate(year:Int, month:Int, dayOfMonth:Int) {
        var gregCalendar = Calendar(identifier: .hebrew)
        gregCalendar.timeZone = timeZone
        workingDate = gregCalendar.date(from: DateComponents(year: year, month: month, day: dayOfMonth))!
    }
    
    /**
     * Sets the Jewish Date and updates the Gregorian date accordingly.
     *
     * @param year
     *            the Jewish year. The year can't be negative
     * @param month
     *            the Jewish month starting with Nisan. A value of 1 is expected for Nissan ... 12 for Adar and 13 for
     *            Adar II. Use the constants {@link #NISSAN} ... {@link #ADAR} (or {@link #ADAR_II} for a leap year Adar
     *            II) to avoid any confusion.
     * @param dayOfMonth
     *            the Jewish day of month. valid values are 1-30. If the day of month is set to 30 for a month that only
     *            has 29 days, the day will be set as 29.
     *
     * @param hours
     *            the hour of the day. Used for Molad calculations
     * @param minutes
     *            the minutes. Used for Molad calculations
     * @param chalakim
     *            the chalakim/parts. Used for Molad calculations. The chalakim should not exceed 17. Minutes should be
     *            used for larger numbers.
     *
     */
    public func setJewishDate(year:Int, month:Int, dayOfMonth:Int, hours:Int, minutes:Int, chalakim:Int) {
        var hebrewCalendar = Calendar(identifier: .hebrew)
        hebrewCalendar.timeZone = timeZone
        workingDate = hebrewCalendar.date(from: DateComponents(year: year, month: month, day: dayOfMonth, hour: hours, minute: minutes + (chalakim / 18)))!//Need to test the chalakim
    }
    
    /**
     * Returns the day of the week as a number between 1-7.
     *
     * @return the day of the week as a number between 1-7.
     */
    public func getDayOfWeek() -> Int {
        var gregCalendar = Calendar(identifier: .gregorian)
        gregCalendar.timeZone = timeZone
        return gregCalendar.component(.weekday, from: workingDate);
    }
    
    /**
     * Returns if the year is a Jewish leap year. Years 3, 6, 8, 11, 14, 17 and 19 in the 19 year cycle are leap years.
     *
     * @param year
     *            the Jewish year.
     * @return true if it is a leap year
     * @see #isJewishLeapYear()
     */
    public func isJewishLeapYear(year:Int) -> Bool {
        return ((7 * year) + 1) % 19 < 7;
    }
    
    /**
     * Returns if the year the calendar is set to is a Jewish leap year. Years 3, 6, 8, 11, 14, 17 and 19 in the 19 year
     * cycle are leap years.
     *
     * @return true if it is a leap year
     * @see #isJewishLeapYear(int)
     */
    public func isJewishLeapYear() -> Bool {
        return isJewishLeapYear(year:getJewishYear());
    }
    
    /**
     * returns the number of days from Rosh Hashana of the date passed in, to the full date passed in.
     *
     * @param year
     *            the Jewish year
     * @param month
     *            the Jewish month
     * @param dayOfMonth
     *            the day in the Jewish month
     * @return the number of days
     */
    private func getDaysSinceStartOfJewishYear(year:Int, month:Int, dayOfMonth:Int) -> Int {
        var elapsedDays = getJewishDayOfMonth()
        
        var hebrewMonth = getJewishMonth()
        
        if !isJewishLeapYear(year: getJewishYear()) && hebrewMonth >= 7 {
            hebrewMonth = hebrewMonth - 1//special case for adar 2 because swift is weird
        }
        
        for month in 1..<hebrewMonth {
            elapsedDays += getDaysInJewishMonth(month: month, year: getJewishYear())
        }
        
        return elapsedDays
    }
    
    /**
     * returns the number of days from Rosh Hashana of the date passed in, to the full date passed in.
     *
     * @return the number of days
     */
    public func getDaysSinceStartOfJewishYear() -> Int {
        return getDaysSinceStartOfJewishYear(year: getJewishYear(), month: getJewishMonth(), dayOfMonth: getJewishDayOfMonth());
    }
    
    /**
     * Returns the number of days of a Jewish month for a given month and year.
     *
     * @param month
     *            the Jewish month
     * @param year
     *            the Jewish Year
     * @return the number of days for a given Jewish month
     */
    private func getDaysInJewishMonth(month:Int, year:Int) -> Int {
        if ((month == JewishCalendar.IYAR) || (month == JewishCalendar.TAMMUZ) || (month == JewishCalendar.ELUL) || ((month == JewishCalendar.CHESHVAN) && !(isCheshvanLong(year: year)))
            || ((month == JewishCalendar.KISLEV) && isKislevShort(year: year)) || (month == JewishCalendar.TEVES)
            || ((month == JewishCalendar.ADAR) && !(isJewishLeapYear(year: year))) || (month == JewishCalendar.ADAR_II)) {
            return 29;
        } else {
            return 30;
        }
    }
    
    /**
     * Returns the number of days of the Jewish month that the calendar is currently set to.
     *
     * @return the number of days for the Jewish month that the calendar is currently set to.
     */
    public func getDaysInJewishMonth() -> Int {
        return getDaysInJewishMonth(month: getJewishMonth(), year: getJewishYear());
    }
    
    /**
     * Returns the number of days for a given Jewish year. ND+ER
     *
     * @param year
     *            the Jewish year
     * @return the number of days for a given Jewish year.
     * @see #isCheshvanLong()
     * @see #isKislevShort()
     */
    public func getDaysInJewishYear(year:Int) -> Int {
        return getJewishCalendarElapsedDays(year: year + 1) - getJewishCalendarElapsedDays(year: year);
    }
    
    /**
     * Returns the number of days for the current year that the calendar is set to.
     *
     * @return the number of days for the Object's current Jewish year.
     * @see #isCheshvanLong()
     * @see #isKislevShort()
     * @see #isJewishLeapYear()
     */
    public func getDaysInJewishYear() -> Int {
        return getDaysInJewishYear(year: getJewishYear());
    }
    
    /**
     * Returns if Cheshvan is long in a given Jewish year. The method name isLong is done since in a Kesidran (ordered)
     * year Cheshvan is short. ND+ER
     *
     * @param year
     *            the year
     * @return true if Cheshvan is long in Jewish year.
     * @see #isCheshvanLong()
     * @see #getCheshvanKislevKviah()
     */
    private func isCheshvanLong(year:Int) -> Bool {
        return getDaysInJewishYear(year: year) % 10 == 5;
    }
    
    /**
     * Returns if Cheshvan is long (30 days VS 29 days) for the current year that the calendar is set to. The method
     * name isLong is done since in a Kesidran (ordered) year Cheshvan is short.
     *
     * @return true if Cheshvan is long for the current year that the calendar is set to
     * @see #isCheshvanLong()
     */
    public func isCheshvanLong() -> Bool {
        return isCheshvanLong(year: getJewishYear());
    }
    
    /**
     * Returns if Kislev is short (29 days VS 30 days) in a given Jewish year. The method name isShort is done since in
     * a Kesidran (ordered) year Kislev is long. ND+ER
     *
     * @param year
     *            the Jewish year
     * @return true if Kislev is short for the given Jewish year.
     * @see #isKislevShort()
     * @see #getCheshvanKislevKviah()
     */
    private func isKislevShort(year:Int) -> Bool {
        return getDaysInJewishYear(year: year) % 10 == 3;
    }
    
    /**
     * Returns if the Kislev is short for the year that this class is set to. The method name isShort is done since in a
     * Kesidran (ordered) year Kislev is long.
     *
     * @return true if Kislev is short for the year that this class is set to
     */
    public func isKislevShort() -> Bool{
        return isKislevShort(year: getJewishYear());
    }
    
    /**
     * Returns the Cheshvan and Kislev kviah (whether a Jewish year is short, regular or long). It will return
     * {@link #SHELAIMIM} if both cheshvan and kislev are 30 days, {@link #KESIDRAN} if Cheshvan is 29 days and Kislev
     * is 30 days and {@link #CHASERIM} if both are 29 days.
     *
     * @return {@link #SHELAIMIM} if both cheshvan and kislev are 30 days, {@link #KESIDRAN} if Cheshvan is 29 days and
     *         Kislev is 30 days and {@link #CHASERIM} if both are 29 days.
     * @see #isCheshvanLong()
     * @see #isKislevShort()
     */
    public func getCheshvanKislevKviah() -> Int {
        if (isCheshvanLong() && !isKislevShort()) {
            return JewishCalendar.SHELAIMIM;
        } else if (!isCheshvanLong() && isKislevShort()) {
            return JewishCalendar.CHASERIM;
        } else {
            return JewishCalendar.KESIDRAN;
        }
    }
    
    /**
     * Returns the last month of a given Jewish year. This will be 6 on a non {@link #isJewishLeapYear(int) leap year}
     * or 7 on a leap year.
     *
     * @param year
     *            the Jewish year.
     * @return 6 on a non leap year or 7 on a leap year
     * @see #isJewishLeapYear(int)
     */
    private func getLastMonthOfJewishYear(year:Int) -> Int {
        return isJewishLeapYear(year: year) ? JewishCalendar.ADAR_II : JewishCalendar.ADAR;
    }
    
    /**
     * Returns the last day in a gregorian month
     *
     * @param month
     *            the Gregorian month
     * @return the last day of the Gregorian month
     */
    func getLastDayOfGregorianMonth(month:Int) -> Int {
        var gregCalendar = Calendar(identifier: .gregorian)
        gregCalendar.timeZone = timeZone
        return getLastDayOfGregorianMonth(month: month, year: gregCalendar.component(.year, from: workingDate));
    }
    
    /**
     * Returns the number of days in a given month in a given month and year.
     *
     * @param month
     *            the month. As with other cases in this class, this is 1-based, not zero-based.
     * @param year
     *            the year (only impacts February)
     * @return the number of days in the month in the given year
     */
    private func getLastDayOfGregorianMonth(month:Int, year:Int) -> Int {
        switch month {
        case 2:
            if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
                return 29;
            } else {
                return 28;
            }
        case 4:
            return 30;
        case 6:
            return 30;
        case 9:
            return 30;
        case 11:
            return 30;
        default:
            return 31;
        }
    }
    
    /**
     * Computes the absolute date from a Gregorian date. ND+ER
     *
     * @param year
     *            the Gregorian year
     * @param month
     *            the Gregorian month. Unlike the Java Calendar where January has the value of 0,This expects a 1 for
     *            January
     * @param dayOfMonth
     *            the day of the month (1st, 2nd, etc...)
     * @return the absolute Gregorian day
     */
    func gregorianDateToAbsDate(year:Int, month:Int, dayOfMonth:Int) -> Int {
        var absDate = dayOfMonth
        for m in stride(from: month-1, to: 0, by: -1) {
            absDate += getLastDayOfGregorianMonth(month: m, year: year)
        }
        return (absDate // days this year
                + 365 * (year - 1) // days in previous years ignoring leap days
                + (year - 1) / 4 // Julian leap days before this year
                - (year - 1) / 100 // minus prior century years
                + (year - 1) / 400); // plus prior years divisible by 400
    }
    
    /**
     * Returns is the year passed in is a <a href=
     * "https://en.wikipedia.org/wiki/Leap_year#Gregorian_calendar">Gregorian leap year</a>.
     * @param year the Gregorian year
     * @return if the year in question is a leap year.
     */
    func isGregorianLeapYear(year:Int) -> Bool {
        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
    }
    
    /**
     * Returns the number of days elapsed from the Sunday prior to the start of the Jewish calendar to the mean
     * conjunction of Tishri of the Jewish year.
     *
     * @param year
     *            the Jewish year
     * @return the number of days elapsed from prior to the molad Tohu BaHaRaD (Be = Monday, Ha= 5 hours and Rad =204
     *         chalakim/parts) prior to the start of the Jewish calendar, to the mean conjunction of Tishri of the
     *         Jewish year. BeHaRaD is 23:11:20 on Sunday night(5 hours 204/1080 chalakim after sunset on Sunday
     *         evening).
     */
    public func getJewishCalendarElapsedDays(year:Int) -> Int {
        let chalakimSince = getChalakimSinceMoladTohu(year: year, month: JewishCalendar.TISHREI)
        let moladDay = Int64(chalakimSince / JewishCalendar.CHALAKIM_PER_DAY)
        let moladParts = Int64(chalakimSince - chalakimSince / JewishCalendar.CHALAKIM_PER_DAY * JewishCalendar.CHALAKIM_PER_DAY)
        // delay Rosh Hashana for the 4 dechiyos
        return addDechiyos(year: year, moladDay: Int(moladDay), moladParts: Int(moladParts))
    }
    
    /**
     * Adds the 4 dechiyos for molad Tishrei. These are:
     * <ol>
     * <li>Lo ADU Rosh - Rosh Hashana can't fall on a Sunday, Wednesday or Friday. If the molad fell on one of these
     * days, Rosh Hashana is delayed to the following day.</li>
     * <li>Molad Zaken - If the molad of Tishrei falls after 12 noon, Rosh Hashana is delayed to the following day. If
     * the following day is ADU, it will be delayed an additional day.</li>
     * <li>GaTRaD - If on a non leap year the molad of Tishrei falls on a Tuesday (Ga) on or after 9 hours (T) and 204
     * chalakim (TRaD) it is delayed till Thursday (one day delay, plus one day for Lo ADU Rosh)</li>
     * <li>BeTuTaKFoT - if the year following a leap year falls on a Monday (Be) on or after 15 hours (Tu) and 589
     * chalakim (TaKFoT) it is delayed till Tuesday</li>
     * </ol>
     *
     * @param year the year
     * @param moladDay the molad day
     * @param moladParts the molad parts
     * @return the number of elapsed days in the JewishCalendar adjusted for the 4 dechiyos.
     */
    func addDechiyos(year: Int, moladDay: Int, moladParts: Int) -> Int {
        var roshHashanaDay = moladDay // if no dechiyos
        // delay Rosh Hashana for the dechiyos of the Molad - new moon 1 - Molad Zaken, 2- GaTRaD 3- BeTuTaKFoT
        if (moladParts >= 19440) || // Dechiya of Molad Zaken - molad is >= midday (18 hours * 1080 chalakim)
            ((moladDay % 7) == 2 && // start Dechiya of GaTRaD - Ga = is a Tuesday
             moladParts >= 9924 && // TRaD = 9 hours, 204 parts or later (9 * 1080 + 204)
             !isJewishLeapYear(year: year)) || // of a non-leap year - end Dechiya of GaTRaD
            ((moladDay % 7) == 1 && // start Dechiya of BeTuTaKFoT - Be = is on a Monday
             moladParts >= 16789 && // TRaD = 15 hours, 589 parts or later (15 * 1080 + 589)
             isJewishLeapYear(year: year - 1)) { // in a year following a leap year - end Dechiya of BeTuTaKFoT
            roshHashanaDay += 1 // Then postpone Rosh HaShanah one day
        }
        // start 4th Dechiya - Lo ADU Rosh - Rosh Hashana can't occur on A- sunday, D- Wednesday, U - Friday
        if (roshHashanaDay % 7 == 0) || // If Rosh HaShanah would occur on Sunday,
            (roshHashanaDay % 7 == 3) || // or Wednesday,
            (roshHashanaDay % 7 == 5) { // or Friday - end 4th Dechiya - Lo ADU Rosh
            roshHashanaDay += 1 // Then postpone it one (more) day
        }
        return roshHashanaDay
    }
    
    /**
     * Returns the number of chalakim (parts - 1080 to the hour) from the original hypothetical Molad Tohu to the year
     * and month passed in.
     *
     * @param year
     *            the Jewish year
     * @param month
     *            the Jewish month the Jewish month, with the month numbers starting from Nisan. Use the JewishDate
     *            constants such as {@link JewishDate#TISHREI}.
     * @return the number of chalakim (parts - 1080 to the hour) from the original hypothetical Molad Tohu
     */
    func getChalakimSinceMoladTohu(year: Int, month: Int) -> Int64 {
        // Jewish lunar month = 29 days, 12 hours and 793 chalakim
        // chalakim since Molad Tohu BeHaRaD - 1 day, 5 hours and 204 chalakim
        var monthOfYear = month
        if !isJewishLeapYear(year: year) && monthOfYear >= 7 {
            monthOfYear = monthOfYear - 1//special case for adar 2 because swift is weird
        }
        var monthsElapsed = (235 * ((year - 1) / 19))
        monthsElapsed = monthsElapsed + (12 * ((year - 1) % 19))
        monthsElapsed = monthsElapsed + ((7 * ((year - 1) % 19) + 1) / 19)
        monthsElapsed = monthsElapsed + (monthOfYear - 1)
        // return chalakim prior to BeHaRaD + number of chalakim since
        return Int64(JewishCalendar.CHALAKIM_MOLAD_TOHU + (JewishCalendar.CHALAKIM_PER_MONTH * Int64(monthsElapsed)))
    }
    
    /**
     * Returns the number of chalakim (parts - 1080 to the hour) from the original hypothetical Molad Tohu to the Jewish
     * year and month that this Object is set to.
     *
     * @return the number of chalakim (parts - 1080 to the hour) from the original hypothetical Molad Tohu
     */
    public func getChalakimSinceMoladTohu() -> Int64 {
        return getChalakimSinceMoladTohu(year: getJewishYear(), month: getJewishMonth());
    }
    
    /**
     * Converts the {@link JewishDate#NISSAN} based constants used by this class to numeric month starting from
     * {@link JewishDate#TISHREI}. This is required for Molad claculations.
     *
     * @param year
     *            The Jewish year
     * @param month
     *            The Jewish Month
     * @return the Jewish month of the year starting with Tishrei
     */
    private func getJewishMonthOfYear(year:Int, month:Int) -> Int {
        let isLeapYear = isJewishLeapYear(year: year);
        return (month + (isLeapYear ? 6 : 5)) % (isLeapYear ? 13 : 12) + 1;
    }
    
    /**
     * <a href="https://en.wikipedia.org/wiki/Birkat_Hachama">Birkas Hachamah</a> is recited every 28 years based on
     * Tekufas Shmuel (Julian years) that a year is 365.25 days. The <a href="https://en.wikipedia.org/wiki/Maimonides">Rambam</a>
     * in <a href="http://hebrewbooks.org/pdfpager.aspx?req=14278&amp;st=&amp;pgnum=323">Hilchos Kiddush Hachodesh 9:3</a> states that
     * tekufas Nisan of year 1 was 7 days + 9 hours before molad Nisan. This is calculated as every 10,227 days (28 * 365.25).
     * @return true for a day that Birkas Hachamah is recited.
     */
    public func isBirkasHachamah() -> Bool {
        var elapsedDays:Int = getJewishCalendarElapsedDays(year: getJewishYear()) //elapsed days since molad ToHu
        elapsedDays = elapsedDays + getDaysSinceStartOfJewishYear(); //elapsed days to the current calendar date
        
        /* Molad Nisan year 1 was 177 days after molad tohu of Tishrei. We multiply 29.5 days * 6 months from Tishrei
         * to Nisan = 177. Subtract 7 days since tekufas Nisan was 7 days and 9 hours before the molad as stated in the Rambam,
         * and we are now at 170 days. Because getJewishCalendarElapsedDays and getDaysSinceStartOfJewishYear use the value for
         * Rosh Hashana as 1, we have to add 1 day for a total of 171. To this add a day since the tekufah is on a Tuesday
         * night, and we push off the bracha to Wednesday AM resulting in the 172 used in the calculation.
         */
        if (elapsedDays % Int(28 * 365.25) == 172) { // 28 years of 365.25 days + the offset from molad tohu mentioned above
            return true;
        }
        return false;
    }
    
    /**
     * Returns an index of the Jewish holiday or fast day for the current day, or a -1 if there is no holiday for this day.
     * There are constants in this class representing each <em>Yom Tov</em>. Formatting of the <em>Yomim tovim</em> is done
     * in the {@link HebrewDateFormatter#formatYomTov(JewishCalendar)}.
     *
     * @todo Consider using enums instead of the constant ints.
     *
     * @return the index of the holiday such as the constant {@link #LAG_BAOMER} or {@link #YOM_KIPPUR} or a -1 if it is not a holiday.
     *
     * @see HebrewDateFormatter#formatYomTov(JewishCalendar)
     */
    public func getYomTovIndex() -> Int {
        let day = getJewishDayOfMonth()
        let dayOfWeek = getDayOfWeek()
        
        switch getJewishMonth() {
        case JewishCalendar.NISSAN:
            if (day == 14) {
                return JewishCalendar.EREV_PESACH;
            }
            if (day == 15 || day == 21
                || (!inIsrael && (day == 16 || day == 22))) {
                return JewishCalendar.PESACH;
            }
            if (day >= 17 && day <= 20
                || (day == 16 && inIsrael)) {
                return JewishCalendar.CHOL_HAMOED_PESACH;
            }
            if ((day == 22 && inIsrael) || (day == 23 && !inIsrael)) {
                return JewishCalendar.ISRU_CHAG;
            }
            if (isUseModernHolidays()
                && ((day == 26 && dayOfWeek == 5)
                    || (day == 28 && dayOfWeek == 2)
                    || (day == 27 && dayOfWeek != 1 && dayOfWeek != 6))) {
                return JewishCalendar.YOM_HASHOAH;
            }
            break;
        case JewishCalendar.IYAR:
            if (isUseModernHolidays()
                && ((day == 4 && dayOfWeek == 3)
                    || ((day == 3 || day == 2) && dayOfWeek == 4) || (day == 5 && dayOfWeek == 2))) {
                return JewishCalendar.YOM_HAZIKARON;
            }
            // if 5 Iyar falls on Wed, Yom Haatzmaut is that day. If it fal1s on Friday or Shabbos, it is moved back to
            // Thursday. If it falls on Monday it is moved to Tuesday
            if (isUseModernHolidays()
                && ((day == 5 && dayOfWeek == 4)
                    || ((day == 4 || day == 3) && dayOfWeek == 5) || (day == 6 && dayOfWeek == 3))) {
                return JewishCalendar.YOM_HAATZMAUT;
            }
            if (day == 14) {
                return JewishCalendar.PESACH_SHENI;
            }
            if (day == 18) {
                return JewishCalendar.LAG_BAOMER;
            }
            if (isUseModernHolidays() && day == 28) {
                return JewishCalendar.YOM_YERUSHALAYIM;
            }
            break;
        case JewishCalendar.SIVAN:
            if (day == 5) {
                return JewishCalendar.EREV_SHAVUOS;
            }
            if (day == 6 || (day == 7 && !inIsrael)) {
                return JewishCalendar.SHAVUOS;
            }
            if ((day == 7 && inIsrael) || (day == 8 && !inIsrael)) {
                return JewishCalendar.ISRU_CHAG;
            }
            break;
        case JewishCalendar.TAMMUZ:
            // push off the fast day if it falls on Shabbos
            if ((day == 17 && dayOfWeek != 7)
                || (day == 18 && dayOfWeek == 1)) {
                return JewishCalendar.SEVENTEEN_OF_TAMMUZ;
            }
            break;
        case JewishCalendar.AV:
            // if Tisha B'av falls on Shabbos, push off until Sunday
            if ((dayOfWeek == 1 && day == 10)
                || (dayOfWeek != 7 && day == 9)) {
                return JewishCalendar.TISHA_BEAV;
            }
            if (day == 15) {
                return JewishCalendar.TU_BEAV;
            }
            break;
        case JewishCalendar.ELUL:
            if (day == 29) {
                return JewishCalendar.EREV_ROSH_HASHANA;
            }
            break;
        case JewishCalendar.TISHREI:
            if (day == 1 || day == 2) {
                return JewishCalendar.ROSH_HASHANA;
            }
            if ((day == 3 && dayOfWeek != 7) || (day == 4 && dayOfWeek == 1)) {
                // push off Tzom Gedalia if it falls on Shabbos
                return JewishCalendar.FAST_OF_GEDALYAH;
            }
            if (day == 9) {
                return JewishCalendar.EREV_YOM_KIPPUR;
            }
            if (day == 10) {
                return JewishCalendar.YOM_KIPPUR;
            }
            if (day == 14) {
                return JewishCalendar.EREV_SUCCOS;
            }
            if (day == 15 || (day == 16 && !inIsrael)) {
                return JewishCalendar.SUCCOS;
            }
            if (day >= 17 && day <= 20 || (day == 16 && inIsrael)) {
                return JewishCalendar.CHOL_HAMOED_SUCCOS;
            }
            if (day == 21) {
                return JewishCalendar.HOSHANA_RABBA;
            }
            if (day == 22) {
                return JewishCalendar.SHEMINI_ATZERES;
            }
            if (day == 23 && !inIsrael) {
                return JewishCalendar.SIMCHAS_TORAH;
            }
            if ((day == 23 && inIsrael) || (day == 24 && !inIsrael)) {
                return JewishCalendar.ISRU_CHAG;
            }
            break;
        case JewishCalendar.KISLEV: // no yomtov in CHESHVAN
            // if (day == 24) {
            // return EREV_CHANUKAH;
            // } else
            if (day >= 25) {
                return JewishCalendar.CHANUKAH;
            }
            break;
        case JewishCalendar.TEVES:
            if (day == 1 || day == 2
                || (day == 3 && isKislevShort())) {
                return JewishCalendar.CHANUKAH;
            }
            if (day == 10) {
                return JewishCalendar.TENTH_OF_TEVES;
            }
            break;
        case JewishCalendar.SHEVAT:
            if (day == 15) {
                return JewishCalendar.TU_BESHVAT;
            }
            break;
        case JewishCalendar.ADAR:
            if (!isJewishLeapYear()) {
                // if 13th Adar falls on Friday or Shabbos, push back to Thursday
                if (((day == 11 || day == 12) && dayOfWeek == 5)
                    || (day == 13 && !(dayOfWeek == 6 || dayOfWeek == 7))) {
                    return JewishCalendar.FAST_OF_ESTHER;
                }
                if (day == 14) {
                    return JewishCalendar.PURIM;
                }
                if (day == 15) {
                    return JewishCalendar.SHUSHAN_PURIM;
                }
            } else { // else if a leap year
                if (day == 14) {
                    return JewishCalendar.PURIM_KATAN;
                }
                if (day == 15) {
                    return JewishCalendar.SHUSHAN_PURIM_KATAN;
                }
            }
            break;
        case JewishCalendar.ADAR_II:
            // if 13th Adar falls on Friday or Shabbos, push back to Thursday
            if (((day == 11 || day == 12) && dayOfWeek == 5)
                || (day == 13 && !(dayOfWeek == 6 || dayOfWeek == 7))) {
                return JewishCalendar.FAST_OF_ESTHER;
            }
            if (day == 14) {
                return JewishCalendar.PURIM;
            }
            if (day == 15) {
                return JewishCalendar.SHUSHAN_PURIM;
            }
            break;
        default:
            return -1
        }
        // if we get to this stage, then there are no holidays for the given date return -1
        return -1
    }
    
    /**
     * Returns true if the current day is <em>Yom Tov</em>. The method returns true even for holidays such as {@link #CHANUKAH}
     * and minor ones such as {@link #TU_BEAV} and {@link #PESACH_SHENI}. <em>Erev Yom Tov</em> (with the exception of
     * {@link #HOSHANA_RABBA}, <em>erev</em> the second days of {@link #PESACH}) returns false, as do {@link #isTaanis() fast
     * days} besides {@link #YOM_KIPPUR}. Use {@link #isAssurBemelacha()} to find the days that have a prohibition of work.
     *
     * @return true if the current day is a Yom Tov
     *
     * @see #getYomTovIndex()
     * @see #isErevYomTov()
     * @see #isErevYomTovSheni()
     * @see #isTaanis()
     * @see #isAssurBemelacha()
     * @see #isCholHamoed()
     */
    public func isYomTov() -> Bool {
        let holidayIndex = getYomTovIndex();
        if ((isErevYomTov() && (holidayIndex != JewishCalendar.HOSHANA_RABBA || (holidayIndex == JewishCalendar.CHOL_HAMOED_PESACH && getJewishDayOfMonth() != 20)))
            || (isTaanis() && holidayIndex != JewishCalendar.YOM_KIPPUR) || holidayIndex == JewishCalendar.ISRU_CHAG) {
            return false;
        }
        return getYomTovIndex() != -1;
    }
    
    /**
     * Returns true if the <em>Yom Tov</em> day has a <em>melacha</em> (work)  prohibition. This method will return false for a
     * non-<em>Yom Tov</em> day, even if it is <em>Shabbos</em>.
     *
     * @return if the <em>Yom Tov</em> day has a <em>melacha</em> (work)  prohibition.
     */
    public func isYomTovAssurBemelacha() -> Bool {
        let holidayIndex = getYomTovIndex();
        return holidayIndex == JewishCalendar.PESACH || holidayIndex == JewishCalendar.SHAVUOS || holidayIndex == JewishCalendar.SUCCOS || holidayIndex == JewishCalendar.SHEMINI_ATZERES ||
        holidayIndex == JewishCalendar.SIMCHAS_TORAH || holidayIndex == JewishCalendar.ROSH_HASHANA  || holidayIndex == JewishCalendar.YOM_KIPPUR;
    }
    
    /**
     * Returns true if it is <em>Shabbos</em> or if it is a <em>Yom Tov</em> day that has a <em>melacha</em> (work)  prohibition.
     *
     * @return if the day is a <em>Yom Tov</em> that is <em>assur bemlacha</em> or <em>Shabbos</em>
     */
    public func isAssurBemelacha() -> Bool {
        return getDayOfWeek() == 7 || isYomTovAssurBemelacha();
    }
    
    /**
     * Returns true if the day has candle lighting. This will return true on <em>Erev Shabbos</em>, <em>Erev Yom Tov</em>, the
     * first day of <em>Rosh Hashana</em> and the first days of <em>Yom Tov</em> out of Israel. It is identical
     * to calling {@link #isTomorrowShabbosOrYomTov()}.
     *
     * @return if the day has candle lighting.
     *
     * @see #isTomorrowShabbosOrYomTov()
     */
    public func hasCandleLighting() -> Bool {
        return isTomorrowShabbosOrYomTov();
    }
    
    /**
     * Returns true if tomorrow is <em>Shabbos</em> or <em>Yom Tov</em>. This will return true on <em>Erev Shabbos</em>,
     * <em>Erev Yom Tov</em>, the first day of <em>Rosh Hashana</em> and <em>erev</em> the first days of <em>Yom Tov</em>
     * out of Israel. It is identical to calling {@link #hasCandleLighting()}.
     *
     * @return will return if the next day is <em>Shabbos</em> or <em>Yom Tov</em>.
     *
     * @see #hasCandleLighting()
     */
    public func isTomorrowShabbosOrYomTov() -> Bool {
        return getDayOfWeek() == 6 || isErevYomTov() || isErevYomTovSheni();
    }
    
    /**
     * Returns true if the day is the second day of <em>Yom Tov</em>. This impacts the second day of <em>Rosh Hashana</em> everywhere and
     * the second days of Yom Tov in <em>chutz laaretz</em> (out of Israel).
     *
     * @return  if the day is the second day of <em>Yom Tov</em>.
     */
    public func isErevYomTovSheni() -> Bool {
        return (getJewishMonth() == JewishCalendar.TISHREI && (getJewishDayOfMonth() == 1))
        || (!getInIsrael()
            && ((getJewishMonth() == JewishCalendar.NISSAN && (getJewishDayOfMonth() == 15 || getJewishDayOfMonth() == 21))
                || (getJewishMonth() == JewishCalendar.TISHREI && (getJewishDayOfMonth() == 15 || getJewishDayOfMonth() == 22))
                || (getJewishMonth() == JewishCalendar.SIVAN && getJewishDayOfMonth() == 6 )));
    }
    
    /**
     * Returns true if the current day is <em>Aseres Yemei Teshuva</em>.
     *
     * @return if the current day is <em>Aseres Yemei Teshuvah</em>
     */
    public func isAseresYemeiTeshuva() -> Bool {
        return getJewishMonth() == JewishCalendar.TISHREI && getJewishDayOfMonth() <= 10;
    }
    
    /**
     * Returns true if the current day is <em>Pesach</em> (either  the <em>Yom Tov</em> of <em>Pesach</em> or<em>Chol Hamoed Pesach</em>).
     *
     * @return true if the current day is <em>Pesach</em> (either  the <em>Yom Tov</em> of <em>Pesach</em> or<em>Chol Hamoed Pesach</em>).
     * @see #isYomTov()
     * @see #isCholHamoedPesach()
     * @see #PESACH
     * @see #CHOL_HAMOED_PESACH
     */
    public func isPesach() -> Bool {
        let holidayIndex = getYomTovIndex();
        return holidayIndex == JewishCalendar.PESACH || holidayIndex == JewishCalendar.CHOL_HAMOED_PESACH;
    }
    
    /**
     * Returns true if the current day is <em>Chol Hamoed</em> of <em>Pesach</em>.
     *
     * @return true if the current day is <em>Chol Hamoed</em> of <em>Pesach</em>
     * @see #isYomTov()
     * @see #isPesach()
     * @see #CHOL_HAMOED_PESACH
     */
    public func isCholHamoedPesach() -> Bool {
        let holidayIndex = getYomTovIndex();
        return holidayIndex == JewishCalendar.CHOL_HAMOED_PESACH;
    }
    
    /**
     * Returns true if the current day is <em>Shavuos</em>.
     *
     * @return true if the current day is <em>Shavuos</em>.
     * @see #isYomTov()
     * @see #SHAVUOS
     */
    public func isShavuos() -> Bool {
        let holidayIndex = getYomTovIndex();
        return holidayIndex == JewishCalendar.SHAVUOS;
    }
    
    /**
     * Returns true if the current day is <em>Rosh Hashana</em>.
     *
     * @return true if the current day is <em>Rosh Hashana</em>.
     * @see #isYomTov()
     * @see #ROSH_HASHANA
     */
    public func isRoshHashana() -> Bool {
        let holidayIndex = getYomTovIndex();
        return holidayIndex == JewishCalendar.ROSH_HASHANA;
    }
    
    /**
     * Returns true if the current day is <em>Yom Kippur</em>.
     *
     * @return true if the current day is <em>Yom Kippur</em>.
     * @see #isYomTov()
     * @see #YOM_KIPPUR
     */
    public func isYomKippur() -> Bool {
        let holidayIndex = getYomTovIndex();
        return holidayIndex == JewishCalendar.YOM_KIPPUR;
    }
    
    /**
     * Returns true if the current day is <em>Succos</em> (either  the <em>Yom Tov</em> of <em>Succos</em> or<em>Chol Hamoed Succos</em>).
     * It will return false for {@link #isShminiAtzeres() Shmini Atzeres} and {@link #isSimchasTorah() Simchas Torah}.
     *
     * @return true if the current day is <em>Succos</em> (either  the <em>Yom Tov</em> of <em>Succos</em> or<em>Chol Hamoed Succos</em>.
     * @see #isYomTov()
     * @see #isCholHamoedSuccos()
     * @see #isHoshanaRabba()
     * @see #SUCCOS
     * @see #CHOL_HAMOED_SUCCOS
     * @see #HOSHANA_RABBA
     */
    public func isSuccos() -> Bool {
        let holidayIndex = getYomTovIndex();
        return holidayIndex == JewishCalendar.SUCCOS || holidayIndex == JewishCalendar.CHOL_HAMOED_SUCCOS || holidayIndex == JewishCalendar.HOSHANA_RABBA;
    }
    
    /**
     * Returns true if the current day is <em>Hoshana Rabba</em>.
     *
     * @return true true if the current day is <em>Hoshana Rabba</em>.
     * @see #isYomTov()
     * @see #HOSHANA_RABBA
     */
    public func isHoshanaRabba() -> Bool {
        let holidayIndex = getYomTovIndex();
        return holidayIndex == JewishCalendar.HOSHANA_RABBA;
    }
    
    /**
     * Returns true if the current day is <em>Shmini Atzeres</em>.
     *
     * @return true if the current day is <em>Shmini Atzeres</em>.
     * @see #isYomTov()
     * @see #SHEMINI_ATZERES
     */
    public func isShminiAtzeres() -> Bool {
        let holidayIndex = getYomTovIndex();
        return holidayIndex == JewishCalendar.SHEMINI_ATZERES;
    }
    
    /**
     * Returns true if the current day is <em>Simchas Torah</em>. This will always return false if {@link #getInIsrael() in Israel}
     *
     * @return true if the current day is <em>Shmini Atzeres</em>.
     * @see #isYomTov()
     * @see #SIMCHAS_TORAH
     */
    public func isSimchasTorah() -> Bool {
        let holidayIndex = getYomTovIndex();
        //if in Israel, Holiday index of SIMCHAS_TORAH will not be returned by getYomTovIndex()
        return holidayIndex == JewishCalendar.SIMCHAS_TORAH;
    }
    
    /**
     * Returns true if the current day is <em>Chol Hamoed</em> of <em>Succos</em>.
     *
     * @return true if the current day is <em>Chol Hamoed</em> of <em>Succos</em>
     * @see #isYomTov()
     * @see #CHOL_HAMOED_SUCCOS
     */
    public func isCholHamoedSuccos() -> Bool {
        let holidayIndex = getYomTovIndex();
        return holidayIndex == JewishCalendar.CHOL_HAMOED_SUCCOS || holidayIndex == JewishCalendar.HOSHANA_RABBA;
    }
    
    /**
     * Returns true if the current day is <em>Chol Hamoed</em> of <em>Pesach</em> or <em>Succos</em>.
     *
     * @return true if the current day is <em>Chol Hamoed</em> of <em>Pesach</em> or <em>Succos</em>
     * @see #isYomTov()
     * @see #CHOL_HAMOED_PESACH
     * @see #CHOL_HAMOED_SUCCOS
     */
    public func isCholHamoed() -> Bool {
        return isCholHamoedPesach() || isCholHamoedSuccos();
    }
    
    /**
     * Returns true if the current day is <em>Erev Yom Tov</em>. The method returns true for <em>Erev</em> - <em>Pesach</em>
     * (first and last days), <em>Shavuos</em>, <em>Rosh Hashana</em>, <em>Yom Kippur</em>, <em>Succos</em> and <em>Hoshana
     * Rabba</em>.
     *
     * @return true if the current day is <em>Erev</em> - <em>Pesach</em>, <em>Shavuos</em>, <em>Rosh Hashana</em>, <em>Yom
     * Kippur</em>, <em>Succos</em> and <em>Hoshana Rabba</em>.
     * @see #isYomTov()
     * @see #isErevYomTovSheni()
     */
    public func isErevYomTov() -> Bool {
        let holidayIndex = getYomTovIndex();
        return holidayIndex == JewishCalendar.EREV_PESACH || holidayIndex == JewishCalendar.EREV_SHAVUOS || holidayIndex == JewishCalendar.EREV_ROSH_HASHANA
        || holidayIndex == JewishCalendar.EREV_YOM_KIPPUR || holidayIndex == JewishCalendar.EREV_SUCCOS || holidayIndex == JewishCalendar.HOSHANA_RABBA
        || (holidayIndex == JewishCalendar.CHOL_HAMOED_PESACH && getJewishDayOfMonth() == 20);
    }
    
    /**
     * Returns true if the current day is <em>Erev Rosh Chodesh</em>. Returns false for <em>Erev Rosh Hashana</em>.
     *
     * @return true if the current day is <em>Erev Rosh Chodesh</em>. Returns false for <em>Erev Rosh Hashana</em>.
     * @see #isRoshChodesh()
     */
    public func isErevRoshChodesh() -> Bool {
        // Erev Rosh Hashana is not Erev Rosh Chodesh.
        return (getJewishDayOfMonth() == 29 && getJewishMonth() != JewishCalendar.ELUL);
    }
    
    
    /**
     * Returns true if the current day is <em>Yom Kippur Katan</em>. Returns false for <em>Erev Rosh Hashana</em>,
     * <em>Erev Rosh Chodesh Cheshvan</em>, <em>Teves</em> and <em>Iyyar</em>. If <em>Erev Rosh Chodesh</em> occurs
     * on a Friday or <em>Shabbos</em>, <em>Yom Kippur Katan</em> is moved back to Thursday.
     *
     * @return true if the current day is <em>Erev Rosh Chodesh</em>. Returns false for <em>Erev Rosh Hashana</em>.
     * @see #isRoshChodesh()
     */
    public func isYomKippurKatan() -> Bool {
        let dayOfWeek = getDayOfWeek();
        let month = getJewishMonth();
        let day = getJewishDayOfMonth();
        
        if (month == JewishCalendar.ELUL || month == JewishCalendar.TISHREI || month == JewishCalendar.KISLEV || month == JewishCalendar.NISSAN) {
            return false;
        }
        
        if (day == 29 && dayOfWeek != 6 && dayOfWeek != 7) {
            return true;
        }
        
        if ((day == 27 || day == 28) && dayOfWeek == 5 ) {
            return true;
        }
        return false;
    }
    
    /**
     * Returns true if the current day is <em>Isru Chag</em>. The method returns true for the day following <em>Pesach</em>
     * <em>Shavuos</em> and <em>Succos</em>. It utilizes {@see #getInIsrael()} to return the proper date.
     *
     * @return true if the current day is <em>Isru Chag</em>. The method returns true for the day following <em>Pesach</em>
     * <em>Shavuos</em> and <em>Succos</em>. It utilizes {@see #getInIsrael()} to return the proper date.
     */
    public func isIsruChag() -> Bool {
        let holidayIndex = getYomTovIndex();
        return holidayIndex == JewishCalendar.ISRU_CHAG;
    }
    
    /**
     * The Monday, Thursday and Monday after the first <em>Shabbos</em> after {@link #isRoshChodesh() <em>Rosh Chodesh</em>}
     * {@link JewishDate#CHESHVAN <em>Cheshvan</em>} and {@link JewishDate#IYAR <em>Iyar</em>} are <a href=
     * "https://outorah.org/p/41334/"> <em>BeHaB</em></a> days. If the last Monday of Iyar's BeHaB coincides with {@link
     * #PESACH_SHENI <em>Pesach Sheni</em>}, the method currently considers it both <em>Pesach Sheni</em> and <em>BeHaB</em>.
     * As seen in an Ohr Sameach  article on the subject <a href="https://ohr.edu/this_week/insights_into_halacha/9340">The
     * unknown Days: BeHaB Vs. Pesach Sheini?</a> there are some customs that delay the day to various points in the future.
     * @return true if the day is <em>BeHaB</em>.
     */
    public func isBeHaB() -> Bool {
        let dayOfWeek = getDayOfWeek();
        let month = getJewishMonth();
        let day = getJewishDayOfMonth();
        
        if (month == JewishCalendar.CHESHVAN || month == JewishCalendar.IYAR) {
            if((dayOfWeek == 2 && day > 4 && day < 18)
               || (dayOfWeek == 5 && day > 7 && day < 14)) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Return true if the day is a Taanis (fast day). Return true for <em>17 of Tammuz</em>, <em>Tisha B'Av</em>,
     * <em>Yom Kippur</em>, <em>Fast of Gedalyah</em>, <em>10 of Teves</em> and the <em>Fast of Esther</em>.
     * See isRegularTaanis if you do not want Yom Kippur included.
     *
     * @return true if today is a fast day
     */
    public func isTaanis() -> Bool {
        let holidayIndex = getYomTovIndex();
        return holidayIndex == JewishCalendar.SEVENTEEN_OF_TAMMUZ || holidayIndex == JewishCalendar.TISHA_BEAV || holidayIndex == JewishCalendar.YOM_KIPPUR
        || holidayIndex == JewishCalendar.FAST_OF_GEDALYAH || holidayIndex == JewishCalendar.TENTH_OF_TEVES || holidayIndex == JewishCalendar.FAST_OF_ESTHER;
    }
    
    /**
     * Return true if the day is a Taanis (fast day) and not Yom Kippur. Return true for <em>17 of Tammuz</em>, <em>Tisha B'Av</em>,
     * <em>Fast of Gedalyah</em>, <em>10 of Teves</em> and the <em>Fast of Esther</em>.
     *
     * @return true if today is a fast day  and not Yom Kippur
     */
    public func isRegularTaanis() -> Bool {
        let holidayIndex = getYomTovIndex();
        return holidayIndex == JewishCalendar.SEVENTEEN_OF_TAMMUZ || holidayIndex == JewishCalendar.TISHA_BEAV || holidayIndex == JewishCalendar.FAST_OF_GEDALYAH || holidayIndex == JewishCalendar.TENTH_OF_TEVES || holidayIndex == JewishCalendar.FAST_OF_ESTHER;
    }
    
    /**
     * Return true if the day is <em>Taanis Bechoros</em> (on <em>Erev Pesach</em>). It will return true for the 14th
     * of <em>Nissan</em> if it is not on <em>Shabbos</em>, or if the 12th of <em>Nissan</em> occurs on a Thursday.
     *
     * @return true if today is <em>Taanis Bechoros</em>.
     */
    public func isTaanisBechoros() -> Bool {
        let day = getJewishDayOfMonth();
        let dayOfWeek = getDayOfWeek();
        // on 14 Nissan unless that is Shabbos where the fast is moved back to Thursday
        return getJewishMonth() == JewishCalendar.NISSAN && ((day == 14 && dayOfWeek != 7) ||
                                                             (day == 12 && dayOfWeek == 5 ));
    }
    
    /**
     * Returns the day of <em>Chanukah</em> or -1 if it is not <em>Chanukah</em>.
     *
     * @return the day of <em>Chanukah</em> or -1 if it is not <em>Chanukah</em>.
     * @see #isChanukah()
     */
    public func getDayOfChanukah() -> Int {
        let day = getJewishDayOfMonth();
        if (isChanukah()) {
            if (getJewishMonth() == JewishCalendar.KISLEV) {
                return day - 24;
            } else { // teves
                return isKislevShort() ? day + 5 : day + 6;
            }
        } else {
            return -1;
        }
    }
    
    /**
     * Returns true if the current day is one of the 8 days of <em>Chanukah</em>.
     *
     * @return if the current day is one of the 8 days of <em>Chanukah</em>.
     *
     * @see #getDayOfChanukah()
     */
    public func isChanukah() -> Bool {
        return getYomTovIndex() == JewishCalendar.CHANUKAH;
    }
    
    /**
     * Returns if the day is Purim (<a href="https://en.wikipedia.org/wiki/Purim#Shushan_Purim">Shushan Purim</a>
     * in a mukaf choma and regular Purim in a non-mukaf choma).
     * @return if the day is Purim (Shushan Purim in a mukaf choma and regular Purin in a non-mukaf choma)
     *
     * @see #getIsMukafChoma()
     * @see #setIsMukafChoma(boolean)
     */
    public func isPurim() -> Bool {
        if(isMukafChoma) {
            return getYomTovIndex() == JewishCalendar.SHUSHAN_PURIM;
        } else {
            return getYomTovIndex() == JewishCalendar.PURIM;
        }
    }
    
    /**
     * Returns if the day is Rosh Chodesh. Rosh Hashana will return false
     *
     * @return true if it is Rosh Chodesh. Rosh Hashana will return false
     */
    public func isRoshChodesh() -> Bool {
        // Rosh Hashana is not rosh chodesh. Elul never has 30 days
        return (getJewishDayOfMonth() == 1 && getJewishMonth() != JewishCalendar.TISHREI) || getJewishDayOfMonth() == 30;
    }
    
    /**
     * Returns if the day is <em>Shabbos</em> and Sunday is <em>Rosh Chodesh</em>.
     *
     * @return true if it is <em>Shabbos</em> and Sunday is <em>Rosh Chodesh</em>.
     * @todo There is more to tweak in this method (it does not cover all cases and opinions), and it may be removed.
     */
    public func isMacharChodesh() -> Bool {
        return (getDayOfWeek() == 7 && (getJewishDayOfMonth() == 30 || getJewishDayOfMonth() == 29));
    }
    
    /**
     * Returns if the day is <em>Shabbos Mevorchim</em>.
     *
     * @return true if it is <em>Shabbos Mevorchim</em>.
     */
    public func isShabbosMevorchim() -> Bool {
        return (getDayOfWeek() == 7 && getJewishDayOfMonth() >= 23 && getJewishDayOfMonth() <= 29 && getJewishMonth() != JewishCalendar.ELUL);
    }
    
    /**
     * Returns the int value of the <em>Omer</em> day or -1 if the day is not in the <em>Omer</em>.
     *
     * @return The <em>Omer</em> count as an int or -1 if it is not a day of the <em>Omer</em>.
     */
    public func getDayOfOmer() -> Int {
        var omer = -1; // not a day of the Omer
        let month = getJewishMonth();
        let day = getJewishDayOfMonth();
        
        // if Nissan and second day of Pesach and on
        if (month == JewishCalendar.NISSAN && day >= 16) {
            omer = day - 15;
            // if Iyar
        } else if (month == JewishCalendar.IYAR) {
            omer = day + 15;
            // if Sivan and before Shavuos
        } else if (month == JewishCalendar.SIVAN && day < 6) {
            omer = day + 44;
        }
        return omer;
    }
    
    /**
     * Returns if the day is Tisha Be'Av (the 9th of Av).
     * @return if the day is Tisha Be'Av (the 9th of Av).
     */
    public func isTishaBav() -> Bool {
        let holidayIndex = getYomTovIndex();
        return holidayIndex == JewishCalendar.TISHA_BEAV;
    }
    
    /**
     This method does not return anything, however, it does set the variables moladHours, moladMiutes, and moladChalakim with the proper
     values for the molad of this month. Using these variable, you can create a string like so: "The molad is at 20 hours, 1 minutes and 3 Chalakim".
     There is also a method to recieve a string like this called getMoladAsString
     */
    public func calculateMolad() {
        let chalakim = getChalakimSinceMoladTohu(year: getJewishYear(), month: getJewishMonth())
        let moladToAbsDate = (chalakim / JewishCalendar.CHALAKIM_PER_DAY) + (JewishCalendar.JEWISH_EPOCH)
        var year = moladToAbsDate / 366
        while (moladToAbsDate >= gregorianDateToAbsDate(year: Int(year)+1,month: 1,dayOfMonth: 1)) {
            year+=1
        }
        var month = 1
        while (moladToAbsDate > gregorianDateToAbsDate(year: Int(year), month: month, dayOfMonth: getLastDayOfGregorianMonth(month: month, year: Int(year)))) {
            month+=1
        }
        var dayOfMonth = Int(moladToAbsDate) - gregorianDateToAbsDate(year: Int(year), month: month, dayOfMonth: 1) + 1
        if dayOfMonth > getLastDayOfGregorianMonth(month: month, year: Int(year)) {
            dayOfMonth = getLastDayOfGregorianMonth(month: month, year: Int(year))
        }
        let conjunctionDay = chalakim / JewishCalendar.CHALAKIM_PER_DAY
        let conjunctionParts = chalakim - conjunctionDay * JewishCalendar.CHALAKIM_PER_DAY
        
        self.moladHours = Int(conjunctionParts / 1080)
        let moladRemainingChalakim = Int(conjunctionParts) - moladHours * 1080
        self.moladMinutes = moladRemainingChalakim / 18
        self.moladChalakim = moladRemainingChalakim - moladMinutes * 18
        self.moladHours = (Int(moladHours) + 18) % 24
    }
    
    /**
     This method sets the variables moladHours, moladMinutes, and moladChalakim within this class and returns a string like so: "The molad is at 20 hours, 1 minutes and 3 Chalakim"
     */
    public func getMoladAsString() -> String {
        let chalakim = getChalakimSinceMoladTohu(year: getJewishYear(), month: getJewishMonth())
        let moladToAbsDate = (chalakim / JewishCalendar.CHALAKIM_PER_DAY) + (JewishCalendar.JEWISH_EPOCH)
        var year = moladToAbsDate / 366
        while (moladToAbsDate >= gregorianDateToAbsDate(year: Int(year)+1,month: 1,dayOfMonth: 1)) {
            year+=1
        }
        var month = 1
        while (moladToAbsDate > gregorianDateToAbsDate(year: Int(year), month: month, dayOfMonth: getLastDayOfGregorianMonth(month: month, year: Int(year)))) {
            month+=1
        }
        var dayOfMonth = Int(moladToAbsDate) - gregorianDateToAbsDate(year: Int(year), month: month, dayOfMonth: 1) + 1
        if dayOfMonth > getLastDayOfGregorianMonth(month: month, year: Int(year)) {
            dayOfMonth = getLastDayOfGregorianMonth(month: month, year: Int(year))
        }
        let conjunctionDay = chalakim / JewishCalendar.CHALAKIM_PER_DAY
        let conjunctionParts = chalakim - conjunctionDay * JewishCalendar.CHALAKIM_PER_DAY
        
        self.moladHours = Int(conjunctionParts / 1080)
        let moladRemainingChalakim = Int(conjunctionParts) - moladHours * 1080
        self.moladMinutes = moladRemainingChalakim / 18
        self.moladChalakim = moladRemainingChalakim - moladMinutes * 18
        self.moladHours = (Int(moladHours) + 18) % 24
        
        return "The molad is at "
            .appending(String(moladHours))
            .appending(" hours, ")
            .appending(String(moladMinutes))
            .appending(" minutes and ")
            .appending(String(moladChalakim))
            .appending(" Chalakim")
    }
    
    /**
     * Returns the <em>molad</em> in Standard Time in Yerushalayim as a Date. The traditional calculation uses local time.
     * This method subtracts 20.94 minutes (20 minutes and 56.496 seconds) from the local time (of <em>Har Habayis</em>
     * with a longitude of 35.2354&deg; is 5.2354&deg; away from the %15 timezone longitude) to get to standard time. This
     * method intentionally uses standard time and not daylight savings time. Swift will implicitly format the time to the
     * default (or set) Timezone.
     *
     * @return the Date representing the moment of the <em>molad</em> in Yerushalayim standard time (GMT + 2)
     */
    public func getMoladAsDate() -> Date {
        let chalakim = getChalakimSinceMoladTohu(year: getJewishYear(), month: getJewishMonth())
        let moladToAbsDate = (chalakim / JewishCalendar.CHALAKIM_PER_DAY) + (JewishCalendar.JEWISH_EPOCH)
        var year = moladToAbsDate / 366
        while (moladToAbsDate >= gregorianDateToAbsDate(year: Int(year)+1,month: 1,dayOfMonth: 1)) {
            year+=1
        }
        var month = 1
        while (moladToAbsDate > gregorianDateToAbsDate(year: Int(year), month: month, dayOfMonth: getLastDayOfGregorianMonth(month: month, year: Int(year)))) {
            month+=1
        }
        var dayOfMonth = Int(moladToAbsDate) - gregorianDateToAbsDate(year: Int(year), month: month, dayOfMonth: 1) + 1
        if dayOfMonth > getLastDayOfGregorianMonth(month: month, year: Int(year)) {
            dayOfMonth = getLastDayOfGregorianMonth(month: month, year: Int(year))
        }
        let conjunctionDay = chalakim / JewishCalendar.CHALAKIM_PER_DAY
        let conjunctionParts = chalakim - conjunctionDay * JewishCalendar.CHALAKIM_PER_DAY
        
        let moladHours = conjunctionParts / 1080
        let moladRemainingChalakim = conjunctionParts - moladHours * 1080
        var moladMinutes = moladRemainingChalakim / 18
        let moladChalakim = moladRemainingChalakim - moladMinutes * 18
        var moladSeconds = Double(moladChalakim * 10 / 3)
        
        // subtract local time difference of 20.94 minutes (20 minutes and 56.496 seconds) to get to Standard time
        moladMinutes = moladMinutes - 20
        moladSeconds = moladSeconds - 56.496
        
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = Calendar.current.timeZone
        
        // The raw molad Date (point in time) must be generated using standard time. Using "Asia/Jerusalem" timezone will result in the time
        // being incorrectly off by an hour in the summer due to DST. Proper adjustment for the actual time in DST will be done by the date
        // formatter class used to display the Date.
        var moladDay = DateComponents(calendar: calendar, timeZone: TimeZone(identifier: "GMT+2")!, year: Int(year), month: Int(month), day: Int(dayOfMonth), hour: Int(moladHours), minute: Int(moladMinutes), second: Int(moladSeconds)-1)
        
        if moladHours > 6 {
            moladDay.day! += 1
            moladDay.setValue(Int(moladHours), for: .hour)
        }
        moladDay.setValue((Int(moladHours) + 18) % 24, for: .hour)
        
        return calendar.date(from: moladDay)!
    }
    
    /**
     * Returns the earliest time of <em>Kiddush Levana</em> calculated as 3 days after the molad. This method returns the time
     * even if it is during the day when <em>Kiddush Levana</em> can't be said. Callers of this method should consider
     * displaying the next <em>tzais</em> if the <em>zman</em> is between <em>alos</em> and <em>tzais</em>.
     *
     * @return the Date representing the moment 3 days after the molad.
     *
     * @see com.kosherjava.zmanim.ComplexZmanimCalendar#getTchilasZmanKidushLevana3Days()
     * @see com.kosherjava.zmanim.ComplexZmanimCalendar#getTchilasZmanKidushLevana3Days(Date, Date)
     */
    public func getTchilasZmanKidushLevana3Days() -> Date {
        let molad = getMoladAsDate();
        var gregCalendar = Calendar(identifier: .gregorian)
        gregCalendar.timeZone = timeZone
        return gregCalendar.date(byAdding: .day, value: 3, to: molad)!
    }
    
    /**
     * Returns the earliest time of <em>Kiddush Levana</em> calculated as 7 days after the <em>molad</em> as mentioned
     * by the <a href="http://en.wikipedia.org/wiki/Yosef_Karo">Mechaber</a>. See the <a
     * href="http://en.wikipedia.org/wiki/Yoel_Sirkis">Bach's</a> opinion on this time. This method returns the time
     * even if it is during the day when <em>Kiddush Levana</em> can't be said. Callers of this method should consider
     * displaying the next <em>tzais</em> if the <em>zman</em> is between <em>alos</em> and <em>tzais</em>.
     *
     * @return the Date representing the moment 7 days after the molad.
     *
     * @see com.kosherjava.zmanim.ComplexZmanimCalendar#getTchilasZmanKidushLevana7Days()
     * @see com.kosherjava.zmanim.ComplexZmanimCalendar#getTchilasZmanKidushLevana7Days(Date, Date)
     */
    public func getTchilasZmanKidushLevana7Days() -> Date {
        let molad = getMoladAsDate();
        var gregCalendar = Calendar(identifier: .gregorian)
        gregCalendar.timeZone = timeZone
        return gregCalendar.date(byAdding: .day, value: 7, to: molad)!
    }
    
    /**
     * Returns the latest time of Kiddush Levana according to the <a
     * href="http://en.wikipedia.org/wiki/Yaakov_ben_Moshe_Levi_Moelin">Maharil's</a> opinion that it is calculated as
     * halfway between <em>molad</em> and <em>molad</em>. This adds half the 29 days, 12 hours and 793 <em>chalakim</em>
     * time between <em>molad</em> and <em>molad</em> (14 days, 18 hours, 22 minutes and 666 milliseconds) to the month's
     * <em>molad</em>. This method returns the time even if it is during the day when <em>Kiddush Levana</em> can't be
     * recited. Callers of this method should consider displaying <em>alos</em> before this time if the <em>zman</em> is
     * between <em>alos</em> and <em>tzais</em>.
     *
     * @return the Date representing the moment halfway between <em>molad</em> and <em>molad</em>.
     *
     * @see #getSofZmanKidushLevana15Days()
     * @see com.kosherjava.zmanim.ComplexZmanimCalendar#getSofZmanKidushLevanaBetweenMoldos()
     * @see com.kosherjava.zmanim.ComplexZmanimCalendar#getSofZmanKidushLevanaBetweenMoldos(Date, Date)
     */
    public func getSofZmanKidushLevanaBetweenMoldos() -> Date {
        let molad = getMoladAsDate();
        var gregCalendar = Calendar(identifier: .gregorian)
        gregCalendar.timeZone = timeZone
        // add half the time between molad and molad (half of 29 days, 12 hours and 793 chalakim (44 minutes, 3.3
        // seconds), or 14 days, 18 hours, 22 minutes and 666 milliseconds). Add it as hours, not days, to avoid
        // DST/ST crossover issues.
        let moladWithHoursAdded = gregCalendar.date(byAdding: .hour, value: (24 * 14) + 18, to: molad)!
        let moladWithMinutesAdded = gregCalendar.date(byAdding: .minute, value: 22, to: moladWithHoursAdded)!
        let moladWithSecondsAdded = gregCalendar.date(byAdding: .second, value: 1, to: moladWithMinutesAdded)!
        return gregCalendar.date(byAdding: .nanosecond, value: 666000000, to: moladWithSecondsAdded)!
    }
    
    /**
     * Returns the latest time of <em>Kiddush Levana</em> calculated as 15 days after the <em>molad.</em> This is the
     * opinion brought down in the Shulchan Aruch (Orach Chaim 426). It should be noted that some opinions hold that
     * the <a href="http://en.wikipedia.org/wiki/Moses_Isserles">Rema</a> who brings down the the <a
     * href="http://en.wikipedia.org/wiki/Yaakov_ben_Moshe_Levi_Moelin">Maharil's</a> opinion of calculating it as
     * {@link #getSofZmanKidushLevanaBetweenMoldos() half way between <em>molad</em> and <em>molad</em>} is of the
     * opinion of the Mechaber as well. Also see the Aruch Hashulchan. For additional details on the subject, See Rabbi
     * Dovid Heber's very detailed writeup in Siman Daled (chapter 4) of <a
     * href="http://www.worldcat.org/oclc/461326125">Shaarei Zmanim</a>. This method returns the time even if it is during
     * the day when <em>Kiddush Levana</em> can't be said. Callers of this method should consider displaying <em>alos</em>
     * before this time if the <em>zman</em> is between <em>alos</em> and <em>tzais</em>.
     *
     * @return the Date representing the moment 15 days after the <em>molad</em>.
     * @see #getSofZmanKidushLevanaBetweenMoldos()
     * @see com.kosherjava.zmanim.ComplexZmanimCalendar#getSofZmanKidushLevana15Days()
     * @see com.kosherjava.zmanim.ComplexZmanimCalendar#getSofZmanKidushLevana15Days(Date, Date)
     */
    public func getSofZmanKidushLevana15Days() -> Date {
        let molad = getMoladAsDate();
        var gregCalendar = Calendar(identifier: .gregorian)
        gregCalendar.timeZone = timeZone
        return gregCalendar.date(byAdding: .day, value: 7, to: molad)!
    }
    
    /**
     * Returns the <em>Daf Yomi (Bavli)</em> for the date that the calendar is set to. See the
     * {@link HebrewDateFormatter#formatDafYomiBavli(Daf)} for the ability to format the <em>daf</em> in
     * Hebrew or transliterated <em>masechta</em> names.
     *
     * @return the daf as a {@link Daf}
     */
    public func getDafYomiBavli() -> Daf? {
        return YomiCalculator.getDafYomiBavli(jewishCalendar: self);
    }
    /**
     * Returns the <em>Daf Yomi (Yerushalmi)</em> for the date that the calendar is set to. See the
     * {@link HebrewDateFormatter#formatDafYomiYerushalmi(Daf)} for the ability to format the <em>daf</em>
     * in Hebrew or transliterated <em>masechta</em> names.
     *
     * @return the daf as a {@link Daf}
     */
    public func getDafYomiYerushalmi() -> Daf? {
        return YerushalmiYomiCalculator.getDafYomiYerushalmi(jewishCalendar: self);
    }
    
    /**
     * Returns the elapsed days since <em>Tekufas Tishrei</em>. This uses <em>Tekufas Shmuel</em> (identical to the <a href=
     * "https://en.wikipedia.org/wiki/Julian_year_(astronomy)">Julian Year</a> with a solar year length of 365.25 days).
     * The notation used below is D = days, H = hours and C = chalakim. <em><a href="https://en.wikipedia.org/wiki/Molad"
     * >Molad</a> BaHaRad</em> was 2D,5H,204C or 5H,204C from the start of <em>Rosh Hashana</em> year 1. For <em>molad
     * Nissan</em> add 177D, 4H and 438C (6 * 29D, 12H and 793C), or 177D,9H,642C after <em>Rosh Hashana</em> year 1.
     * <em>Tekufas Nissan</em> was 7D, 9H and 642C before <em>molad Nissan</em> according to the Rambam, or 170D, 0H and
     * 0C after <em>Rosh Hashana</em> year 1. <em>Tekufas Tishrei</em> was 182D and 3H (365.25 / 2) before <em>tekufas
     * Nissan</em>, or 12D and 15H before <em>Rosh Hashana</em> of year 1. Outside of Israel we start reciting <em>Tal
     * Umatar</em> in <em>Birkas Hashanim</em> from 60 days after <em>tekufas Tishrei</em>. The 60 days include the day of
     * the <em>tekufah</em> and the day we start reciting <em>Tal Umatar</em>. 60 days from the tekufah == 47D and 9H
     * from <em>Rosh Hashana</em> year 1.
     *
     * @return the number of elapsed days since <em>tekufas Tishrei</em>.
     *
     * @see #isVeseinTalUmatarStartDate()
     * @see #isVeseinTalUmatarStartingTonight()
     * @see #isVeseinTalUmatarRecited()
     */
    public func getTekufasTishreiElapsedDays() -> Int {
        // Days since Rosh Hashana year 1. Add 1/2 day as the first tekufas tishrei was 9 hours into the day. This allows all
        // 4 years of the secular leap year cycle to share 47 days. Truncate 47D and 9H to 47D for simplicity.
        let days = Double(getJewishCalendarElapsedDays(year: getJewishYear())) + Double(getDaysSinceStartOfJewishYear() - 1) + 0.5
        // days of completed solar years
        let solar = Double(getJewishYear() - 1) * 365.25
        return Int(floor(days - solar))
    }
    
    /**
     Returns a double if the current day has a tekufa event. The double represents the amout of hours and minutes into the day the tekufa event happens at. You will need to minus 6 hours from this double to account for the hebrew date starting at 6 hours into the day. See the ``getTekufaAsDate(shouldMinus21Minutes:)`` method for more details.
     - Returns a double representing the hours and minutes of the tekufa with 6 hours added
     */
    public func getTekufa() -> Double? {
        let INITIAL_TEKUFA_OFFSET = 12.625 // the number of days Tekufas Tishrei occurs before JEWISH_EPOCH
        
        let days = Double(getJewishCalendarElapsedDays(year: getJewishYear()) + getDaysSinceStartOfJewishYear()) + INITIAL_TEKUFA_OFFSET - 1 // total days since first Tekufas Tishrei event
        
        let solarDaysElapsed = days.truncatingRemainder(dividingBy: 365.25) // total days elapsed since start of solar year
        let tekufaDaysElapsed = solarDaysElapsed.truncatingRemainder(dividingBy: 91.3125) // the number of days that have passed since a tekufa event
        if (tekufaDaysElapsed > 0 && tekufaDaysElapsed <= 1) { // if the tekufa happens in the upcoming 24 hours
            return ((1.0 - tekufaDaysElapsed) * 24.0).truncatingRemainder(dividingBy: 24) // rationalize the tekufa event to number of hours since start of jewish day
        } else {
            return nil
        }
    }
    
    /**
     Returns a string if the current day has a tekufa event. The string will contain the name of the tekufa/season that is arriving. If this method is called on a day without the tekufa event, it will return an empty string.
     - Returns a string with the tekufa name or an empty string on a day with no tekufa change
     */
    public func getTekufaName() -> String {
        let tekufaNames = ["Tishri", "Tevet", "Nissan", "Tammuz"]
        let INITIAL_TEKUFA_OFFSET = 12.625 // the number of days Tekufas Tishrei occurs before JEWISH_EPOCH
        
        let days = Double(getJewishCalendarElapsedDays(year: getJewishYear()) + getDaysSinceStartOfJewishYear()) + INITIAL_TEKUFA_OFFSET - 1 // total days since first Tekufas Tishrei event
        
        let solarDaysElapsed = days.truncatingRemainder(dividingBy: 365.25) // total days elapsed since start of solar year
        let currentTekufaNumber = Int(solarDaysElapsed / 91.3125)
        let tekufaDaysElapsed = solarDaysElapsed.truncatingRemainder(dividingBy: 91.3125) // the number of days that have passed since a tekufa event
        
        if (tekufaDaysElapsed > 0 && tekufaDaysElapsed <= 1) {//if the tekufa happens in the upcoming 24 hours
            return tekufaNames[currentTekufaNumber]
        } else {
            return ""
        }
    }
    
    /**
     Returns a Date if the current day has a tekufa event. The Date will contain the time of the tekufa/season that is arriving. If this method is called on a day without the tekufa event, it will return a nil. The default implementation of this method will return the Tekufa event according to the calculations of Rabbi Tulchinsky calendar. However, there is also the opinion of Rabbi Yonah Mertzbach, who says to calculate the tekufa based on local midday in Israel which causes a 21-minute difference. There is a third opinion as well to use seasonal midday but that is not an accepted opinion.
     - Returns a Date with the tekufa time or a nil on a day with no tekufa change
     - Parameter shouldMinus21Minutes a bool that, if true, removes 21 minutes from the time of Rabbi Tulchinsky's tekufa which is the opinion of Rabbi Yonah Mertzbach.
     */
    public func getTekufaAsDate(shouldMinus21Minutes:Bool = false) -> Date? {
        let yerushalayimStandardTZ = TimeZone(identifier: "GMT+2")!
        let cal = Calendar(identifier: .gregorian)
        let workingDateComponents = cal.dateComponents([.year, .month, .day], from: workingDate)
        guard let tekufa = getTekufa() else {
            return nil
        }
        let hours = tekufa - 6
        var minutes = Int((hours - Double(Int(hours))) * 60)
        if shouldMinus21Minutes {
            minutes -= 21
        }
        return cal.date(from: DateComponents(calendar: cal, timeZone: yerushalayimStandardTZ, year: workingDateComponents.year, month: workingDateComponents.month, day: workingDateComponents.day, hour: Int(hours), minute: minutes, second: 0, nanosecond: 0))
    }
    
    /**
     * returns true if the current hebrew year is a shmita year. Note that according to Rashi and other Rishonim, the year before is the year of shmita.
     */
    public func isShmitaYear() -> Bool {
        return (getJewishYear() % 7) == 0
    }
    
    /**
     * Returns a string containing the Jewish date in the form, "day Month, year" e.g. "21 Shevat, 5729". For more
     * complex formatting, use the formatter classes.
     *
     * @return the Jewish date in the form "day Month, year" e.g. "21 Shevat, 5729"
     * @see HebrewDateFormatter#format(JewishDate)
     */
    public func toString() -> String {
        return HebrewDateFormatter().format(jewishCalendar: self);
    }
}
