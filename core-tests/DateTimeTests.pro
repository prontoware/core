////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

class DateTimeTests implements IUnitTest
{
	void run()
	{
		DateTime dt1 = DateTime(); // should be current date time
		test(dt1.timeVal != 0); // epoch!

		test(dt1.timeVal > 1481924197); // 1481924197 is approx dec 16th 2016 @ 16:37 and since we can't time travel, this is a good test

		DateTime dt2 = DateTime(dt1);
		test(dt2.equals(dt1) == true);
	}
}

class CalendarBasicTests implements IUnitTest
{
	void run()
	{
		DateTime dt1 = DateTime(); // should be current date time
		CalendarDateTime cal = dt1.getCalendar();
		test(cal.getYear() > 2016);

		cal.set(1990, 1, 2, 12, 30, 1);
		test(cal.getYear() == 1990);
		test(cal.getMonth() == 1);
		test(cal.getDay() == 2);
		test(cal.getDayOfWeek() == 2); // 2 == tuesday

		CalendarDateTime calB = CalendarDateTime(cal);
		test(calB.equals(cal) == true);
		test(calB.isValid() == true);

		calB.set(1999, 1, 2, 12, 30, 60); // invalid
		test(calB.isValid() == false);
	}
}

class CalendarToStringTests implements IUnitTest
{
	void run()
	{
		DateTime dt1 = DateTime(); // should be current date time
		CalendarDateTime calA = dt1.getCalendar();
		test(calA.equals(calA) == true);
		test(calA.isValid() == true);

		calA.set(1999, 1, 2, 12, 30, 60); // invalid
		test(calA.isValid() == false);

		calA.set(2016, 12, 16, 12, 9, 7);
		String<u8> defStr = calA.toString(); // to string has short format
		test(defStr.compare("2016-12-16 12:09:07") == true);
		String<u8> rfcStr = calA.toRFC1123String();
		test(rfcStr.compare("Fri, 16 Dec 2016 12:09:07 GMT") == true); // i.e. "Fri, 18 Sep 2015 07:01:10 GMT"

		CalendarDateTime calB = CalendarDateTime:parseRFC1123String(rfcStr);
		test(calB.equals(calA) == true);
	}
}

class CalendarAdjTests implements IUnitTest
{
	void run()
	{
		CalendarDateTime calA = CalendarDateTime();
		calA.set(2000, 1, 15, 12, 30, 1); // jan 15th, 2000

		CalendarDateTime calB = CalendarDateTime(calA); // for comparison later

		// go back a day by seconds
		i64 negDay = -1 * CalendarDateTime:DAY_AS_SECONDS;
		test(negDay == -86400);
		calA.adjust(negDay);
		test(calA.getDay() == 14);
		test(calA.getYear() == 2000);
		test(calA.getMonth() == 1);
		test(calA.getHour() == 12);
		test(calA.getMinute() == 30);
		test(calA.getSecond() == 1); // everything else should be unchanged...

		// go forward a day by seconds (to original date/time)
		calA.adjust(1 * CalendarDateTime:DAY_AS_SECONDS);
		test(calA.getDay() == 15); // only change
		test(calA.getYear() == 2000);
		test(calA.getMonth() == 1);
		test(calA.getHour() == 12);
		test(calA.getMinute() == 30);
		test(calA.getSecond() == 1);

		// adjust by year/month/days/hours/minutes/seconds.

		// go back a year
		calA.adjust(-1, 0, 0, 0, 0, 0);
		test(calA.getYear() == 1999); // only change
		test(calA.getMonth() == 1);
		test(calA.getDay() == 15);
		test(calA.getHour() == 12);
		test(calA.getMinute() == 30);
		test(calA.getSecond() == 1);

		// go back a month, which pushes us back a year too
		calA.adjust(0, -1, 0, 0, 0, 0);
		test(calA.getYear() == 1998); // back to dec 98'
		test(calA.getMonth() == 12); // dec now
		test(calA.getDay() == 15); // everything else unchanged
		test(calA.getHour() == 12);
		test(calA.getMinute() == 30);
		test(calA.getSecond() == 1);

		// go back 15 days, which pushes us back a month too
		calA.adjust(0, 0, -15, 0, 0, 0);
		test(calA.getMonth() == 11);
		test(calA.getDay() == 30); // 30 days in november
		test(calA.getYear() == 1998); // everything else unchanged
		test(calA.getHour() == 12);
		test(calA.getMinute() == 30);
		test(calA.getSecond() == 1);

		// go back 3 hours
		calA.adjust(0, 0, 0, -3, 0, 0);
		test(calA.getHour() == 9); // 12 to 9
		test(calA.getYear() == 1998); // everything else unchanged
		test(calA.getMonth() == 11);
		test(calA.getDay() == 30);
		test(calA.getMinute() == 30);
		test(calA.getSecond() == 1);

		// go back 10 minutes
		calA.adjust(0, 0, 0, 0, -10, 0);
		test(calA.getMinute() == 20); // changes 30 to 20
		test(calA.getYear() == 1998);
		test(calA.getMonth() == 11);
		test(calA.getDay() == 30);
		test(calA.getHour() == 9);
		test(calA.getSecond() == 1);

		// go forward 10 years
		calA.adjust(10, 0, 0, 0, 0, 0);
		test(calA.getYear() == 2008); // only change
		test(calA.getMonth() == 11);
		test(calA.getDay() == 30);
		test(calA.getHour() == 9);
		test(calA.getMinute() == 20);
		test(calA.getSecond() == 1);

		// go forward 4 months, which pushes us up a year
		calA.adjust(0, 4, 0, 0, 0, 0);
		test(calA.getYear() == 2009);
		test(calA.getMonth() == 3);
		test(calA.getDay() == 30);
		test(calA.getHour() == 9);
		test(calA.getMinute() == 20);
		test(calA.getSecond() == 1);

		// go forward 4 days, which pushes us up a month too
		calA.adjust(0, 0, 4, 0, 0, 0);
		test(calA.getMonth() == 4);
		test(calA.getDay() == 3);
		test(calA.getYear() == 2009);
		test(calA.getHour() == 9);
		test(calA.getMinute() == 20);
		test(calA.getSecond() == 1);

		// special testing of edge case where we advance a month but the new month doesn't have as many days as previous
		calA.set(2016, 1, 31, 12, 30, 5); // jan 31, feb-2016 has 29 days
		calA.adjust(0, 1, 0, 0, 0, 0); // advance a month, which means feb 31 which is invalid, so we end up with March 2
		test(calA.getMonth() == 3);
		test(calA.getDay() == 2);
		test(calA.getHour() == 12);
		test(calA.getMinute() == 30);
		test(calA.getSecond() == 5);
	}
}

class CalendarTimeZoneTests implements IUnitTest
{
	void run()
	{
		CalendarDateTime calA = CalendarDateTime();
		calA.set(2016, 1, 31, 12, 30, 5, 120); // jan 31, feb-2016 has 29 days, GMT+2
		test(calA.getTimeZoneOffset() == 120);

		calA.removeTimeZoneOffset();
		test(calA.getHour() == 10);

		calA.applyTimeZoneOffset(180);
		test(calA.getHour() == 13);
	}
}