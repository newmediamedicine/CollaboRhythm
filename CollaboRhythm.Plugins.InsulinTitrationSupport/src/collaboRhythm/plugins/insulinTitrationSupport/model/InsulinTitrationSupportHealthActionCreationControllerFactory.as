package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.plugins.insulinTitrationSupport.controller.InsulinTitrationSupportHealthActionCreationController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationControllerFactory;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import spark.components.ViewNavigator;

	public class InsulinTitrationSupportHealthActionCreationControllerFactory implements IHealthActionCreationControllerFactory
	{
		public function InsulinTitrationSupportHealthActionCreationControllerFactory()
		{
		}

		public function createHealthActionCreationController(activeAccount:Account, activeRecordAccount:Account,
															 viewNavigator:ViewNavigator):IHealthActionCreationController
		{
			return new InsulinTitrationSupportHealthActionCreationController(activeAccount, activeRecordAccount,
					viewNavigator);
		}

		public function createHealthActionCreationControllerFromScheduleItemOccurrence(activeAccount:Account,
																					   activeRecordAccount:Account,
																					   scheduleItemOccurrence:ScheduleItemOccurrence,
																					   viewNavigator:ViewNavigator):IHealthActionCreationController
		{
			return new InsulinTitrationSupportHealthActionCreationController(activeAccount, activeRecordAccount, viewNavigator,
									scheduleItemOccurrence);
		}
	}
}
