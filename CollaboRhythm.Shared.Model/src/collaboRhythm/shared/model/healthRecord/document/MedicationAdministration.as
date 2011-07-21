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
package collaboRhythm.shared.model.healthRecord.document
{

	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.ValueAndUnit;

	[Bindable]
    public class MedicationAdministration extends DocumentBase
    {
		public static const DOCUMENT_TYPE:String = "http://indivo.org/vocab/xml/documents#MedicationAdministration";
		private var _name:CodedValue;
		private var _reportedBy:String;
		private var _dateReported:Date;
		private var _dateAdministered:Date;
		private var _amountAdministered:ValueAndUnit;
		private var _amountRemaining:ValueAndUnit;

        public function MedicationAdministration()
        {
			meta.type = DOCUMENT_TYPE;
        }

        public function init(name:CodedValue, reportedBy:String, dateReported:Date, dateAdministered:Date = null, amountAministered:ValueAndUnit = null, amountRemaining:ValueAndUnit = null):void
		{
			_name = name;
            _reportedBy = reportedBy;
            _dateReported = dateReported;
            _dateAdministered = dateAdministered;
            _amountAdministered = amountAministered;
            _amountRemaining = amountRemaining;
		}

        public function get name():CodedValue
        {
            return _name;
        }

        public function set name(value:CodedValue):void
        {
            _name = value;
        }

        public function get reportedBy():String
        {
            return _reportedBy;
        }

        public function set reportedBy(value:String):void
        {
            _reportedBy = value;
        }

        public function get dateReported():Date
        {
            return _dateReported;
        }

        public function set dateReported(value:Date):void
        {
            _dateReported = value;
        }

        public function get dateAdministered():Date
        {
            return _dateAdministered;
        }

        public function set dateAdministered(value:Date):void
        {
            _dateAdministered = value;
        }

		/**
		 * Returns dateAdministered.valueOf() to facilitate sorting
		 */
		public function get dateAdministeredValue():Number
		{
			return dateAdministered.valueOf();
		}

        public function get amountAdministered():ValueAndUnit
        {
            return _amountAdministered;
        }

        public function set amountAdministered(value:ValueAndUnit):void
        {
            _amountAdministered = value;
        }

        public function get amountRemaining():ValueAndUnit
        {
            return _amountRemaining;
        }

        public function set amountRemaining(value:ValueAndUnit):void
        {
            _amountRemaining = value;
        }
    }
}
