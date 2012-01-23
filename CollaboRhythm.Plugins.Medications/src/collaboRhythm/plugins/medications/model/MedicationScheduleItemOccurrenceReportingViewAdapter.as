package collaboRhythm.plugins.medications.model
{
	import collaboRhythm.plugins.medications.view.MedicationImage;
	import collaboRhythm.plugins.schedule.shared.model.HealthAction;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleItemOccurrenceReportingModelBase;
	import collaboRhythm.shared.model.healthRecord.document.MedicationFillsModel;
	import collaboRhythm.shared.model.healthRecord.document.MedicationOrder;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.util.MedicationName;
	import collaboRhythm.shared.model.healthRecord.util.MedicationNameUtil;
	import collaboRhythm.shared.model.services.IMedicationColorSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import spark.components.Image;

	public class MedicationScheduleItemOccurrenceReportingViewAdapter implements IHealthActionListViewAdapter
	{
		private var _medicationScheduleItem:MedicationScheduleItem;
		private var _medicationOrder:MedicationOrder;
		private var _medicationName:MedicationName;
		private var _medicationColorSource:IMedicationColorSource;
		private var _scheduleItemOccurrence:ScheduleItemOccurrence;
		private var _scheduleModel:IScheduleModel;

		public function MedicationScheduleItemOccurrenceReportingViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
																			 scheduleModel:IScheduleModel)
		{
			_scheduleItemOccurrence = scheduleItemOccurrence;
			_scheduleModel = scheduleModel;

			_medicationScheduleItem = scheduleItemOccurrence.scheduleItem as MedicationScheduleItem;
			_medicationOrder = _medicationScheduleItem.scheduledMedicationOrder;
			_medicationName = MedicationNameUtil.parseName(_medicationScheduleItem.name.text);

			_medicationColorSource = WorkstationKernel.instance.resolve(IMedicationColorSource) as IMedicationColorSource;
		}

		public function get healthAction():HealthAction
		{
			return new HealthAction(_medicationScheduleItem.name.text, _medicationOrder.name.text)
		}

		public function get image():Image
		{
			var medicationImage:MedicationImage = new MedicationImage();
			if (_medicationScheduleItem && _medicationOrder && _medicationOrder.medicationFill)
			{
				medicationImage.setStyle("loadingImageColor",
										 _medicationColorSource.getMedicationColor(_medicationOrder.medicationFill.ndc.text));
				medicationImage.source = MedicationFillsModel.MEDICATION_API_URL_BASE + _medicationScheduleItem.scheduledMedicationOrder.medicationFill.ndc.text + "-front.png";
			}
			return medicationImage;
		}

		public function get name():String
		{
			if (_medicationName.proprietaryName)
				return _medicationName.medicationName + " " + _medicationName.proprietaryName;
			else
				return _medicationName.medicationName;
		}

		public function get description():String
		{
			return _medicationName.strength + " " + _medicationName.form;
		}

		public function get indication():String
		{
			if (_medicationOrder)
				return _medicationOrder.indication;
			else
				return "";
		}

		public function get instructions():String
		{
			return _medicationScheduleItem.instructions;
		}
		public function get model():ScheduleItemOccurrenceReportingModelBase
		{
			return new MedicationScheduleItemOccurrenceReportingModel(_scheduleItemOccurrence, _scheduleModel);
		}
	}
}
