package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.schedule.shared.model.DeviceGatewayConstants;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapterFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.Equipment;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionSchedule;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import mx.collections.ArrayCollection;

	public class ForaD40bHealthActionListViewAdapterFactory implements IHealthActionListViewAdapterFactory
	{
		private static const HEALTH_ACTION_NAME_BLOOD_PRESSURE:String = DeviceGatewayConstants.BLOOD_PRESSURE_HEALTH_ACTION_NAME;
		private static const HEALTH_ACTION_NAME_BLOOD_GLUCOSE:String = DeviceGatewayConstants.BLOOD_GLUCOSE_HEALTH_ACTION_NAME;
		private static const EQUIPMENT_NAME:String = "FORA D40b";
		private static const BLOOD_PRESSURE_INSTRUCTIONS:String = "Use device to record blood pressure systolic and blood pressure diastolic readings. Heart rate will also be recorded. Press the power button and wait several seconds to take reading.";
		private static const BLOOD_PRESSURE_PARTIAL_INSTRUCTIONS:String = "blood pressure";
		private static const BLOOD_GLUCOSE_INSTRUCTIONS:String = "Use device to record blood glucose. Insert test strip into device and apply a drop of blood.";
		private static const BLOOD_GLUCOSE_PARTIAL_INSTRUCTIONS:String = "blood glucose";

		public function ForaD40bHealthActionListViewAdapterFactory()
		{
		}

		public function createUnscheduledHealthActionViewAdapters(healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																  adapters:ArrayCollection):void
		{

		}

		public function createScheduledHealthActionViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
															   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
															   currentHealthActionListViewAdapter:IHealthActionListViewAdapter):IHealthActionListViewAdapter
		{
			var healthActionSchedule:HealthActionSchedule = scheduleItemOccurrence ? scheduleItemOccurrence.scheduleItem as HealthActionSchedule : null;
			if (healthActionSchedule)
			{
				if (healthActionSchedule.scheduledEquipment)
				{
					if (isForBloodPressure(healthActionSchedule))
						return new BloodPressureHealthActionListViewAdapter(scheduleItemOccurrence,
								healthActionModelDetailsProvider);
					else if (isForBloodGlucose(healthActionSchedule))
						return new BloodGlucoseHealthActionListViewAdapter(scheduleItemOccurrence,
								healthActionModelDetailsProvider);
				}
			}
			return currentHealthActionListViewAdapter;
		}

		public static function isForBloodPressure(healthActionSchedule:HealthActionSchedule):Boolean
		{
			// TODO: implement a more robust check for blood pressure schedule items
			return healthActionSchedule.scheduledEquipment &&
					healthActionSchedule.scheduledEquipment.name == EQUIPMENT_NAME &&
					healthActionSchedule.instructions &&
					healthActionSchedule.instructions.toLowerCase().indexOf(BLOOD_PRESSURE_PARTIAL_INSTRUCTIONS) != -1;
		}

		public static function isForBloodGlucose(healthActionSchedule:HealthActionSchedule):Boolean
		{
			// TODO: implement a more robust check for blood glucose schedule items
			return healthActionSchedule.scheduledEquipment &&
					healthActionSchedule.scheduledEquipment.name == EQUIPMENT_NAME &&
					healthActionSchedule.instructions &&
					healthActionSchedule.instructions.toLowerCase().indexOf(BLOOD_GLUCOSE_PARTIAL_INSTRUCTIONS) != -1;
		}
	}
}
