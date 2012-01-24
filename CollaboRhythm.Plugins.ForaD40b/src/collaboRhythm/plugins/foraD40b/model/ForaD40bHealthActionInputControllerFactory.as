package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.foraD40b.controller.BloodGlucoseHealthActionInputController;
	import collaboRhythm.plugins.foraD40b.controller.BloodPressureHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.EquipmentHealthAction;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class ForaD40bHealthActionInputControllerFactory implements IHealthActionInputControllerFactory
	{
		private static const NAME:String = "FORA D40b";
		private static const BLOOD_PRESSURE_INSTRUCTIONS:String = "press the power button and wait several seconds to take reading";// "Use device to record blood pressure systolic and blood pressure diastolic readings. Heart rate will also be recorded. Press the power button and wait several seconds to take reading.";
		private static const BLOOD_GLUCOSE_INSTRUCTIONS:String = "Use device to record blood glucose. Insert test strip into device and apply a drop of blood.";

		public function ForaD40bHealthActionInputControllerFactory()
		{
		}

		public function createHealthActionInputController(healthAction:HealthActionBase,
														  scheduleItemOccurrence:ScheduleItemOccurrence,
														  healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
														  viewNavigator:ViewNavigator,
														  currentHealthActionInputController:IHealthActionInputController):IHealthActionInputController
		{
			if (healthAction.type == EquipmentHealthAction.TYPE)
			{
				var equipmentHealthAction:EquipmentHealthAction = EquipmentHealthAction(healthAction);
				if (equipmentHealthAction.name == BLOOD_PRESSURE_INSTRUCTIONS &&
						equipmentHealthAction.equipmentName == NAME)
					return new BloodPressureHealthActionInputController(scheduleItemOccurrence, healthActionModelDetailsProvider, viewNavigator);
				else if (equipmentHealthAction.name == BLOOD_GLUCOSE_INSTRUCTIONS &&
						equipmentHealthAction.equipmentName == NAME)
					return new BloodGlucoseHealthActionInputController(scheduleItemOccurrence, healthActionModelDetailsProvider, viewNavigator);
			}
			return currentHealthActionInputController;
		}

		public function createDeviceHealthActionInputController(urlVariables:URLVariables,
																scheduleItemOccurrence:ScheduleItemOccurrence,
																healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																viewNavigator:ViewNavigator,
																currentDeviceHealthActionInputController:IHealthActionInputController):IHealthActionInputController
		{
			if (urlVariables.healthActionType == "Equipment" && urlVariables.healthActionName == "Blood Pressure" &&
					urlVariables.equipmentName == "ForaD40b")
				return new BloodPressureHealthActionInputController(scheduleItemOccurrence, healthActionModelDetailsProvider, viewNavigator);
			else if (urlVariables.healthActionType == "Equipment" && urlVariables.healthActionName == "Blood Glucose" &&
					urlVariables.equipmentName == "ForaD40b")
				return new BloodGlucoseHealthActionInputController(scheduleItemOccurrence, healthActionModelDetailsProvider, viewNavigator);
			else
				return currentDeviceHealthActionInputController;
		}
	}
}
