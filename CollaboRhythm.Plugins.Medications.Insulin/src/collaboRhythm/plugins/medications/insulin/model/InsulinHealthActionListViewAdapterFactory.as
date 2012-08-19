package collaboRhythm.plugins.medications.insulin.model
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapterFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.filesystem.File;

	import mx.collections.ArrayCollection;

	public class InsulinHealthActionListViewAdapterFactory implements IHealthActionListViewAdapterFactory
	{
		public static const INSULIN_LEVEMIR_CODE:String = "847241";
		public static const INSULIN_LANTUS_CODE:String = "847232";
		public static const INSULIN_MEDICATION_CODES:Vector.<String> = new <String>[INSULIN_LEVEMIR_CODE, INSULIN_LANTUS_CODE];
		private static const MOVIES_DIRECTORY_NAME:String = "Movies";
		private static const JOSLIN_INSULIN_PEN_DEMO_MOVIE_FILE_NAME:String = "Joslin_Insulin_Pen_demo.mp4";

		public function InsulinHealthActionListViewAdapterFactory()
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
			if (ReflectionUtils.getClass(scheduleItemOccurrence.scheduleItem) == MedicationScheduleItem)
			{
				var medicationScheduleItem:MedicationScheduleItem = scheduleItemOccurrence.scheduleItem as MedicationScheduleItem;
				if (INSULIN_MEDICATION_CODES.indexOf(medicationScheduleItem.name.value) != -1)
				{
					if (currentHealthActionListViewAdapter)
						currentHealthActionListViewAdapter.instructionalVideoPath = File.documentsDirectory.
								resolvePath(MOVIES_DIRECTORY_NAME).resolvePath(JOSLIN_INSULIN_PEN_DEMO_MOVIE_FILE_NAME).nativePath;

					return new InsulinHealthActionListViewAdapter(scheduleItemOccurrence, healthActionModelDetailsProvider, currentHealthActionListViewAdapter);
				}
			}
			return currentHealthActionListViewAdapter;
		}
	}
}
