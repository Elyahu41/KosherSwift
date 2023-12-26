//
//  AstronomicalCalculator.swift
//  KosherSwift
//
//  Created by Elyahu Jacobi on 12/21/23.
//

import Foundation

/**
 * An abstract class that all sun time calculating classes extend. This allows the algorithm used to be changed at
 * runtime, easily allowing comparison the results of using different algorithms.
 * @todo Consider methods that would allow atmospheric modeling. This can currently be adjusted by {@link
 * #setRefraction(double) setting the refraction}.
 *
 * @author &copy; Eliyahu Hershfeld 2004 - 2023
 */
public class AstronomicalCalculator {
    /**
     * The commonly used average solar refraction. Calendrical Calculations lists a more accurate global average of
     * 34.478885263888294
     *
     * @see #getRefraction()
     */
    public var refraction = 34.0 / 60.0;

    /**
     * The commonly used average solar radius in minutes of a degree.
     *
     * @see #getSolarRadius()
     */
    public var solarRadius = 16.0 / 60.0;

    /**
     * The commonly used average earth radius in KM. At this time, this only affects elevation adjustment and not the
     * sunrise and sunset calculations. The value currently defaults to 6356.9 KM.
     *
     * @see #getEarthRadius()
     * @see #setEarthRadius(double)
     */
    public var earthRadius = 6356.9; // in KM

    /**
     * A method that returns the earth radius in KM. The value currently defaults to 6356.9 KM if not set.
     *
     * @return the earthRadius the earth radius in KM.
     */
    public func getEarthRadius() -> Double {
        return earthRadius;
    }

    /**
     * A method that allows setting the earth's radius.
     *
     * @param earthRadius
     *            the earthRadius to set in KM
     */
    public func setEarthRadius(earthRadius:Double) {
        self.earthRadius = earthRadius;
    }

    /**
     * The zenith of astronomical sunrise and sunset. The sun is 90&deg; from the vertical 0&deg;
     */
    public static let GEOMETRIC_ZENITH = 90.0;

    /**
     * Returns the default class for calculating sunrise and sunset. This is currently the {@link NOAACalculator},
     * but this may change. The NOAACalculator is the most accurate sunrise/sunset calculator that is currently available.
     * It should be prefered over the SunTimesCalculator.
     *
     * @return AstronomicalCalculator the default class for calculating sunrise and sunset. In the current
     *         implementation the default calculator returned is the {@link NOAACalculator}.
     */
    public static func getDefault(geoLocation: GeoLocation) -> AstronomicalCalculator {
        return NOAACalculator(geoLocation: geoLocation);
    }
    
    /**
     * Method to return the adjustment to the zenith required to account for the elevation. Since a person at a higher
     * elevation can see farther below the horizon, the calculation for sunrise / sunset is calculated below the horizon
     * used at sea level. This is only used for sunrise and sunset and not times before or after it such as
     * {@link com.kosherjava.zmanim.AstronomicalCalendar#getBeginNauticalTwilight() nautical twilight} since those
     * calculations are based on the level of available light at the given dip below the horizon, something that is not
     * affected by elevation, the adjustment should only made if the zenith == 90&deg; {@link #adjustZenith adjusted}
     * for refraction and solar radius. The algorithm used is
     *
     * <pre>
     * elevationAdjustment = Math.toDegrees(Math.acos(earthRadiusInMeters / (earthRadiusInMeters + elevationMeters)));
     * </pre>
     *
     * The source of this algorithm is <a href="http://www.calendarists.com">Calendrical Calculations</a> by Edward M.
     * Reingold and Nachum Dershowitz. An alternate algorithm that produces an almost identical (but not accurate)
     * result found in Ma'aglay Tzedek by Moishe Kosower and other sources is:
     *
     * <pre>
     * elevationAdjustment = 0.0347 * Math.sqrt(elevationMeters);
     * </pre>
     *
     * @param elevation
     *            elevation in Meters.
     * @return the adjusted zenith
     */
    func getElevationAdjustment(elevation:Double) -> Double {
        let elevationAdjustment = NOAACalculator.toDegrees(radians: (acos(earthRadius / (earthRadius + (elevation / 1000)))));
        return elevationAdjustment;
    }

    /**
     * Adjusts the zenith of astronomical sunrise and sunset to account for solar refraction, solar radius and
     * elevation. The value for Sun's zenith and true rise/set Zenith (used in this class and subclasses) is the angle
     * that the center of the Sun makes to a line perpendicular to the Earth's surface. If the Sun were a point and the
     * Earth were without an atmosphere, true sunset and sunrise would correspond to a 90&deg; zenith. Because the Sun
     * is not a point, and because the atmosphere refracts light, this 90&deg; zenith does not, in fact, correspond to
     * true sunset or sunrise, instead the center of the Sun's disk must lie just below the horizon for the upper edge
     * to be obscured. This means that a zenith of just above 90&deg; must be used. The Sun subtends an angle of 16
     * minutes of arc (this can be changed via the {@link #setSolarRadius(double)} method , and atmospheric refraction
     * accounts for 34 minutes or so (this can be changed via the {@link #setRefraction(double)} method), giving a total
     * of 50 arcminutes. The total value for ZENITH is 90+(5/6) or 90.8333333&deg; for true sunrise/sunset. Since a
     * person at an elevation can see blow the horizon of a person at sea level, this will also adjust the zenith to
     * account for elevation if available. Note that this will only adjust the value if the zenith is exactly 90 degrees.
     * For values below and above this no correction is done. As an example, astronomical twilight is when the sun is
     * 18&deg; below the horizon or {@link com.kosherjava.zmanim.AstronomicalCalendar#ASTRONOMICAL_ZENITH 108&deg;
     * below the zenith}. This is traditionally calculated with none of the above mentioned adjustments. The same goes
     * for various <em>tzais</em> and <em>alos</em> times such as the
     * {@link com.kosherjava.zmanim.ZmanimCalendar#ZENITH_16_POINT_1 16.1&deg;} dip used in
     * {@link com.kosherjava.zmanim.ComplexZmanimCalendar#getAlos16Point1Degrees()}.
     *
     * @param zenith
     *            the azimuth below the vertical zenith of 90&deg;. For sunset typically the {@link #adjustZenith
     *            zenith} used for the calculation uses geometric zenith of 90&deg; and {@link #adjustZenith adjusts}
     *            this slightly to account for solar refraction and the sun's radius. Another example would be
     *            {@link com.kosherjava.zmanim.AstronomicalCalendar#getEndNauticalTwilight()} that passes
     *            {@link com.kosherjava.zmanim.AstronomicalCalendar#NAUTICAL_ZENITH} to this method.
     * @param elevation
     *            elevation in Meters.
     * @return The zenith adjusted to include the {@link #getSolarRadius sun's radius}, {@link #getRefraction
     *         refraction} and {@link #getElevationAdjustment elevation} adjustment. This will only be adjusted for
     *         sunrise and sunset (if the zenith == 90&deg;)
     * @see #getElevationAdjustment(double)
     */
    func adjustZenith(zenith:Double, elevation:Double) -> Double {
        var adjustedZenith = zenith;
        if (zenith == AstronomicalCalculator.GEOMETRIC_ZENITH) { // only adjust if it is exactly sunrise or sunset
            adjustedZenith = zenith + (getSolarRadius() + getRefraction() + getElevationAdjustment(elevation: elevation));
        }
        return adjustedZenith;
    }

    /**
     * Method to get the refraction value to be used when calculating sunrise and sunset. The default value is 34 arc
     * minutes. The <a href=
     * "https://web.archive.org/web/20150915094635/http://emr.cs.iit.edu/home/reingold/calendar-book/second-edition/errata.pdf"
     * >Errata and Notes for Calendrical Calculations: The Millennium Edition</a> by Edward M. Reingold and Nachum Dershowitz
     * lists the actual average refraction value as 34.478885263888294 or approximately 34' 29". The refraction value as well
     * as the solarRadius and elevation adjustment are added to the zenith used to calculate sunrise and sunset.
     *
     * @return The refraction in arc minutes.
     */
    public func getRefraction() -> Double {
        return self.refraction;
    }

    /**
     * A method to allow overriding the default refraction of the calculator.
     * @todo At some point in the future, an AtmosphericModel or Refraction object that models the atmosphere of different
     * locations might be used for increased accuracy.
     *
     * @param refraction
     *            The refraction in arc minutes.
     * @see #getRefraction()
     */
    public func setRefraction(refraction:Double) {
        self.refraction = refraction;
    }

    /**
     * Method to get the sun's radius. The default value is 16 arc minutes. The sun's radius as it appears from earth is
     * almost universally given as 16 arc minutes but in fact it differs by the time of the year. At the <a
     * href="https://en.wikipedia.org/wiki/Perihelion">perihelion</a> it has an apparent radius of 16.293, while at the
     * <a href="https://en.wikipedia.org/wiki/Aphelion">aphelion</a> it has an apparent radius of 15.755. There is little
     * affect for most location, but at high and low latitudes the difference becomes more apparent. My Calculations for
     * the difference at the location of the <a href="https://www.rmg.co.uk/royal-observatory">Royal Observatory, Greenwich</a>
     * shows only a 4.494 second difference between the perihelion and aphelion radii, but moving into the arctic circle the
     * difference becomes more noticeable. Tests for Tromso, Norway (latitude 69.672312, longitude 19.049787) show that
     * on May 17, the rise of the midnight sun, a 2 minute 23 second difference is observed between the perihelion and
     * aphelion radii using the USNO algorithm, but only 1 minute and 6 seconds difference using the NOAA algorithm.
     * Areas farther north show an even greater difference. Note that these test are not real valid test cases because
     * they show the extreme difference on days that are not the perihelion or aphelion, but are shown for illustrative
     * purposes only.
     *
     * @return The sun's radius in arc minutes.
     */
    public func getSolarRadius() -> Double {
        return self.solarRadius;
    }

    /**
     * Method to set the sun's radius.
     *
     * @param solarRadius
     *            The sun's radius in arc minutes.
     * @see #getSolarRadius()
     */
    public func setSolarRadius(solarRadius:Double) {
        self.solarRadius = solarRadius;
    }
    
    /*
     Do not use this method directly, it must be overrided by sub classes like the NOAACalculator class
     */
    public func getUTCSunrise(date: Date, geoLocation: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double {
        return Double.nan
    }
    /*
     Do not use this method directly, it must be overrided by sub classes like the NOAACalculator class
     */
    public func getUTCSunset(date: Date, geoLocation: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double {
        return Double.nan
    }
    /*
     Do not use this method directly, it must be overrided by sub classes like the NOAACalculator class
     */
    public func getUTCNoon(date: Date, geoLocation: GeoLocation) -> Double {
        return Double.nan
    }
}
