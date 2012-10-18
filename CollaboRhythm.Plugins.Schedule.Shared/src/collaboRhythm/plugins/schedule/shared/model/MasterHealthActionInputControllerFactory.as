package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.IComponentContainer;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class MasterHealthActionInputControllerFactory
	{
		private var _factoryArray:Array;

		public function MasterHealthActionInputControllerFactory(componentContainer:IComponentContainer)
		{
			_factoryArray = componentContainer.resolveAll(IHealthActionInputControllerFactory);
		}

		public function createHealthActionInputController(healthAction:HealthActionBase,
														  scheduleItemOccurrence:ScheduleItemOccurrence,
														  healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
														  scheduleCollectionsProvider:IScheduleCollectionsProvider,
														  viewNavigator:ViewNavigator,
														  collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy):IHealthActionInputController
		{
			var currentHealthActionInputController:IHealthActionInputController = null;
			for each (var healthActionInputControllerFactory:IHealthActionInputControllerFactory in _factoryArray)
			{
				var healthActionInputController:IHealthActionInputController = healthActionInputControllerFactory.createHealthActionInputController(healthAction,
						scheduleItemOccurrence, healthActionModelDetailsProvider, scheduleCollectionsProvider,
						viewNavigator, currentHealthActionInputController, collaborationLobbyNetConnectionServiceProxy);
				if (healthActionInputController)
					currentHealthActionInputController = healthActionInputController;
			}

			return currentHealthActionInputController;
		}

		public function createDeviceHealthActionInputController(urlVariables:URLVariables,
																healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																scheduleCollectionsProvider:IScheduleCollectionsProvider,
																viewNavigator:ViewNavigator):IHealthActionInputController
		{
			var currentDeviceHealthActionInputController:IHealthActionInputController = null;
			for each (var healthActionInputControllerFactory:IHealthActionInputControllerFactory in _factoryArray)
			{
				var deviceHealthActionInputController:IHealthActionInputController = healthActionInputControllerFactory.createDeviceHealthActionInputController(urlVariables,
						healthActionModelDetailsProvider, scheduleCollectionsProvider, viewNavigator,
						currentDeviceHealthActionInputController);
				if (deviceHealthActionInputController)
					currentDeviceHealthActionInputController = deviceHealthActionInputController;
			}

			return currentDeviceHealthActionInputController;
		}
	}
}
