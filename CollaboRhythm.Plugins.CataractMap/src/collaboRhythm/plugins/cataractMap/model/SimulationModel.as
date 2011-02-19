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
package collaboRhythm.plugins.cataractMap.model
{
	[Bindable]
	public class SimulationModel
	{
		private var _date:Date;
		private var _dataPointDate:Date;
		private var _systolic:Number;
		private var _diastolic:Number;
		private var _concentration:Number;
		
		public function SimulationModel()
		{
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

	}
}