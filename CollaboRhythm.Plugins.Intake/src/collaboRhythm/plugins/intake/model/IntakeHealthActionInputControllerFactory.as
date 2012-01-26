package collaboRhythm.plugins.intake.model
{
	import collaboRhythm.plugins.intake.controller.IntakeHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class IntakeHealthActionInputControllerFactory implements IHealthActionInputControllerFactory
	{
		public function IntakeHealthActionInputControllerFactory()
		{

		}
		public function createHealthActionInputController(healthAction:HealthActionBase,
														  scheduleItemOccurrence:ScheduleItemOccurrence,
														  healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
														  viewNavigator:ViewNavigator,
														  currentHealthActionInputController:IHealthActionInputController):IHealthActionInputController
		{
			if (healthAction.type == IntakeHealthActionListViewAdapter.HEALTH_ACTION_TYPE)
				return new IntakeHealthActionInputController(scheduleItemOccurrence, healthActionModelDetailsProvider, viewNavigator);
			else
				return currentHealthActionInputController;
		}

		public function createDeviceHealthActionInputController(urlVariables:URLVariables,
																scheduleItemOccurrence:ScheduleItemOccurrence,
																healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																viewNavigator:ViewNavigator,
																currentDeviceHealthActionInputController:IHealthActionInputController):IHealthActionInputController
		{
			return currentDeviceHealthActionInputController;
		}
	}
}