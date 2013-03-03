package collaboRhythm.plugins.bloodPressure.model.titration
{
	import collaboRhythm.plugins.bloodPressure.controller.titration.HypertensionMedicationTitrationSupportHealthActionCreationController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationControllerFactory;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import spark.components.ViewNavigator;

	public class HypertensionMedicationTitrationSupportHealthActionCreationControllerFactory implements IHealthActionCreationControllerFactory
	{
		public function HypertensionMedicationTitrationSupportHealthActionCreationControllerFactory()
		{
		}

		public function createHealthActionCreationController(activeAccount:Account, activeRecordAccount:Account,
															 viewNavigator:ViewNavigator):IHealthActionCreationController
		{
			return new HypertensionMedicationTitrationSupportHealthActionCreationController(activeAccount, activeRecordAccount,
					viewNavigator);
		}

		public function createHealthActionCreationControllerFromScheduleItemOccurrence(activeAccount:Account,
																					   activeRecordAccount:Account,
																					   scheduleItemOccurrence:ScheduleItemOccurrence,
																					   viewNavigator:ViewNavigator):IHealthActionCreationController
		{
			return new HypertensionMedicationTitrationSupportHealthActionCreationController(activeAccount, activeRecordAccount, viewNavigator,
									scheduleItemOccurrence);
		}
	}
}
