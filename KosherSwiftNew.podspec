Pod::Spec.new do |spec|

  spec.name         = "KosherSwiftNew"
  spec.version      = "1.0.6"
  spec.summary      = "KosherJava Zmanim API / Library ported to Swift."

  spec.description  = "This Zmanim library is an API for a specialized calendar that can calculate different astronomical times including sunrise and sunset and Jewish zmanim or religious times for prayers and other Jewish religious duties.

For non religious astronomical / solar calculations use the AstronomicalCalendar.

The ZmanimCalendar contains the most common zmanim or religious time calculations. For a much more extensive list of zmanim use the ComplexZmanimCalendar. This class contains the main functionality of the Zmanim library."

  spec.homepage     = "https://github.com/Elyahu41/KosherSwift"
  spec.license      = "LGPL 2.1"
  spec.author       = { "Elyahu" => "ElyahuJacobi@gmail.com" }
  spec.ios.deployment_target = "13.0"
  spec.osx.deployment_target = "13.0"
  spec.watchos.deployment_target = "4.0"
  spec.tvos.deployment_target = "12.0"

  spec.source       = { :git => "https://github.com/Elyahu41/KosherSwift.git", :tag => spec.version.to_s }

  spec.source_files  = "Sources/**/*.{swift}"
  spec.swift_versions = "5.0"
end
