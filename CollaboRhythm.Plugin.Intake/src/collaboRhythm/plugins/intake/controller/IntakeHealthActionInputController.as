package collaboRhythm.plugins.intake.controller
{
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	public class IntakeHealthActionInputController extends HealthActionInputControllerBase
	{
		private var _dataInputModel:PainReportHealthActionInputModel;

		public function IntakeHealthActionInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
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
