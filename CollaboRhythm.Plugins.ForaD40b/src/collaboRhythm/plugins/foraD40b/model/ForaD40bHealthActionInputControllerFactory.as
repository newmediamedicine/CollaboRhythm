package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.foraD40b.controller.ForaD40bHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.DeviceGatewayConstants;
	import collaboRhythm.plugins.schedule.shared.model.EquipmentHealthAction;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleCollectionsProvider;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionSchedule;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class ForaD40bHealthActionInputControllerFactory implements IHealthActionInputControllerFactory
	{
		private static const HEALTH_ACTION_NAME_BLOOD_PRESSURE:String = DeviceGatewayConstants.BLOOD_PRESSURE_HEALTH_ACTION_NAME;
		private static const HEALTH_ACTION_NAME_BLOOD_GLUCOSE:String = DeviceGatewayConstants.BLOOD_GLUCOSE_HEALTH_ACTION_NAME;
		public static const EQUIPMENT_NAME:String = "FORA D40b";
		private static const BLOOD_PRESSURE_INSTRUCTIONS:String = "Use device to record blood pressure systolic and blood pressure diastolic readings. Heart rate will also be recorded. Press the power button and wait several seconds to take reading.";
		private static const BLOOD_GLUCOSE_INSTRUCTIONS:String = "Use device to record blood glucose. Insert test strip into device and apply a drop of blood.";

		public function ForaD40bHealthActionInputControllerFactory()
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
			if (healthAction.type == EquipmentHealthAction.TYPE)
			{
				var equipmentHealthAction:EquipmentHealthAction = EquipmentHealthAction(healthAction);
				if (equipmentHealthAction.equipmentName == EQUIPMENT_NAME)
					return new ForaD40bHealthActionInputController(equipmentHealthAction, scheduleItemOccurrence,
							healthActionModelDetailsProvider, scheduleCollectionsProvider, viewNavigator);
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

			if (urlVariables[DeviceGatewayConstants.HEALTH_ACTION_TYPE_KEY] == EquipmentHealthAction.TYPE &&
					urlVariables[DeviceGatewayConstants.EQUIPMENT_NAME_KEY] == EQUIPMENT_NAME)
			{
				scheduleItemOccurrence = scheduleCollectionsProvider.findClosestMatchingScheduleItemOccurrence(function (scheduleItemOccurrence:ScheduleItemOccurrence):Boolean
						{
							var healthActionSchedule:HealthActionSchedule = scheduleItemOccurrence.scheduleItem as
									HealthActionSchedule;
							if (healthActionSchedule && healthActionSchedule.scheduledEquipment)
							{
								var healthAction:ForaD40bHealthAction = new ForaD40bHealthAction(healthActionSchedule.name.text,
										healthActionSchedule.scheduledEquipment.name,
										healthActionSchedule.instructions);
								if (healthAction.isBloodPressure &&
										urlVariables[DeviceGatewayConstants.HEALTH_ACTION_NAME_KEY] ==
												DeviceGatewayConstants.BLOOD_PRESSURE_HEALTH_ACTION_NAME ||
										healthAction.isBloodGlucose &&
												urlVariables[DeviceGatewayConstants.HEALTH_ACTION_NAME_KEY] ==
														DeviceGatewayConstants.BLOOD_GLUCOSE_HEALTH_ACTION_NAME)
								{
									return true;
								}
							}
							return false;
						},
						urlVariables[DeviceGatewayConstants.CORRECTED_MEASURED_DATE_KEY]);
				return new ForaD40bHealthActionInputController(new ForaD40bHealthAction(urlVariables[DeviceGatewayConstants.HEALTH_ACTION_NAME_KEY],
						urlVariables[DeviceGatewayConstants.EQUIPMENT_NAME_KEY],
						urlVariables[DeviceGatewayConstants.HEALTH_ACTION_NAME_KEY]), scheduleItemOccurrence,
						healthActionModelDetailsProvider, scheduleCollectionsProvider, viewNavigator);
			}
			else
			{
				return currentDeviceHealthActionInputController;
			}
		}
	}
}
