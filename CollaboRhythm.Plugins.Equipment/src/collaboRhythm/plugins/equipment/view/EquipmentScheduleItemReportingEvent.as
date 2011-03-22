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
package collaboRhythm.plugins.equipment.view
{
	import flash.events.Event;
	
	public class EquipmentScheduleItemReportingEvent extends Event
	{
		public static const BLOOD_PRESSURE_REPORTING_VIEW_BACK:String = "BloodPressureReportingViewOpen";
		public static const BLOOD_PRESSURE_REPORTING_VIEW_RESULT:String = "BloodPressureReportingViewResult";
		
		private var _systolic:String;
		private var _diastolic:String;
		private var _heartRate:String;
		
		public function EquipmentScheduleItemReportingEvent(type:String, systolic:String, diastolic:String, heartRate:String)
		{
			super(type);
			
			_systolic = systolic;
			_diastolic = diastolic;
			_heartRate = heartRate;
		}

		public function get systolic():String
		{
			return _systolic;
		}
		
		public function get diastolic():String
		{
			return _diastolic;
		}
		
		public function get heartRate():String
		{
			return _heartRate;
		}

	}
}