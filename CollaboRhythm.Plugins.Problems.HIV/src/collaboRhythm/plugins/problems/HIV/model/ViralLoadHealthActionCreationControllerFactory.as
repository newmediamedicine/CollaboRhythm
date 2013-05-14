package collaboRhythm.plugins.problems.HIV.model
{
	import collaboRhythm.plugins.problems.HIV.controller.ViralLoadHealthActionCreationController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationControllerFactory;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import spark.components.ViewNavigator;

	public class ViralLoadHealthActionCreationControllerFactory implements IHealthActionCreationControllerFactory
	{
		public function ViralLoadHealthActionCreationControllerFactory()
		{

		}

		public function createHealthActionCreationController(activeAccount:Account, activeRecordAccount:Account,
															 viewNavigator:ViewNavigator):IHealthActionCreationController
		{
			return new ViralLoadHealthActionCreationController(activeAccount, activeRecordAccount, viewNavigator);
		}

		public function createHealthActionCreationControllerFromScheduleItemOccurrence(activeAccount:Account,
																					   activeRecordAccount:Account,
																					   scheduleItemOccurrence:ScheduleItemOccurrence,
																					   viewNavigator:ViewNavigator):IHealthActionCreationController
		{
			return null;
		}
	}
}
