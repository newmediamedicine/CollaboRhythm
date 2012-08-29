package collaboRhythm.plugins.medications.model
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.medications.controller.MedicationHealthActionCreationController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationControllerFactory;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import spark.components.ViewNavigator;

	public class MedicationHealthActionCreationControllerFactory implements IHealthActionCreationControllerFactory
	{
		public function MedicationHealthActionCreationControllerFactory()
		{
		}

		public function createHealthActionCreationController(activeAccount:Account, activeRecordAccount:Account,
															 viewNavigator:ViewNavigator):IHealthActionCreationController
		{
			return new MedicationHealthActionCreationController(activeAccount, activeRecordAccount, viewNavigator);
		}

		public function createHealthActionCreationControllerFromScheduleItemOccurrence(activeAccount:Account,
																					   activeRecordAccount:Account,
																					   scheduleItemOccurrence:ScheduleItemOccurrence,
																					   viewNavigator:ViewNavigator):IHealthActionCreationController
		{
			if (ReflectionUtils.getClass(scheduleItemOccurrence.scheduleItem) == MedicationScheduleItem)
				return new MedicationHealthActionCreationController(activeAccount, activeRecordAccount, viewNavigator,
						scheduleItemOccurrence);
			else
				return null;
		}
	}
}
