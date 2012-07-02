package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapterFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.Equipment;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionSchedule;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import mx.collections.ArrayCollection;

	public class ForaD40bHealthActionListViewAdapterFactory implements IHealthActionListViewAdapterFactory
	{
		private static const HEALTH_ACTION_NAME_BLOOD_PRESSURE:String = "Blood Pressure";
		private static const HEALTH_ACTION_NAME_BLOOD_GLUCOSE:String = "Blood Glucose";
		private static const EQUIPMENT_NAME:String = "FORA D40b";
		private static const BLOOD_PRESSURE_INSTRUCTIONS:String = "Use device to record blood pressure systolic and blood pressure diastolic readings. Heart rate will also be recorded. Press the power button and wait several seconds to take reading.";
		private static const BLOOD_GLUCOSE_INSTRUCTIONS:String = "Use device to record blood glucose. Insert test strip into device and apply a drop of blood.";

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
			var healthActionSchedule:HealthActionSchedule = scheduleItemOccurrence.scheduleItem as HealthActionSchedule;
			if (healthActionSchedule)
			{
				var equipment:Equipment = healthActionSchedule.scheduledEquipment;
				if (equipment)
				{
					if (healthActionSchedule.instructions == BLOOD_PRESSURE_INSTRUCTIONS &&
							equipment.name == EQUIPMENT_NAME)
						return new BloodPressureHealthActionListViewAdapter(scheduleItemOccurrence,
								healthActionModelDetailsProvider);
					else if (healthActionSchedule.instructions == BLOOD_GLUCOSE_INSTRUCTIONS &&
							equipment.name == EQUIPMENT_NAME)
						return new BloodGlucoseHealthActionListViewAdapter(scheduleItemOccurrence,
								healthActionModelDetailsProvider);
				}
			}
			return currentHealthActionListViewAdapter;
		}
	}
}
