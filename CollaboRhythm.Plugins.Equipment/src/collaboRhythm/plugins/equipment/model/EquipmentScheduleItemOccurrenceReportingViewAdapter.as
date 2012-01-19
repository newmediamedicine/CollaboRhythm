package collaboRhythm.plugins.equipment.model
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleItemOccurrenceReportingModelBase;
	import collaboRhythm.shared.model.healthRecord.document.Equipment;
	import collaboRhythm.shared.model.healthRecord.document.EquipmentModel;
	import collaboRhythm.shared.model.healthRecord.document.EquipmentScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import spark.components.Image;
	import spark.skins.spark.ImageSkin;

	public class EquipmentScheduleItemOccurrenceReportingViewAdapter implements IHealthActionListViewAdapter
	{
		private var _equipmentScheduleItem:EquipmentScheduleItem;
		private var _equipment:Equipment;
		private var _scheduleItemOccurrence:ScheduleItemOccurrence;
		private var _scheduleModel:IScheduleModel;

		public function EquipmentScheduleItemOccurrenceReportingViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
																			scheduleModel:IScheduleModel)
		{
			_scheduleItemOccurrence = scheduleItemOccurrence;
			_scheduleModel = scheduleModel;

			_equipmentScheduleItem = scheduleItemOccurrence.scheduleItem as EquipmentScheduleItem;
			_equipment = _equipmentScheduleItem.scheduledEquipment;
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

		public function get model():ScheduleItemOccurrenceReportingModelBase
		{
			return new EquipmentScheduleItemOccurrenceReportingModel(_scheduleItemOccurrence, _scheduleModel);
		}
	}
}
