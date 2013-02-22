package collaboRhythm.plugins.medications.model
{
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleCollectionsProvider;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministration;
	import collaboRhythm.shared.model.healthRecord.document.MedicationOrder;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	[Bindable]
	public class MedicationHealthActionInputModel extends HealthActionInputModelBase implements IHealthActionInputModel
	{
		private var _medicationScheduleItem:MedicationScheduleItem;
		private var _medicationOrder:MedicationOrder;
		private var _dateMeasuredStart:Date;

		public function MedicationHealthActionInputModel(scheduleItemOccurrence:ScheduleItemOccurrence,
														 healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
														 scheduleCollectionsProvider:IScheduleCollectionsProvider)
		{
			super(scheduleItemOccurrence, healthActionModelDetailsProvider, scheduleCollectionsProvider);

			if (scheduleItemOccurrence)
			{
				_medicationScheduleItem = scheduleItemOccurrence.scheduleItem as MedicationScheduleItem;
				_medicationOrder = _medicationScheduleItem.scheduledMedicationOrder;
			}

			dateMeasuredStart = _currentDateSource.now();
		}

		public function handleHealthActionResult(initiatedLocally:Boolean):void
		{
			createMedicationAdministration(initiatedLocally);
		}

		public function createMedicationAdministration(initiatedLocally:Boolean):void
		{
			if (_medicationScheduleItem)
			{
				var medicationAdministration:MedicationAdministration = new MedicationAdministration();
				medicationAdministration.init(_medicationOrder ? _medicationOrder.name : _medicationScheduleItem.name,
						healthActionModelDetailsProvider.accountId,
						dateMeasuredStart, dateMeasuredStart, _medicationScheduleItem.dose);

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
			var adherenceResultDate:Date;

			if (scheduleItemOccurrence && scheduleItemOccurrence.adherenceItem &&
					scheduleItemOccurrence.adherenceItem.adherenceResults &&
					scheduleItemOccurrence.adherenceItem.adherenceResults.length != 0)
			{
				var medicationAdministration:MedicationAdministration = scheduleItemOccurrence.adherenceItem.adherenceResults[0] as
						MedicationAdministration;
				adherenceResultDate = medicationAdministration.dateAdministered;
			}

			return adherenceResultDate;
		}

		public function get dateMeasuredStart():Date
		{
			return _dateMeasuredStart;
		}

		public function set dateMeasuredStart(value:Date):void
		{
			_dateMeasuredStart = value;
		}

		public function get isChangeTimeAllowed():Boolean
		{
			return true;
		}
	}
}
