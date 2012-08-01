package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.ui.healthCharts.view.SynchronizedHealthCharts;

	public class MedicationTitrationHelper
	{
		/**
		 * Number of milliseconds after the end of a schedule occurrence for which the item/action is to be still considered
		 * "current" or "next" even though it is in the past (has been missed). This a non-negative value would allow the
		 * schedule to be changed for a dose of medication (for example) after the medication was due to be taken.
		 */
		private static const NEXT_OCCURRENCE_DELTA:Number = 0;
		private static const ALLOW_CHANGE_LATE_OCCURRENCE:Boolean = true;

		private var _record:Record;
		private var _currentDateSource:ICurrentDateSource;
		private var _scheduleDetails:ScheduleDetails;
		private var _currentDoseValue:Number;
		private var _previousDoseValue:Number;
		private var _dosageChangeValue:Number;
		private var _newDose:Number;

		public function MedicationTitrationHelper(record:Record, currentDateSource:ICurrentDateSource)
		{
			_record = record;
			_currentDateSource = currentDateSource;
		}

		public function get record():Record
		{
			return _record;
		}

		public function set record(value:Record):void
		{
			_record = value;
		}

		public function get currentDateSource():ICurrentDateSource
		{
			return _currentDateSource;
		}

		public function set currentDateSource(value:ICurrentDateSource):void
		{
			_currentDateSource = value;
		}

		/**
		 * Finds the next ScheduleItemOccurrence and corresponding MedicationScheduleItem for the specified medication
		 * where the medication has not yet been administered and the occurrence is current (adherence window overlaps
		 * the current time) or future (occurrence starts after the current time).
		 * @param medicationCode The medication to match.
		 * @return The details of the schedule, including the ScheduleItemOccurrence and corresponding MedicationScheduleItem.
		 */
		public function getNextMedicationScheduleDetails(medicationCode:String, todayOnly:Boolean = false):ScheduleDetails
		{
			var scheduleDetails:ScheduleDetails;
			var now:Date = currentDateSource.now();
			for each (var medicationScheduleItem:MedicationScheduleItem in record.medicationScheduleItemsModel.medicationScheduleItemCollection)
			{
				if (medicationScheduleItem.name.value == medicationCode)
				{
					var currentPeriodDateStart:Date;
					var currentPeriodDateEnd:Date;
					if (todayOnly)
					{
						currentPeriodDateEnd = SynchronizedHealthCharts.roundTimeToNextDay(now);
						currentPeriodDateStart = new Date(currentPeriodDateEnd.valueOf() - ScheduleItemBase.MILLISECONDS_IN_DAY);
					}
					else
					{
						// TODO: exactly what span of time should we use to look for the "next" scheduled item? Currently we are using 24 hours before to 48 hours after the current time (a 3 day window)
						currentPeriodDateStart = new Date(now.valueOf() - ScheduleItemBase.MILLISECONDS_IN_DAY);
						currentPeriodDateEnd = new Date(now.valueOf() + 2 * ScheduleItemBase.MILLISECONDS_IN_DAY);
					}

					var scheduleItemOccurrences:Vector.<ScheduleItemOccurrence> = medicationScheduleItem.getScheduleItemOccurrences(
							currentPeriodDateStart, currentPeriodDateEnd);
					for each (var scheduleItemOccurrence:ScheduleItemOccurrence in scheduleItemOccurrences)
					{
						if (todayOnly)
						{
							scheduleDetails = new ScheduleDetails(medicationScheduleItem, scheduleItemOccurrence);
							break;
						}
						else {
							var currentScheduleCutoff:Number = ALLOW_CHANGE_LATE_OCCURRENCE ? SynchronizedHealthCharts.roundTimeToNextDay(now).valueOf() - ScheduleItemBase.MILLISECONDS_IN_DAY : (now.valueOf() - NEXT_OCCURRENCE_DELTA);
							if ((scheduleItemOccurrence.adherenceItem == null || scheduleItemOccurrence.adherenceItem.adherence == false) &&
															scheduleItemOccurrence.dateEnd.valueOf() >= currentScheduleCutoff)
													{
														scheduleDetails = new ScheduleDetails(medicationScheduleItem, scheduleItemOccurrence);
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
				for each (medicationScheduleItem in
						record.medicationScheduleItemsModel.medicationScheduleItemCollection)
				{
					if (medicationScheduleItem.name.value == medicationCode)
					{
						// TODO: find a more robust way of determining the previousSchedule; currently we look for the first occurrence in the 24 hours prior to the current occurrence
						// For dateEnd, subtract 1 millisecond because dateEnd is inclusive, and we want to exclude occurrences that start at occurrence.dateStart
						scheduleItemOccurrences = medicationScheduleItem.getScheduleItemOccurrences(
								new Date(scheduleDetails.occurrence.dateStart.valueOf() -
										ScheduleItemBase.MILLISECONDS_IN_DAY),
								new Date(scheduleDetails.occurrence.dateStart.valueOf() - 1));
						if (scheduleItemOccurrences.length > 0)
						{
							scheduleDetails.previousSchedule = medicationScheduleItem;
							break;
						}
					}
				}
			}
			else
			{
				scheduleDetails = new ScheduleDetails(null, null);
			}

			_scheduleDetails = scheduleDetails;

			updateCurrentDoseValue();
			updatePreviousDoseValue();
			newDose = currentDoseValue;
			updateDosageChangeValue();

			return scheduleDetails;
		}

		public function updateCurrentDoseValue():void
		{
			currentDoseValue = (_scheduleDetails && _scheduleDetails.currentSchedule && _scheduleDetails.currentSchedule.dose) ? Number(_scheduleDetails.currentSchedule.dose.value) : NaN;
		}

		public function updatePreviousDoseValue():void
		{
			var previousMedicationScheduleItem:MedicationScheduleItem = _scheduleDetails.previousSchedule;
			previousDoseValue = previousMedicationScheduleItem ? (previousMedicationScheduleItem.dose ? Number(previousMedicationScheduleItem.dose.value) : NaN) : NaN;
		}

		public function updateDosageChangeValue():void
		{
			if ((!isNaN(currentDoseValue) && !isNaN(previousDoseValue)) && (newDose != previousDoseValue))
				dosageChangeValue = newDose - previousDoseValue;
			else
				dosageChangeValue = 0;
		}

		public function get previousDoseValue():Number
		{
			return _previousDoseValue;
		}

		public function set previousDoseValue(value:Number):void
		{
			_previousDoseValue = value;
		}

		public function get currentDoseValue():Number
		{
			return _currentDoseValue;
		}

		public function set currentDoseValue(value:Number):void
		{
			_currentDoseValue = value;
		}

		public function get dosageChangeValue():Number
		{
			return _dosageChangeValue;
		}

		public function set dosageChangeValue(value:Number):void
		{
			_dosageChangeValue = value;
		}

		public function get newDose():Number
		{
			return _newDose;
		}

		public function set newDose(value:Number):void
		{
			_newDose = value;
		}

		public function get dosageChangeValueLabel():String
		{
			return (isNaN(_dosageChangeValue) || _dosageChangeValue == 0) ? "No Change" : (_dosageChangeValue > 0 ? "+" : "") + _dosageChangeValue.toString();
		}
	}
}
