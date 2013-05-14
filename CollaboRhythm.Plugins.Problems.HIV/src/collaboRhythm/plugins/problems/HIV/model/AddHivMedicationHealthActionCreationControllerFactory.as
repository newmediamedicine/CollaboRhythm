package collaboRhythm.plugins.problems.HIV.model
{
	import collaboRhythm.plugins.problems.HIV.controller.AddHivMedicationHealthActionCreationController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationControllerFactory;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import spark.components.ViewNavigator;

	public class AddHivMedicationHealthActionCreationControllerFactory implements IHealthActionCreationControllerFactory
	{
		public function AddHivMedicationHealthActionCreationControllerFactory()
		{
			super();
		}

		public function createHealthActionCreationController(activeAccount:Account, activeRecordAccount:Account,
															 viewNavigator:ViewNavigator):IHealthActionCreationController
		{
			return new AddHivMedicationHealthActionCreationController(activeAccount, activeRecordAccount, viewNavigator);
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
