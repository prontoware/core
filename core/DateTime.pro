////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// CalendarDateTime
////////////////////////////////////////////////////////////////////////////////////////////////////

// Gregorian calendar date representation. Year, month, day, hour, minute, seconds and timezone
// offset. If the timezone offset is anything other than zero, the date values are offset by the
// minutes indicated in the timezone offset. Use DateTime for absolute representations of time,
// which can be converted to CalendarDateTime on-demand when needed.
class CalendarDateTime
{
	// days of week by numerical value
	const u8 SUNDAY    = 0;
	const u8 MONDAY    = 1;
	const u8 TUESDAY   = 2;
	const u8 WEDNESDAY = 3;
	const u8 THURSDAY  = 4;
	const u8 FRIDAY    = 5;
	const u8 SATURDAY  = 6;

	// months of year by numerical value
	const u8 JANUARY    = 1;
	const u8 FEBRUARY   = 2;
	const u8 MARCH      = 3;
	const u8 APRIL      = 4;
	const u8 MAY        = 5;
	const u8 JUNE       = 6;
	const u8 JULY       = 7;
	const u8 AUGUST     = 8;
	const u8 SEPTEMBER  = 9;
	const u8 OCTOBER    = 10;
	const u8 NOVEMBER   = 11;
	const u8 DECEMBER   = 12;

	// useful constants
	const u64 DAY_AS_SECONDS    = 86400;
	const u64 HOUR_AS_SECONDS   = 3600;
	const u64 MINUTE_AS_SECONDS = 60;

	// indexes into dateVals
	const u8 YEAR     = 0; // 1 to 9999
	const u8 MONTH    = 1; // 1-12
	const u8 DAY      = 2; // 1-31
	const u8 HOUR     = 3; // 0-23
	const u8 MINUTE   = 4; // 0-59
	const u8 SECOND   = 5; // 0-59
	const u8 TIMEZONE = 6; // +/- 0-3600 in minutes offset. GMT = 0.

	i16[8] dateVals; // indexed by YEAR, MONTH etc.

	// Create as meaningless year 0 date.
	void constructor()
	{
		for(u8 i=0; i<8; i++)
			dateVals[i] = 0;
	}

	// Copy constructor
	void constructor(CalendarDateTime cal)
	{
		copy(cal);
	}

	// Create as GMT date.
	void constructor(i16 year, i16 month, i16 day, i16 hour, i16 minute, i16 second)
	{
		set(year, month, day, hour, minute, second, 0);
	}

	// Create as date with a timezone offset.
	void constructor(i16 year, i16 month, i16 day, i16 hour, i16 minute, i16 second, i16 timeZoneOffset)
	{
		set(year, month, day, hour, minute, second, timeZoneOffset);
	}

	// Copy passed-in.
	void copy(CalendarDateTime cal)
	{
		for(u8 c=0; c<7; c++)
		{
			this.dateVals[c] = cal.dateVals[c];
		}
	}

	// Replace default equals(). Compare exact to second and including timezone.
	bool equals(IObj obj)
	{
		CalendarDateTime cal = obj;
		if(cal == null)
			return false;

		for(u8 c=0; c<7; c++)
		{
			if(dateVals[c] != cal.dateVals[c])
				return false;
		}

		return true;
	}

	// Checks that none of the year/month/day/hour/minute/second values are out of range.
	bool isValid()
	{
		if(dateVals[YEAR] < 1 || dateVals[YEAR] > 9999)
			return false;

		if(dateVals[MONTH] < 1 || dateVals[MONTH] > 12)
			return false;

		i16 daysInCurMonth = getDaysInMonth(dateVals[YEAR], dateVals[MONTH]);
		if(dateVals[DAY] < 1 || dateVals[DAY] > daysInCurMonth)
			return false;

		if(dateVals[HOUR] < 0 || dateVals[HOUR] > 23)
			return false;

		if(dateVals[MINUTE] < 0 || dateVals[MINUTE] > 59)
			return false;

		if(dateVals[SECOND] < 0 || dateVals[SECOND] > 59)
			return false;

		// we let timezone offsets be up to 24h either way, but if it's more than a day, that's likely unintended.
		if(dateVals[TIMEZONE] < -1440 || dateVals[TIMEZONE] > 1440) 
			return false;

		return true;
	}

	// Constrain (force) all values to be valid. 
	void makeValid()
	{
		dateVals[YEAR]  = Math:minMax(1, 9999, dateVals[YEAR]);
		dateVals[MONTH] = Math:minMax(1, 12, dateVals[MONTH]);
		dateVals[DAY]   = Math:minMax(1, getDaysInMonth(dateVals[YEAR], dateVals[MONTH]), dateVals[DAY]);

		dateVals[HOUR]   = Math:minMax(0, 23, dateVals[HOUR]);
		dateVals[MINUTE] = Math:minMax(0, 59, dateVals[MINUTE]);
		dateVals[SECOND] = Math:minMax(0, 59, dateVals[SECOND]);

		dateVals[TIMEZONE] = Math:minMax(-1440, 1440, dateVals[TIMEZONE]);
	}

	// Get 1 to 9999 year.
	i16 getYear() { return dateVals[YEAR]; }

	// Get 1 to 12 month of year.
	i16 getMonth() { return dateVals[MONTH]; }

	// Get 1 to 31 day of month.
	i16 getDay() { return dateVals[DAY]; }

	// Get 0 to 23 hour of day.
	i16 getHour() { return dateVals[HOUR]; }

	// Get 0 to 59 minute of the hour.
	i16 getMinute() { return dateVals[MINUTE]; }

	// Get 0 to 59 second of the minute.
	i16 getSecond() { return dateVals[SECOND]; }

	// Get -1440 to 1440 timezone offset in minutes.
	i16 getTimeZoneOffset() { return dateVals[TIMEZONE]; }

	// Get day of week - Sunday = 0, Monday = 1 etc.
	i16 getDayOfWeek()
	{
		CalendarDateTime calRef = CalendarDateTime(2016, 12, 18, 12, 0, 0, 0); // 2016 Dec 18th is a sunday, we use as reference day
		DateTime dtRef  = DateTime(calRef);
		DateTime dtThis = DateTime(this);
		i64 secondsGap      = dtThis.timeVal - dtRef.timeVal; // negative for going back in time from 2016/dec/18th
		i64 leftOverSeconds = secondsGap % (7 * DAY_AS_SECONDS);
		i16 dayOfWeek = 0;
		if(leftOverSeconds > 0)
		{
			dayOfWeek = leftOverSeconds / DAY_AS_SECONDS;
		}
		else
		{
			i16 backwardsDayOfWeek = Math:abs(leftOverSeconds / DAY_AS_SECONDS); // 0 is saturday, 1 is friday etc.
			dayOfWeek = 6 - backwardsDayOfWeek;
		}

		return dayOfWeek;
	}

	// Get 1 to 9999 year.
	i16 getYearGMT()
	{
		// already GMT?
		i16 timeZoneOffset = getTimeZoneOffset();
		if(timeZoneOffset == 0)
			return dateVals[YEAR];

		// Other than GMT, remove timezone offset
		removeTimeZoneOffset();

		i16 retVal = dateVals[YEAR];

		// revert to original timezone
		applyTimeZoneOffset(timeZoneOffset);

		return retVal;
	}

	// Get 1 to 12 month of year.
	i16 getMonthGMT()
	{
		// already GMT?
		i16 timeZoneOffset = getTimeZoneOffset();
		if(timeZoneOffset == 0)
			return dateVals[MONTH];

		// Other than GMT, remove timezone offset
		removeTimeZoneOffset();

		i16 retVal = dateVals[MONTH];

		// revert to original timezone
		applyTimeZoneOffset(timeZoneOffset);

		return retVal;
	}

	// Get 1 to 31 day of month.
	i16 getDayGMT()
	{
		// already GMT?
		i16 timeZoneOffset = getTimeZoneOffset();
		if(timeZoneOffset == 0)
			return dateVals[DAY];

		// Other than GMT, remove timezone offset
		removeTimeZoneOffset();

		i16 retVal = dateVals[DAY];

		// revert to original timezone
		applyTimeZoneOffset(timeZoneOffset);

		return retVal;
	}

	// Get 0 to 23 hour of day.
	i16 getHourGMT()
	{
		// already GMT?
		i16 timeZoneOffset = getTimeZoneOffset();
		if(timeZoneOffset == 0)
			return dateVals[HOUR];

		// Other than GMT, remove timezone offset
		removeTimeZoneOffset();

		i16 retVal = dateVals[HOUR];

		// revert to original timezone
		applyTimeZoneOffset(timeZoneOffset);

		return retVal;
	}

	// Get 0 to 59 minute of the hour.
	i16 getMinuteGMT()
	{
		// already GMT?
		i16 timeZoneOffset = getTimeZoneOffset();
		if(timeZoneOffset == 0)
			return dateVals[MINUTE];

		// Other than GMT, remove timezone offset
		removeTimeZoneOffset();

		i16 retVal = dateVals[MINUTE];

		// revert to original timezone
		applyTimeZoneOffset(timeZoneOffset);

		return retVal;
	}

	// Get 0 to 59 second of the minute.
	i16 getSecondGMT()
	{
		// already GMT?
		i16 timeZoneOffset = getTimeZoneOffset();
		if(timeZoneOffset == 0)
			return dateVals[SECOND];

		// Other than GMT, remove timezone offset
		removeTimeZoneOffset();

		i16 retVal = dateVals[SECOND];

		// revert to original timezone
		applyTimeZoneOffset(timeZoneOffset);

		return retVal;
	}

	// Set calendar date/time assuming GMT timezone.
	void set(i16 year, i16 month, i16 day, i16 hour, i16 minute, i16 second)
	{
		this.dateVals[YEAR]     = year;
		this.dateVals[MONTH]    = month;
		this.dateVals[DAY]      = day;
		this.dateVals[HOUR]     = hour;
		this.dateVals[MINUTE]   = minute;
		this.dateVals[SECOND]   = second;
		this.dateVals[TIMEZONE] = 0;
	}

	// Set calendar date/time. timeZoneOffset is in +/- minutes.
	void set(i16 year, i16 month, i16 day, i16 hour, i16 minute, i16 second, i16 timeZoneOffset)
	{
		this.dateVals[YEAR]     = year;
		this.dateVals[MONTH]    = month;
		this.dateVals[DAY]      = day;
		this.dateVals[HOUR]     = hour;
		this.dateVals[MINUTE]   = minute;
		this.dateVals[SECOND]   = second;
		this.dateVals[TIMEZONE] = timeZoneOffset;
	}

	// Apply a timezone offset to this date. This *will* change the date/time values by the amount of the timezone offset. Any existing timezone offset will be reverted before applying this.
	void applyTimeZoneOffset(i16 timeZoneOffset)
	{
		if(timeZoneOffset == 0)
			return;

		removeTimeZoneOffset();
		adjust(timeZoneOffset * 60);
		dateVals[TIMEZONE] = timeZoneOffset;
	}

	// Remove the currently applied timezone offset (if any) making this a GMT+00 date/time.
	void removeTimeZoneOffset()
	{
		if(dateVals[TIMEZONE] == 0)
			return;

		adjust(-1 * dateVals[TIMEZONE] * 60); // timezone is in minutes, adjust() expects seconds
		dateVals[TIMEZONE] = 0;
	}

	// Get the current local (to this computer) time zone offset.
	// shared i16 getLocalTimeZoneOffset() - native built-in function

	// Short format: YYYY-MM-DD HH:mm:SS
	String<u8> toString()
	{
		return toString(false);
	}

	// Short format: YYYY-MM-DD HH:mm:SS
	String<u8> toString(bool dateOnly)
	{
		String<u8> s(32);

		s.appendPadded(String<u8>:formatNumber(getYear()), Chars:ZERO, 4, false);
		s += "-";
		s.appendPadded(String<u8>:formatNumber(getMonth()), Chars:ZERO, 2, false);
		s += "-";
		s.appendPadded(String<u8>:formatNumber(getDay()), Chars:ZERO, 2, false);

		if(dateOnly == false)
		{
			s += " ";
			s.appendPadded(String<u8>:formatNumber(getHour()), Chars:ZERO, 2, false);
			s += ":";
			s.appendPadded(String<u8>:formatNumber(getMinute()), Chars:ZERO, 2, false);
			s += ":";
			s.appendPadded(String<u8>:formatNumber(getSecond()), Chars:ZERO, 2, false);
		}

		return s;
	}

	// Short format: YYYY-MM-DD HH:mm:SS i.e. 2015-10-10 23:08:11
	String<u8> toStringGMT()
	{
		return toStringGMT(false);
	}

	// Short format: YYYY-MM-DD HH:mm:SS i.e. 2015-10-10 23:08:11
	String<u8> toStringGMT(bool dateOnly)
	{
		String<u8> s(32);

		s.appendPadded(String<u8>:formatNumber(getYearGMT()), Chars:ZERO, 4, false);
		s += "-";
		s.appendPadded(String<u8>:formatNumber(getMonthGMT()), Chars:ZERO, 2, false);
		s += "-";
		s.appendPadded(String<u8>:formatNumber(getDayGMT()), Chars:ZERO, 2, false);

		if(dateOnly == false)
		{
			s += " ";
			s.appendPadded(String<u8>:formatNumber(getHourGMT()), Chars:ZERO, 2, false);
			s += ":";
			s.appendPadded(String<u8>:formatNumber(getMinuteGMT()), Chars:ZERO, 2, false);
			s += ":";
			s.appendPadded(String<u8>:formatNumber(getSecondGMT()), Chars:ZERO, 2, false);
		}

		return s;
	}

	// Returns string representation of this date which is RFC1123 compliant. Example "Fri, 18 Sep 2015 07:01:10 GMT".
	String<u8> toRFC1123String()
	{
		// Format:
		// DAY, DD MON YYYY HH:MM:SS GMT
		//
		// Examples:
		// Fri, 18 Sep 2015 07:01:10 GMT
		bool PAD_LEFT = false;

		String<u8> s = String<u8>("");

		// DAY day of week
		s.append(CalendarDateTime:getShortDayOfWeekString(getDayOfWeek()));
		s.append(", ");

		// DD
		s.appendPadded(String<u8>:formatNumber(getDay()), Chars:ZERO, 2, PAD_LEFT);
		s.append(" ");

		// MON
		s.append(CalendarDateTime:getShortMonthString(getMonth()));
		s.append(" ");

		// YYYY
		s.append(String<u8>:formatNumber(getYear()));
		s.append(" ");

		// HH
		s.appendPadded(String<u8>:formatNumber(getHour()), Chars:ZERO, 2, PAD_LEFT);
		s.append(":");

		// MM
		s.appendPadded(String<u8>:formatNumber(getMinute()), Chars:ZERO, 2, PAD_LEFT);
		s.append(":");

		// SS
		s.appendPadded(String<u8>:formatNumber(getSecond()), Chars:ZERO, 2, PAD_LEFT);
		if(getTimeZoneOffset() == 0)
			s.append(" GMT");

		return s;
	}

	// Parse a string representation of this date which is RFC1123 compliant. Example "Fri, 18 Sep 2015 07:01:10 GMT".
	shared CalendarDateTime parseRFC1123String(String<u8> str)
	{
		// Format:
		// DAY, DD MON YYYY HH:MM:SS GMT
		//
		// Examples:
		// Fri, 18 Sep 2015 07:01:10 GMT

		str.trimWhitespace();
		if(str.length() < 3)
			return CalendarDateTime();

		i64 commaIndex = str.findNext(Chars:COMMA, 0);
		if(commaIndex < 0)
			return CalendarDateTime();

		str = str.subString(commaIndex+1, str.length()-1); // don't care about day of week
		str.trimWhitespace();

		str.replaceAll(Chars:COLON, Chars:SPACE); // now we should have DD MON YYYY HH MM SS GMT

		ArrayList<String<u8>> strBits = str.split(Chars:SPACE, true);

		if(strBits.size() < 3)
			return CalendarDateTime(); // need at least date portion to be useful.

		i32 day   = strBits[0].parseInteger();
		i32 month = parseMonth(strBits[1]);
		i32 year  = strBits[2].parseInteger();

		if(strBits.size() < 6)
			return CalendarDateTime(year, month, day, 0, 0, 0); // just return date, no time

		i32 hour   = strBits[3].parseInteger();
		i32 minute = strBits[4].parseInteger();
		i32 second = strBits[5].parseInteger();

		return CalendarDateTime(year, month, day, hour, minute, second);
	}

	// Add/subtract any number of years, months, days, hours, minutes and/or seconds. This is relative to the 
	// currently set date. Year/month advancements can lead to out of bounds day values. For example move 1
	// year forward starting from feb 29 in a leap year. This function will advance the day to fix this, but
	// it can mean moving forward/backward more than expected. Day/hours/minutes/seconds changes do not have
	// this issue.
	void adjust(i64 years, i64 months, i64 days, i64 hours, i64 minutes, i64 seconds)
	{
		this.dateVals[YEAR] += years;

		i64 absMonths = Math:abs(months);
		for(i64 m=0; m<absMonths; m++)
		{
			if(months < 0) // go back in time
			{
				if(this.dateVals[MONTH] == 1) // rollover
				{
					this.dateVals[YEAR]  -= 1;
					this.dateVals[MONTH]  = 12;
				}
				else
				{
					this.dateVals[MONTH] -= 1;
				}
			}
			else // go forward in time
			{
				if(this.dateVals[MONTH] == 12) // rollover
				{
					this.dateVals[YEAR]  += 1;
					this.dateVals[MONTH]  = 1;
				}
				else
				{
					this.dateVals[MONTH] += 1;
				}
			}
		}

		// day could be invalid now, make it valid
		if(dateVals[DAY] > getDaysInMonth(dateVals[YEAR], dateVals[MONTH]))
		{
			// this happens if, for example, we start from jan 30 and advance 1 month to feb 30 which is invalid.
			i16 extraDays = dateVals[DAY] - getDaysInMonth(dateVals[YEAR], dateVals[MONTH]);
			dateVals[DAY] -= extraDays; // valid date now, but we need to add extra days
			adjust(extraDays * DAY_AS_SECONDS); // move into next month etc.
		}

		// days, hours, minutes and seconds can all be done together via adjust(seconds)
		i64 totalSeconds = (days * DAY_AS_SECONDS) + (hours * HOUR_AS_SECONDS) + (minutes * MINUTE_AS_SECONDS) + seconds;
		adjust(totalSeconds);
	}

	// Add/subtract absolute timespan of seconds. Useful for timezone adjustments etc. This is relative to the currently set date.
	void adjust(i64 secondsDelta)
	{
		// we can only march back/forward up to ~28 days at a time due to different days in each month, leap years, special leap years etc.
		i64 numSecondsIn27Days = 27 * DAY_AS_SECONDS; // 60 * 60 * 24 * 27;
		while(Math:abs(secondsDelta) > numSecondsIn27Days)
		{
			// shave off 27 days at a time until we are below threshold
			i64 adjSeconds = numSecondsIn27Days;
			if(secondsDelta < 0)
				adjSeconds *= -1;

			adjust(adjSeconds); // one level of recusion only
			secondsDelta -= adjSeconds;
		}

		// working values
		i64 year   = this.dateVals[YEAR];
		i64 month  = this.dateVals[MONTH];
		i64 day    = this.dateVals[DAY];
		i64 hour   = this.dateVals[HOUR];
		i64 minute = this.dateVals[MINUTE];
		i64 second = this.dateVals[SECOND];

		// add/remove up to 27 days with rollovers for year/month/day etc.
		if(secondsDelta < 0) // going back in time
		{
			secondsDelta = Math:abs(secondsDelta);
			if(secondsDelta > second)
			{
				i64 minutesDelta = Math:ceil(secondsDelta / 60.0);
				if(minutesDelta > minute)
				{
					i64 hoursDelta = Math:ceil(secondsDelta / 3600.0);
					if(hoursDelta > hour)
					{
						i64 daysDelta = Math:ceil(secondsDelta / 86400.0);
						if(daysDelta > (day-1)) // day is 1-31 not 0-30 hence off by 1
						{
							// Need to go back a month. This is where shit hits the fan.
							if(month == 1)
							{
								// have to go back a year before
								year--;
								month = 12;
								day    += getDaysInMonth(year, month); // i.e. add 31 days
								day    -= daysDelta; // subtract some days
								hour   += (daysDelta * 24);
								hour   -= hoursDelta;
								minute += (hoursDelta * 60);
								minute -= minutesDelta;
								second += (minutesDelta * 60);
								second -= secondsDelta;
							}
							else
							{
								month--; // i.e. from feb to january 
								day    += getDaysInMonth(year, month); // i.e. add 31 days
								day    -= daysDelta; // subtract some days
								hour   += (daysDelta * 24);
								hour   -= hoursDelta;
								minute += (hoursDelta * 60);
								minute -= minutesDelta;
								second += (minutesDelta * 60);
								second -= secondsDelta;
							}
						}
						else
						{
							day    -= daysDelta;
							hour   += (daysDelta * 24);
							hour   -= hoursDelta;
							minute += (hoursDelta * 60);
							minute -= minutesDelta;
							second += (minutesDelta * 60);
							second -= secondsDelta;
						}
					}
					else
					{
						hour   -= hoursDelta;
						minute += (hoursDelta * 60);
						minute -= minutesDelta;
						second += (minutesDelta * 60);
						second -= secondsDelta;
					}
				}
				else
				{
					minute -= minutesDelta;
					second += (minutesDelta * 60);
					second -= secondsDelta;
				}
			}
			else
			{
				second -= secondsDelta; // easy
			}
		}
		else // going forward in time
		{
			second += secondsDelta;
			if(second > 59)
			{
				i64 addMinutes = second / 60;
				second = second % 60;

				minute += addMinutes;
				if(minute > 59)
				{
					i64 addHours = minute / 60;
					minute = minute % 60;

					hour += addHours;
					if(hour > 23)
					{
						i64 addDays = hour / 24;
						hour = hour % 24;

						day += addDays; // where shit hits the fan

						// at most we might move one month forward
						u32 daysInCurMonth = getDaysInMonth(year, month);
						if(day >= daysInCurMonth) // day is 1-31 not 0-30 hence off by 1
						{
							// roll forward a month
							if(month == 12)
							{
								// roll forward to next year
								year++;
								month = 1;
								day  -= daysInCurMonth;
							}
							else
							{
								// roll forward a month
								month++;
								day  -= daysInCurMonth;
							}
						}
						// else day is in month range, done
					}
				}
			}
		}

		// store result
		set(year, month, day, hour, minute, second, this.dateVals[TIMEZONE]);
	}

	// Get number of days in month.
	shared u32 getDaysInMonth(u32 year, u32 month)
	{
		if(month == 1) // jan
			return 31;
		else if(month == 2) // feb
		{
			if((year % 4) == 0)
			{
				if((year % 100) == 0)
				{
					// not a leap year unless exactly 400
					if((year % 400) == 0)
						return 29; // leap year in 1600, 2000, 2400 etc.

					return 28; // not a leap year in 1700, 1800, 1900, 2100 etc.
				}

				return 29; // leap year
			}
			else
			{
				return 28; // non leap year
			}
		}
		else if(month == 3) // mar
			return 31;
		else if(month == 4) // apr
			return 30;
		else if(month == 5) // may
			return 31;
		else if(month == 6) // jun
			return 30;
		else if(month == 7) // jul
			return 31;
		else if(month == 8) // aug
			return 31;
		else if(month == 9) // sep
			return 30;
		else if(month == 10) // oct
			return 31;
		else if(month == 11) // nov
			return 30;
		else if(month == 12) // dec
			return 31;

		return 0;
	}

	// Returns "Sunday", "Monday" etc. 0 for Sunday, 1 for Monday etc.
	shared String<u8> getDayOfWeekString(i16 dayOfWeek)
	{
		if(dayOfWeek == 0)
			return String<u8>("Sunday");
		else if(dayOfWeek == 1)
			return String<u8>("Monday");
		else if(dayOfWeek == 2)
			return String<u8>("Tuesday");
		else if(dayOfWeek == 3)
			return String<u8>("Wednesday");
		else if(dayOfWeek == 4)
			return String<u8>("Thursday");
		else if(dayOfWeek == 5)
			return String<u8>("Friday");
		else if(dayOfWeek == 6)
			return String<u8>("Saturday");

		return String<u8>("");
	}

	// Returns "Sun", "Mon" etc. 0 for Sunday, 1 for Monday etc.
	shared String<u8> getShortDayOfWeekString(i16 dayOfWeek)
	{
		if(dayOfWeek == 0)
			return String<u8>("Sun");
		else if(dayOfWeek == 1)
			return String<u8>("Mon");
		else if(dayOfWeek == 2)
			return String<u8>("Tue");
		else if(dayOfWeek == 3)
			return String<u8>("Wed");
		else if(dayOfWeek == 4)
			return String<u8>("Thu");
		else if(dayOfWeek == 5)
			return String<u8>("Fri");
		else if(dayOfWeek == 6)
			return String<u8>("Sat");

		return String<u8>("");
	}

	// Returns "January", "February" etc. 1 for January, 2 for February etc.
	shared String<u8> getMonthString(i16 month)
	{
		if(month == 1)
			return String<u8>("January");
		else if(month == 2)
			return String<u8>("February");
		else if(month == 3)
			return String<u8>("March");
		else if(month == 4)
			return String<u8>("April");
		else if(month == 5)
			return String<u8>("May");
		else if(month == 6)
			return String<u8>("June");
		else if(month == 7)
			return String<u8>("July");
		else if(month == 8)
			return String<u8>("August");
		else if(month == 9)
			return String<u8>("September");
		else if(month == 10)
			return String<u8>("October");
		else if(month == 11)
			return String<u8>("November");
		else if(month == 12)
			return String<u8>("December");

		return String<u8>("");
	}

	// Returns "Jan", "Feb" etc. 1 for January, 2 for February etc.
	shared String<u8> getShortMonthString(i16 month)
	{
		if(month == 1)
			return String<u8>("Jan");
		else if(month == 2)
			return String<u8>("Feb");
		else if(month == 3)
			return String<u8>("Mar");
		else if(month == 4)
			return String<u8>("Apr");
		else if(month == 5)
			return String<u8>("May");
		else if(month == 6)
			return String<u8>("Jun");
		else if(month == 7)
			return String<u8>("Jul");
		else if(month == 8)
			return String<u8>("Aug");
		else if(month == 9)
			return String<u8>("Sep");
		else if(month == 10)
			return String<u8>("Oct");
		else if(month == 11)
			return String<u8>("Nov");
		else if(month == 12)
			return String<u8>("Dec");

		return String<u8>("");
	}

	// Parses month by short/long string (i.e. one of "Jan" or "January"). Not case sensitive. Returns 0 if unknown, or 1-12 for valid month.
	shared i16 parseMonth(String<u8> monStr)
	{
		monStr.toLowercase();
		monStr.trimWhitespace();

		if(monStr.beginsWith("jan"))
			return 1;
		if(monStr.beginsWith("feb"))
			return 2;
		if(monStr.beginsWith("mar"))
			return 3;
		if(monStr.beginsWith("apr"))
			return 4;
		if(monStr.beginsWith("may"))
			return 5;
		if(monStr.beginsWith("jun"))
			return 6;
		if(monStr.beginsWith("jul"))
			return 7;
		if(monStr.beginsWith("aug"))
			return 8;
		if(monStr.beginsWith("sep"))
			return 9;
		if(monStr.beginsWith("oct"))
			return 10;
		if(monStr.beginsWith("nov"))
			return 11;
		if(monStr.beginsWith("dec"))
			return 12;

		return 0; // don't know
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// DateTime
////////////////////////////////////////////////////////////////////////////////////////////////////

// Absolute representation of date/time as seconds from epoch. Can be interpreted as-in various 
// timezones via CalendarDateTime class. This extends the built-in class defintion with additional
// convenience methods.
class DateTime
{
	//i64 timeVal = 0; // declared as built-in member property, class seconds before/after UNIX epoch (Jan 1, 1970)

	// Create a date time set to current time.
	void constructor()
	{
		this.timeVal = DateTime:getSecondsPastEpoch();
	}

	// Create a date time set to seconds past epoch time.
	void constructor(i64 secondsPastEpoch)
	{
		this.timeVal = secondsPastEpoch;
	}

	// Create a date time set to calendar date/time. timeZoneOffset is in minutes where 0 is GMT.
	void constructor(i16 year, i16 month, i16 day, i16 hour, i16 minute, i16 second, i16 timeZoneOffset)
	{
		CalendarDateTime cal = CalendarDateTime(year, month, day, hour, minute, second, timeZoneOffset);
		set(cal);
	}

	// Set from calendar date/time.
	void constructor(CalendarDateTime cal)
	{
		set(cal);
	}

	// Copy passed-in.
	void constructor(DateTime dateTime)
	{
		this.timeVal = dateTime.timeVal;
	}

	// Copy passed-in.
	void copy(DateTime dateTime)
	{
		this.timeVal = dateTime.timeVal;
	}

	// Compare exact to second.
	bool equals(IObj obj)
	{
		DateTime dt = obj;
		if(dt == null)
			return false;

		if(this.timeVal == dt.timeVal)
			return true;

		return false;
	}

	// Get as calendar date time string, format is YYYY-MM-DD HH:mm:SS
	String<u8> toString()
	{
		CalendarDateTime cal = getCalendar();
		return cal.toString();
	}

	// Get as calendar date time string, format is YYYY-MM-DD HH:mm:SS
	String<u8> toString(bool dateOnly)
	{
		CalendarDateTime cal = getCalendar();
		return cal.toString(dateOnly);
	}

	// Get as calendar date time string, format is YYYY-MM-DD HH:mm:SS
	String<u8> toStringGMT()
	{
		CalendarDateTime cal = getCalendar();
		return cal.toStringGMT();
	}

	// Get as calendar date time string, format is YYYY-MM-DD HH:mm:SS
	String<u8> toStringGMT(bool dateOnly)
	{
		CalendarDateTime cal = getCalendar();
		return cal.toStringGMT(dateOnly);
	}

	// Returns string representation of this date which is RFC1123 compliant. Example "Fri, 18 Sep 2015 07:01:10 GMT".
	String<u8> toRFC1123String()
	{
		CalendarDateTime cal = getCalendar();
		return cal.toRFC1123String();
	}

	// Set from CalendarDateTime representation.
	void set(CalendarDateTime cal)
	{
		if(cal == null)
			return;

		// go to GMT if needed
		i16 timeZoneOffset = cal.getTimeZoneOffset();
		cal.removeTimeZoneOffset();

		this.timeVal = convertCalendarToEpochRel_native(cal.dateVals);

		// revert to original timezone
		cal.applyTimeZoneOffset(timeZoneOffset);
	}

	// Get calendar representation. CalendarDateTime always returned represented in GMT+00 timezone.
	CalendarDateTime getCalendar()
	{
		CalendarDateTime cal = CalendarDateTime();
		cal.dateVals = DateTime:convertEpochRelToCalendar_native(this.timeVal);
		return cal;
	}

	// Within range, inclusive.
	bool withinRange(DateTime start, DateTime end)
	{
		if(this.timeVal < start.timeVal)
			return false;

		if(this.timeVal > end.timeVal)
			return false;

		return true;
	}

	// Within range, inclusive.
	bool withinRange(CalendarDateTime startCal, CalendarDateTime endCal)
	{
		DateTime start(startCal);
		DateTime end(endCal);

		return withinRange(start, end);
	}
}