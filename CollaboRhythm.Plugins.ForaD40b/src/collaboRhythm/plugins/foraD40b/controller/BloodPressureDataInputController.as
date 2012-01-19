package collaboRhythm.plugins.foraD40b.controller
{
	import collaboRhythm.plugins.foraD40b.model.BloodPressureDataInputModel;
	import collaboRhythm.plugins.foraD40b.view.BloodPressureDataInputView;
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionInputControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelAndController;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;
	import spark.transitions.SlideViewTransition;

	public class BloodPressureDataInputController extends HealthActionInputControllerBase
	{
		private var _dataInputModel:BloodPressureDataInputModel;

		public function BloodPressureDataInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
														 scheduleModel:IScheduleModel,
														 viewNavigator:ViewNavigator)
		{
			super(scheduleItemOccurrence, scheduleModel, viewNavigator);

			_dataInputModel = new BloodPressureDataInputModel(scheduleItemOccurrence, scheduleModel);
		}

		override public function showHealthActionInputView():void
		{
			var dataInputModelAndController:HealthActionInputModelAndController = new HealthActionInputModelAndController(_dataInputModel,
					this);

			_viewNavigator.pushView(healthActionInputViewClass, dataInputModelAndController, null,
					new SlideViewTransition());
		}

		public function submitBloodPressure(position:String, site:String):void
		{
			_dataInputModel.submitBloodPressure(position, site);
			_viewNavigator.popView();
		}

		override public function updateVariables(urlVariables:URLVariables):void
		{
			_dataInputModel.urlVariables = urlVariables;
		}

		override public function get healthActionInputViewClass():Class
		{
			return BloodPressureDataInputView;
		}
	}
}
