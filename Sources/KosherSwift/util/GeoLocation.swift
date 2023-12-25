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
 * specific implementations of the {@link AstronomicalCalculator} to see if elevation is calculated as part of the
 * algorithm.
 *
 * @author &copy; Eliyahu Hershfeld 2004 - 2022
 */
public class GeoLocation {
    /**
     * @see #getLatitude()
     * @see #setLatitude(double)
     * @see #setLatitude(int, int, double, String)
     */
     var latitude:Double;
    
    /**
     * @see #getLongitude()
     * @see #setLongitude(double)
     * @see #setLongitude(int, int, double, String)
     */
     var longitude:Double;
    
    /**
     * @see #getLocationName()
     * @see #setLocationName(String)
     */
     var locationName:String;
    
    /**
     * @see #getTimeZone()
     * @see #setTimeZone(TimeZone)
     */
     var timeZone:TimeZone;
    
    /**
     * @see #getElevation()
     * @see #setElevation(double)
     */
     var elevation:Double;
    
    /**
     * Constant for a distance type calculation.
     * @see #getGeodesicDistance(GeoLocation)
     */
    private static let DISTANCE = 0;
    
    /**
     * Constant for a initial bearing type calculation.
     * @see #getGeodesicInitialBearing(GeoLocation)
     */
    private static let INITIAL_BEARING = 1;
    
    /**
     * Constant for a final bearing type calculation.
     * @see #getGeodesicFinalBearing(GeoLocation)
     */
    private static let FINAL_BEARING = 2;

    /** constant for milliseconds in a minute (60,000) */
    private static let MINUTE_MILLIS = 60 * 1000;

    /** constant for milliseconds in an hour (3,600,000) */
    private static let HOUR_MILLIS = Double(MINUTE_MILLIS * 60);

    /**
     * Method to get the elevation in Meters.
     *
     * @return Returns the elevation in Meters.
     */
    public func getElevation() -> Double {
        return elevation;
    }

    /**
     * Method to set the elevation in Meters <b>above</b> sea level.
     *
     * @param elevation
     *            The elevation to set in Meters. Nothing will happen the number is negative.
     */
    public func setElevation(elevation: Double) {
        if (elevation < 0) {
            return // do nothing
        }
        self.elevation = elevation;
    }

    /**
     * GeoLocation constructor with parameters for all required fields.
     *
     * @param name
     *            The location name for display use such as &quot;Lakewood, NJ&quot;
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
    init(locationName: String, latitude: Double, longitude: Double, timeZone: TimeZone) {
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = 0
        self.timeZone = timeZone
    }

    /**
     * GeoLocation constructor with parameters for all required fields.
     *
     * @param name
     *            The location name for display use such as &quot;Lakewood, NJ&quot;
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
    init(locationName: String, latitude: Double, longitude: Double, elevation:Double, timeZone: TimeZone) {
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
        self.timeZone = timeZone
    }

    /**
     * Default GeoLocation constructor will set location to the Prime Meridian at Greenwich, England and a TimeZone of
     * GMT. The longitude will be set to 0 and the latitude will be 51.4772 to match the location of the <a
     * href="https://www.rmg.co.uk/royal-observatory">Royal Observatory, Greenwich</a>. No daylight savings time will be used.
     */
    init() {
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
        if (latitude > 90 || latitude < -90) {
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
        var tempLat = degrees + Int(Double(minutes + Int(seconds / 60.0)) / 60.0);
        if (tempLat > 90 || tempLat < 0) { //FIXME An exception should be thrown if degrees, minutes or seconds are negative
            return // Do nothing
        }
        if (direction == "S") {
            tempLat *= -1;
        } else if (!(direction == "N")) {
            return // Do nothing
        }
        self.latitude = Double(tempLat);
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
        if (longitude > 180 || longitude < -180) {
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
     *            An IllegalArgumentException will be thrown if
     *            the value is not E or W.
     */
    public func setLongitude(degrees: Int, minutes: Int, seconds: Double, direction:String) {
        var longTemp = degrees + Int(Double(minutes + Int(seconds / 60.0)) / 60.0);
        if (longTemp > 180 || self.longitude < 0) { //FIXME An exception should be thrown if degrees, minutes or seconds are negative
            return // Do nothing
        }
        if (direction == "W") {
            longTemp *= -1;
        } else if (!(direction == "E")) {
            return // Do Nothing
        }
        self.longitude = Double(longTemp);
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
     * Method to set the TimeZone. If this is ever set after the GeoLocation is set in the
     * {@link com.kosherjava.zmanim.AstronomicalCalendar}, it is critical that
     * {@link com.kosherjava.zmanim.AstronomicalCalendar#getCalendar()}.
     * {@link java.util.Calendar#setTimeZone(TimeZone) setTimeZone(TimeZone)} be called in order for the
     * AstronomicalCalendar to output times in the expected offset. This situation will arise if the
     * AstronomicalCalendar is ever {@link com.kosherjava.zmanim.AstronomicalCalendar#clone() cloned}.
     *
     * @param timeZone
     *            The timeZone to set.
     */
    public func setTimeZone(timeZone:TimeZone) {
        self.timeZone = timeZone;
    }

    /**
     * This method is not tested at all. If you want to use this method or fix it, please submit an issue on github.
     * A method that will return the location's local mean time offset in milliseconds from local <a
     * href="https://en.wikipedia.org/wiki/Standard_time">standard time</a>. The globe is split into 360&deg;, with
     * 15&deg; per hour of the day. For a local that is at a longitude that is evenly divisible by 15 (longitude % 15 ==
     * 0), at solar {@link com.kosherjava.zmanim.AstronomicalCalendar#getSunTransit() noon} (with adjustment for the <a
     * href="https://en.wikipedia.org/wiki/Equation_of_time">equation of time</a>) the sun should be directly overhead,
     * so a user who is 1&deg; west of this will have noon at 4 minutes after standard time noon, and conversely, a user
     * who is 1&deg; east of the 15&deg; longitude will have noon at 11:56 AM. Lakewood, N.J., whose longitude is
     * -74.2094, is 0.7906 away from the closest multiple of 15 at -75&deg;. This is multiplied by 4 to yield 3 minutes
     * and 10 seconds earlier than standard time. The offset returned does not account for the <a
     * href="https://en.wikipedia.org/wiki/Daylight_saving_time">Daylight saving time</a> offset since this class is
     * unaware of dates.
     *
     * @return the offset in milliseconds not accounting for Daylight saving time. A positive value will be returned
     *         East of the 15&deg; timezone line, and a negative value West of it.
     * @since 1.1
     */
    public func getLocalMeanTimeOffset() -> Double {
        //This method might not work properly. I did not test it at all.
        return Double(Int(getLongitude()) * 4 * GeoLocation.MINUTE_MILLIS - getTimeZone().secondsFromGMT());
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
    public func getAntimeridianAdjustment() -> Int {
        let localHoursOffset = getLocalMeanTimeOffset() / GeoLocation.HOUR_MILLIS;
        
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
        return vincentyFormula(location: location, formula: GeoLocation.INITIAL_BEARING);
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
        return vincentyFormula(location: location, formula: GeoLocation.FINAL_BEARING);
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
        return vincentyFormula(location: location, formula: GeoLocation.DISTANCE);
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
     *            This formula calculates initial bearing ({@link #INITIAL_BEARING}), final bearing (
     *            {@link #FINAL_BEARING}) and distance ({@link #DISTANCE}).
     * @return geodesic distance in Meters
     */
    private func vincentyFormula(location: GeoLocation, formula: Int) -> Double {
        let a = 6378137.0
        let b = 6356752.3142
        let f = 1 / 298.257223563 // WGS-84 ellipsoid
        let L = toRadians(degrees: location.longitude) - toRadians(degrees: longitude)
        let U1 = atan((1 - f) * tan(toRadians(degrees: latitude)))
        let U2 = atan((1 - f) * tan(toRadians(degrees: location.latitude)))
        let sinU1 = sin(U1), cosU1 = cos(U1)
        let sinU2 = sin(U2), cosU2 = cos(U2)

        var lambda = L
        var lambdaP = 2 * Double.pi
        var iterLimit = 20
        var sinLambda = 0.0, cosLambda = 0.0, sinSigma = 0.0, cosSigma = 0.0, sigma = 0.0
        var sinAlpha = 0.0, cosSqAlpha = 0.0, cos2SigmaM = 0.0, C = 0.0

        while abs(lambda - lambdaP) > 1e-12, iterLimit > 0 {
            sinLambda = sin(lambda)
            cosLambda = cos(lambda)
            sinSigma = sqrt((cosU2 * sinLambda) * (cosU2 * sinLambda)
                + (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda) * (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda))

            if sinSigma == 0 { return 0 } // co-incident points

            cosSigma = sinU1 * sinU2 + cosU1 * cosU2 * cosLambda
            sigma = atan2(sinSigma, cosSigma)
            sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma
            cosSqAlpha = 1 - sinAlpha * sinAlpha
            cos2SigmaM = cosSigma - 2 * sinU1 * sinU2 / cosSqAlpha

            if cos2SigmaM.isNaN { cos2SigmaM = 0 } // equatorial line: cosSqAlpha=0 (§6)

            C = f / 16 * cosSqAlpha * (4 + f * (4 - 3 * cosSqAlpha))
            lambdaP = lambda
            lambda = L + (1 - C) * f * sinAlpha
                * (sigma + C * sinSigma * (cos2SigmaM + C * cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM)))

            iterLimit -= 1
        }

        if iterLimit == 0 { return Double.nan } // formula failed to converge

        let uSq = cosSqAlpha * (a * a - b * b) / (b * b)
        let A = 1 + uSq / 16384 * (4096 + uSq * (-768 + uSq * (320 - 175 * uSq)))
        let B = uSq / 1024 * (256 + uSq * (-128 + uSq * (74 - 47 * uSq)))
        let deltaSigma = B
            * sinSigma
            * (cos2SigmaM + B
                / 4
                * (cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM) - B / 6 * cos2SigmaM
                    * (-3 + 4 * sinSigma * sinSigma) * (-3 + 4 * cos2SigmaM * cos2SigmaM)))

        let distance = b * A * (sigma - deltaSigma)

        let atanPart1 = cosU1 * sinU2 - sinU1 * cosU2 * cosLambda
        let atanPart2 = -sinU1 * cosU2 + cosU1 * sinU2 * cosLambda

        let atanResult1 = atan2(atanPart1, Double(sinLambda))
        let atanResult2 = atan2(atanPart2, Double(sinLambda))

        let fwdAz = toDegrees(radians: cosU2 * atanResult1)
        let revAz = toDegrees(radians: cosU1 * atanResult2)


        switch formula {
        case GeoLocation.DISTANCE:
            return distance
        case GeoLocation.INITIAL_BEARING:
            return fwdAz
        case GeoLocation.FINAL_BEARING:
            return revAz
        default: // should never happen
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
        var dLon = toRadians(degrees: location.getLongitude() - getLongitude());
        let dPhi = log(tan(toRadians(degrees: location.getLatitude()) / 2 + Double.pi / 4)
                       / tan(toRadians(degrees: getLatitude()) / 2 + Double.pi / 4));
        if (abs(dLon) > Double.pi) {
            dLon = dLon > 0 ? -(2 * Double.pi - dLon) : (2 * Double.pi + dLon);
        }
        return toDegrees(radians: atan2(dLon, dPhi));
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
        let dLat = toRadians(degrees: location.getLatitude()) - toRadians(degrees: getLatitude());
        var dLon = abs(toRadians(degrees: location.getLongitude()) - toRadians(degrees: getLongitude()));
        let dPhi = log(tan(toRadians(degrees: location.getLatitude()) / 2 + Double.pi / 4)
                       / tan(toRadians(degrees: getLatitude()) / 2 + Double.pi / 4));
        var q = dLat / dPhi;

        if (!(abs(q) <= Double.greatestFiniteMagnitude)) {
            q = cos(toRadians(degrees: getLatitude()));
        }
        // if dLon over 180° take shorter rhumb across 180° meridian:
        if (dLon > Double.pi) {
            dLon = 2 * Double.pi - dLon;
        }
        let d = sqrt(dLat * dLat + q * q * dLon * dLon);
        return d * earthRadius;
    }
    
    public func toRadians(degrees:Double) -> Double {
        return Double.pi / 180.0
    }
    
    public func toDegrees(radians:Double) -> Double {
        return radians * 180.0 / Double.pi
    }

    /**
     * @see java.lang.Object#toString()
     */
//    public func toString() -> String {
//        StringBuilder sb = new StringBuilder();
//        sb.append("\nLocation Name:\t\t\t").append(getLocationName());
//        sb.append("\nLatitude:\t\t\t").append(getLatitude()).append("\u00B0");
//        sb.append("\nLongitude:\t\t\t").append(getLongitude()).append("\u00B0");
//        sb.append("\nElevation:\t\t\t").append(getElevation()).append(" Meters");
//        sb.append("\nTimezone ID:\t\t\t").append(getTimeZone().getID());
//        sb.append("\nTimezone Display Name:\t\t").append(getTimeZone().getDisplayName())
//                .append(" (").append(getTimeZone().getDisplayName(false, TimeZone.SHORT)).append(")");
//        sb.append("\nTimezone GMT Offset:\t\t").append(getTimeZone().getRawOffset() / HOUR_MILLIS);
//        sb.append("\nTimezone DST Offset:\t\t").append(getTimeZone().getDSTSavings() / HOUR_MILLIS);
//        return sb.toString();
//    }
}
