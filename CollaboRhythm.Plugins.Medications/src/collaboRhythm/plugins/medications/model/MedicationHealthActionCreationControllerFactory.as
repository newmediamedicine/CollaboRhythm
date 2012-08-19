package collaboRhythm.plugins.medications.model
{
	import collaboRhythm.plugins.medications.controller.MedicationHealthActionCreationController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationControllerFactory;
	import collaboRhythm.shared.model.Account;

	import spark.components.ViewNavigator;

	public class MedicationHealthActionCreationControllerFactory implements IHealthActionCreationControllerFactory
	{
		public function MedicationHealthActionCreationControllerFactory()
		{
		}

		public function createHealthActionCreationController(activeAccount:Account,
															 activeRecordAccount:Account,
															 viewNavigator:ViewNavigator):IHealthActionCreationController
		{
			return new MedicationHealthActionCreationController(activeAccount, activeRecordAccount, viewNavigator);
		}
	}
}
