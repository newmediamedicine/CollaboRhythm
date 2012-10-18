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
	 * 	Class that contains static utility methods for manipulating and working
	 *	with Dates.
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
				return com.adobe.utils.DateUtil.parseW3CDTF(dateString);
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
	}
}
