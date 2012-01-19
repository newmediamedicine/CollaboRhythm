package collaboRhythm.plugins.foraD40b.controller
{
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionInputControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import spark.components.ViewNavigator;

	public class BloodGlucoseDataInputController extends HealthActionInputControllerBase
	{
		public function BloodGlucoseDataInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
														scheduleModel:IScheduleModel,
														viewNavigator:ViewNavigator)
		{
			super(scheduleItemOccurrence, scheduleModel, viewNavigator);
		}
	}
}
