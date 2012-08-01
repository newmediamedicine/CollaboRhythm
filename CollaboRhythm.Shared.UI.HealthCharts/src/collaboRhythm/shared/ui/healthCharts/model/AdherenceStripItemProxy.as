package collaboRhythm.shared.ui.healthCharts.model
{
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministration;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.ICurrentDateSource;

	public class AdherenceStripItemProxy
	{
		private var _scheduleItemOccurrence:ScheduleItemOccurrence;
		private var _adherenceItem:AdherenceItem;
		private var _currentDateSource:ICurrentDateSource;
		private var _proxyType:String;
		public static const MEDICATION_TYPE:String = "Medication";
		public static const EQUIPMENT_TYPE:String = "Equipment";
		private var _date:Date;
		private var _color:uint;

		public function AdherenceStripItemProxy(currentDateSource:ICurrentDateSource,
												proxyType:String,
												scheduleItemOccurrence:ScheduleItemOccurrence,
												adherenceItem:AdherenceItem,
												color:uint)
		{
			_currentDateSource = currentDateSource;
			_proxyType = proxyType;
			_scheduleItemOccurrence = scheduleItemOccurrence;
			_color = color;
			if (scheduleItemOccurrence && scheduleItemOccurrence.adherenceItem)
				_adherenceItem = scheduleItemOccurrence.adherenceItem;
			if (adherenceItem)
				_adherenceItem = adherenceItem;
			_date = calculateDate();
		}

		public function get scheduleItemOccurrence():ScheduleItemOccurrence
		{
			return _scheduleItemOccurrence;
		}

		public function get date():Date
		{
			return _date;
		}

		private function calculateDate():Date
		{
			if (adherenceItem)
			{
				return adherenceItem.dateReported;
			}
			else if (scheduleItemOccurrence)
			{
				return new Date(scheduleItemOccurrence.dateStart.valueOf() +
						(scheduleItemOccurrence.dateEnd.valueOf() - scheduleItemOccurrence.dateStart.valueOf()) /
								2);
			}
			else
			{
				return null;
			}
		}

		public function get yPosition():Number
		{
			return 0;
		}

		public function get adherenceItem():AdherenceItem
		{
			return _adherenceItem;
		}

		public function get isEndBeforeCurrentDate():Boolean
		{
			return date && date.valueOf() < _currentDateSource.now().valueOf();
		}

		public function get dataTip():String
		{
			var scheduleItemOccurrence:ScheduleItemOccurrence = scheduleItemOccurrence;
			var adherenceItem:AdherenceItem = adherenceItem;
			if (adherenceItem)
			{
				var dateReportedMessage:String = adherenceItem.dateReported ? ("<br/>" +
						"Date reported: " + adherenceItem.dateReported.toLocaleString()) : "";

				if (_proxyType == MEDICATION_TYPE)
				{
					var adherenceResultMessage:String = "";
					var medicationAdministration:MedicationAdministration = adherenceItem.adherenceResults.length > 0 ? adherenceItem.adherenceResults[0] as MedicationAdministration : null;
					if (medicationAdministration && medicationAdministration.amountAdministered)
						adherenceResultMessage = " " + medicationAdministration.amountAdministered.value + " " + medicationAdministration.amountAdministered.unit.text;
					return "Medication " + (adherenceItem.adherence ? "<b>Taken</b>" : "<b>Not</b> Taken") + adherenceResultMessage +
							dateReportedMessage;
				}
				else if (_proxyType == EQUIPMENT_TYPE)
				{
					return "Equipment " + (adherenceItem.adherence ? "<b>Used</b>" : "<b>Not</b> Used") +
							dateReportedMessage;
				}
				else return "Unsupported proxy type " + _proxyType;
			}
			else
			{
				var notReportedPhrase:String = scheduleItemOccurrence.isPast ? "was not reported" : "has not been reported yet";

				if (_proxyType == MEDICATION_TYPE)
				{
					var medicationScheduleItem:MedicationScheduleItem = scheduleItemOccurrence.scheduleItem as MedicationScheduleItem;
					return "Medication " + notReportedPhrase + " " + medicationScheduleItem.dose.value + " " + medicationScheduleItem.dose.unit.text + ".<br/>" +
											"Date scheduled: " + scheduleItemOccurrence.dateStart.toLocaleString() + " to " +
											scheduleItemOccurrence.dateEnd.toLocaleString();
				}

				// TODO: describe the type of health action instead of the particular name of the item
				return scheduleItemOccurrence.scheduleItem.name.text + " " + notReportedPhrase + ".<br/>" +
						"Date scheduled: " + scheduleItemOccurrence.dateStart.toLocaleString() + " to " +
						scheduleItemOccurrence.dateEnd.toLocaleString();
			}
		}

		public function get color():uint
		{
			return _color;
		}

		public function set color(value:uint):void
		{
			_color = value;
		}
	}
}
