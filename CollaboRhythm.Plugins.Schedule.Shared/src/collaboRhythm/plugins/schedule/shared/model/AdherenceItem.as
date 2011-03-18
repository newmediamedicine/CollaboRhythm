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
	import collaboRhythm.shared.model.CodedValue;
	import collaboRhythm.shared.model.DateUtil;
	import collaboRhythm.shared.model.ValueAndUnit;
	import collaboRhythm.shared.model.healthRecord.DocumentMetadata;
	
	[Bindable]
	public class AdherenceItem extends DocumentMetadata
	{
		private var _name:String;
		private var _reportedBy:String;
		private var _dateTimeReported:Date;
		private var _adherence:Boolean;
		private var _nonadherenceReason:String;
		private var _adherenceResult:AdministrationBase;
		
		public function AdherenceItem()
		{
		}

		public function init(name:String, reportedBy:String, dateTimeReported:Date, adherence:Boolean, nonadherenceReason:String = null):void
		{
			_name = name;
			_reportedBy = reportedBy;
			_dateTimeReported = dateTimeReported;
			_adherence = adherence;
			_nonadherenceReason = nonadherenceReason;
		}
		
		public function initFromReportXML(adherenceItemReportXML:XML):void
		{
			parseDocumentMetadata(adherenceItemReportXML.Meta.Document[0], this);
			var adherenceItemXML:XML = adherenceItemReportXML.Item.AdherenceItem[0];
			_name = adherenceItemXML.name;
			_reportedBy = adherenceItemXML.reportedBy;
			_adherence = (adherenceItemXML.adherence.toLowerCase() == "true");
			_nonadherenceReason = adherenceItemXML.nonadherenceReason;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get reportedBy():String
		{
			return _reportedBy;
		}
		
		public function get dateTimeReported():Date
		{
			return _dateTimeReported;
		}
		
		public function get adherence():Boolean
		{
			return _adherence;
		}
		
		public function get nonadherenceReason():String
		{
			return _nonadherenceReason;
		}
		
		public function get adherenceResult():AdministrationBase
		{
			return _adherenceResult;
		}
		
		public function set adherenceResult(value:AdministrationBase):void
		{
			_adherenceResult = value;
		}
	}
}