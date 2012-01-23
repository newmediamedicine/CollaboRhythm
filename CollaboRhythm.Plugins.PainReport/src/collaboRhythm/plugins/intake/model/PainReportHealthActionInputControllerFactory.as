package collaboRhythm.plugins.painReport.model
{
	import collaboRhythm.plugins.painReport.controller.PainReportHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionInputControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.HealthAction;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class PainReportHealthActionInputControllerFactory implements IHealthActionInputControllerFactory
	{
		public function PainReportHealthActionInputControllerFactory()
		{
		}

		public function createHealthActionInputController(healthAction:HealthAction,
														  scheduleItemOccurrence:ScheduleItemOccurrence,
														  scheduleModel:IScheduleModel,
														  viewNavigator:ViewNavigator,
														  currentHealthActionInputController:HealthActionInputControllerBase):HealthActionInputControllerBase
		{
			if (healthAction.healthActionType == PainReportHealthActionListViewAdapter.HEALTH_ACTION_TYPE)
				return new PainReportHealthActionInputController(scheduleItemOccurrence, scheduleModel, viewNavigator);
			else
				return currentHealthActionInputController;
		}

		public function createDeviceHealthActionInputController(urlVariables:URLVariables,
																scheduleItemOccurrence:ScheduleItemOccurrence,
																scheduleModel:IScheduleModel,
																viewNavigator:ViewNavigator,
																currentDeviceHealthActionInputController:HealthActionInputControllerBase):HealthActionInputControllerBase
		{
			return currentDeviceHealthActionInputController;
		}
	}
}
