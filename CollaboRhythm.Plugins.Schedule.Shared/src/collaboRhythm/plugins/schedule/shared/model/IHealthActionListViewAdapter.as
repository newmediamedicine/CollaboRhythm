package collaboRhythm.plugins.schedule.shared.model
{
	import mx.core.IVisualElement;

	import spark.components.Image;

	/**
	 * View adapter responsible for customizing how the health action is displayed in the various views associated with
	 * scheduling and acting upon the health action, including the clock view, reporting view, and time line view.
	 */
	public interface IHealthActionListViewAdapter
	{
		function get healthAction():HealthActionBase;

		/**
		 * Creates a new Image instance to represent the health action.
		 */
		function createImage():Image;

		/**
		 * Creates a view to use to represent the health action instead of the image (optional). Returns null
		 * if the adapter does not opt to provide a custom view, in which case the image should be used.
		 */
		function createCustomView():IVisualElement;

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
