package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionInputControllerBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import spark.components.ViewNavigator;

	public interface IHealthActionInputControllerFactory
	{
		function createHealthActionInputController(name:String, measurements:String,
												   scheduleItemOccurrence:ScheduleItemOccurrence,
												   scheduleModel:IScheduleModel,
												   viewNavigator:ViewNavigator,
												   currentHealthActionInputController:HealthActionInputControllerBase):HealthActionInputControllerBase;
	}
}
