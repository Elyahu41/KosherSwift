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
        jewishCalendar.setUseModernHolidays(useModernHolidays: true)
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
    
    func testGregorianDateChangeWithTimzone() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        var comp = DateComponents()
        comp.setValue(2023, for: .year)
        comp.setValue(12, for: .month)
        comp.setValue(24, for: .day)
        jewishCalendar.workingDate = calendar.date(from: comp)!
        jewishCalendar.timeZone = TimeZone(identifier: "America/New_York")!
        XCTAssertEqual(jewishCalendar.getGregorianYear(), 2023)
        XCTAssertEqual(jewishCalendar.getGregorianMonth(), 12)
        XCTAssertEqual(jewishCalendar.getGregorianDayOfMonth(), 24)
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
    
    func testTefilaRules() {
        jewishCalendar.setJewishDate(year: 5784, month: JewishCalendar.NISSAN, dayOfMonth: 14)
        XCTAssertEqual(TefilaRules().isVeseinBerachaRecited(jewishCalendar: jewishCalendar), false)
        
        jewishCalendar.setJewishDate(year: 5784, month: JewishCalendar.NISSAN, dayOfMonth: 15)
        XCTAssertEqual(TefilaRules().isVeseinBerachaRecited(jewishCalendar: jewishCalendar), true)
        
        jewishCalendar.setGregorianDate(year: 2023, month: 12, dayOfMonth: 5)
        XCTAssertEqual(TefilaRules().isVeseinTalUmatarRecited(jewishCalendar: jewishCalendar), false)
        
        jewishCalendar.setGregorianDate(year: 2023, month: 12, dayOfMonth: 6)
        XCTAssertEqual(TefilaRules().isVeseinTalUmatarRecited(jewishCalendar: jewishCalendar), true)
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
        let moladFromKosherJava = Date(timeIntervalSince1970: 1702402813.5039999)
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
    
    func testTekufa() {
        jewishCalendar.setGregorianDate(year: 2025, month: 4, dayOfMonth: 8)//the day this test was made
        let tekufa = jewishCalendar.getTekufaAsDate()
        let tekufaActualDate = Date(timeIntervalSince1970: 1744041600.0)
        XCTAssertEqual(tekufa, tekufaActualDate)
    }
    
    func testDaysSinceStartOfJewishYearCheshvan() {
        jewishCalendar.setGregorianDate(year: 2026, month: 11, dayOfMonth: 3)//the day this test was made
        let days = jewishCalendar.getDaysSinceStartOfJewishYear()
        XCTAssertEqual(days, 53)
    }
    
    func testDaysSinceStartOfJewishYearElul() {
        jewishCalendar.setGregorianDate(year: 2027, month: 9, dayOfMonth: 25)
        let days = jewishCalendar.getDaysSinceStartOfJewishYear()
        XCTAssertEqual(days, 379)
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
        XCTAssertEqual(hebrewDateFormatter.formatParshah(jewishCalendar: jewishCalendar), "Vayigash")
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
    
    func testRhumbLineBearing() {
        let denver = GeoLocation(locationName: "Denver", latitude: 39.6272082, longitude: -104.8800718, timeZone: TimeZone.current)
        let jer = GeoLocation(locationName: "Jerusalem", latitude: 31.778015, longitude: 35.235413, timeZone: TimeZone.current)

        let bearing = denver.getRhumbLineBearing(location: jer)        
        XCTAssertEqual(bearing, 93.95254891601921, accuracy: 1e-12) // KosherJava's values
        XCTAssertEqual(denver.getRhumbLineDistance(location: jer), 1.2676113714176698E7, accuracy: 1e-6)
    }
    
    func testGeodiscBearing() {
        let denver = GeoLocation(locationName: "Denver", latitude: 39.6272082, longitude: -104.8800718, timeZone: TimeZone.current)
        let jer = GeoLocation(locationName: "Jerusalem", latitude: 31.778015, longitude: 35.235413, timeZone: TimeZone.current)

        let bearingInit = denver.getGeodesicInitialBearing(location: jer)
        let bearingFinal = denver.getGeodesicFinalBearing(location: jer)
        XCTAssertEqual(bearingInit, 33.50820371562616, accuracy: 1e-12) // KosherJava's values
        XCTAssertEqual(bearingFinal, 149.97377985851242, accuracy: 1e-12)
        XCTAssertEqual(denver.getGeodesicDistance(location: jer), 1.1096260525658436E7, accuracy: 1e-6)
    }
    
    func testLocalMeanTimeOffset() {
        let denver = GeoLocation(locationName: "Denver", latitude: 39.6272082, longitude: -104.8800718, timeZone: TimeZone(identifier: "America/Denver")!)
        let jer = GeoLocation(locationName: "Jerusalem", latitude: 31.778015, longitude: 35.235413, timeZone: TimeZone(identifier: "Asia/Jerusalem")!)

        let testDate = Date(timeIntervalSince1970: 1785310117.780254)
        let denverLMT = denver.getLocalMeanTimeOffset(date: testDate)
        let jerLMT = jer.getLocalMeanTimeOffset(date: testDate)
        // in seconds, truncated to whole milliseconds like KosherJava's -3571217 and -2343500 milliseconds
        XCTAssertEqual(denverLMT, -3571.217)
        XCTAssertEqual(jerLMT, -2343.5)
    }
    
    func testDafYomis() {
        jewishCalendar.setGregorianDate(year: 2023, month: 12, dayOfMonth: 21)
        var dafYomi = jewishCalendar.getDafYomiBavli()
        var dafYomiYeru = jewishCalendar.getDafYomiYerushalmi()
        XCTAssertEqual(dafYomi?.getMasechta(), "בבא קמא")
        XCTAssertEqual(dafYomi?.getDaf(), 49)
        XCTAssertEqual(dafYomiYeru?.getYerushalmiMasechta(), "שבת")
        XCTAssertEqual(dafYomiYeru?.getDaf(), 8)
        
        jewishCalendar.setGregorianDate(year: 2024, month: 2, dayOfMonth: 4)
        dafYomi = jewishCalendar.getDafYomiBavli()
        dafYomiYeru = jewishCalendar.getDafYomiYerushalmi()
        XCTAssertEqual(dafYomi?.getMasechta(), "בבא קמא")
        XCTAssertEqual(dafYomi?.getDaf(), 94)
        XCTAssertEqual(dafYomiYeru?.getYerushalmiMasechta(), "שבת")
        XCTAssertEqual(dafYomiYeru?.getDaf(), 53)
        
        jewishCalendar.setGregorianDate(year: 2020, month: 6, dayOfMonth: 18)
        dafYomi = jewishCalendar.getDafYomiBavli()
        dafYomiYeru = jewishCalendar.getDafYomiYerushalmi()
        XCTAssertEqual(dafYomi?.getMasechta(), "שבת")
        XCTAssertEqual(dafYomi?.getDaf(), 104)
        XCTAssertEqual(dafYomiYeru?.getYerushalmiMasechta(), "יומא")
        XCTAssertEqual(dafYomiYeru?.getDaf(), 17)
    }
    
    /// The local time of a Date in a time zone, as "HH:mm:ss" plus the fraction of the second in nanoseconds.
    private func assertTime(_ date: Date?, _ year: Int, _ month: Int, _ day: Int, _ time: String, _ timeZone: TimeZone,
                            file: StaticString = #filePath, line: UInt = #line) {
        guard let date = date else {
            XCTFail("nil time", file: file, line: line)
            return
        }
        let parts = time.split(separator: ":")
        let seconds = Double(parts[2])!
        let expected = LocalDate(year: year, month: month, day: day)
            .atTime(seconds: Double(Int(parts[0])! * 3600 + Int(parts[1])! * 60) + seconds, timeZone: timeZone)
        XCTAssertEqual(date.timeIntervalSince1970, expected.timeIntervalSince1970, accuracy: 1e-6, file: file, line: line)
    }

    func testCalculatorSunrise() throws {
        // the expected values are KosherJava's
        let newYork = TimeZone(identifier: "America/New_York")!
        let geoLocation = GeoLocation(locationName: "", latitude: 40.08213, longitude: -74.20970, timeZone: newYork)
        let calendar = AstronomicalCalendar(geoLocation: geoLocation)
        calendar.setAstronomicalCalculator(astronomicalCalculator: NOAACalculator())
        calendar.setLocalDate(localDate: LocalDate(year: 2023, month: 1, day: 1))
        assertTime(calendar.getSunrise(), 2023, 1, 1, "07:18:55.649376427", newYork)
        calendar.setLocalDate(localDate: LocalDate(year: 2023, month: 5, day: 1))
        assertTime(calendar.getSunrise(), 2023, 5, 1, "05:57:00.265101273", newYork)
        calendar.setLocalDate(localDate: LocalDate(year: 2023, month: 8, day: 1))
        assertTime(calendar.getSunrise(), 2023, 8, 1, "05:54:52.779346857", newYork)
        // setting a Date still works: the calendar uses the day it falls on in the location's time zone
        var gregorianCalendar = Calendar(identifier: .gregorian)
        gregorianCalendar.timeZone = newYork
        calendar.workingDate = gregorianCalendar.date(from: DateComponents(year: 2023, month: 12, day: 1, hour: 23, minute: 30))!
        XCTAssertEqual(calendar.getLocalDate(), LocalDate(year: 2023, month: 12, day: 1))
        assertTime(calendar.getSunrise(), 2023, 12, 1, "06:59:28.096772523", newYork)
    }
    
    func testCalculatorSunset() throws {
        // the expected values are KosherJava's
        let newYork = TimeZone(identifier: "America/New_York")!
        let geoLocation = GeoLocation(locationName: "", latitude: 40.08213, longitude: -74.20970, timeZone: newYork)
        let calendar = AstronomicalCalendar(geoLocation: geoLocation)
        for (month, time) in [(1, "16:41:58.561719738"), (5, "19:51:32.778739961"), (8, "20:10:55.706244291"), (12, "16:31:58.078986594")] {
            calendar.setLocalDate(localDate: LocalDate(year: 2023, month: month, day: 1))
            assertTime(calendar.getSunset(), 2023, month, 1, time, newYork)
        }
    }
    
    func testZmanimCalendar() {
        // the expected values are KosherJava's
        let newYork = TimeZone(identifier: "America/New_York")!
        let calendar = ZmanimCalendar(geoLocation: GeoLocation(locationName: "", latitude: 40.08213, longitude: -74.20970, timeZone: newYork))
        for (year, month, day, time) in [(2023, 12, 24, "06:04:40.499647789"), (2023, 5, 1, "04:45:00.265101273"),
                                         (2024, 8, 1, "04:43:35.214353737"), (2024, 12, 1, "05:48:13.626684808")] {
            calendar.setLocalDate(localDate: LocalDate(year: year, month: month, day: day))
            assertTime(calendar.getAlos72Minutes(), year, month, day, time, newYork)
        }
    }
    
    func testNilZman() {
        let geoLocation = GeoLocation(locationName: "NY", latitude: 40.73114, longitude: -73.79993, timeZone: TimeZone(identifier: "America/New_York")!)
        let calculator = ComprehensiveZmanimCalendar(geoLocation: geoLocation)
        calculator.setLocalDate(localDate: LocalDate(year: 2024, month: 6, day: 16))
        XCTAssertNil(calculator.getTzais26Degrees())
        XCTAssertNil(calculator.getShaahZmanis26Degrees())
        XCTAssertNotNil(calculator.getShaahZmanisGRA())
        // the chametz zmanim are only calculated on Erev Pesach
        XCTAssertNil(calculator.getSofZmanAchilasChametzGRA())
        calculator.setLocalDate(localDate: LocalDate(year: 2025, month: 4, day: 12)) // 14 Nissan 5785
        XCTAssertNotNil(calculator.getSofZmanAchilasChametzGRA())
        XCTAssertNotNil(calculator.getSofZmanBiurChametzGRA())
    }
    
    func testZmanim() {
        //let geoLocation = GeoLocation(locationName: "CO", latitude: 39.6240, longitude: -104.8709, timeZone: TimeZone.current)
        //let calculator = ComplexZmanimCalendar(location: geoLocation)
        //let format = DateFormatter()
        //format.timeStyle = .full
        //print(format.string(from: calculator.getTzais72ZmanisAmudeiHoraah()!))
        //print(format.string(from: calculator.getTzaisShabbatAmudeiHoraah()!))
        
        //let geoLocationFL = GeoLocation(locationName: "FL", latitude: 37.32495943, longitude: -122.01973712, timeZone: TimeZone(identifier: "America/New_York")!)
        //let calculatorFL = ComplexZmanimCalendar(location: geoLocation)

        //print(format.string(from: calculatorFL.getFixedLocalChatzos()!))
    }
    
    func testEquals() {
        let geoLocation1 = GeoLocation(locationName: "CO", latitude: 39.6240, longitude: -104.8709, timeZone: TimeZone.current)
        let geoLocation2 = GeoLocation(locationName: "CO", latitude: 39.6240, longitude: -104.8709, timeZone: TimeZone.current)
        
        XCTAssertEqual(geoLocation1, geoLocation2)
        XCTAssertTrue(geoLocation1.equals(geoLocation2))
    }
    
    func testHebrewDateFormatterMapsWithUpdatedValues() {
        let hdf = HebrewDateFormatter()
        XCTAssertEqual(hdf.hebrewParshaMap[JewishCalendar.Parshah.BERESHIS], "בראשית")
        
        hdf.hebrewParshaMap.updateValue("Changed", forKey: JewishCalendar.Parshah.BERESHIS)
        
        XCTAssertNotEqual(hdf.hebrewParshaMap[JewishCalendar.Parshah.BERESHIS], "בראשית")
        XCTAssertEqual(hdf.hebrewParshaMap[JewishCalendar.Parshah.BERESHIS], "Changed")
    }
    
    func testZmanimFormatter() {
        let formatter = ZmanimFormatter(timeZone: TimeZone(identifier: "America/New_York")!)
        let temporalHour: TimeInterval = 72.5 * 60
        XCTAssertEqual(formatter.format(duration: temporalHour), "1:12:30")
        formatter.setTimeFormat(format: ZmanimFormatter.SEXAGESIMAL_XSD_FORMAT)
        XCTAssertEqual(formatter.format(duration: temporalHour), "01:12:30.000")
        formatter.setTimeFormat(format: ZmanimFormatter.XSD_DURATION_FORMAT)
        XCTAssertEqual(formatter.format(duration: temporalHour), "PT1H12M30S")
        XCTAssertEqual(formatter.formatDate(date: Date(timeIntervalSince1970: 0)), "7:00:00")
        XCTAssertEqual(formatter.formatXSDateTime(date: Date(timeIntervalSince1970: 0)), "1969-12-31T19:00:00-05:00")
        XCTAssertEqual(ZmanimFormatter(timeZone: TimeZone(identifier: "UTC")!).formatXSDateTime(date: Date(timeIntervalSince1970: 0)),
                       "1970-01-01T00:00:00Z")
    }
    
    func testCandleLightingIsNeverBeforePlagHamincha() {
        // on a very short day near the Arctic Circle, 18 minutes before sunset is before plag hamincha
        let oslo = TimeZone(identifier: "Europe/Oslo")!
        let calendar = ZmanimCalendar(location: GeoLocation(locationName: "Bodo area", latitude: 66.2, longitude: 14.4, timeZone: oslo))
        calendar.setLocalDate(localDate: LocalDate(year: 2026, month: 12, day: 21))
        let plag = calendar.getPlagHaminchaGRA()!
        let sunsetMinusOffset = calendar.getSeaLevelSunset()!.addingTimeInterval(-Double(calendar.getCandleLightingOffset()) * 60)
        XCTAssertLessThan(sunsetMinusOffset, plag, "precondition: the test day must be short enough")
        XCTAssertEqual(calendar.getCandleLighting(), plag)

        // on a normal day it is still the offset before sea level sunset
        let newYork = TimeZone(identifier: "America/New_York")!
        let lakewood = ZmanimCalendar(location: GeoLocation(locationName: "Lakewood", latitude: 40.0828, longitude: -74.2094, timeZone: newYork))
        lakewood.setLocalDate(localDate: LocalDate(year: 2026, month: 12, day: 21))
        XCTAssertEqual(lakewood.getCandleLighting(), lakewood.getSeaLevelSunset()!.addingTimeInterval(-Double(lakewood.getCandleLightingOffset()) * 60))
    }

    func testXSDDurationEdgeCases() {
        let formatter = ZmanimFormatter(timeZone: TimeZone(identifier: "America/New_York")!)
        XCTAssertEqual(formatter.formatXSDDurationTime(duration: 90 * 60), "PT1H30M")
        XCTAssertEqual(formatter.formatXSDDurationTime(duration: -(75 * 60 + 3)), "-PT1H15M3S")
        XCTAssertEqual(formatter.formatXSDDurationTime(duration: -0.4), "-PT0.4S") // KosherJava writes the invalid PT-0.4S
        XCTAssertEqual(formatter.formatXSDDurationTime(duration: 0), "PT0S")
        XCTAssertEqual(formatter.formatXSDDurationTime(duration: 3023.259), "PT50M23.259S")
        XCTAssertEqual(formatter.formatXSDDurationTime(duration: 0.000001), "PT0.000001S")
        XCTAssertEqual(formatter.formatXSDDurationTime(duration: nil), "")
        XCTAssertEqual(formatter.formatXSDDurationTime(duration: .nan), "")
        XCTAssertEqual(formatter.formatXSDDurationTime(duration: .infinity), "")
        XCTAssertEqual(formatter.format(duration: .nan), "0:00:00")
        XCTAssertEqual(formatter.format(duration: -90), "-0:01:30")
    }
    
    func testHebrewNumbersAbove9999() {
        let formatter = HebrewDateFormatter()
        XCTAssertEqual(formatter.formatHebrewNumber(number: 5000), "ה׳ אלפים")
        XCTAssertEqual(formatter.formatHebrewNumber(number: 5786), "תשפ״ו")
        XCTAssertEqual(formatter.formatHebrewNumber(number: 10_000), "י׳ אלפים")
        XCTAssertEqual(formatter.formatHebrewNumber(number: 12_345), "שמ״ה")
        formatter.useLonghebrewYears = true
        XCTAssertEqual(formatter.formatHebrewNumber(number: 5786), "ה׳ תשפ״ו")
        XCTAssertEqual(formatter.formatHebrewNumber(number: 9999), "ט׳ תתקצ״ט")
        XCTAssertEqual(formatter.formatHebrewNumber(number: 12_345), "יב׳ שמ״ה")
        XCTAssertEqual(formatter.formatHebrewNumber(number: 15_001), "טו׳ א׳")
        XCTAssertEqual(formatter.formatHebrewNumber(number: 999_999), "תתקצט׳ תתקצ״ט")
        XCTAssertEqual(formatter.formatHebrewNumber(number: 1_000_000), "numbers > 999,999 can't be formatted")
    }

    func testZmanClass() {
        let date = Date()
        let zman = Zman(zman: date, label: "Sunrise")
        XCTAssertEqual(zman.label, "Sunrise")
        XCTAssertEqual(zman.zman, date)
        XCTAssertNil(zman.duration)
        XCTAssertNil(zman.description)

        let zmanAsDur = Zman(duration: 3600, label: "Shaah Zmanis")
        XCTAssertEqual(zmanAsDur.label, "Shaah Zmanis")
        XCTAssertNil(zmanAsDur.zman)
        XCTAssertEqual(zmanAsDur.duration, 3600)
        XCTAssertNotEqual(zman, zmanAsDur)

        let early = Date()
        let later = early.addingTimeInterval(3600)
        let z1 = Zman(zman: later, label: "Later")
        let z2 = Zman(zman: early, label: "Earlier")
        let sorted = [z1, z2, zmanAsDur].sorted(by: Zman.dateOrder)
        XCTAssertEqual(sorted.map { $0.label }, ["Earlier", "Later", "Shaah Zmanis"])
        XCTAssertEqual([z1, z2, zmanAsDur].sorted(by: Zman.nameOrder).map { $0.label }, ["Earlier", "Later", "Shaah Zmanis"])
        XCTAssertEqual([z1, z2, zmanAsDur].sorted(by: Zman.durationOrder).map { $0.label }, ["Shaah Zmanis", "Earlier", "Later"])

        let geo = GeoLocation(locationName: "Lakewood & <NJ>", latitude: 40.0828, longitude: -74.2094, timeZone: TimeZone(identifier: "America/New_York")!)
        let xml = Zman(zman: Date(timeIntervalSince1970: 0), geoLocation: geo, label: "A & B").toXML()
        XCTAssertTrue(xml.contains("<Label>A &amp; B</Label>"))
        XCTAssertTrue(xml.contains("<Zman>1969-12-31T19:00:00.000</Zman>"))
        XCTAssertTrue(xml.contains("<LocationName>Lakewood &amp; &lt;NJ&gt;</LocationName>"))
    }
    
    func testMishnaYomiClass() {
        jewishCalendar.timeZone = .init(identifier: "America/New_York")!
        jewishCalendar.setGregorianDate(year: 2026, month: 1, dayOfMonth: 1)
        XCTAssertEqual(MishnaYomi().getMishnaYomi(jewishCalendar: jewishCalendar, useHebrewText: false)!, "Bechorot 9:5-6")
    }
    
    func testDailyHalachaClass() {
        let date = Date(timeIntervalSince1970: 1780353891.3084102)
        let array = HalachaYomi.getDailyLearning(date: date)
        XCTAssertEqual(array![0].bookName, "שו\"ע - או\"ח")
        XCTAssertEqual(array![0].siman, 202)
        XCTAssertEqual(array![0].seifim, "יג-טו")
    }
    
    func testChafetzChaimClass() {
        jewishCalendar.setGregorianDate(year: 2026, month: JewishCalendar.AV, dayOfMonth: 5)
        let string = ChafetzChayimYomi.getChafetzChayimYomi(jewishCalendar: jewishCalendar)
        XCTAssertEqual(string, "הלכות ל\"ה: 10.13")
    }

    func testWarningsAreReportedInsteadOfCrashing() {
        var warnings: [KosherSwiftWarnings.Warning] = []
        let original = KosherSwiftWarnings.handler
        KosherSwiftWarnings.handler = { warnings.append($0) }
        defer { KosherSwiftWarnings.handler = original }

        let geo = GeoLocation(locationName: "Lakewood", latitude: 40.0828, longitude: -74.2094, timeZone: TimeZone(identifier: "America/New_York")!)
        geo.setLatitude(latitude: 91)
        XCTAssertEqual(geo.getLatitude(), 40.0828)
        XCTAssertEqual(warnings.last?.function, "setLatitude(latitude:)")
        XCTAssertTrue(warnings.last!.message.contains("91"))
        geo.setHorizonElevationAtSunset(horizonElevationAtSunset: -5)
        XCTAssertEqual(geo.getHorizonElevationAtSunset(), 0)
        XCTAssertEqual(warnings.last?.function, "setHorizonElevationAtSunset(horizonElevationAtSunset:)")
        XCTAssertTrue(NOAACalculator().getTimeAtAzimuth(localDate: LocalDate(year: 2026, month: 1, day: 1), geoLocation: geo, azimuth: 45).isNaN)
        XCTAssertEqual(warnings.count, 3)

        KosherSwiftWarnings.handler = nil // silenced
        geo.setLongitude(longitude: 200)
        XCTAssertEqual(warnings.count, 3)
    }
    
    //    func testPerformanceExample() throws {
    //        // This is an example of a performance test case.
    //        self.measure {
    //            // Put the code you want to measure the time of here.
    //        }
    //    }
}
