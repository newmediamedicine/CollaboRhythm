package collaboRhythm.shared.model
{


    [Bindable]
    public class EquipmentScheduleItem extends ScheduleItemBase
	{
        private var _scheduledEquipment:Equipment;
//		private var _dose:ValueAndUnit;
//		private var _scheduledActionID:String;
//		private var _scheduledAction:Equipment;
//		private var _scheduleGroupID:String;
		
		public function EquipmentScheduleItem():void
		{

		}

        public override function initFromReportXML(scheduleItemReportXml:XML, scheduleItemElementName:String):void
        {
			default xml namespace = "http://indivo.org/vocab/xml/documents#";
            super.initFromReportXML(scheduleItemReportXml, scheduleItemElementName);

//            _scheduledActionID = scheduleItemReportXML.Meta.Document.relatesTo.relation.relatedDocument.@id;
//			_scheduleGroupID =  scheduleItemReportXML.Meta.Document.isRelatedFrom.relation.relatedDocument[0].@id;
        }
		
//		public function get dose():ValueAndUnit
//		{
//			return _dose;
//		}
//
//		public function get scheduledActionID():String
//		{
//			return _scheduledActionID;
//		}
//
//		public function get scheduledAction():Equipment
//		{
//			return _scheduledAction;
//		}
//
//		public function set scheduledAction(value:Equipment):void
//		{
//			_scheduledAction = value;
//		}
//
//		public function get scheduleGroupID():String
//		{
//			return _scheduleGroupID;
//		}
//
//		public override function createScheduleItemClockView():ScheduleItemClockViewBase
//		{
//			var equipmentScheduleItemClockView:EquipmentScheduleItemClockView = new EquipmentScheduleItemClockView();
//			equipmentScheduleItemClockView.equipment = _scheduledAction;
//			equipmentScheduleItemClockView.equipmentScheduleItem = this;
//			return equipmentScheduleItemClockView;
//		}
//
//		public override function createScheduleItemReportingView():ScheduleItemReportingViewBase
//		{
//			var equipmentScheduleItemWidgetView:EquipmentScheduleItemReportingView = new EquipmentScheduleItemReportingView();
//			equipmentScheduleItemWidgetView.equipment = _scheduledAction;
//			equipmentScheduleItemWidgetView.equipmentScheduleItem = this;
//			return equipmentScheduleItemWidgetView;
//		}
//
//		public override function createScheduleItemTimelineView():ScheduleItemTimelineViewBase
//		{
//			var equipmentScheduleItemFullView:EquipmentScheduleItemTimelineView = new EquipmentScheduleItemTimelineView();
//			equipmentScheduleItemFullView.equipment = _scheduledAction;
//			return equipmentScheduleItemFullView;
//		}
        public function get scheduledEquipment():Equipment
        {
            return _scheduledEquipment;
        }

        public function set scheduledEquipment(value:Equipment):void
        {
            _scheduledEquipment = value;
        }
    }
}