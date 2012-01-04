package collaboRhythm.plugins.schedule.shared.model
{

	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public interface IScheduleModel
	{
		function voidAdherenceItem(scheduleItemOccurrence:ScheduleItemOccurrence):void;

		function get accountId():String;

		function createAdherenceItem(scheduleItemOccurrence:ScheduleItemOccurrence, adherenceItem:AdherenceItem):void;
	}
}
