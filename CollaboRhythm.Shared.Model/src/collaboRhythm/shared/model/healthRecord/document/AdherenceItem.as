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

	[Bindable]
	public class AdherenceItem extends DocumentBase
	{
		public static const DOCUMENT_TYPE:String = "http://indivo.org/vocab/xml/documents#AdherenceItem";
		public static const RELATION_TYPE_ADHERENCE_RESULT:String = "http://indivo.org/vocab/documentrels#adherenceresult";
		private var _name:CodedValue;
		private var _reportedBy:String;
		private var _dateReported:Date;
		private var _recurrenceIndex:int;
		private var _adherence:Boolean;
		private var _nonadherenceReason:String;
		private var _adherenceResultId:String;
		private var _adherenceResult:DocumentBase;

		public function AdherenceItem()
		{
			meta.type = DOCUMENT_TYPE;
		}

		public function init(name:CodedValue, reportedBy:String, dateReported:Date, recurrenceIndex:int,  adherence:Boolean, nonadherenceReason:String = null, adherenceResult:DocumentBase = null):void
		{
			_name = name;
			_reportedBy = reportedBy;
			_dateReported = dateReported;
            _recurrenceIndex = recurrenceIndex;
			_adherence = adherence;
			_nonadherenceReason = nonadherenceReason;
            _adherenceResult = adherenceResult;
		}
		
        public function get name():CodedValue
        {
            return _name;
        }

        public function get reportedBy():String
        {
            return _reportedBy;
        }

        public function get dateReported():Date
        {
            return _dateReported;
        }

        public function get recurrenceIndex():int
        {
            return _recurrenceIndex;
        }

        public function get adherence():Boolean
        {
            return _adherence;
        }

        public function set adherence(value:Boolean):void
        {
            _adherence = value;
        }

        public function get nonadherenceReason():String
        {
            return _nonadherenceReason;
        }

        public function get adherenceResultId():String
        {
            return _adherenceResultId;
        }

        public function set adherenceResultId(value:String):void
        {
            _adherenceResultId = value;
        }

        public function get adherenceResult():DocumentBase
        {
            return _adherenceResult;
        }

        public function set adherenceResult(value:DocumentBase):void
        {
            _adherenceResult = value;
        }

		public function set name(value:CodedValue):void
		{
			_name = value;
		}

		public function set reportedBy(value:String):void
		{
			_reportedBy = value;
		}

		public function set dateReported(value:Date):void
		{
			_dateReported = value;
		}

		/**
		 * Returns dateReported.valueOf() to facilitate sorting
		 */
		public function get dateReportedValue():Number
		{
			return dateReported.valueOf();
		}

		public function set recurrenceIndex(value:int):void
		{
			_recurrenceIndex = value;
		}

		public function set nonadherenceReason(value:String):void
		{
			_nonadherenceReason = value;
		}

		/**
		 * Workaround property that returns 0. Used for the y value of the AdherencePlotItemRenderer so that it can be positioned in the chart correctly.
		 */
		public function get adherencePosition():Number
		{
			return 0;
		}
	}
}