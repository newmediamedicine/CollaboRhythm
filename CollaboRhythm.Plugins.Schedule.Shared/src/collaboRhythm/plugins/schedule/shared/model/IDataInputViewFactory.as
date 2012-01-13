package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public interface IDataInputViewFactory
    {
        function isMatchingDataInputViewFactory(name:String):Boolean;
        function createDataInputView(name:String, measurements:String,
									 scheduleItemOccurrence:ScheduleItemOccurrence):Class;
    }
}
