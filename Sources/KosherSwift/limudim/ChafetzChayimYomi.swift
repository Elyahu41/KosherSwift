//
//  ChafetzChayimYomi.swift
//  KosherSwift
//
//  Created by Elyahu Jacobi on 9/27/24.
//

import Foundation

/// A utility class for calculating the daily study portion of the Sefer Chafetz Chayim.
///
/// The Chafetz Chayim Yomi cycle completes the study of the laws of Lashon Hara (derogatory speech)
/// and Rechilus (gossip). The schedule dynamically adjusts its pacing based on the Hebrew calendar,
/// utilizing different cyclical tracks depending on whether the current year is a standard year
/// or a Jewish leap year (which contains an additional month).
public class ChafetzChayimYomi {
    
    private static let hakdamah = "הקדמה";
    private static let psichah = "פתיחה";
    private static let lavin = "לווין";
    private static let asin = "עשין";
    private static let arurin = "ערורין";
    private static let hilchosLH = "הלכות ל\"ה";
    private static let hilchosRechilus = "הלכות רכילות";
    private static let tziyurim = "צייורים";
    
    private static let hakdama1 = "ברוך ד׳ - שכינתו בתוכנו";
    private static let hakdama2 = "וכאשר נחפשה - מגדל העון";
    private static let hakdama3 = "ונראה פשוט - לאין שעור";
    private static let hakdama4 = "ואחשבה - בפנים הספר";
    private static let hakdama5 = "על כן - צד הדי";
    private static let hakdama6 = "ואחלה להקורא - במהרה בימינו אמן";
    private static let hakdama7 = "ואל יפלא - לעון כלל";
    
    /// Calculates and retrieves the assigned Chafetz Chayim reading for a specific Hebrew date.
    ///
    /// This method evaluates the day and month from the provided `JewishCalendar` instance.
    /// It automatically routes the lookup through either the leap-year schedule or the standard-year
    /// schedule to ensure the study cycle completes accurately.
    ///
    /// - Parameter jewishCalendar: A `JewishCalendar` instance representing the target date.
    /// - Returns: A formatted string indicating the section and specific paragraphs to study
    ///   (e.g., "פתיחה: 1-4", "הלכות ל"ה: 1.1-1.2"). Returns an empty string if no match is found for the given date.
    public static func getChafetzChayimYomi(jewishCalendar:JewishCalendar) -> String {
        let day = jewishCalendar.getJewishDayOfMonth();
        let month = jewishCalendar.getJewishMonth();

        if (jewishCalendar.isJewishLeapYear()) {
            if ((day == 1 && month == JewishCalendar.TISHREI) ||
                    (day == 11 && month == JewishCalendar.SHEVAT) ||
                    (day == 20 && month == JewishCalendar.IYAR)) {
                return hakdama1;
            }
            if ((day == 2 && month == JewishCalendar.TISHREI) ||
                    (day == 12 && month == JewishCalendar.SHEVAT) ||
                    (day == 21 && month == JewishCalendar.IYAR)) {
                return hakdama2;
            }
            if ((day == 3 && month == JewishCalendar.TISHREI) ||
                    (day == 13 && month == JewishCalendar.SHEVAT) ||
                    (day == 22 && month == JewishCalendar.IYAR)) {
                return hakdama3;
            }
            if ((day == 4 && month == JewishCalendar.TISHREI) ||
                    (day == 14 && month == JewishCalendar.SHEVAT) ||
                    (day == 23 && month == JewishCalendar.IYAR)) {
                return hakdama4;
            }
            if ((day == 5 && month == JewishCalendar.TISHREI) ||
                    (day == 15 && month == JewishCalendar.SHEVAT) ||
                    (day == 24 && month == JewishCalendar.IYAR)) {
                return hakdama5;
            }
            if ((day == 6 && month == JewishCalendar.TISHREI) ||
                    (day == 16 && month == JewishCalendar.SHEVAT) ||
                    (day == 25 && month == JewishCalendar.IYAR)) {
                return hakdama6;
            }
            if ((day == 7 && month == JewishCalendar.TISHREI) ||
                    (day == 16 && month == JewishCalendar.SHEVAT) ||
                    (day == 25 && month == JewishCalendar.IYAR)) {//TODO fix this issue with the case being the same for Shevat and Iyar. This was how it was in the javascript version
                return hakdama7;
            }
            if ((day == 8 && month == JewishCalendar.TISHREI) ||
                    (day == 17 && month == JewishCalendar.SHEVAT) ||
                    (day == 26 && month == JewishCalendar.IYAR)) {
                return psichah + ": " + "1-4";
            }
            if ((day == 9 && month == JewishCalendar.TISHREI) ||
                    (day == 18 && month == JewishCalendar.SHEVAT) ||
                    (day == 27 && month == JewishCalendar.IYAR)) {
                return psichah + ": " + "5-11";
            }
            if ((day == 10 && month == JewishCalendar.TISHREI) ||
                    (day == 19 && month == JewishCalendar.SHEVAT) ||
                    (day == 28 && month == JewishCalendar.IYAR)) {
                return lavin + ": " + "1-2";
            }
            if ((day == 11 && month == JewishCalendar.TISHREI) ||
                    (day == 20 && month == JewishCalendar.SHEVAT) ||
                    (day == 29 && month == JewishCalendar.IYAR)) {
                return lavin + ": " + "3-4";
            }
            if ((day == 12 && month == JewishCalendar.TISHREI) ||
                    (day == 21 && month == JewishCalendar.SHEVAT) ||
                    (day == 1 && month == JewishCalendar.SIVAN)) {
                return lavin + ": " + "5-6";
            }
            if ((day == 13 && month == JewishCalendar.TISHREI) ||
                    (day == 22 && month == JewishCalendar.SHEVAT) ||
                    (day == 2 && month == JewishCalendar.SIVAN)) {
                return lavin + ": " + "7-9";
            }
            if ((day == 14 && month == JewishCalendar.TISHREI) ||
                    (day == 23 && month == JewishCalendar.SHEVAT) ||
                    (day == 3 && month == JewishCalendar.SIVAN)) {
                return lavin + ": " + "10-11";
            }
            if ((day == 15 && month == JewishCalendar.TISHREI) ||
                    (day == 24 && month == JewishCalendar.SHEVAT) ||
                    (day == 4 && month == JewishCalendar.SIVAN)) {
                return lavin + ": " + "12-13";
            }
            if ((day == 16 && month == JewishCalendar.TISHREI) ||
                    (day == 25 && month == JewishCalendar.SHEVAT) ||
                    (day == 5 && month == JewishCalendar.SIVAN)) {
                return lavin + ": " + "14-15";
            }
            if ((day == 17 && month == JewishCalendar.TISHREI) ||
                    (day == 26 && month == JewishCalendar.SHEVAT) ||
                    (day == 6 && month == JewishCalendar.SIVAN)) {
                return lavin + ": " + "16-17";
            }
            if ((day == 18 && month == JewishCalendar.TISHREI) ||
                    (day == 27 && month == JewishCalendar.SHEVAT) ||
                    (day == 7 && month == JewishCalendar.SIVAN)) {
                return asin + ": " + "1-2";
            }
            if ((day == 19 && month == JewishCalendar.TISHREI) ||
                    (day == 28 && month == JewishCalendar.SHEVAT) ||
                    (day == 8 && month == JewishCalendar.SIVAN)) {
                return asin + ": " + "3-4";
            }
            if ((day == 20 && month == JewishCalendar.TISHREI) ||
                    (day == 29 && month == JewishCalendar.SHEVAT) ||
                    (day == 9 && month == JewishCalendar.SIVAN)) {
                return asin + ": " + "5-6";
            }
            if ((day == 21 && month == JewishCalendar.TISHREI) ||
                    (day == 30 && month == JewishCalendar.SHEVAT) ||
                    (day == 10 && month == JewishCalendar.SIVAN)) {
                return asin + ": " + "7-8";
            }
            if ((day == 22 && month == JewishCalendar.TISHREI) ||
                    (day == 1 && month == JewishCalendar.ADAR) ||
                    (day == 11 && month == JewishCalendar.SIVAN)) {
                return asin + ": " + "9-10";
            }
            if ((day == 23 && month == JewishCalendar.TISHREI) ||
                    (day == 2 && month == JewishCalendar.ADAR) ||
                    (day == 12 && month == JewishCalendar.SIVAN)) {
                return asin + ": " + "11-12";
            }
            if ((day == 24 && month == JewishCalendar.TISHREI) ||
                    (day == 3 && month == JewishCalendar.ADAR) ||
                    (day == 13 && month == JewishCalendar.SIVAN)) {
                return asin + ": " + "13-14";
            }
            if ((day == 25 && month == JewishCalendar.TISHREI) ||
                    (day == 4 && month == JewishCalendar.ADAR) ||
                    (day == 14 && month == JewishCalendar.SIVAN)) {
                return arurin;
            }
            if ((day == 26 && month == JewishCalendar.TISHREI) ||
                    (day == 5 && month == JewishCalendar.ADAR) ||
                    (day == 15 && month == JewishCalendar.SIVAN)) {
                return hilchosLH + ": " + "1.1-1.2";
            }
            if ((day == 27 && month == JewishCalendar.TISHREI) ||
                    (day == 6 && month == JewishCalendar.ADAR) ||
                    (day == 16 && month == JewishCalendar.SIVAN)) {
                return hilchosLH + ": " + "1.3-1.4";
            }
            if ((day == 28 && month == JewishCalendar.TISHREI) ||
                    (day == 7 && month == JewishCalendar.ADAR) ||
                    (day == 17 && month == JewishCalendar.SIVAN)) {
                return hilchosLH + ": " + "1.5-1.6";
            }
            if ((day == 29 && month == JewishCalendar.TISHREI) ||
                    (day == 8 && month == JewishCalendar.ADAR) ||
                    (day == 18 && month == JewishCalendar.SIVAN)) {
                return hilchosLH + ": " + "1.7-1.9";
            }
            if ((day == 30 && month == JewishCalendar.TISHREI) ||
                    (day == 9 && month == JewishCalendar.ADAR) ||
                    (day == 19 && month == JewishCalendar.SIVAN)) {
                return hilchosLH + ": " + "2.1-2.2";
            }
            if ((day == 1 && month == JewishCalendar.CHESHVAN) ||
                    (day == 10 && month == JewishCalendar.ADAR) ||
                    (day == 20 && month == JewishCalendar.SIVAN)) {
                return hilchosLH + ": " + "2.3-2.4";
            }
            if ((day == 2 && month == JewishCalendar.CHESHVAN) ||
                    (day == 11 && month == JewishCalendar.ADAR) ||
                    (day == 21 && month == JewishCalendar.SIVAN)) {
                return hilchosLH + ": " + "2.5-2.6";
            }
            if ((day == 3 && month == JewishCalendar.CHESHVAN) ||
                    (day == 12 && month == JewishCalendar.ADAR) ||
                    (day == 22 && month == JewishCalendar.SIVAN)) {
                return hilchosLH + ": " + "2.7-2.8";
            }
            if ((day == 4 && month == JewishCalendar.CHESHVAN) ||
                    (day == 13 && month == JewishCalendar.ADAR) ||
                    (day == 23 && month == JewishCalendar.SIVAN)) {
                return hilchosLH + ": " + "2.9-2.10";
            }
            if ((day == 5 && month == JewishCalendar.CHESHVAN) ||
                    (day == 14 && month == JewishCalendar.ADAR) ||
                    (day == 24 && month == JewishCalendar.SIVAN)) {
                return hilchosLH + ": " + "2.11";
            }
            if ((day == 6 && month == JewishCalendar.CHESHVAN) ||
                    (day == 15 && month == JewishCalendar.ADAR) ||
                    (day == 25 && month == JewishCalendar.SIVAN)) {
                return hilchosLH + ": " + "2.12-2.13";
            }
            if ((day == 7 && month == JewishCalendar.CHESHVAN) ||
                    (day == 16 && month == JewishCalendar.ADAR) ||
                    (day == 26 && month == JewishCalendar.SIVAN)) {
                return hilchosLH + ": " + "3.1-3.2";
            }
            if ((day == 8 && month == JewishCalendar.CHESHVAN) ||
                    (day == 17 && month == JewishCalendar.ADAR) ||
                    (day == 27 && month == JewishCalendar.SIVAN)) {
                return hilchosLH + ": " + "3.3-3.4";
            }
            if ((day == 9 && month == JewishCalendar.CHESHVAN) ||
                    (day == 18 && month == JewishCalendar.ADAR) ||
                    (day == 28 && month == JewishCalendar.SIVAN)) {
                return hilchosLH + ": " + "3.5-3.6";
            }
            if ((day == 10 && month == JewishCalendar.CHESHVAN) ||
                    (day == 19 && month == JewishCalendar.ADAR) ||
                    (day == 29 && month == JewishCalendar.SIVAN)) {
                return hilchosLH + ": " + "3.7-3.8";
            }
            if ((day == 11 && month == JewishCalendar.CHESHVAN) ||
                    (day == 20 && month == JewishCalendar.ADAR) ||
                    (day == 30 && month == JewishCalendar.SIVAN)) {
                return hilchosLH + ": " + "4.1-4.2";
            }
            if ((day == 12 && month == JewishCalendar.CHESHVAN) ||
                    (day == 21 && month == JewishCalendar.ADAR) ||
                    (day == 1 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "4.3-4.4";
            }
            if ((day == 13 && month == JewishCalendar.CHESHVAN) ||
                    (day == 22 && month == JewishCalendar.ADAR) ||
                    (day == 2 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "4.5-4.6";
            }
            if ((day == 14 && month == JewishCalendar.CHESHVAN) ||
                    (day == 23 && month == JewishCalendar.ADAR) ||
                    (day == 3 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "4.7-4.8";
            }
            if ((day == 15 && month == JewishCalendar.CHESHVAN) ||
                    (day == 24 && month == JewishCalendar.ADAR) ||
                    (day == 4 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "4.9-4.10";
            }
            if ((day == 16 && month == JewishCalendar.CHESHVAN) ||
                    (day == 25 && month == JewishCalendar.ADAR) ||
                    (day == 5 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "4.11";
            }
            if ((day == 17 && month == JewishCalendar.CHESHVAN) ||
                    (day == 26 && month == JewishCalendar.ADAR) ||
                    (day == 6 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "4.12";
            }
            if ((day == 18 && month == JewishCalendar.CHESHVAN) ||
                    (day == 27 && month == JewishCalendar.ADAR) ||
                    (day == 7 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "5.1";
            }
            if ((day == 19 && month == JewishCalendar.CHESHVAN) ||
                    (day == 28 && month == JewishCalendar.ADAR) ||
                    (day == 8 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "5.2";
            }
            if ((day == 20 && month == JewishCalendar.CHESHVAN) ||
                    (day == 29 && month == JewishCalendar.ADAR) ||
                    (day == 9 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "5.3-5.4";
            }
            if ((day == 21 && month == JewishCalendar.CHESHVAN) ||
                    (day == 30 && month == JewishCalendar.ADAR) ||
                    (day == 10 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "5.5-5.6";
            }
            if ((day == 22 && month == JewishCalendar.CHESHVAN) ||
                    (day == 1 && month == JewishCalendar.ADAR_II) ||
                    (day == 11 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "5.7-5.8";
            }
            if ((day == 23 && month == JewishCalendar.CHESHVAN) ||
                    (day == 2 && month == JewishCalendar.ADAR_II) ||
                    (day == 12 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "6.1-6.2";
            }
            if ((day == 24 && month == JewishCalendar.CHESHVAN) ||
                    (day == 3 && month == JewishCalendar.ADAR_II) ||
                    (day == 13 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "6.3-6.4";
            }
            if ((day == 25 && month == JewishCalendar.CHESHVAN) ||
                    (day == 4 && month == JewishCalendar.ADAR_II) ||
                    (day == 14 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "6.5-6.6";
            }
            if ((day == 26 && month == JewishCalendar.CHESHVAN) ||
                    (day == 5 && month == JewishCalendar.ADAR_II) ||
                    (day == 15 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "6.7-6.8";
            }
            if ((day == 27 && month == JewishCalendar.CHESHVAN) ||
                    (day == 6 && month == JewishCalendar.ADAR_II) ||
                    (day == 16 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "6.9-6.10";
            }
            if ((day == 28 && month == JewishCalendar.CHESHVAN) ||
                    (day == 7 && month == JewishCalendar.ADAR_II) ||
                    (day == 17 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "6.11-6.12";
            }
            if ((day == 29 && month == JewishCalendar.CHESHVAN) ||
                    (day == 8 && month == JewishCalendar.ADAR_II) ||
                    (day == 18 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "7.1-7.2";
            }
            if ((day == 30 && month == JewishCalendar.CHESHVAN) ||
                    (day == 9 && month == JewishCalendar.ADAR_II) ||
                    (day == 19 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "7.3-7.4";
            }
            if ((day == 1 && month == JewishCalendar.KISLEV) ||
                    (day == 10 && month == JewishCalendar.ADAR_II) ||
                    (day == 20 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "7.5-7.6";
            }
            if ((day == 2 && month == JewishCalendar.KISLEV) ||
                    (day == 11 && month == JewishCalendar.ADAR_II) ||
                    (day == 21 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "7.7-7.8";
            }
            if ((day == 3 && month == JewishCalendar.KISLEV) ||
                    (day == 12 && month == JewishCalendar.ADAR_II) ||
                    (day == 22 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "7.9";
            }
            if ((day == 4 && month == JewishCalendar.KISLEV) ||
                    (day == 13 && month == JewishCalendar.ADAR_II) ||
                    (day == 23 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "7.10";
            }
            if ((day == 5 && month == JewishCalendar.KISLEV) ||
                    (day == 14 && month == JewishCalendar.ADAR_II) ||
                    (day == 24 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "7.11-7.11";
            }
            if ((day == 6 && month == JewishCalendar.KISLEV) ||
                    (day == 15 && month == JewishCalendar.ADAR_II) ||
                    (day == 25 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "7.13-7.14";
            }
            if ((day == 7 && month == JewishCalendar.KISLEV) ||
                    (day == 16 && month == JewishCalendar.ADAR_II) ||
                    (day == 26 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "8.1-8.2";
            }
            if ((day == 8 && month == JewishCalendar.KISLEV) ||
                    (day == 17 && month == JewishCalendar.ADAR_II) ||
                    (day == 27 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "8.3-8.4";
            }
            if ((day == 9 && month == JewishCalendar.KISLEV) ||
                    (day == 18 && month == JewishCalendar.ADAR_II) ||
                    (day == 28 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "8.5";
            }
            if ((day == 10 && month == JewishCalendar.KISLEV) ||
                    (day == 19 && month == JewishCalendar.ADAR_II) ||
                    (day == 29 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "8.6-8.7";
            }
            if ((day == 11 && month == JewishCalendar.KISLEV) ||
                    (day == 20 && month == JewishCalendar.ADAR_II) ||
                    (day == 1 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "8.8-8.9";
            }
            if ((day == 12 && month == JewishCalendar.KISLEV) ||
                    (day == 21 && month == JewishCalendar.ADAR_II) ||
                    (day == 2 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "8.10-8.11";
            }
            if ((day == 13 && month == JewishCalendar.KISLEV) ||
                    (day == 22 && month == JewishCalendar.ADAR_II) ||
                    (day == 3 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "8.12";
            }
            if ((day == 14 && month == JewishCalendar.KISLEV) ||
                    (day == 23 && month == JewishCalendar.ADAR_II) ||
                    (day == 4 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "8.13-8.14";
            }
            if ((day == 15 && month == JewishCalendar.KISLEV) ||
                    (day == 24 && month == JewishCalendar.ADAR_II) ||
                    (day == 5 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "9.1-9.2";
            }
            if ((day == 16 && month == JewishCalendar.KISLEV) ||
                    (day == 25 && month == JewishCalendar.ADAR_II) ||
                    (day == 6 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "9.3-9.4";
            }
            if ((day == 17 && month == JewishCalendar.KISLEV) ||
                    (day == 26 && month == JewishCalendar.ADAR_II) ||
                    (day == 7 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "9.5-9.6";
            }
            if ((day == 18 && month == JewishCalendar.KISLEV) ||
                    (day == 27 && month == JewishCalendar.ADAR_II) ||
                    (day == 8 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "10.1-10.2";
            }
            if ((day == 19 && month == JewishCalendar.KISLEV) ||
                    (day == 28 && month == JewishCalendar.ADAR_II) ||
                    (day == 9 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "10.3";
            }
            if ((day == 20 && month == JewishCalendar.KISLEV) ||
                    (day == 29 && month == JewishCalendar.ADAR_II) ||
                    (day == 10 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "10.4";
            }
            if ((day == 21 && month == JewishCalendar.KISLEV) ||
                    (day == 1 && month == JewishCalendar.NISSAN) ||
                    (day == 11 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "10.5-10.6";
            }
            if ((day == 22 && month == JewishCalendar.KISLEV) ||
                    (day == 2 && month == JewishCalendar.NISSAN) ||
                    (day == 12 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "10.7-10.8";
            }
            if ((day == 23 && month == JewishCalendar.KISLEV) ||
                    (day == 3 && month == JewishCalendar.NISSAN) ||
                    (day == 13 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "10.9-10.10";
            }
            if ((day == 24 && month == JewishCalendar.KISLEV) ||
                    (day == 4 && month == JewishCalendar.NISSAN) ||
                    (day == 14 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "10.11-10.12";
            }
            if ((day == 25 && month == JewishCalendar.KISLEV) ||
                    (day == 5 && month == JewishCalendar.NISSAN) ||
                    (day == 15 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "10.13";
            }
            if ((day == 26 && month == JewishCalendar.KISLEV) ||
                    (day == 6 && month == JewishCalendar.NISSAN) ||
                    (day == 16 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "10.14";
            }
            if ((day == 27 && month == JewishCalendar.KISLEV) ||
                    (day == 7 && month == JewishCalendar.NISSAN) ||
                    (day == 17 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "10.15-10.16";
            }
            if ((day == 28 && month == JewishCalendar.KISLEV) ||
                    (day == 8 && month == JewishCalendar.NISSAN) ||
                    (day == 18 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "10.17";
            }
            if ((day == 29 && month == JewishCalendar.KISLEV) ||
                    (day == 9 && month == JewishCalendar.NISSAN) ||
                    (day == 19 && month == JewishCalendar.AV)) {
                return hilchosRechilus + ": " + "1.1-1.2";
            }
            if ((day == 30 && month == JewishCalendar.KISLEV) ||
                    (day == 10 && month == JewishCalendar.NISSAN) ||
                    (day == 20 && month == JewishCalendar.AV)) {
                return hilchosRechilus + ": " + "1.3";
            }
            if ((day == 1 && month == JewishCalendar.TEVES) ||
                    (day == 11 && month == JewishCalendar.NISSAN) ||
                    (day == 21 && month == JewishCalendar.AV)) {
                return hilchosRechilus + ": " + "1.4-1.5";
            }
            if ((day == 2 && month == JewishCalendar.TEVES) ||
                    (day == 12 && month == JewishCalendar.NISSAN) ||
                    (day == 22 && month == JewishCalendar.AV)) {
                return hilchosRechilus + ": " + "1.6-1.7";
            }
            if ((day == 3 && month == JewishCalendar.TEVES) ||
                    (day == 13 && month == JewishCalendar.NISSAN) ||
                    (day == 23 && month == JewishCalendar.AV)) {
                return hilchosRechilus + ": " + "1.8-1.9";
            }
            if ((day == 4 && month == JewishCalendar.TEVES) ||
                    (day == 14 && month == JewishCalendar.NISSAN) ||
                    (day == 24 && month == JewishCalendar.AV)) {
                return hilchosRechilus + ": " + "1.10-1.11";
            }
            if ((day == 5 && month == JewishCalendar.TEVES) ||
                    (day == 15 && month == JewishCalendar.NISSAN) ||
                    (day == 25 && month == JewishCalendar.AV)) {
                return hilchosRechilus + ": " + "2.1-2.2";
            }
            if ((day == 6 && month == JewishCalendar.TEVES) ||
                    (day == 16 && month == JewishCalendar.NISSAN) ||
                    (day == 26 && month == JewishCalendar.AV)) {
                return hilchosRechilus + ": " + "2.3-2.4";
            }
            if ((day == 7 && month == JewishCalendar.TEVES) ||
                    (day == 17 && month == JewishCalendar.NISSAN) ||
                    (day == 27 && month == JewishCalendar.AV)) {
                return hilchosRechilus + ": " + "3.1";
            }
            if ((day == 8 && month == JewishCalendar.TEVES) ||
                    (day == 18 && month == JewishCalendar.NISSAN) ||
                    (day == 28 && month == JewishCalendar.AV)) {
                return hilchosRechilus + ": " + "3.2-3.4";
            }
            if ((day == 9 && month == JewishCalendar.TEVES) ||
                    (day == 19 && month == JewishCalendar.NISSAN) ||
                    (day == 29 && month == JewishCalendar.AV)) {
                return hilchosRechilus + ": " + "4.1-4.3";
            }
            if ((day == 10 && month == JewishCalendar.TEVES) ||
                    (day == 20 && month == JewishCalendar.NISSAN) ||
                    (day == 30 && month == JewishCalendar.AV)) {
                return hilchosRechilus + ": " + "5.1-5.2";
            }
            if ((day == 11 && month == JewishCalendar.TEVES) ||
                    (day == 21 && month == JewishCalendar.NISSAN) ||
                    (day == 1 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "5.3-5.4";
            }
            if ((day == 12 && month == JewishCalendar.TEVES) ||
                    (day == 22 && month == JewishCalendar.NISSAN) ||
                    (day == 2 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "5.5";
            }
            if ((day == 13 && month == JewishCalendar.TEVES) ||
                    (day == 23 && month == JewishCalendar.NISSAN) ||
                    (day == 3 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "5.6-5.7";
            }
            if ((day == 14 && month == JewishCalendar.TEVES) ||
                    (day == 24 && month == JewishCalendar.NISSAN) ||
                    (day == 4 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "6.1-6.2";
            }
            if ((day == 15 && month == JewishCalendar.TEVES) ||
                    (day == 25 && month == JewishCalendar.NISSAN) ||
                    (day == 5 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "6.3-6.4";
            }
            if ((day == 16 && month == JewishCalendar.TEVES) ||
                    (day == 26 && month == JewishCalendar.NISSAN) ||
                    (day == 6 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "6.5-6.6";
            }
            if ((day == 17 && month == JewishCalendar.TEVES) ||
                    (day == 27 && month == JewishCalendar.NISSAN) ||
                    (day == 7 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "6.7";
            }
            if ((day == 18 && month == JewishCalendar.TEVES) ||
                    (day == 28 && month == JewishCalendar.NISSAN) ||
                    (day == 8 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "6.8-6.9";
            }
            if ((day == 19 && month == JewishCalendar.TEVES) ||
                    (day == 29 && month == JewishCalendar.NISSAN) ||
                    (day == 9 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "6.10";
            }
            if ((day == 20 && month == JewishCalendar.TEVES) ||
                    (day == 30 && month == JewishCalendar.NISSAN) ||
                    (day == 10 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "7.1";
            }
            if ((day == 21 && month == JewishCalendar.TEVES) ||
                    (day == 1 && month == JewishCalendar.IYAR) ||
                    (day == 11 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "7.3";
            }
            if ((day == 22 && month == JewishCalendar.TEVES) ||
                    (day == 2 && month == JewishCalendar.IYAR) ||
                    (day == 12 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "7.3-7.4";
            }
            if ((day == 23 && month == JewishCalendar.TEVES) ||
                    (day == 3 && month == JewishCalendar.IYAR) ||
                    (day == 13 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "7.5";
            }
            if ((day == 24 && month == JewishCalendar.TEVES) ||
                    (day == 4 && month == JewishCalendar.IYAR) ||
                    (day == 14 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "8.1-8.3";
            }
            if ((day == 25 && month == JewishCalendar.TEVES) ||
                    (day == 5 && month == JewishCalendar.IYAR) ||
                    (day == 15 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "8.4-8.5";
            }
            if ((day == 26 && month == JewishCalendar.TEVES) ||
                    (day == 6 && month == JewishCalendar.IYAR) ||
                    (day == 16 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "9.1-9.2";
            }
            if ((day == 27 && month == JewishCalendar.TEVES) ||
                    (day == 7 && month == JewishCalendar.IYAR) ||
                    (day == 17 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "9.3-9.4";
            }
            if ((day == 28 && month == JewishCalendar.TEVES) ||
                    (day == 8 && month == JewishCalendar.IYAR) ||
                    (day == 18 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "9.5-9.6";
            }
            if ((day == 29 && month == JewishCalendar.TEVES) ||
                    (day == 9 && month == JewishCalendar.IYAR) ||
                    (day == 19 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "9.7-9.9";
            }
            if ((day == 1 && month == JewishCalendar.SHEVAT) ||
                    (day == 10 && month == JewishCalendar.IYAR) ||
                    (day == 20 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "9.10";
            }
            if ((day == 2 && month == JewishCalendar.SHEVAT) ||
                    (day == 11 && month == JewishCalendar.IYAR) ||
                    (day == 21 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "9.11-9.12";
            }
            if ((day == 3 && month == JewishCalendar.SHEVAT) ||
                    (day == 12 && month == JewishCalendar.IYAR) ||
                    (day == 22 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "9.13";
            }
            if ((day == 4 && month == JewishCalendar.SHEVAT) ||
                    (day == 13 && month == JewishCalendar.IYAR) ||
                    (day == 23 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "9.14-9.15";
            }
            if ((day == 5 && month == JewishCalendar.SHEVAT) ||
                    (day == 14 && month == JewishCalendar.IYAR) ||
                    (day == 24 && month == JewishCalendar.ELUL)) {
                return tziyurim + ": " + "1-2";
            }
            if ((day == 6 && month == JewishCalendar.SHEVAT) ||
                    (day == 15 && month == JewishCalendar.IYAR) ||
                    (day == 25 && month == JewishCalendar.ELUL)) {
                return tziyurim + ": " + "3";
            }
            if ((day == 7 && month == JewishCalendar.SHEVAT) ||
                    (day == 16 && month == JewishCalendar.IYAR) ||
                    (day == 26 && month == JewishCalendar.ELUL)) {
                return tziyurim + ": " + "4-5";
            }
            if ((day == 8 && month == JewishCalendar.SHEVAT) ||
                    (day == 17 && month == JewishCalendar.IYAR) ||
                    (day == 27 && month == JewishCalendar.ELUL)) {
                return tziyurim + ": " + "6-7";
            }
            if ((day == 9 && month == JewishCalendar.SHEVAT) ||
                    (day == 18 && month == JewishCalendar.IYAR) ||
                    (day == 28 && month == JewishCalendar.ELUL)) {
                return tziyurim + ": " + "8-9";
            }
            if ((day == 10 && month == JewishCalendar.SHEVAT) ||
                    (day == 19 && month == JewishCalendar.IYAR) ||
                    (day == 29 && month == JewishCalendar.ELUL)) {
                return tziyurim + ": " + "10-11";
            }
        } else {// not leap year
            if ((day == 1 && month == JewishCalendar.TISHREI) ||
                    (day == 1 && month == JewishCalendar.SHEVAT) ||
                    (day == 1 && month == JewishCalendar.SIVAN)) {
                return hakdama1;
            }
            if ((day == 2 && month == JewishCalendar.TISHREI) ||
                    (day == 2 && month == JewishCalendar.SHEVAT) ||
                    (day == 2 && month == JewishCalendar.SIVAN)) {
                return hakdama2;
            }
            if ((day == 3 && month == JewishCalendar.TISHREI) ||
                    (day == 3 && month == JewishCalendar.SHEVAT) ||
                    (day == 3 && month == JewishCalendar.SIVAN)) {
                return hakdama3;
            }
            if ((day == 4 && month == JewishCalendar.TISHREI) ||
                    (day == 4 && month == JewishCalendar.SHEVAT) ||
                    (day == 4 && month == JewishCalendar.SIVAN)) {
                return hakdama4;
            }
            if ((day == 5 && month == JewishCalendar.TISHREI) ||
                    (day == 5 && month == JewishCalendar.SHEVAT) ||
                    (day == 5 && month == JewishCalendar.SIVAN)) {
                return hakdama5;
            }
            if ((day == 6 && month == JewishCalendar.TISHREI) ||
                    (day == 6 && month == JewishCalendar.SHEVAT) ||
                    (day == 6 && month == JewishCalendar.SIVAN)) {
                return hakdama6;
            }
            if ((day == 7 && month == JewishCalendar.TISHREI) ||
                    (day == 6 && month == JewishCalendar.SHEVAT) ||
                    (day == 6 && month == JewishCalendar.SIVAN)) {//TODO fix this issue with the case being the same for Shevat and Sivan. This was how it was in the javascript version
                return hakdama7;
            }
            if ((day == 8 && month == JewishCalendar.TISHREI) ||
                    (day == 7 && month == JewishCalendar.SHEVAT) ||
                    (day == 7 && month == JewishCalendar.SIVAN)) {
                return psichah + ": " + "1-4";
            }
            if ((day == 9 && month == JewishCalendar.TISHREI) ||
                    (day == 8 && month == JewishCalendar.SHEVAT) ||
                    (day == 8 && month == JewishCalendar.SIVAN)) {
                return psichah + ": " + "5-11";
            }
            if ((day == 10 && month == JewishCalendar.TISHREI) ||
                    (day == 9 && month == JewishCalendar.SHEVAT) ||
                    (day == 9 && month == JewishCalendar.SIVAN)) {
                return lavin + ": " + "1-2";
            }
            if ((day == 11 && month == JewishCalendar.TISHREI) ||
                    (day == 10 && month == JewishCalendar.SHEVAT) ||
                    (day == 10 && month == JewishCalendar.SIVAN)) {
                return lavin + ": " + "3-4";
            }
            if ((day == 12 && month == JewishCalendar.TISHREI) ||
                    (day == 11 && month == JewishCalendar.SHEVAT) ||
                    (day == 11 && month == JewishCalendar.SIVAN)) {
                return lavin + ": " + "5-6";
            }
            if ((day == 13 && month == JewishCalendar.TISHREI) ||
                    (day == 12 && month == JewishCalendar.SHEVAT) ||
                    (day == 12 && month == JewishCalendar.SIVAN)) {
                return lavin + ": " + "7-9";
            }
            if ((day == 14 && month == JewishCalendar.TISHREI) ||
                    (day == 13 && month == JewishCalendar.SHEVAT) ||
                    (day == 13 && month == JewishCalendar.SIVAN)) {
                return lavin + ": " + "10-11";
            }
            if ((day == 15 && month == JewishCalendar.TISHREI) ||
                    (day == 14 && month == JewishCalendar.SHEVAT) ||
                    (day == 14 && month == JewishCalendar.SIVAN)) {
                return lavin + ": " + "12-13";
            }
            if ((day == 16 && month == JewishCalendar.TISHREI) ||
                    (day == 15 && month == JewishCalendar.SHEVAT) ||
                    (day == 15 && month == JewishCalendar.SIVAN)) {
                return lavin + ": " + "14-15";
            }
            if ((day == 17 && month == JewishCalendar.TISHREI) ||
                    (day == 16 && month == JewishCalendar.SHEVAT) ||
                    (day == 16 && month == JewishCalendar.SIVAN)) {
                return lavin + ": " + "16-17";
            }
            if ((day == 18 && month == JewishCalendar.TISHREI) ||
                    (day == 17 && month == JewishCalendar.SHEVAT) ||
                    (day == 17 && month == JewishCalendar.SIVAN)) {
                return asin + ": " + "1-2";
            }
            if ((day == 19 && month == JewishCalendar.TISHREI) ||
                    (day == 18 && month == JewishCalendar.SHEVAT) ||
                    (day == 18 && month == JewishCalendar.SIVAN)) {
                return asin + ": " + "3-4";
            }
            if ((day == 20 && month == JewishCalendar.TISHREI) ||
                    (day == 19 && month == JewishCalendar.SHEVAT) ||
                    (day == 19 && month == JewishCalendar.SIVAN)) {
                return asin + ": " + "5-6";
            }
            if ((day == 21 && month == JewishCalendar.TISHREI) ||
                    (day == 20 && month == JewishCalendar.SHEVAT) ||
                    (day == 20 && month == JewishCalendar.SIVAN)) {
                return asin + ": " + "7-8";
            }
            if ((day == 22 && month == JewishCalendar.TISHREI) ||
                    (day == 21 && month == JewishCalendar.SHEVAT) ||
                    (day == 21 && month == JewishCalendar.SIVAN)) {
                return asin + ": " + "9-10";
            }
            if ((day == 23 && month == JewishCalendar.TISHREI) ||
                    (day == 22 && month == JewishCalendar.SHEVAT) ||
                    (day == 22 && month == JewishCalendar.SIVAN)) {
                return asin + ": " + "11-12";
            }
            if ((day == 24 && month == JewishCalendar.TISHREI) ||
                    (day == 23 && month == JewishCalendar.SHEVAT) ||
                    (day == 23 && month == JewishCalendar.SIVAN)) {
                return asin + ": " + "13-14";
            }
            if ((day == 25 && month == JewishCalendar.TISHREI) ||
                    (day == 24 && month == JewishCalendar.SHEVAT) ||
                    (day == 24 && month == JewishCalendar.SIVAN)) {
                return arurin;
            }
            if ((day == 26 && month == JewishCalendar.TISHREI) ||
                    (day == 25 && month == JewishCalendar.SHEVAT) ||
                    (day == 25 && month == JewishCalendar.SIVAN)) {
                return hilchosLH + ": " + "1.1-1.2";
            }
            if ((day == 27 && month == JewishCalendar.TISHREI) ||
                    (day == 26 && month == JewishCalendar.SHEVAT) ||
                    (day == 26 && month == JewishCalendar.SIVAN)) {
                return hilchosLH + ": " + "1.3-1.4";
            }
            if ((day == 28 && month == JewishCalendar.TISHREI) ||
                    (day == 27 && month == JewishCalendar.SHEVAT) ||
                    (day == 27 && month == JewishCalendar.SIVAN)) {
                return hilchosLH + ": " + "1.5-1.6";
            }
            if ((day == 29 && month == JewishCalendar.TISHREI) ||
                    (day == 28 && month == JewishCalendar.SHEVAT) ||
                    (day == 28 && month == JewishCalendar.SIVAN)) {
                return hilchosLH + ": " + "1.7-1.9";
            }
            if ((day == 30 && month == JewishCalendar.TISHREI) ||
                    (day == 29 && month == JewishCalendar.SHEVAT) ||
                    (day == 29 && month == JewishCalendar.SIVAN)) {
                return hilchosLH + ": " + "2.1-2.2";
            }
            if ((day == 1 && month == JewishCalendar.CHESHVAN) ||
                    (day == 30 && month == JewishCalendar.SHEVAT) ||
                    (day == 30 && month == JewishCalendar.SIVAN)) {
                return hilchosLH + ": " + "2.3-2.4";
            }
            if ((day == 2 && month == JewishCalendar.CHESHVAN) ||
                    (day == 1 && month == JewishCalendar.ADAR_II) ||
                    (day == 1 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "2.5-2.6";
            }
            if ((day == 3 && month == JewishCalendar.CHESHVAN) ||
                    (day == 2 && month == JewishCalendar.ADAR_II) ||
                    (day == 2 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "2.7-2.8";
            }
            if ((day == 4 && month == JewishCalendar.CHESHVAN) ||
                    (day == 3 && month == JewishCalendar.ADAR_II) ||
                    (day == 3 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "2.9-2.10";
            }
            if ((day == 5 && month == JewishCalendar.CHESHVAN) ||
                    (day == 4 && month == JewishCalendar.ADAR_II) ||
                    (day == 4 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "2.11";
            }
            if ((day == 6 && month == JewishCalendar.CHESHVAN) ||
                    (day == 5 && month == JewishCalendar.ADAR_II) ||
                    (day == 5 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "2.12-2.13";
            }
            if ((day == 7 && month == JewishCalendar.CHESHVAN) ||
                    (day == 6 && month == JewishCalendar.ADAR_II) ||
                    (day == 6 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "3.1-3.2";
            }
            if ((day == 8 && month == JewishCalendar.CHESHVAN) ||
                    (day == 7 && month == JewishCalendar.ADAR_II) ||
                    (day == 7 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "3.3-3.4";
            }
            if ((day == 9 && month == JewishCalendar.CHESHVAN) ||
                    (day == 8 && month == JewishCalendar.ADAR_II) ||
                    (day == 8 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "3.5-3.6";
            }
            if ((day == 10 && month == JewishCalendar.CHESHVAN) ||
                    (day == 9 && month == JewishCalendar.ADAR_II) ||
                    (day == 9 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "3.7-3.8";
            }
            if ((day == 11 && month == JewishCalendar.CHESHVAN) ||
                    (day == 10 && month == JewishCalendar.ADAR_II) ||
                    (day == 10 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "4.1-4.2";
            }
            if ((day == 12 && month == JewishCalendar.CHESHVAN) ||
                    (day == 11 && month == JewishCalendar.ADAR_II) ||
                    (day == 11 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "4.3-4.4";
            }
            if ((day == 13 && month == JewishCalendar.CHESHVAN) ||
                    (day == 12 && month == JewishCalendar.ADAR_II) ||
                    (day == 12 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "4.5-4.6";
            }
            if ((day == 14 && month == JewishCalendar.CHESHVAN) ||
                    (day == 13 && month == JewishCalendar.ADAR_II) ||
                    (day == 13 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "4.7-4.8";
            }
            if ((day == 15 && month == JewishCalendar.CHESHVAN) ||
                    (day == 14 && month == JewishCalendar.ADAR_II) ||
                    (day == 14 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "4.9-4.10";
            }
            if ((day == 16 && month == JewishCalendar.CHESHVAN) ||
                    (day == 15 && month == JewishCalendar.ADAR_II) ||
                    (day == 15 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "4.11";
            }
            if ((day == 17 && month == JewishCalendar.CHESHVAN) ||
                    (day == 16 && month == JewishCalendar.ADAR_II) ||
                    (day == 16 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "4.12-5.1";
            }
            if ((day == 18 && month == JewishCalendar.CHESHVAN) ||
                    (day == 17 && month == JewishCalendar.ADAR_II) ||
                    (day == 17 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "5.2-5.4";
            }
            if ((day == 19 && month == JewishCalendar.CHESHVAN) ||
                    (day == 18 && month == JewishCalendar.ADAR_II) ||
                    (day == 18 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "5.5-5.6";
            }
            if ((day == 20 && month == JewishCalendar.CHESHVAN) ||
                    (day == 19 && month == JewishCalendar.ADAR_II) ||
                    (day == 19 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "5.7-5.8";
            }
            if ((day == 21 && month == JewishCalendar.CHESHVAN) ||
                    (day == 20 && month == JewishCalendar.ADAR_II) ||
                    (day == 20 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "6.1-6.2";
            }
            if ((day == 22 && month == JewishCalendar.CHESHVAN) ||
                    (day == 21 && month == JewishCalendar.ADAR_II) ||
                    (day == 21 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "6.3-6.4";
            }
            if ((day == 23 && month == JewishCalendar.CHESHVAN) ||
                    (day == 22 && month == JewishCalendar.ADAR_II) ||
                    (day == 22 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "6.5-6.6";
            }
            if ((day == 24 && month == JewishCalendar.CHESHVAN) ||
                    (day == 23 && month == JewishCalendar.ADAR_II) ||
                    (day == 23 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "6.7-6.8";
            }
            if ((day == 25 && month == JewishCalendar.CHESHVAN) ||
                    (day == 24 && month == JewishCalendar.ADAR_II) ||
                    (day == 24 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "6.9-6.10";
            }
            if ((day == 26 && month == JewishCalendar.CHESHVAN) ||
                    (day == 25 && month == JewishCalendar.ADAR_II) ||
                    (day == 25 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "6.11-6.12";
            }
            if ((day == 27 && month == JewishCalendar.CHESHVAN) ||
                    (day == 26 && month == JewishCalendar.ADAR_II) ||
                    (day == 26 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "7.1-7.2";
            }
            if ((day == 28 && month == JewishCalendar.CHESHVAN) ||
                    (day == 27 && month == JewishCalendar.ADAR_II) ||
                    (day == 27 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "7.3-7.4";
            }
            if ((day == 29 && month == JewishCalendar.CHESHVAN) ||
                    (day == 28 && month == JewishCalendar.ADAR_II) ||
                    (day == 28 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "7.5-7.6";
            }
            if ((day == 30 && month == JewishCalendar.CHESHVAN) ||
                    (day == 29 && month == JewishCalendar.ADAR_II) ||
                    (day == 29 && month == JewishCalendar.TAMMUZ)) {
                return hilchosLH + ": " + "7.7-7.8";
            }
            if ((day == 1 && month == JewishCalendar.KISLEV) ||
                    (day == 1 && month == JewishCalendar.NISSAN) ||
                    (day == 1 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "7.9";
            }
            if ((day == 2 && month == JewishCalendar.KISLEV) ||
                    (day == 2 && month == JewishCalendar.NISSAN) ||
                    (day == 2 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "7.10-7.12";
            }
            if ((day == 3 && month == JewishCalendar.KISLEV) ||
                    (day == 3 && month == JewishCalendar.NISSAN) ||
                    (day == 3 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "7.13-7.14";
            }
            if ((day == 4 && month == JewishCalendar.KISLEV) ||
                    (day == 4 && month == JewishCalendar.NISSAN) ||
                    (day == 4 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "8.1-8.2";
            }
            if ((day == 5 && month == JewishCalendar.KISLEV) ||
                    (day == 5 && month == JewishCalendar.NISSAN) ||
                    (day == 5 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "8.3-8.4";
            }
            if ((day == 6 && month == JewishCalendar.KISLEV) ||
                    (day == 6 && month == JewishCalendar.NISSAN) ||
                    (day == 6 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "8.5-8.7";
            }
            if ((day == 7 && month == JewishCalendar.KISLEV) ||
                    (day == 7 && month == JewishCalendar.NISSAN) ||
                    (day == 7 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "8.8-8.9";
            }
            if ((day == 8 && month == JewishCalendar.KISLEV) ||
                    (day == 8 && month == JewishCalendar.NISSAN) ||
                    (day == 8 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "8.10-8.11";
            }
            if ((day == 9 && month == JewishCalendar.KISLEV) ||
                    (day == 9 && month == JewishCalendar.NISSAN) ||
                    (day == 9 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "8.12";
            }
            if ((day == 10 && month == JewishCalendar.KISLEV) ||
                    (day == 10 && month == JewishCalendar.NISSAN) ||
                    (day == 10 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "8.13-8.14";
            }
            if ((day == 11 && month == JewishCalendar.KISLEV) ||
                    (day == 11 && month == JewishCalendar.NISSAN) ||
                    (day == 11 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "9.1-9.2";
            }
            if ((day == 12 && month == JewishCalendar.KISLEV) ||
                    (day == 12 && month == JewishCalendar.NISSAN) ||
                    (day == 12 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "9.3-9.4";
            }
            if ((day == 13 && month == JewishCalendar.KISLEV) ||
                    (day == 13 && month == JewishCalendar.NISSAN) ||
                    (day == 13 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "9.5-9.6";
            }
            if ((day == 14 && month == JewishCalendar.KISLEV) ||
                    (day == 14 && month == JewishCalendar.NISSAN) ||
                    (day == 14 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "10.1-10.2";
            }
            if ((day == 15 && month == JewishCalendar.KISLEV) ||
                    (day == 15 && month == JewishCalendar.NISSAN) ||
                    (day == 15 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "10.3-10.4";
            }
            if ((day == 16 && month == JewishCalendar.KISLEV) ||
                    (day == 16 && month == JewishCalendar.NISSAN) ||
                    (day == 16 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "10.5-10.6";
            }
            if ((day == 17 && month == JewishCalendar.KISLEV) ||
                    (day == 17 && month == JewishCalendar.NISSAN) ||
                    (day == 17 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "10.7-10.8";
            }
            if ((day == 18 && month == JewishCalendar.KISLEV) ||
                    (day == 18 && month == JewishCalendar.NISSAN) ||
                    (day == 18 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "10.9-10.10";
            }
            if ((day == 19 && month == JewishCalendar.KISLEV) ||
                    (day == 19 && month == JewishCalendar.NISSAN) ||
                    (day == 19 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "10.11-10.12";
            }
            if ((day == 20 && month == JewishCalendar.KISLEV) ||
                    (day == 20 && month == JewishCalendar.NISSAN) ||
                    (day == 20 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "10.13-10.14";
            }
            if ((day == 21 && month == JewishCalendar.KISLEV) ||
                    (day == 21 && month == JewishCalendar.NISSAN) ||
                    (day == 21 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "10.15-10.16";
            }
            if ((day == 22 && month == JewishCalendar.KISLEV) ||
                    (day == 22 && month == JewishCalendar.NISSAN) ||
                    (day == 22 && month == JewishCalendar.AV)) {
                return hilchosLH + ": " + "10.17";
            }
            if ((day == 23 && month == JewishCalendar.KISLEV) ||
                    (day == 23 && month == JewishCalendar.NISSAN) ||
                    (day == 23 && month == JewishCalendar.AV)) {
                return hilchosRechilus + ": " + "1.1-1.3";
            }
            if ((day == 24 && month == JewishCalendar.KISLEV) ||
                    (day == 24 && month == JewishCalendar.NISSAN) ||
                    (day == 24 && month == JewishCalendar.AV)) {
                return hilchosRechilus + ": " + "1.4-1.5";
            }
            if ((day == 25 && month == JewishCalendar.KISLEV) ||
                    (day == 25 && month == JewishCalendar.NISSAN) ||
                    (day == 25 && month == JewishCalendar.AV)) {
                return hilchosRechilus + ": " + "1.6-1.7";
            }
            if ((day == 26 && month == JewishCalendar.KISLEV) ||
                    (day == 26 && month == JewishCalendar.NISSAN) ||
                    (day == 26 && month == JewishCalendar.AV)) {
                return hilchosRechilus + ": " + "1.8-1.9";
            }
            if ((day == 27 && month == JewishCalendar.KISLEV) ||
                    (day == 27 && month == JewishCalendar.NISSAN) ||
                    (day == 27 && month == JewishCalendar.AV)) {
                return hilchosRechilus + ": " + "1.10-1.11";
            }
            if ((day == 28 && month == JewishCalendar.KISLEV) ||
                    (day == 28 && month == JewishCalendar.NISSAN) ||
                    (day == 28 && month == JewishCalendar.AV)) {
                return hilchosRechilus + ": " + "2.1-2.2";
            }
            if ((day == 29 && month == JewishCalendar.KISLEV) ||
                    (day == 29 && month == JewishCalendar.NISSAN) ||
                    (day == 29 && month == JewishCalendar.AV)) {
                return hilchosRechilus + ": " + "2.3-2.4";
            }
            if ((day == 30 && month == JewishCalendar.KISLEV) ||
                    (day == 30 && month == JewishCalendar.NISSAN) ||
                    (day == 30 && month == JewishCalendar.AV)) {
                return hilchosRechilus + ": " + "3.1";
            }
            if ((day == 1 && month == JewishCalendar.TEVES) ||
                    (day == 1 && month == JewishCalendar.IYAR) ||
                    (day == 1 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "3.2-3.4";
            }
            if ((day == 2 && month == JewishCalendar.TEVES) ||
                    (day == 2 && month == JewishCalendar.IYAR) ||
                    (day == 2 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "4.1-4.3";
            }
            if ((day == 3 && month == JewishCalendar.TEVES) ||
                    (day == 3 && month == JewishCalendar.IYAR) ||
                    (day == 3 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "5.1-5.2";
            }
            if ((day == 4 && month == JewishCalendar.TEVES) ||
                    (day == 4 && month == JewishCalendar.IYAR) ||
                    (day == 4 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "5.3-5.4";
            }
            if ((day == 5 && month == JewishCalendar.TEVES) ||
                    (day == 5 && month == JewishCalendar.IYAR) ||
                    (day == 5 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "5.5";
            }
            if ((day == 6 && month == JewishCalendar.TEVES) ||
                    (day == 6 && month == JewishCalendar.IYAR) ||
                    (day == 6 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "5.6-5.7";
            }
            if ((day == 7 && month == JewishCalendar.TEVES) ||
                    (day == 7 && month == JewishCalendar.IYAR) ||
                    (day == 7 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "6.1-6.2";
            }
            if ((day == 8 && month == JewishCalendar.TEVES) ||
                    (day == 8 && month == JewishCalendar.IYAR) ||
                    (day == 8 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "6.3-6.4";
            }
            if ((day == 9 && month == JewishCalendar.TEVES) ||
                    (day == 9 && month == JewishCalendar.IYAR) ||
                    (day == 9 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "6.5-6.7";
            }
            if ((day == 10 && month == JewishCalendar.TEVES) ||
                    (day == 10 && month == JewishCalendar.IYAR) ||
                    (day == 10 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "6.8-6.10";
            }
            if ((day == 11 && month == JewishCalendar.TEVES) ||
                    (day == 11 && month == JewishCalendar.IYAR) ||
                    (day == 11 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "7.1";
            }
            if ((day == 12 && month == JewishCalendar.TEVES) ||
                    (day == 12 && month == JewishCalendar.IYAR) ||
                    (day == 12 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "7.2";
            }
            if ((day == 13 && month == JewishCalendar.TEVES) ||
                    (day == 13 && month == JewishCalendar.IYAR) ||
                    (day == 13 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "7.3-7.4";
            }
            if ((day == 14 && month == JewishCalendar.TEVES) ||
                    (day == 14 && month == JewishCalendar.IYAR) ||
                    (day == 14 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "7.5";
            }
            if ((day == 15 && month == JewishCalendar.TEVES) ||
                    (day == 15 && month == JewishCalendar.IYAR) ||
                    (day == 15 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "8.1-8.3";
            }
            if ((day == 16 && month == JewishCalendar.TEVES) ||
                    (day == 16 && month == JewishCalendar.IYAR) ||
                    (day == 16 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "8.4-8.5";
            }
            if ((day == 17 && month == JewishCalendar.TEVES) ||
                    (day == 17 && month == JewishCalendar.IYAR) ||
                    (day == 17 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "9.1-9.2";
            }
            if ((day == 18 && month == JewishCalendar.TEVES) ||
                    (day == 18 && month == JewishCalendar.IYAR) ||
                    (day == 18 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "9.3-9.4";
            }
            if ((day == 19 && month == JewishCalendar.TEVES) ||
                    (day == 19 && month == JewishCalendar.IYAR) ||
                    (day == 19 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "9.5-9.6";
            }
            if ((day == 20 && month == JewishCalendar.TEVES) ||
                    (day == 20 && month == JewishCalendar.IYAR) ||
                    (day == 20 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "9.7-9.9";
            }
            if ((day == 21 && month == JewishCalendar.TEVES) ||
                    (day == 21 && month == JewishCalendar.IYAR) ||
                    (day == 21 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "9.10";
            }
            if ((day == 22 && month == JewishCalendar.TEVES) ||
                    (day == 22 && month == JewishCalendar.IYAR) ||
                    (day == 22 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "9.11-9.12";
            }
            if ((day == 23 && month == JewishCalendar.TEVES) ||
                    (day == 23 && month == JewishCalendar.IYAR) ||
                    (day == 23 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "9.13";
            }
            if ((day == 24 && month == JewishCalendar.TEVES) ||
                    (day == 24 && month == JewishCalendar.IYAR) ||
                    (day == 24 && month == JewishCalendar.ELUL)) {
                return hilchosRechilus + ": " + "9.14-9.15";
            }
            if ((day == 25 && month == JewishCalendar.TEVES) ||
                    (day == 25 && month == JewishCalendar.IYAR) ||
                    (day == 25 && month == JewishCalendar.ELUL)) {
                return tziyurim + ": " + "1-3";
            }
            if ((day == 26 && month == JewishCalendar.TEVES) ||
                    (day == 26 && month == JewishCalendar.IYAR) ||
                    (day == 26 && month == JewishCalendar.ELUL)) {
                return tziyurim + ": " + "4-5";
            }
            if ((day == 27 && month == JewishCalendar.TEVES) ||
                    (day == 27 && month == JewishCalendar.IYAR) ||
                    (day == 27 && month == JewishCalendar.ELUL)) {
                return tziyurim + ": " + "6-7";
            }
            if ((day == 28 && month == JewishCalendar.TEVES) ||
                    (day == 28 && month == JewishCalendar.IYAR) ||
                    (day == 28 && month == JewishCalendar.ELUL)) {
                return tziyurim + ": " + "8-9";
            }
            if ((day == 29 && month == JewishCalendar.TEVES) ||
                    (day == 29 && month == JewishCalendar.IYAR) ||
                    (day == 29 && month == JewishCalendar.ELUL)) {
                return tziyurim + ": " + "10-11";
            }
        }
        return "";
    }
    
}
