package collaboRhythm.plugins.foraD40b.controller
{
	import collaboRhythm.plugins.schedule.shared.controller.DataInputControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class BloodGlucoseDataInputController extends DataInputControllerBase
	{
		public function BloodGlucoseDataInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
														urlVariables:URLVariables, scheduleModel:IScheduleModel,
														viewNavigator:ViewNavigator)
		{
			super(scheduleItemOccurrence, urlVariables, scheduleModel, viewNavigator);
		}
	}
}
