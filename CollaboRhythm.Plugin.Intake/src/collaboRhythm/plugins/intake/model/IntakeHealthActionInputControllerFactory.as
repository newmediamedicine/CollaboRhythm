package collaboRhythm.plugins.intake.model
{
	import collaboRhythm.plugins.intake.controller.IntakeHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionInputControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import spark.components.ViewNavigator;

	public class IntakeHealthActionInputControllerFactory implements IHealthActionInputControllerFactory
	{
		public function IntakeHealthActionInputControllerFactory()
		{
		}

		public function createHealthActionInputController(name:String, measurements:String,
														  scheduleItemOccurrence:ScheduleItemOccurrence,
														  scheduleModel:IScheduleModel,
														  viewNavigator:ViewNavigator,
														  currentHealthActionInputController:HealthActionInputControllerBase):HealthActionInputControllerBase
		{
			if (name == "Intake")
				return new IntakeHealthActionInputController(scheduleItemOccurrence, scheduleModel, viewNavigator);
			else
				return currentHealthActionInputController;
		}
	}
}
