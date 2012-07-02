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

		/**
		 * Path to the video file instructing the user how to perform the health action.
		 */
		function get instructionalVideoPath():String;
		function set instructionalVideoPath(value:String):void;

		function get additionalAdherenceInformation():String;

		function get model():IHealthActionListViewModel;

		function get controller():IHealthActionListViewController;
	}
}
