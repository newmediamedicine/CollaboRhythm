package collaboRhythm.plugins.medications.insulin.model
{
	import collaboRhythm.plugins.schedule.shared.model.HealthActionBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.MedicationFillsModel;
	import collaboRhythm.shared.model.healthRecord.document.MedicationOrder;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.IImageCacheService;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import flash.events.Event;

	import mx.core.IVisualElement;
	import mx.events.ResizeEvent;

	import spark.components.Group;
	import spark.components.Image;
	import spark.components.Label;

	public class InsulinHealthActionListViewAdapter implements IHealthActionListViewAdapter
	{
		private var _scheduleItemOccurrence:ScheduleItemOccurrence;
		private var _healthActionModelDetailsProvider:IHealthActionModelDetailsProvider;
		private var _currentHealthActionListViewAdapter:IHealthActionListViewAdapter;

		private var _medicationScheduleItem:MedicationScheduleItem;
		private var _medicationOrder:MedicationOrder;

		private var _imageCacheService:IImageCacheService;


		public function InsulinHealthActionListViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
														   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
														   currentHealthActionListViewAdapter:IHealthActionListViewAdapter,
														   medicationOrder:MedicationOrder = null)
		{
			_scheduleItemOccurrence = scheduleItemOccurrence;
			_healthActionModelDetailsProvider = healthActionModelDetailsProvider;
			_currentHealthActionListViewAdapter = currentHealthActionListViewAdapter;

			if (scheduleItemOccurrence)
			{
				_medicationScheduleItem = scheduleItemOccurrence.scheduleItem as MedicationScheduleItem;
				_medicationOrder = _medicationScheduleItem.scheduledMedicationOrder;
			}
			else if (medicationOrder)
			{
				_medicationOrder = medicationOrder;
			}

			_imageCacheService = WorkstationKernel.instance.resolve(IImageCacheService) as IImageCacheService;
		}

		public function get healthAction():HealthActionBase
		{
			return _currentHealthActionListViewAdapter.healthAction;
		}

		public function createImage():Image
		{
			var medicationImage:Image = _currentHealthActionListViewAdapter.createImage();
			if (_medicationOrder && _medicationOrder.medicationFill)
			{
				medicationImage.source = _imageCacheService.getImage(medicationImage, MedicationFillsModel.MEDICATION_API_URL_BASE + _medicationOrder.medicationFill.ndc.text + "-dial-front.png");
			}
			return medicationImage;
		}

		public function get name():String
		{
			return _currentHealthActionListViewAdapter.name;
		}

		public function get description():String
		{
			return _currentHealthActionListViewAdapter.description;
		}

		public function get indication():String
		{
			return _currentHealthActionListViewAdapter.indication;
		}

		public function get primaryInstructions():String
		{
			return _currentHealthActionListViewAdapter.primaryInstructions;
		}

		public function get secondaryInstructions():String
		{
			return _currentHealthActionListViewAdapter.secondaryInstructions;
		}

		public function get instructionalVideoPath():String
		{
			return _currentHealthActionListViewAdapter.instructionalVideoPath;
		}

		public function set instructionalVideoPath(value:String):void
		{
			_currentHealthActionListViewAdapter.instructionalVideoPath = value;
		}

		public function get additionalAdherenceInformation():String
		{
			return _currentHealthActionListViewAdapter.additionalAdherenceInformation;
		}

		public function get model():IHealthActionListViewModel
		{
			return _currentHealthActionListViewAdapter.model;
		}

		public function get controller():IHealthActionListViewController
		{
			return _currentHealthActionListViewAdapter.controller;
		}

		public function createCustomView():IVisualElement
		{
			var group:Group = new Group();
			group.percentWidth = 100;
			group.percentHeight = 100;
			group.addEventListener(Event.RESIZE, group_resizeHandler);

			// Note that the image property creates a new instance of an image for this health action
			var customViewImage:Image = createImage();
			customViewImage.smooth = true;
			customViewImage.percentWidth = 100;
			customViewImage.percentHeight = 100;
			group.addElement(customViewImage);

			var label:Label = new Label();
			label.top = 13;
			label.right = 34;
			var medicationScheduleItem:MedicationScheduleItem = _scheduleItemOccurrence.scheduleItem as MedicationScheduleItem;
			if (medicationScheduleItem)
				label.text = medicationScheduleItem.dose.value;
			label.setStyle("fontSize", 26);
			label.setStyle("fontStyle", "italic");
			label.setStyle("color", 0xFFFFFF);
			group.addElement(label);

			return group;
		}

		private function group_resizeHandler(event:ResizeEvent):void
		{
			var group:Group = event.currentTarget as Group;
			var label:Label = group.getElementAt(1) as Label;

			if (label)
			{
				label.top = 11 / 75 * group.height;
				label.right = 33.0 / 75 * group.width;
				label.setStyle("fontSize", 26.0 / 75 * group.width);
			}
		}
	}
}
