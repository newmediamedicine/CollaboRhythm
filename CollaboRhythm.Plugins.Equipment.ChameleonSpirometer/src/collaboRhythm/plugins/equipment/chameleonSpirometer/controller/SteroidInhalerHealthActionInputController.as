package collaboRhythm.plugins.equipment.chameleonSpirometer.controller
{
	import collaboRhythm.plugins.equipment.chameleonSpirometer.model.SteroidInhalerHealthActionInputModel;
	import collaboRhythm.plugins.equipment.chameleonSpirometer.view.SteroidInhalerHealthActionInputView;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class SteroidInhalerHealthActionInputController implements IHealthActionInputController
	{
		private const HEALTH_ACTION_INPUT_VIEW_CLASS:Class = SteroidInhalerHealthActionInputView;

		private var _dataInputModel:SteroidInhalerHealthActionInputModel;

		public function SteroidInhalerHealthActionInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
																  healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																  viewNavigator:ViewNavigator)
		{
			_dataInputModel = new SteroidInhalerHealthActionInputModel(scheduleItemOccurrence,
					healthActionModelDetailsProvider);
		}

		public function handleHealthActionResult():void
		{

		}

		public function handleHealthActionSelected():void
		{
		}

		public function handleUrlVariables(urlVariables:URLVariables):void
		{
			_dataInputModel.urlVariables = urlVariables;
		}

		public function get healthActionInputViewClass():Class
		{
			return HEALTH_ACTION_INPUT_VIEW_CLASS;
		}
	}
}