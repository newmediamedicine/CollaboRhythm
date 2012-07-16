package collaboRhythm.plugins.equipment.insulinPen.controller
{
	import collaboRhythm.plugins.equipment.insulinPen.model.InsulinPenHealthActionInputModel;
	import collaboRhythm.plugins.equipment.insulinPen.view.InsulinPenHealthActionInputView;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class InsulinPenHealthActionInputController implements IHealthActionInputController
	{
		private const HEALTH_ACTION_INPUT_VIEW_CLASS:Class = InsulinPenHealthActionInputView;

		private var _dataInputModel:InsulinPenHealthActionInputModel;

		public function InsulinPenHealthActionInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
														   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
														   viewNavigator:ViewNavigator)
		{
			_dataInputModel = new InsulinPenHealthActionInputModel(scheduleItemOccurrence,
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
