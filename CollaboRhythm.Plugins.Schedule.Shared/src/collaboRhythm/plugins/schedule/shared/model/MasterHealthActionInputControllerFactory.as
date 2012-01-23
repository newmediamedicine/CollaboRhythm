package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionInputControllerBase;
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

		public function createHealthActionInputController(healthAction:HealthAction,
														  scheduleItemOccurrence:ScheduleItemOccurrence,
														  scheduleModel:IScheduleModel,
														  viewNavigator:ViewNavigator):HealthActionInputControllerBase
		{
			var currentHealthActionInputController:HealthActionInputControllerBase = null;
			for each (var healthActionInputControllerFactory:IHealthActionInputControllerFactory in _factoryArray)
			{
				var healthActionInputController:HealthActionInputControllerBase = healthActionInputControllerFactory.createHealthActionInputController(healthAction,
						scheduleItemOccurrence, scheduleModel, viewNavigator, currentHealthActionInputController);
				if (healthActionInputController)
					currentHealthActionInputController = healthActionInputController;
			}

			return currentHealthActionInputController;
		}

		public function createDeviceHealthActionInputController(urlVariables:URLVariables,
																scheduleItemOccurrence:ScheduleItemOccurrence,
																scheduleModel:IScheduleModel,
																viewNavigator:ViewNavigator):HealthActionInputControllerBase
		{
			var currentDeviceHealthActionInputController:HealthActionInputControllerBase = null;
			for each (var healthActionInputControllerFactory:IHealthActionInputControllerFactory in _factoryArray)
			{
				var deviceHealthActionInputController:HealthActionInputControllerBase = healthActionInputControllerFactory.createDeviceHealthActionInputController(urlVariables,
						scheduleItemOccurrence, scheduleModel, viewNavigator, currentDeviceHealthActionInputController);
				if (deviceHealthActionInputController)
					currentDeviceHealthActionInputController = deviceHealthActionInputController;
			}

			return currentDeviceHealthActionInputController;
		}
	}
}
