package collaboRhythm.plugins.bathroom.model
{
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.VitalSignFactory;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	import flash.net.URLVariables;

	public class BathroomHealthActionInputModel extends HealthActionInputModelBase
	{
		private var _urine1:String = "";
		private var _urine2:String = "";
		
		public function BathroomHealthActionInputModel(scheduleItemOccurrence:ScheduleItemOccurrence = null,
															healthActionModelDetailsProvider:IHealthActionModelDetailsProvider = null)
		{
			super(scheduleItemOccurrence, healthActionModelDetailsProvider);
		}

		public function submitBathroom():void
		{
			createVitalSigns();
		}

		private function createVitalSigns():void
		{
			var vitalSignFactory:VitalSignFactory = new VitalSignFactory();

			var bathroomUrine1:VitalSign = vitalSignFactory.createBathroomUrine1(_currentDateSource.now(),
					urine1, null, null, null, null);
			var bathroomUrine2:VitalSign = vitalSignFactory.createBathroomUrine2(_currentDateSource.now(),
					urine2, null, null, null, null);


			var results:Vector.<DocumentBase> = new Vector.<DocumentBase>();
			results.push(bathroomUrine1, bathroomUrine2);

			if (scheduleItemOccurrence)
			{
				scheduleItemOccurrence.createAdherenceItem(results, _healthActionModelDetailsProvider.record,
						_healthActionModelDetailsProvider.accountId);
			}
			else
			{
				for each (var result:DocumentBase in results)
				{
					result.pendingAction = DocumentBase.ACTION_CREATE;
					_healthActionModelDetailsProvider.record.addDocument(result);
				}
			}
		}

		override public function set urlVariables(value:URLVariables):void
		{
			urine1 = value.urine1;
			urine2 = value.urine2;

			_urlVariables = value;
		}
		
		public function get urine1():String
		{
			return _urine1;
		}

		public function set urine1(value:String):void
		{
			_urine1 = value;
		}

		public function get urine2():String
		{
			return _urine2;
		}

		public function set urine2(value:String):void
		{
			_urine2 = value;
		}
	}
}
