//
//  YerushalmiYomiCalculator.swift
//  KosherSwift
//
//  Created by User on 12/20/23.
//

import Foundation

/**
 * This class calculates the <a href="https://en.wikipedia.org/wiki/Jerusalem_Talmud">Talmud Yerusalmi</a> <a href=
 * "https://en.wikipedia.org/wiki/Daf_Yomi">Daf Yomi</a> page (``Daf``) for the given date.
 *
 * @author &copy; elihaidv
 * @author &copy; Eliyahu Hershfeld 2017 - 2026
 */
public class YerushalmiYomiCalculator {
    
    /**
     * The start date of the first Daf Yomi Yerushalmi cycle of February 2, 1980 / 15 Shevat, 5740.
     */
    private static let DAF_YOMI_START_DAY = LocalDate(year: 1980, month: 2, day: 2)
    
    /** The number of pages in the Talmud Yerushalmi.*/
    private static let WHOLE_SHAS_DAFS = 1554
    
    /** The number of pages per <em>masechta</em> (tractate).*/
    private static let BLATT_PER_MASECHTA = [
            68, 37, 34, 44, 31, 59, 26, 33, 28, 20, 13, 92, 65, 71, 22, 22, 42, 26, 26, 33, 34, 22,
            19, 85, 72, 47, 40, 47, 54, 48, 44, 37, 34, 44, 9, 57, 37, 19, 13]

    /**
     * Returns the <a href="https://en.wikipedia.org/wiki/Daf_Yomi">Daf Yomi</a>
     * <a href="https://en.wikipedia.org/wiki/Jerusalem_Talmud">Yerusalmi</a> page (``Daf``) for a given date.
     * The first Daf Yomi cycle started on 15 Shevat (Tu Bishvat), 5740 (February, 2, 1980) and calculations
     * prior to this date will result in an nil. A nil will be returned on Tisha B'Av or
     * Yom Kippur.
     *
     * @param calendar
     *            the calendar date for calculation
     * @return the ``Daf`` or nil if the date is on Tisha B'Av or Yom Kippur, or if the date is prior to the February 2, 1980, the start of the first Daf Yomi Yerushalmi cycle
     *
     */
    public static func getDafYomiYerushalmi(jewishCalendar:JewishCalendar) -> Daf? {
        let requested = jewishCalendar.getLocalDate()
        var masechta = 0
        var dafYomi: Daf?

        // There isn't Daf Yomi on Yom Kippur or Tisha B'Av.
        if jewishCalendar.getYomTovIndex() == JewishCalendar.YOM_KIPPUR || jewishCalendar.getYomTovIndex() == JewishCalendar.TISHA_BEAV {
            return nil
        }

        if requested < DAF_YOMI_START_DAY {
            return nil // KosherJava throws an IllegalArgumentException
        }

        // Go cycle by cycle, until we get the cycle of the date
        var prevCycle = DAF_YOMI_START_DAY
        var nextCycle = getNextCycleStart(prevCycle)
        while !(requested < nextCycle) {
            prevCycle = nextCycle
            nextCycle = getNextCycleStart(prevCycle)
        }

        // Get the number of days from cycle start until request.
        let dafNo = requested.epochDay - prevCycle.epochDay

        // Get the number of special days to subtract
        let specialDays = getNumOfSpecialDays(start: prevCycle, end: requested)
        var total = dafNo - specialDays

        // Finally find the daf.
        for blatt in BLATT_PER_MASECHTA {
            if total < blatt {
                dafYomi = Daf(masechtaNumber: masechta, daf: total + 1)
                break
            }
            total -= blatt
            masechta += 1
        }

        return dafYomi
    }

    /**
     * The start of the cycle after the one starting on `cycleStart`: 1,554 days of learning, plus a day for each Yom Kippur
     * and Tisha B'Av in the cycle (including those in the added days).
     */
    private static func getNextCycleStart(_ cycleStart: LocalDate) -> LocalDate {
        var endDate = cycleStart.plusDays(WHOLE_SHAS_DAFS - 1)
        var specialDays = getNumOfSpecialDays(start: cycleStart, end: endDate)
        while specialDays > 0 {
            let newStart = endDate.plusDays(1)
            endDate = endDate.plusDays(specialDays)
            specialDays = getNumOfSpecialDays(start: newStart, end: endDate)
        }
        return endDate.plusDays(1)
    }

    /**
     * Return the number of special days (Yom Kippur and Tisha Beav, where there are no dafim on these days),
     * from the start date given until the given end date, both included.
     *
     * @param start date to start calculating from
     * @param end date to finish calculating at
     * @return the number of special days between the start time and end time
     */
    private static func getNumOfSpecialDays(start: LocalDate, end: LocalDate) -> Int {
        let startYear = JewishCalendar(localDate: start).getJewishYear()
        let endYear = JewishCalendar(localDate: end).getJewishYear()
        var specialDays = 0
        for year in startYear...max(startYear, endYear) where year <= endYear {
            let yomKippur = JewishCalendar(localDate: start)
            yomKippur.setJewishDate(year: year, month: JewishCalendar.TISHREI, dayOfMonth: 10)
            let tishaBeav = JewishCalendar(localDate: start)
            tishaBeav.setJewishDate(year: year, month: JewishCalendar.AV, dayOfMonth: 9)
            // a Tisha B'Av that falls on Shabbos is pushed off to Sunday
            if tishaBeav.getDayOfWeek() == 7 {
                tishaBeav.plusDays(days: 1)
            }
            if isBetween(start, yomKippur.getLocalDate(), end) {
                specialDays += 1
            }
            if isBetween(start, tishaBeav.getLocalDate(), end) {
                specialDays += 1
            }
        }
        return specialDays
    }

    /// True if the date is from the start date to the end date, both included.
    private static func isBetween(_ start: LocalDate, _ date: LocalDate, _ end: LocalDate) -> Bool {
        return !(date < start) && !(end < date)
    }
}
