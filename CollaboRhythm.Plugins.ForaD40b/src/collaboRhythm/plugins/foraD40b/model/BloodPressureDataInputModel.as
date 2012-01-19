package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.shared.model.VitalSignFactory;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	import flash.net.URLVariables;

	[Bindable]
	public class BloodPressureDataInputModel extends HealthActionInputModelBase
	{
		private var _position:String;
		private var _site:String;
		private var _systolic:String = "";
		private var _diastolic:String = "";
		private var _heartRate:String = "";

		public function BloodPressureDataInputModel(scheduleItemOccurrence:ScheduleItemOccurrence = null,
													scheduleModel:IScheduleModel = null)
		{
			super(scheduleItemOccurrence, urlVariables, scheduleModel);
		}

		public function submitBloodPressure(position:String, site:String):void
		{
			_position = position;
			_site = site;

			createVitalSigns();
		}

		private function createVitalSigns():void
		{
			var vitalSignFactory:VitalSignFactory = new VitalSignFactory();
			
			var bloodPressureSystolic:VitalSign = vitalSignFactory.createBloodPressureSystolic(_currentDateSource.now(), systolic, null, null, site, position);
			var bloodPressureDiastolic:VitalSign = vitalSignFactory.createBloodPressureDiastolic(_currentDateSource.now(), diastolic, null, null, site, position);
			var heartRate:VitalSign = vitalSignFactory.createHeartRate(_currentDateSource.now(), heartRate, null, null, site, position);

			var results:Vector.<DocumentBase> = new Vector.<DocumentBase>();
			results.push(bloodPressureSystolic, bloodPressureDiastolic, heartRate);

			if (scheduleItemOccurrence)
			{
				scheduleItemOccurrence.createAdherenceItem(results, _scheduleModel.accountId);

				_scheduleModel.createAdherenceItem(scheduleItemOccurrence);
			}
			else
			{
				_scheduleModel.createResults(results);
			}
		}

		override public function set urlVariables(value:URLVariables):void
		{
			systolic = value.systolic;
			diastolic = value.diastolic;
			heartRate = value.heartrate;
		}

		public function get systolic():String
		{
			return _systolic;
		}

		public function set systolic(value:String):void
		{
			_systolic = value;
		}

		public function get diastolic():String
		{
			return _diastolic;
		}

		public function set diastolic(value:String):void
		{
			_diastolic = value;
		}

		public function get heartRate():String
		{
			return _heartRate;
		}

		public function set heartRate(value:String):void
		{
			_heartRate = value;
		}

		public function get position():String
		{
			return _position;
		}

		public function set position(value:String):void
		{
			_position = value;
		}

		public function get site():String
		{
			return _site;
		}

		public function set site(value:String):void
		{
			_site = value;
		}
	}
}
