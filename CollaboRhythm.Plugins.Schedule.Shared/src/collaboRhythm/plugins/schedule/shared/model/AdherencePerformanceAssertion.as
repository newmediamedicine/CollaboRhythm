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
package collaboRhythm.plugins.schedule.shared.model
{

	[Bindable]
	public class AdherencePerformanceAssertion
	{
		public static const THUMBS_UP:String = "Thumbs up";
		public static const LIGHTNING:String = "Lightning";
		public static const WARNING:String = "Warning";

		private var _icon:String;
		private var _assertion:String;
		private var _valence:Boolean;
		public function AdherencePerformanceAssertion(icon:String, assertion:String, valence:Boolean)
		{
			_icon = icon;
			_assertion = assertion;
			_valence = valence;
		}

		public function get icon():String
		{
			return _icon;
		}

		public function set icon(value:String):void
		{
			_icon = value;
		}

		public function get assertion():String
		{
			return _assertion;
		}

		public function set assertion(value:String):void
		{
			_assertion = value;
		}

		public function get valence():Boolean
		{
			return _valence;
		}

		public function set valence(value:Boolean):void
		{
			_valence = value;
		}
	}
}
