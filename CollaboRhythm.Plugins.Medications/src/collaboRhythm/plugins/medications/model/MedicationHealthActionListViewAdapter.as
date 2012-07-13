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
	import collaboRhythm.shared.model.services.IImageCacheService;
	import collaboRhythm.shared.model.services.IMedicationColorSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import mx.core.IVisualElement;

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
		private var _instructionalVideo:String = "";

		private var _imageCacheService:IImageCacheService;

		public function MedicationHealthActionListViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
															  healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
															  medicationOrder:MedicationOrder = null)
		{
			if (scheduleItemOccurrence)
			{
				_medicationScheduleItem = scheduleItemOccurrence.scheduleItem as MedicationScheduleItem;
				_medicationOrder = _medicationScheduleItem.scheduledMedicationOrder;
			}
			else if (medicationOrder)
			{
				_medicationOrder = medicationOrder;
			}

			if (_medicationOrder)
				_medicationName = MedicationNameUtil.parseName(_medicationOrder.name.text);
			else if (_medicationScheduleItem)
				_medicationName = MedicationNameUtil.parseName(_medicationScheduleItem.name.text);

			_medicationColorSource = WorkstationKernel.instance.resolve(IMedicationColorSource) as IMedicationColorSource;

			_medicationHealthAction = new MedicationHealthAction(_medicationName.rawName);

			_model = new MedicationHealthActionListViewModel(scheduleItemOccurrence, healthActionModelDetailsProvider, _medicationOrder);
			_controller = new HealthActionListViewControllerBase(_model);

			_imageCacheService = WorkstationKernel.instance.resolve(IImageCacheService) as IImageCacheService;
		}

		public function get healthAction():HealthActionBase
		{
			return _medicationHealthAction;
		}

		public function createImage():Image
		{
			var medicationImage:MedicationImage = new MedicationImage();
			if (_medicationOrder && _medicationOrder.medicationFill)
			{
				medicationImage.setStyle("loadingImageColor",
										 _medicationColorSource.getMedicationColor(_medicationOrder.medicationFill.ndc.text));
				medicationImage.source = _imageCacheService.getImage(medicationImage, MedicationFillsModel.MEDICATION_API_URL_BASE + _medicationOrder.medicationFill.ndc.text + "-front.png");
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

		public function get primaryInstructions():String
		{
			if (_medicationScheduleItem)
			{
				//TODO: Use the actual route from Indivo once it is modeled in the data
				var route:String = "";
				switch (_medicationName.form)
				{
					case "Oral Tablet":
						route = "by mouth";
						break;
					case "Prefilled Syringe":
						route = "subcutaneous injection";
						break;
				}
				return _medicationScheduleItem.dose.value + " " + _medicationScheduleItem.dose.unit.text + " " + route;
			}
			else
				return "";
		}

		public function get secondaryInstructions():String
		{
			if (_medicationScheduleItem)
				return _medicationScheduleItem.instructions;
			else if (_medicationOrder)
				return _medicationOrder.instructions;
			else
				return "";
		}

		public function get instructionalVideoPath():String
		{
			return _instructionalVideo;
		}

		public function set instructionalVideoPath(value:String):void
		{
			_instructionalVideo = value;
		}

		public function get additionalAdherenceInformation():String
		{
			return "...";
		}

		public function get model():IHealthActionListViewModel
		{
			return _model;
		}

		public function get controller():IHealthActionListViewController
		{
			return _controller;
		}

		public function createCustomView():IVisualElement
		{
			return null;
		}
	}
}
