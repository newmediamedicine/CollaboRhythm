package collaboRhythm.shared.model.medications
{
	import collaboRhythm.plugins.schedule.shared.model.ScheduleDetailsResolver;
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmValueAndUnit;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.DateUtil;
	import collaboRhythm.shared.model.services.ICurrentDateSource;

	import mx.collections.ArrayCollection;

	public class MedicationTitrationAnalyzer
	{
		private var _medicationScheduleItemsCollection:ArrayCollection;
		private var _currentDateSource:ICurrentDateSource;
		private var _mostRecentDoseChangeMedication:MedicationScheduleItem;

		public function MedicationTitrationAnalyzer(medicationScheduleItemsCollection:ArrayCollection, currentDateSource:ICurrentDateSource)
		{
			_medicationScheduleItemsCollection = medicationScheduleItemsCollection;
			_currentDateSource = currentDateSource;
		}

		public function getMostRecentDoseChange():Date
		{
			var mostRecentDoseChange:Date = null;

			// TODO: detect schedule end times (effective end, with recurrence evaluated) as well as start times
			for each (var medicationScheduleItem:MedicationScheduleItem in _medicationScheduleItemsCollection)
			{
				var doseChangeDate:Date = getDoseChangeDate(medicationScheduleItem);
				if (doseChangeDate)
				{
					if (mostRecentDoseChange)
					{
						if (mostRecentDoseChange.time < doseChangeDate.time)
						{
							mostRecentDoseChange = doseChangeDate;
							mostRecentDoseChangeMedication = medicationScheduleItem;
						}
					}
					else
					{
						mostRecentDoseChange = doseChangeDate;
						mostRecentDoseChangeMedication = medicationScheduleItem;
					}
				}
			}

			return mostRecentDoseChange;
		}

		/**
		 * Determines if the medicationScheduleItem corresponds to a change in dose. If it does correspond to a change,
		 * the date of the change is returned, otherwise null. The date of the change will either be (a) the dateStart
		 * of the fist occurrence if the medication is new or has changed from the previous total dose (increase or
		 * decrease) or (b) the dateStart of the occurrence that would have occurred AFTER the last occurrence if the
		 * medication schedule has ended (medication has been removed) and is no longer taken.
		 *
		 * @param medicationScheduleItem
		 * @return
		 */
		private function getDoseChangeDate(medicationScheduleItem:MedicationScheduleItem):Date
		{
			var occurrences:Vector.<ScheduleItemOccurrence> = medicationScheduleItem.getScheduleItemOccurrences();
			if (occurrences.length > 0)
			{
				var firstOccurrence:ScheduleItemOccurrence = occurrences[0];
				var lastOccurrence:ScheduleItemOccurrence = occurrences[occurrences.length - 1];
				var firstOccurrenceDayStart:Date = DateUtil.roundTimeToPreviousDay(firstOccurrence.dateStart);
				var lastOccurrenceDayAfterEnd:Date = new Date(DateUtil.roundTimeToNextDay(lastOccurrence.dateEnd).valueOf() + DateUtil.MILLISECONDS_IN_DAY);

				// If the medication schedule has not ended, only consider the possibility that the start is a change
				var endIsChange:Boolean = getScheduleHasEnded(medicationScheduleItem);
				var startIsChange:Boolean = true;

				for each (var otherMedicationScheduleItem:MedicationScheduleItem in _medicationScheduleItemsCollection)
				{
					// TODO: consider the total dose (schedule dose * order strength) instead of just the dose
					if (otherMedicationScheduleItem != medicationScheduleItem &&
							otherMedicationScheduleItem.name.text == medicationScheduleItem.name.text &&
							CollaboRhythmValueAndUnit.areEqual(otherMedicationScheduleItem.dose, medicationScheduleItem.dose))
					{
						var otherOccurrences:Vector.<ScheduleItemOccurrence> = otherMedicationScheduleItem.getScheduleItemOccurrences();
						if (otherOccurrences.length > 0)
						{
							if (endIsChange)
							{
								var firstOtherOccurrence:ScheduleItemOccurrence = otherOccurrences[0];
								var deltaOtherAfter:Number = lastOccurrenceDayAfterEnd.valueOf() - firstOtherOccurrence.dateEnd.valueOf();
								if (deltaOtherAfter > 0 && deltaOtherAfter < DateUtil.MILLISECONDS_IN_DAY)
								{
									// found a schedule that starts with the same dose of the same medication on the day after the last occurrence of the specified medicationScheduleItem
									endIsChange = false;
								}
							}

							if (startIsChange)
							{
								var lastOtherOccurrence:ScheduleItemOccurrence = otherOccurrences[otherOccurrences.length -
										1];
								var deltaOtherBefore:Number = firstOccurrenceDayStart.valueOf() -
										lastOtherOccurrence.dateStart.valueOf();
								if (deltaOtherBefore > 0 && deltaOtherBefore < DateUtil.MILLISECONDS_IN_DAY)
								{
									// found a schedule that ends with the same dose of the same medication on the day before the first occurrence of the specified medicationScheduleItem
									startIsChange = false;
								}
							}
						}
					}
				}
				return endIsChange ? new Date(lastOccurrence.dateStart.valueOf() + DateUtil.MILLISECONDS_IN_DAY) :
						(startIsChange ? firstOccurrence.dateStart : null);
			}
			return null;
		}

		private function getScheduleHasEnded(medicationScheduleItem:MedicationScheduleItem):Boolean
		{
			var occurrences:Vector.<ScheduleItemOccurrence> = medicationScheduleItem.getScheduleItemOccurrences();
			if (occurrences.length > 0)
			{
				var lastOccurrence:ScheduleItemOccurrence = occurrences[occurrences.length - 1];
				var now:Date = _currentDateSource.now();

				// TODO: determine the next would-be occurrence more robustly than adding a day; we are currently assuming that the schedule is once daily
				return (now.valueOf() > lastOccurrence.dateEnd.valueOf() + DateUtil.MILLISECONDS_IN_DAY);
			}
			return true;
		}

		public function get medicationScheduleItemsCollection():ArrayCollection
		{
			return _medicationScheduleItemsCollection;
		}

		public function set medicationScheduleItemsCollection(value:ArrayCollection):void
		{
			_medicationScheduleItemsCollection = value;
		}

		public function get mostRecentDoseChangeMedication():MedicationScheduleItem
		{
			return _mostRecentDoseChangeMedication;
		}

		public function set mostRecentDoseChangeMedication(value:MedicationScheduleItem):void
		{
			_mostRecentDoseChangeMedication = value;
		}

		/**
		 * Calculates the difference in time from the most recent dose change to the next possible occurrence (future
		 * and not yet acted upon) of the most recently changed medication.
		 * @return The difference in time (milliseconds) from the most recent dose change to the next possible
		 * occurrence
		 */
		public function calculateTimeSinceChange():Number
		{
			var mostRecentDoseChange:Date = getMostRecentDoseChange();

			if (mostRecentDoseChange)
			{
				var dateOfNextOccurrence:Date = ScheduleDetailsResolver.getPossibleDateOfNextOccurrence(new <String>[_mostRecentDoseChangeMedication.name.value],
						_medicationScheduleItemsCollection, _currentDateSource.now());

				if (dateOfNextOccurrence)
				{
					return dateOfNextOccurrence.valueOf() - mostRecentDoseChange.valueOf();
				}
			}

			return NaN;
		}
	}
}
