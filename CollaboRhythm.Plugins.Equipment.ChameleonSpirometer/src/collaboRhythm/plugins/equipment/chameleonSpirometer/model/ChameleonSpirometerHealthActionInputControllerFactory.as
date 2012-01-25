package collaboRhythm.plugins.equipment.chameleonSpirometer.model
{
	import collaboRhythm.plugins.equipment.chameleonSpirometer.controller.RescueInhalerHealthActionInputController;
	import collaboRhythm.plugins.equipment.chameleonSpirometer.controller.SpirometerHealthActionInputController;
	import collaboRhythm.plugins.equipment.chameleonSpirometer.controller.SteroidInhalerHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.EquipmentHealthAction;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.plugins.schedule.shared.model.MedicationHealthAction;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class ChameleonSpirometerHealthActionInputControllerFactory implements IHealthActionInputControllerFactory
	{
		private static const HEALTH_ACTION_NAME_SPIROMETER_MEASUREMENT:String = "SpirometerMeasurement";
		private static const HEALTH_ACTION_NAME_RESCUE_INHALER:String = "RescueInhaler";
		private static const HEALTH_ACTION_NAME_STEROID_INHALER:String = "SteroidInhaler";
		private static const EQUIPMENT_NAME:String = "ChameleonSpirometer";

		public function ChameleonSpirometerHealthActionInputControllerFactory()
		{
		}

		public function createHealthActionInputController(healthAction:HealthActionBase,
														  scheduleItemOccurrence:ScheduleItemOccurrence,
														  healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
														  viewNavigator:ViewNavigator,
														  currentHealthActionInputController:IHealthActionInputController):IHealthActionInputController
		{
			if (healthAction.type == MedicationHealthAction.TYPE)
			{
				var medicationHealthAction:MedicationHealthAction = healthAction as MedicationHealthAction;
				if (medicationHealthAction && medicationHealthAction.medicationOrderName == "Albuterol")
				{
					return new RescueInhalerHealthActionInputController(scheduleItemOccurrence, healthActionModelDetailsProvider, viewNavigator);
				}
			}
			return currentHealthActionInputController;
		}

		public function createDeviceHealthActionInputController(urlVariables:URLVariables,
																scheduleItemOccurrence:ScheduleItemOccurrence,
																healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																viewNavigator:ViewNavigator,
																currentDeviceHealthActionInputController:IHealthActionInputController):IHealthActionInputController
		{
			if (urlVariables.healthActionType == EquipmentHealthAction.TYPE &&
					urlVariables.healthActionName == HEALTH_ACTION_NAME_SPIROMETER_MEASUREMENT &&
					urlVariables.equipmentName == EQUIPMENT_NAME)
				return new SpirometerHealthActionInputController(scheduleItemOccurrence,
						healthActionModelDetailsProvider, viewNavigator);
			else if (urlVariables.healthActionType == EquipmentHealthAction.TYPE &&
					urlVariables.healthActionName == HEALTH_ACTION_NAME_STEROID_INHALER &&
					urlVariables.equipmentName == EQUIPMENT_NAME)
				return new SteroidInhalerHealthActionInputController(scheduleItemOccurrence,
						healthActionModelDetailsProvider, viewNavigator);
			else if (urlVariables.healthActionType == EquipmentHealthAction.TYPE &&
					urlVariables.healthActionName == HEALTH_ACTION_NAME_RESCUE_INHALER &&
					urlVariables.equipmentName == EQUIPMENT_NAME)
				return new RescueInhalerHealthActionInputController(scheduleItemOccurrence,
						healthActionModelDetailsProvider, viewNavigator);
			else
				return currentDeviceHealthActionInputController;
		}
	}
}