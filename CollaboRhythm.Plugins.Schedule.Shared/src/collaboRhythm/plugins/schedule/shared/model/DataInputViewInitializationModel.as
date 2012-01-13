package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class DataInputViewInitializationModel
    {
        private var _scheduleItemOccurrence:ScheduleItemOccurrence;
        private var _urlVariables:URLVariables;
		private var _scheduleModel:IScheduleModel;
		private var _viewNavigator:ViewNavigator;

        public function DataInputViewInitializationModel(scheduleItemOccurrence:ScheduleItemOccurrence = null,
														 urlVariables:URLVariables = null,
														 scheduleModel:IScheduleModel = null,
														 viewNavigator:ViewNavigator = null)
        {
            _scheduleItemOccurrence = scheduleItemOccurrence;
            _urlVariables = urlVariables;
			_scheduleModel = scheduleModel;
			_viewNavigator = viewNavigator;
		}

        public function get scheduleItemOccurrence():ScheduleItemOccurrence
        {
            return _scheduleItemOccurrence;
        }

        public function get urlVariables():URLVariables
        {
            return _urlVariables;
        }

		public function get scheduleModel():IScheduleModel
		{
			return _scheduleModel;
		}

		public function set scheduleModel(value:IScheduleModel):void
		{
			_scheduleModel = value;
		}

		public function get viewNavigator():ViewNavigator
		{
			return _viewNavigator;
		}

		public function set viewNavigator(value:ViewNavigator):void
		{
			_viewNavigator = value;
		}
	}
}
