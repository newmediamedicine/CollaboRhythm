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
	import collaboRhythm.shared.model.CodedValue;
	import collaboRhythm.shared.model.IDataItem;

	public class AdherenceItem implements IDataItem
	{
		private var _name:CodedValue;
		private var _reportedBy:String;
		private var _dateTimeReported:Date;
		private var _administered:Boolean;
		private var _nonAdherenceReason:Boolean;

		public function AdherenceItem()
		{
		}

		public function set date(date:Date):void
		{
			dateTimeReported = date;
		}

		public function get date():Date
		{
			return dateTimeReported;
		}

		public function get name():CodedValue
		{
			return _name;
		}

		public function set name(name:CodedValue):void
		{
			_name = name;
		}

		public function get reportedBy():String
		{
			return _reportedBy;
		}

		public function set reportedBy(reportedBy:String):void
		{
			_reportedBy = reportedBy;
		}

		public function get dateTimeReported():Date
		{
			return _dateTimeReported;
		}

		public function set dateTimeReported(dateTimeReported:Date):void
		{
			_dateTimeReported = dateTimeReported;
		}

		public function get administered():Boolean
		{
			return _administered;
		}

		public function set administered(administered:Boolean):void
		{
			_administered = administered;
		}

		public function get nonAdherenceReason():Boolean
		{
			return _nonAdherenceReason;
		}

		public function set nonAdherenceReason(nonAdherenceReason:Boolean):void
		{
			_nonAdherenceReason = nonAdherenceReason;
		}

		public function get dateValue():Number
		{
			return dateTimeReported.valueOf();
		}
	}
}
