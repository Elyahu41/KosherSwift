//
//  GeoLocation.swift
//  KosherSwift
//
//  Created by Elyahu Jacobi on 12/21/23.
//

import Foundation

/**
 * A class that contains location information such as latitude and longitude required for astronomical calculations. The
 * elevation field may not be used by some calculation engines and would be ignored if set. Check the documentation for
 * specific implementations of the ``AstronomicalCalculator`` to see if elevation is calculated as part of the
 * algorithm.
 *
 * @author &copy; Eliyahu Hershfeld 2004 - 2022
 */
public class GeoLocation: Equatable {
    /**
     * @see #getLatitude()
     * @see #setLatitude(double)
     * @see #setLatitude(int, int, double, String)
     */
    public var latitude:Double;
    
    /**
     * @see #getLongitude()
     * @see #setLongitude(double)
     * @see #setLongitude(int, int, double, String)
     */
    public var longitude:Double;
    
    /**
     * @see #getLocationName()
     * @see #setLocationName(String)
     */
    public var locationName:String;
    
    /**
     * @see #getTimeZone()
     * @see #setTimeZone(TimeZone)
     */
    public var timeZone:TimeZone;
    
    /**
     * @see #getElevation()
     * @see #setElevation(double)
     */
    public var elevation:Double;

    /**
     * The elevation in meters of the horizon that the sun rises over, such as mountains east of the location. Sunrise is
     * calculated using the location's elevation minus this value (never less than 0).
     */
    public private(set) var horizonElevationAtSunrise: Double = 0

    /**
     * The elevation in meters of the horizon that the sun sets behind, such as mountains west of the location. Sunset is
     * calculated using the location's elevation minus this value (never less than 0).
     */
    public private(set) var horizonElevationAtSunset: Double = 0
    
    /**
     * Constant for a distance type calculation.
     * @see #getGeodesicDistance(GeoLocation)
     */
    private static let DISTANCE = 0;
    
    /**
     * Constant for an initial bearing type calculation.
     * @see #getGeodesicInitialBearing(GeoLocation)
     */
    private static let INITIAL_BEARING = 1;
    
    /**
     * Constant for a final bearing type calculation.
     * @see #getGeodesicFinalBearing(GeoLocation)
     */
    private static let FINAL_BEARING = 2;
    
    /** constant for milliseconds in a minute (60,000) */
    private static let MINUTE_MILLIS: Int64 = 60 * 1000;
    
    /** constant for milliseconds in an hour (3,600,000) */
    private static let HOUR_MILLIS: Int64 = MINUTE_MILLIS * 60;
    
    /**
     * Method to get the elevation in Meters.
     *
     * @return Returns the elevation in Meters.
     */
    public func getElevation() -> Double {
        return elevation;
    }
    
    /**
     * Method to set the elevation in Meters <b>above</b> sea level. Locations with an elevation below sea level should use a sea level
     * value, since this delay is due to obstructions (natural in this case) on the horizon that should be discounted. Natural obstructions
     * such as the walls of the Grand Canyon that block visibility to the sun to a person at the bottom of the canyon (that is actually
     * above sea level) for 3 to 4 hours after sunrise would not mean that <em>halachic</em> sunrise would be 3 hours after sea level sunrise
     * and sunset 3 hours before sea level sunset at that location.
     * @param elevation The elevation to set in Meters. If the elevation is negative, not a number, or infinite, it will be set to 0.
     */
    public func setElevation(elevation: Double) {
        if (elevation < 0) {
            self.elevation = 0
            print("Elevation cannot be negative")
            return
        }
        if elevation.isNaN || elevation.isInfinite {
            self.elevation = 0
            print("Elevation cannot be NaN or infinite")
            return
        }
        self.elevation = elevation;
    }

    /// The elevation in meters of the horizon at sunrise. See `setHorizonElevationAtSunrise(horizonElevationAtSunrise:)`.
    public func getHorizonElevationAtSunrise() -> Double {
        return horizonElevationAtSunrise
    }

    /**
     * Sets the elevation in meters of the horizon the sun rises over (for example the height of mountains to the east). When
     * calculating elevation-adjusted sunrise, this is subtracted from the location's elevation. Negative, NaN and infinite
     * values are ignored (KosherJava throws an IllegalArgumentException).
     */
    public func setHorizonElevationAtSunrise(horizonElevationAtSunrise: Double) {
        if GeoLocation.isValidHorizonElevation(horizonElevationAtSunrise) {
            self.horizonElevationAtSunrise = horizonElevationAtSunrise
        }
    }

    /// The elevation in meters of the horizon at sunset. See `setHorizonElevationAtSunset(horizonElevationAtSunset:)`.
    public func getHorizonElevationAtSunset() -> Double {
        return horizonElevationAtSunset
    }

    /**
     * Sets the elevation in meters of the horizon the sun sets behind (for example the height of mountains to the west).
     * When calculating elevation-adjusted sunset, this is subtracted from the location's elevation. Negative, NaN and
     * infinite values are ignored (KosherJava throws an IllegalArgumentException).
     */
    public func setHorizonElevationAtSunset(horizonElevationAtSunset: Double) {
        if GeoLocation.isValidHorizonElevation(horizonElevationAtSunset) {
            self.horizonElevationAtSunset = horizonElevationAtSunset
        }
    }

    private static func isValidHorizonElevation(_ horizonElevation: Double) -> Bool {
        if horizonElevation < 0 {
            print("Horizon elevation cannot be negative")
            return false
        }
        if horizonElevation.isNaN || horizonElevation.isInfinite {
            print("Horizon elevation cannot be NaN or infinite")
            return false
        }
        return true
    }

    /// The elevation used for elevation-adjusted sunrise: the elevation above the horizon at sunrise, never less than 0.
    public func getSunriseElevation() -> Double {
        return max(elevation - horizonElevationAtSunrise, 0)
    }

    /// The elevation used for elevation-adjusted sunset: the elevation above the horizon at sunset, never less than 0.
    public func getSunsetElevation() -> Double {
        return max(elevation - horizonElevationAtSunset, 0)
    }
    
    /**
     * GeoLocation constructor with parameters for all required fields.
     *
     * @param locationName
     *            The location name for display use such as &quot;Lakewood, NJ&quot;. This can be an empty string as well
     * @param latitude
     *            the latitude in a double format such as 40.095965 for Lakewood, NJ.
     *            <b>Note:</b> For latitudes south of the equator, a negative value should be used.
     * @param longitude
     *            double the longitude in a double format such as -74.222130 for Lakewood, NJ.
     *            <b>Note:</b> For longitudes east of the <a href="https://en.wikipedia.org/wiki/Prime_Meridian">Prime
     *            Meridian</a> (Greenwich), a negative value should be used.
     * @param timeZone
     *            the <code>TimeZone</code> for the location.
     */
    public convenience init(locationName: String, latitude: Double, longitude: Double, timeZone: TimeZone) {
        self.init(locationName: locationName, latitude: latitude, longitude: longitude, elevation: 0, timeZone: timeZone)
    }
    
    /**
     * GeoLocation constructor with parameters for all required fields.
     *
     * @param locationName
     *            The location name for display use such as &quot;Lakewood, NJ&quot;. This can be an empty string as well
     * @param latitude
     *            the latitude in a double format such as 40.095965 for Lakewood, NJ.
     *            <b>Note:</b> For latitudes south of the equator, a negative value should be used.
     * @param longitude
     *            double the longitude in a double format such as -74.222130 for Lakewood, NJ.
     *            <b>Note:</b> For longitudes east of the <a href="https://en.wikipedia.org/wiki/Prime_Meridian">Prime
     *            Meridian</a> (Greenwich), a negative value should be used.
     * @param elevation
     *            the elevation above sea level in Meters. Elevation is not used in most algorithms used for calculating
     *            sunrise and set.
     * @param timeZone
     *            the <code>TimeZone</code> for the location.
     */
    public init(locationName: String, latitude: Double, longitude: Double, elevation:Double, timeZone: TimeZone) {
        self.locationName = locationName
        self.latitude = 0
        self.longitude = 0
        self.elevation = 0
        self.timeZone = timeZone
        setLatitude(latitude: latitude)
        setLongitude(longitude: longitude)
        setElevation(elevation: elevation)
    }

    /**
     * GeoLocation constructor with the elevation of the horizon at sunrise and sunset, for a location such as a valley
     * where mountains block the view of the horizon. See `setHorizonElevationAtSunrise(horizonElevationAtSunrise:)`.
     */
    public convenience init(locationName: String, latitude: Double, longitude: Double, elevation: Double,
                            horizonElevationAtSunrise: Double, horizonElevationAtSunset: Double, timeZone: TimeZone) {
        self.init(locationName: locationName, latitude: latitude, longitude: longitude, elevation: elevation, timeZone: timeZone)
        setHorizonElevationAtSunrise(horizonElevationAtSunrise: horizonElevationAtSunrise)
        setHorizonElevationAtSunset(horizonElevationAtSunset: horizonElevationAtSunset)
    }
    
    /**
     * Default GeoLocation constructor will set location to the Prime Meridian at Greenwich, England and a TimeZone of
     * GMT. The longitude will be set to 0 and the latitude will be 51.4772 to match the location of the <a
     * href="https://www.rmg.co.uk/royal-observatory">Royal Observatory, Greenwich</a>. No daylight savings time will be used.
     */
    public init() {
        locationName = "Greenwich, England"
        latitude = 51.4772
        longitude = 0
        elevation = 0
        timeZone = TimeZone(identifier: "GMT")!
    }
    
    /**
     * Method to set the latitude.
     *
     * @param latitude
     *            The degrees of latitude to set. The values should be between -90&deg; and 90&deg;. Nothing will happen if the value exceeds the limit. For example 40.095965 would be
     *            used for Lakewood, NJ. <b>Note:</b> For latitudes south of the equator, a negative value should be
     *            used.
     */
    public func setLatitude(latitude:Double) {
        if (latitude > 90 || latitude < -90 || latitude.isNaN) {
            print("Latitude must be between -90 and  90")
            return // do nothing
        }
        self.latitude = latitude;
    }
    
    /**
     * Method to set the latitude in degrees, minutes and seconds.
     *
     * @param degrees
     *            The degrees of latitude to set between 0&deg; and 90&deg;. For example 40 would be used for Lakewood, NJ.
     *            Nothing will happen if the value exceeds the limit.
     * @param minutes
     *            <a href="https://en.wikipedia.org/wiki/Minute_of_arc#Cartography">minutes of arc</a>
     * @param seconds
     *            <a href="https://en.wikipedia.org/wiki/Minute_of_arc#Cartography">seconds of arc</a>
     * @param direction
     *            N for north and S for south.
     */
    public func setLatitude(degrees: Int, minutes: Int, seconds: Double, direction:String) {
        var tempLat = Double(degrees) + ((Double(minutes) + (seconds / 60.0)) / 60.0);
        if (tempLat > 90 || tempLat < 0 || tempLat.isNaN) { //FIXME An exception should be thrown if degrees, minutes or seconds are negative
            return // Do nothing
        }
        if (direction == "S") {
            tempLat *= -1;
        } else if (!(direction == "N")) {
            return // Do nothing
        }
        self.latitude = tempLat;
    }
    
    /**
     * @return Returns the latitude.
     */
    public func getLatitude() -> Double {
        return latitude;
    }
    
    /**
     * Method to set the longitude in a double format.
     *
     * @param longitude
     *            The degrees of longitude to set in a double format between -180&deg; and 180&deg;. Nothing will happen if the value exceeds the limit. For example -74.2094 would be
     *            used for Lakewood, NJ. Note: for longitudes east of the <a
     *            href="https://en.wikipedia.org/wiki/Prime_Meridian">Prime Meridian</a> (Greenwich) a negative value
     *            should be used.
     */
    public func setLongitude(longitude:Double) {
        if (longitude > 180 || longitude < -180 || longitude.isNaN) {
            print("Longitude must be between -180 and  180")
            return // Do nothing
        }
        self.longitude = longitude;
    }
    
    /**
     * Method to set the longitude in degrees, minutes and seconds.
     *
     * @param degrees
     *            The degrees of longitude to set between 0&deg; and 180&deg;. As an example 74 would be set for Lakewood, NJ.
     *            An IllegalArgumentException will be thrown if the value exceeds the limits.
     * @param minutes
     *            <a href="https://en.wikipedia.org/wiki/Minute_of_arc#Cartography">minutes of arc</a>
     * @param seconds
     *            <a href="https://en.wikipedia.org/wiki/Minute_of_arc#Cartography">seconds of arc</a>
     * @param direction
     *            E for east of the <a href="https://en.wikipedia.org/wiki/Prime_Meridian">Prime Meridian</a> or W for west of it.
     */
    public func setLongitude(degrees: Int, minutes: Int, seconds: Double, direction:String) {
        var longTemp = Double(degrees) + ((Double(minutes) + (seconds / 60.0)) / 60.0);
        if (longTemp > 180 || longTemp < 0 || longTemp.isNaN) { //FIXME An exception should be thrown if degrees, minutes or seconds are negative
            return // Do nothing
        }
        if (direction == "W") {
            longTemp *= -1;
        } else if (!(direction == "E")) {
            return // Do Nothing
        }
        self.longitude = longTemp;
    }
    
    /**
     * @return Returns the longitude.
     */
    public func getLongitude() -> Double {
        return longitude;
    }
    
    /**
     * @return Returns the location name.
     */
    public func getLocationName() -> String {
        return locationName;
    }
    
    /**
     * @param name
     *            The setter method for the display name.
     */
    public func setLocationName(name:String) {
        self.locationName = name;
    }
    
    /**
     * @return Returns the timeZone.
     */
    public func getTimeZone() -> TimeZone {
        return timeZone;
    }
    
    /**
     * Method to set the TimeZone.
     *
     * @param timeZone
     *            The timeZone to set.
     */
    public func setTimeZone(timeZone:TimeZone) {
        self.timeZone = timeZone;
    }
    
    /**
     * A method that will return the location's local mean time offset in milliseconds from the local clock time defined by the time
     * zone offset in effect for the supplied Date. The globe is split into 360°, with 15° per hour of the day. For
     * a local that is at a longitude that is evenly divisible by 15 (longitude % 15 == 0), at solar noon (with adjustment for the <a
     * href="https://en.wikipedia.org/wiki/Equation_of_time">equation of time</a>) the sun should be directly overhead, so a user who
     * is 1° west of this will have noon at 4 minutes after local clock noon, and conversely, a user who is 1° east of the 15°
     * longitude will have noon at 11:56 AM local clock time. Lakewood, N.J., whose longitude is -74.222, is 0.778 away from the
     * closest multiple of 15 at -75°. This is multiplied by 4 to yield 3 minutes and 10 seconds earlier than the local clock time
     *  derived from the zone offset in effect for the supplied date, including any applicable <a href=
     *  "https://en.wikipedia.org/wiki/Daylight_saving_time">Daylight saving time</a> adjustment.
     *
     * @param date the date used to calculate the local mean offset for the date in question.
     *
     * @return the offset in seconds (whole milliseconds) not accounting for Daylight saving time. A positive value will be returned
     *         East of the 15&deg; timezone line, and a negative value West of it.
     * @since 1.1
     */
    public func getLocalMeanTimeOffset(date: Date) -> TimeInterval {
        let timezoneOffsetMillis = Int64(getTimeZone().secondsFromGMT(for: date)) * 1000
        // KosherJava truncates the offset to whole milliseconds
        return Double(JavaMath.toLong(getLongitude() * 4 * Double(GeoLocation.MINUTE_MILLIS) - Double(timezoneOffsetMillis))) / 1000
    }
    
    /**
     * Adjust the date for <a href="https://en.wikipedia.org/wiki/180th_meridian">antimeridian</a> crossover. This is
     * needed to deal with edge cases such as Samoa that use a different calendar date than expected based on their
     * geographic location.
     *
     * The actual Time Zone offset may deviate from the expected offset based on the longitude. Since the 'absolute time'
     * calculations are always based on longitudinal offset from UTC for a given date, the date is presumed to only
     * increase East of the Prime Meridian, and to only decrease West of it. For Time Zones that cross the antimeridian,
     * the date will be artificially adjusted before calculation to conform with this presumption.
     *
     * For example, Apia, Samoa with a longitude of -171.75 uses a local offset of +14:00.  When calculating sunrise for
     * 2018-02-03, the calculator should operate using 2018-02-02 since the expected zone is -11.  After determining the
     * UTC time, the local DST offset of <a href="https://en.wikipedia.org/wiki/UTC%2B14:00">UTC+14:00</a> should be applied
     * to bring the date back to 2018-02-03.
     *
     * @return the number of days to adjust the date This will typically be 0 unless the date crosses the antimeridian
     */
    public func getAntimeridianAdjustment(date: Date) -> Int {
        let localHoursOffset = getLocalMeanTimeOffset(date: date) * 1000 / Double(GeoLocation.HOUR_MILLIS);
        
        if (localHoursOffset >= 20){// if the offset is 20 hours or more in the future (never expected anywhere other
            // than a location using a timezone across the anti meridian to the east such as Samoa)
            return 1; // roll the date forward a day
        } else if (localHoursOffset <= -20) {    // if the offset is 20 hours or more in the past (no current location is known
            //that crosses the antimeridian to the west, but better safe than sorry)
            return -1; // roll the date back a day
        }
        return 0; //99.999% of the world will have no adjustment
    }
    
    /**
     * Calculate the initial <a href="https://en.wikipedia.org/wiki/Great_circle">geodesic</a> bearing between this
     * Object and a second Object passed to this method using <a
     * href="https://en.wikipedia.org/wiki/Thaddeus_Vincenty">Thaddeus Vincenty's</a> inverse formula See T Vincenty, "<a
     * href="https://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf">Direct and Inverse Solutions of Geodesics on the Ellipsoid
     * with application of nested equations</a>", Survey Review, vol XXII no 176, 1975
     *
     * @param location
     *            the destination location
     * @return the initial bearing
     */
    public func getGeodesicInitialBearing(location:GeoLocation) -> Double {
        return vincentyInverseFormula(location: location, formula: GeoLocation.INITIAL_BEARING);
    }
    
    /**
     * Calculate the final <a href="https://en.wikipedia.org/wiki/Great_circle">geodesic</a> bearing between this Object
     * and a second Object passed to this method using <a href="https://en.wikipedia.org/wiki/Thaddeus_Vincenty">Thaddeus
     * Vincenty's</a> inverse formula See T Vincenty, "<a href="https://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf">Direct and
     * Inverse Solutions of Geodesics on the Ellipsoid with application of nested equations</a>", Survey Review, vol
     * XXII no 176, 1975
     *
     * @param location
     *            the destination location
     * @return the final bearing
     */
    public func getGeodesicFinalBearing(location:GeoLocation) -> Double {
        return vincentyInverseFormula(location: location, formula: GeoLocation.FINAL_BEARING);
    }
    
    /**
     * Calculate <a href="https://en.wikipedia.org/wiki/Great-circle_distance">geodesic distance</a> in Meters between
     * this Object and a second Object passed to this method using <a
     * href="https://en.wikipedia.org/wiki/Thaddeus_Vincenty">Thaddeus Vincenty's</a> inverse formula See T Vincenty, "<a
     * href="https://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf">Direct and Inverse Solutions of Geodesics on the Ellipsoid
     * with application of nested equations</a>", Survey Review, vol XXII no 176, 1975
     *
     * @see #vincentyFormula(GeoLocation, int)
     * @param location
     *            the destination location
     * @return the geodesic distance in Meters
     */
    public func getGeodesicDistance(location:GeoLocation) -> Double {
        return vincentyInverseFormula(location: location, formula: GeoLocation.DISTANCE);
    }
    
    /**
     * Calculate <a href="https://en.wikipedia.org/wiki/Great-circle_distance">geodesic distance</a> in Meters between
     * this Object and a second Object passed to this method using <a
     * href="https://en.wikipedia.org/wiki/Thaddeus_Vincenty">Thaddeus Vincenty's</a> inverse formula See T Vincenty, "<a
     * href="https://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf">Direct and Inverse Solutions of Geodesics on the Ellipsoid
     * with application of nested equations</a>", Survey Review, vol XXII no 176, 1975
     *
     * @param location
     *            the destination location
     * @param formula
     *            This formula calculates initial bearing (``INITIAL_BEARING``), final bearing (
     *            ``FINAL_BEARING``) and distance (``DISTANCE``).
     * @return geodesic distance in Meters
     */
    private func vincentyInverseFormula(location: GeoLocation, formula: Int) -> Double {
        let majorSemiAxis: Double = 6378137
        let minorSemiAxis: Double = 6356752.3142
        let f: Double = 1 / 298.257223563 // WGS-84 ellipsoid
        
        // Helper closures for degrees/radians conversion
        let toRadians = JavaMath.toRadians
        let toDegrees = JavaMath.toDegrees
        
        let L = toRadians(location.longitude - self.longitude)
        let U1 = atan((1 - f) * tan(toRadians(self.latitude)))
        let U2 = atan((1 - f) * tan(toRadians(location.latitude)))
        
        let sinU1 = sin(U1), cosU1 = cos(U1)
        let sinU2 = sin(U2), cosU2 = cos(U2)
        
        var lambda = L
        var lambdaP = 2 * Double.pi
        var iterLimit = 20
        
        var sinLambda: Double = 0
        var cosLambda: Double = 0
        var sinSigma: Double = 0
        var cosSigma: Double = 0
        var sigma: Double = 0
        var sinAlpha: Double = 0
        var cosSqAlpha: Double = 0
        var cos2SigmaM: Double = 0
        var C: Double = 0
        
        // Java's `--iterLimit > 0` decrements before the check, so the loop runs at most 19 times
        while abs(lambda - lambdaP) > 1e-12 {
            iterLimit -= 1
            if iterLimit <= 0 {
                break
            }
            
            sinLambda = sin(lambda)
            cosLambda = cos(lambda)
            
            let part1 = cosU2 * sinLambda
            let part2 = cosU1 * sinU2 - sinU1 * cosU2 * cosLambda
            sinSigma = sqrt((part1 * part1) + (part2 * part2))
            
            if sinSigma == 0 {
                return 0 // co-incident points
            }
            
            cosSigma = sinU1 * sinU2 + cosU1 * cosU2 * cosLambda
            sigma = atan2(sinSigma, cosSigma)
            sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma
            cosSqAlpha = 1 - sinAlpha * sinAlpha
            cos2SigmaM = cosSigma - 2 * sinU1 * sinU2 / cosSqAlpha
            
            if cos2SigmaM.isNaN {
                cos2SigmaM = 0 // equatorial line: cosSqAlpha=0 (§6)
            }
            
            C = f / 16 * cosSqAlpha * (4 + f * (4 - 3 * cosSqAlpha))
            lambdaP = lambda
            lambda = L + (1 - C) * f * sinAlpha * (sigma + C * sinSigma * (cos2SigmaM + C * cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM)))
        }
        
        if iterLimit == 0 {
            return Double.nan // formula failed to converge
        }
        
        let uSq = cosSqAlpha * (majorSemiAxis * majorSemiAxis - minorSemiAxis * minorSemiAxis) / (minorSemiAxis * minorSemiAxis)
        let A = 1 + uSq / 16384 * (4096 + uSq * (-768 + uSq * (320 - 175 * uSq)))
        let B = uSq / 1024 * (256 + uSq * (-128 + uSq * (74 - 47 * uSq)))
        
        let deltaSigma = B * sinSigma * (cos2SigmaM + B / 4 * (cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM) - B / 6 * cos2SigmaM * (-3 + 4 * sinSigma * sinSigma) * (-3 + 4 * cos2SigmaM * cos2SigmaM)))
        let distance = minorSemiAxis * A * (sigma - deltaSigma)
        
        // initial bearing
        let fwdAz = toDegrees(atan2(cosU2 * sinLambda, cosU1 * sinU2 - sinU1 * cosU2 * cosLambda))
        // final bearing
        let revAz = toDegrees(atan2(cosU1 * sinLambda, -sinU1 * cosU2 + cosU1 * sinU2 * cosLambda))
        
        switch formula {
        case GeoLocation.DISTANCE:
            return distance
        case GeoLocation.INITIAL_BEARING:
            return fwdAz
        case GeoLocation.FINAL_BEARING:
            return revAz
        default:
            return Double.nan
        }
    }
    
    /**
     * Returns the <a href="https://en.wikipedia.org/wiki/Rhumb_line">rhumb line</a> bearing from the current location to
     * the GeoLocation passed in.
     *
     * @param location
     *            destination location
     * @return the bearing in degrees
     */
    public func getRhumbLineBearing(location:GeoLocation) -> Double {
        var dLon = JavaMath.toRadians(location.getLongitude() - getLongitude());
        let dPhi = log(tan(JavaMath.toRadians(location.getLatitude()) / 2 + Double.pi / 4)
                       / tan(JavaMath.toRadians(getLatitude()) / 2 + Double.pi / 4));
        if (abs(dLon) > Double.pi) {
            dLon = dLon > 0 ? -(2 * Double.pi - dLon) : (2 * Double.pi + dLon);
        }
        return JavaMath.toDegrees(atan2(dLon, dPhi));
    }
    
    /**
     * Returns the <a href="https://en.wikipedia.org/wiki/Rhumb_line">rhumb line</a> distance from the current location
     * to the GeoLocation passed in.
     *
     * @param location
     *            the destination location
     * @return the distance in Meters
     */
    public func getRhumbLineDistance(location:GeoLocation) -> Double {
        let earthRadius = Double(6378137); // Earth's radius in meters (WGS-84)
        let dLat = JavaMath.toRadians(location.getLatitude()) - JavaMath.toRadians(getLatitude());
        var dLon = abs(JavaMath.toRadians(location.getLongitude()) - JavaMath.toRadians(getLongitude()));
        let dPhi = log(tan(JavaMath.toRadians(location.getLatitude()) / 2 + Double.pi / 4)
                       / tan(JavaMath.toRadians(getLatitude()) / 2 + Double.pi / 4));
        var q = dLat / dPhi;

        if (!(abs(q) <= Double.greatestFiniteMagnitude)) {
            q = cos(JavaMath.toRadians(getLatitude()));
        }
        // if dLon over 180° take shorter rhumb across 180° meridian:
        if (dLon > Double.pi) {
            dLon = 2 * Double.pi - dLon;
        }
        let d = sqrt(dLat * dLat + q * q * dLon * dLon);
        return d * earthRadius;
    }

    /// Converts degrees to radians, like Java's `Math.toRadians`.
    public func toRadians(degrees:Double) -> Double {
        return JavaMath.toRadians(degrees)
    }

    /// Converts radians to degrees, like Java's `Math.toDegrees`.
    public func toDegrees(radians:Double) -> Double {
        return JavaMath.toDegrees(radians)
    }

    /**
     * A method that returns an XML formatted `String` representing the serialized `GeoLocation` object. The format is:
     *
     * ```
     * <GeoLocation>
     *     <LocationName>Lakewood, NJ</LocationName>
     *     <Latitude>40.0828</Latitude>
     *     <Longitude>-74.2094</Longitude>
     *     <Elevation>0 Meters</Elevation>
     *     <HorizonElevationAtSunrise>0 Meters</HorizonElevationAtSunrise>
     *     <HorizonElevationAtSunset>0 Meters</HorizonElevationAtSunset>
     *     <TimezoneName>America/New_York</TimezoneName>
     *     <TimeZoneDisplayName>Eastern Time</TimeZoneDisplayName>
     * </GeoLocation>
     * ```
     *
     * The location name and time zone name are XML escaped.
     */
    public func toXML() -> String {
        return "<GeoLocation>\n" +
            "\t<LocationName>" + ZmanimFormatter.escapeXML(getLocationName()) + "</LocationName>\n" +
            "\t<Latitude>" + "\(getLatitude())" + "</Latitude>\n" +
            "\t<Longitude>" + "\(getLongitude())" + "</Longitude>\n" +
            "\t<Elevation>" + "\(getElevation())" + " Meters" + "</Elevation>\n" +
            "\t<HorizonElevationAtSunrise>" + "\(getHorizonElevationAtSunrise())" + " Meters" + "</HorizonElevationAtSunrise>\n" +
            "\t<HorizonElevationAtSunset>" + "\(getHorizonElevationAtSunset())" + " Meters" + "</HorizonElevationAtSunset>\n" +
            "\t<TimezoneName>" + ZmanimFormatter.escapeXML(getTimeZone().identifier) + "</TimezoneName>\n" +
            "\t<TimeZoneDisplayName>" + ZmanimFormatter.escapeXML(GeoLocation.displayName(getTimeZone())) + "</TimeZoneDisplayName>\n" +
            "</GeoLocation>"
    }

    /// The full English generic name of a time zone (such as "Eastern Time"), like Java's `getDisplayName(TextStyle.FULL, Locale.ENGLISH)`.
    static func displayName(_ timeZone: TimeZone) -> String {
        return timeZone.localizedName(for: .generic, locale: Locale(identifier: "en_US")) ?? timeZone.identifier
    }

    /// A string representation of the location.
    public func toString() -> String {
        return "\nLocation Name:\t\t\t" + getLocationName() +
            "\nLatitude:\t\t\t" + "\(getLatitude())" + "\u{00B0}" +
            "\nLongitude:\t\t\t" + "\(getLongitude())" + "\u{00B0}" +
            "\nElevation:\t\t\t" + "\(getElevation())" + " Meters" +
            "\nHorizon Elevation At Sunrise:\t" + "\(getHorizonElevationAtSunrise())" + " Meters" +
            "\nHorizon Elevation At Sunset:\t" + "\(getHorizonElevationAtSunset())" + " Meters" +
            "\nTimezone ID:\t\t\t" + getTimeZone().identifier +
            "\nTimezone Display Name:\t\t" + GeoLocation.displayName(getTimeZone())
    }

    public static func == (lhs: GeoLocation, rhs: GeoLocation) -> Bool {
        return lhs.equals(rhs)
    }

    /// True if the other location has the same name, coordinates, elevations and time zone.
    public func equals(_ other: GeoLocation) -> Bool {
        if self === other {
            return true
        }
        return type(of: self) == type(of: other)
            && GeoLocation.javaCompare(latitude, other.latitude)
            && GeoLocation.javaCompare(longitude, other.longitude)
            && GeoLocation.javaCompare(elevation, other.elevation)
            && GeoLocation.javaCompare(horizonElevationAtSunrise, other.horizonElevationAtSunrise)
            && GeoLocation.javaCompare(horizonElevationAtSunset, other.horizonElevationAtSunset)
            && locationName == other.locationName
            && timeZone.identifier == other.timeZone.identifier
    }

    /// Java's `Double.compare(a, b) == 0`: NaN equals NaN, and 0.0 differs from -0.0.
    private static func javaCompare(_ a: Double, _ b: Double) -> Bool {
        if a.isNaN || b.isNaN {
            return a.isNaN && b.isNaN
        }
        return a == b && a.sign == b.sign
    }

    /// Creates and returns a copy of this `GeoLocation`.
    public func copy() -> GeoLocation {
        let new = GeoLocation()
        new.locationName = self.locationName
        new.latitude = self.latitude
        new.longitude = self.longitude
        new.elevation = self.elevation
        new.horizonElevationAtSunrise = self.horizonElevationAtSunrise
        new.horizonElevationAtSunset = self.horizonElevationAtSunset
        new.timeZone = self.timeZone
        return new
    }
}
