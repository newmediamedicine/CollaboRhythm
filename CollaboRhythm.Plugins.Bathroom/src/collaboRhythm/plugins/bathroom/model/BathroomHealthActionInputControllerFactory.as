package collaboRhythm.plugins.bathroom.model
{
	import collaboRhythm.plugins.bathroom.controller.BathroomHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionInputControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import spark.components.ViewNavigator;

	public class BathroomHealthActionInputControllerFactory implements IHealthActionInputControllerFactory
	{
		public function BathroomHealthActionInputControllerFactory()
		{
		}

		public function createHealthActionInputController(name:String, measurements:String,
														  scheduleItemOccurrence:ScheduleItemOccurrence,
														  scheduleModel:IScheduleModel,
														  viewNavigator:ViewNavigator,
														  currentHealthActionInputController:HealthActionInputControllerBase):HealthActionInputControllerBase
		{
			//if (name == "Bathroom")
				return new BathroomHealthActionInputController(scheduleItemOccurrence, scheduleModel, viewNavigator);
			//else
			//	return currentHealthActionInputController;
		}
	}
}
