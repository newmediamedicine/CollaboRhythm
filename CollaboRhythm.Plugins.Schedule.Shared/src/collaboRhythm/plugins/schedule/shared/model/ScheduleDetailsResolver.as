package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.DateUtil;

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

		/**
		 * Determines the current schedule details for any schedule items matching any of the specified
		 * scheduleItemValues (scheduleItem.name.value).
		 * @param scheduleItemValues
		 * @param todayOnly
		 * @param scheduleItemCollection
		 * @param now
		 * @return
		 */
		public static function getCurrentScheduleDetails(scheduleItemValues:Vector.<String>, todayOnly:Boolean,
														 scheduleItemCollection:ArrayCollection,
														 now:Date):ScheduleDetails
		{
			var scheduleDetails:ScheduleDetails;
			for each (var scheduleItem:ScheduleItemBase in scheduleItemCollection)
			{
				if (scheduleItemValues.indexOf(scheduleItem.name.value) != -1)
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
						// TODO: exactly what span of time should we use to look for the "next" scheduled item? Currently we are using the 48 hours after the current time (a 2 day window)
						currentPeriodDateStart = now;
						currentPeriodDateEnd = new Date(now.valueOf() + 2 * ScheduleItemBase.MILLISECONDS_IN_DAY);
					}

					var scheduleItemOccurrences:Vector.<ScheduleItemOccurrence> = scheduleItem.getScheduleItemOccurrences(
							currentPeriodDateStart, currentPeriodDateEnd, true);
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
				for each (scheduleItem in scheduleItemCollection)
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

		/**
		 * Determines the possible date for the next (future and not yet acted upon) occurrence of a schedule matching
		 * one of the specified scheduleItemValues. If any matching schedule is active, use the occurrence that
		 * both (a) ends after now and (b) has not been acted upon (no adherence item). Otherwise (no match, no longer
		 * active), return a possible start date for a schedule by extrapolating from the last matching scheduled
		 * occurrence to a theoretical occurrence that ends after now.
		 * @param scheduleItemValues
		 * @param scheduleItemCollection
		 * @param now
		 * @return
		 */
		public static function getPossibleDateOfNextOccurrence(scheduleItemValues:Vector.<String>,
																 scheduleItemCollection:ArrayCollection,
																 now:Date):Date
		{
			var scheduleDetails:ScheduleDetails = getCurrentScheduleDetails(scheduleItemValues, false, scheduleItemCollection, now);
			if (scheduleDetails && scheduleDetails.occurrence)
			{
				return scheduleDetails.occurrence.dateStart;
			}
			else
			{
				var latestMatchingSchedule:ScheduleItemBase = getLatestMatchingSchedule(scheduleItemValues,
						scheduleItemCollection);
				if (latestMatchingSchedule)
				{
					var latestDateStart:Date = latestMatchingSchedule.dateStart;
					var latestDateEnd:Date = latestMatchingSchedule.dateEnd;
					var nextOccurrenceDateEnd:Date = new Date(now.fullYear, now.month, now.date,
							latestDateEnd.hours, latestDateEnd.minutes, latestDateEnd.seconds,
							latestDateEnd.milliseconds);
					var nextOccurrenceDateStart:Date = new Date(now.fullYear, now.month, now.date,
							latestDateStart.hours, latestDateStart.minutes, latestDateStart.seconds,
							latestDateStart.milliseconds);
					if (nextOccurrenceDateEnd.valueOf() < now.valueOf())
					{
						nextOccurrenceDateStart = new Date(nextOccurrenceDateStart.valueOf() +
								DateUtil.MILLISECONDS_IN_DAY);
					}
					return nextOccurrenceDateStart;
				}
			}
			return null;
		}

		public static function getLatestMatchingSchedule(scheduleItemValues:Vector.<String>,
												  scheduleItemCollection:ArrayCollection):ScheduleItemBase
		{
			var latestMatchingSchedule:ScheduleItemBase;
			for (var i:int = scheduleItemCollection.length - 1; i >= 0; i--)
			{
				var scheduleItem:ScheduleItemBase = scheduleItemCollection[i];
				if (scheduleItemValues.indexOf(scheduleItem.name.value) != -1)
				{
					latestMatchingSchedule = scheduleItem;
					break;
				}
			}
			return latestMatchingSchedule;
		}
	}
}
