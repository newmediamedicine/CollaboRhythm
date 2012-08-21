package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.events.MouseEvent;

	public interface IHealthActionCreationController
	{
		function get buttonLabel():String;

		function showHealthActionCreationView(event:MouseEvent):void;

		function showHealthActionEditView(scheduleItemOccurrence:ScheduleItemOccurrence):void;
	}
}
