package collaboRhythm.plugins.medications.model
{

	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleItemOccurrenceReportingModelBase;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministration;
	import collaboRhythm.shared.model.healthRecord.document.MedicationOrder;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	public class MedicationScheduleItemOccurrenceReportingModel extends ScheduleItemOccurrenceReportingModelBase
	{
		private var _medicationScheduleItem:MedicationScheduleItem;
		private var _medicationOrder:MedicationOrder;

		private var _currentDateSource:ICurrentDateSource;

		public function MedicationScheduleItemOccurrenceReportingModel(scheduleItemOccurrence:ScheduleItemOccurrence,
																	   scheduleModel:IScheduleModel)
		{
			super(scheduleItemOccurrence, scheduleModel);

			_medicationScheduleItem = scheduleItemOccurrence.scheduleItem as MedicationScheduleItem;
			_medicationOrder = _medicationScheduleItem.scheduledMedicationOrder;

			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

		override public function createAdherenceItem():void
		{
			var medicationAdministration:MedicationAdministration = new MedicationAdministration();
			medicationAdministration.init(_medicationOrder.name, _scheduleModel.accountId,
										  _currentDateSource.now(), _currentDateSource.now(),
										  _medicationScheduleItem.dose);

			var adherenceItem:AdherenceItem = new AdherenceItem();
			var adherenceResults:Vector.<DocumentBase> = new Vector.<DocumentBase>();
			adherenceResults.push(medicationAdministration);
			adherenceItem.init(_medicationOrder.name, _scheduleModel.accountId, _currentDateSource.now(),
							   scheduleItemOccurrence.recurrenceIndex, true, null, adherenceResults);

			_scheduleModel.createAdherenceItem(scheduleItemOccurrence, adherenceItem);
		}

		override public function isAdditionalInformationRequired():Boolean
		{
			return false;
		}
	}
}
