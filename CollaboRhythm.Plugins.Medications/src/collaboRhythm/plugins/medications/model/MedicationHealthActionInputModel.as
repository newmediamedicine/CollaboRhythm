package collaboRhythm.plugins.medications.model
{
	import collaboRhythm.plugins.medications.view.MedicationHealthActionInputView;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministration;
	import collaboRhythm.shared.model.healthRecord.document.MedicationOrder;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class MedicationHealthActionInputModel extends HealthActionInputModelBase implements IHealthActionInputModel
	{
		private var _medicationScheduleItem:MedicationScheduleItem;
		private var _medicationOrder:MedicationOrder;

		public function MedicationHealthActionInputModel(scheduleItemOccurrence:ScheduleItemOccurrence,
														 healthActionModelDetailsProvider:IHealthActionModelDetailsProvider)
		{
			super(scheduleItemOccurrence, healthActionModelDetailsProvider);

			if (scheduleItemOccurrence)
			{
				_medicationScheduleItem = scheduleItemOccurrence.scheduleItem as MedicationScheduleItem;
				_medicationOrder = _medicationScheduleItem.scheduledMedicationOrder;
			}
		}

		public function handleHealthActionResult(initiatedLocally:Boolean):void
		{
			createMedicationAdministration(initiatedLocally);
		}

		public function createMedicationAdministration(initiatedLocally:Boolean, selectedDate:Date = null):void
		{
			if (_medicationScheduleItem)
			{
				if (selectedDate == null)
				{
					selectedDate = _currentDateSource.now();
				}

				var medicationAdministration:MedicationAdministration = new MedicationAdministration();
				medicationAdministration.init(_medicationOrder ? _medicationOrder.name : _medicationScheduleItem.name,
						healthActionModelDetailsProvider.accountId,
						selectedDate, selectedDate, _medicationScheduleItem.dose);

				var adherenceResults:Vector.<DocumentBase> = new Vector.<DocumentBase>();
				adherenceResults.push(medicationAdministration);
				scheduleItemOccurrence.createAdherenceItem(adherenceResults,
						healthActionModelDetailsProvider.record, healthActionModelDetailsProvider.accountId,
						initiatedLocally);
			}
		}

		public function saveAllChanges():void
		{
			healthActionModelDetailsProvider.record.saveAllChanges();
		}

		public function get adherenceResultDate():Date
		{
			return null;
		}

		public function get dateMeasuredStart():Date
		{
			return null;
		}
	}
}
