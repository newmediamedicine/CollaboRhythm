/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
 * version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
package collaboRhythm.shared.model
{
	import com.adobe.utils.DateUtil;

	/**
	 *     Class that contains static utility methods for manipulating and working
	 *    with Dates.
	 */
	public class DateUtil
	{
		public static const MILLISECONDS_IN_DAY:Number = 1000 * 60 * 60 * 24;

		/**
		 * Parses dates that conform to the W3C Date-time Format into Date objects.
		 *
		 * This function is useful for parsing RSS 1.0 and Atom 1.0 dates.
		 *
		 * @param dateString The date string to parse
		 *
		 * @returns The parsed Date value, or null if the dateString is null or empty and returnNullIfEmpty is true.
		 *
		 * @see http://www.w3.org/TR/NOTE-datetime
		 */
		public static function parseW3CDTF(dateString:String, returnNullIfEmpty:Boolean = true):Date
		{
			if (returnNullIfEmpty && (dateString == null || dateString.length == 0))
				return null;
			else
				return parse(dateString);
		}

		/**
		 * Parses dates that have the format "YYYY-MM-DD" into Date objects. Note that the parseW3CDTF function does not
		 * currently support this format (though it probably should).
		 *
		 * @param dateString The date string to parse
		 *
		 * @returns The parsed Date value, or null if the dateString is null or empty and returnNullIfEmpty is true.
		 *
		 * @see http://www.w3.org/TR/NOTE-datetime
		 */
		public static function parseDate(dateString:String, returnNullIfEmpty:Boolean = true):Date
		{
			if (returnNullIfEmpty && (dateString == null || dateString.length == 0))
				return null;
			else
				return com.adobe.utils.DateUtil.parseW3CDTF(dateString + "T00:00:00Z");
		}

		public static function roundTimeToNextDay(date:Date):Date
		{
			var interval:int = 60 * 24;
			var timezoneOffsetMilliseconds:Number = date.getTimezoneOffset() * 60 * 1000;
			var time:Number = date.getTime() - timezoneOffsetMilliseconds;
			var roundNumerator:Number = 60000 * interval; //there are 60000 milliseconds in a minute
			var newTime:Number = (Math.ceil(time / roundNumerator) * roundNumerator);
			return new Date(newTime + timezoneOffsetMilliseconds);
		}

		/**
		 * Parse W3CDTF format string
		 *
		 * Copyright (c) Lyo Kato (lyo.kato _at_ gmail.com)

		 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
		 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
		 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
		 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
		 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
		 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
		 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
		 *
		 * @param dateString
		 * @return date
		 * @langversion ActionScript 3.0
		 * @playerversion 9.0
		 *
		 * XXX:
		 *   This code is borrowed from as3corelib's DateUtil class.
		 *   I copied same functionality because I want to remove dependencies on mx-libraries.
		 */
		public static function parse(dateString:String):Date
		{
			var finalDate:Date;
			try
			{
				var dateStr:String = dateString.substring(0, dateString.indexOf("T"));
				var timeStr:String = dateString.substring(dateString.indexOf("T") + 1, dateString.length);
				var dateArr:Array = dateStr.split("-");
				var year:Number = Number(dateArr.shift());
				var month:Number = Number(dateArr.shift());
				var date:Number = Number(dateArr.shift());

				var multiplier:Number;
				var offsetHours:Number;
				var offsetMinutes:Number;
				var offsetStr:String;

				if (timeStr.indexOf("Z") != -1)
				{
					multiplier = 1;
					offsetHours = 0;
					offsetMinutes = 0;
					timeStr = timeStr.replace("Z", "");
				}
				else if (timeStr.indexOf("+") != -1)
				{
					multiplier = 1;
					offsetStr = timeStr.substring(timeStr.indexOf("+") + 1, timeStr.length);
					offsetHours = Number(offsetStr.substring(0, offsetStr.indexOf(":")));
					offsetMinutes = Number(offsetStr.substring(offsetStr.indexOf(":") + 1, offsetStr.length));
					timeStr = timeStr.substring(0, timeStr.indexOf("+"));
				}
				else // offset is -
				{
					multiplier = -1;
					offsetStr = timeStr.substring(timeStr.indexOf("-") + 1, timeStr.length);
					offsetHours = Number(offsetStr.substring(0, offsetStr.indexOf(":")));
					offsetMinutes = Number(offsetStr.substring(offsetStr.indexOf(":") + 1, offsetStr.length));
					timeStr = timeStr.substring(0, timeStr.indexOf("-"));
				}
				var timeArr:Array = timeStr.split(":");
				var hour:Number = Number(timeArr.shift());
				var minutes:Number = Number(timeArr.shift());
				var secondsArr:Array = (timeArr.length > 0) ? String(timeArr.shift()).split(".") : null;
				var seconds:Number = (secondsArr != null && secondsArr.length > 0) ? Number(secondsArr.shift()) : 0;
				var milliseconds:Number = (secondsArr != null &&
						secondsArr.length > 0) ? Number(secondsArr.shift()) : 0;
				var utc:Number = Date.UTC(year, month - 1, date, hour, minutes, seconds, milliseconds);
				var offset:Number = (((offsetHours * 3600000) + (offsetMinutes * 60000)) * multiplier);
				finalDate = new Date(utc - offset);

				if (finalDate.toString() == "Invalid Date")
				{
					throw new Error("This date does not conform to W3CDTF.");
				}
			}
			catch (e:Error)
			{
				var eStr:String = "Unable to parse the string [" + dateString + "] into a date. ";
				eStr += "The internal error was: " + e.toString();
				throw new Error(eStr);
			}
			return finalDate;
		}

		/**
		 * Get current date as w3cdtf formatted string
		 *
		 * @return string
		 * @langversion ActionScript 3.0
		 * @playerversion 9.0
		 */
		public static function now():String
		{
			var d:Date = new Date();
			return format(d);
		}

		/**
		 * Get W3CDTF formatted string from passed date object.
		 *
		 * @param date
		 * @return formatted string
		 * @langversion ActionScript 3.0
		 * @playerversion 9.0
		 */
		public static function format(d:Date, calcMilliSeconds:Boolean = true):String
		{
			var year:Number = d.getUTCFullYear();
			var month:Number = d.getUTCMonth() + 1;
			var date:Number = d.getUTCDate();
			var hour:Number = d.getUTCHours();
			var minute:Number = d.getUTCMinutes();
			var second:Number = d.getUTCSeconds();
			var milli:Number = d.getUTCMilliseconds();
			var value:String = year
					+ "-"
					+ pushZero(month)
					+ "-"
					+ pushZero(date)
					+ "T"
					+ pushZero(hour)
					+ ":"
					+ pushZero(minute)
					+ ":"
					+ pushZero(second);
			if (calcMilliSeconds && milli > 0)
			{
				var milliStr:String = pushZero(milli, 3);
				while (milliStr.charAt(milliStr.length - 1) == "0")
				{
					milliStr = milliStr.substr(0, milliStr.length - 1);
				}
				value = value + "." + milliStr;
			}
			return value + "Z";
		}

		private static function pushZero(num:Number, digit:uint = 2):String
		{
			var value:String = num.toString();
			while (value.length < digit)
			{
				value = "0" + value;
			}
			return value;
		}

		public static function isDateToday(date:Date, now:Date):Boolean
		{
			return roundTimeToNextDay(date).valueOf() ==
					roundTimeToNextDay(now).valueOf();
		}

		public static function isDateYesterday(date:Date, now:Date):Boolean
		{
			return roundTimeToNextDay(date).valueOf() ==
					(roundTimeToNextDay(now).valueOf() - MILLISECONDS_IN_DAY);
		}
	}
}
