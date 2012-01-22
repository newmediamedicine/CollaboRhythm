package collaboRhythm.plugins.intake.controller
{
	import collaboRhythm.plugins.intake.model.PainReportHealthActionInputModel;
	import collaboRhythm.plugins.intake.view.PainReportHealthActionInputView;
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionInputControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelAndController;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;
	import spark.transitions.SlideViewTransition;

	public class PainReportHealthActionInputController extends HealthActionInputControllerBase
	{
		private var _dataInputModel:PainReportHealthActionInputModel;

		public function PainReportHealthActionInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
															  scheduleModel:IScheduleModel, viewNavigator:ViewNavigator)
		{
			super(scheduleItemOccurrence, scheduleModel, viewNavigator);

			_dataInputModel = new PainReportHealthActionInputModel(scheduleItemOccurrence, scheduleModel);
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
			return PainReportHealthActionInputView;
		}

		override public function get isUnscheduleReporting():Boolean
		{
			return true;
		}
	}
}
