import java.io.*;
import java.lang.reflect.Method;
import java.time.*;
import java.util.*;
import java.util.zip.GZIPOutputStream;

import com.kosherjava.zmanim.*;
import com.kosherjava.zmanim.util.*;

/**
 * Generates golden values from KosherJava for KosherSwift's cross-check tests (Tests/KosherSwiftTests/GoldenZmanimTests.swift).
 * Output: zmanim.tsv.gz in the directory passed as the first argument.
 */
public class GoldenGenerator {

	static final String[][] LOCATIONS = {
		// name, lat, lon, elev, zone, horizonSunrise, horizonSunset
		{"lakewood", "40.0721087", "-74.2400243", "15", "America/New_York", "0", "0"},
		{"woodcliff", "41.1181036", "-74.0840691", "167", "America/New_York", "0", "0"},
		{"la", "34.0201613", "-118.6919095", "71", "America/Los_Angeles", "0", "0"},
		{"jerusalem", "31.7962994", "35.1053185", "754", "Asia/Jerusalem", "0", "0"},
		{"norway", "70.1498248", "9.1456867", "0", "Europe/Oslo", "0", "0"},
		{"sydney", "-33.8688", "151.2093", "58", "Australia/Sydney", "0", "0"},
		{"macapa", "0.0349", "-51.0694", "15", "America/Belem", "0", "0"},
		{"suva", "-18.1416", "178.4419", "6", "Pacific/Fiji", "0", "0"},
		{"ushuaia", "-54.8019", "-68.3030", "23", "America/Argentina/Ushuaia", "0", "0"},
		{"apia", "-13.8333", "-171.75", "2", "Pacific/Apia", "0", "0"},
		{"horizon", "31.7683", "35.2137", "800", "Asia/Jerusalem", "650", "720"},
		{"utc", "51.4772", "0", "0", "UTC", "0", "0"},
	};

	static List<LocalDate> dates() {
		TreeSet<LocalDate> set = new TreeSet<>();
		LocalDate d = LocalDate.of(2025, 1, 3);
		while (d.isBefore(LocalDate.of(2027, 1, 1))) { // every 17 days for two years
			set.add(d);
			d = d.plusDays(17);
		}
		String[] specials = {"2026-03-08", "2026-03-07", "2026-03-27", "2026-03-29", "2026-11-01", "2026-10-25",
			"2026-04-05", "2026-10-04", "2026-06-21", "2026-12-21", "2026-03-20", "2026-09-23", "2024-02-29",
			"2017-10-17", "1969-02-08", "1900-01-01", "1950-07-15", "2000-01-01", "2050-06-15", "2099-12-31",
			"2011-12-29", "2011-12-31", "2018-02-03", "2026-01-01", "2026-12-31", "2027-12-15", "2026-05-15",
			"2026-07-15", "2026-08-15", "2026-01-15", "2026-04-01", "2025-04-12"};
		for (String s : specials) {
			set.add(LocalDate.parse(s));
		}
		return new ArrayList<>(set);
	}

	static String fmt(Object value) {
		if (value == null) return "null";
		if (value instanceof Instant) {
			Instant i = (Instant) value;
			return "I" + i.getEpochSecond() + "." + String.format("%09d", i.getNano());
		}
		if (value instanceof Duration) {
			Duration d = (Duration) value;
			return "D" + d.getSeconds() + "." + String.format("%09d", d.getNano());
		}
		return value.toString();
	}

	static List<Method> methods(Class<?> c, Class<?>... types) {
		List<Method> list = new ArrayList<>();
		for (Method m : c.getMethods()) {
			if (m.getParameterCount() != 0 || m.getDeclaringClass() == Object.class) continue;
			if (!m.getName().startsWith("get")) continue;
			for (Class<?> t : types) {
				if (m.getReturnType() == t) {
					list.add(m);
					break;
				}
			}
		}
		list.sort(Comparator.comparing(Method::getName));
		return list;
	}

	public static void main(String[] args) throws Exception {
		String outDir = args[0];
		List<Method> all = methods(ComprehensiveZmanimCalendar.class, Instant.class, Duration.class);
		Set<String> basic = new TreeSet<>(Arrays.asList("getSunrise", "getSeaLevelSunrise", "getSunset", "getSeaLevelSunset",
			"getBeginCivilTwilight", "getBeginNauticalTwilight", "getBeginAstronomicalTwilight", "getEndCivilTwilight",
			"getEndNauticalTwilight", "getEndAstronomicalTwilight", "getSunTransit", "getSolarMidnight", "getTemporalHour",
			"getAlos16Point1Degrees", "getAlos72Minutes", "getTzaisGeonim8Point5Degrees", "getTzais72Minutes", "getSofZmanShmaGRA",
			"getSofZmanShmaMGA72Minutes", "getChatzosHayom", "getChatzosHayomAsHalfDay", "getChatzosHalayla", "getMinchaGedolaGRA",
			"getPlagHaminchaGRA", "getShaahZmanisGRA", "getAlos19Point8Degrees", "getTzaisGeonim3Point7Degrees",
			"getMisheyakir11Point5Degrees", "getPolarSunriseBenIshChai", "getPolarSunsetBenIshChai"));
		String[] calcs = {"NOAA", "SPA", "Meeus", "SunTimes"};
		int count = 0;
		try (Writer w = new OutputStreamWriter(new GZIPOutputStream(new FileOutputStream(outDir + "/zmanim.tsv.gz")), "UTF-8")) {
			StringBuilder header = new StringBuilder("#Z\tlocation\tdate\tcalculator\tconfig");
			for (Method m : all) header.append('\t').append(m.getName());
			w.write(header + "\n");
			StringBuilder basicHeader = new StringBuilder("#B\tlocation\tdate\tcalculator\tconfig");
			for (Method m : all) if (basic.contains(m.getName())) basicHeader.append('\t').append(m.getName());
			w.write(basicHeader + "\n");
			for (String[] loc : LOCATIONS) {
				GeoLocation geo = new GeoLocation(loc[0], Double.parseDouble(loc[1]), Double.parseDouble(loc[2]),
					Double.parseDouble(loc[3]), Double.parseDouble(loc[5]), Double.parseDouble(loc[6]), ZoneId.of(loc[4]));
				for (String calcName : calcs) {
					for (int cfg = 0; cfg < 2; cfg++) {
						if (cfg == 1 && !calcName.equals("NOAA")) continue;
						for (LocalDate date : dates()) {
							ComprehensiveZmanimCalendar czc = new ComprehensiveZmanimCalendar(geo);
							czc.setAstronomicalCalculator(calculator(calcName));
							if (cfg == 1) {
								czc.setUseElevation(true);
								czc.setUseAstronomicalChatzos(false);
								czc.setUseAstronomicalChatzosForOtherZmanim(true);
								czc.setCandleLightingOffset(40);
								czc.setAteretTorahSunsetOffset(30);
							}
							czc.setLocalDate(date);
							boolean full = calcName.equals("NOAA");
							StringBuilder row = new StringBuilder(full ? "Z" : "B");
							row.append('\t').append(loc[0]).append('\t').append(date).append('\t').append(calcName).append('\t').append(cfg);
							for (Method m : all) {
								if (!full && !basic.contains(m.getName())) continue;
								Object value;
								try {
									value = m.invoke(czc);
								} catch (Exception e) {
									value = "EX:" + e.getCause().getClass().getSimpleName();
								}
								row.append('\t').append(fmt(value));
								count++;
							}
							w.write(row + "\n");
						}
					}
				}
			}
			// low level calculator values at many zeniths
			double[] zeniths = {90, 90.833, 96, 102, 108, 106.1, 109.8, 98.5, 93.7, 84, 80};
			w.write("#C\tlocation\tdate\tcalculator\tzeniths=90,90.833,96,102,108,106.1,109.8,98.5,93.7,84,80 x adj(0,1) x (rise,set); noon; midnight; (elev,az) at -9..9 step 3 h (+1234 s) from local mean noon; time at azimuth 90,270\n");
			for (String[] loc : LOCATIONS) {
				GeoLocation geo = new GeoLocation(loc[0], Double.parseDouble(loc[1]), Double.parseDouble(loc[2]),
					Double.parseDouble(loc[3]), Double.parseDouble(loc[5]), Double.parseDouble(loc[6]), ZoneId.of(loc[4]));
				for (String calcName : calcs) {
					AstronomicalCalculator c = calculator(calcName);
					for (LocalDate date : dates()) {
						StringBuilder row = new StringBuilder("C\t" + loc[0] + "\t" + date + "\t" + calcName);
						for (double z : zeniths) {
							for (int adj = 0; adj < 2; adj++) {
								row.append('\t').append(c.getUTCSunrise(date, geo, z, adj == 1));
								row.append('\t').append(c.getUTCSunset(date, geo, z, adj == 1));
							}
						}
						row.append('\t').append(c.getUTCNoon(date, geo));
						row.append('\t').append(c.getUTCMidnight(date, geo));
						if (!calcName.equals("SunTimes")) {
							Instant noonish = date.atTime(12, 0).atZone(ZoneOffset.UTC).toInstant().minusSeconds((long) (geo.getLongitude() * 240));
							for (int h = -9; h <= 9; h += 3) {
								Instant at = noonish.plusSeconds(h * 3600L + 1234);
								row.append('\t').append(c.getSolarElevation(at, geo));
								row.append('\t').append(c.getSolarAzimuth(at, geo));
							}
							for (double az : new double[] {90, 270}) {
								row.append('\t').append(c.getTimeAtAzimuth(date, geo, az));
							}
						}
						w.write(row + "\n");
					}
				}
			}
		}
		System.out.println("zmanim values: " + count);
	}

	static AstronomicalCalculator calculator(String name) {
		switch (name) {
			case "SPA": return new SPACalculator();
			case "Meeus": return new MeeusCalculator();
			case "SunTimes": return new SunTimesCalculator();
			default: return new NOAACalculator();
		}
	}
}
