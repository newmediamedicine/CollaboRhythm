package collaboRhythm.plugins.equipment.pillBox.controller
{
	import collaboRhythm.plugins.equipment.pillBox.model.PillBoxHealthActionInputModel;
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionInputControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.events.MouseEvent;
	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class PillBoxHealthActionInputController extends HealthActionInputControllerBase implements IHealthActionInputController
	{
		private const HEALTH_ACTION_INPUT_VIEW_CLASS:Class = PillBoxHealthActionInputController;

		private var _dataInputModel:PillBoxHealthActionInputModel;

		public function PillBoxHealthActionInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
														   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
														   viewNavigator:ViewNavigator)
		{
			_dataInputModel = new PillBoxHealthActionInputModel(scheduleItemOccurrence,
					healthActionModelDetailsProvider);
		}

		public function handleHealthActionResult(initiatedLocally:Boolean):void
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

		public function updateDateMeasuredStart(date:Date):void
		{
		}

		public function handleHealthActionCommandButtonClick(event:MouseEvent):void
		{
		}
	}
}
