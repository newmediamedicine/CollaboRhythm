package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.services.DateUtil;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import mx.collections.ArrayCollection;

	/**
	 * Utility class which determines the current schedule for a given medication or other health action.
	 */
	public class ScheduleDetailsResolver
	{
		/**
		 * Number of milliseconds after the end of a schedule occurrence for which the item/action is to be still considered
		 * "current" or "next" even though it is in the past (has been missed). This a non-negative value would allow the
		 * schedule to be changed for a dose of medication (for example) after the medication was due to be taken.
		 */
		private static const NEXT_OCCURRENCE_DELTA:Number = 0;

		private static const ALLOW_CHANGE_LATE_OCCURRENCE:Boolean = true;

		public function ScheduleDetailsResolver()
		{
		}

		public static function getCurrentScheduleDetails(scheduleItemNameValues:Vector.<String>, todayOnly:Boolean,
														 scheduleItemCollection:ArrayCollection,
														 now:Date):ScheduleDetails
		{
			var scheduleDetails:ScheduleDetails;
			for each (var scheduleItem:ScheduleItemBase in
					scheduleItemCollection)
			{
				if (scheduleItemNameValues.indexOf(scheduleItem.name.value) != -1)
				{
					var currentPeriodDateStart:Date;
					var currentPeriodDateEnd:Date;
					if (todayOnly)
					{
						currentPeriodDateEnd = DateUtil.roundTimeToNextDay(now);
						currentPeriodDateStart = new Date(currentPeriodDateEnd.valueOf() -
								ScheduleItemBase.MILLISECONDS_IN_DAY);
					}
					else
					{
						// TODO: exactly what span of time should we use to look for the "next" scheduled item? Currently we are using 24 hours before to 48 hours after the current time (a 3 day window)
						currentPeriodDateStart = new Date(now.valueOf() - ScheduleItemBase.MILLISECONDS_IN_DAY);
						currentPeriodDateEnd = new Date(now.valueOf() + 2 * ScheduleItemBase.MILLISECONDS_IN_DAY);
					}

					var scheduleItemOccurrences:Vector.<ScheduleItemOccurrence> = scheduleItem.getScheduleItemOccurrences(
							currentPeriodDateStart, currentPeriodDateEnd);
					for each (var scheduleItemOccurrence:ScheduleItemOccurrence in scheduleItemOccurrences)
					{
						if (todayOnly)
						{
							scheduleDetails = new ScheduleDetails(scheduleItem, scheduleItemOccurrence);
							break;
						}
						else
						{
							var currentScheduleCutoff:Number = ALLOW_CHANGE_LATE_OCCURRENCE ? DateUtil.roundTimeToNextDay(now).valueOf() -
									ScheduleItemBase.MILLISECONDS_IN_DAY : (now.valueOf() - NEXT_OCCURRENCE_DELTA);
							if ((scheduleItemOccurrence.adherenceItem == null ||
									scheduleItemOccurrence.adherenceItem.adherence == false) &&
									scheduleItemOccurrence.dateEnd.valueOf() >= currentScheduleCutoff)
							{
								scheduleDetails = new ScheduleDetails(scheduleItem, scheduleItemOccurrence);
								break;
							}
						}
					}
					if (scheduleDetails)
						break;
				}
			}

			if (scheduleDetails)
			{
				for each (scheduleItem in
						scheduleItemCollection)
				{
					if (scheduleItem.name.value == scheduleDetails.currentSchedule.name.value)
					{
						// TODO: find a more robust way of determining the previousSchedule; currently we look for any occurrence after midnight the day prior to the current occurrence
						// For dateEnd, subtract 1 millisecond because dateEnd is inclusive, and we want to exclude occurrences that start at occurrence.dateStart
						scheduleItemOccurrences = scheduleItem.getScheduleItemOccurrences(
								new Date(DateUtil.roundTimeToNextDay(scheduleDetails.occurrence.dateStart).valueOf() -
										ScheduleItemBase.MILLISECONDS_IN_DAY * 2),
								new Date(scheduleDetails.occurrence.dateStart.valueOf() - 1));
						if (scheduleItemOccurrences.length > 0)
						{
							scheduleDetails.previousSchedule = scheduleItem;
							break;
						}
					}
				}
			}
			else
			{
				scheduleDetails = new ScheduleDetails(null, null);
			}
			return scheduleDetails;
		}
	}
}
