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
	import collaboRhythm.shared.model.healthRecord.document.HealthActionSchedule;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import mx.core.IVisualElement;

	import spark.components.Image;
	import spark.skins.spark.ImageSkin;

	public class EquipmentHealthActionListViewAdapter implements IHealthActionListViewAdapter
	{
		private var _healthActionSchedule:HealthActionSchedule;
		private var _equipment:Equipment;
		private var _equipmentHealthAction:EquipmentHealthAction;

		private var _model:HealthActionListViewModelBase;
		private var _controller:HealthActionListViewControllerBase;

		public function EquipmentHealthActionListViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
															 healthActionModelDetailsProvider:IHealthActionModelDetailsProvider)
		{
			_healthActionSchedule = scheduleItemOccurrence.scheduleItem as HealthActionSchedule;
			_equipment = _healthActionSchedule.scheduledEquipment;

			_equipmentHealthAction = new EquipmentHealthAction(_healthActionSchedule.instructions, _equipment.name);

			_model = new HealthActionListViewModelBase(scheduleItemOccurrence, healthActionModelDetailsProvider);

		}

		public function get healthAction():HealthActionBase
		{
			return _equipmentHealthAction;
		}

		public function createImage():Image
		{
			var equipmentImage:Image = new Image();
			equipmentImage.setStyle("skinClass", ImageSkin);
			equipmentImage.source = encodeURI(EquipmentModel.EQUIPMENT_API_URL_BASE + _equipment.name + ".png");

			return equipmentImage;
		}

		public function get name():String
		{
			return _equipment.name;
		}

		public function get description():String
		{
			return "Blood Glucose Meter";
		}

		public function get indication():String
		{
			return "";
		}

		public function get primaryInstructions():String
		{
			return "1 measurement from fingerstick";
		}

		public function get secondaryInstructions():String
		{
			return "take measurement before eating";
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
			return "...";
		}

		public function get model():IHealthActionListViewModel
		{
			return _model;
		}

		public function get controller():IHealthActionListViewController
		{
			if (!_controller)
			{
				_controller = new HealthActionListViewControllerBase(_model);
			}
			return _controller;
		}

		public function createCustomView():IVisualElement
		{
			return null;
		}
	}
}
