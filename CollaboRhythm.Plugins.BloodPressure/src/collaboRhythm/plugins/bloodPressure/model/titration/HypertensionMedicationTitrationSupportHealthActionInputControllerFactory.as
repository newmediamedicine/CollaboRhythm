package collaboRhythm.plugins.bloodPressure.model.titration
{
	import collaboRhythm.plugins.bloodPressure.controller.titration.HypertensionMedicationTitrationSupportHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleCollectionsProvider;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class HypertensionMedicationTitrationSupportHealthActionInputControllerFactory implements IHealthActionInputControllerFactory
	{
		public function HypertensionMedicationTitrationSupportHealthActionInputControllerFactory()
		{
		}

		public function createHealthActionInputController(healthAction:HealthActionBase,
														  scheduleItemOccurrence:ScheduleItemOccurrence,
														  healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
														  scheduleCollectionsProvider:IScheduleCollectionsProvider,
														  viewNavigator:ViewNavigator,
														  currentHealthActionInputController:IHealthActionInputController,
														  collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy):IHealthActionInputController
		{
			if (healthAction.type == HypertensionMedicationTitrationSupportHealthAction.HEALTH_ACTION_TYPE)
			{
				return new HypertensionMedicationTitrationSupportHealthActionInputController(scheduleItemOccurrence,
						healthActionModelDetailsProvider, viewNavigator, collaborationLobbyNetConnectionServiceProxy);
			}
			return currentHealthActionInputController;
		}

		public function createDeviceHealthActionInputController(urlVariables:URLVariables,
																healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																scheduleCollectionsProvider:IScheduleCollectionsProvider,
																viewNavigator:ViewNavigator,
																currentDeviceHealthActionInputController:IHealthActionInputController):IHealthActionInputController
		{
			return currentDeviceHealthActionInputController;
		}
	}
}
