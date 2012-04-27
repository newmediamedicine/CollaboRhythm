package collaboRhythm.shared.ui.healthCharts.model
{
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
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

		public function AdherenceStripItemProxy(currentDateSource:ICurrentDateSource, proxyType:String,
												scheduleItemOccurrence:ScheduleItemOccurrence,
												adherenceItem:AdherenceItem)
		{
			_currentDateSource = currentDateSource;
			_proxyType = proxyType;
			_scheduleItemOccurrence = scheduleItemOccurrence;
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
					return "Medication " + (adherenceItem.adherence ? "<b>Taken</b>" : "<b>Not</b> Taken") +
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
				return scheduleItemOccurrence.scheduleItem.name.text + " was not reported.<br/>" +
						"Date scheduled: " + scheduleItemOccurrence.dateStart.toLocaleString() + " to " +
						scheduleItemOccurrence.dateEnd.toLocaleString();
			}
		}
	}
}
