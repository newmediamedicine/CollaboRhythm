package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	/**
	 * Factory for creating input controllers. Each factory can support one or more type of health actions. All
	 * registered factories will be given a chance to create or modify the input controller for a given health action.
	 * @see IHealthActionInputController
	 */
	public interface IHealthActionInputControllerFactory
	{
		/**
		 * Creates (or modifies) an input controller for the specified health action. If this factory does not
		 * support the specified healthAction, the currentHealthActionInputController should be returned instead.
		 * @param healthAction
		 * @param scheduleItemOccurrence
		 * @param healthActionModelDetailsProvider
		 * @param scheduleCollectionsProvider
		 * @param viewNavigator
		 * @param currentHealthActionInputController
		 * @param collaborationLobbyNetConnectionServiceProxy
		 * @return
		 */
		function createHealthActionInputController(healthAction:HealthActionBase,
												   scheduleItemOccurrence:ScheduleItemOccurrence,
												   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
												   scheduleCollectionsProvider:IScheduleCollectionsProvider,
												   viewNavigator:ViewNavigator,
												   currentHealthActionInputController:IHealthActionInputController,
												   collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy):IHealthActionInputController;

		/**
		 * Creates a health action input controller for handling input from a device. If this factory does not support
		 * the health action specified by the urlVariables, the currentDeviceHealthActionInputController should be
		 * returned instead.
		 * @param urlVariables
		 * @param healthActionModelDetailsProvider
		 * @param scheduleCollectionsProvider
		 * @param viewNavigator
		 * @param currentDeviceHealthActionInputController
		 * @return
		 */
		function createDeviceHealthActionInputController(urlVariables:URLVariables,
														 healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
														 scheduleCollectionsProvider:IScheduleCollectionsProvider,
														 viewNavigator:ViewNavigator,
														 currentDeviceHealthActionInputController:IHealthActionInputController):IHealthActionInputController;
	}
}
