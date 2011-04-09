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
package collaboRhythm.shared.apps.bloodPressure.model
{
	import mx.events.PropertyChangeEvent;

	/**
	 * Represents the data used by the blood pressure simulation.
	 */
	[Bindable]
	public class SimulationModel
	{
		private var _date:Date;
		private var _dataPointDate:Date;
		private var _systolic:Number;
		private var _diastolic:Number;
		private var _concentration:Number;

		/**
		 * Maximum value to use for the plugRatio, the ratio of plugs (medication) to gaps, in the simulation.
		 */
		public static const maxPlugRatio:Number = 2.0;

		/**
		 * Goal value for the concentration of medication in the blood. A concentration at or above goalConcentration
		 * will result in ideal functioning of the medication.
		 */
		public static const goalConcentration:Number = 0.05;
		private var _mode:String;
		private var _modeLabel:String;
		public static const MOST_RECENT_MODE:String = "mostRecentMode";
		public static const HISTORY_MODE:String = "historyMode";

		public function SimulationModel()
		{
			mode = MOST_RECENT_MODE;
		}

		public function get dataPointDate():Date
		{
			return _dataPointDate;
		}

		public function set dataPointDate(value:Date):void
		{
			_dataPointDate = value;
		}

		public function get date():Date
		{
			return _date;
		}

		public function set date(value:Date):void
		{
			_date = value;
		}

		public function get systolic():Number
		{
			return _systolic;
		}

		public function set systolic(value:Number):void
		{
			_systolic = value;
		}

		public function get diastolic():Number
		{
			return _diastolic;
		}

		public function set diastolic(value:Number):void
		{
			_diastolic = value;
		}

		public function get concentration():Number
		{
			return _concentration;
		}

		public function set concentration(value:Number):void
		{
			_concentration = value;
		}

		public function get mode():String
		{
			return _mode;
		}

		public function set mode(value:String):void
		{
			_mode = value;
			modeLabel = determineModeLabel();
		}

		private function determineModeLabel():String
		{
			switch (mode)
			{
				case MOST_RECENT_MODE:
					return "Latest Data Mode";
					break;
				case HISTORY_MODE:
					return "History Mode";
					break;
				default:
					throw new Error("Unsupported mode: " + mode);
					break;
			}
		}

		public function get modeLabel():String
		{
			return _modeLabel;
		}

		public function set modeLabel(value:String):void
		{
			_modeLabel = value;
		}
	}
}