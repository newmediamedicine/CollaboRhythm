package collaboRhythm.plugins.medications.model
{

	import collaboRhythm.plugins.schedule.shared.model.HealthActionListViewModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministration;
	import collaboRhythm.shared.model.healthRecord.document.MedicationOrder;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	public class MedicationHealthActionListViewModel extends HealthActionListViewModelBase
	{
		private var _medicationScheduleItem:MedicationScheduleItem;
		private var _medicationOrder:MedicationOrder;

		private var _currentDateSource:ICurrentDateSource;

		public function MedicationHealthActionListViewModel(scheduleItemOccurrence:ScheduleItemOccurrence,
															healthActionModelDetailsProvider:IHealthActionModelDetailsProvider)
		{
			super(scheduleItemOccurrence, healthActionModelDetailsProvider);

			_medicationScheduleItem = scheduleItemOccurrence.scheduleItem as MedicationScheduleItem;
			_medicationOrder = _medicationScheduleItem.scheduledMedicationOrder;

			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

		override public function createHealthActionResult():void
		{
			var medicationAdministration:MedicationAdministration = new MedicationAdministration();
			medicationAdministration.init(_medicationOrder.name, healthActionInputModelDetailsProvider.accountId,
					_currentDateSource.now(), _currentDateSource.now(),
					_medicationScheduleItem.dose);

			var adherenceResults:Vector.<DocumentBase> = new Vector.<DocumentBase>();
			adherenceResults.push(medicationAdministration);
			scheduleItemOccurrence.createAdherenceItem(adherenceResults, healthActionInputModelDetailsProvider.record,
					healthActionInputModelDetailsProvider.accountId);
		}
	}
}
