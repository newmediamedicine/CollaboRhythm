package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.events.MouseEvent;

	/**
	 * Health action creation controllers are used to create and edit health actions in the schedule time line view.
	 * @see IHealthActionCreationControllerFactory
	 */
	public interface IHealthActionCreationController
	{
		function get buttonLabel():String;

		function showHealthActionCreationView(event:MouseEvent):void;

		function showHealthActionEditView(scheduleItemOccurrence:ScheduleItemOccurrence):void;
	}
}
