package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	public interface IHealthActionInputModel
	{
		function get scheduleItemOccurrence():ScheduleItemOccurrence;
		function set scheduleItemOccurrence(value:ScheduleItemOccurrence):void;

		function set urlVariables(value:URLVariables):void;

		function get adherenceResultDate():Date;

		function get dateMeasuredStart():Date;

		function get healthActionModelDetailsProvider():IHealthActionModelDetailsProvider;

		function get isChangeTimeAllowed():Boolean;

		function get scheduleCollectionsProvider():IScheduleCollectionsProvider;

		function getPossibleScheduleItemOccurrences():Vector.<ScheduleItemOccurrence>;
	}
}
