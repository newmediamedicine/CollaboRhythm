package collaboRhythm.plugins.foraD40b.controller
{
	import collaboRhythm.plugins.foraD40b.model.BloodPressureDataInputModel;
	import collaboRhythm.plugins.foraD40b.view.BloodPressureDataInputView;
	import collaboRhythm.plugins.schedule.shared.controller.DataInputControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.DataInputModelAndController;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;
	import spark.transitions.SlideViewTransition;

	public class BloodPressureDataInputController extends DataInputControllerBase
	{
		private var _dataInputModel:BloodPressureDataInputModel;

		public function BloodPressureDataInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
														 urlVariables:URLVariables, scheduleModel:IScheduleModel,
														 viewNavigator:ViewNavigator)
		{
			super(scheduleItemOccurrence, urlVariables, scheduleModel, viewNavigator);

			_dataInputModel = new BloodPressureDataInputModel(scheduleItemOccurrence, urlVariables, scheduleModel);
		}

		override public function handleVariables():void
		{
			var dataInputModelAndController:DataInputModelAndController = new DataInputModelAndController(_dataInputModel,
					this);

			_viewNavigator.pushView(BloodPressureDataInputView, dataInputModelAndController, null,
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
	}
}
