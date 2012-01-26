package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	public interface IHealthActionInputModel
	{
		function get scheduleItemOccurrence():ScheduleItemOccurrence;
		function set urlVariables(value:URLVariables):void;
	}
}
