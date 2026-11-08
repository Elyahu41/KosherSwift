//
//  KosherSwiftWarnings.swift
//  KosherSwift
//
//  Where KosherJava throws an exception for an invalid argument or a calculation it can't do, KosherSwift doesn't crash the
//  app: it returns nil or NaN, or leaves the value unchanged, and reports a warning here.
//

import Foundation
#if canImport(os)
import os
#endif

/**
 * Warnings for invalid arguments and calculations that can't be done, in the places where KosherJava throws an exception.
 * KosherSwift never crashes the app for these: the method returns `nil` or `Double.nan`, or a setter leaves the value
 * unchanged, and the warning is reported to ``handler``.
 *
 * By default each warning is logged with the unified logging system (subsystem "KosherSwift", category "warnings") at the
 * error level, so Xcode's console highlights it and it can be found in the Console app, or written to standard error on
 * platforms without it. To see the warnings in your own way, set a handler:
 *
 * ```
 * KosherSwiftWarnings.handler = { warning in
 *     Analytics.log("KosherSwift: \(warning)")
 * }
 * ```
 *
 * To stop in the debugger when a warning is reported in a debug build, set ``stopInDebugBuilds`` to `true`. Set ``handler``
 * to `nil` to silence the warnings.
 */
public enum KosherSwiftWarnings {

    /// A warning: what went wrong, and the method that reported it.
    public struct Warning: CustomStringConvertible {
        /// What went wrong, including the invalid value and what was done instead.
        public let message: String
        /// The method that reported the warning, such as `setLatitude(latitude:)`.
        public let function: String
        /// The source file of the method, such as `KosherSwift/GeoLocation.swift`.
        public let file: String
        /// The line in the source file.
        public let line: Int

        public var description: String {
            return "\(function): \(message)"
        }
    }

    private static let lock = NSLock()
    private static var currentHandler: ((Warning) -> Void)? = defaultHandler
    public static var currentStopInDebugBuilds = false

    /// Called with every warning. The default logs it (see ``KosherSwiftWarnings``); `nil` silences the warnings.
    public static var handler: ((Warning) -> Void)? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return currentHandler
        }
        set {
            lock.lock()
            currentHandler = newValue
            lock.unlock()
        }
    }

    /// If `true`, a debug build also stops with `assertionFailure` when a warning is reported, so it can't be missed while
    /// developing. Release builds never stop. The default is `false`.
    public static var stopInDebugBuilds: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return currentStopInDebugBuilds
        }
        set {
            lock.lock()
            currentStopInDebugBuilds = newValue
            lock.unlock()
        }
    }

    /// The default handler: the unified logging system at the error level, or standard error where it isn't available.
    public static let defaultHandler: (Warning) -> Void = { warning in
        #if canImport(os)
        os_log("%{public}@", log: log, type: .error, "KosherSwift warning: \(warning) (\(warning.file):\(warning.line))")
        #else
        FileHandle.standardError.write(Data("KosherSwift warning: \(warning) (\(warning.file):\(warning.line))\n".utf8))
        #endif
    }

    #if canImport(os)
    private static let log = OSLog(subsystem: "KosherSwift", category: "warnings")
    #endif

    /// Reports a warning to the handler.
    static func report(_ message: String, function: String = #function, file: String = #fileID, line: Int = #line) {
        let warning = Warning(message: message, function: function, file: file, line: line)
        handler?(warning)
        if stopInDebugBuilds {
            assertionFailure("KosherSwift warning: \(warning)")
        }
    }
}
