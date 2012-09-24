package collaboRhythm.plugins.equipment.chameleonSpirometer.controller
{
	import collaboRhythm.plugins.equipment.chameleonSpirometer.model.SpirometerHealthActionInputModel;
	import collaboRhythm.plugins.equipment.chameleonSpirometer.view.SpirometerHealthActionInputView;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class SpirometerHealthActionInputController implements IHealthActionInputController
	{
		private const HEALTH_ACTION_INPUT_VIEW_CLASS:Class = SpirometerHealthActionInputView;

		private var _dataInputModel:SpirometerHealthActionInputModel;

		public function SpirometerHealthActionInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
															  healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
															  viewNavigator:ViewNavigator)
		{
			_dataInputModel = new SpirometerHealthActionInputModel(scheduleItemOccurrence,
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

		public function useDefaultHandleHealthActionResult():Boolean
		{
			return false;
		}
	}
}