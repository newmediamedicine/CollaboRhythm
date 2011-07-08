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
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.DateUtil;
	import collaboRhythm.shared.model.healthRecord.ValueAndUnit;
	import collaboRhythm.shared.model.healthRecord.DocumentMetadata;
	import collaboRhythm.shared.model.healthRecord.HealthRecordHelperMethods;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	[Bindable]
	public class Medication extends DocumentMetadata
	{
		private static const ATORVASTATIN_RXCUI:String = "617320";
		private static const HYDROCHLOROTHIAZIDE_RXCUI:String = "310798";
		
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

		//TODO: Automate color selection
		private var _color:uint = 0x000000;
				
		private var _currentDateSource:ICurrentDateSource;
		
		public function Medication(medicationReportXML:XML)
		{
			default xml namespace = "http://indivo.org/vocab/xml/documents#";
			parseDocumentMetadata(medicationReportXML.Meta.Document[0], this);
			var medicationXML:XML = medicationReportXML.Item.Medication[0];
			_name = HealthRecordHelperMethods.xmlToCodedValue(medicationXML.name[0]);
			_orderType = medicationXML.orderType;
			_orderedBy = medicationXML.orderedBy;
			_dateTimeOrdered = DateUtil.parseW3CDTF(medicationXML.dateTimeOrdered.toString());
			_dateTimeExpires = DateUtil.parseW3CDTF(medicationXML.dateTimeExpires.toString());
			_indication = medicationXML.indication;
			for each (var activeIngredientXML:XML in medicationXML.activeIngredients.activeIngredient)
			{
				var strength:ValueAndUnit = new ValueAndUnit(activeIngredientXML.strength.value, HealthRecordHelperMethods.xmlToCodedValue(activeIngredientXML.strength.unit[0]));
				var activeIngredient:ActiveIngredient = new ActiveIngredient(HealthRecordHelperMethods.xmlToCodedValue(activeIngredientXML.name[0]), strength);
				_activeIngredients.push(activeIngredient);
			}
			_dose = new ValueAndUnit(medicationXML.dose.value, HealthRecordHelperMethods.xmlToCodedValue(medicationXML.dose.unit[0]));
			_form = HealthRecordHelperMethods.xmlToCodedValue(medicationXML.form[0]);
			_route = HealthRecordHelperMethods.xmlToCodedValue(medicationXML.route[0]);
			_frequency = HealthRecordHelperMethods.xmlToCodedValue(medicationXML.frequency[0]);
			_amountOrdered = new ValueAndUnit(medicationXML.amountOrdered.value, HealthRecordHelperMethods.xmlToCodedValue(medicationXML.amountOrdered.unit[0]));
			_refills = Number(medicationXML.refills);
			_substitutionPermitted = Boolean(medicationXML.substitutionPermitted);
			_instructions = medicationXML.instructions;
			_dateTimeStarted = DateUtil.parseW3CDTF(medicationXML.dateStarted.toString());
			_dateTimeStopped = DateUtil.parseW3CDTF(medicationXML.dateStopped.toString());
			_reasonStopped = medicationXML.reasonStopped;
			
			//TODO: Automate the color selection process
			if (name.value == ATORVASTATIN_RXCUI)
			{
				_color = 0xb38f81;
			}
			else if (name.value == HYDROCHLOROTHIAZIDE_RXCUI)
			{
				_color = 0x7f90aa;
			}
					
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

		public function get color():uint
		{
			return _color;
		}
		
		private function set color(value:uint):void
		{
			_color = value;
		}

		public function get name():CodedValue
		{
			return _name;
		}
		
		private function set name(value:CodedValue):void
		{
			_name = value;
		}
		
		public function get orderType():String
		{
			return _orderType;
		}
		
		private function set orderType(value:String):void
		{
			_orderType = value;
		}
		
		public function get orderedBy():String
		{
			return _orderedBy;
		}
		
		private function set orderedBy(value:String):void
		{
			_orderedBy = value;
		}

		public function get dateTimeOrdered():Date
		{
			return _dateTimeOrdered;
		}
		
		private function set dateTimeOrdered(value:Date):void
		{
			_dateTimeOrdered = value;
		}

		public function get dateTimeExpires():Date
		{
			return _dateTimeExpires;
		}
		
		private function set dateTimeExpires(value:Date):void
		{
			_dateTimeExpires = value;
		}

		public function get indication():String
		{
			return _indication;
		}
		
		private function set indication(value:String):void
		{
			_indication = value;
		}

		public function get activeIngredients():Vector.<ActiveIngredient>
		{
			return _activeIngredients;
		}
		
		private function set activeIngredients(value:Vector.<ActiveIngredient>):void
		{
			_activeIngredients = value;
		}

		public function get dose():ValueAndUnit
		{
			return _dose;
		}
		
		private function set dose(value:ValueAndUnit):void
		{
			_dose = value;
		}

		public function get form():CodedValue
		{
			return _form;
		}

		private function set form(value:CodedValue):void
		{
			_form = value;
		}
		
		public function get route():CodedValue
		{
			return _route;
		}

		private function set route(value:CodedValue):void
		{
			_route = value;
		}
		
		public function get frequency():CodedValue
		{
			return _frequency;
		}

		private function set frequency(value:CodedValue):void
		{
			_frequency = value;
		}
		
		public function get amountOrdered():ValueAndUnit
		{
			return _amountOrdered;
		}
		
		private function set amountOrdered(value:ValueAndUnit):void
		{
			_amountOrdered = value;
		}
		
		public function get refills():Number
		{
			return _refills;
		}

		private function set refills(value:Number):void
		{
			_refills = value;
		}

		public function get substitutionPermitted():Boolean
		{
			return _substitutionPermitted;
		}
		
		private function set substitutionPermitted(value:Boolean):void
		{
			_substitutionPermitted = value;
		}

		public function get instructions():String
		{
			return _instructions;
		}
		
		private function set instructions(value:String):void
		{
			_instructions = value;
		}
		
		public function get dateTimeStarted():Date
		{
			return _dateTimeStarted;
		}
		
		private function set dateTimeStarted(value:Date):void
		{
			_dateTimeStarted = value;
		}
		
		public function get dateTimeStopped():Date
		{
			return _dateTimeStopped;
		}
		
		private function set dateTimeStopped(value:Date):void
		{
			_dateTimeStopped = value;
		}

		public function get reasonStopped():String
		{
			return _reasonStopped;
		}
		
		private function set reasonStopped(value:String):void
		{
			_reasonStopped = value;
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