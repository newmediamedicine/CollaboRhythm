package collaboRhythm.plugins.bathroom.controller
{
	import collaboRhythm.plugins.bathroom.model.BathroomHealthActionInputModel;
	import collaboRhythm.plugins.bathroom.view.BathroomHealthActionInputView;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelAndController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;
	import spark.transitions.SlideViewTransition;

	public class BathroomHealthActionInputController implements IHealthActionInputController
	{
		private const HEALTH_ACTION_INPUT_VIEW_CLASS:Class = BathroomHealthActionInputView;

		private var _dataInputModel:BathroomHealthActionInputModel;
		private var _viewNavigator:ViewNavigator;

		public function BathroomHealthActionInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
															  healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
															  viewNavigator:ViewNavigator)
		{
			_dataInputModel = new BathroomHealthActionInputModel(scheduleItemOccurrence,
					healthActionModelDetailsProvider);
			_viewNavigator = viewNavigator;
		}

		public function showHealthActionInputView():void
		{
			var dataInputModelAndController:HealthActionInputModelAndController = new HealthActionInputModelAndController(_dataInputModel,
					this);

			_viewNavigator.pushView(HEALTH_ACTION_INPUT_VIEW_CLASS, dataInputModelAndController, null,
					new SlideViewTransition());
		}

		public function updateVariables(urlVariables:URLVariables):void
		{

		}

		public function get healthActionInputViewClass():Class
		{
			return HEALTH_ACTION_INPUT_VIEW_CLASS;
		}
	}
}
