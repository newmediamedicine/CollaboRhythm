package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionInputControllerBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public interface IHealthActionInputControllerFactory
	{
		function createHealthActionInputController(healthAction:HealthAction,
												   scheduleItemOccurrence:ScheduleItemOccurrence,
												   scheduleModel:IScheduleModel,
												   viewNavigator:ViewNavigator,
												   currentHealthActionInputController:HealthActionInputControllerBase):HealthActionInputControllerBase;

		function createDeviceHealthActionInputController(urlVariables:URLVariables,
														 scheduleItemOccurrence:ScheduleItemOccurrence,
														 scheduleModel:IScheduleModel, viewNavigator:ViewNavigator,
														 currentDeviceHealthActionInputController:HealthActionInputControllerBase):HealthActionInputControllerBase;
	}
}
