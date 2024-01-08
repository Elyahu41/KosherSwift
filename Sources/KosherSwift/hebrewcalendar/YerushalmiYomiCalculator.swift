//
//  YerushalmiYomiCalculator.swift
//  KosherSwift
//
//  Created by User on 12/20/23.
//

import Foundation

/**
 * This class calculates the <a href="https://en.wikipedia.org/wiki/Jerusalem_Talmud">Talmud Yerusalmi</a> <a href=
 * "https://en.wikipedia.org/wiki/Daf_Yomi">Daf Yomi</a> page (``Daf``) for the a given date.
 *
 * @author &copy; elihaidv
 * @author &copy; Eliyahu Hershfeld 2017 - 2023
 */
public class YerushalmiYomiCalculator {
    
    /**
     * The start date of the first Daf Yomi Yerushalmi cycle of February 2, 1980 / 15 Shevat, 5740.
     */
    private static let DAF_YOMI_START_DAY = gregorianDate(forYear: 1980, month: 2, andDay: 2)
    
    /** The number of milliseconds in a day. */
    private static let DAY_MILIS = 1000 * 60 * 60 * 24
    
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
        let dateCreator = Calendar(identifier: .gregorian)
        var nextCycle = DateComponents()
        var prevCycle = DateComponents()
        var masechta = 0
        var dafYomi: Daf?
        
        // There isn't Daf Yomi on Yom Kippur or Tisha B'Av.
        if jewishCalendar.getYomTovIndex() == JewishCalendar.YOM_KIPPUR || jewishCalendar.getYomTovIndex() == JewishCalendar.TISHA_BEAV {
            return nil
        }
        
        if jewishCalendar.workingDate.compare(DAF_YOMI_START_DAY!) == .orderedAscending {
            return nil
        }
        
        nextCycle.year = 1980
        nextCycle.month = 2
        nextCycle.day = 2
        
//        let n = dateCreator.date(from: nextCycle)
//        let p = dateCreator.date(from: prevCycle)

        // Go cycle by cycle, until we get the next cycle
        while jewishCalendar.workingDate.compare(dateCreator.date(from: nextCycle)!) == .orderedDescending {
            prevCycle = nextCycle
            
            nextCycle.day! += WHOLE_SHAS_DAFS
            nextCycle.day! += getNumOfSpecialDays(startDate: dateCreator.date(from: prevCycle)!, endDate: dateCreator.date(from: nextCycle)!)
        }
        
        // Get the number of days from cycle start until request.
        let dafNo = getDiffBetweenDays(start: dateCreator.date(from: prevCycle)!, end: jewishCalendar.workingDate.addingTimeInterval(-86400))// this should be a temporary solution. Not sure why the dates are one day off
        
        // Get the number of special day to subtract
        let specialDays = getNumOfSpecialDays(startDate: dateCreator.date(from: prevCycle)!, endDate: jewishCalendar.workingDate)
        var total = dafNo - specialDays
        
        // Finally find the daf.
        for j in 0..<BLATT_PER_MASECHTA.count {
            if total < BLATT_PER_MASECHTA[j] {
                dafYomi = Daf(masechtaNumber: masechta, daf: total + 1)
                break
            }
            total -= BLATT_PER_MASECHTA[j]
            masechta += 1
        }
        
        return dafYomi
    }
    
    /**
     * Return the number of special days (Yom Kippur and Tisha Beav) That there is no Daf in this days.
     * From the last given number of days until given date
     *
     * @param start start date to calculate
     * @param end end date to calculate
     * @return the number of special days
     */
    private static func getNumOfSpecialDays(startDate: Date, endDate: Date) -> Int {
        let startCalendar = JewishCalendar()
        startCalendar.workingDate = startDate
        let endCalendar = JewishCalendar()
        endCalendar.workingDate = endDate
        
        var startYear = startCalendar.getJewishYear()
        let endYear = endCalendar.getJewishYear()
        
        var specialDays = 0
        
        let dateCreator = Calendar(identifier: .hebrew)

        //create a hebrew calendar set to the date 7/10/5770
        var yomKippurComponents = DateComponents()
        yomKippurComponents.year = 5770
        yomKippurComponents.month = 1
        yomKippurComponents.day = 10
        
        var tishaBeavComponents = DateComponents()
        tishaBeavComponents.year = 5770
        tishaBeavComponents.month = 5
        tishaBeavComponents.day = 9
        
        while startYear <= endYear {
            yomKippurComponents.year = startYear
            tishaBeavComponents.year = startYear
            
            if isBetween(start: startDate, date: dateCreator.date(from: yomKippurComponents)!, end: endDate) {
                specialDays += 1
            }
            
            if isBetween(start: startDate, date: dateCreator.date(from: tishaBeavComponents)!, end: endDate) {
                specialDays += 1
            }
            
            startYear += 1
        }

        return specialDays
    }

    /**
     * Return if the date is between two dates
     *
     * @param start the start date
     * @param date the date being compared
     * @param end the end date
     * @return if the date is between the start and end dates
     */
    private static func isBetween(start: Date, date: Date, end: Date) -> Bool {
        return (start.compare(date) == .orderedAscending) && (end.compare(date) == .orderedDescending)
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
    
    private static func gregorianDate(forYear year: Int, month: Int, andDay day: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.calendar = Calendar(identifier: .gregorian)
        return components.date
    }
}
