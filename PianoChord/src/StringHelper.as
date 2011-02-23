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
package
{
	public class StringHelper {
		public static function replace(str:String, oldSubStr:String, newSubStr:String):String {
			return str.split(oldSubStr).join(newSubStr);
		}
		
		/**
		 * Removes any whitespaces characters from the str. If chars is specified, those characters are removed instead.
		 * Whitespace characters include the following: space, tab, carriage return, new line
		 * @param str
		 * @param chars
		 * @return The specified str with any leading and trailing whitespace removed.
		 * 
		 */
		public static function trim(str:String, chars:Vector.<String>=null):String {
			if (chars == null)
				chars = Vector.<String>([" ", "\t", "\n", "\r"]);
			
			return trimBack(trimFront(str, chars), chars);
		}
		
		public static function trimFront(str:String, chars:Vector.<String>):String {
			if (chars.indexOf(str.charAt(0)) != -1) {
				str = trimFront(str.substring(1), chars);
			}
			return str;
		}
		
		public static function trimBack(str:String, chars:Vector.<String>):String {
			if (chars.indexOf(str.charAt(str.length - 1)) != -1) {
				str = trimBack(str.substring(0, str.length - 1), chars);
			}
			return str;
		}
		
		public static function stringToCharacter(str:String):String {
			if (str.length == 1) {
				return str;
			}
			return str.slice(0, 1);
		}
	}
}