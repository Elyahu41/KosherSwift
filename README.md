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
To add KosherSwift as a dependency to your project, add the following dependency to your xcode project's package dependancy:

```
https://github.com/Elyahu41/KosherSwift.git

```

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
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/KosherJava/zmanim?color=eed6af&label=KosherSwift&logo=github)](1.0.0)
[![GitHub](https://img.shields.io/github/license/KosherJava/zmanim?color=eed6af&logo=gnu)](https://github.com/KosherJava/zmanim/blob/master/LICENSE)
[![GitHub last commit](https://img.shields.io/github/last-commit/KosherJava/zmanim?logo=github)](https://github.com/Elyahu41/KosherSwift/commits/master)
[![CodeQL](https://github.com/KosherJava/zmanim/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/KosherJava/zmanim/actions/workflows/codeql-analysis.yml)
[![Run unit tests](https://github.com/KosherJava/zmanim/actions/workflows/pull_request_worklow.yml/badge.svg)](https://github.com/KosherJava/zmanim/actions/workflows/pull_request_worklow.yml)
