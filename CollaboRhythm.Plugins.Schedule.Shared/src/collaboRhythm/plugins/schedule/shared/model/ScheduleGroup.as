/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
 * version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
package collaboRhythm.plugins.schedule.shared.model
{

    import collaboRhythm.shared.model.ScheduleItemOccurrence;
    import collaboRhythm.shared.model.ScheduleItemOccurrenceBase;

    import mx.collections.ArrayCollection;

    [Bindable]
	public class ScheduleGroup extends ScheduleItemOccurrenceBase
	{
		private var _scheduleItemsOccurrencesCollection:ArrayCollection = new ArrayCollection();
        private var _stackNumber:Number;

		public function ScheduleGroup(dateStart:Date, dateEnd:Date)//scheduleModel:ScheduleModel, scheduleGroupReportXML:XML)
		{
            super(dateStart, dateEnd);
		}

        //			parseDocumentMetadata(scheduleGroupReportXML.Meta.Document[0], this);
//			var scheduleGroupXML:XML = scheduleGroupReportXML.Item.ScheduleGroup[0];
//			_scheduledBy = scheduleGroupXML.scheduledBy;
//			_dateTimeScheduled = collaboRhythm.shared.model.DateUtil.parseW3CDTF(scheduleGroupXML.dateTimeScheduled.toString());
//			_dateTimeStart = collaboRhythm.shared.model.DateUtil.parseW3CDTF(scheduleGroupXML.dateTimeStart.toString());
//			_dateTimeEnd = collaboRhythm.shared.model.DateUtil.parseW3CDTF(scheduleGroupXML.dateTimeEnd.toString());
////			_recurrenceRule = new RecurrenceRule(scheduleGroupXML.recurrenceRule.frequency, Number(scheduleGroupXML.recurrenceRule.count));
//
//			_scheduleModel = scheduleModel;
//

		public function convertToXML():XML
		{
			var scheduleGroupDocument:XML = <ScheduleGroup/>;
//			scheduleGroupDocument.@xmlns = "http://indivo.org/vocab/xml/documents#";
//			scheduleGroupDocument.scheduledBy = scheduledBy;
//			scheduleGroupDocument.dateTimeScheduled = com.adobe.utils.DateUtil.toW3CDTF(dateTimeScheduled);
//			scheduleGroupDocument.dateTimeStart = com.adobe.utils.DateUtil.toW3CDTF(dateTimeStart);
//			scheduleGroupDocument.dateTimeEnd = com.adobe.utils.DateUtil.toW3CDTF(dateTimeEnd);
//			scheduleGroupDocument.recurrenceRule.frequency = recurrenceRule.frequency;
//			scheduleGroupDocument.recurrenceRule.count = recurrenceRule.count;
//
			return scheduleGroupDocument;
		}

		public function get scheduleItemsOccurrencesCollection():ArrayCollection
		{
			return _scheduleItemsOccurrencesCollection;
		}
		
		public function addScheduleItemOccurrence(scheduleItemOccurrence:ScheduleItemOccurrence):void
		{
			_scheduleItemsOccurrencesCollection.addItem(scheduleItemOccurrence);
		}

        public function get stackNumber():Number
        {
            return _stackNumber;
        }

        public function set stackNumber(value:Number):void
        {
            _stackNumber = value;
        }
    }
}