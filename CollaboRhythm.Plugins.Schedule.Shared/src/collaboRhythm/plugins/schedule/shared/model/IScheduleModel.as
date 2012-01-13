package collaboRhythm.plugins.schedule.shared.model
{

	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public interface IScheduleModel
	{
		function voidAdherenceItem(scheduleItemOccurrence:ScheduleItemOccurrence):void;

		function get accountId():String;

		function createAdherenceItem(scheduleItemOccurrence:ScheduleItemOccurrence):void;

		function createResults(results:Vector.<DocumentBase>):void;
	}
}
