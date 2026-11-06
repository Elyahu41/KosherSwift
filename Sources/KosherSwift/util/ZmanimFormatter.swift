//
//  ZmanimFormatter.swift
//  KosherSwift
//
//  Created by Elyahu Jacobi on 12/21/23.
//

import Foundation

/// A convenience class to help format Date and TimeInterval objects and the like.
public class ZmanimFormatter {
    
    // MARK: - Properties
    public var timeZone: TimeZone
    public var is24HourFormat: Bool
    public var prependZeroHours: Bool
    public var useSeconds: Bool
    public var useMillis: Bool
    
    /// Formatter for points in time (e.g., Sunrise)
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        // Ensures AM/PM and 12/24h logic is consistent across all regions
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    /// Formatter for durations (e.g., Temporal Hour length)
    private let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    /// Initializes a zmanim formatter with configurable display settings.
    ///
    /// - Parameters:
    ///   - timeZone: The time zone to use for date formatting. Defaults to `.current`.
    ///   - is24HourFormat: Set to `true` for 24-hour time (13:00) or `false` for 12-hour time with AM/PM (1:00 PM). Defaults to `false`.
    ///   - prependZeroHours: For durations, set to `true` to pad hours (01:05:00) or `false` to drop them (1:05:00). Defaults to `false`.
    ///   - useSeconds: Set to `true` to include seconds in the output. Defaults to `true`.
    ///   - useMillis: Set to `true` to include milliseconds in duration formatting. Defaults to `false`.
    public init(
        timeZone: TimeZone = .current,
        is24HourFormat: Bool = false,
        prependZeroHours: Bool = false,
        useSeconds: Bool = true,
        useMillis: Bool = false
    ) {
        self.timeZone = timeZone
        self.is24HourFormat = is24HourFormat
        self.prependZeroHours = prependZeroHours
        self.useSeconds = useSeconds
        self.useMillis = useMillis
    }
    
    // MARK: - Date Formatting
    
    /// Formats a specific Date object based on the current configuration.
    public func format(date: Date) -> String {
        // H = 24h, h = 12h.
        // If 12h, we append " a" for the AM/PM marker.
        let hourToken = is24HourFormat ? "H" : "h"
        let secondsToken = useSeconds ? ":ss" : ""
        let amPmToken = is24HourFormat ? "" : " a"
        
        dateFormatter.dateFormat = "\(hourToken):mm\(secondsToken)\(amPmToken)"
        dateFormatter.timeZone = timeZone
        
        return dateFormatter.string(from: date)
    }
    
    /// Formats a date specifically for XSD (ISO8601) format
    public func formatXSD(date: Date) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.timeZone = timeZone
        isoFormatter.formatOptions = [.withInternetDateTime]
        return isoFormatter.string(from: date)
    }
    
    // MARK: - Duration Formatting (Milliseconds)
    
    /// Formats milliseconds into a readable string like "01:30:00". Returns an empty string for a NaN or infinite value.
    public func format(milliseconds: Double) -> String {
        guard milliseconds.isFinite else { return "" } // Int(NaN) would crash below
        let seconds = milliseconds / 1000.0
        
        // Adjust padding based on prependZeroHours
        durationFormatter.zeroFormattingBehavior = prependZeroHours ? .pad : .dropLeading
        
        // Adjust units based on useSeconds
        durationFormatter.allowedUnits = useSeconds ? [.hour, .minute, .second] : [.hour, .minute]
        
        guard let formattedString = durationFormatter.string(from: seconds) else { return "" }
        
        // Add milliseconds manually if requested
        if useMillis {
            let millis = Int(milliseconds.truncatingRemainder(dividingBy: 1000))
            return String(format: "%@.%03d", formattedString, millis)
        }
        
        return formattedString
    }
    
    /// Formats milliseconds into XSD Duration format (e.g., PT1H30M, or -PT1H30M for a negative duration). Returns an empty
    /// string for a NaN, infinite or out of range value.
    public func formatXSDDuration(milliseconds: Double) -> String {
        // Int(_:) traps on NaN, infinity and values outside Int's range
        guard milliseconds.isFinite, abs(milliseconds) / 1000 < Double(Int.max) else { return "" }
        let totalSeconds = Int(abs(milliseconds) / 1000)
        // XSD puts a single sign in front of the whole value; the fields themselves are never negative
        let sign = milliseconds < 0 && totalSeconds > 0 ? "-" : ""
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        var result = "PT"
        if hours > 0 { result += "\(hours)H" }
        if minutes > 0 { result += "\(minutes)M" }
        if seconds > 0 || result == "PT" { result += "\(seconds)S" }
        
        return sign + result
    }
    
    // MARK: - TimeInterval Formatting
        
        /// Formats a `TimeInterval` (seconds) into a readable string like "01:30:00"
        /// - Parameter interval: The time interval in seconds.
        public func format(interval: TimeInterval) -> String {
            return format(milliseconds: interval * 1000)
        }
        
        /// Formats a `TimeInterval` (seconds) into XSD Duration format (e.g., PT1H30M).
        /// - Parameter interval: The time interval in seconds.
        public func formatXSDDuration(interval: TimeInterval) -> String {
            return formatXSDDuration(milliseconds: interval * 1000)
        }
}
