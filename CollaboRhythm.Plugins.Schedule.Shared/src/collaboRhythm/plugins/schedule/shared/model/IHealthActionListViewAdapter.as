package collaboRhythm.plugins.schedule.shared.model
{
	import spark.components.Image;

	public interface IHealthActionListViewAdapter
	{
		function get healthAction():HealthActionBase;

		function get image():Image;
		function get name():String;
		function get description():String;
		function get indication():String;
		function get primaryInstructions():String;
		function get secondaryInstructions():String;
		function get instructionalVideo():String;
		function set instructionalVideo(value:String):void

		function get model():IHealthActionListViewModel

		function get controller():IHealthActionListViewController
	}
}
