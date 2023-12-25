//
//  YomiCalculator.swift
//  KosherSwift
//
//  Created by Elyahu Jacobi on 12/20/23.
//

import Foundation

/**
 * This class calculates the Daf Yomi Bavli page (daf) for a given date. To calculate Daf Yomi Yerushalmi
 * use the {@link YerushalmiYomiCalculator}. The library may cover Mishna Yomi etc. at some point in the future.
 *
 * @author &copy; Bob Newell (original C code)
 * @author &copy; Eliyahu Hershfeld 2011 - 2020
 */
public class YomiCalculator {

    /**
     * The start date of the first Daf Yomi Bavli cycle of September 11, 1923 / Rosh Hashana 5684.
     */
    private static let dafYomiStartDay = gregorianDate(forYear: 1923, month: 9, andDay: 11)!;
    /** The start date of the first Daf Yomi Bavli cycle in the Julian calendar. Used internally for claculations.*/
    private static let dafYomiJulianStartDay = getJulianDay(date: dafYomiStartDay);
    /**
     * The date that the pagination for the Daf Yomi <em>Maseches Shekalim</em> changed to use the commonly used Vilna
     * Shas pagination from the no longer commonly available Zhitomir / Slavuta Shas used by Rabbi Meir Shapiro.
     */
    private static let shekalimChangeDay = gregorianDate(forYear: 1975, month: 6, andDay: 24)!;
    
    /** The Julian date that the cycle for Shekalim changed.
     * @see #getDafYomiBavli(JewishCalendar) for details.
     */
    private static let shekalimJulianChangeDay = getJulianDay(date: shekalimChangeDay);

    /**
     * Returns the <a href="http://en.wikipedia.org/wiki/Daf_yomi">Daf Yomi</a> <a
     * href="http://en.wikipedia.org/wiki/Talmud">Bavli</a> {@link Daf} for a given date. The first Daf Yomi cycle
     * started on Rosh Hashana 5684 (September 11, 1923) and calculations prior to this date will result in an
     * IllegalArgumentException thrown. For historical calculations (supported by this method), it is important to note
     * that a change in length of the cycle was instituted starting in the eighth Daf Yomi cycle beginning on June 24,
     * 1975. The Daf Yomi Bavli cycle has a single masechta of the Talmud Yerushalmi - Shekalim as part of the cycle.
     * Unlike the Bavli where the number of daf per masechta was standardized since the original <a
     * href="http://en.wikipedia.org/wiki/Daniel_Bomberg">Bomberg Edition</a> published from 1520 - 1523, there is no
     * uniform page length in the Yerushalmi. The early cycles had the Yerushalmi Shekalim length of 13 days following the
     * <a href=
     * "https://he.wikipedia.org/wiki/%D7%93%D7%A4%D7%95%D7%A1_%D7%A1%D7%9C%D7%90%D7%95%D7%95%D7%99%D7%98%D7%90">Slavuta/Zhytomyr</a>
     * Shas used by <a href="http://en.wikipedia.org/wiki/Meir_Shapiro">Rabbi Meir Shapiro</a>. With the start of the eighth Daf Yomi
     * cycle beginning on June 24, 1975 the length of the Yerushalmi Shekalim was changed from 13 to 22 daf to follow
     * the <a href="https://en.wikipedia.org/wiki/Vilna_Edition_Shas">Vilna Shas</a> that is in common use today.
     *
     * @param jewishCalendar
     *            The JewishCalendar date for calculation. TODO: this can be changed to use a regular GregorianCalendar since
     *            there is nothing specific to the JewishCalendar in this class.
     * @return the {@link Daf} or nil if before the bavli start date
     *
     */
    public static func getDafYomiBavli(jewishCalendar: JewishCalendar) -> Daf? {
        /*
         * The number of daf per masechta. Since the number of blatt in Shekalim changed on the 8th Daf Yomi cycle
         * beginning on June 24, 1975 from 13 to 22, the actual calculation for blattPerMasechta[4] will later be
         * adjusted based on the cycle.
         */
        var blattPerMasechta = [ 64, 157, 105, 121, 22, 88, 56, 40, 35, 31, 32, 29, 27, 122, 112, 91, 66, 49, 90, 82,
                119, 119, 176, 113, 24, 49, 76, 14, 120, 110, 142, 61, 34, 34, 28, 22, 4, 9, 5, 73 ];
        let calendar = jewishCalendar.workingDate.addingTimeInterval(-86400)//temp fix

        var dafYomi: Daf? = nil;
        let julianDay = getJulianDay(date: calendar);
        var cycleNo = 0;
        var dafNo = 0;
        if (calendar.compare(dafYomiStartDay) == .orderedAscending) {
            return nil
        }
        if (calendar.compare(shekalimChangeDay) == .orderedSame || calendar.compare(shekalimChangeDay) == .orderedDescending) {
            cycleNo = 8 + ((julianDay - shekalimJulianChangeDay) / 2711);
            dafNo = ((julianDay - shekalimJulianChangeDay) % 2711);
        } else {
            cycleNo = 1 + ((julianDay - dafYomiJulianStartDay) / 2702);
            dafNo = ((julianDay - dafYomiJulianStartDay) % 2702);
        }

        var total = 0;
        var masechta = -1;
        var blatt = 0;

        // Fix Shekalim for old cycles.
        if (cycleNo <= 7) {
            blattPerMasechta[4] = 13;
        } else {
            blattPerMasechta[4] = 22; // correct any change that may have been changed from a prior calculation
        }
        // Finally find the daf.
        for j in 0..<blattPerMasechta.count {
            masechta+=1;
            total = total + blattPerMasechta[j] - 1;
            if (dafNo < total) {
                blatt = 1 + blattPerMasechta[j] - (total - dafNo);
                // Fiddle with the weird ones near the end.
                if (masechta == 36) {
                    blatt += 21;
                } else if (masechta == 37) {
                    blatt += 24;
                } else if (masechta == 38) {
                    blatt += 32;
                }
                dafYomi = Daf(masechtaNumber: masechta, daf: blatt);
                break;
            }
        }

        return dafYomi;
    }

    /**
     * Return the <a href="http://en.wikipedia.org/wiki/Julian_day">Julian day</a> from a Swift Date.
     *
     * @param date
     * @return the Julian day number corresponding to the date
     */
    private static func getJulianDay(date: Date) -> Int {
        let calendar = Calendar(identifier: .gregorian)
        var year = calendar.component(.year, from: date)
        var month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        if (month <= 2) {
            year -= 1;
            month += 12;
        }
        let a = year / 100;
        let b = 2 - a + a / 4;
        let c = floor(365.25 * (Double(year) + 4716))
        let d = floor(30.6001 * Double(month))
        let e = Double(day) + Double(b) - 1524.5
        return Int(c + d + e);
    }
    
    private static func gregorianDate(forYear year: Int, month: Int, andDay day: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.calendar = Calendar(identifier: .gregorian)
        return components.date
    }
}
