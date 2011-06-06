package collaboRhythm.plugins.equipment.model
{
	import collaboRhythm.plugins.equipment.view.EquipmentScheduleItemClockView;
	import collaboRhythm.plugins.equipment.view.EquipmentScheduleItemReportingView;
	import collaboRhythm.plugins.equipment.view.EquipmentScheduleItemTimelineView;
	import collaboRhythm.shared.model.ScheduleItemBase;
	import collaboRhythm.plugins.schedule.shared.view.ScheduleItemClockViewBase;
	import collaboRhythm.plugins.schedule.shared.view.ScheduleItemReportingViewBase;
	import collaboRhythm.plugins.schedule.shared.view.ScheduleItemTimelineViewBase;
	import collaboRhythm.shared.model.ValueAndUnit;
	import collaboRhythm.shared.model.healthRecord.HealthRecordHelperMethods;
	
	public class EquipmentScheduleItem extends ScheduleItemBase
	{
		private var _dose:ValueAndUnit;
		private var _scheduledActionID:String;
		private var _scheduledAction:Equipment;
		private var _scheduleGroupID:String;
		
		public function EquipmentScheduleItem(scheduleItemReportXML:XML):void
		{
			super(scheduleItemReportXML, "MedicationScheduleItem");
			
			_dose = new ValueAndUnit(scheduleItemXML.dose.value, HealthRecordHelperMethods.xmlToCodedValue(scheduleItemXML.dose.unit[0]));
			_scheduledActionID = scheduleItemReportXML.Meta.Document.relatesTo.relation.relatedDocument.@id;
			_scheduleGroupID =  scheduleItemReportXML.Meta.Document.isRelatedFrom.relation.relatedDocument[0].@id;
		}
		
		public function get dose():ValueAndUnit
		{
			return _dose;
		}
		
		public function get scheduledActionID():String
		{
			return _scheduledActionID;
		}
		
		public function get scheduledAction():Equipment
		{
			return _scheduledAction;
		}
		
		public function set scheduledAction(value:Equipment):void
		{
			_scheduledAction = value;
		}
		
		public function get scheduleGroupID():String
		{
			return _scheduleGroupID;
		}
		
		public override function createScheduleItemClockView():ScheduleItemClockViewBase
		{
			var equipmentScheduleItemClockView:EquipmentScheduleItemClockView = new EquipmentScheduleItemClockView();
			equipmentScheduleItemClockView.equipment = _scheduledAction;
			equipmentScheduleItemClockView.equipmentScheduleItem = this;
			return equipmentScheduleItemClockView;
		}
		
		public override function createScheduleItemReportingView():ScheduleItemReportingViewBase
		{
			var equipmentScheduleItemWidgetView:EquipmentScheduleItemReportingView = new EquipmentScheduleItemReportingView();
			equipmentScheduleItemWidgetView.equipment = _scheduledAction;
			equipmentScheduleItemWidgetView.equipmentScheduleItem = this;
			return equipmentScheduleItemWidgetView;
		}
		
		public override function createScheduleItemTimelineView():ScheduleItemTimelineViewBase
		{
			var equipmentScheduleItemFullView:EquipmentScheduleItemTimelineView = new EquipmentScheduleItemTimelineView();
			equipmentScheduleItemFullView.equipment = _scheduledAction;
			return equipmentScheduleItemFullView;
		}
	}
}