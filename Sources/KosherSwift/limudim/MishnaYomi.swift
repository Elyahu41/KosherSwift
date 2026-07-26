//
//  MishnaYomi.swift
//  KosherSwift
//
//  Created by Elyahu Jacobi on 9/27/24.
//

import Foundation

/// A utility class for calculating the daily Mishna Yomi learning schedule.
///
/// The Mishna Yomi cycle consists of learning two Mishnayot each day. This class calculates
/// which specific Mishnayot are scheduled for a given date, tracking from the original cycle
/// start date of May 20, 1947.
public class MishnaYomi {
    
    /** The start date of the Mishna Yomi Cycle. */
    private static let CYCLE_START_DATE = gregorianDate(forYear: 1947, month: 5, andDay: 20)
    /// The number of mishnayot studied per day.
    private static let MISHNAS_PER_DAY = 2;
    /// The total number of mishnayot in the entire Talmud.
    private static let NUM_MISHNAS = 4192;
    /// The length of a single Mishna Yomi cycle in days.
    private static let CYCLE_LENGTH = NUM_MISHNAS / 2; // 2096 mishnas
    
    /// An ordered collection mapping each Masechta to an array representing the number of Mishnayot in each Perek.
    /// `KeyValuePairs` is intentionally used here instead of a `Dictionary` to preserve the chronological order of the Masechtot.
    static let UNITS: KeyValuePairs = [
        "Berachot": [5, 8, 6, 7, 5, 8, 5, 8, 5],
        "Peah": [6, 8, 8, 11, 8, 11, 8, 9],
        "Demai": [4, 5, 6, 7, 11, 12, 8],
        "Kilayim": [9, 11, 7, 9, 8, 9, 8, 6, 10],
        "Sheviit": [8, 10, 10, 10, 9, 6, 7, 11, 9, 9],
        "Terumot": [10, 6, 9, 13, 9, 6, 7, 12, 7, 12, 10],
        "Maasrot": [8, 8, 10, 6, 8],
        "Maaser Sheni": [7, 10, 13, 12, 15],
        "Challah": [9, 8, 10, 11],
        "Orlah": [9, 17, 9],
        "Bikurim": [11, 11, 12, 5],
        "Shabbat": [11, 7, 6, 2, 4, 10, 4, 7, 7, 6, 6, 6, 7, 4, 3, 8, 8, 3, 6, 5, 3, 6, 5, 5],
        "Eruvin": [10, 6, 9, 11, 9, 10, 11, 11, 4, 15],
        "Pesachim": [7, 8, 8, 9, 10, 6, 13, 8, 11, 9],
        "Shekalim": [7, 5, 4, 9, 6, 6, 7, 8],
        "Yoma": [8, 7, 11, 6, 7, 8, 5, 9],
        "Sukkah": [11, 9, 15, 10, 8],
        "Beitzah": [10, 10, 8, 7, 7],
        "Rosh Hashanah": [9, 8, 9, 9],
        "Taanit": [7, 10, 9, 8],
        "Megillah": [11, 6, 6, 10],
        "Moed Katan": [10, 5, 9],
        "Chagigah": [8, 7, 8],
        "Yevamot": [4, 10, 10, 13, 6, 6, 6, 6, 6, 9, 7, 6, 13, 9, 10, 7],
        "Ketubot": [10, 10, 9, 12, 9, 7, 10, 8, 9, 6, 6, 4, 11],
        "Nedarim": [4, 5, 11, 8, 6, 10, 9, 7, 10, 8, 12],
        "Nazir": [7, 10, 7, 7, 7, 11, 4, 2, 5],
        "Sotah": [9, 6, 8, 5, 5, 4, 8, 7, 15],
        "Gittin": [6, 7, 8, 9, 9, 7, 9, 10, 10],
        "Kiddushin": [10, 10, 13, 14],
        "Bava Kamma": [4, 6, 11, 9, 7, 6, 7, 7, 12, 10],
        "Bava Metzia": [8, 11, 12, 12, 11, 8, 11, 9, 13, 6],
        "Bava Batra": [6, 14, 8, 9, 11, 8, 4, 8, 10, 8],
        "Sanhedrin": [6, 5, 8, 5, 5, 6, 11, 7, 6, 6, 6],
        "Makkot": [10, 8, 16],
        "Shevuot": [7, 5, 11, 13, 5, 7, 8, 6],
        "Eduyot": [14, 10, 12, 12, 7, 3, 9, 7],
        "Avodah Zarah": [9, 7, 10, 12, 12],
        "Avot": [18, 16, 18, 22, 23, 11],
        "Horiyot": [5, 7, 8],
        "Zevachim": [4, 5, 6, 6, 8, 7, 6, 12, 7, 8, 8, 6, 8, 10],
        "Menachot": [4, 5, 7, 5, 9, 7, 6, 7, 9, 9, 9, 5, 11],
        "Chullin": [7, 10, 7, 7, 5, 7, 6, 6, 8, 4, 2, 5],
        "Bechorot": [7, 9, 4, 10, 6, 12, 7, 10, 8],
        "Arachin": [4, 6, 5, 4, 6, 5, 5, 7, 8],
        "Temurah": [6, 3, 5, 4, 6, 5, 6],
        "Keritot": [7, 6, 10, 3, 8, 9],
        "Meilah": [4, 9, 8, 6, 5, 6],
        "Tamid": [4, 5, 9, 3, 6, 4, 3],
        "Midot": [9, 6, 8, 7, 4],
        "Kinnim": [4, 5, 6],
        "Keilim": [9, 8, 8, 4, 11, 4, 6, 11, 8, 8, 9, 8, 8, 8, 6, 8, 17, 9, 10, 7, 3, 10, 5, 17, 9, 9, 12, 10, 8, 4],
        "Ohalot": [8, 7, 7, 3, 7, 7, 6, 6, 16, 7, 9, 8, 6, 7, 10, 5, 5, 10],
        "Negaim": [6, 5, 8, 11, 5, 8, 5, 10, 3, 10, 12, 7, 12, 13],
        "Parah": [4, 5, 11, 4, 9, 5, 12, 11, 9, 6, 9, 11],
        "Tahorot": [9, 8, 8, 13, 9, 10, 9, 9, 9, 8],
        "Mikvaot": [8, 10, 4, 5, 6, 11, 7, 5, 7, 8],
        "Niddah": [7, 7, 7, 7, 9, 14, 5, 4, 11, 8],
        "Machshirin": [6, 11, 8, 10, 11, 8],
        "Zavim": [6, 4, 3, 7, 12],
        "Tevul Yom": [5, 8, 6, 7],
        "Yadayim": [5, 4, 5, 8],
        "Uktzin": [6, 10, 12]
    ]
    
    /// The name of the Masechta for the first Mishna of the day.
    public var sFirstMasechta = ""
    /// The chapter (Perek) number for the first Mishna of the day.
    public var sFirstPerek = 0
    /// The Mishna number for the first Mishna of the day.
    public var sFirstMishna = 0
        
    /// The name of the Masechta for the second Mishna of the day.
    public var sSecondMasechta = ""
    /// The chapter (Perek) number for the second Mishna of the day.
    public var sSecondPerek = 0
    /// The Mishna number for the second Mishna of the day.
    public var sSecondMishna = 0
    
    /// Creates an empty, unconfigured `MishnaYomi` instance.
    init() {}
    
    /// Initializes a `MishnaYomi` instance and immediately calculates the schedule for a given date.
    ///
    /// - Parameters:
    ///   - jewishCalendar: The `JewishCalendar` instance containing the target working date.
    ///   - useHebrewText: A boolean indicating whether the calculated result should use Hebrew text formatting.
    init(jewishCalendar: JewishCalendar, useHebrewText:Bool) {
        let _ = getMishnaYomi(jewishCalendar: jewishCalendar, useHebrewText: useHebrewText) // init variables
    }
    
    /// Calculates and returns a formatted string representing the Mishna Yomi for the provided date.
    ///
    /// This method updates the public properties (`sFirstMasechta`, `sSecondMasechta`, etc.) as a side effect.
    ///
    /// - Parameters:
    ///   - jewishCalendar: The `JewishCalendar` instance representing the target date.
    ///   - useHebrewText: Set to `true` to return the Masechta and numbers formatted in Hebrew, or `false` for English/Numerals.
    /// - Returns: A formatted string containing the daily study assignment (e.g., "Berachot 1:1-2"), or `nil` if the date is prior to the start of the first cycle.
    public func getMishnaYomi(jewishCalendar: JewishCalendar, useHebrewText:Bool) -> String? {
        let dateCreator = Calendar(identifier: .gregorian)
        var nextCycle = DateComponents()
        var prevCycle = DateComponents()
        
        if jewishCalendar.workingDate.compare(MishnaYomi.CYCLE_START_DATE!) == .orderedAscending {
            return nil
        }
        
        nextCycle.year = 1947
        nextCycle.month = 5
        nextCycle.day = 20

        // Go cycle by cycle, until we get the next cycle
        while jewishCalendar.workingDate.compare(dateCreator.date(from: nextCycle)!) == .orderedDescending {
            prevCycle = nextCycle
            nextCycle.day! += MishnaYomi.CYCLE_LENGTH
        }
        
        // Get the number of days from cycle start until request.
        let numberOfMishnasRead = MishnaYomi.getDiffBetweenDays(start: dateCreator.date(from: prevCycle)!, end: jewishCalendar.workingDate) * MishnaYomi.MISHNAS_PER_DAY
        
        // Finally find the mishna.
        findFirstMishna(numberOfMishnasRead: numberOfMishnasRead);

        // Again for the second mishna which could be in the next masechta
        findSecondMishna(numberOfMishnasRead: numberOfMishnasRead + 1);
        
        if useHebrewText {
                let hebrewDateFormatter = HebrewDateFormatter()
                hebrewDateFormatter.useGershGershayim = false
                
                if sFirstMasechta == sSecondMasechta {
                    if sFirstPerek == sSecondPerek {
                        return "\(replaceEnglishWithHebrew(sFirstMasechta)) \(hebrewDateFormatter.formatHebrewNumber(number: sFirstPerek)):\(hebrewDateFormatter.formatHebrewNumber(number: sFirstMishna))-\(hebrewDateFormatter.formatHebrewNumber(number: sSecondMishna))"
                    } else { // Different Perakim
                        return "\(replaceEnglishWithHebrew(sFirstMasechta)) \(hebrewDateFormatter.formatHebrewNumber(number: sFirstPerek)):\(hebrewDateFormatter.formatHebrewNumber(number: sFirstMishna))-\(hebrewDateFormatter.formatHebrewNumber(number: sSecondPerek)):\(hebrewDateFormatter.formatHebrewNumber(number: sSecondMishna))"
                    }
                } else { // Different Masechtas
                    return "\(replaceEnglishWithHebrew(sFirstMasechta)) \(hebrewDateFormatter.formatHebrewNumber(number: sFirstPerek)):\(hebrewDateFormatter.formatHebrewNumber(number: sFirstMishna)) - \(replaceEnglishWithHebrew(sSecondMasechta)) \(hebrewDateFormatter.formatHebrewNumber(number: sSecondPerek)):\(hebrewDateFormatter.formatHebrewNumber(number: sSecondMishna))"
                }
            } else {
                if sFirstMasechta == sSecondMasechta {
                    if sFirstPerek == sSecondPerek {
                        return "\(sFirstMasechta) \(sFirstPerek):\(sFirstMishna)-\(sSecondMishna)"
                    } else { // Different Perakim
                        return "\(sFirstMasechta) \(sFirstPerek):\(sFirstMishna)-\(sSecondPerek):\(sSecondMishna)"
                    }
                } else { // Different Masechtas
                    return "\(sFirstMasechta) \(sFirstPerek):\(sFirstMishna) - \(sSecondMasechta) \(sSecondPerek):\(sSecondMishna)"
                }
            }
    }
    /// Iterates through the order of the Talmud to find and assign the location of the first Mishna.
    /// - Parameter numberOfMishnasRead: The cumulative count of Mishnayot studied up to the current day.
    func findFirstMishna(numberOfMishnasRead: Int) {
        var numberOfMishnasRead = numberOfMishnasRead // mutable copy for decrementing
        for (masechta, perakim) in MishnaYomi.UNITS {
            for (index, numberOfMishnayot) in perakim.enumerated() {
                let perek = index + 1
                var currentMishna = 1
                
                if numberOfMishnasRead >= 0 {
                    for _ in 0..<numberOfMishnayot {
                        if numberOfMishnasRead == 0 {
                            sFirstMasechta = masechta
                            sFirstPerek = perek
                            sFirstMishna = currentMishna
                            return
                        }
                        numberOfMishnasRead -= 1
                        currentMishna += 1
                    }
                }
            }
            
            if !sFirstMasechta.isEmpty {
                return
            }
        }
    }

    /// Iterates through the order of the Talmud to find and assign the location of the second Mishna.
    /// - Parameter numberOfMishnasRead: The cumulative count of Mishnayot studied up to the current day.
    func findSecondMishna(numberOfMishnasRead: Int) {
        var numberOfMishnasRead = numberOfMishnasRead // mutable copy for decrementing
        for (masechta, perakim) in MishnaYomi.UNITS {
            for (index, numberOfMishnayot) in perakim.enumerated() {
                let perek = index + 1
                var currentMishna = 1
                
                if numberOfMishnasRead >= 0 {
                    for _ in 0..<numberOfMishnayot {
                        if numberOfMishnasRead == 0 {
                            sSecondMasechta = masechta
                            sSecondPerek = perek
                            sSecondMishna = currentMishna
                            return
                        }
                        numberOfMishnasRead -= 1
                        currentMishna += 1
                    }
                }
            }
            
            if !sSecondMasechta.isEmpty {
                return
            }
        }
    }
    
    /**
     * Return the number of days between the dates passed in
     * @param start the start date
     * @param end the end date
     * @return the number of days between the start and end dates
     */
    private static func getDiffBetweenDays(start: Date, end: Date) -> Int {
        let DAY_MILIS: Double = 24 * 60 * 60
        let s = Int(end.timeIntervalSince1970 - start.timeIntervalSince1970)
        return s / Int(DAY_MILIS)
    }
    
    /// A helper method to construct a generic Gregorian date safely.
    private static func gregorianDate(forYear year: Int, month: Int, andDay day: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.calendar = Calendar(identifier: .gregorian)
        return components.date
    }
    
    /// Translates the English phonetic spelling of a Masechta into Hebrew characters.
    /// - Parameter input: The English name of the Masechta (e.g., "Berachot").
    /// - Returns: The Hebrew equivalent (e.g., "ברכות"). If no match is found, returns the original input.
    func replaceEnglishWithHebrew(_ input: String) -> String {
        switch input {
        case "Berachot": return "ברכות"
        case "Peah": return "פאה"
        case "Demai": return "דמאי"
        case "Kilayim": return "כלאים"
        case "Sheviit": return "שביעית"
        case "Terumot": return "תרומות"
        case "Maasrot": return "מעשרות"
        case "Maaser Sheni": return "מעשר שני"
        case "Challah": return "חלה"
        case "Orlah": return "ערלה"
        case "Bikurim": return "ביכורים"
        case "Shabbat": return "שבת"
        case "Eruvin": return "ערובין"
        case "Pesachim": return "פסחים"
        case "Shekalim": return "שקלים"
        case "Yoma": return "יומא"
        case "Sukkah": return "סוכה"
        case "Beitzah": return "ביצה"
        case "Rosh Hashanah": return "ראש השנה"
        case "Taanit": return "תענית"
        case "Megillah": return "מגילה"
        case "Moed Katan": return "מועד קטן"
        case "Chagigah": return "חגיגה"
        case "Yevamot": return "יבמות"
        case "Ketubot": return "כתובות"
        case "Nedarim": return "נדרים"
        case "Nazir": return "נזיר"
        case "Sotah": return "סוטה"
        case "Gittin": return "גיטין"
        case "Kiddushin": return "קידושין"
        case "Bava Kamma": return "בבא קמא"
        case "Bava Metzia": return "בבא מציעא"
        case "Bava Batra": return "בבא בתרא"
        case "Sanhedrin": return "סנהדרין"
        case "Makkot": return "מכות"
        case "Shevuot": return "שבועות"
        case "Eduyot": return "עדויות"
        case "Avodah Zarah": return "עבודה זרה"
        case "Avot": return "אבות"
        case "Horiyot": return "הוריות"
        case "Zevachim": return "זבחים"
        case "Menachot": return "מנחות"
        case "Chullin": return "חולין"
        case "Bechorot": return "בכורות"
        case "Arachin": return "ערכין"
        case "Temurah": return "תמורה"
        case "Keritot": return "כריתות"
        case "Meilah": return "מעילה"
        case "Tamid": return "תמיד"
        case "Midot": return "מדות"
        case "Kinnim": return "קינים"
        case "Keilim": return "כלים"
        case "Ohalot": return "אהלות"
        case "Negaim": return "נגעים"
        case "Parah": return "פרה"
        case "Tahorot": return "טהרות"
        case "Mikvaot": return "מקואות"
        case "Niddah": return "נדה"
        case "Machshirin": return "מכשירין"
        case "Zavim": return "זבים"
        case "Tevul Yom": return "טבול יום"
        case "Yadayim": return "ידים"
        case "Uktzin": return "עוקצין"
        default: return input // If no match is found, return the original string
        }
    }
}
