/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see <http://www.gnu.org/licenses/>.
*/
/**
 * Copyright 2009 (c) , Brooks Andrus
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 * 
 */
package com.brooksandrus.utils
{
	public class ISO8601Util
	{
		private const DASH:String  = "-";
		private const COLON:String = ":";
		private const ZULU:String  = "Z";
		private const T:String     = "T";
		private const ZERO:String  = "0";
		
		public function ISO8601Util()
		{
		}
		
		/**
		 * Converts an AS3 Date object into an ISO-8601 UTC extended date and time String (YYYY-MM-HHTHH:MM:SSZ).
		 * The zulu designation (Z) at the end of the string indicates the time is UTC (Coordinated Universal Time).
		 */
		public function formatExtendedDateTime( date:Date ):String
		{
			return formatExtendedDate( date )
			+ T
				+ formatExtendedTime( date )
				+ ZULU;
		}
		
		/**
		 * Converts an AS3 Date object into an ISO-8601 UTC basic date and time String. The Basic format has no hyphens or 
		 * colons, but does have a UTC zulu designation at the end.
		 */
		public function formatBasicDateTime( date:Date ):String
		{
			return formatBasicDate( date )
			+ T
				+ formatBasicTime( date )
				+ ZULU;
		}
		
		/**
		 * converts an ISO-8601 date + time (UTC) string of format "2009-02-21T09:00:00Z" to an AS3 Date Object.
		 * The zulu designation (Z) at the end of the string indicates the time is UTC (Coordinated Universal Time).
		 * Even if the zulu designation is missing UTC will be assumed.
		 */
		public function parseDateTimeString( val:String ):Date
		{
			//first strip all non-numerals from the String ( convert all extended dates to basic)
			val = val.replace( /-|:|T|Z/g, "" );
			
			var date:Date = parseBasicDate( val.substr( 0, 8 ) );
			date = parseBasicTime( val.substr( 8, 6 ), date );
			
			return date;
		}
		
		public function parseBasicDate( val:String, date:Date = null ):Date
		{
			if ( date == null )
			{
				date = new Date();
			}
			
			date.setUTCFullYear( convertYear( val ), convertMonth( val ), convertDate( val ) );
			
			return date;
		}
		
		public function parseBasicTime( val:String, date:Date = null ):Date
		{
			if ( date == null )
			{
				date = new Date();
			}
			
			date.setUTCHours( convertHours( val ), convertMinutes( val ), convertSeconds( val ) );
			
			return date;
		}
		
		public function formatExtendedDate( date:Date ):String
		{
			return formatYear( date.getUTCFullYear() )
			+ DASH 
				+ formatMonth( date.getUTCMonth() )
				+ DASH
				+ formatDate( date.getUTCDate() )
		}
		
		public function formatBasicDate( date:Date ):String
		{
			return formatYear( date.getUTCFullYear() )
			+ formatMonth( date.getUTCMonth() )
				+ formatDate( date.getUTCDate() );
		}
		
		public function formatExtendedTime( date:Date ):String
		{
			return formatTimeChunk( date.getUTCHours() )
			+ COLON
				+ formatTimeChunk( date.getUTCMinutes() )
				+ COLON
				+ formatTimeChunk( date.getUTCSeconds() );
		}
		
		public function formatBasicTime( date:Date ):String
		{
			return formatTimeChunk( date.getUTCHours() )
			+ formatTimeChunk( date.getUTCMinutes() )
				+ formatTimeChunk( date.getUTCSeconds() );
		}
		
		/**
		 * assumes an 8601 basic date string (8 characters YYYYMMDD)
		 */
		private function convertYear( val:String ):int
		{
			val = val.substr( 0, 4 );
			return parseInt( val );
		}
		
		/**
		 * assumes an 8601 basic date string (8 characters YYYYMMDD)
		 */
		private function convertMonth( val:String ):int
		{
			val = val.substr( 4, 2 );
			var y:int = parseInt( val ) - 1; // months are zero indexed in Date objects so we need to decrement
			return y;
		}
		
		/**
		 * assumes an 8601 basic date string (8 characters YYYYMMDD)
		 */
		private function convertDate( val:String ):int
		{
			val = val.substr( 6, 2 );
			
			return parseInt( val );
		}
		
		/**
		 * assumes a 8601 basic UTC time string (6 characters HHMMSS)
		 */
		private function convertHours( val:String ):int
		{
			val = val.substr( 0, 2 );
			
			return parseInt( val );
		}
		
		/**
		 * assumes a 8601 basic UTC time string (6 characters HHMMSS)
		 */
		private function convertMinutes( val:String ):int
		{
			val = val.substr( 2, 2 );
			
			return parseInt( val );
		}
		
		/**
		 * assumes a 8601 basic UTC time string (6 characters HHMMSS)
		 */
		private function convertSeconds( val:String ):int
		{
			val = val.substr( 4, 2 );
			
			return parseInt( val );
		}
		
		// doesn't handle BC dates
		private function formatYear( year:int ):String
		{
			var y:String = year.toString();
			// 0009 0010 0099 0100
			if ( year < 10 )
			{
				y = ZERO + ZERO + ZERO + y;
			}
			else if ( year < 100 )
			{
				y = ZERO + ZERO + y;
			}
			else if ( year < 1000 )
			{
				y = ZERO + y;
			}
			
			return y;
		}
		
		private function formatMonth( month:int ):String
		{
			// Date object months are zero indexed so always increment the month up by one
			month++;
			
			// convert the month to a String
			var m:String = month.toString();
			
			if ( month < 10 )
			{
				m = ZERO + m; 
			}
			
			return m;
		}
		
		private function formatDate( date:int ):String
		{
			var d:String = date.toString()
			if ( date < 10 )
			{
				d = ZERO + d;
			}
			
			return d;
		}
		
		private function formatTimeChunk( val:int ):String
		{
			var t:String = val.toString();
			
			if ( val < 10 )
			{
				t = ZERO + t;
			}
			
			return t;
		}
	}
}