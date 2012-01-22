package collaboRhythm.plugins.medications.model
{
	import collaboRhythm.plugins.medications.view.MedicationImage;
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionListViewControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.plugins.schedule.shared.model.MedicationHealthAction;
	import collaboRhythm.shared.model.healthRecord.document.MedicationFillsModel;
	import collaboRhythm.shared.model.healthRecord.document.MedicationOrder;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.util.MedicationName;
	import collaboRhythm.shared.model.healthRecord.util.MedicationNameUtil;
	import collaboRhythm.shared.model.services.IMedicationColorSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import spark.components.Image;

	public class MedicationHealthActionListViewAdapter implements IHealthActionListViewAdapter
	{
		private var _medicationScheduleItem:MedicationScheduleItem;
		private var _medicationOrder:MedicationOrder;
		private var _medicationName:MedicationName;
		private var _medicationColorSource:IMedicationColorSource;
		private var _medicationHealthAction:MedicationHealthAction;

		private var _model:MedicationHealthActionListViewModel;
		private var _controller:HealthActionListViewControllerBase;

		public function MedicationHealthActionListViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
																			 healthActionModelDetailsProvider:IHealthActionModelDetailsProvider)
		{
			_medicationScheduleItem = scheduleItemOccurrence.scheduleItem as MedicationScheduleItem;
			_medicationOrder = _medicationScheduleItem.scheduledMedicationOrder;
			_medicationName = MedicationNameUtil.parseName(_medicationScheduleItem.name.text);

			_medicationColorSource = WorkstationKernel.instance.resolve(IMedicationColorSource) as IMedicationColorSource;

			_medicationHealthAction = new MedicationHealthAction(_medicationScheduleItem.name.text, _medicationOrder.name.text);

			_model = new MedicationHealthActionListViewModel(scheduleItemOccurrence, healthActionModelDetailsProvider);
			_controller = new HealthActionListViewControllerBase(_model)
		}

		public function get healthAction():HealthActionBase
		{
			return _medicationHealthAction;
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

		public function get model():IHealthActionListViewModel
		{
			return _model;
		}

		public function get controller():IHealthActionListViewController
		{
			return _controller;
		}
	}
}
