package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import spark.components.ViewNavigator;

	public interface IHealthActionCreationControllerFactory
	{
		function createHealthActionCreationController(activeAccount:Account,
													  activeRecordAccount:Account,
													  viewNavigator:ViewNavigator):IHealthActionCreationController;

		function createHealthActionCreationControllerFromScheduleItemOccurrence(activeAccount:Account,
																				activeRecordAccount:Account,
																				scheduleItemOccurrence:ScheduleItemOccurrence,
																				viewNavigator:ViewNavigator):IHealthActionCreationController;
	}
}
