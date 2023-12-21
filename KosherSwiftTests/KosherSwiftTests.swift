//
//  KosherSwiftTests.swift
//  KosherSwiftTests
//
//  Created by User on 12/19/23.
//

import XCTest
@testable import KosherSwift

class KosherSwiftTests: XCTestCase {
    
    var jewishCalendar = JewishCalendar()

    override func setUpWithError() throws {
        jewishCalendar.setUseModernHolidays(bool: true)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        jewishCalendar = JewishCalendar()
    }

    func testBoolsBeingSet() throws {
        XCTAssertEqual(jewishCalendar.useModernHolidays, true)
        XCTAssertEqual(jewishCalendar.isUseModernHolidays(), true)
    }
    
    func testGregorianDateChange() {
        jewishCalendar.setGregorianDate(year: 2023, month: 9, dayOfMonth: 25)
        XCTAssertEqual(jewishCalendar.getGregorianYear(), 2023)
        XCTAssertEqual(jewishCalendar.getGregorianMonth(), 9)
        XCTAssertEqual(jewishCalendar.getGregorianDayOfMonth(), 25)
    }
    
    func testHebrewDateChange() {
        jewishCalendar.setJewishDate(year: 5784, month: JewishCalendar.TEVES, dayOfMonth: 5)
        XCTAssertEqual(jewishCalendar.getJewishYear(), 5784)
        XCTAssertEqual(jewishCalendar.getJewishMonth(), 4)
        XCTAssertEqual(jewishCalendar.getJewishDayOfMonth(), 5)
    }
    
    func testIsErevPesach() {
        jewishCalendar.setJewishDate(year: 5784, month: JewishCalendar.NISSAN, dayOfMonth: 14)
        XCTAssertEqual(jewishCalendar.getYomTovIndex(), JewishCalendar.EREV_PESACH)
    }
    
    func testIsPesach() {
        jewishCalendar.setJewishDate(year: 5784, month: JewishCalendar.NISSAN, dayOfMonth: 15)
        XCTAssertEqual(jewishCalendar.isPesach(), true)
    }
    
    func testInternalHebrewCalendarMonths() {
        let arrayOfHebrewMonthsLeapYear = [8,9,10,11,12,13,1,2,3,4,5,6,7]
        jewishCalendar.setJewishDate(year: 5784, month: JewishCalendar.TISHREI, dayOfMonth: 1)//leap year
        while jewishCalendar.getJewishYear() == 5784 {
            XCTAssertEqual(arrayOfHebrewMonthsLeapYear.contains(jewishCalendar.getJewishMonth()), true)
            jewishCalendar.forward()
        }
        
        let arrayOfHebrewMonths = [8,9,10,11,12,13,1,2,3,4,5,7]//ADAR is skipped on non leap years
        jewishCalendar.setJewishDate(year: 5783, month: JewishCalendar.TISHREI, dayOfMonth: 1)
        while jewishCalendar.getJewishYear() == 5783 {
            XCTAssertEqual(arrayOfHebrewMonths.contains(jewishCalendar.getJewishMonth()), true)
            jewishCalendar.forward()
        }
    }
    
    func testAdarInNonLeapYears() {
        jewishCalendar.setJewishDate(year: 5783, month: JewishCalendar.ADAR, dayOfMonth: 1)
        XCTAssertEqual(jewishCalendar.getJewishMonth(), 7)
        //Test will return 7 even though adar is 6 since adar II is used instead on non leap years
    }
    
    func testMolad() {
        jewishCalendar.setGregorianDate(year: 2023, month: 12, dayOfMonth: 20)//the day this test was made
        let molad = jewishCalendar.getMoladAsDate()
        let moladFromKosherJava = Date(timeIntervalSince1970: 1702402813.0)//had to go up or down a few intervals to make it work
        XCTAssertEqual(molad, moladFromKosherJava)
        XCTAssertEqual(jewishCalendar.getMoladAsString(), "The molad is at 20 hours, 1 minutes and 3 Chalakim")
    }
    
    func testDayOfWeek() {
        jewishCalendar.setGregorianDate(year: 2023, month: 12, dayOfMonth: 20)//the day this test was made
        XCTAssertEqual(jewishCalendar.getDayOfWeek(), 4)
    }
    
    func testParasha() {
        jewishCalendar.setGregorianDate(year: 2023, month: 12, dayOfMonth: 20)//the day this test was made
        XCTAssertEqual(jewishCalendar.getParshah(), .NONE)
        
        jewishCalendar.setGregorianDate(year: 2023, month: 12, dayOfMonth: 23)//shabbat
        XCTAssertEqual(jewishCalendar.getParshah(), .VAYIGASH)
        
        jewishCalendar.setGregorianDate(year: 2023, month: 12, dayOfMonth: 30)//shabbat
        XCTAssertEqual(jewishCalendar.getParshah(), .VAYECHI)
    }
    
    func testToString() {
        //leap year
        jewishCalendar.setJewishDate(year: 5784, month: JewishCalendar.TISHREI, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Tishrei, 5784")
        jewishCalendar.setJewishDate(year: 5784, month: JewishCalendar.CHESHVAN, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Cheshvan, 5784")
        jewishCalendar.setJewishDate(year: 5784, month: JewishCalendar.KISLEV, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Kislev, 5784")
        jewishCalendar.setJewishDate(year: 5784, month: JewishCalendar.TEVES, dayOfMonth: 8)//the day this test was made
        XCTAssertEqual(jewishCalendar.toString(), "8 Teves, 5784")
        jewishCalendar.setJewishDate(year: 5784, month: JewishCalendar.SHEVAT, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Shevat, 5784")
        jewishCalendar.setJewishDate(year: 5784, month: JewishCalendar.ADAR, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Adar I, 5784")
        jewishCalendar.setJewishDate(year: 5784, month: JewishCalendar.ADAR_II, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Adar II, 5784")
        jewishCalendar.setJewishDate(year: 5784, month: JewishCalendar.NISSAN, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Nissan, 5784")
        jewishCalendar.setJewishDate(year: 5784, month: JewishCalendar.SIVAN, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Sivan, 5784")
        jewishCalendar.setJewishDate(year: 5784, month: JewishCalendar.IYAR, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Iyar, 5784")
        jewishCalendar.setJewishDate(year: 5784, month: JewishCalendar.TAMMUZ, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Tammuz, 5784")
        jewishCalendar.setJewishDate(year: 5784, month: JewishCalendar.AV, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Av, 5784")
        jewishCalendar.setJewishDate(year: 5784, month: JewishCalendar.ELUL, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Elul, 5784")
        
        //non leap year
        jewishCalendar.setJewishDate(year: 5783, month: JewishCalendar.TISHREI, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Tishrei, 5783")
        jewishCalendar.setJewishDate(year: 5783, month: JewishCalendar.CHESHVAN, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Cheshvan, 5783")
        jewishCalendar.setJewishDate(year: 5783, month: JewishCalendar.KISLEV, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Kislev, 5783")
        jewishCalendar.setJewishDate(year: 5783, month: JewishCalendar.TEVES, dayOfMonth: 8)//the day this test was made
        XCTAssertEqual(jewishCalendar.toString(), "8 Teves, 5783")
        jewishCalendar.setJewishDate(year: 5783, month: JewishCalendar.SHEVAT, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Shevat, 5783")
        jewishCalendar.setJewishDate(year: 5783, month: JewishCalendar.ADAR, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Adar, 5783")
        jewishCalendar.setJewishDate(year: 5783, month: JewishCalendar.ADAR_II, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Adar, 5783")
        jewishCalendar.setJewishDate(year: 5783, month: JewishCalendar.NISSAN, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Nissan, 5783")
        jewishCalendar.setJewishDate(year: 5783, month: JewishCalendar.SIVAN, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Sivan, 5783")
        jewishCalendar.setJewishDate(year: 5783, month: JewishCalendar.IYAR, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Iyar, 5783")
        jewishCalendar.setJewishDate(year: 5783, month: JewishCalendar.TAMMUZ, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Tammuz, 5783")
        jewishCalendar.setJewishDate(year: 5783, month: JewishCalendar.AV, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Av, 5783")
        jewishCalendar.setJewishDate(year: 5783, month: JewishCalendar.ELUL, dayOfMonth: 8)
        XCTAssertEqual(jewishCalendar.toString(), "8 Elul, 5783")
    }
    
    func testParshahString() {
        jewishCalendar.setGregorianDate(year: 2023, month: 12, dayOfMonth: 23)
        let hebrewDateFormatter = HebrewDateFormatter()
        XCTAssertEqual(hebrewDateFormatter.formatParsha(jewishCalendar: jewishCalendar), "Vayigash")
    }
    
    func testYomTovString() {
        jewishCalendar.setJewishDate(year: 5784, month: JewishCalendar.NISSAN, dayOfMonth: 15)
        let hebrewDateFormatter = HebrewDateFormatter()
        XCTAssertEqual(hebrewDateFormatter.formatYomTov(jewishCalendar: jewishCalendar), "Pesach")
    }
    
    func testLongWeekFormat() {
        jewishCalendar.setJewishDate(year: 5784, month: JewishCalendar.NISSAN, dayOfMonth: 15)
        let hebrewDateFormatter = HebrewDateFormatter()
        hebrewDateFormatter.setLongWeekFormat(longWeekFormat: true)
        XCTAssertEqual(hebrewDateFormatter.formatDayOfWeek(jewishCalendar: jewishCalendar), "Tuesday")
    }
    
    func testDafYomis() {
        jewishCalendar.setGregorianDate(year: 2023, month: 12, dayOfMonth: 21)
        let dafYomi = jewishCalendar.getDafYomiBavli()
        let dafYomiYeru = jewishCalendar.getDafYomiYerushalmi()
        XCTAssertEqual(dafYomi?.getMasechta(), "בבא קמא")
        XCTAssertEqual(dafYomi?.getDaf(), 49)
        XCTAssertEqual(dafYomiYeru?.getYerushalmiMasechta(), "שבת")
        XCTAssertEqual(dafYomiYeru?.getDaf(), 8)
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
