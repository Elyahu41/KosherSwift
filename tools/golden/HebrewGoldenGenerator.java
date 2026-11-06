import java.io.*;
import java.lang.reflect.Method;
import java.time.*;
import java.util.*;
import java.util.zip.GZIPOutputStream;

import com.kosherjava.zmanim.hebrewcalendar.*;

/**
 * Generates golden values from KosherJava's JewishCalendar, TefilaRules and HebrewDateFormatter for KosherSwift's
 * cross-check tests (Tests/KosherSwiftTests/GoldenHebrewCalendarTests.swift).
 * Output: hebrew.tsv.gz in the directory passed as the first argument.
 */
public class HebrewGoldenGenerator {

	/** The JewishCalendar methods compared, by their KosherJava names. */
	static final String[] METHODS = {"getJewishYear", "getJewishMonth", "getJewishDayOfMonth", "getDayOfWeek", "getYomTovIndex",
		"getDayOfOmer", "getDayOfChanukah", "getDaysInJewishMonth", "getDaysInJewishYear", "getDaysSinceStartOfJewishYear",
		"getCheshvanKislevKviah", "getTekufasTishreiElapsedDays", "getChalakimSinceMoladTohu", "isJewishLeapYear", "isCheshvanLong",
		"isKislevShort", "hasCandleLighting", "isAseresYemeiTeshuva", "isAssurBemelacha", "isBeHaB", "isBirkasHachamah", "isChanukah",
		"isCholHamoed", "isCholHamoedPesach", "isCholHamoedSuccos", "isErevRoshChodesh", "isErevYomTov", "isErevYomTovSheni",
		"isHoshanaRabba", "isIsruChag", "isMacharChodesh", "isPesach", "isPurim", "isRoshChodesh", "isRoshHashana",
		"isShabbosMevorchim", "isShavuos", "isShminiAtzeres", "isSimchasTorah", "isSuccos", "isTaanis", "isTaanisBechoros",
		"isTishaBav", "isTomorrowShabbosOrYomTov", "isTonightMutarBemelacha", "isYomKippur", "isYomKippurKatan", "isYomTov",
		"isYomTovAssurBemelacha", "getParshah", "getUpcomingParshah", "getSpecialShabbos", "getDafYomiBavli", "getDafYomiYerushalmi",
		"getMoladAsInstant", "getTchilasZmanKidushLevana3Days", "getTchilasZmanKidushLevana7Days",
		"getSofZmanKidushLevanaBetweenMoldos", "getSofZmanKidushLevana15Days"};

	static String fmt(Object value) {
		if (value == null) return "null";
		if (value instanceof Instant) {
			Instant i = (Instant) value;
			return "I" + i.getEpochSecond() + "." + String.format("%09d", i.getNano());
		}
		if (value instanceof Daf) return ((Daf) value).getMasechtaNumber() + ":" + ((Daf) value).getDaf();
		return value.toString();
	}

	public static void main(String[] args) throws Exception {
		List<Method> rules = new ArrayList<>();
		for (Method m : TefilaRules.class.getMethods()) {
			if (m.getParameterCount() == 1 && m.getParameterTypes()[0] == JewishCalendar.class && m.getReturnType() == boolean.class) {
				rules.add(m);
			}
		}
		rules.sort(Comparator.comparing(Method::getName));
		TefilaRules tefilaRules = new TefilaRules();
		HebrewDateFormatter he = new HebrewDateFormatter();
		he.setHebrewFormat(true);
		HebrewDateFormatter en = new HebrewDateFormatter();
		String[] formats = {"format", "formatYomTov", "formatRoshChodesh", "formatParshah", "formatSpecialParshah", "formatOmer",
			"formatDayOfWeek", "formatMonth", "formatDafYomiBavli", "formatDafYomiYerushalmi"};
		try (Writer w = new OutputStreamWriter(new GZIPOutputStream(new FileOutputStream(args[0] + "/hebrew.tsv.gz")), "UTF-8")) {
			StringBuilder header = new StringBuilder("#H\tdate\tconfig");
			for (String m : METHODS) header.append('\t').append(m);
			header.append("\tgetMolad.hours\tgetMolad.minutes\tgetMolad.chalakim");
			for (Method m : rules) header.append("\tTefilaRules.").append(m.getName());
			for (String f : new String[] {"he.", "en."}) for (String n : formats) header.append('\t').append(f).append(n);
			w.write(header + "\n");
			LocalDate d = LocalDate.of(1981, 1, 1);
			LocalDate end = LocalDate.of(2100, 12, 31);
			while (!d.isAfter(end)) {
				boolean dense = d.getYear() >= 2024 && d.getYear() <= 2027;
				for (int cfg = 0; cfg < 2; cfg++) {
					JewishCalendar jc = new JewishCalendar(d);
					jc.setInIsrael(cfg == 1);
					jc.setUseModernHolidays(cfg == 1);
					StringBuilder row = new StringBuilder("H\t" + d + "\t" + cfg);
					for (String name : METHODS) {
						Object value;
						try {
							value = JewishCalendar.class.getMethod(name).invoke(jc);
						} catch (java.lang.reflect.InvocationTargetException e) {
							value = "EX:" + e.getCause().getClass().getSimpleName();
						}
						row.append('\t').append(fmt(value));
					}
					JewishDate molad = jc.getMolad();
					row.append('\t').append(molad.getMoladHours()).append('\t').append(molad.getMoladMinutes()).append('\t').append(molad.getMoladChalakim());
					for (Method m : rules) {
						row.append('\t').append(fmt(m.invoke(tefilaRules, jc)));
					}
					for (HebrewDateFormatter f : new HebrewDateFormatter[] {he, en}) {
						row.append('\t').append(f.format(jc));
						row.append('\t').append(f.formatYomTov(jc));
						row.append('\t').append(f.formatRoshChodesh(jc));
						row.append('\t').append(f.formatParshah(jc));
						row.append('\t').append(f.formatSpecialParshah(jc));
						row.append('\t').append(f.formatOmer(jc));
						row.append('\t').append(f.formatDayOfWeek(jc));
						row.append('\t').append(f.formatMonth(jc));
						row.append('\t').append(jc.getDafYomiBavli() == null ? "null" : f.formatDafYomiBavli(jc.getDafYomiBavli()));
						row.append('\t').append(jc.getDafYomiYerushalmi() == null ? "null" : f.formatDafYomiYerushalmi(jc.getDafYomiYerushalmi()));
					}
					w.write(row + "\n");
				}
				d = d.plusDays(dense ? 1 : 3);
			}
			for (int n = 0; n <= 9999; n += (n < 1000 ? 1 : 7)) {
				w.write("N\t" + n + "\t" + he.formatHebrewNumber(n) + "\n");
			}
		}
	}
}
