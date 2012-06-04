package collaboRhythm.shared.model.healthRecord.document
{

	import collaboRhythm.shared.model.*;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;

	import mx.collections.ArrayCollection;


	[Bindable]
    public class HealthActionSchedule extends ScheduleItemBase
	{
		public static const DOCUMENT_TYPE:String = "http://indivo.org/vocab/xml/documents#HealthActionSchedule";
        public static const EQUIPMENT:String = "Equipment";

        private var _scheduledEquipment:Equipment;
//		private var _scheduledActionID:String;
//		private var _scheduledAction:Equipment;
//		private var _scheduleGroupID:String;
		private var _scheduledHealthAction:DocumentBase;
		private var _occurrences:ArrayCollection;
		
		public function HealthActionSchedule():void
		{

		}

        override public function initFromReportXML(scheduleItemReportXml:XML, scheduleItemElementName:String):void
        {
			default xml namespace = "http://indivo.org/vocab/xml/documents#";
            super.initFromReportXML(scheduleItemReportXml, scheduleItemElementName);
        }

        override public function createXmlDocument():XML
        {
            var healthActionScheduleXml:XML = <HealthActionSchedule/>;
            return healthActionScheduleXml;
        }

        override public function schedueItemType():String
        {
            return EQUIPMENT;
        }

        override public function addExtraXml(scheduleItemXml:XML):XML
        {
            return scheduleItemXml;
        }

        override public function getScheduleActionId():String
        {
            return _scheduledEquipment.meta.id;
        }
		
        public function get scheduledEquipment():Equipment
        {
            return _scheduledEquipment;
        }

        public function set scheduledEquipment(value:Equipment):void
        {
            _scheduledEquipment = value;
        }

		public function get scheduledHealthAction():DocumentBase
		{
			return _scheduledHealthAction;
		}

		public function set scheduledHealthAction(value:DocumentBase):void
		{
			_scheduledHealthAction = value;
		}

		public function get occurrences():ArrayCollection
		{
			return _occurrences;
		}

		public function set occurrences(value:ArrayCollection):void
		{
			_occurrences = value;
		}
	}
}