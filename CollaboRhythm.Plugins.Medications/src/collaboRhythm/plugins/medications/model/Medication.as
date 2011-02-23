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
package collaboRhythm.plugins.medications.model
{
	import collaboRhythm.shared.model.CodedValue;
	import collaboRhythm.shared.model.DateUtil;
	import collaboRhythm.shared.model.HealthRecordHelperMethods;
	import collaboRhythm.shared.model.ValueAndUnit;
	import collaboRhythm.shared.model.healthRecord.DocumentMetadata;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	[Bindable]
	public class Medication extends DocumentMetadata
	{
		private var _name:CodedValue;
		private var _orderType:String;
		private var _orderedBy:String;
		private var _dateTimeOrdered:Date;
		private var _dateTimeExpires:Date;
		private var _indication:String;
		private var _activeIngredients:Vector.<ActiveIngredient> = new Vector.<ActiveIngredient>;
		private var _dose:ValueAndUnit;
		private var _form:CodedValue;
		private var _route:CodedValue;
		private var _frequency:CodedValue;
		private var _amountOrdered:ValueAndUnit;
		private var _refills:Number;
		private var _substitutionPermitted:Boolean;
		private var _instructions:String;
		private var _dateTimeStarted:Date;
		private var _dateTimeStopped:Date;
		private var _reasonStopped:String;

//		private var _color:uint;
//		private var _imageURI:String;
				
		private var _currentDateSource:ICurrentDateSource;
		
		public function Medication(medicationReportXML:XML)
		{
			parseDocumentMetadata(medicationReportXML.Meta.Document[0], this);
			var medicationXML:XML = medicationReportXML.Item.Medication[0];
			_name = HealthRecordHelperMethods.codedValueFromXml(medicationXML.name[0]);
			_orderType = medicationXML.orderType;
			_orderedBy = medicationXML.orderedBy;
			_dateTimeOrdered = DateUtil.parseW3CDTF(medicationXML.dateTimeOrdered.toString());
			_dateTimeExpires = DateUtil.parseW3CDTF(medicationXML.dateTimeExpires.toString());
			_indication = medicationXML.indication;
			for each (var activeIngredientXML:XML in medicationXML.activeIngredients.activeIngredient)
			{
				var strength:ValueAndUnit = new ValueAndUnit(activeIngredientXML.strength.value, HealthRecordHelperMethods.codedValueFromXml(activeIngredientXML.strength.unit[0]));
				var activeIngredient:ActiveIngredient = new ActiveIngredient(HealthRecordHelperMethods.codedValueFromXml(activeIngredientXML.name[0]), strength);
				_activeIngredients.push(activeIngredient);
			}
			_dose = new ValueAndUnit(medicationXML.dose.value, HealthRecordHelperMethods.codedValueFromXml(medicationXML.dose.unit[0]));
			_form = HealthRecordHelperMethods.codedValueFromXml(medicationXML.form[0]);
			_route = HealthRecordHelperMethods.codedValueFromXml(medicationXML.route[0]);
			_frequency = HealthRecordHelperMethods.codedValueFromXml(medicationXML.frequency[0]);
			_amountOrdered = new ValueAndUnit(medicationXML.amountOrdered.value, HealthRecordHelperMethods.codedValueFromXml(medicationXML.amountOrdered.unit[0]));
			_refills = Number(medicationXML.refills);
			_substitutionPermitted = Boolean(medicationXML.substitutionPermitted);
			_instructions = medicationXML.instructions;
			_dateTimeStarted = DateUtil.parseW3CDTF(medicationXML.dateStarted.toString());
			_dateTimeStopped = DateUtil.parseW3CDTF(medicationXML.dateStopped.toString());
			_reasonStopped = medicationXML.reasonStopped;

//			_imageURI = "assets/images/" + _name + "_front.jpg";
						
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}
		
		public function get name():CodedValue
		{
			return _name;
		}
		
		public function get orderType():String
		{
			return _orderType;
		}
		
		public function get orderedBy():String
		{
			return _orderedBy;
		}

		public function get dateTimeOrdered():Date
		{
			return _dateTimeOrdered;
		}

		public function get dateTimeExpires():Date
		{
			return _dateTimeExpires;
		}

		public function get indication():String
		{
			return _indication;
		}

		public function get activeIngredients():Vector.<ActiveIngredient>
		{
			return _activeIngredients;
		}

		public function get dose():ValueAndUnit
		{
			return _dose;
		}

		public function get form():CodedValue
		{
			return _form;
		}

		public function get route():CodedValue
		{
			return _route;
		}

		public function get frequency():CodedValue
		{
			return _frequency;
		}

		public function get amountOrdered():ValueAndUnit
		{
			return _amountOrdered;
		}

		public function get refills():Number
		{
			return _refills;
		}

		public function get substitutionPermitted():Boolean
		{
			return _substitutionPermitted;
		}

		public function get instructions():String
		{
			return _instructions;
		}

		public function get dateTimeStarted():Date
		{
			return _dateTimeStarted;
		}

		public function get dateTimeStopped():Date
		{
			return _dateTimeStopped;
		}

		public function get reasonStopped():String
		{
			return _reasonStopped;
		}

		public function get isInactive():Boolean
		{
			if (_dateTimeStopped != null)
			{
				return _dateTimeStopped < _currentDateSource.now();
			}
			return false;
		}
		
		public function get nameLabelText():String
		{
			return _activeIngredients[0].name.text;
		}
		
		public function get strengthLabelText():String
		{
			return _activeIngredients[0].strength.value + _activeIngredients[0].strength.unit.abbrev;
		}
		
		public function get doseLabelText():String
		{
			return _dose.value + " " + _dose.unit.abbrev;
		}
		
		public function get frequencyLabelText():String
		{
			return _frequency.text;
		}

//		public function get imageURI():String
//		{
//			return _imageURI;
//		}
//		
//		private function set imageURI(value:String):void
//		{
//			_imageURI = value;
//		}
		
//		public override function createScheduleItemWidgetView():ScheduleItemWidgetViewBase
//		{
//			var widgetMedicationView:ScheduleItemWidgetViewMedication = new ScheduleItemWidgetViewMedication();
//			widgetMedicationView.medication = this;
//			return widgetMedicationView;
//		}
//			
//		public override function createScheduleItemFullView():FullScheduleItemViewBase
//		{
//			var fullMedicationView:FullMedicationView = new FullMedicationView();
//			fullMedicationView.medication = this;
//			return fullMedicationView;
//		}
	}
}