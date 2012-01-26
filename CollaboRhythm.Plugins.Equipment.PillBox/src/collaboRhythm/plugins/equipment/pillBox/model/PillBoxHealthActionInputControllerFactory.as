package collaboRhythm.plugins.equipment.pillBox.model
{
	import collaboRhythm.plugins.equipment.pillBox.controller.PillBoxHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.EquipmentHealthAction;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class PillBoxHealthActionInputControllerFactory implements IHealthActionInputControllerFactory
	{
		private static const HEALTH_ACTION_NAME:String = "MedicationAdministration";
		private static const EQUIPMENT_NAME:String = "PillBox";

		public function PillBoxHealthActionInputControllerFactory()
		{
		}

		public function createHealthActionInputController(healthAction:HealthActionBase,
														  scheduleItemOccurrence:ScheduleItemOccurrence,
														  healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
														  viewNavigator:ViewNavigator,
														  currentHealthActionInputController:IHealthActionInputController):IHealthActionInputController
		{
			return currentHealthActionInputController;
		}

		public function createDeviceHealthActionInputController(urlVariables:URLVariables,
																scheduleItemOccurrence:ScheduleItemOccurrence,
																healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																viewNavigator:ViewNavigator,
																currentDeviceHealthActionInputController:IHealthActionInputController):IHealthActionInputController
		{
			if (urlVariables.healthActionType == EquipmentHealthAction.TYPE &&
					urlVariables.healthActionName == HEALTH_ACTION_NAME &&
					urlVariables.equipmentName == EQUIPMENT_NAME)
				return new PillBoxHealthActionInputController(scheduleItemOccurrence,
						healthActionModelDetailsProvider, viewNavigator);
			else
				return currentDeviceHealthActionInputController;
		}
	}
}
