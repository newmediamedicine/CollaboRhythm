package collaboRhythm.plugins.schedule.shared.model
{
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
														  viewNavigator:ViewNavigator):IHealthActionInputController
		{
			var currentHealthActionInputController:IHealthActionInputController = null;
			for each (var healthActionInputControllerFactory:IHealthActionInputControllerFactory in _factoryArray)
			{
				var healthActionInputController:IHealthActionInputController = healthActionInputControllerFactory.createHealthActionInputController(healthAction,
						scheduleItemOccurrence, healthActionModelDetailsProvider, viewNavigator, currentHealthActionInputController);
				if (healthActionInputController)
					currentHealthActionInputController = healthActionInputController;
			}

			return currentHealthActionInputController;
		}

		public function createDeviceHealthActionInputController(urlVariables:URLVariables,
																scheduleItemOccurrence:ScheduleItemOccurrence,
																healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																viewNavigator:ViewNavigator):IHealthActionInputController
		{
			var currentDeviceHealthActionInputController:IHealthActionInputController = null;
			for each (var healthActionInputControllerFactory:IHealthActionInputControllerFactory in _factoryArray)
			{
				var deviceHealthActionInputController:IHealthActionInputController = healthActionInputControllerFactory.createDeviceHealthActionInputController(urlVariables,
						scheduleItemOccurrence, healthActionModelDetailsProvider, viewNavigator, currentDeviceHealthActionInputController);
				if (deviceHealthActionInputController)
					currentDeviceHealthActionInputController = deviceHealthActionInputController;
			}

			return currentDeviceHealthActionInputController;
		}
	}
}
