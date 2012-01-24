package collaboRhythm.plugins.bathroom.model
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	public class BathroomHealthActionInputModel implements IHealthActionInputModel
	{
		private var _numActivity:String = "";

		public function BathroomHealthActionInputModel(scheduleItemOccurrence:ScheduleItemOccurrence = null,
															healthActionModelDetailsProvider:IHealthActionModelDetailsProvider = null)
		{
			//super(scheduleItemOccurrence, urlVariables, scheduleModel);
		}

		public function get scheduleItemOccurrence():ScheduleItemOccurrence
		{
			return null;
		}

		public function set urlVariables(value:URLVariables):void
		{
		}
		/*		private function createVitalSigns():void
		{
			var vitalSignFactory:VitalSignFactory = new VitalSignFactory();

			var numAmbulations:VitalSign = vitalSignFactory.createNumberAmbulations(_currentDateSource.now(), numActivity, null, null, null, null);

			var results:Vector.<DocumentBase> = new Vector.<DocumentBase>();
			results.push(numAmbulations);

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

		public function submitBathroom():void
		{
			createVitalSigns();
		}

		override public function set urlVariables(value:URLVariables):void
		{
			numActivity = value.numActivity;
		}

		public function get numActivity():String
		{
			return _numActivity;
		}

		public function set numActivity(value:String):void
		{
			_numActivity = value;
		}
		*/
	}
}
