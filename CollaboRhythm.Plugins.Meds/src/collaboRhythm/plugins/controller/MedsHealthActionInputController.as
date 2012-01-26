package collaboRhythm.plugins.controller
{
	import collaboRhythm.plugins.model.MedsHealthActionInputModel;
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionInputControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelAndController;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.plugins.view.MedsHealthActionInputView;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import spark.components.ViewNavigator;
	import spark.transitions.SlideViewTransition;
	import flash.net.URLVariables;

	public class MedsHealthActionInputController extends HealthActionInputControllerBase
	{
		private var _dataInputModel:MedsHealthActionInputModel;

		public function MedsHealthActionInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
															  scheduleModel:IScheduleModel, viewNavigator:ViewNavigator)
		{
			super(scheduleItemOccurrence, scheduleModel, viewNavigator);

			_dataInputModel = new MedsHealthActionInputModel(scheduleItemOccurrence, scheduleModel);
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
			return MedsHealthActionInputView;
		}

		override public function get isUnscheduleReporting():Boolean
		{
			return true;
		}
	}
}
