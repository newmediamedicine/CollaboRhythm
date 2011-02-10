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
package collaboRhythm.workstation.apps.schedule.model
{

	[Bindable]
	public class Measurement extends ScheduleItemBase
	{
		private var _description:String = "Blood Pressure Measurement";
		private var _indication:String = "High Blood Pressure";
		private var _administration:String = "Measure once a day"
		private var _instructions:String = "Remember to relax arm"
		private var _imageURI:String = "resources/images/apps/schedule/blood_pressure_measurement.png";
		
		public function Measurement()
		{
			documentID = "hack";
		}

		public function get description():String
		{
			return _description;
		}

		public function set description(value:String):void
		{
			_description = value;
		}

		public function get indication():String
		{
			return _indication;
		}

		public function set indication(value:String):void
		{
			_indication = value;
		}
		
		public function get administration():String
		{
			return _administration;
		}
		
		public function set administration(value:String):void
		{
			_administration = value;
		}
		
		public function get instructions():String
		{
			return _instructions;
		}

		public function set instructions(value:String):void
		{
			_instructions = value;
		}

		public function get imageURI():String
		{
			return _imageURI;
		}

		public function set imageURI(value:String):void
		{
			_imageURI = value;
		}
	}
}