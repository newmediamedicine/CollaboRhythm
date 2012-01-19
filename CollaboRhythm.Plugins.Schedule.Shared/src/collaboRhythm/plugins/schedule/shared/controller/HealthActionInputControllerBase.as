package collaboRhythm.plugins.schedule.shared.controller
{
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class HealthActionInputControllerBase
    {
		protected var _viewNavigator:ViewNavigator;

        public function HealthActionInputControllerBase(scheduleItemOccurrence:ScheduleItemOccurrence,
														scheduleModel:IScheduleModel,
														viewNavigator:ViewNavigator)
        {
			_viewNavigator = viewNavigator;
		}

		public function showHealthActionInputView():void
		{
			//abstract; subclasses should override
		}

		public function updateVariables(urlVariables:URLVariables):void
		{
			//abstract; subclasses should override
		}

		public function get healthActionInputViewClass():Class
		{
			//abstract; subclasses should override
			return null;
		}

		public function get isUnscheduleReporting():Boolean
		{
			//abstract; subclasses should override
			return false;
		}
	}
}
