//
//  HebrewDateFormatter.swift
//  KosherSwift
//
//  Created by Elyahu Jacobi on 12/20/23.
//

import Foundation

/**
 * The HebrewDateFormatter class formats a {@link JewishCalendar}.
 *
 * The class formats Jewish dates, numbers, <em>Daf Yomi</em> (<em>Bavli</em> and <em>Yerushalmi</em>), the <em>Omer</em>,
 * <em>Parshas Hashavua</em> (including the special <em>parshiyos</em> of <em>Shekalim</em>, <em>Zachor</em>, <em>Parah</em>
 * and <em>Hachodesh</em>), Yomim Tovim and the Molad (experimental) in Hebrew or Latin chars, and has various settings.
 * Sample full date output includes (using various options):
 * <ul>
 * <li>21 Shevat, 5729</li>
 * <li>&#x5DB;&#x5D0; &#x5E9;&#x5D1;&#x5D8; &#x5EA;&#x5E9;&#x5DB;&#x5D8;</li>
 * <li>&#x5DB;&#x5F4;&#x5D0; &#x5E9;&#x5D1;&#x5D8; &#x5D4;&#x5F3;&#x5EA;&#x5E9;&#x5DB;&#x5F4;&#x5D8;</li>
 * <li>&#x5DB;&#x5F4;&#x5D0; &#x5E9;&#x5D1;&#x5D8; &#x5EA;&#x5E9;&#x5F4;&#x05E4; or
 * &#x5DB;&#x5F4;&#x5D0; &#x5E9;&#x5D1;&#x5D8; &#x5EA;&#x5E9;&#x5F4;&#x05E3;</li>
 * <li>&#x05DB;&#x05F3; &#x05E9;&#x05D1;&#x05D8; &#x05D5;&#x05F3; &#x05D0;&#x05DC;&#x05E4;&#x05D9;&#x05DD;</li>
 * </ul>
 *
 * @see JewishCalendar
 * @see JewishCalendar
 *
 * @author &copy; Eliyahu Hershfeld 2011 - 2023
 */
public class HebrewDateFormatter {
    
    /**
     * See {@link #isHebrewFormat()} and {@link #setHebrewFormat(boolean)}.
     */
    private var hebrewFormat = false;
    
    /**
     * See {@link #isUseLongHebrewYears()} and {@link #setUseLongHebrewYears(boolean)}.
     */
    private var useLonghebrewYears = false;
    
    /**
     * See {@link #isUseGershGershayim()} and {@link #setUseGershGershayim(boolean)}.
     */
    private var useGershGershayim = true;
    
    /**
     * See {@link #isLongWeekFormat()} and {@link #setLongWeekFormat(boolean)}.
     */
    private var longWeekFormat = true;
    
    /**
     * See {@link #isUseFinalFormLetters()} and {@link #setUseFinalFormLetters(boolean)}.
     */
    private var useFinalFormLetters = false;
    
    /**
     * The internal DateFormat.&nbsp; See {@link #isLongWeekFormat()} and {@link #setLongWeekFormat(boolean)}.
     */
    private let weekFormat = DateFormatter();
    
    /**
         * List of transliterated parshiyos using the default <em>Ashkenazi</em> pronunciation.&nbsp; The formatParsha method
         * uses self for transliterated <em>parsha</em> formatting.&nbsp; self list can be overridden (for <em>Sephardi</em>
         * English transliteration for example) by setting the {@link #setTransliteratedParshiosList(EnumMap)}.&nbsp; The list
         * includes double and special <em>parshiyos</em> is set as "<em>Bereshis, Noach, Lech Lecha, Vayera, Chayei Sara,
         * Toldos, Vayetzei, Vayishlach, Vayeshev, Miketz, Vayigash, Vayechi, Shemos, Vaera, Bo, Beshalach, Yisro, Mishpatim,
         * Terumah, Tetzaveh, Ki Sisa, Vayakhel, Pekudei, Vayikra, Tzav, Shmini, Tazria, Metzora, Achrei Mos, Kedoshim, Emor,
         * Behar, Bechukosai, Bamidbar, Nasso, Beha'aloscha, Sh'lach, Korach, Chukas, Balak, Pinchas, Matos, Masei, Devarim,
         * Vaeschanan, Eikev, Re'eh, Shoftim, Ki Seitzei, Ki Savo, Nitzavim, Vayeilech, Ha'Azinu, Vezos Habracha,
         * Vayakhel Pekudei, Tazria Metzora, Achrei Mos Kedoshim, Behar Bechukosai, Chukas Balak, Matos Masei, Nitzavim Vayeilech,
         * Shekalim, Zachor, Parah, Hachodesh,Shuva, Shira, Hagadol, Chazon, Nachamu</em>".
         *
         * @see #formatParsha(JewishCalendar)
         */
    private var transliteratedParshaMap:[JewishCalendar.Parsha: String];
        
    private var hebrewParshaMap:[JewishCalendar.Parsha: String];
        
        /**
         * Default constructor sets the {@link EnumMap}s of Hebrew and default transliterated parshiyos.
         */
        init() {
            transliteratedParshaMap = [
                JewishCalendar.Parsha.NONE: "",
                JewishCalendar.Parsha.BERESHIS: "Bereshis",
                        JewishCalendar.Parsha.NOACH: "Noach",
                        JewishCalendar.Parsha.LECH_LECHA: "Lech Lecha",
                        JewishCalendar.Parsha.VAYERA: "Vayera",
                        JewishCalendar.Parsha.CHAYEI_SARA: "Chayei Sara",
                        JewishCalendar.Parsha.TOLDOS: "Toldos",
                        JewishCalendar.Parsha.VAYETZEI: "Vayetzei",
                        JewishCalendar.Parsha.VAYISHLACH: "Vayishlach",
                        JewishCalendar.Parsha.VAYESHEV: "Vayeshev",
                        JewishCalendar.Parsha.MIKETZ: "Miketz",
                        JewishCalendar.Parsha.VAYIGASH: "Vayigash",
                        JewishCalendar.Parsha.VAYECHI: "Vayechi",
                        JewishCalendar.Parsha.SHEMOS: "Shemos",
                        JewishCalendar.Parsha.VAERA: "Vaera",
                        JewishCalendar.Parsha.BO: "Bo",
                        JewishCalendar.Parsha.BESHALACH: "Beshalach",
                        JewishCalendar.Parsha.YISRO: "Yisro",
                        JewishCalendar.Parsha.MISHPATIM: "Mishpatim",
                        JewishCalendar.Parsha.TERUMAH: "Terumah",
                        JewishCalendar.Parsha.TETZAVEH: "Tetzaveh",
                        JewishCalendar.Parsha.KI_SISA: "Ki Sisa",
                        JewishCalendar.Parsha.VAYAKHEL: "Vayakhel",
                        JewishCalendar.Parsha.PEKUDEI: "Pekudei",
                        JewishCalendar.Parsha.VAYIKRA: "Vayikra",
                        JewishCalendar.Parsha.TZAV: "Tzav",
                        JewishCalendar.Parsha.SHMINI: "Shmini",
                        JewishCalendar.Parsha.TAZRIA: "Tazria",
                        JewishCalendar.Parsha.METZORA: "Metzora",
                        JewishCalendar.Parsha.ACHREI_MOS: "Achrei Mos",
                        JewishCalendar.Parsha.KEDOSHIM: "Kedoshim",
                        JewishCalendar.Parsha.EMOR: "Emor",
                        JewishCalendar.Parsha.BEHAR: "Behar",
                        JewishCalendar.Parsha.BECHUKOSAI: "Bechukosai",
                        JewishCalendar.Parsha.BAMIDBAR: "Bamidbar",
                        JewishCalendar.Parsha.NASSO: "Nasso",
                        JewishCalendar.Parsha.BEHAALOSCHA: "Beha'aloscha",
                        JewishCalendar.Parsha.SHLACH: "Sh'lach",
                        JewishCalendar.Parsha.KORACH: "Korach",
                        JewishCalendar.Parsha.CHUKAS: "Chukas",
                        JewishCalendar.Parsha.BALAK: "Balak",
                        JewishCalendar.Parsha.PINCHAS: "Pinchas",
                        JewishCalendar.Parsha.MATOS: "Matos",
                        JewishCalendar.Parsha.MASEI: "Masei",
                        JewishCalendar.Parsha.DEVARIM: "Devarim",
                        JewishCalendar.Parsha.VAESCHANAN: "Vaeschanan",
                        JewishCalendar.Parsha.EIKEV: "Eikev",
                        JewishCalendar.Parsha.REEH: "Re'eh",
                        JewishCalendar.Parsha.SHOFTIM: "Shoftim",
                        JewishCalendar.Parsha.KI_SEITZEI: "Ki Seitzei",
                        JewishCalendar.Parsha.KI_SAVO: "Ki Savo",
                        JewishCalendar.Parsha.NITZAVIM: "Nitzavim",
                        JewishCalendar.Parsha.VAYEILECH: "Vayeilech",
                        JewishCalendar.Parsha.HAAZINU: "Ha'Azinu",
                        JewishCalendar.Parsha.VZOS_HABERACHA: "Vezos Habracha",
                        JewishCalendar.Parsha.VAYAKHEL_PEKUDEI: "Vayakhel Pekudei",
                        JewishCalendar.Parsha.TAZRIA_METZORA: "Tazria Metzora",
                        JewishCalendar.Parsha.ACHREI_MOS_KEDOSHIM: "Achrei Mos Kedoshim",
                        JewishCalendar.Parsha.BEHAR_BECHUKOSAI: "Behar Bechukosai",
                        JewishCalendar.Parsha.CHUKAS_BALAK: "Chukas Balak",
                        JewishCalendar.Parsha.MATOS_MASEI: "Matos Masei",
                        JewishCalendar.Parsha.NITZAVIM_VAYEILECH: "Nitzavim Vayeilech",
                        JewishCalendar.Parsha.SHKALIM: "Shekalim",
                        JewishCalendar.Parsha.ZACHOR: "Zachor",
                        JewishCalendar.Parsha.PARA: "Parah",
                        JewishCalendar.Parsha.HACHODESH: "Hachodesh",
                        JewishCalendar.Parsha.SHUVA: "Shuva",
                        JewishCalendar.Parsha.SHIRA: "Shira",
                        JewishCalendar.Parsha.HAGADOL: "Hagadol",
                        JewishCalendar.Parsha.CHAZON: "Chazon",
                        JewishCalendar.Parsha.NACHAMU: "Nachamu",
            ]
            
            hebrewParshaMap = [
                                JewishCalendar.Parsha.NONE: "",
                                JewishCalendar.Parsha.BERESHIS: "בראשית",
                                JewishCalendar.Parsha.NOACH: "נח",
                                JewishCalendar.Parsha.LECH_LECHA: "לך לך",
                                JewishCalendar.Parsha.VAYERA: "וירא",
                                JewishCalendar.Parsha.CHAYEI_SARA: "חיי שרה",
                                JewishCalendar.Parsha.TOLDOS: "תולדות",
                                JewishCalendar.Parsha.VAYETZEI: "ויצא",
                                JewishCalendar.Parsha.VAYISHLACH: "וישלח",
                                JewishCalendar.Parsha.VAYESHEV: "וישב",
                                JewishCalendar.Parsha.MIKETZ: "מקץ",
                                JewishCalendar.Parsha.VAYIGASH: "ויגש",
                                JewishCalendar.Parsha.VAYECHI: "ויחי",
                                JewishCalendar.Parsha.SHEMOS: "שמות",
                                JewishCalendar.Parsha.VAERA: "וארא",
                                JewishCalendar.Parsha.BO: "בא",
                                JewishCalendar.Parsha.BESHALACH: "בשלח",
                                JewishCalendar.Parsha.YISRO: "יתרו",
                                JewishCalendar.Parsha.MISHPATIM: "משפטים",
                                JewishCalendar.Parsha.TERUMAH: "תרומה",
                                JewishCalendar.Parsha.TETZAVEH: "תצוה",
                                JewishCalendar.Parsha.KI_SISA: "כי תשא",
                                JewishCalendar.Parsha.VAYAKHEL: "ויקהל",
                                JewishCalendar.Parsha.PEKUDEI: "פקודי",
                                JewishCalendar.Parsha.VAYIKRA: "ויקרא",
                                JewishCalendar.Parsha.TZAV: "צו",
                                JewishCalendar.Parsha.SHMINI: "שמיני",
                                JewishCalendar.Parsha.TAZRIA: "תזריע",
                                JewishCalendar.Parsha.METZORA: "מצרע",
                                JewishCalendar.Parsha.ACHREI_MOS: "אחרי מות",
                                JewishCalendar.Parsha.KEDOSHIM: "קדושים",
                                JewishCalendar.Parsha.EMOR: "אמור",
                                JewishCalendar.Parsha.BEHAR: "בהר",
                                JewishCalendar.Parsha.BECHUKOSAI: "בחקתי",
                                JewishCalendar.Parsha.BAMIDBAR: "במדבר",
                                JewishCalendar.Parsha.NASSO: "נשא",
                                JewishCalendar.Parsha.BEHAALOSCHA: "בהעלתך",
                                JewishCalendar.Parsha.SHLACH: "שלח לך",
                                JewishCalendar.Parsha.KORACH: "קרח",
                                JewishCalendar.Parsha.CHUKAS: "חוקת",
                                JewishCalendar.Parsha.BALAK: "בלק",
                                JewishCalendar.Parsha.PINCHAS: "פינחס",
                                JewishCalendar.Parsha.MATOS: "מטות",
                                JewishCalendar.Parsha.MASEI: "מסעי",
                                JewishCalendar.Parsha.DEVARIM: "דברים",
                                JewishCalendar.Parsha.VAESCHANAN: "ואתחנן",
                                JewishCalendar.Parsha.EIKEV: "עקב",
                                JewishCalendar.Parsha.REEH: "ראה",
                                JewishCalendar.Parsha.SHOFTIM: "שופטים",
                                JewishCalendar.Parsha.KI_SEITZEI: "כי תצא",
                                JewishCalendar.Parsha.KI_SAVO: "כי תבוא",
                                JewishCalendar.Parsha.NITZAVIM: "נצבים",
                                JewishCalendar.Parsha.VAYEILECH: "וילך",
                                JewishCalendar.Parsha.HAAZINU: "האזינו",
                                JewishCalendar.Parsha.VZOS_HABERACHA: "וזאת הברכה",
                                JewishCalendar.Parsha.VAYAKHEL_PEKUDEI: "ויקהל פקודי",
                                JewishCalendar.Parsha.TAZRIA_METZORA: "תזריע מצרע",
                                JewishCalendar.Parsha.ACHREI_MOS_KEDOSHIM: "אחרי מות קדושים",
                                JewishCalendar.Parsha.BEHAR_BECHUKOSAI: "בהר בחקתי",
                                JewishCalendar.Parsha.CHUKAS_BALAK: "חוקת בלק",
                                JewishCalendar.Parsha.MATOS_MASEI: "מטות מסעי",
                                JewishCalendar.Parsha.NITZAVIM_VAYEILECH: "נצבים וילך",
                                JewishCalendar.Parsha.SHKALIM: "שקלים",
                                JewishCalendar.Parsha.ZACHOR: "זכור",
                                JewishCalendar.Parsha.PARA: "פרה",
                                JewishCalendar.Parsha.HACHODESH: "החדש",
                                JewishCalendar.Parsha.SHUVA: "שובה",
                                JewishCalendar.Parsha.SHIRA: "שירה",
                                JewishCalendar.Parsha.HAGADOL: "הגדול",
                                JewishCalendar.Parsha.CHAZON: "חזון",
                                JewishCalendar.Parsha.NACHAMU: "נחמו"
            ]
        }

        /**
         * Returns if the {@link #formatDayOfWeek(JewishCalendar)} will use the long format such as
         * &#x05E8;&#x05D0;&#x05E9;&#x05D5;&#x05DF; or short such as &#x05D0; when formatting the day of week in
         * {@link #isHebrewFormat() Hebrew}.
         *
         * @return the longWeekFormat
         * @see #setLongWeekFormat(boolean)
         * @see #formatDayOfWeek(JewishCalendar)
         */
        public func isLongWeekFormat() -> Bool{
            return longWeekFormat;
        }

        /**
         * Setting to control if the {@link #formatDayOfWeek(JewishCalendar)} will use the long format such as
         * &#x05E8;&#x05D0;&#x05E9;&#x05D5;&#x05DF; or short such as &#x05D0; when formatting the day of week in
         * {@link #isHebrewFormat() Hebrew}.
         *
         * @param longWeekFormat
         *            the longWeekFormat to set
         */
    public func setLongWeekFormat(longWeekFormat:Bool) {
            self.longWeekFormat = longWeekFormat;
            if (longWeekFormat) {
                weekFormat.dateFormat = "EEEE";
            } else {
                weekFormat.dateFormat = "EEE";
            }
        }

        /**
         * The <a href="https://en.wikipedia.org/wiki/Geresh#Punctuation_mark">gersh</a> character is the &#x05F3; char
         * that is similar to a single quote and is used in formatting Hebrew numbers.
         */
        private static let GERESH = "\u{05F3}";
        
        /**
         * The <a href="https://en.wikipedia.org/wiki/Gershayim#Punctuation_mark">gershyim</a> character is the &#x05F4; char
         * that is similar to a double quote and is used in formatting Hebrew numbers.
         */
        private static let GERSHAYIM = "\u{05F4}";
        
        /**
         * Transliterated month names.&nbsp; Defaults to ["Nissan", "Iyar", "Sivan", "Tammuz", "Av", "Elul", "Tishrei", "Cheshvan",
         * "Kislev", "Teves", "Shevat", "Adar", "Adar II", "Adar I" ].
         * @see #getTransliteratedMonthList()
         * @see #setTransliteratedMonthList(String[])
         */
        private var transliteratedMonths = [ "Tishrei", "Cheshvan", "Kislev", "Teves", "Shevat", "Adar", "Adar II", "Nissan", "Iyar", "Sivan", "Tammuz", "Av", "Elul" , "Adar I"];
        
        /**
         * The Hebrew omer prefix charachter. It defaults to &#x05D1; producing &#x05D1;&#x05E2;&#x05D5;&#x05DE;&#x05E8;,
         * but can be set to &#x05DC; to produce &#x05DC;&#x05E2;&#x05D5;&#x05DE;&#x05E8; (or any other prefix).
         * @see #getHebrewOmerPrefix()
         * @see #setHebrewOmerPrefix(String)
         */
        private var hebrewOmerPrefix = "\u{05D1}";

        /**
         * The default value for formatting Shabbos (Saturday).&nbsp; Defaults to Shabbos.
         * @see #getTransliteratedShabbosDayOfWeek()
         * @see #setTransliteratedShabbosDayOfWeek(String)
         */
        private var transliteratedShabbosDayOfweek = "Shabbos";

        /**
         * Returns the day of Shabbos transliterated into Latin chars. The default uses Ashkenazi pronunciation "Shabbos".
         * self can be overwritten using the {@link #setTransliteratedShabbosDayOfWeek(String)}
         *
         * @return the transliteratedShabbos. The default list of months uses Ashkenazi pronunciation "Shabbos".
         * @see #setTransliteratedShabbosDayOfWeek(String)
         * @see #formatDayOfWeek(JewishCalendar)
         */
        public func getTransliteratedShabbosDayOfWeek() -> String {
            return transliteratedShabbosDayOfweek;
        }

        /**
         * Setter to override the default transliterated name of "Shabbos" to alternate spelling such as "Shabbat" used by
         * the {@link #formatDayOfWeek(JewishCalendar)}
         *
         * @param transliteratedShabbos
         *            the transliteratedShabbos to set
         *
         * @see #getTransliteratedShabbosDayOfWeek()
         * @see #formatDayOfWeek(JewishCalendar)
         */
    public func setTransliteratedShabbosDayOfWeek(transliteratedShabbos:String) {
            self.transliteratedShabbosDayOfweek = transliteratedShabbos;
        }

        /**
         * See {@link #getTransliteratedHolidayList()} and {@link #setTransliteratedHolidayList(String[])}.
         */
    private var transliteratedHolidays = ["Erev Pesach", "Pesach", "Chol Hamoed Pesach", "Pesach Sheni",
                "Erev Shavuos", "Shavuos", "Seventeenth of Tammuz", "Tishah B'Av", "Tu B'Av", "Erev Rosh Hashana",
                "Rosh Hashana", "Fast of Gedalyah", "Erev Yom Kippur", "Yom Kippur", "Erev Succos", "Succos",
                "Chol Hamoed Succos", "Hoshana Rabbah", "Shemini Atzeres", "Simchas Torah", "Erev Chanukah", "Chanukah",
                "Tenth of Teves", "Tu B'Shvat", "Fast of Esther", "Purim", "Shushan Purim", "Purim Katan", "Rosh Chodesh",
                "Yom HaShoah", "Yom Hazikaron", "Yom Ha'atzmaut", "Yom Yerushalayim", "Lag B'Omer","Shushan Purim Katan",
                "Isru Chag"];

        /**
         * Returns the list of holidays transliterated into Latin chars. self is used by the
         * {@link #formatYomTov(JewishCalendar)} when formatting the Yom Tov String. The default list of months uses
         * Ashkenazi pronunciation in typical American English spelling.
         *
         * @return the list of transliterated holidays. The default list is currently ["Erev Pesach", "Pesach",
         *         "Chol Hamoed Pesach", "Pesach Sheni", "Erev Shavuos", "Shavuos", "Seventeenth of Tammuz", "Tishah B'Av",
         *         "Tu B'Av", "Erev Rosh Hashana", "Rosh Hashana", "Fast of Gedalyah", "Erev Yom Kippur", "Yom Kippur",
         *         "Erev Succos", "Succos", "Chol Hamoed Succos", "Hoshana Rabbah", "Shemini Atzeres", "Simchas Torah",
         *         "Erev Chanukah", "Chanukah", "Tenth of Teves", "Tu B'Shvat", "Fast of Esther", "Purim", "Shushan Purim",
         *         "Purim Katan", "Rosh Chodesh", "Yom HaShoah", "Yom Hazikaron", "Yom Ha'atzmaut", "Yom Yerushalayim",
         *         "Lag B'Omer","Shushan Purim Katan","Isru Chag"].
         *
         * @see #setTransliteratedMonthList(String[])
         * @see #formatYomTov(JewishCalendar)
         * @see #isHebrewFormat()
         */
        public func getTransliteratedHolidayList() -> Array<String> {
            return transliteratedHolidays;
        }

        /**
         * Sets the list of holidays transliterated into Latin chars. self is used by the
         * {@link #formatYomTov(JewishCalendar)} when formatting the Yom Tov String.
         *
         * @param transliteratedHolidays
         *            the transliteratedHolidays to set. Ensure that the sequence exactly matches the list returned by the
         *            default
         */
    public func setTransliteratedHolidayList(transliteratedHolidays:Array<String>) {
            self.transliteratedHolidays = transliteratedHolidays;
        }

        private final let hebrewHolidays = [
            "ערב פסח", "פסח", "חול המועד פסח", "פסח שני", "ערב שבועות", "שבועות",
            "שבעה עשר בתמוז", "תשעה באב", "ט\"ו באב", "ערב ראש השנה", "ראש השנה",
            "צום גדליה", "ערב יום כיפור", "יום כיפור", "ערב סוכות", "סוכות",
            "חול המועד סוכות", "הושענא רבה", "שמיני עצרת", "שמחת תורה", "ערב חנוכה",
            "חנוכה", "עשרה בטבת", "ט\"ו בשבט", "תענית אסתר", "פורים",
            "פורים שושן", "פורים קטן", "ראש חודש", "יום השואה", "יום הזיכרון",
            "יום העצמאות", "יום ירושלים", "ל\"ג בעומר", "פורים שושן קטן", "אסרו חג"
          ];


        /**
         * Formats the Yom Tov (holiday) in Hebrew or transliterated Latin characters.
         *
         * @param jewishCalendar the JewishCalendar
         * @return the formatted holiday or an empty String if the day is not a holiday.
         * @see #isHebrewFormat()
         */
    public func formatYomTov(jewishCalendar:JewishCalendar) -> String {
            let index = jewishCalendar.getYomTovIndex();
            if (index == JewishCalendar.CHANUKAH) {
                let dayOfChanukah = jewishCalendar.getDayOfChanukah();
                return hebrewFormat ? (formatHebrewNumber(number: dayOfChanukah).appending(" ").appending(hebrewHolidays[index]))
                : (transliteratedHolidays[index].appending(" ").appending(String(dayOfChanukah)));
            }
            return index == -1 ? "" : hebrewFormat ? hebrewHolidays[index] : transliteratedHolidays[index];
        }

        /**
         * Formats a day as Rosh Chodesh in the format of in the format of &#x05E8;&#x05D0;&#x05E9;
         * &#x05D7;&#x05D5;&#x05D3;&#x05E9; &#x05E9;&#x05D1;&#x05D8; or Rosh Chodesh Shevat. If it
         * is not Rosh Chodesh, an empty <code>String</code> will be returned.
         * @param jewishCalendar the JewishCalendar
         * @return The formatted <code>String</code> in the format of &#x05E8;&#x05D0;&#x05E9;
         * &#x05D7;&#x05D5;&#x05D3;&#x05E9; &#x05E9;&#x05D1;&#x05D8; or Rosh Chodesh Shevat. If it
         * is not Rosh Chodesh, an empty <code>String</code> will be returned.
         */
    public func formatRoshChodesh(jewishCalendar:JewishCalendar) -> String {
            if (!jewishCalendar.isRoshChodesh()) {
                return "";
            }
            var formattedRoshChodesh = "";
            var month = jewishCalendar.getJewishMonth();
            if (jewishCalendar.getJewishDayOfMonth() == 30) {
                if (month < JewishCalendar.ADAR || (month == JewishCalendar.ADAR && jewishCalendar.isJewishLeapYear())) {
                    month+=1;
                } else { // roll to Nissan
                    month = JewishCalendar.NISSAN;
                }
            }
        let tempJewishCalendar = JewishCalendar(date: jewishCalendar.workingDate, isInIsrael: jewishCalendar.getInIsrael(), shouldUseModernHolidays: jewishCalendar.isUseModernHolidays())

        tempJewishCalendar.setJewishMonth(month: month);
            formattedRoshChodesh = hebrewFormat ? hebrewHolidays[JewishCalendar.ROSH_CHODESH]
                    : transliteratedHolidays[JewishCalendar.ROSH_CHODESH];
        return formattedRoshChodesh.appending(" ").appending(formatMonth(jewishCalendar: tempJewishCalendar));
        }

        /**
         * Returns if the formatter is set to use Hebrew formatting in the various formatting methods.
         *
         * @return the hebrewFormat
         * @see #setHebrewFormat(boolean)
         * @see #format(JewishCalendar)
         * @see #formatDayOfWeek(JewishCalendar)
         * @see #formatMonth(JewishCalendar)
         * @see #formatOmer(JewishCalendar)
         * @see #formatYomTov(JewishCalendar)
         */
        public func isHebrewFormat() -> Bool {
            return hebrewFormat;
        }

        /**
         * Sets the formatter to format in Hebrew in the various formatting methods.
         *
         * @param hebrewFormat
         *            the hebrewFormat to set
         * @see #isHebrewFormat()
         * @see #format(JewishCalendar)
         * @see #formatDayOfWeek(JewishCalendar)
         * @see #formatMonth(JewishCalendar)
         * @see #formatOmer(JewishCalendar)
         * @see #formatYomTov(JewishCalendar)
         */
    public func setHebrewFormat(hebrewFormat:Bool) {
            self.hebrewFormat = hebrewFormat;
        }

        /**
         * Returns the Hebrew Omer prefix.&nbsp; By default it is the letter &#x05D1; producing
         * &#x05D1;&#x05E2;&#x05D5;&#x05DE;&#x05E8;, but it can be set to &#x05DC; to produce
         * &#x05DC;&#x05E2;&#x05D5;&#x05DE;&#x05E8; (or any other prefix) using the {@link #setHebrewOmerPrefix(String)}.
         *
         * @return the hebrewOmerPrefix
         *
         * @see #hebrewOmerPrefix
         * @see #setHebrewOmerPrefix(String)
         * @see #formatOmer(JewishCalendar)
         */
        public func getHebrewOmerPrefix() -> String {
            return hebrewOmerPrefix;
        }

        /**
         * Method to set the Hebrew Omer prefix.&nbsp; By default it is the letter &#x05D1; producing
         * &#x05D1;&#x05E2;&#x05D5;&#x05DE;&#x05E8;, but it can be set to &#x05DC; to produce
         * &#x05DC;&#x05E2;&#x05D5;&#x05DE;&#x05E8; (or any other prefix)
         * @param hebrewOmerPrefix
         *            the hebrewOmerPrefix to set. You can use the Unicode &#92;u05DC to set it to &#x5DC;.
         * @see #hebrewOmerPrefix
         * @see #getHebrewOmerPrefix()
         * @see #formatOmer(JewishCalendar)
         */
    public func setHebrewOmerPrefix(hebrewOmerPrefix:String) {
            self.hebrewOmerPrefix = hebrewOmerPrefix;
        }

        /**
         * Returns the list of months transliterated into Latin chars. The default list of months uses Ashkenazi
         * pronunciation in typical American English spelling. self list has a length of 14 with 3 variations for Adar -
         * "Adar", "Adar II", "Adar I"
         *
         * @return the list of months beginning in Nissan and ending in in "Adar", "Adar II", "Adar I". The default list is
         *         currently ["Nissan", "Iyar", "Sivan", "Tammuz", "Av", "Elul", "Tishrei", "Cheshvan", "Kislev", "Teves",
         *         "Shevat", "Adar", "Adar II", "Adar I"].
         * @see #setTransliteratedMonthList(String[])
         */
        public func getTransliteratedMonthList() -> Array<String>{
            return transliteratedMonths;
        }

        /**
         * Setter method to allow overriding of the default list of months transliterated into into Latin chars. The default
         * uses Ashkenazi American English transliteration.
         *
         * @param transliteratedMonths
         *            an array of 14 month names that defaults to ["Nissan", "Iyar", "Sivan", "Tamuz", "Av", "Elul", "Tishrei",
         *            "Heshvan", "Kislev", "Tevet", "Shevat", "Adar", "Adar II", "Adar I"].
         * @see #getTransliteratedMonthList()
         */
    public func setTransliteratedMonthList(transliteratedMonths:Array<String>) {
            self.transliteratedMonths = transliteratedMonths;
        }

        /**
         * Unicode list of Hebrew months in the following format <code>["\u05E0\u05D9\u05E1\u05DF","\u05D0\u05D9\u05D9\u05E8",
         * "\u05E1\u05D9\u05D5\u05DF","\u05EA\u05DE\u05D5\u05D6","\u05D0\u05D1","\u05D0\u05DC\u05D5\u05DC",
         * "\u05EA\u05E9\u05E8\u05D9","\u05D7\u05E9\u05D5\u05DF","\u05DB\u05E1\u05DC\u05D5","\u05D8\u05D1\u05EA",
         * "\u05E9\u05D1\u05D8","\u05D0\u05D3\u05E8","\u05D0\u05D3\u05E8 \u05D1","\u05D0\u05D3\u05E8 \u05D0"]</code>
         *
         * @see #formatMonth(JewishCalendar)
         */
        private static let hebrewMonths = [
            "תשרי",
            "חשון",
            "כסלו",
            "טבת",
            "שבט",
            "אדר",
            "אדר ב",
            "ניסן",
            "אייר",
            "סיוון",
            "תמוז",
            "אב",
            "אלול",
            "אדר א"
          ];
    

        /**
         * Unicode list of Hebrew days of week in the format of <code>["&#x05E8;&#x05D0;&#x05E9;&#x05D5;&#x05DF;",
         * "&#x05E9;&#x05E0;&#x05D9;","&#x05E9;&#x05DC;&#x05D9;&#x05E9;&#x05D9;","&#x05E8;&#x05D1;&#x05D9;&#x05E2;&#x05D9;",
         * "&#x05D7;&#x05DE;&#x05D9;&#x05E9;&#x05D9;","&#x05E9;&#x05E9;&#x05D9;","&#x05E9;&#x05D1;&#x05EA;"]</code>
         */
        private static let hebrewDaysOfWeek = [
            "ראשון", "שני", "שלישי", "רביעי", "חמישי", "שישי", "שבת"
          ];

        /**
         * Formats the day of week. If {@link #isHebrewFormat() Hebrew formatting} is set, it will display in the format
         * &#x05E8;&#x05D0;&#x05E9;&#x05D5;&#x05DF; etc. If Hebrew formatting is not in use it will return it in the format
         * of Sunday etc. There are various formatting options that will affect the output.
         *
         * @param JewishCalendar the JewishCalendar Object
         * @return the formatted day of week
         * @see #isHebrewFormat()
         * @see #isLongWeekFormat()
         */
    public func formatDayOfWeek(jewishCalendar:JewishCalendar) -> String{
            if (hebrewFormat) {
                if (isLongWeekFormat()) {
                    return HebrewDateFormatter.hebrewDaysOfWeek[jewishCalendar.getDayOfWeek() - 1];
                } else {
                    if(jewishCalendar.getDayOfWeek() == 7) {
                        return formatHebrewNumber(number: 300);
                    } else {
                        return formatHebrewNumber(number: jewishCalendar.getDayOfWeek());
                    }
                }
            } else {
                if (jewishCalendar.getDayOfWeek() == 7) {
                    if (isLongWeekFormat()) {
                        return getTransliteratedShabbosDayOfWeek();
                    } else {
                        return String(getTransliteratedShabbosDayOfWeek().prefix(upTo: .init(utf16Offset: 3, in: getTransliteratedShabbosDayOfWeek())));
                    }
                } else {
                    return weekFormat.string(from: jewishCalendar.workingDate);
                }
            }
        }

        /**
         * Returns whether the class is set to use the Geresh &#x5F3; and Gershayim &#x5F4; in formatting Hebrew dates and
         * numbers. When true and output would look like &#x5DB;&#x5F4;&#x5D0; &#x5E9;&#x5D1;&#x5D8; &#x5EA;&#x5E9;&#x5F4;&#x5DB;
         * (or &#x5DB;&#x5F4;&#x5D0; &#x5E9;&#x5D1;&#x5D8; &#x5EA;&#x5E9;&#x5F4;&#x5DA;). When set to false, self output
         * would display as &#x5DB;&#x5D0; &#x5E9;&#x5D1;&#x5D8; &#x5EA;&#x5E9;&#x5DB;.
         *
         * @return true if set to use the Geresh &#x5F3; and Gershayim &#x5F4; in formatting Hebrew dates and numbers.
         */
        public func isUseGershGershayim() -> Bool {
            return useGershGershayim;
        }

        /**
         * Sets whether to use the Geresh &#x5F3; and Gershayim &#x5F4; in formatting Hebrew dates and numbers. The default
         * value is true and output would look like &#x5DB;&#x5F4;&#x5D0; &#x5E9;&#x5D1;&#x5D8; &#x5EA;&#x5E9;&#x5F4;&#x5DB;
         * (or &#x5DB;&#x5F4;&#x5D0; &#x5E9;&#x5D1;&#x5D8; &#x5EA;&#x5E9;&#x5F4;&#x5DA;). When set to false, self output would
         * display as &#x5DB;&#x5D0; &#x5E9;&#x5D1;&#x5D8; &#x5EA;&#x5E9;&#x5DB; (or
         * &#x5DB;&#x5D0; &#x5E9;&#x5D1;&#x5D8; &#x5EA;&#x5E9;&#x5DA;). Single digit days or month or years such as &#x05DB;&#x05F3;
         * &#x05E9;&#x05D1;&#x05D8; &#x05D5;&#x05F3; &#x05D0;&#x05DC;&#x05E4;&#x05D9;&#x05DD; show the use of the Geresh.
         *
         * @param useGershGershayim
         *            set to false to omit the Geresh &#x5F3; and Gershayim &#x5F4; in formatting
         */
    public func setUseGershGershayim(useGershGershayim:Bool) {
            self.useGershGershayim = useGershGershayim;
        }

        /**
         * Returns whether the class is set to use the &#x05DE;&#x05E0;&#x05E6;&#x05E4;&#x05F4;&#x05DA; letters when
         * formatting years ending in 20, 40, 50, 80 and 90 to produce &#x05EA;&#x05E9;&#x05F4;&#x05E4; if false or
         * or &#x05EA;&#x05E9;&#x05F4;&#x05E3; if true. Traditionally non-final form letters are used, so the year
         * 5780 would be formatted as &#x05EA;&#x05E9;&#x05F4;&#x05E4; if the default false is used here. If self returns
         * true, the format &#x05EA;&#x05E9;&#x05F4;&#x05E3; would be used.
         *
         * @return true if set to use final form letters when formatting Hebrew years. The default value is false.
         */
        public func isUseFinalFormLetters() -> Bool {
            return useFinalFormLetters;
        }

        /**
         * When formatting a Hebrew Year, traditionally years ending in 20, 40, 50, 80 and 90 are formatted using non-final
         * form letters for example &#x05EA;&#x05E9;&#x05F4;&#x05E4; for the year 5780. Setting self to true (the default
         * is false) will use the final form letters for &#x05DE;&#x05E0;&#x05E6;&#x05E4;&#x05F4;&#x05DA; and will format
         * the year 5780 as &#x05EA;&#x05E9;&#x05F4;&#x05E3;.
         *
         * @param useFinalFormLetters
         *            Set self to true to use final form letters when formatting Hebrew years.
         */
    public func setUseFinalFormLetters(useFinalFormLetters:Bool) {
            self.useFinalFormLetters = useFinalFormLetters;
        }

        /**
         * Returns whether the class is set to use the thousands digit when formatting. When formatting a Hebrew Year,
         * traditionally the thousands digit is omitted and output for a year such as 5729 (1969 Gregorian) would be
         * calculated for 729 and format as &#x5EA;&#x5E9;&#x5DB;&#x5F4;&#x5D8;. When set to true the long format year such
         * as &#x5D4;&#x5F3; &#x5EA;&#x5E9;&#x5DB;&#x5F4;&#x5D8; for 5729/1969 is returned.
         *
         * @return true if set to use the thousands digit when formatting Hebrew dates and numbers.
         */
        public func isUseLongHebrewYears() -> Bool {
            return useLonghebrewYears;
        }

        /**
         * When formatting a Hebrew Year, traditionally the thousands digit is omitted and output for a year such as 5729
         * (1969 Gregorian) would be calculated for 729 and format as &#x5EA;&#x5E9;&#x5DB;&#x5F4;&#x5D8;. self method
         * allows setting self to true to return the long format year such as &#x5D4;&#x5F3;
         * &#x5EA;&#x5E9;&#x5DB;&#x5F4;&#x5D8; for 5729/1969.
         *
         * @param useLongHebrewYears
         *            Set self to true to use the long formatting
         */
    public func setUseLongHebrewYears(useLongHebrewYears:Bool) {
            self.useLonghebrewYears = useLongHebrewYears;
        }
        /**
         * Formats the Jewish date. If the formatter is set to Hebrew, it will format in the form, "day Month year" for
         * example &#x5DB;&#x5F4;&#x5D0; &#x5E9;&#x5D1;&#x5D8; &#x5EA;&#x5E9;&#x5DB;&#x5F4;&#x5D8;, and the format
         * "21 Shevat, 5729" if not.
         *
         * @param JewishCalendar
         *            the JewishCalendar to be formatted
         * @return the formatted date. If the formatter is set to Hebrew, it will format in the form, "day Month year" for
         *         example &#x5DB;&#x5F4;&#x5D0; &#x5E9;&#x5D1;&#x5D8; &#x5EA;&#x5E9;&#x5DB;&#x5F4;&#x5D8;, and the format
         *         "21 Shevat, 5729" if not.
         */
    public func format(jewishCalendar:JewishCalendar) -> String {
            if (isHebrewFormat()) {
                return formatHebrewNumber(number: jewishCalendar.getJewishDayOfMonth()).appending(" ").appending(formatMonth(jewishCalendar: jewishCalendar)).appending(" ").appending(formatHebrewNumber(number: jewishCalendar.getJewishYear()));
            } else {
                return String(jewishCalendar.getJewishDayOfMonth()).appending(" ").appending(formatMonth(jewishCalendar: jewishCalendar)).appending(", ").appending(String(jewishCalendar.getJewishYear()));
            }
        }

        /**
         * Returns a string of the current Hebrew month such as "Tishrei". Returns a string of the current Hebrew month such
         * as "&#x5D0;&#x5D3;&#x5E8; &#x5D1;&#x5F3;".
         *
         * @param JewishCalendar
         *            the JewishCalendar to format
         * @return the formatted month name
         * @see #isHebrewFormat()
         * @see #setHebrewFormat(boolean)
         * @see #getTransliteratedMonthList()
         * @see #setTransliteratedMonthList(String[])
         */
    public func formatMonth(jewishCalendar:JewishCalendar) -> String {
            let month = jewishCalendar.getJewishMonth();
        if (isHebrewFormat()) {
            if (jewishCalendar.isJewishLeapYear() && month == JewishCalendar.ADAR) {
                return HebrewDateFormatter.hebrewMonths[13] + (useGershGershayim ? HebrewDateFormatter.GERESH : ""); // return Adar I, not Adar in a leap year
            } else if (jewishCalendar.isJewishLeapYear() && month == JewishCalendar.ADAR_II) {
                return HebrewDateFormatter.hebrewMonths[6] + (useGershGershayim ? HebrewDateFormatter.GERESH : "");
            } else {
                if month == JewishCalendar.ADAR_II {
                    return HebrewDateFormatter.hebrewMonths[month - 2];
                }
                return HebrewDateFormatter.hebrewMonths[month - 1];
            }
        } else {
                if (jewishCalendar.isJewishLeapYear() && month == JewishCalendar.ADAR) {
                    return transliteratedMonths[13]; // return Adar I, not Adar in a leap year
                } else {
                    if !jewishCalendar.isJewishLeapYear() && month == JewishCalendar.ADAR_II {
                        return transliteratedMonths[month - 2];
                    }
                    return transliteratedMonths[month - 1];
                }
            }
        }

        /**
         * Returns a String of the Omer day in the form &#x5DC;&#x5F4;&#x5D2; &#x5D1;&#x05E2;&#x05D5;&#x05DE;&#x5E8; if
         * Hebrew Format is set, or "Omer X" or "Lag B'Omer" if not. An empty string if there is no Omer self day.
         *
         * @param jewishCalendar
         *            the JewishCalendar to be formatted
         *
         * @return a String of the Omer day in the form or an empty string if there is no Omer self day. The default
         *         formatting has a &#x5D1;&#x5F3; prefix that would output &#x5D1;&#x05E2;&#x05D5;&#x05DE;&#x5E8;, but self
         *         can be set via the {@link #setHebrewOmerPrefix(String)} method to use a &#x5DC; and output
         *         &#x5DC;&#x5F4;&#x5D2; &#x5DC;&#x05E2;&#x05D5;&#x05DE;&#x5E8;.
         * @see #isHebrewFormat()
         * @see #getHebrewOmerPrefix()
         * @see #setHebrewOmerPrefix(String)
         */
    public func formatOmer(jewishCalendar:JewishCalendar) -> String {
            let omer = jewishCalendar.getDayOfOmer();
            if (omer == -1) {
                return "";
            }
            if (hebrewFormat) {
                return formatHebrewNumber(number: omer) + " " + hebrewOmerPrefix + "עומר";
            } else {
                if (omer == 33) { // if Lag B'Omer
                    return transliteratedHolidays[33];
                } else {
                    return "Omer ".appending(String(omer));
                }
            }
        }

        /**
         * Formats a molad.
         * @todo Experimental and incomplete.
         *
         * @param moladChalakim the chalakim of the molad
         * @return the formatted molad. FIXME: define proper format in English and Hebrew.
         */
    private static func formatMolad(moladChalakim:Int64) -> String{
        var adjustedChalakim:Int64 = moladChalakim;
        let MINUTE_CHALAKIM = 18;
        let HOUR_CHALAKIM = 1080;
        let DAY_CHALAKIM = 24 * HOUR_CHALAKIM;
        
        var days:Int64 = adjustedChalakim / Int64(DAY_CHALAKIM);
        adjustedChalakim = adjustedChalakim - (days * Int64(DAY_CHALAKIM));
        let hours = ((adjustedChalakim / Int64(HOUR_CHALAKIM)));
        if (hours >= 6) {
            days += 1;
        }
        adjustedChalakim = adjustedChalakim - (hours * Int64(HOUR_CHALAKIM));
        let minutes = (adjustedChalakim / Int64(MINUTE_CHALAKIM));
        adjustedChalakim = adjustedChalakim - minutes * Int64(MINUTE_CHALAKIM);
        return "Day: ".appending(String(days % 7)).appending(" hours: ").appending(String(hours)).appending(", minutes ").appending(String(minutes)).appending(", chalakim: ").appending(String(adjustedChalakim));
    }

        /**
         * Returns the kviah in the traditional 3 letter Hebrew format where the first letter represents the day of week of
         * Rosh Hashana, the second letter represents the lengths of Cheshvan and Kislev ({@link JewishCalendar#SHELAIMIM
         * Shelaimim} , {@link JewishCalendar#KESIDRAN Kesidran} or {@link JewishCalendar#CHASERIM Chaserim}) and the 3rd letter
         * represents the day of week of Pesach. For example 5729 (1969) would return &#x5D1;&#x5E9;&#x5D4; (Rosh Hashana on
         * Monday, Shelaimim, and Pesach on Thursday), while 5771 (2011) would return &#x5D4;&#x5E9;&#x5D2; (Rosh Hashana on
         * Thursday, Shelaimim, and Pesach on Tuesday).
         *
         * @param jewishYear
         *            the Jewish year
         * @return the Hebrew String such as &#x5D1;&#x5E9;&#x5D4; for 5729 (1969) and &#x5D4;&#x5E9;&#x5D2; for 5771
         *         (2011).
         */
    public func getFormattedKviah(jewishYear:Int) -> String{
        let jewishCalendar = JewishCalendar(jewishYear: jewishYear, jewishMonth: JewishCalendar.TISHREI, jewishDayOfMonth: 1); // set date to Rosh Hashana
            let kviah = jewishCalendar.getCheshvanKislevKviah();
            let roshHashanaDayOfweek = jewishCalendar.getDayOfWeek();
        var returnValue = formatHebrewNumber(number: roshHashanaDayOfweek);
            returnValue += (kviah == JewishCalendar.CHASERIM ? "\u{05D7}" : kviah == JewishCalendar.SHELAIMIM ? "\u{05E9}" : "\u{05DB}");
        jewishCalendar.setJewishDate(year: jewishYear, month: JewishCalendar.NISSAN, dayOfMonth: 15); // set to Pesach of the given year
            let pesachDayOfweek = jewishCalendar.getDayOfWeek();
        returnValue += formatHebrewNumber(number: pesachDayOfweek);
        returnValue = returnValue.replacingOccurrences(of: HebrewDateFormatter.GERESH, with: "");// geresh is never used in the kviah format
            // boolean isLeapYear = JewishCalendar.isJewishLeapYear(jewishYear);
            // for efficiency we can avoid the expensive recalculation of the pesach day of week by adding 1 day to Rosh
            // Hashana for a 353 day year, 2 for a 354 day year, 3 for a 355 or 383 day year, 4 for a 384 day year and 5 for
            // a 385 day year
            return returnValue;
        }

        /**
         * Formats the <a href="https://en.wikipedia.org/wiki/Daf_Yomi">Daf Yomi</a> Bavli in the format of
         * "&#x05E2;&#x05D9;&#x05E8;&#x05D5;&#x05D1;&#x05D9;&#x05DF; &#x05E0;&#x05F4;&#x05D1;" in {@link #isHebrewFormat() Hebrew},
         * or the transliterated format of "Eruvin 52".
         * @param daf the Daf to be formatted.
         * @return the formatted daf.
         */
    public func formatDafYomiBavli(daf:Daf) -> String {
            if (hebrewFormat) {
                return daf.getMasechta().appending(" ").appending(formatHebrewNumber(number: daf.getDaf()));
            } else {
                return daf.getMasechtaTransliterated().appending(" ").appending(String(daf.getDaf()));
            }
        }
        
        /**
         * Formats the <a href="https://en.wikipedia.org/wiki/Jerusalem_Talmud#Daf_Yomi_Yerushalmi">Daf Yomi Yerushalmi</a> in the format
         * of "&#x05E2;&#x05D9;&#x05E8;&#x05D5;&#x05D1;&#x05D9;&#x05DF; &#x05E0;&#x05F4;&#x05D1;" in {@link #isHebrewFormat() Hebrew}, or
         * the transliterated format of "Eruvin 52".
         *
         * @param daf the Daf to be formatted.
         * @return the formatted daf.
         */
    public func formatDafYomiYerushalmi(daf:Daf?) -> String {
            if (daf == nil) {
                if (hebrewFormat) {
                    return Daf.getYerushalmiMasechtos()[39];
                } else {
                    return Daf.getYerushalmiMasechtosTransliterated()[39];
                }
            }
            if (hebrewFormat) {
                return (daf?.getYerushalmiMasechta().appending(" ").appending(formatHebrewNumber(number: (daf?.getDaf())!)))!;
            } else {
                return (daf?.getYerushalmiMasechtaTransliterated().appending(" ").appending(String((daf?.getDaf())!)))!;
            }
        }

        /**
         * Returns a Hebrew formatted string of a number. The method can calculate from 0 - 9999.
         * <ul>
         * <li>Single digit numbers such as 3, 30 and 100 will be returned with a &#x5F3; (<a
         * href="http://en.wikipedia.org/wiki/Geresh">Geresh</a>) appended as at the end. For example &#x5D2;&#x5F3;,
         * &#x5DC;&#x5F3; and &#x5E7;&#x5F3;</li>
         * <li>multi digit numbers such as 21 and 769 will be returned with a &#x5F4; (<a
         * href="http://en.wikipedia.org/wiki/Gershayim">Gershayim</a>) between the second to last and last letters. For
         * example &#x5DB;&#x5F4;&#x5D0;, &#x5EA;&#x5E9;&#x5DB;&#x5F4;&#x5D8;</li>
         * <li>15 and 16 will be returned as &#x5D8;&#x5F4;&#x5D5; and &#x5D8;&#x5F4;&#x5D6;</li>
         * <li>Single digit numbers (years assumed) such as 6000 (%1000=0) will be returned as &#x5D5;&#x5F3;
         * &#x5D0;&#x5DC;&#x5E4;&#x5D9;&#x5DD;</li>
         * <li>0 will return &#x5D0;&#x5E4;&#x05E1;</li>
         * </ul>
         *
         * @param number
         *            the number to be formatted. It will trow an IllegalArgumentException if the number is &lt; 0 or &gt; 9999.
         * @return the Hebrew formatted number such as &#x5EA;&#x5E9;&#x5DB;&#x5F4;&#x5D8;
         * @see #isUseFinalFormLetters()
         * @see #isUseGershGershayim()
         * @see #isHebrewFormat()
         *
         */
    public func formatHebrewNumber(number:Int) -> String {
//            if (number < 0) {
//                throw Error("negative numbers can't be formatted");
//            } else if (number > 9999) {
//                throw Error("numbers > 9999 can't be formatted");
//            }

            let ALAFIM = "אלפים";
            let EFES = "אפס";

            let jHundreds =  ["", "ק", "ר", "ש", "ת", "תק", "תר", "תש", "תת", "תתק"];
            let jTens = ["", "י", "כ", "ל", "מ", "נ", "ס", "ע", "פ", "צ"];
            let jTenEnds = ["", "י", "ך", "ל", "ם", "ן", "ס", "ע", "ף", "ץ"];
            let tavTaz =  ["טו", "טז"] ;
            let jOnes =  ["", "א", "ב", "ג", "ד", "ה", "ו", "ז", "ח", "ט"];

        var number = number
            if (number == 0) { // do we really need self? Should it be applicable to a date?
                return EFES;
            }
            let shortNumber = number % 1000; // discard thousands
            // next check for all possible single Hebrew digit years
            let singleDigitNumber = (shortNumber < 11 || (shortNumber < 100 && shortNumber % 10 == 0) || (shortNumber <= 400 && shortNumber % 100 == 0));
            let thousands = number / 1000; // get # thousands
            var sb = "";
            // append thousands to String
            if (number % 1000 == 0) { // in year is 5000, 4000 etc
                sb.append(jOnes[thousands]);
                if (isUseGershGershayim()) {
                    sb.append(HebrewDateFormatter.GERESH);
                }
                sb.append(" ");
                sb.append(ALAFIM); // add # of thousands plus word thousand (overide alafim boolean)
                return sb;
            } else if (useLonghebrewYears && number >= 1000) { // if alafim boolean display thousands
                sb.append(jOnes[thousands]);
                if (isUseGershGershayim()) {
                    sb.append(HebrewDateFormatter.GERESH); // append thousands quote
                }
                sb.append(" ");
            }
            number = number % 1000; // remove 1000s
        let hundreds = number / 100; // # of hundreds
            sb.append(jHundreds[hundreds]); // add hundreds to String
            number = number % 100; // remove 100s
            if (number == 15) { // special case 15
                sb.append(tavTaz[0]);
            } else if (number == 16) { // special case 16
                sb.append(tavTaz[1]);
            } else {
                let tens = number / 10;
                if (number % 10 == 0) { // if evenly divisable by 10
                    if (!singleDigitNumber) {
                        if(isUseFinalFormLetters()) {
                            sb.append(jTenEnds[tens]); // years like 5780 will end with a final form &#x05E3;
                        } else {
                            sb.append(jTens[tens]); // years like 5780 will end with a regular &#x05E4;
                        }
                    } else {
                        sb.append(jTens[tens]); // standard letters so years like 5050 will end with a regular nun
                    }
                } else {
                    sb.append(jTens[tens]);
                    number = number % 10;
                    sb.append(jOnes[number]);
                }
            }
            if (isUseGershGershayim()) {
                if (singleDigitNumber) {
                    sb.append(HebrewDateFormatter.GERESH); // append single quote
                } else { // append double quote before last digit
                    let indexToInsert = sb.index(sb.endIndex, offsetBy: -1)
                    sb.insert(contentsOf: HebrewDateFormatter.GERSHAYIM, at: indexToInsert)
                }
            }
            return sb;
        }

        /**
         * Retruns the list of transliterated parshiyos used by self formatter.
         *
         * @return the list of transliterated Parshios
         */
    public func getTransliteratedParshiosList() -> [JewishCalendar.Parsha: String] {
            return transliteratedParshaMap;
        }

        /**
         * Setter method to allow overriding of the default list of parshiyos transliterated into into Latin chars. The
         * default uses Ashkenazi American English transliteration.
         *
         * @param transliteratedParshaMap
         *            the transliterated Parshios as an EnumMap to set
         * @see #getTransliteratedParshiosList()
         */
    public func setTransliteratedParshiosList(transliteratedParshaMap:[JewishCalendar.Parsha: String]) {
            self.transliteratedParshaMap = transliteratedParshaMap;
        }
        
        /**
         * Returns a String with the name of the current parsha(ios). self method gets the current <em>parsha</em> by
         * calling {@link JewishCalendar#getParshah()} that does not return a <em>parsha</em> for any non-<em>Shabbos</em>
         * or a <em>Shabbos</em> that occurs on a <em>Yom Tov</em>, and will return an empty <code>String</code> in those
         * cases. If the class {@link #isHebrewFormat() is set to format in Hebrew} it will return a <code>String</code>
         * of the current parsha(ios) in Hebrew for example &#x05D1;&#x05E8;&#x05D0;&#x05E9;&#x05D9;&#x05EA; or
         * &#x05E0;&#x05E6;&#x05D1;&#x05D9;&#x05DD; &#x05D5;&#x05D9;&#x05DC;&#x05DA; or an empty string if there
         * are none. If not set to Hebrew, it returns a string of the parsha(ios) transliterated into Latin chars. The
         * default uses Ashkenazi pronunciation in typical American English spelling, for example Bereshis or
         * Nitzavim Vayeilech or an empty string if there are none.
         *
         * @param jewishCalendar the JewishCalendar Object
         * @return today's parsha(ios) in Hebrew for example, if the formatter is set to format in Hebrew, returns a string
         *         of the current parsha(ios) in Hebrew for example &#x05D1;&#x05E8;&#x05D0;&#x05E9;&#x05D9;&#x05EA; or
         *         &#x05E0;&#x05E6;&#x05D1;&#x05D9;&#x05DD; &#x05D5;&#x05D9;&#x05DC;&#x05DA; or an empty string if
         *         there are none. If not set to Hebrew, it returns a string of the parsha(ios) transliterated into Latin
         *         chars. The default uses Ashkenazi pronunciation in typical American English spelling, for example
         *         Bereshis or Nitzavim Vayeilech or an empty string if there are none.
         * @see #formatParsha(JewishCalendar)
         * @see #isHebrewFormat()
         * @see JewishCalendar#getParshah()
         */
    public func formatParsha(jewishCalendar:JewishCalendar) -> String {
            let parsha =  jewishCalendar.getParshah();
        return formatParsha(parsha: parsha);
        }

        /**
         * Returns a String with the name of the current parsha(ios). self method overloads {@link
         * HebrewDateFormatter#formatParsha(JewishCalendar)} and unlike that method, it will format the <em>parsha</em> passed
         * to self method regardless of the day of week. self is the way to format a <em>parsha</em> retrieved from calling
         * {@link JewishCalendar#getUpcomingParshah()}.
         *
         * @param parsha a JewishCalendar.Parsha object
         * @return today's parsha(ios) in Hebrew for example, if the formatter is set to format in Hebrew, returns a string
         *         of the current parsha(ios) in Hebrew for example &#x05D1;&#x05E8;&#x05D0;&#x05E9;&#x05D9;&#x05EA; or
         *         &#x05E0;&#x05E6;&#x05D1;&#x05D9;&#x05DD; &#x05D5;&#x05D9;&#x05DC;&#x05DA; or an empty string if
         *         there are none. If not set to Hebrew, it returns a string of the parsha(ios) transliterated into Latin
         *         chars. The default uses Ashkenazi pronunciation in typical American English spelling, for example
         *         Bereshis or Nitzavim Vayeilech or an empty string if there are none.
         * @see #formatParsha(JewishCalendar)
         *
         */
    public func formatParsha(parsha:JewishCalendar.Parsha) -> String {
        return hebrewFormat ? hebrewParshaMap[parsha]! : transliteratedParshaMap[parsha]!;
        }
        
        /**
         * Returns a String with the name of the current special parsha of Shekalim, Zachor, Parah or Hachodesh or an
         * empty String for a non-special parsha. If the formatter is set to format in Hebrew, it returns a string of
         * the current special parsha in Hebrew, for example &#x05E9;&#x05E7;&#x05DC;&#x05D9;&#x05DD;,
         * &#x05D6;&#x05DB;&#x05D5;&#x05E8;, &#x05E4;&#x05E8;&#x05D4; or &#x05D4;&#x05D7;&#x05D3;&#x05E9;. An empty
         * string if the date is not a special parsha. If not set to Hebrew, it returns a string of the special parsha
         * transliterated into Latin chars. The default uses Ashkenazi pronunciation in typical American English spelling
         * Shekalim, Zachor, Parah or Hachodesh.
         *
         * @param jewishCalendar the JewishCalendar Object
         * @return today's special parsha. If the formatter is set to format in Hebrew, returns a string
         *         of the current special parsha  in Hebrew for in the format of &#x05E9;&#x05E7;&#x05DC;&#x05D9;&#x05DD;,
         *         &#x05D6;&#x05DB;&#x05D5;&#x05E8;, &#x05E4;&#x05E8;&#x05D4; or &#x05D4;&#x05D7;&#x05D3;&#x05E9; or an empty
         *         string if there are none. If not set to Hebrew, it returns a string of the special parsha transliterated
         *         into Latin chars. The default uses Ashkenazi pronunciation in typical American English spelling of Shekalim,
         *         Zachor, Parah or Hachodesh. An empty string if there are none.
         */
    public func formatSpecialParsha(jewishCalendar:JewishCalendar) -> String {
            let specialParsha =  jewishCalendar.getSpecialShabbos();
            return hebrewFormat ? hebrewParshaMap[specialParsha]! : transliteratedParshaMap[specialParsha]!;
        }
}
