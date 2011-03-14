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
package collaboRhythm.plugins.medications.model
{
	import collaboRhythm.plugins.schedule.shared.model.AdministrationBase;
	import collaboRhythm.shared.model.CodedValue;
	import collaboRhythm.shared.model.DateUtil;
	import collaboRhythm.shared.model.HealthRecordHelperMethods;
	import collaboRhythm.shared.model.ValueAndUnit;
	import collaboRhythm.shared.model.healthRecord.DocumentMetadata;

	[Bindable]
	public class MedicationAdministration extends AdministrationBase
	{
		private var _name:CodedValue;
		private var _reportedBy:String;
		private var _dateTimeReported:Date;
		private var _dateTimeAdministered:Date;
		private var _amountAdministered:ValueAndUnit;
		private var _amountRemaining:ValueAndUnit;
		
		public function MedicationAdministration()
		{
		}

		public function init(name:CodedValue, reportedBy:String, dateTimeReported:Date, dateTimeAdministered:Date = null, amountAdministered:ValueAndUnit = null, amountRemaining:ValueAndUnit = null):void
		{
			_name = name;
			_reportedBy = reportedBy;
			_dateTimeReported = dateTimeReported;
			_dateTimeAdministered = dateTimeAdministered;
			_amountAdministered = amountAdministered;
			_amountRemaining = amountRemaining;
		}
		
		public function initFromReportXML(medicationAdministrationReportXML:XML):void
		{
			parseDocumentMetadata(medicationAdministrationReportXML.Meta.Document[0], this);
			var medicationAdministrationXML:XML = medicationAdministrationReportXML.Item.MedicationAdministration[0];
			_name = HealthRecordHelperMethods.codedValueFromXml(medicationAdministrationXML.name[0]);
			_reportedBy = medicationAdministrationXML.reportedBy;
			_dateTimeReported = DateUtil.parseW3CDTF(medicationAdministrationXML.dateTimeReported.toString());
			_dateTimeAdministered = DateUtil.parseW3CDTF(medicationAdministrationXML.dateTimeAdministered.toString());
			_amountAdministered = new ValueAndUnit(medicationAdministrationXML.amountAdministered.value, HealthRecordHelperMethods.codedValueFromXml(medicationAdministrationXML.amountAdministered.unit[0]));
			_amountRemaining = new ValueAndUnit(medicationAdministrationXML.amountRemaining.value, HealthRecordHelperMethods.codedValueFromXml(medicationAdministrationXML.amountRemaining.unit[0]));
		}
		
		
		public function get name():CodedValue
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
		
		public function get dateTimeAdministered():Date
		{
			return _dateTimeAdministered;
		}
		
		public function get amountAdministered():ValueAndUnit
		{
			return _amountAdministered;
		}
		
		public function get amountRemaining():ValueAndUnit
		{
			return _amountRemaining;
		}
	}
}