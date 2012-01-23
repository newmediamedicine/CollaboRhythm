package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public interface IHealthActionListViewModel
	{
		function createHealthActionResult():void;
		function voidHealthActionResult():void;
		function get scheduleItemOccurrence():ScheduleItemOccurrence;
		function get healthActionInputController():IHealthActionInputController;
		function set healthActionInputController(healthActionInputController:IHealthActionInputController):void;
	}
}
