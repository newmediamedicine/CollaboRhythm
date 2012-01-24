package collaboRhythm.plugins.equipment.model
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
	import collaboRhythm.shared.model.healthRecord.document.EquipmentScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import spark.components.Image;
	import spark.skins.spark.ImageSkin;

	public class EquipmentHealthActionListViewAdapter implements IHealthActionListViewAdapter
	{
		private var _equipmentScheduleItem:EquipmentScheduleItem;
		private var _equipment:Equipment;
		private var _equipmentHealthAction:EquipmentHealthAction;
		
		private var _model:HealthActionListViewModelBase;
		private var _controller:HealthActionListViewControllerBase;

		public function EquipmentHealthActionListViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
																			healthcationModelDetailsProvider:IHealthActionModelDetailsProvider)
		{
			_equipmentScheduleItem = scheduleItemOccurrence.scheduleItem as EquipmentScheduleItem;
			_equipment = _equipmentScheduleItem.scheduledEquipment;

			_equipmentHealthAction = new EquipmentHealthAction(_equipmentScheduleItem.instructions, _equipment.name);

			_model = new HealthActionListViewModelBase(scheduleItemOccurrence, healthcationModelDetailsProvider);
			_controller = new HealthActionListViewControllerBase(_model);
		}

		public function get healthAction():HealthActionBase
		{
			return _equipmentHealthAction;
		}

		public function get image():Image
		{
			var equipmentImage:Image = new Image();
			equipmentImage.setStyle("skinClass", ImageSkin);
			equipmentImage.source = encodeURI(EquipmentModel.EQUIPMENT_API_URL_BASE + _equipment.name + ".jpg");

			return equipmentImage;
		}

		public function get name():String
		{
			return _equipmentScheduleItem.name.text;
		}

		public function get description():String
		{
			return "";
		}

		public function get indication():String
		{
			return "";
		}

		public function get instructions():String
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
	}
}
