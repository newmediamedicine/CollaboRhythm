package collaboRhythm.plugins.bathroom.model
{
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.shared.model.VitalSignFactory;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	import flash.net.URLVariables;

	public class BathroomHealthActionInputModel extends HealthActionInputModelBase
	{
		private var _numActivity:String = "";

		public function BathroomHealthActionInputModel(scheduleItemOccurrence:ScheduleItemOccurrence = null,
															scheduleModel:IScheduleModel = null)
		{
			//super(scheduleItemOccurrence, urlVariables, scheduleModel);
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
