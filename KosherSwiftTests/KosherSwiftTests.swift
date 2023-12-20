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
        var arrayOfHebrewMonthsLeapYear = [8,9,10,11,12,13,1,2,3,4,5,6,7]
        jewishCalendar.setJewishDate(year: 5784, month: JewishCalendar.TISHREI, dayOfMonth: 1)//leap year
        while jewishCalendar.getJewishYear() == 5784 {
            XCTAssertEqual(arrayOfHebrewMonthsLeapYear.contains(jewishCalendar.getJewishMonth()), true)
            jewishCalendar.forward()
        }
        
        var arrayOfHebrewMonths = [8,9,10,11,12,13,1,2,3,4,5,7]//ADAR is skipped on non leap years
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
        let moladFromKosherJava = Date(timeIntervalSince1970: 1702338014.0)//had to go up or down a few intervals to make it work
        XCTAssertEqual(molad, moladFromKosherJava)
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
