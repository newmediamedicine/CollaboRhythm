package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import spark.components.ViewNavigator;

	/**
	 * Factory interface which a CollaboRhythm plugin can use to provide custom IHealthActionCreationController instances.
	 * Each factory can support one or more type of health actions. All registered factories will be given a chance to
	 * create or modify the creation controller for a given health action.
	 * @see IHealthActionCreationController
	 */
	public interface IHealthActionCreationControllerFactory
	{
		/**
		 * Creates a controller which will be used in the schedule time line view to create a button for creating
		 * a new scheduled health action.
		 * @param activeAccount The account of the current user who is editing the record
		 * @param activeRecordAccount The account of the active record
		 * @param viewNavigator The view navigator onto which a view can be pushed
		 * @return The controller
		 */
		function createHealthActionCreationController(activeAccount:Account, activeRecordAccount:Account,
													  viewNavigator:ViewNavigator):IHealthActionCreationController;

		/**
		 * Creates a controller for editing an existing scheduled health action. The controller will be used in the
		 * schedule time line view to create a view for editing the health action.
		 * @param activeAccount The account of the current user who is editing the record
		 * @param activeRecordAccount The account of the active record
		 * @param scheduleItemOccurrence The occurrence of the scheduled health action to be edited
		 * @param viewNavigator The view navigator onto which a view can be pushed
		 * @return The controller
		 */
		function createHealthActionCreationControllerFromScheduleItemOccurrence(activeAccount:Account,
																				activeRecordAccount:Account,
																				scheduleItemOccurrence:ScheduleItemOccurrence,
																				viewNavigator:ViewNavigator):IHealthActionCreationController;
	}
}
