package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.events.MouseEvent;
	import flash.net.URLVariables;

	/**
	 * A health action input controller is used to handle creating/reporting a scheduled and/or unscheduled health
	 * action. A plugin can implement an input controller to customize the appearance and behavior of the view(s)
	 * used for reporting a given health action.
	 * @see IHealthActionInputControllerFactory
	 */
	public interface IHealthActionInputController
	{
		/**
		 * Shows the appropriate input view for this input controller. The controller should push an appropriate
		 * spark.components.View onto the ViewNavigator and thus allow the user to enter/view data for the
		 * corresponding health action.
		 */
		function handleHealthActionResult(initiatedLocally:Boolean):void;

		/**
		 * Shows the appropriate view when a health action is selected from the list of scheduled health actions. The
		 * controller should push an appropriate spark.components.View onto the ViewNavigator.
		 */
		function handleHealthActionSelected():void;

		/**
		 * Updates the input controller with new data (urlVariables) from a device.
		 * @param urlVariables Data from the device, received via an InvokeEvent from the DeviceGateway.
		 */
		function handleUrlVariables(urlVariables:URLVariables):void;

		/**
		 * The class of the spark.components.View this input controller uses. This property is used to determine if
		 * the active view of the ViewNavigator corresponds to the view of this input controller.
		 */
		function get healthActionInputViewClass():Class;

		function useDefaultHandleHealthActionResult():Boolean;

		function updateDateMeasuredStart(date:Date):void;

		function handleHealthActionCommandButtonClick(event:MouseEvent):void;

		function removeEventListener():void;

		function handleAdherenceChange(dataInputModel:IHealthActionInputModel,
									   scheduleItemOccurrence:ScheduleItemOccurrence, selected:Boolean):void;

		/**
		 * Returns true if an existing health action is being reviewed (in read-only mode).
		 */
		function get isReview():Boolean;
	}
}
