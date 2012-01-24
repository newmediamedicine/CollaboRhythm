package collaboRhythm.plugins.intake.model
{
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.VitalSignFactory;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	import flash.net.URLVariables;

	public class IntakeHealthActionInputModel extends HealthActionInputModelBase
	{
		private var _fluid:String = "";
		private var _food:String = "";

		public function IntakeHealthActionInputModel(scheduleItemOccurrence:ScheduleItemOccurrence,
													 healthActionModelDetailsProvider:IHealthActionModelDetailsProvider)
		{
			super(scheduleItemOccurrence, healthActionModelDetailsProvider);
		}

		public function submitIntake():void
		{
			createVitalSigns();
		}

		private function createVitalSigns():void
		{
			var vitalSignFactory:VitalSignFactory = new VitalSignFactory();

			var intakeFluid:VitalSign = vitalSignFactory.createIntakeFluid(_currentDateSource.now(),
					fluid, null, null, null, null);
			var intakeFood:VitalSign = vitalSignFactory.createIntakeFood(_currentDateSource.now(),
					food, null, null, null, null);


			var results:Vector.<DocumentBase> = new Vector.<DocumentBase>();
			results.push(intakeFluid,  intakeFood);

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
			fluid = value.fluid;
			food = value.food;

			_urlVariables = value;
		}
		
		public function get fluid():String
		{
			return _fluid;
		}

		public function set fluid(value:String):void
		{
			_fluid = value;
		}

		public function get food():String
		{
			return _food;
		}

		public function set food(value:String):void
		{
			_food = value;
		}
	}
}
