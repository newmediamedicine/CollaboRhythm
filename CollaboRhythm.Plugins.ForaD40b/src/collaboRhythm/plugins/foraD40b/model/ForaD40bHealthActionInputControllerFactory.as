package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.foraD40b.controller.BloodGlucoseDataInputController;
	import collaboRhythm.plugins.foraD40b.controller.BloodPressureDataInputController;
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionInputControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import spark.components.ViewNavigator;

	public class ForaD40bHealthActionInputControllerFactory implements IHealthActionInputControllerFactory
	{
		private static const NAME:String = "FORA D40b";
		private static const BLOOD_PRESSURE:String = "Blood Pressure";
		private static const BLOOD_GLUCOSE:String = "Blood Glucose";
		private static const BLOOD_PRESSURE_INSTRUCTIONS:String = "press the power button and wait several seconds to take reading";// "Use device to record blood pressure systolic and blood pressure diastolic readings. Heart rate will also be recorded. Press the power button and wait several seconds to take reading.";
		private static const BLOOD_GLUCOSE_INSTRUCTIONS:String = "Use device to record blood glucose. Insert test strip into device and apply a drop of blood.";

		public function ForaD40bHealthActionInputControllerFactory()
		{
		}

		public function createHealthActionInputController(name:String, measurements:String,
														  scheduleItemOccurrence:ScheduleItemOccurrence,
														  scheduleModel:IScheduleModel,
														  viewNavigator:ViewNavigator,
														  currentHealthActionInputController:HealthActionInputControllerBase):HealthActionInputControllerBase
		{
			if (measurements == BLOOD_PRESSURE || measurements == BLOOD_PRESSURE_INSTRUCTIONS)
				return new BloodPressureDataInputController(scheduleItemOccurrence, scheduleModel, viewNavigator);
			else if (measurements == BLOOD_GLUCOSE || measurements == BLOOD_GLUCOSE_INSTRUCTIONS)
				return new BloodGlucoseDataInputController(scheduleItemOccurrence, scheduleModel, viewNavigator);
			else
				return currentHealthActionInputController;
		}
	}
}
