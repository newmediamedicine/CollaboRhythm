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
package collaboRhythm.shared.controller.apps
{
	/**
	 * Specifies a constraint for ordering one app relative to another.
	 */
	public class AppOrderConstraint
	{
		/**
		 * Order the target app before the other app.
		 */
		public static const ORDER_BEFORE:String = "before";

		/**
		 * Order the target app after the other app.
		 */
		public static const ORDER_AFTER:String = "after";

		private var _relativeOrder:String;
		private var _otherAppIdPattern:String;

		public function AppOrderConstraint(relativeOrder:String, otherAppId:String)
		{
			_relativeOrder = relativeOrder;
			this.otherAppId = otherAppId;
		}

		/**
		 * Specifies if the constraint is to order the target app either before or after the other app.
		 * Valid values are <see>ORDER_BEFORE</see> or <see>ORDER_AFTER</see>
		 *
		 * @see #ORDER_BEFORE
		 * @see #ORDER_AFTER
		 */
		public function get relativeOrder():String
		{
			return _relativeOrder;
		}

		/**
		 * Specifies the regular expression pattern for matching the id of the other app for which the ordering
		 * is relative to. App id values will generally be the fully qualified class name of the app controller, such
		 * as collaboRhythm.plugins.problems.controller::ProblemsAppController.
		 */
		public function get otherAppIdPattern():String
		{
			return _otherAppIdPattern;
		}

		public function set otherAppIdPattern(value:String):void
		{
			_otherAppIdPattern = value;
		}

		public function appMatches(otherAppInfo:AppControllerInfo):Boolean
		{
			var expression:RegExp = new RegExp(otherAppIdPattern);
			var matches:Object = expression.exec(otherAppInfo.appId);
			return matches != null && matches.length > 0;
		}

		private function set otherAppId(otherAppId:String):void
		{
			_otherAppIdPattern = escapeRegexChars(otherAppId);
		}

		private function escapeRegexChars(s:String):String
		{
			var newString:String =
				s.replace(
					new RegExp("([{}\(\)\^$&.\*\?\/\+\|\[\\\\]|\]|\-)","g"),
					"\\$1");
			return newString;
		}
	}
}
