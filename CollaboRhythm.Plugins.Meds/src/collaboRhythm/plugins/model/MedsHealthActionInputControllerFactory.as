package collaboRhythm.plugins.model
{
	import collaboRhythm.plugins.controller.MedsHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionInputControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import spark.components.ViewNavigator;

	public class MedsHealthActionInputControllerFactory implements IHealthActionInputControllerFactory
	{
		public function MedsHealthActionInputControllerFactory()
		{
		}

		public function createHealthActionInputController(name:String, measurements:String,
														  scheduleItemOccurrence:ScheduleItemOccurrence,
														  scheduleModel:IScheduleModel,
														  viewNavigator:ViewNavigator,
														  currentHealthActionInputController:HealthActionInputControllerBase):HealthActionInputControllerBase
		{
			if (name == "Meds")
				return new MedsHealthActionInputController(scheduleItemOccurrence, scheduleModel, viewNavigator);
			else
				return currentHealthActionInputController;
		}
	}
}
