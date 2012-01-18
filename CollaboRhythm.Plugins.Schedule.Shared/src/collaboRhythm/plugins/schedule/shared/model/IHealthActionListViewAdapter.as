package collaboRhythm.plugins.schedule.shared.model
{
	import spark.components.Image;

	public interface IHealthActionListViewAdapter
	{
		function get image():Image;
		function get name():String;
		function get description():String;
		function get indication():String;
		function get instructions():String;
		function get model():ScheduleItemOccurrenceReportingModelBase
	}
}
