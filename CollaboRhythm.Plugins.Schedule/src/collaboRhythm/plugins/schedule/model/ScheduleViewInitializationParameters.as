package collaboRhythm.plugins.schedule.model
{
	import collaboRhythm.plugins.schedule.controller.ScheduleAppController;

	public class ScheduleViewInitializationParameters
	{
		private var _scheduleModel:ScheduleModel;
		private var _scheduleAppController:ScheduleAppController;

		public function ScheduleViewInitializationParameters(sheduleAppController:ScheduleAppController, scheduleModel:ScheduleModel)
		{
			_scheduleAppController = sheduleAppController;
			_scheduleModel = scheduleModel;
		}

		public function get scheduleModel():ScheduleModel
		{
			return _scheduleModel;
		}

		public function set scheduleModel(value:ScheduleModel):void
		{
			_scheduleModel = value;
		}

		public function get scheduleAppController():ScheduleAppController
		{
			return _scheduleAppController;
		}

		public function set scheduleAppController(value:ScheduleAppController):void
		{
			_scheduleAppController = value;
		}
	}
}
