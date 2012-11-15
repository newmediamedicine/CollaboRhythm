package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.VitalSignFactory;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	import flash.net.URLVariables;

	[Bindable]
	public class BloodPressureHealthActionInputModel extends HealthActionInputModelBase implements IHealthActionInputModel
	{
		private var _position:String;
		private var _site:String;
		private var _systolic:String = "";
		private var _diastolic:String = "";
		private var _heartRate:String = "";

		public function BloodPressureHealthActionInputModel(scheduleItemOccurrence:ScheduleItemOccurrence = null,
															healthActionModelDetailsProvider:IHealthActionModelDetailsProvider = null)
		{
			super(scheduleItemOccurrence, healthActionModelDetailsProvider);
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

			var bloodPressureSystolic:VitalSign = vitalSignFactory.createBloodPressureSystolic(_currentDateSource.now(),
					systolic, null, null, site, position);
			var bloodPressureDiastolic:VitalSign = vitalSignFactory.createBloodPressureDiastolic(_currentDateSource.now(),
					diastolic, null, null, site, position);
			var heartRate:VitalSign = vitalSignFactory.createHeartRate(_currentDateSource.now(), heartRate, null, null,
					site, position);

			var results:Vector.<DocumentBase> = new Vector.<DocumentBase>();
			results.push(bloodPressureSystolic, bloodPressureDiastolic, heartRate);

			if (scheduleItemOccurrence)
			{
				scheduleItemOccurrence.createAdherenceItem(results, healthActionModelDetailsProvider.record,
						healthActionModelDetailsProvider.accountId, true);
			}
			else
			{
				for each (var result:DocumentBase in results)
				{
					result.pendingAction = DocumentBase.ACTION_CREATE;
					healthActionModelDetailsProvider.record.addDocument(result);
				}
			}
		}

		override public function set urlVariables(value:URLVariables):void
		{
			systolic = value.systolic;
			diastolic = value.diastolic;
			heartRate = value.heartrate;

			_urlVariables = value;
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

		public function get adherenceResultDate():Date
		{
			return null;
		}

		public function get dateMeasuredStart():Date
		{
			return null;
		}

		public function get isChangeTimeAllowed():Boolean
		{
			return true;
		}
	}
}
