package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionListViewControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.EquipmentHealthAction;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionBase;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionListViewModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.Equipment;
	import collaboRhythm.shared.model.healthRecord.document.EquipmentModel;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionSchedule;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.IImageCacheService;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import mx.core.IVisualElement;

	import spark.components.Image;
	import spark.skins.spark.ImageSkin;

	public class ForaD40bHealthActionListViewAdapterBase implements IHealthActionListViewAdapter
	{
		protected var _scheduleItemOccurrence:ScheduleItemOccurrence;
		private var _healthActionSchedule:HealthActionSchedule;
		private var _equipment:Equipment;

		private var _equipmentHealthAction:EquipmentHealthAction;
		private var _model:HealthActionListViewModelBase;
		private var _controller:HealthActionListViewControllerBase;

		private var _imageCacheService:IImageCacheService;

		public function ForaD40bHealthActionListViewAdapterBase(scheduleItemOccurrence:ScheduleItemOccurrence,
																healthActionModelDetailsProvider:IHealthActionModelDetailsProvider)
		{
			_scheduleItemOccurrence = scheduleItemOccurrence;
			_healthActionSchedule = scheduleItemOccurrence.scheduleItem as HealthActionSchedule;
			_equipment = _healthActionSchedule.scheduledEquipment;

			_equipmentHealthAction = new EquipmentHealthAction(_healthActionSchedule.instructions, _equipment.name);

			_model = new HealthActionListViewModelBase(scheduleItemOccurrence, healthActionModelDetailsProvider);
			_controller = new HealthActionListViewControllerBase(_model);

			_imageCacheService = WorkstationKernel.instance.resolve(IImageCacheService) as IImageCacheService;
		}

		public function get healthAction():HealthActionBase
		{
			return _equipmentHealthAction;
		}

		public function createImage():Image
		{
			var equipmentImage:Image = new Image();
			equipmentImage.setStyle("skinClass", ImageSkin);
			equipmentImage.source = _imageCacheService.getImage(equipmentImage, encodeURI(EquipmentModel.EQUIPMENT_API_URL_BASE + _equipment.name + ".png"));

			return equipmentImage;
		}

		public function get name():String
		{
			return _equipment.name;
		}

		public function get description():String
		{
			return "";
		}

		public function get indication():String
		{
			return "";
		}

		public function get primaryInstructions():String
		{
			return "";
		}

		public function get secondaryInstructions():String
		{
			return "";
		}

		public function get instructionalVideoPath():String
		{
			return "";
		}

		public function set instructionalVideoPath(value:String):void
		{
		}

		public function get additionalAdherenceInformation():String
		{
			return "";
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
