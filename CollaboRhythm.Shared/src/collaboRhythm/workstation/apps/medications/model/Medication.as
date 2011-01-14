package collaboRhythm.workstation.apps.medications.model
{
	import collaboRhythm.workstation.apps.schedule.model.ScheduleItemBase;
	import collaboRhythm.workstation.model.HealthRecordServiceBase;
	import collaboRhythm.workstation.model.services.ICurrentDateSource;
	import collaboRhythm.workstation.model.services.WorkstationKernel;
	
	import mx.core.UIComponent;

	[Bindable]
	public class Medication extends ScheduleItemBase
	{
		private var _dateStarted:Date;
		private var _dateStopped:Date;
		private var _name:String;
		private var _brandName:String;
		private var _doseValue:Number;
		private var _doseUnit:String;
		private var _route:String;
		private var _strengthValue:Number;
		private var _strengthUnit:String;
		private var _frequency:String;
		private var _indication:String;
		private var _color:uint;
		private var _imageURI:String;
				
		private var _currentDateSource:ICurrentDateSource;
		
		public function Medication(medicationReportXML:XML)
		{			
			documentID = medicationReportXML.Meta.Document.@id;		
			_dateStarted = HealthRecordServiceBase.parseDate(medicationReportXML.Item.Medication.dateStarted.toString());
			_dateStopped = HealthRecordServiceBase.parseDate(medicationReportXML.Item.Medication.dateStopped.toString());
			_name = medicationReportXML.Item.Medication.name;
			_brandName = medicationReportXML.Item.Medication.brandName;
			_doseValue = medicationReportXML.Item.Medication.dose.value;
			_doseUnit = medicationReportXML.Item.Medication.dose.unit.@value;
			_route = medicationReportXML.Item.Medication.route;
			_strengthValue = medicationReportXML.Item.Medication.strength.value;
			_strengthUnit = medicationReportXML.Item.Medication.strength.unit.@value;
			_frequency = medicationReportXML.Item.Medication.frequency;
			_imageURI = "resources/images/apps/medications/" + _name + "_front.jpg";
			
			// hack: no indication in data now, so set it here for the moment
			if (_name == "Metformin")
			{
				_indication = "Diabetes";
				_color = 0xabbdab;
			}
			else if (_name == "Hydrochlorothiazide")
			{
				_indication = "High Blood Pressure";
				_color = 0x8295a8;
			}
			else if (_name == "Simvastatin")
			{
				_indication = "High Cholesterol";
				_color = 0xAF897A;
			}
			
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

		public function get dateStopped():Date
		{
			return _dateStopped;
		}

		private function set dateStopped(value:Date):void
		{
			_dateStopped = value;
		}

		public function get isInactive():Boolean
		{
			if (_dateStopped != null)
			{
				return _dateStopped < _currentDateSource.now();
			}
			return false;
		}

		public function get name():String
		{
			return _name;
		}
		
		private function set name(value:String):void
		{
			_name = value;
		}
		
		public function get brandName():String
		{
			return _brandName;
		}
		
		private function set brandName(value:String):void
		{
			_brandName = value;
		}
		
		public function get doseValue():Number
		{
			return _doseValue;
		}

		private function set doseValue(value:Number):void
		{
			_doseValue = value;
		}

		public function get doseUnit():String
		{
			return _doseUnit;
		}

		private function set doseUnit(value:String):void
		{
			_doseUnit = value;
		}
		
		public function get doseLabelText():String
		{
			return this.doseValue + " " + this.doseUnit;
		}

		public function get route():String
		{
			return _route;
		}

		private function set route(value:String):void
		{
			_route = value;
		}

		public function get strengthValue():Number
		{
			return _strengthValue;
		}

		private function set strengthValue(value:Number):void
		{
			_strengthValue = value;
		}

		public function get strengthUnit():String
		{
			return _strengthUnit;
		}

		private function set strengthUnit(value:String):void
		{
			_strengthUnit = value;
		}
		
		public function get strengthLabelText():String
		{
			return this.strengthValue + " " + this.strengthUnit;
		}

		public function get frequency():String
		{
			return _frequency;
		}

		private function set frequency(value:String):void
		{
			_frequency = value;
		}
		
		public function get indication():String
		{
			return _indication;
		}
		
		private function set indication(value:String):void
		{
			_indication = value;
		}
		
		public function get color():uint
		{
			return _color;
		}
		
		private function set color(value:uint):void
		{
			_color = value;
		}

		public function get imageURI():String
		{
			return _imageURI;
		}
		
		private function set imageURI(value:String):void
		{
			_imageURI = value;
		}
	}
}