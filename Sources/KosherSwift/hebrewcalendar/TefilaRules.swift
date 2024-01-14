//
//  TefilaRules.swift
//  KosherSwift
//
//  Created by Elyahu Jacobi on 12/20/23.
//

import Foundation

/**
 * Tefila Rules is a utility class that covers the various <em>halachos</em> and <em>minhagim</em> regarding
 * changes to daily <em>tefila</em> / prayers, based on the Jewish calendar. This is mostly useful for use in
 * developing <em>siddur</em> type applications, but it is also valuable for <em>shul</em> calendars that set
 * <em>tefila</em> times based on if <a href="https://en.wikipedia.org/wiki/Tachanun"><em>tachanun</em></a> is
 * recited that day. There are many settings in this class to cover the vast majority of <em>minhagim</em>, but
 * there are likely some not covered here. The source for many of the <em>chasidishe minhagim</em> can be found
 * in the <a href="https://www.nli.org.il/he/books/NNL_ALEPH001141272/NLI">Minhag Yisrael Torah</a> on Orach
 * Chaim 131.
 * Dates used in specific communities such as specific <em>yahrzeits</em> or a holidays like Purim Mezhbizh
 * (Medzhybizh) celebrated on 11 ``JewishCalendar.TEVES`` <em>Teves</em> or <a href=
 * "https://en.wikipedia.org/wiki/Second_Purim#Purim_Saragossa_(18_Shevat)">Purim Saragossa</a> celebrated on
 * the (17th or) 18th of ``JewishCalendar.SHEVAT`` <em>Shevat</em> are not (and likely will not be) supported by
 * this class.
 * @author &copy; Y. Paritcher 2019 - 2021
 * @author &copy; Eliyahu Hershfeld 2019 - 2023
 */
public class TefilaRules {
    /**
     * The default value is <code>true</code>.
     * @see #isTachanunRecitedEndOfTishrei()
     * @see #setTachanunRecitedEndOfTishrei(boolean)
     */
    public var tachanunRecitedEndOfTishrei = true;
    
    /**
     * The default value is <code>false</code>.
     * @see #isTachanunRecitedWeekAfterShavuos()
     * @see #setTachanunRecitedWeekAfterShavuos(boolean)
     */
    public var tachanunRecitedWeekAfterShavuos = false;
    
    /**
     * The default value is <code>true</code>.
     * @see #isTachanunRecited13SivanOutOfIsrael()
     * @see #setTachanunRecited13SivanOutOfIsrael(boolean)
     */
    public var tachanunRecited13SivanOutOfIsrael = true;
    
    /**
     * The default value is <code>false</code>.
     * @see #isTachanunRecitedPesachSheni()
     * @see #setTachanunRecitedPesachSheni(boolean)
     */
    public var tachanunRecitedPesachSheni = false;
    
    /**
     * The default value is <code>true</code>.
     * @see #isTachanunRecited15IyarOutOfIsrael()
     * @see #setTachanunRecited15IyarOutOfIsrael(boolean)
     */
    public var tachanunRecited15IyarOutOfIsrael = true;
    
    /**
     * The default value is <code>false</code>.
     * @see #isTachanunRecitedMinchaErevLagBaomer()
     * @see #setTachanunRecitedMinchaErevLagBaomer(boolean)
     */
    public var tachanunRecitedMinchaErevLagBaomer = false;
    
    /**
     * The default value is <code>true</code>.
     * @see #isTachanunRecitedShivasYemeiHamiluim()
     * @see #setTachanunRecitedShivasYemeiHamiluim(boolean)
     */
    public var tachanunRecitedShivasYemeiHamiluim = true;
    
    /**
     * The default value is <code>true</code>.
     * @see #isTachanunRecitedWeekOfHod()
     * @see #setTachanunRecitedWeekOfHod(boolean)
     */
    public var tachanunRecitedWeekOfHod = true;
    
    /**
     * The default value is <code>true</code>.
     * @see #isTachanunRecitedWeekOfPurim()
     * @see #setTachanunRecitedWeekOfPurim(boolean)
     */
    public var tachanunRecitedWeekOfPurim = true;
    
    /**
     * The default value is <code>true</code>.
     * @see #isTachanunRecitedFridays()
     * @see #setTachanunRecitedFridays(boolean)
     */
    public var tachanunRecitedFridays = true;
    
    /**
     * The default value is <code>true</code>.
     * @see #isTachanunRecitedSundays()
     * @see #setTachanunRecitedSundays(boolean)
     */
    public var tachanunRecitedSundays = true;
    
    /**
     * The default value is <code>true</code>.
     * @see #isTachanunRecitedMinchaAllYear()
     * @see #setTachanunRecitedMinchaAllYear(boolean)
     */
    public var tachanunRecitedMinchaAllYear = true;
    
    /**
     * The default value is <code>false</code>.
     * @see #isMizmorLesodaRecited(JewishCalendar)
     * @see #setMizmorLesodaRecitedErevYomKippurAndPesach(boolean)
     */
    public var mizmorLesodaRecitedErevYomKippurAndPesach = false;
    
    public init() {}
    
    /**
     * Returns if <em>tachanun</em> is recited during <em>shacharis</em> on the day in question. There are the many
     * <em>minhagim</em> based settings that are available in this class that control what days are set for
     * <em>tachanun</em> recital.
     *
     * @param jewishCalendar the Jewish calendar day.
     * @return if <em>tachanun</em> is recited during <em>shacharis</em>.
     * @see #isTachanunRecitedMincha(JewishCalendar)
     * @see #isTachanunRecitedSundays()
     * @see #isTachanunRecitedFridays()
     * @see #isTachanunRecitedEndOfTishrei()
     * @see #isTachanunRecitedWeekAfterShavuos()
     * @see #isTachanunRecited13SivanOutOfIsrael()
     * @see #isTachanunRecitedPesachSheni()
     * @see #isTachanunRecited15IyarOutOfIsrael()
     * @see #isTachanunRecitedShivasYemeiHamiluim()
     * @see #isTachanunRecitedWeekOfPurim()
     * @see #isTachanunRecitedWeekOfHod()
     */
    public func isTachanunRecitedShacharis(jewishCalendar:JewishCalendar) -> Bool {
        let holidayIndex = jewishCalendar.getYomTovIndex();
        let day = jewishCalendar.getJewishDayOfMonth();
        let month = jewishCalendar.getJewishMonth();
        
        if (jewishCalendar.getDayOfWeek() == 7
            || (!tachanunRecitedSundays && jewishCalendar.getDayOfWeek() == 1)
            || (!tachanunRecitedFridays && jewishCalendar.getDayOfWeek() == 6)
            || month == JewishCalendar.NISSAN
            || (month == JewishCalendar.TISHREI && ((!tachanunRecitedEndOfTishrei && day > 8)
                                                    || (tachanunRecitedEndOfTishrei && (day > 8 && day < 22))))
            || (month == JewishCalendar.SIVAN && (tachanunRecitedWeekAfterShavuos && day < 7
                                                  || !tachanunRecitedWeekAfterShavuos && day < (!jewishCalendar.getInIsrael()
                                                                                                && !tachanunRecited13SivanOutOfIsrael ? 14: 13)))
            || (jewishCalendar.isYomTov() && (!jewishCalendar.isTaanis()
                                              || (!tachanunRecitedPesachSheni && holidayIndex == JewishCalendar.PESACH_SHENI))) // Erev YT is included in isYomTov()
            || (!jewishCalendar.getInIsrael() && !tachanunRecitedPesachSheni && !tachanunRecited15IyarOutOfIsrael
                && jewishCalendar.getJewishMonth() == JewishCalendar.IYAR && day == 15)
            || holidayIndex == JewishCalendar.TISHA_BEAV || jewishCalendar.isIsruChag()
            || jewishCalendar.isRoshChodesh()
            || (!tachanunRecitedShivasYemeiHamiluim &&
                ((!jewishCalendar.isJewishLeapYear() && month == JewishCalendar.ADAR)
                 || (jewishCalendar.isJewishLeapYear() && month == JewishCalendar.ADAR_II)) && day > 22)
            || (!tachanunRecitedWeekOfPurim &&
                ((!jewishCalendar.isJewishLeapYear() && month == JewishCalendar.ADAR)
                 || (jewishCalendar.isJewishLeapYear() && month == JewishCalendar.ADAR_II)) && day > 10 && day < 18)
            || (jewishCalendar.isUseModernHolidays()
                && (holidayIndex == JewishCalendar.YOM_HAATZMAUT || holidayIndex == JewishCalendar.YOM_YERUSHALAYIM))
            || (!tachanunRecitedWeekOfHod && month == JewishCalendar.IYAR && day > 13 && day < 21)) {
            return false;
        }
        return true;
    }
    
    /**
     * Returns if <em>tachanun</em> is recited during <em>mincha</em> on the day in question.
     *
     * @param jewishCalendar the Jewish calendar day.
     * @return if <em>tachanun</em> is recited during <em>mincha</em>.
     * @see #isTachanunRecitedShacharis(JewishCalendar)
     */
    public func isTachanunRecitedMincha(jewishCalendar:JewishCalendar) -> Bool {
        let tomorrow = JewishCalendar();
        tomorrow.forward()
        
        if (!tachanunRecitedMinchaAllYear
            || jewishCalendar.getDayOfWeek() == 6
            || !isTachanunRecitedShacharis(jewishCalendar: jewishCalendar)
            || (!isTachanunRecitedShacharis(jewishCalendar: tomorrow) &&
                !(tomorrow.getYomTovIndex() == JewishCalendar.EREV_ROSH_HASHANA) &&
                !(tomorrow.getYomTovIndex() == JewishCalendar.EREV_YOM_KIPPUR) &&
                !(tomorrow.getYomTovIndex() == JewishCalendar.PESACH_SHENI))
            || !tachanunRecitedMinchaErevLagBaomer && tomorrow.getYomTovIndex() == JewishCalendar.LAG_BAOMER) {
            return false;
        }
        return true;
    }
    
    /**
     * Returns if it is the Jewish day (starting the evening before) to start reciting <em>Vesein Tal Umatar Livracha</em>
     * (<em>Sheailas Geshamim</em>). In Israel this is the 7th day of ``JewishCalendar.CHESHVAN`` <em>Marcheshvan</em>}.
     * Outside Israel recitation starts on the evening of December 4th (or 5th if it is the year before a civil leap year)
     * in the 21st century and shifts a day forward every century not evenly divisible by 400. This method will return true
     * if <em>vesein tal umatar</em> on the current Jewish date that starts on the previous night, so Dec 5/6 will be
     * returned by this method in the 21st century. <em>vesein tal umatar</em> is not recited on <em>Shabbos</em> and the
     * start date will be delayed a day when the start day is on a <em>Shabbos</em> (this can only occur out of Israel).
     *
     * @param jewishCalendar the Jewish calendar day.
     *
     * @return true if it is the first Jewish day (starting the prior evening of reciting <em>Vesein Tal Umatar Livracha</em>
     *         (<em>Sheailas Geshamim</em>).
     *
     * @see #isVeseinTalUmatarStartingTonight(JewishCalendar)
     * @see #isVeseinTalUmatarRecited(JewishCalendar)
     */
    public func isVeseinTalUmatarStartDate(jewishCalendar:JewishCalendar) -> Bool {
        if (jewishCalendar.getInIsrael()) {
            // The 7th Cheshvan can't occur on Shabbos, so always return true for 7 Cheshvan
            if (jewishCalendar.getJewishMonth() == JewishCalendar.CHESHVAN && jewishCalendar.getJewishDayOfMonth() == 7) {
                return true;
            }
        } else {
            if (jewishCalendar.getDayOfWeek() == 7) { //Not recited on Friday night
                return false;
            }
            if(jewishCalendar.getDayOfWeek() == 1) { // When starting on Sunday, it can be the start date or delayed from Shabbos
                return jewishCalendar.getTekufasTishreiElapsedDays() == 48 || jewishCalendar.getTekufasTishreiElapsedDays() == 47;
            } else {
                return jewishCalendar.getTekufasTishreiElapsedDays() == 47;
            }
        }
        return false; // keep the compiler happy
    }
    
    /**
     * Returns true if tonight is the first night to start reciting <em>Vesein Tal Umatar Livracha</em> (
     * <em>Sheailas Geshamim</em>). In Israel this is the 7th day of ``JewishCalendar.CHESHVAN``
     * <em>Marcheshvan</em> (so the 6th will return true). Outside Israel recitation starts on the evening
     * of December 4th (or 5th if it is the year before a civil leap year) in the 21st century and shifts a
     * day forward every century not evenly divisible by 400. <em>Vesein tal umatar</em> is not recited on
     * <em>Shabbos</em> and the start date will be delayed a day when the start day is on a <em>Shabbos</em>
     * (this can only occur out of Israel).
     *
     * @param jewishCalendar the Jewish calendar day.
     *
     * @return true if it is the first Jewish day (starting the prior evening of reciting <em>Vesein Tal Umatar
     *         Livracha</em> (<em>Sheailas Geshamim</em>).
     *
     * @see #isVeseinTalUmatarStartDate(JewishCalendar)
     * @see #isVeseinTalUmatarRecited(JewishCalendar)
     */
    public func isVeseinTalUmatarStartingTonight(jewishCalendar:JewishCalendar) -> Bool {
        if (jewishCalendar.getInIsrael()) {
            // The 7th Cheshvan can't occur on Shabbos, so always return true for 6 Cheshvan
            if (jewishCalendar.getJewishMonth() == JewishCalendar.CHESHVAN && jewishCalendar.getJewishDayOfMonth() == 6) {
                return true;
            }
        } else {
            if (jewishCalendar.getDayOfWeek() == 6) { //Not recited on Friday night
                return false;
            }
            if (jewishCalendar.getDayOfWeek() == 7) { // When starting on motzai Shabbos, it can be the start date or delayed from Friday night
                return jewishCalendar.getTekufasTishreiElapsedDays() == 47 || jewishCalendar.getTekufasTishreiElapsedDays() == 46;
            } else {
                return jewishCalendar.getTekufasTishreiElapsedDays() == 46;
            }
        }
        return false;
    }
    
    /**
     * Returns if <em>Vesein Tal Umatar Livracha</em> (<em>Sheailas Geshamim</em>) is recited. this will return
     * true for the entire season, even on <em>Shabbos</em> when it is not recited.
     *
     * @param jewishCalendar the Jewish calendar day.
     *
     * @return true if <em>Vesein Tal Umatar Livracha</em> (<em>Sheailas Geshamim</em>) is recited.
     *
     * @see #isVeseinTalUmatarStartDate(JewishCalendar)
     * @see #isVeseinTalUmatarStartingTonight(JewishCalendar)
     */
    public func isVeseinTalUmatarRecited(jewishCalendar:JewishCalendar) -> Bool {
        if (jewishCalendar.getJewishMonth() == JewishCalendar.NISSAN && jewishCalendar.getJewishDayOfMonth() < 15) {
            return true;
        }
        if (jewishCalendar.getJewishMonth() < JewishCalendar.CHESHVAN) {
            return false;
        }
        if (jewishCalendar.getInIsrael()) {
            return jewishCalendar.getJewishMonth() != JewishCalendar.CHESHVAN || jewishCalendar.getJewishDayOfMonth() >= 7;
        } else {
            return jewishCalendar.getTekufasTishreiElapsedDays() >= 47;
        }
    }
    
    /**
     * Returns if <em>Vesein Beracha</em> is recited. It is recited from 15 ``JewishCalendar.NISSAN`` <em>Nissan</em> to the
     * point that ``isVeseinTalUmatarRecited(jewishCalendar:)`` <em>vesein tal umatar</em> is recited.
     *
     * @param jewishCalendar the Jewish calendar day.
     * @return true if <em>Vesein Beracha</em> is recited.
     * @see #isVeseinTalUmatarRecited(JewishCalendar)
     */
    public func isVeseinBerachaRecited(jewishCalendar:JewishCalendar) -> Bool {
        return !isVeseinTalUmatarRecited(jewishCalendar: jewishCalendar);
    }
    
    /**
     * Returns if the date is the start date for reciting <em>Mashiv Haruach Umorid Hageshem</em>. The date is 22
     * ``JewishCalendar.TISHREI`` <em>Tishrei</em>.
     *
     * @param jewishCalendar the Jewish calendar day.
     * @return true if the date is the start date for reciting <em>Mashiv Haruach Umorid Hageshem</em>.
     * @see #isMashivHaruachEndDate(JewishCalendar)
     * @see #isMashivHaruachRecited(JewishCalendar)
     */
    public func isMashivHaruachStartDate(jewishCalendar:JewishCalendar) -> Bool {
        return jewishCalendar.getJewishMonth() == JewishCalendar.TISHREI && jewishCalendar.getJewishDayOfMonth() == 22;
    }
    
    /**
     * Returns if the date is the end date for reciting <em>Mashiv Haruach Umorid Hageshem</em>. The date is 15
     * ``JewishCalendar.NISSAN`` <em>Nissan</em>.
     *
     * @param jewishCalendar the Jewish calendar day.
     * @return true if the date is the end date for reciting <em>Mashiv Haruach Umorid Hageshem</em>.
     * @see #isMashivHaruachStartDate(JewishCalendar)
     * @see #isMashivHaruachRecited(JewishCalendar)
     */
    public func isMashivHaruachEndDate(jewishCalendar:JewishCalendar) -> Bool {
        return jewishCalendar.getJewishMonth() == JewishCalendar.NISSAN && jewishCalendar.getJewishDayOfMonth() == 15;
    }
    
    /**
     * Returns if <em>Mashiv Haruach Umorid Hageshem</em> is recited. this period starts on 22
     * ``JewishCalendar.TISHREI`` <em>Tishrei</em> and ends on the 15th day of ``JewishCalendar.NISSAN`` <em>Nissan</em>.
     *
     * @param jewishCalendar the Jewish calendar day.
     * @return true if <em>Mashiv Haruach Umorid Hageshem</em> is recited.
     * @see #isMashivHaruachStartDate(JewishCalendar)
     * @see #isMashivHaruachEndDate(JewishCalendar)
     */
    public func isMashivHaruachRecited(jewishCalendar:JewishCalendar) -> Bool {
        let startDate = JewishCalendar(jewishYear: jewishCalendar.getJewishYear(), jewishMonth: JewishCalendar.TISHREI, jewishDayOfMonth: 22);
        let endDate = JewishCalendar(jewishYear: jewishCalendar.getJewishYear(), jewishMonth: JewishCalendar.NISSAN, jewishDayOfMonth: 15);
        return jewishCalendar.workingDate.compare(startDate.workingDate) == .orderedDescending && jewishCalendar.workingDate.compare(endDate.workingDate) == .orderedAscending;
    }
    
    /**
     * Returns if <em>Morid Hatal</em> (or the lack of reciting <em>Mashiv Haruach</em> following <em>nussach Ashkenaz</em>) is
     * recited. this period starts on the 15th day of ``JewishCalendar.NISSAN`` <em>Nissan</em> and ends on 22
     * ``JewishCalendar.TISHREI`` <em>Tishrei</em>.
     *
     * @param jewishCalendar the Jewish calendar day.
     *
     * @return true if <em>Morid Hatal</em> (or the lack of reciting <em>Mashiv Haruach</em> following <em>nussach Ashkenaz</em>) is recited.
     */
    public func isMoridHatalRecited(jewishCalendar:JewishCalendar) -> Bool {
        return !isMashivHaruachRecited(jewishCalendar: jewishCalendar) || isMashivHaruachStartDate(jewishCalendar: jewishCalendar) || isMashivHaruachEndDate(jewishCalendar: jewishCalendar);
    }
    
    /**
     * Returns if <em>Hallel</em> is recited on the day in question. this will return true for both <em>Hallel shalem</em>
     * and <em>Chatzi Hallel</em>. See ``isHallelShalemRecited(jewishCalendar:)`` to know if the complete <em>Hallel</em>
     * is recited.
     *
     * @param jewishCalendar the Jewish calendar day.
     * @return if <em>Hallel</em> is recited.
     * @see #isHallelShalemRecited(JewishCalendar)
     */
    public func isHallelRecited(jewishCalendar:JewishCalendar) -> Bool {
        let day = jewishCalendar.getJewishDayOfMonth();
        let month = jewishCalendar.getJewishMonth();
        let holidayIndex = jewishCalendar.getYomTovIndex();
        let inIsrael = jewishCalendar.getInIsrael();
        
        if (jewishCalendar.isRoshChodesh()) { //RH returns false for RC
            return true;
        }
        if (jewishCalendar.isChanukah()) {
            return true;
        }
        switch (month) {
        case JewishCalendar.NISSAN:
            if (day >= 15 && ((inIsrael && day <= 21) || (!inIsrael && day <= 22))) {
                return true;
            }
            break;
        case JewishCalendar.IYAR: // modern holidays
            if (jewishCalendar.isUseModernHolidays() && (holidayIndex == JewishCalendar.YOM_HAATZMAUT || holidayIndex == JewishCalendar.YOM_YERUSHALAYIM)) {
                return true;
            }
            break;
        case JewishCalendar.SIVAN:
            if (day == 6 || (!inIsrael && (day == 7))) {
                return true;
            }
            break;
        case JewishCalendar.TISHREI:
            if (day >= 15 && (day <= 22 || (!inIsrael && (day <= 23)))) {
                return true;
            }
        default:
            return false
        }
        return false;
    }
    
    /**
     * Returns if <em>hallel shalem</em> is recited on the day in question. This will always return false if
     * ``isHallelRecited(jewishCalendar:)`` returns false.
     *
     * @param jewishCalendar the Jewish calendar day.
     * @return if <em>hallel shalem</em> is recited.
     * @see #isHallelRecited(JewishCalendar)
     */
    public func isHallelShalemRecited(jewishCalendar:JewishCalendar) -> Bool {
        let day = jewishCalendar.getJewishDayOfMonth();
        let month = jewishCalendar.getJewishMonth();
        let inIsrael = jewishCalendar.getInIsrael();
        if (isHallelRecited(jewishCalendar: jewishCalendar)) {
            if ((jewishCalendar.isRoshChodesh() && !jewishCalendar.isChanukah())
                || (month == JewishCalendar.NISSAN && ((inIsrael && day > 15) || (!inIsrael && day > 16)))) {
                return false;
            } else {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Returns if <a href="https://en.wikipedia.org/wiki/Al_HaNissim"><em>Al HaNissim</em></a> is recited on the day in question.
     *
     * @param jewishCalendar the Jewish calendar day.
     * @return if <em>al hanissim</em> is recited.
     * @see JewishCalendar#isChanukah()
     * @see JewishCalendar#isPurim()
     * @see JewishCalendar#getIsMukafChoma()
     */
    public func isAlHanissimRecited(jewishCalendar: JewishCalendar) -> Bool {
        return jewishCalendar.isPurim() || jewishCalendar.isChanukah();
    }
    
    /**
     * Returns if <em>Yaaleh Veyavo</em> is recited on the day in question.
     *
     * @param jewishCalendar the Jewish calendar day.
     * @return if <em>Yaaleh Veyavo</em> is recited.
     * @see JewishCalendar#isPesach()
     * @see JewishCalendar#isShavuos()
     * @see JewishCalendar#isRoshHashana()
     * @see JewishCalendar#isYomKippur()
     * @see JewishCalendar#isSuccos()
     * @see JewishCalendar#isShminiAtzeres()
     * @see JewishCalendar#isSimchasTorah()
     * @see JewishCalendar#isRoshChodesh()
     */
    public func isYaalehVeyavoRecited(jewishCalendar:JewishCalendar) -> Bool {
        return jewishCalendar.isPesach() || jewishCalendar.isShavuos() || jewishCalendar.isRoshHashana() || jewishCalendar.isYomKippur()
        || jewishCalendar.isSuccos() || jewishCalendar.isShminiAtzeres() || jewishCalendar.isSimchasTorah()
        || jewishCalendar.isRoshChodesh();
    }
    
    /**
     * Returns if Is <em>Mizmor Lesoda</em> is recited on the day in question.
     * @param jewishCalendar  the Jewish calendar day.
     * @return if <em>Mizmor Lesoda</em> is recited.
     *
     * @see #isMizmorLesodaRecitedErevYomKippurAndPesach()
     *
     */
    public func isMizmorLesodaRecited(jewishCalendar:JewishCalendar) -> Bool {
        if (jewishCalendar.isAssurBemelacha()) {
            return false;
        }
        
        let holidayIndex = jewishCalendar.getYomTovIndex();
        if(!isMizmorLesodaRecitedErevYomKippurAndPesach()
           && (holidayIndex == JewishCalendar.EREV_YOM_KIPPUR
               || holidayIndex == JewishCalendar.EREV_PESACH
               || jewishCalendar.isCholHamoedPesach())) {
            return false;
        }
        return true;
    }
    
    /**
     * Is <em>tachanun</em> set to be recited during the week of Purim, from the 11th through the 17th of
     * ``JewishCalendar.ADAR`` <em>Adar</em> (on a non-leap year, or ``JewishCalendar.ADAR_II`` <em>Adar II</em> on a leap year). Some
     * <em>chasidishe</em> communities do not recite <em>tachanun</em> during this period. See the <a href=
     * "https://www.nli.org.il/he/books/NNL_ALEPH001141272/NLI">Minhag Yisrael Torah</a> 131 and <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=4692&st=&pgnum=70">Darkei Chaim Veshalom 191</a>who discuss the
     * <em>minhag</em> not to recite <em>tachanun</em>. Also see the <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=8944&st=&pgnum=160">Mishmeres Shalom (Hadras Shalom)</a> who discusses the
     * <em>minhag</em> of not reciting it on the 16th and 17th.
     * @return If <em>tachanun</em> is set to be recited during the week of Purim from the 11th through the 17th of
     *         ``JewishCalendar.ADAR`` <em>Adar</em> (on a non-leap year, or ``JewishCalendar.ADAR_II`` <em>Adar II</em> on a leap year).
     * @see #setTachanunRecitedWeekOfPurim(boolean)
     */
    public func isTachanunRecitedWeekOfPurim() -> Bool {
        return tachanunRecitedWeekOfPurim;
    }
    
    /**
     * Sets if <em>tachanun</em> should be recited during the week of Purim from the 11th through the 17th of
     * ``JewishCalendar.ADAR`` <em>Adar</em> (on a non-leap year), or ``JewishCalendar.ADAR_II`` <em>Adar II</em> (on a leap year).
     * @param tachanunRecitedWeekOfPurim Sets if <em>tachanun</em> is to recited during the week of Purim from the 11th
     *         through the 17th of ``JewishCalendar.ADAR`` <em>Adar</em> (on a non-leap year), or ``JewishCalendar.ADAR_II``
     *         <em>Adar II</em> (on a leap year). Some <em>chasidishe</em> communities do not recite <em>tachanun</em>
     *         during this period.
     * @see #isTachanunRecitedWeekOfPurim()
     */
    public func setTachanunRecitedWeekOfPurim(tachanunRecitedWeekOfPurim:Bool) {
        self.tachanunRecitedWeekOfPurim = tachanunRecitedWeekOfPurim;
    }
    
    /**
     * Is <em>tachanun</em> set to be recited during the <em>sefira</em> week of <em>Hod</em> (14 - 20 {@link
     * JewishCalendar#IYAR <em>Iyar</em>}, or the 29th - 35th of the ``JewishCalendar.getDayOfOmer()`` <em>Omer</em>). Some
     * <em>chasidishe</em> communities do not recite <em>tachanun</em> during this week. See Minhag Yisrael Torah 131:Iyar.
     * @return If <em>tachanun</em> is set to be recited during the <em>sefira</em> week of <em>Hod</em> (14 - 20
     *         JewishCalendar.IYAR <em>Iyar</em>, or the 29th - 35th of the JewishCalendar.getDayOfOmer() <em>Omer</em>).
     * @see #setTachanunRecitedWeekOfHod(boolean)
     */
    public func isTachanunRecitedWeekOfHod() -> Bool {
        return tachanunRecitedWeekOfHod;
    }
    
    /**
     * Sets if <em>tachanun</em> should be recited during the <em>sefira</em> week of <em>Hod</em> (14 - 20
     * ``JewishCalendar.IYAR`` <em>Iyar</em>, or the 29th - 35th of the ``JewishCalendar.getDayOfOmer()`` <em>Omer</em>).
     * @param tachanunRecitedWeekOfHod Sets if <em>tachanun</em> should be recited during the <em>sefira</em> week of
     * <em>Hod</em>.
     * @see #isTachanunRecitedWeekOfHod()
     */
    public func setTachanunRecitedWeekOfHod(tachanunRecitedWeekOfHod:Bool) {
        self.tachanunRecitedWeekOfHod = tachanunRecitedWeekOfHod;
    }
    
    /**
     * Is <em>tachanun</em> set to be recited at the end of ``JewishCalendar.TISHREI`` <em>Tishrei</em>.The Magen Avraham 669:1 and
     * the Pri Chadash 131:7 state that some places to not recite <em>tachanun</em> during this period. The Sh"UT Chasam Sofer on
     * Choshen Mishpat 77 writes that this is the <em>minhag</em> in Ashkenaz. The Shaarei Teshuva 131:19 quotes the Sheyarie Kneses
     * Hagdola who also states that it should not be recited. The Aderes wanted to institute saying <em>tachanun</em> during this
     * period, but was dissuaded from this by Rav Shmuel Salant who did not want to change the <em>minhag</em> in Yerushalayim.
     * The Aruch Hashulchan is of the opinion that this <em>minhag</em> is incorrect, and it should be recited, and The Chazon
     * Ish also recited <em>tachanun</em> during this period. See the Dirshu edition of the Mishna Berurah for details.
     * @return If <em>tachanun</em> is set to be recited at the end of ``JewishCalendar.TISHREI`` <em>Tishrei</em>.
     * @see #setTachanunRecitedEndOfTishrei(tachanunRecitedEndOfTishrei)
     */
    public func isTachanunRecitedEndOfTishrei() -> Bool {
        return tachanunRecitedEndOfTishrei;
    }
    
    /**
     * Sets if <em>tachanun</em> should be recited at the end of ``JewishCalendar.TISHREI`` <em>Tishrei</em>.
     * @param tachanunRecitedEndOfTishrei is <em>tachanun</em> recited at the end of ``JewishCalendar.TISHREI`` <em>Tishrei</em>.
     * @see #isTachanunRecitedEndOfTishrei()
     */
    public func setTachanunRecitedEndOfTishrei(tachanunRecitedEndOfTishrei:Bool) {
        self.tachanunRecitedEndOfTishrei = tachanunRecitedEndOfTishrei;
    }
    
    /**
     * Is <em>tachanun</em> set to be recited during the week after <em>Shavuos</em>. this is the opinion of the Pri
     * Megadim quoted by the Mishna Berurah. this is since <em>karbanos</em> of <em>Shavuos</em> have <em>tashlumim</em>
     * for 7 days, it is still considered like a <em>Yom Tov</em>. The Chazon Ish quoted in the Orchos Rabainu vol. 1
     * page 68 recited <em>tachanun</em> during this week.
     *
     * @return If <em>tachanun</em> is set to be recited during the week after Shavuos.
     * @see #setTachanunRecitedWeekAfterShavuos(boolean)
     */
    public func isTachanunRecitedWeekAfterShavuos() -> Bool {
        return tachanunRecitedWeekAfterShavuos;
    }
    
    /**
     * Sets if <em>tachanun</em> should be recited during the week after <em>Shavuos</em>.
     * @param tachanunRecitedWeekAfterShavuos is <em>tachanun</em> recited during the week after Shavuos.
     * @see #isTachanunRecitedWeekAfterShavuos()
     */
    public func setTachanunRecitedWeekAfterShavuos(tachanunRecitedWeekAfterShavuos:Bool) {
        self.tachanunRecitedWeekAfterShavuos = tachanunRecitedWeekAfterShavuos;
    }
    
    /**
     * Is <em>tachanun</em> is set to be recited on the 13th of ``JewishCalendar.SIVAN`` <em>Sivan</em> (<a href=
     * "https://en.wikipedia.org/wiki/Yom_tov_sheni_shel_galuyot"><em>Yom Tov Sheni shel Galuyos</em></a> of the 7th
     * day) outside Israel. This is brought down by the Shaarie Teshuva 131:19 quoting the <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=41295&st=&pgnum=39">Sheyarei Kneses Hagedola 131:12</a>that
     * <em>tachanun</em> should not be recited on this day. Rav Shlomo Zalman Orbach in Halichos Shlomo on
     * Shavuos 12:16:25 is of the opinion that even in <em>chutz laaretz</em> it should be recited since the <em>yemei
     * Tashlumin</em> are counted based on Israel since that is where the <em>karbanos</em> are brought. Both
     * ``isTachanunRecitedShacharis(jewishCalendar:)`` and ``isTachanunRecitedMincha(jewishCalendar:)``
     * only return false if the location is not set to ``JewishCalendar.getInIsrael()`` Israel and both
     * ``tachanunRecitedWeekAfterShavuos`` and ``setTachanunRecited13SivanOutOfIsrael(tachanunRecitedThirteenSivanOutOfIsrael:)`` are set to false.
     *
     * @return If <em>tachanun</em> is set to be recited on the 13th of {@link JewishCalendar#SIVAN <em>Sivan</em>} out of Israel.
     * @see #setTachanunRecited13SivanOutOfIsrael(isTachanunRecitedThirteenSivanOutOfIsrael)
     * @see #isTachanunRecitedWeekAfterShavuos()
     */
    public func isTachanunRecited13SivanOutOfIsrael() -> Bool {
        return tachanunRecited13SivanOutOfIsrael;
    }
    
    /**
     * Sets if <em>tachanun</em> should be recited on the 13th of ``JewishCalendar.SIVAN`` <em>Sivan</em> (<a href=
     * "https://en.wikipedia.org/wiki/Yom_tov_sheni_shel_galuyot"><em>Yom Tov Sheni shel Galuyos</em></a> of the 7th
     * day) outside Israel.
     * @param tachanunRecitedThirteenSivanOutOfIsrael sets if <em>tachanun</em> should be recited on the 13th of
     *          ``JewishCalendar.SIVAN`` <em>Sivan</em> out of Israel. Both  ``isTachanunRecitedShacharis(jewishCalendar:)`` and
     *          ``isTachanunRecitedMincha(jewishCalendar:)`` only return false if the location is not set to
     *          ``JewishCalendar.getInIsrael()`` Israel and both ``tachanunRecitedWeekAfterShavuos`` and
     *          ``setTachanunRecited13SivanOutOfIsrael(tachanunRecitedThirteenSivanOutOfIsrael:)`` are set to false.
     * @see #isTachanunRecited13SivanOutOfIsrael()
     */
    public func setTachanunRecited13SivanOutOfIsrael(tachanunRecitedThirteenSivanOutOfIsrael:Bool) {
        self.tachanunRecited13SivanOutOfIsrael = tachanunRecitedThirteenSivanOutOfIsrael;
    }
    
    /**
     * Is <em>tachanun</em> set to be recited on ``JewishCalendar.PESACH_SHENI`` <em>Pesach Sheni</em>. The Pri Chadash 131:7
     * states that <em>tachanun</em> should not be recited. The Aruch Hashulchan states that this is the minhag of the
     * <em>sephardim</em>. The Shaarei Efraim 10:27 also mentions that it is not recited, as does the Siddur Yaavetz (Shaar Hayesod,
     * Chodesh Iyar). The Pri Megadim (Mishbetzes Hazahav 131:15) and the Chazon Ish (Erev Pesach Shechal Beshabbos, page 203 in
     * <a href="https://he.wikipedia.org/wiki/%D7%A9%D7%A8%D7%99%D7%94_%D7%93%D7%91%D7%9C%D7%99%D7%A6%D7%A7%D7%99">Rav Sheraya
     * Devlitzky's</a> comments).
     *
     * @return If <em>tachanun</em> is set to be recited on ``JewishCalendar.PESACH_SHENI`` <em>Pesach Sheni</em>.
     * @see #setTachanunRecitedPesachSheni(boolean)
     */
    public func isTachanunRecitedPesachSheni() -> Bool {
        return tachanunRecitedPesachSheni;
    }
    
    /**
     * Sets if <em>tachanun</em> should be recited on ``JewishCalendar.PESACH_SHENI`` <em>Pesach Sheni</em>.
     * @param tachanunRecitedPesachSheni sets if <em>tachanun</em> should be recited on <em>Pesach Sheni</em>.
     * @see #isTachanunRecitedPesachSheni()
     */
    public func setTachanunRecitedPesachSheni(tachanunRecitedPesachSheni:Bool) {
        self.tachanunRecitedPesachSheni = tachanunRecitedPesachSheni;
    }
    
    /**
     * Is <em>tachanun</em> set to be recited on 15 ``JewishCalendar.IYAR`` <em>Iyar</em> (<em>sfaika deyoma</em> of
     * ``JewishCalendar.PESACH_SHENI`` <em>Pesach Sheni</em>) out of Israel. If ``isTachanunRecitedPesachSheni()`` is
     * <code>true</code> this will be ignored even if <code>false</code>.
     *
     * @return if <em>tachanun</em> is set to be recited on 15 ``JewishCalendar.IYAR`` <em>Iyar</em>  (<em>sfaika deyoma</em>
     *          of``JewishCalendar.PESACH_SHENI`` <em>Pesach Sheni</em> out of Israel. If
     *          ``isTachanunRecitedPesachSheni()`` is <code>true</code> this will be ignored even if <code>false</code>.
     * @see #setTachanunRecited15IyarOutOfIsrael(boolean)
     * @see #setTachanunRecitedPesachSheni(boolean)
     * @see #isTachanunRecitedPesachSheni()
     */
    public func isTachanunRecited15IyarOutOfIsrael() -> Bool {
        return tachanunRecited15IyarOutOfIsrael;
    }
    
    /**
     * Sets if <em>tachanun</em> should be recited on the 15th of ``JewishCalendar.IYAR`` <em>Iyar</em>  (<a href=
     * "https://en.wikipedia.org/wiki/Yom_tov_sheni_shel_galuyot"><em>Yom Tov Sheni shel Galuyos</em></a> of
     * ``JewishCalendar.PESACH_SHENI`` <em>Pesach Sheni</em>) out of Israel. Ignored if
     * ``isTachanunRecitedPesachSheni()`` is <code>true</code>.
     *
     * @param tachanunRecited15IyarOutOfIsrael if <em>tachanun</em> should be recited on the 15th of ``JewishCalendar.IYAR``
     *          <em>Iyar</em> (<em>sfaika deyoma</em> of ``JewishCalendar.PESACH_SHENI`` <em>Pesach Sheni</em>) out of Israel.
     * @see #isTachanunRecited15IyarOutOfIsrael()
     */
    public func setTachanunRecited15IyarOutOfIsrael(tachanunRecited15IyarOutOfIsrael:Bool) {
        self.tachanunRecited15IyarOutOfIsrael = tachanunRecited15IyarOutOfIsrael;
    }
    
    /**
     * Is <em>tachanun</em> set to be recited on <em>mincha</em> on <em>erev ``JewishCalendar.LAG_BAOMER`` Lag
     * Baomer</em>.
     * @return if <em>tachanun</em> is set to be recited in <em>mincha</em> on <em>erev</em>
     *           ``JewishCalendar.LAG_BAOMER`` <em>Lag Baomer</em>.
     * @see #setTachanunRecitedMinchaErevLagBaomer(boolean)
     */
    public func isTachanunRecitedMinchaErevLagBaomer() -> Bool {
        return tachanunRecitedMinchaErevLagBaomer;
    }
    
    /**
     * Sets if <em>tachanun</em> should be recited on <em>erev ``JewishCalendar.LAG_BAOMER`` Lag Baomer</em>.
     * @param tachanunRecitedMinchaErevLagBaomer sets if <em>tachanun</em> should be recited on <em>mincha</em>
     *          of <em>erev ``JewishCalendar.LAG_BAOMER`` Lag Baomer</em>.
     * @see #isTachanunRecitedMinchaErevLagBaomer()
     */
    public func setTachanunRecitedMinchaErevLagBaomer(tachanunRecitedMinchaErevLagBaomer: Bool) {
        self.tachanunRecitedMinchaErevLagBaomer = tachanunRecitedMinchaErevLagBaomer;
    }
    
    /**
     * Is <em>tachanun</em> set to be recited during the <em>Shivas Yemei Hamiluim</em>, from the 23 of
     * ``JewishCalendar.ADAR`` <em>Adar</em> on a non-leap-year or ``JewishCalendar.ADAR_II`` <em>Adar II</em> on a
     * leap year to the end of the month. Some <em>chasidishe</em> communities do not say <em>tachanun</em>
     * during this week. See <a href="https://hebrewbooks.org/pdfpager.aspx?req=4692&st=&pgnum=70">Darkei
     * Chaim Veshalom 191</a>.
     * @return if <em>tachanun</em> is set to be recited during the <em>Shivas Yemei Hamiluim</em>, from the 23
     *           of ``JewishCalendar.ADAR`` <em>Adar</em> on a non-leap-year or ``JewishCalendar.ADAR_II``
     *           <em>Adar II</em> on a leap year to the end of the month.
     * @see #setTachanunRecitedShivasYemeiHamiluim(boolean)
     */
    public func isTachanunRecitedShivasYemeiHamiluim() -> Bool {
        return tachanunRecitedShivasYemeiHamiluim;
    }
    
    /**
     * Sets if <em>tachanun</em> should be recited during the <em>Shivas Yemei Hamiluim</em>, from the 23 of
     * ``JewishCalendar.ADAR`` <em>Adar</em> on a non-leap-year or ``JewishCalendar.ADAR_II`` <em>Adar II</em>
     * on a leap year to the end of the month.
     * @param tachanunRecitedShivasYemeiHamiluim sets if <em>tachanun</em> should be recited during the
     *          <em>Shivas Yemei Hamiluim</em>.
     * @see #isTachanunRecitedShivasYemeiHamiluim()
     */
    public func setTachanunRecitedShivasYemeiHamiluim(tachanunRecitedShivasYemeiHamiluim:Bool) {
        self.tachanunRecitedShivasYemeiHamiluim = tachanunRecitedShivasYemeiHamiluim;
    }
    
    /**
     * Is <em>tachanun</em> set to be recited on Fridays. Some <em>chasidishe</em> communities do not recite
     * <em>tachanun</em> on Fridays. See <a href="https://hebrewbooks.org/pdfpager.aspx?req=41190&st=&pgnum=10">Likutei
     * Maharich Vol 2 Seder Hanhagos Erev Shabbos</a>. this is also the <em>minhag</em> in Satmar.
     * @return if <em>tachanun</em> is set to be recited on Fridays.
     * @see #setTachanunRecitedFridays(boolean)
     */
    public func isTachanunRecitedFridays() -> Bool {
        return tachanunRecitedFridays;
    }
    
    /**
     * Sets if <em>tachanun</em> should be recited on Fridays.
     * @param tachanunRecitedFridays sets if <em>tachanun</em> should be recited on Fridays. Some <em>chasidishe</em>
     *          communities do not recite <em>tachanun</em> on Fridays.
     * @see #isTachanunRecitedFridays()
     */
    public func setTachanunRecitedFridays(tachanunRecitedFridays:Bool) {
        self.tachanunRecitedFridays = tachanunRecitedFridays;
    }
    
    /**
     * Is <em>tachanun</em> set to be recited on Sundays. Some <em>chasidishe</em> communities do not recite
     * <em>tachanun</em> on Sundays. See <a href="https://hebrewbooks.org/pdfpager.aspx?req=41190&st=&pgnum=10">Likutei
     * Maharich Vol 2 Seder Hanhagos Erev Shabbos</a>.
     * @return if <em>tachanun</em> is set to be recited on Sundays.
     * @see #setTachanunRecitedSundays(boolean)
     */
    public func isTachanunRecitedSundays() -> Bool {
        return tachanunRecitedSundays;
    }
    
    /**
     * Sets if <em>tachanun</em> should be recited on Sundays.
     * @param tachanunRecitedSundays sets if <em>tachanun</em> should be recited on Sundays. Some <em>chasidishe</em>
     *          communities do not recite <em>tachanun</em> on Sundays.
     * @see #isTachanunRecitedSundays()
     */
    public func setTachanunRecitedSundays(tachanunRecitedSundays:Bool) {
        self.tachanunRecitedSundays = tachanunRecitedSundays;
    }
    
    /**
     * Is <em>tachanun</em> set to be recited in <em>Mincha</em> the entire year. Some <em>chasidishe</em> communities do
     * not recite <em>tachanun</em> by <em>Mincha</em> all year round. See <a href=
     * "https://hebrewbooks.org/pdfpager.aspx?req=4751&st=&pgnum=105">Nemukei Orach Chaim 131:3</a>.
     * @return if <em>tachanun</em> is set to be recited in <em>Mincha</em> the entire year.
     * @see #setTachanunRecitedMinchaAllYear(boolean)
     */
    public func isTachanunRecitedMinchaAllYear() -> Bool{
        return tachanunRecitedMinchaAllYear;
    }
    
    /**
     * Sets if <em>tachanun</em> should be recited in <em>Mincha</em> the entire year.
     * @param tachanunRecitedMinchaAllYear sets if <em>tachanun</em> should be recited by <em>mincha</em> all year. If set
     *          to false, ``isTachanunRecitedMincha(jewishCalendar:)`` will always return false. If set to true (the
     *          default), it will use the regular rules.
     * @see #isTachanunRecitedMinchaAllYear()
     */
    public func setTachanunRecitedMinchaAllYear(tachanunRecitedMinchaAllYear:Bool) {
        self.tachanunRecitedMinchaAllYear = tachanunRecitedMinchaAllYear;
    }
    
    /**
     * Sets if <em>Mizmor Lesoda</em> should be recited on <em>Erev Yom Kippur</em>, <em>Erev Pesach</em> and <em>Chol
     * Hamoed Pesach</em>. Ashkenazi congregations do not recite it on these days, while Sephardi congregations do. The
     * default value is <code>false</code>.
     * @param mizmorLesodaRecitedErevYomKippurAndPesach Sets if <em>Mizmor Lesoda</em> should be recited on <em>Erev Yom
     *          Kippur</em>, <em>Erev Pesach</em> and <em>Chol Hamoed Pesach</em>. If set to true (the default value is
     *          <code>false</code>).
     * @see #isTachanunRecitedMinchaAllYear()
     */
    public func setMizmorLesodaRecitedErevYomKippurAndPesach(mizmorLesodaRecitedErevYomKippurAndPesach:Bool) {
        self.mizmorLesodaRecitedErevYomKippurAndPesach = mizmorLesodaRecitedErevYomKippurAndPesach;
    }
    
    /**
     * Is <em>Mizmor Lesoda</em> set to be recited on <em>Erev Yom Kippur</em>, <em>Erev Pesach</em> and <em>Chol
     * Hamoed Pesach</em>. Ashkenazi congregations do not recite it on these days, while Sephardi congregations do.
     * The default value is <code>false</code>.
     * @return if <em>Mizmor Lesoda</em> is set to be recited on <em>Erev Yom Kippur</em>, <em>Erev Pesach</em> and
     *          <em>Chol Hamoed Pesach</em>. If set to true (the default value is <code>false</code>).
     * @see #isMizmorLesodaRecited(JewishCalendar)
     */
    public func isMizmorLesodaRecitedErevYomKippurAndPesach() -> Bool {
        return mizmorLesodaRecitedErevYomKippurAndPesach;
    }
    
}
