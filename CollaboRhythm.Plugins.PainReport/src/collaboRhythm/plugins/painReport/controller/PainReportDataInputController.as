package collaboRhythm.plugins.painReport.controller
{
	import collaboRhythm.plugins.painReport.model.PainReportDataInputModel;
	import collaboRhythm.plugins.painReport.view.PainReportDataInputView;
	import collaboRhythm.plugins.schedule.shared.controller.DataInputControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class PainReportDataInputController extends DataInputControllerBase
	{
		private var _dataInputModel:PainReportDataInputModel;

		public function PainReportDataInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
													  urlVariables:URLVariables, scheduleModel:IScheduleModel,
													  viewNavigator:ViewNavigator)
		{
			super(scheduleItemOccurrence, urlVariables, scheduleModel, viewNavigator);

			_dataInputModel = new PainReportDataInputModel(scheduleItemOccurrence, urlVariables, scheduleModel);
		}

		override public function handleVariables():void
		{
			//abstract; subclasses should override
		}

		override public function updateVariables(urlVariables:URLVariables):void
		{
			//abstract; subclasses should override
		}

		override public function get dataInputViewClass():Class
		{
			return PainReportDataInputView;
		}

		override public function get isUnscheduleReporting():Boolean
		{
			return true;
		}
	}
}
