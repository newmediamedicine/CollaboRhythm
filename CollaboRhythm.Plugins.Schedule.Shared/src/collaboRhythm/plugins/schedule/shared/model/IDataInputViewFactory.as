package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.plugins.schedule.shared.controller.DataInputControllerBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public interface IDataInputViewFactory
    {
        function isMatchingDataInputViewFactory(name:String):Boolean;
        function createDataInputView(name:String, measurements:String,
									 scheduleItemOccurrence:ScheduleItemOccurrence):Class;
		function createDataInputController(name:String, measurements:String,
										   scheduleItemOccurrence:ScheduleItemOccurrence,
										   urlVariables:URLVariables,
										   scheduleModel:IScheduleModel,
										   viewNavigator:ViewNavigator):DataInputControllerBase;
    }
}
