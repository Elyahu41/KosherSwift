//
//  Daf.swift
//  KosherSwift
//
//  Created by Elyahu Jacobi on 12/20/23.
//

import Foundation

/**
 * An Object representing a <em>daf</em> (page) in the <a href="https://en.wikipedia.org/wiki/Daf_Yomi">Daf Yomi</a> cycle.
 *
 * @author &copy; Eliyahu Hershfeld 2011 - 2023
 */
public class Daf {
    /**
     * ``getMasechtaNumber()`` and ``setMasechtaNumber(masechtaNumber:).
     */
    public var masechtaNumber:Int = 0
    
    /**
     * See ``getDaf()`` and ``setDaf(daf:)``.
     */
    public var daf:Int = 0

    /**
     * See ``getMasechtaTransliterated()`` and ``setMasechtaTransliterated(masechtosBavliTransliterated:)``.
     */
    public static var masechtosBavliTransliterated = [ "Berachos", "Shabbos", "Eruvin", "Pesachim", "Shekalim",
            "Yoma", "Sukkah", "Beitzah", "Rosh Hashana", "Taanis", "Megillah", "Moed Katan", "Chagigah", "Yevamos",
            "Kesubos", "Nedarim", "Nazir", "Sotah", "Gitin", "Kiddushin", "Bava Kamma", "Bava Metzia", "Bava Basra",
            "Sanhedrin", "Makkos", "Shevuos", "Avodah Zarah", "Horiyos", "Zevachim", "Menachos", "Chullin", "Bechoros",
            "Arachin", "Temurah", "Kerisos", "Meilah", "Kinnim", "Tamid", "Midos", "Niddah" ];

    /**
     * See ``getMasechta()``.
     */
    private static let masechtosBavli = [
        "ברקות", "שבת", "אירובים", "פסחים", "שקלים", "יומא", "סוכה", "ביצה",
        "ראש השנה", "תענית", "מגילה", "מועד קטן", "חגיגה", "יבמות", "כתובות",
        "נדרים", "נזיר", "סוטה", "גיטין", "קידושין", "בבא קמא", "בבא מציעא",
        "בבא בתרא", "סנהדרין", "מכות", "חולין", "בכורות", "ערכין", "תמורה",
        "כריתות", "מעילה", "קינים", "תמיד", "מדות", "נדה"
    ];
    
    /**
     * See ``getYerushalmiMasechtaTransliterated()``.
     */
    public static var masechtosYerushalmiTransliterated = [ "Berachos", "Pe'ah", "Demai", "Kilayim", "Shevi'is",
            "Terumos", "Ma'asros", "Ma'aser Sheni", "Chalah", "Orlah", "Bikurim", "Shabbos", "Eruvin", "Pesachim",
            "Beitzah", "Rosh Hashanah", "Yoma", "Sukah", "Ta'anis", "Shekalim", "Megilah", "Chagigah", "Moed Katan",
            "Yevamos", "Kesuvos", "Sotah", "Nedarim", "Nazir", "Gitin", "Kidushin", "Bava Kama", "Bava Metzia",
            "Bava Basra", "Shevuos", "Makos", "Sanhedrin", "Avodah Zarah", "Horayos", "Nidah", "No Daf Today" ];
    
    /**
     * See ``getYerushalmiMasechta()``.
     */
    public static let masechtosYerushalmi = [ "ברכות"
                                                     , "פיאה"
                                                     , "דמאי"
                                                     , "כלאים"
                                                     , "שביעית"
                                                     , "תרומות"
                                                     , "מעשרות"
                                                     , "מעשר שני"
                                                     , "חלה"
                                                     , "עורלה"
                                                     , "ביכורים"
                                                     , "שבת"
                                                     , "עירובין"
                                                     , "פסחים"
                                                     , "ביצה"
                                                     , "ראש השנה"
                                                     , "יומא"
                                                     , "סוכה"
                                                     , "תענית"
                                                     , "שקלים"
                                                     , "מגילה"
                                                     , "חגיגה"
                                                     , "מועד קטן"
                                                     , "יבמות"
                                                     , "כתובות"
                                                     , "סוטה"
                                                     , "נדרים"
                                                     , "נזיר"
                                                     , "גיטין"
                                                     , "קידושין"
                                                     , "בבא קמא"
                                                     , "בבא מציעא"
                                                     , "בבא בתרא"
                                                     , "שבועות"
                                                     , "מכות"
                                                     , "סנהדרין"
                                                     , "עבודה זרה"
                                                     , "הוריות"
                                                     , "נידה"
                                                     , "אין דף היום" ];

    /**
     * Gets the <em>masechta</em> number of the currently set <em>Daf</em>. The sequence is: Berachos, Shabbos, Eruvin,
     * Pesachim, Shekalim, Yoma, Sukkah, Beitzah, Rosh Hashana, Taanis, Megillah, Moed Katan, Chagigah, Yevamos, Kesubos,
     * Nedarim, Nazir, Sotah, Gitin, Kiddushin, Bava Kamma, Bava Metzia, Bava Basra, Sanhedrin, Makkos, Shevuos, Avodah
     * Zarah, Horiyos, Zevachim, Menachos, Chullin, Bechoros, Arachin, Temurah, Kerisos, Meilah, Kinnim, Tamid, Midos and
     * Niddah.
     * @return the masechtaNumber.
     * @see #setMasechtaNumber(int)
     */
    public func getMasechtaNumber() -> Int {
        return masechtaNumber;
    }

    /**
     * Set the <em>masechta</em> number in the order of the Daf Yomi. The sequence is: Berachos, Shabbos, Eruvin, Pesachim,
     * Shekalim, Yoma, Sukkah, Beitzah, Rosh Hashana, Taanis, Megillah, Moed Katan, Chagigah, Yevamos, Kesubos, Nedarim,
     * Nazir, Sotah, Gitin, Kiddushin, Bava Kamma, Bava Metzia, Bava Basra, Sanhedrin, Makkos, Shevuos, Avodah Zarah,
     * Horiyos, Zevachim, Menachos, Chullin, Bechoros, Arachin, Temurah, Kerisos, Meilah, Kinnim, Tamid, Midos and
     * Niddah.
     *
     * @param masechtaNumber
     *            the <em>masechta</em> number in the order of the Daf Yomi to set.
     */
    public func setMasechtaNumber(masechtaNumber:Int) {
        self.masechtaNumber = masechtaNumber;
    }

    /**
     * Constructor that creates a ``Daf`` setting the ``setMasechtaNumber(masechtaNumber:)`` <em>masechta</em> number} and
     * ``setDaf(daf:)`` <em>daf</em> number.
     *
     * @param masechtaNumber the <em>masechta</em> number in the order of the Daf Yomi to set as the current <em>masechta</em>.
     * @param daf the <em>daf</em> (page) number to set.
     */
    public init(masechtaNumber: Int, daf: Int) {
        self.masechtaNumber = masechtaNumber
        self.daf = daf
    }

    /**
     * Returns the <em>daf</em> (page) number of the Daf Yomi.
     * @return the <em>daf</em> (page) number of the Daf Yomi.
     */
    public func getDaf() -> Int{
        return daf;
    }

    /**
     * Sets the <em>daf</em> (page) number of the Daf Yomi.
     * @param daf the <em>daf</em> (page) number.
     */
    public func setDaf(daf:Int) {
        self.daf = daf;
    }

    /**
     * Returns the transliterated name of the <em>masechta</em> (tractate) of the Daf Yomi. The list of <em>mashechtos</em>
     * is: Berachos, Shabbos, Eruvin, Pesachim, Shekalim, Yoma, Sukkah, Beitzah, Rosh Hashana, Taanis, Megillah, Moed Katan,
     * Chagigah, Yevamos, Kesubos, Nedarim, Nazir, Sotah, Gitin, Kiddushin, Bava Kamma, Bava Metzia, Bava Basra, Sanhedrin,
     * Makkos, Shevuos, Avodah Zarah, Horiyos, Zevachim, Menachos, Chullin, Bechoros, Arachin, Temurah, Kerisos, Meilah,
     * Kinnim, Tamid, Midos and Niddah.
     *
     * @return the transliterated name of the <em>masechta</em> (tractate) of the Daf Yomi such as Berachos.
     * @see #setMasechtaTransliterated(String[])
     */
    public func getMasechtaTransliterated() -> String {
        return Daf.masechtosBavliTransliterated[masechtaNumber];
    }
    
    /**
     * Setter method to allow overriding of the default list of <em>masechtos</em> transliterated into into Latin chars.
     * The default values use Ashkenazi American English transliteration.
     *
     * @param masechtosBavliTransliterated the list of transliterated Bavli <em>masechtos</em> to set.
     * @see #getMasechtaTransliterated()
     */
    public func setMasechtaTransliterated(masechtosBavliTransliterated:Array<String>) {
        Daf.masechtosBavliTransliterated = masechtosBavliTransliterated;
    }

    /**
     * Returns the <em>masechta</em> (tractate) of the Daf Yomi in Hebrew. The list is in the following format<br>
     * <code>["&#x05D1;&#x05E8;&#x05DB;&#x05D5;&#x05EA;",
     * "&#x05E9;&#x05D1;&#x05EA;", "&#x05E2;&#x05D9;&#x05E8;&#x05D5;&#x05D1;&#x05D9;&#x05DF;",
     * "&#x05E4;&#x05E1;&#x05D7;&#x05D9;&#x05DD;", "&#x05E9;&#x05E7;&#x05DC;&#x05D9;&#x05DD;", "&#x05D9;&#x05D5;&#x05DE;&#x05D0;",
     * "&#x05E1;&#x05D5;&#x05DB;&#x05D4;", "&#x05D1;&#x05D9;&#x05E6;&#x05D4;", "&#x05E8;&#x05D0;&#x05E9; &#x05D4;&#x05E9;&#x05E0;&#x05D4;",
     * "&#x05EA;&#x05E2;&#x05E0;&#x05D9;&#x05EA;", "&#x05DE;&#x05D2;&#x05D9;&#x05DC;&#x05D4;", "&#x05DE;&#x05D5;&#x05E2;&#x05D3;
     * &#x05E7;&#x05D8;&#x05DF;", "&#x05D7;&#x05D2;&#x05D9;&#x05D2;&#x05D4;", "&#x05D9;&#x05D1;&#x05DE;&#x05D5;&#x05EA;",
     * "&#x05DB;&#x05EA;&#x05D5;&#x05D1;&#x05D5;&#x05EA;", "&#x05E0;&#x05D3;&#x05E8;&#x05D9;&#x05DD;","&#x05E0;&#x05D6;&#x05D9;&#x05E8;",
     * "&#x05E1;&#x05D5;&#x05D8;&#x05D4;", "&#x05D2;&#x05D9;&#x05D8;&#x05D9;&#x05DF;", "&#x05E7;&#x05D9;&#x05D3;&#x05D5;&#x05E9;&#x05D9;&#x05DF;",
     * "&#x05D1;&#x05D1;&#x05D0; &#x05E7;&#x05DE;&#x05D0;", "&#x05D1;&#x05D1;&#x05D0; &#x05DE;&#x05E6;&#x05D9;&#x05E2;&#x05D0;",
     * "&#x05D1;&#x05D1;&#x05D0; &#x05D1;&#x05EA;&#x05E8;&#x05D0;", "&#x05E1;&#x05E0;&#x05D4;&#x05D3;&#x05E8;&#x05D9;&#x05DF;",
     * "&#x05DE;&#x05DB;&#x05D5;&#x05EA;", "&#x05E9;&#x05D1;&#x05D5;&#x05E2;&#x05D5;&#x05EA;", "&#x05E2;&#x05D1;&#x05D5;&#x05D3;&#x05D4;
     * &#x05D6;&#x05E8;&#x05D4;", "&#x05D4;&#x05D5;&#x05E8;&#x05D9;&#x05D5;&#x05EA;", "&#x05D6;&#x05D1;&#x05D7;&#x05D9;&#x05DD;",
     * "&#x05DE;&#x05E0;&#x05D7;&#x05D5;&#x05EA;", "&#x05D7;&#x05D5;&#x05DC;&#x05D9;&#x05DF;", "&#x05D1;&#x05DB;&#x05D5;&#x05E8;&#x05D5;&#x05EA;",
     * "&#x05E2;&#x05E8;&#x05DB;&#x05D9;&#x05DF;", "&#x05EA;&#x05DE;&#x05D5;&#x05E8;&#x05D4;", "&#x05DB;&#x05E8;&#x05D9;&#x05EA;&#x05D5;&#x05EA;",
     * "&#x05DE;&#x05E2;&#x05D9;&#x05DC;&#x05D4;", "&#x05E7;&#x05D9;&#x05E0;&#x05D9;&#x05DD;", "&#x05EA;&#x05DE;&#x05D9;&#x05D3;",
     * "&#x05DE;&#x05D9;&#x05D3;&#x05D5;&#x05EA;", "&#x05E0;&#x05D3;&#x05D4;"]</code>.
     *
     * @return the <em>masechta</em> (tractate) of the Daf Yomi in Hebrew. As an example, it will return
     *         &#x05D1;&#x05E8;&#x05DB;&#x05D5;&#x05EA; for Berachos.
     */
    public func getMasechta() -> String {
        return Daf.masechtosBavli[masechtaNumber];
    }

    /**
     * Returns the transliterated name of the <em>masechta</em> (tractate) of the Daf Yomi in Yerushalmi. The list of
     * <em>mashechtos</em> is:
     * Berachos, Pe'ah, Demai, Kilayim, Shevi'is, Terumos, Ma'asros, Ma'aser Sheni, Chalah, Orlah, Bikurim,
     * Shabbos, Eruvin, Pesachim, Beitzah, Rosh Hashanah, Yoma, Sukah, Ta'anis, Shekalim, Megilah, Chagigah,
     * Moed Katan, Yevamos, Kesuvos, Sotah, Nedarim, Nazir, Gitin, Kidushin, Bava Kama, Bava Metzia,
     * Bava Basra, Shevuos, Makos, Sanhedrin, Avodah Zarah, Horayos, Nidah and No Daf Today.
     *
     * @return the transliterated name of the <em>masechta</em> (tractate) of the Daf Yomi such as Berachos.
     */
    public func getYerushalmiMasechtaTransliterated() -> String {
        return Daf.masechtosYerushalmiTransliterated[masechtaNumber];
    }
    
    /**
     * Setter method to allow overriding of the default list of Yerushalmi <em>masechtos</em> transliterated into into Latin chars.
     * The default uses Ashkenazi American English transliteration.
     *
     * @param masechtosYerushalmiTransliterated the list of transliterated Yerushalmi <em>masechtos</em> to set.
     */
    public func setYerushalmiMasechtaTransliterated(masechtosYerushalmiTransliterated:Array<String>) {
        Daf.masechtosYerushalmiTransliterated = masechtosYerushalmiTransliterated;
    }
    
    /**
     * Getter method to allow retrieving the list of Yerushalmi <em>masechtos</em> transliterated into into Latin chars.
     * The default uses Ashkenazi American English transliteration.
     *
     * @return the array of transliterated <em>masechta</em> (tractate) names of the Daf Yomi Yerushalmi.
     */
    public static func getYerushalmiMasechtosTransliterated() -> Array<String> {
        return masechtosYerushalmiTransliterated;
    }
    
    /**
     * Getter method to allow retrieving the list of Yerushalmi <em>masechtos</em>.
     *
     * @return the array of Hebrew <em>masechta</em> (tractate) names of the Daf Yomi Yerushalmi.
     */
    public static func getYerushalmiMasechtos() -> Array<String> {
        return masechtosYerushalmi;
    }

    /**
     * Returns the Yerushalmi <em>masechta</em> (tractate) of the Daf Yomi in Hebrew. As an example, it will return
     * &#x05D1;&#x05E8;&#x05DB;&#x05D5;&#x05EA; for Berachos.
     *
     * @return the Yerushalmi <em>masechta</em> (tractate) of the Daf Yomi in Hebrew. As an example, it will return
     *         &#x05D1;&#x05E8;&#x05DB;&#x05D5;&#x05EA; for Berachos.
     */
    public func getYerushalmiMasechta() -> String {
        return Daf.masechtosYerushalmi[masechtaNumber];
    }
}
