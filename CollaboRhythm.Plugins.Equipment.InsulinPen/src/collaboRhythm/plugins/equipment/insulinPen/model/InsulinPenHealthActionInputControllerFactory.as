package collaboRhythm.plugins.equipment.insulinPen.model
{
	import collaboRhythm.plugins.equipment.insulinPen.controller.InsulinPenHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.EquipmentHealthAction;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleCollectionsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class InsulinPenHealthActionInputControllerFactory implements IHealthActionInputControllerFactory
	{
		private static const HEALTH_ACTION_NAME:String = "MedicationAdministration";
		private static const EQUIPMENT_NAME:String = "3 ML insulin detemir 100 UNT/ML Prefilled Syringe [Levemir]";

		public function InsulinPenHealthActionInputControllerFactory()
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
																healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																scheduleCollectionsProvider:IScheduleCollectionsProvider,
																viewNavigator:ViewNavigator,
																currentDeviceHealthActionInputController:IHealthActionInputController):IHealthActionInputController
		{
			if (urlVariables.healthActionType == EquipmentHealthAction.TYPE &&
					urlVariables.healthActionName == HEALTH_ACTION_NAME &&
					urlVariables.equipmentName == EQUIPMENT_NAME)
			{
				var scheduleItemOccurrence:ScheduleItemOccurrence = scheduleCollectionsProvider.findClosestScheduleItemOccurrence(EQUIPMENT_NAME);
				return new InsulinPenHealthActionInputController(scheduleItemOccurrence,
						healthActionModelDetailsProvider, viewNavigator);
			}
			else
			{
				return currentDeviceHealthActionInputController;
			}
		}
	}
}