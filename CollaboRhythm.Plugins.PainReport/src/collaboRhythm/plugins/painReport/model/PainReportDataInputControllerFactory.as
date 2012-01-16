package collaboRhythm.plugins.painReport.model
{
	import collaboRhythm.plugins.painReport.controller.PainReportDataInputController;
	import collaboRhythm.plugins.schedule.shared.controller.DataInputControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.IDataInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class PainReportDataInputControllerFactory implements IDataInputControllerFactory
	{
		public function PainReportDataInputControllerFactory()
		{
		}

		public function isMatchingDataInputControllerFactory(name:String):Boolean
		{
			return false;
		}

		public function createDataInputController(name:String, measurements:String,
												  scheduleItemOccurrence:ScheduleItemOccurrence,
												  urlVariables:URLVariables, scheduleModel:IScheduleModel,
												  viewNavigator:ViewNavigator):DataInputControllerBase
		{
			return new PainReportDataInputController(scheduleItemOccurrence, urlVariables, scheduleModel, viewNavigator);
		}
	}
}
