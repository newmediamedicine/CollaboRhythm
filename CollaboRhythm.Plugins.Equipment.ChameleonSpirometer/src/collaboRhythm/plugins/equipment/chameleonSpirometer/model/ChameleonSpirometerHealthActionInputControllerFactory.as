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
	import collaboRhythm.plugins.schedule.shared.model.IScheduleCollectionsProvider;
	import collaboRhythm.plugins.schedule.shared.model.MedicationHealthAction;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class ChameleonSpirometerHealthActionInputControllerFactory implements IHealthActionInputControllerFactory
	{
		private static const HEALTH_ACTION_NAME_SPIROMETER_MEASUREMENT:String = "SpirometerMeasurement";
		private static const HEALTH_ACTION_NAME_RESCUE_INHALER:String = "RescueInhaler";
		private static const HEALTH_ACTION_NAME_STEROID_INHALER:String = "SteroidInhaler";
		private static const RESCUE_INHALER_NAME:String = "200 ACTUAT Albuterol 0.09 MG/ACTUAT Metered Dose Inhaler [Proventil]";
		private static const STEROID_INHALER_NAME:String = "120 ACTUAT Fluticasone propionate 0.044 MG/ACTUAT Metered Dose Inhaler [Flovent]";
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
				if (medicationHealthAction && medicationHealthAction.medicationOrderName == RESCUE_INHALER_NAME)
				{
					return new RescueInhalerHealthActionInputController(scheduleItemOccurrence,
							healthActionModelDetailsProvider, viewNavigator);
				}
			}
			return currentHealthActionInputController;
		}

		public function createDeviceHealthActionInputController(urlVariables:URLVariables,
																healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																scheduleCollectionsProvider:IScheduleCollectionsProvider,
																viewNavigator:ViewNavigator,
																currentDeviceHealthActionInputController:IHealthActionInputController):IHealthActionInputController
		{
			var scheduleItemOccurrence:ScheduleItemOccurrence;
			if (urlVariables.healthActionType == EquipmentHealthAction.TYPE &&
					urlVariables.healthActionName == HEALTH_ACTION_NAME_SPIROMETER_MEASUREMENT &&
					urlVariables.equipmentName == EQUIPMENT_NAME)
			{
				scheduleItemOccurrence = scheduleCollectionsProvider.findClosestScheduleItemOccurrence(EQUIPMENT_NAME);
				return new SpirometerHealthActionInputController(scheduleItemOccurrence,
						healthActionModelDetailsProvider, viewNavigator);
			}
			else if (urlVariables.healthActionType == EquipmentHealthAction.TYPE &&
					urlVariables.healthActionName == HEALTH_ACTION_NAME_STEROID_INHALER &&
					urlVariables.equipmentName == EQUIPMENT_NAME)
			{
				scheduleItemOccurrence = scheduleCollectionsProvider.findClosestScheduleItemOccurrence(STEROID_INHALER_NAME);
				return new SteroidInhalerHealthActionInputController(scheduleItemOccurrence,
						healthActionModelDetailsProvider, viewNavigator);
			}
			else if (urlVariables.healthActionType == EquipmentHealthAction.TYPE &&
					urlVariables.healthActionName == HEALTH_ACTION_NAME_RESCUE_INHALER &&
					urlVariables.equipmentName == EQUIPMENT_NAME)
			{
				scheduleItemOccurrence = scheduleCollectionsProvider.findClosestScheduleItemOccurrence(RESCUE_INHALER_NAME);
				return new RescueInhalerHealthActionInputController(scheduleItemOccurrence,
						healthActionModelDetailsProvider, viewNavigator);
			}
			else
			{
				return currentDeviceHealthActionInputController;
			}
		}
	}
}