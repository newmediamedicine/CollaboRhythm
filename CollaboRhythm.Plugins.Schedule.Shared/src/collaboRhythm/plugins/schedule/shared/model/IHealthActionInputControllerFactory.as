package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public interface IHealthActionInputControllerFactory
	{
		function createHealthActionInputController(healthAction:HealthActionBase,
												   scheduleItemOccurrence:ScheduleItemOccurrence,
												   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
												   viewNavigator:ViewNavigator,
												   currentHealthActionInputController:IHealthActionInputController):IHealthActionInputController;

		function createDeviceHealthActionInputController(urlVariables:URLVariables,
														 healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
														 scheduleCollectionsProvider:IScheduleCollectionsProvider,
														 viewNavigator:ViewNavigator,
														 currentDeviceHealthActionInputController:IHealthActionInputController):IHealthActionInputController;
	}
}
