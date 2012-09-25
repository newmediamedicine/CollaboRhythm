package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.StringUtils;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.ui.healthCharts.view.SynchronizedHealthCharts;

	import mx.collections.ArrayCollection;

	public class DecisionScheduleItemOccurrenceFinder
	{
		private var _healthActionModelDetailsProvider:IHealthActionModelDetailsProvider;

		public function DecisionScheduleItemOccurrenceFinder(healthActionModelDetailsProvider:IHealthActionModelDetailsProvider)
		{
			_healthActionModelDetailsProvider = healthActionModelDetailsProvider;
		}

		public function getDecisionScheduleItemOccurrence():ScheduleItemOccurrence
		{
			var decisionScheduleItemOccurrence:ScheduleItemOccurrence;
			var scheduleItemCollection:ArrayCollection = _healthActionModelDetailsProvider.record.healthActionSchedulesModel.healthActionScheduleCollection;
			var now:Date = _healthActionModelDetailsProvider.currentDateSource.now();
			var endOfToday:Number = SynchronizedHealthCharts.roundTimeToNextDay(now).valueOf();
			for each (var scheduleItem:ScheduleItemBase in scheduleItemCollection)
			{
				if (scheduleItemMatches(scheduleItem, TitratingInsulinHealthActionListViewAdapter.INSULIN_TITRATION_DECISION_HEALTH_ACTION_SCHEDULE_NAME))
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
