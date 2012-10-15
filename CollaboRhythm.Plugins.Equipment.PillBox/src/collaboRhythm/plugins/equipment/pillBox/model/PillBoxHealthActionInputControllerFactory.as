package collaboRhythm.plugins.equipment.pillBox.model
{
	import collaboRhythm.plugins.equipment.pillBox.controller.PillBoxHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.EquipmentHealthAction;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleCollectionsProvider;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;
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
														  currentHealthActionInputController:IHealthActionInputController,
														  collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy):IHealthActionInputController
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
				var scheduleItemOccurrence:ScheduleItemOccurrence = findClosestScheduleItemOccurrence(urlVariables, scheduleCollectionsProvider);
				return new PillBoxHealthActionInputController(scheduleItemOccurrence,
						healthActionModelDetailsProvider, viewNavigator);
			}
			else
			{
				return currentDeviceHealthActionInputController;
			}
		}


		public function findClosestScheduleItemOccurrence(urlVariables:URLVariables,
														  scheduleCollectionsProvider:IScheduleCollectionsProvider):ScheduleItemOccurrence
		{
			var name:String;
			switch (urlVariables.bin)
			{
				case "1":
					name = "Ibuprofen 400 MG Oral Tablet [Motrin]";
					break;
				case "2":
					name = "Cyclobenzaprine hydrochloride 5 MG Oral Tablet [Flexeril]";
					break;
				case "3":
					name = "Ibuprofen 400 MG Oral Tablet [Motrin]";
					break;
				case "4":
					name = "Cyclobenzaprine hydrochloride 5 MG Oral Tablet [Flexeril]";
					break;
			}

			return scheduleCollectionsProvider.findClosestScheduleItemOccurrence(name, urlVariables.dateMeasuredStart);

		}
	}
}
