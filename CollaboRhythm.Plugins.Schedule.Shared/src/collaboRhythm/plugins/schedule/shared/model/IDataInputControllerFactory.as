package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.plugins.schedule.shared.controller.DataInputControllerBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public interface IDataInputControllerFactory
    {
        function isMatchingDataInputControllerFactory(name:String):Boolean;
		function createHealthActionInputController(name:String, measurements:String,
										   scheduleItemOccurrence:ScheduleItemOccurrence,
										   urlVariables:URLVariables,
										   scheduleModel:IScheduleModel,
										   viewNavigator:ViewNavigator):DataInputControllerBase;
    }
}
