package collaboRhythm.plugins.bathroom.controller
{
	import collaboRhythm.plugins.bathroom.model.BathroomHealthActionInputModel;
	import collaboRhythm.plugins.bathroom.view.BathroomHealthActionInputView;
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionInputControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelAndController;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;
	import spark.transitions.SlideViewTransition;

	public class BathroomHealthActionInputController extends HealthActionInputControllerBase
	{
		private var _dataInputModel:BathroomHealthActionInputModel;

		public function BathroomHealthActionInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
															  scheduleModel:IScheduleModel, viewNavigator:ViewNavigator)
		{
			super(scheduleItemOccurrence, scheduleModel, viewNavigator);

			_dataInputModel = new BathroomHealthActionInputModel(scheduleItemOccurrence, scheduleModel);
		}

		override public function showHealthActionInputView():void
		{
			var dataInputModelAndController:HealthActionInputModelAndController = new HealthActionInputModelAndController(_dataInputModel,
					this);

			_viewNavigator.pushView(healthActionInputViewClass, dataInputModelAndController, null,
					new SlideViewTransition());
		}

		override public function updateVariables(urlVariables:URLVariables):void
		{
			//abstract; subclasses should override
		}

		override public function get healthActionInputViewClass():Class
		{
			return BathroomHealthActionInputView;
		}

		override public function get isUnscheduleReporting():Boolean
		{
			return true;
		}
	}
}
