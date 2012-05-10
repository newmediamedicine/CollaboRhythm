package collaboRhythm.plugins.foraD40b.controller
{
	import collaboRhythm.plugins.foraD40b.model.BloodPressureHealthActionInputModel;
	import collaboRhythm.plugins.foraD40b.view.BloodPressureHealthActionInputView;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelAndController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;
	import spark.transitions.SlideViewTransition;

	public class BloodPressureHealthActionInputController implements IHealthActionInputController
	{
		private const HEALTH_ACTION_INPUT_VIEW_CLASS:Class = BloodPressureHealthActionInputView;

		private var _dataInputModel:BloodPressureHealthActionInputModel;
		private var _viewNavigator:ViewNavigator;

		public function BloodPressureHealthActionInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
														 healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
														 viewNavigator:ViewNavigator)
		{
			_dataInputModel = new BloodPressureHealthActionInputModel(scheduleItemOccurrence, healthActionModelDetailsProvider);
			_viewNavigator = viewNavigator;
		}

		public function handleHealthActionResult():void
		{
			var healthActionInputModelAndController:HealthActionInputModelAndController = new HealthActionInputModelAndController(_dataInputModel,
					this);

			_viewNavigator.pushView(HEALTH_ACTION_INPUT_VIEW_CLASS, healthActionInputModelAndController, null,
					new SlideViewTransition());
		}

		public function handleUrlVariables(urlVariables:URLVariables):void
		{
			_dataInputModel.urlVariables = urlVariables;
		}

		public function submitBloodPressure(position:String, site:String):void
		{
			_dataInputModel.submitBloodPressure(position, site);
			_viewNavigator.popView();
		}

		public function get healthActionInputViewClass():Class
		{
			return HEALTH_ACTION_INPUT_VIEW_CLASS;
		}
	}
}
