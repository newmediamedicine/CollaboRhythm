package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.plugins.schedule.shared.model.ScheduleDetails;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleDetailsResolver;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.services.ICurrentDateSource;

	public class MedicationTitrationHelper
	{

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
		 * @param medicationCodes The medication(s) to match.
		 * @return The details of the schedule, including the ScheduleItemOccurrence and corresponding MedicationScheduleItem.
		 */
		public function getNextMedicationScheduleDetails(medicationCodes:Vector.<String>, todayOnly:Boolean = false):ScheduleDetails
		{
			var scheduleDetails:ScheduleDetails = ScheduleDetailsResolver.getCurrentScheduleDetails(medicationCodes, todayOnly,
					record.medicationScheduleItemsModel.medicationScheduleItemCollection, currentDateSource.now());
			_scheduleDetails = scheduleDetails;

			updateCurrentDoseValue();
			updatePreviousDoseValue();
			newDose = currentDoseValue;
			updateDosageChangeValue();

			return scheduleDetails;
		}

		public function updateCurrentDoseValue():void
		{
			currentDoseValue = (_scheduleDetails && _scheduleDetails.currentSchedule && (_scheduleDetails.currentSchedule as MedicationScheduleItem).dose) ? Number((_scheduleDetails.currentSchedule as MedicationScheduleItem).dose.value) : NaN;
		}

		public function updatePreviousDoseValue():void
		{
			var previousMedicationScheduleItem:MedicationScheduleItem = _scheduleDetails.previousSchedule as MedicationScheduleItem;
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
