package collaboRhythm.plugins.schedule.shared.controller
{
	import collaboRhythm.plugins.schedule.shared.model.ScheduleItemOccurrenceReportingModelBase;

	import spark.components.ViewNavigator;

	public class ScheduleItemOccurrenceReportingController
	{
		private var _scheduleItemOccurrenceReportingModel:ScheduleItemOccurrenceReportingModelBase;
		private var _viewNavigator:ViewNavigator;

		public function ScheduleItemOccurrenceReportingController(scheduleItemOccurrenceReportingModel:ScheduleItemOccurrenceReportingModelBase,
																  viewNavigator:ViewNavigator)
		{
			_scheduleItemOccurrenceReportingModel = scheduleItemOccurrenceReportingModel;
			_viewNavigator = viewNavigator;
		}

		public function updateAdherence():void
		{
			if (_scheduleItemOccurrenceReportingModel.scheduleItemOccurrence && _scheduleItemOccurrenceReportingModel.scheduleItemOccurrence.adherenceItem)
			{
				_scheduleItemOccurrenceReportingModel.voidAdherenceItem();
			}
			else
			{
				if (_scheduleItemOccurrenceReportingModel.healthActionInputController)
				{
					_scheduleItemOccurrenceReportingModel.healthActionInputController.showHealthActionInputView();
				}
				else
				{
					_scheduleItemOccurrenceReportingModel.createAdherenceItem();
				}
			}
		}
	}
}
