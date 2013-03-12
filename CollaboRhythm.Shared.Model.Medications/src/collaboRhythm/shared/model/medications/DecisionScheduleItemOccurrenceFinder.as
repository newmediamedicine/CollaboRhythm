package collaboRhythm.shared.model.medications
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.services.DateUtil;
	import collaboRhythm.shared.model.StringUtils;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import mx.collections.ArrayCollection;

	public class DecisionScheduleItemOccurrenceFinder
	{
		private var _healthActionModelDetailsProvider:IHealthActionModelDetailsProvider;
		private var _scheduleItemName:String;

		public function DecisionScheduleItemOccurrenceFinder(healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
															 scheduleItemName:String)
		{
			_healthActionModelDetailsProvider = healthActionModelDetailsProvider;
			_scheduleItemName = scheduleItemName;
		}

		public function getDecisionScheduleItemOccurrence():ScheduleItemOccurrence
		{
			var decisionScheduleItemOccurrence:ScheduleItemOccurrence;
			var scheduleItemCollection:ArrayCollection = _healthActionModelDetailsProvider.record.healthActionSchedulesModel.healthActionScheduleCollection;
			var now:Date = _healthActionModelDetailsProvider.currentDateSource.now();
			var endOfToday:Number = DateUtil.roundTimeToNextDay(now).valueOf();
			for each (var scheduleItem:ScheduleItemBase in scheduleItemCollection)
			{
				if (scheduleItemMatches(scheduleItem, _scheduleItemName))
				{
					var scheduleItemOccurrences:Vector.<ScheduleItemOccurrence> =
							scheduleItem.getScheduleItemOccurrences(new Date(endOfToday -
									ScheduleItemBase.MILLISECONDS_IN_DAY), new Date(endOfToday));
					if (scheduleItemOccurrences && scheduleItemOccurrences.length > 0)
					{
						decisionScheduleItemOccurrence = scheduleItemOccurrences[0];
						break;
					}
				}
			}
			return decisionScheduleItemOccurrence;
		}

		private function scheduleItemMatches(scheduleItem:ScheduleItemBase, scheduleItemName:String):Boolean
		{
			if (StringUtils.isEmpty(scheduleItem.name.value))
			{
				return scheduleItem.name.text == scheduleItemName;
			}
			else
			{
				return scheduleItem.name.value == scheduleItemName;
			}
		}
	}
}
