KosherSwift Zmanim API
=====================

This Zmanim library is an API for a specialized calendar that can calculate different astronomical
times including sunrise and sunset and Jewish _zmanim_ or religious times for prayers and other
Jewish religious duties.

For non religious astronomical / solar
calculations use the [AstronomicalCalendar](./Sources/KosherSwift/AstronomicalCalendar.swift).

The ZmanimCalendar contains the most common zmanim or religious time calculations. For a much more
extensive list of _zmanim_ use the ComplexZmanimCalendar.
This class contains the main functionality of the Zmanim library.

For a basic set of instructions on the use of the API, see [How to Use the Zmanim API](https://kosherjava.com/zmanim-project/how-to-use-the-zmanim-api/), [zmanim code samples](https://kosherjava.com/tag/code-sample/) and the [KosherJava FAQ](https://kosherjava.com/tag/faq/). See the <a href="https://kosherjava.com">KosherJava Zmanim site</a> for additional information.

# Get Started
Add KosherSwift as a dependency to your project:

Copy this line:
```
https://github.com/Elyahu41/KosherSwift.git
```
Go to [Package Dependencies](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app) in Xcode and search for this repository and add it!

If you want to use CocoaPods add this line to your podfile:
```ruby
pod "KosherSwiftNew"
```
KosherSwift was already taken on CocoaPods, hence the "New"

How To Use This API
-------
Once you have added this project, you can go to any file/viewcontroller and import the framework:
```Swift
import KosherSwift
```
If you used CocoaPods:
```Swift
import KosherSwiftNew
```
Then, it is as simple as instantiating a class and calling it's methods:
```Swift
let jewishCalendar = JewishCalendar() // by default it is set to today's date
print(jewishCalendar.getJewishMonth()) // This will print the jewish month as a number, so Nissan will be 8. See the JewishCalendar class for more details

// To check for holidays/yom tovs, you can use the built in methods of the jewish calendar:
if jewishCalendar.isPesach() {
print("Today is Passover!")
}
// or you can check it yourself with the getYomTovIndex() method just like in KosherJava:
if jewishCalendar.getYomTovIndex() == JewishCalendar.PESACH {
print("Today is Passover!")
}
```
For sunrise and sunset times, you will need a GeoLocation object. Then, you will need to pass that into the AstronomicalCalendar class like so:
```Swift
let geoLocation = GeoLocation(locationName: "Lakewood, NJ", latitude: 40.08213, longitude: -74.20970, timeZone: TimeZone(identifier: "America/New_York")!)
// The locationName string can be left empty if you'd like. There is also a constructor for elevation to be added.
// There are two Sunrise/Sunset calculators in this API, the NOAA Calculator and the SunTimes Calculator. By default, the NOAA calculator is used as it is more accurate than the SunTimes calculator as it takes into account leap years and other things.
let cal = AstronomicalCalendar(location: geoLocation)
// To use the SunTimesCalculator:
// cal.astronomicalCalculator = SunTimesCalculator()
let sunrise = cal.getSunrise() // This will return a nullable Date? object
```
For zmanim, you will do the same thing, just use the ComplexZmanimCalendar or ZmanimCalendar classes:
```Swift
let geoLocation = GeoLocation(locationName: "Lakewood, NJ", latitude: 40.08213, longitude: -74.20970, timeZone: TimeZone(identifier: "America/New_York")!)
let cal = ComplexZmanimCalendar(location: geoLocation)
let sofZmanShmaGra = cal.getSofZmanShmaGRA() // This will return a nullable Date? object
```
If you want to calculate a zman for a certain date:
```Swift
var gregorianCalendar = Calendar(identifier: .gregorian)
gregorianCalendar.timeZone = TimeZone(identifier: "America/New_York")! // It is important to set the Timezone as the date can change in Swift
        
let geoLocation = GeoLocation(locationName: "", latitude: 40.08213, longitude: -74.20970, timeZone: TimeZone(identifier: "America/New_York")!)
let calendar = ComplexZmanimCalendar(geoLocation: geoLocation) // Timezone is kept track of inside these classes with the geolocation

var januaryFirst = DateComponents()
januaryFirst.year = 2023
januaryFirst.month = 1
januaryFirst.day = 1
        
calendar.workingDate = gregorianCalendar.date(from: januaryFirst)!
var sunrise = calendar.getSunrise()        
```
For converting any of the data in this API to hebrew, look at the HebrewDateFormatter class:
```Swift
let jewishCalendar = JewishCalendar() // by default it is set to today's date
let hebrewDateFormatter = HebrewDateFormatter()
print(hebrewDateFormatter.formatMonth(jewishCalendar: jewishCalendar)) // prints "Nissan"
hebrewDateFormatter.hebrewFormat = true
print(hebrewDateFormatter.formatMonth(jewishCalendar: jewishCalendar)) // prints "ניסן"
```
Lastly, look at the TefilaRules class for methods that use the JewishCalendar to tell you which prayers to say:
```Swift
let jewishCalendar = JewishCalendar()
let tefilaRules = TefilaRules()
tefilaRules.isVeseinTalUmatarRecited(jewishCalendar: jewishCalendar) // returns true or false depending on the DAY of the year
```
Making Your Own Methods
-------
If you want to add onto what is already available in KosherSwift, Swift has a powerful feature called extensions that lets you do just that!
For example, if you wanted to make a method that gives you a jewishCalendar object set to the first day of the jewish month, you could do this:
```Swift
public extension JewishCalendar {
    func getFirstDayOfJewishMonth(jewishCalendar:JewishCalendar) -> JewishCalendar {
        let firstDayOfMonth = jewishCalendar
        jewishCalendar.setJewishDayOfMonth(dayOfMonth: 1)
        return firstDayOfMonth
    }
}
```
The same goes for zmanim! If you want to create your own zmanim, it would look like this:
```Swift
public extension ComplexZmanimCalendar {

    // for regular minutes (note the need to convert to milliseconds)
    func getTzais45() -> Date?  {
        return ComplexZmanimCalendar.getTimeOffset(time: getElevationAdjustedSunset(), offset: 45 * ComplexZmanimCalendar.MINUTE_MILLIS);
    }
    
    // for degrees
    func getTzais8PointSevenDegrees() -> Date? {
        return getSunsetOffsetByDegrees(offsetZenith: ComplexZmanimCalendar.GEOMETRIC_ZENITH + 8.7);
    }
    
    // for seasonal times
    func getTwoSeasonalHoursIntoTheDay() -> Date? {
        let seasonalHour = getTemporalHour()
        // it is preferred to use getTimeOffset because it will handle nil values
        return AstronomicalCalendar.getTimeOffset(time: getElevationAdjustedSunrise(), offset: seasonalHour * 2)
    }
}
```

Things To Keep In Mind
-------
KosherSwift is very similar to KosherJava as it has brought over almost all of it's methods to Swift. I have tried to keep the code as similar as possible to the original repository, because I personally wanted to bring over my Java code from my android project to iOS without having to refactor almost all of the code. However, as much as I tried to keep them similar, there are still big differences in the inner workings of the classes. For starters, the Calendar class in Swift does not contain a time in milliseconds to keep track of time, it only contains functions that can create a date. So everywhere there would be a need to use a Calendar has been replaced with a Date. If you look inside the code of the classes, there is a workingDate variable that can be changed instead of a calendar class.

Timezone issues are a big deal in Swift since Date objects are set to UTC by default and only afterwards are timezones taken into account, this leads to the date changing if the timezone for the Calendar class in Swift is not set to the same as timezone as the system. All objects that have a GeoLocation object take this into account, however, if you are using the JewishCalendar class in another timezone, use the JewishCalendar(workingDate: <Date>, timezone: <TimeZone>) constructor.

Otherwise, most methods have been tried and tested, however, if you come accross a method that is not working correctly, please create a issue or (more preferably) a pull request.

License
-------
The library is released under the [LGPL 2.1 license](https://kosherjava.com/2011/05/09/kosherjava-zmanim-api-released-under-the-lgpl-license/).

Ports to Other Languages
------------------------
The KosherJava Zmanim API has been ported to:
* Java (original repo) - https://github.com/KosherJava/zmanim/
* Swift - https://github.com/Elyahu41/KosherSwift (You are here)
* Objective-C - https://github.com/MosheBerman/KosherCocoa
* .NET - https://github.com/Yitzchok/Zmanim
* TypeScript - https://github.com/BehindTheMath/KosherZmanim
* JavaScript - https://github.com/yparitcher/zmanJS
* Kotlin - https://github.com/Sternbach-Software/KosherKotlin
* Ruby - https://github.com/pinnymz/ruby-zmanim
* Scala - https://github.com/nafg/jewish-date
* C - https://github.com/yparitcher/libzmanim
* Python - https://github.com/pinnymz/python-zmanim & https://pypi.org/project/zmanim/
* PHP - https://github.com/zachweix/PhpZmanim/
* Dart / Flutter - https://github.com/yakir8/kosher_dart
* Go - https://github.com/vlipovetskii/go-zmanim

ZmanCode Desktop App
------------------------
The .NET port was used to create a desktop app that is available at https://github.com/NykUser/MyZman.

Disclaimer:
-----------
__While I did my best to get accurate results, please double check before relying on these zmanim for <em>halacha lemaaseh</em>__.

------------------------
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/Elyahu41/KosherSwift?color=eed6af&label=KosherSwift&logo=github)](1.0.0)
[![GitHub](https://img.shields.io/github/license/KosherJava/zmanim?color=eed6af&logo=gnu)](https://github.com/KosherJava/zmanim/blob/master/LICENSE)
[![GitHub last commit](https://img.shields.io/github/last-commit/Elyahu41/KosherSwift?logo=github)](https://github.com/Elyahu41/KosherSwift/commits/master)
[![CodeQL](https://github.com/KosherJava/zmanim/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/KosherJava/zmanim/actions/workflows/codeql-analysis.yml)
[![Run unit tests](https://github.com/KosherJava/zmanim/actions/workflows/pull_request_worklow.yml/badge.svg)](https://github.com/Elyahu41/KosherSwift/actions/workflows/swift.yml)
