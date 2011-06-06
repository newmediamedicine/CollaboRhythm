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
	import collaboRhythm.shared.model.DateUtil;
    import collaboRhythm.shared.model.RecurrenceRule;
    import collaboRhythm.shared.model.ScheduleItemBase;
    import collaboRhythm.shared.model.healthRecord.DocumentMetadata;
	
	import com.adobe.utils.DateUtil;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class ScheduleGroup extends DocumentMetadata
	{
		private var _id:String;
		private var _scheduledBy:String;
		private var _dateTimeScheduled:Date;
		private var _dateTimeStart:Date;
		private var _dateTimeEnd:Date;
		private var _recurrenceRule:RecurrenceRule;
		private var _scheduleItemsCollection:ArrayCollection = new ArrayCollection();
		
		private var _scheduleModel:ScheduleModel;
		private var _dateTimeCenter:Date;
		
		private var _changed:Boolean = false;
		private var _moving:Boolean = false;
		private var _dateTimeCenterPreMove:Date;
		private var _dateTimeStartPreMove:Date;
		private var _dateTimeEndPreMove:Date;
		private var _containerMouseDownX:Number;
		private var _containerMouseDownY:Number;
		private var _yPreMove:Number;
		private var _yPosition:Number;
		private var _scheduleGroupsStacked:Number;
		private var _scheduleItemsStacked:Number;
		private var _stackingUpdate:Boolean;
		
		
		public function ScheduleGroup(scheduleModel:ScheduleModel, scheduleGroupReportXML:XML)
		{
			parseDocumentMetadata(scheduleGroupReportXML.Meta.Document[0], this);
			var scheduleGroupXML:XML = scheduleGroupReportXML.Item.ScheduleGroup[0];
			_scheduledBy = scheduleGroupXML.scheduledBy;
			_dateTimeScheduled = collaboRhythm.shared.model.DateUtil.parseW3CDTF(scheduleGroupXML.dateTimeScheduled.toString());
			_dateTimeStart = collaboRhythm.shared.model.DateUtil.parseW3CDTF(scheduleGroupXML.dateTimeStart.toString());
			_dateTimeEnd = collaboRhythm.shared.model.DateUtil.parseW3CDTF(scheduleGroupXML.dateTimeEnd.toString());
//			_recurrenceRule = new RecurrenceRule(scheduleGroupXML.recurrenceRule.frequency, Number(scheduleGroupXML.recurrenceRule.count));
				
			_scheduleModel = scheduleModel;
			_dateTimeCenter = new Date(dateTimeStart.time + (dateTimeEnd.time - dateTimeStart.time) / 2);
		}

		public function convertToXML():XML
		{
			var scheduleGroupDocument:XML = <ScheduleGroup/>;
			scheduleGroupDocument.@xmlns = "http://indivo.org/vocab/xml/documents#";
			scheduleGroupDocument.scheduledBy = scheduledBy;
			scheduleGroupDocument.dateTimeScheduled = com.adobe.utils.DateUtil.toW3CDTF(dateTimeScheduled);
			scheduleGroupDocument.dateTimeStart = com.adobe.utils.DateUtil.toW3CDTF(dateTimeStart);
			scheduleGroupDocument.dateTimeEnd = com.adobe.utils.DateUtil.toW3CDTF(dateTimeEnd);
			scheduleGroupDocument.recurrenceRule.frequency = recurrenceRule.frequency;
			scheduleGroupDocument.recurrenceRule.count = recurrenceRule.count;
			
			return scheduleGroupDocument;
		}

		public function get scheduledBy():String
		{
			return _scheduledBy;
		}

		public function get dateTimeScheduled():Date
		{
			return _dateTimeScheduled;
		}

		public function set dateTimeScheduled(value:Date):void
		{
			_dateTimeScheduled = value;
		}

		public function get dateTimeStart():Date
		{
			return _dateTimeStart;
		}
		
		public function set dateTimeStart(value:Date):void
		{
			_dateTimeStart = value;
			if (_moving)
			{
				dateTimeEnd = new Date(_dateTimeStart.time + (_dateTimeEndPreMove.time - _dateTimeStartPreMove.time));
			}
		}

		public function get dateTimeEnd():Date
		{
			return _dateTimeEnd;
		}
		
		public function set dateTimeEnd(value:Date):void
		{
			_dateTimeEnd = value;
		}

		public function get recurrenceRule():RecurrenceRule
		{
			return _recurrenceRule;
		}
		
		public function get scheduleModel():ScheduleModel
		{
			return _scheduleModel;
		}
		
		public function get dateTimeCenter():Date
		{
			return _dateTimeCenter;
		}
		
		public function set dateTimeCenter(value:Date):void
		{
			_dateTimeCenter = value;
			if (_moving)
			{
				dateTimeStart = new Date(_dateTimeCenter.time - (_dateTimeEndPreMove.time - _dateTimeStartPreMove.time) / 2);
			}			
		}
		
		public function get changed():Boolean
		{
			return _changed;
		}
		
		public function set changed(value:Boolean):void
		{
			_changed = value;
		}

		public function get moving():Boolean
		{
			return _moving;
		}
		
		public function set moving(value:Boolean):void
		{
			_moving = value;
		}
		
		public function get dateTimeCenterPreMove():Date
		{
			return _dateTimeCenterPreMove;
		}
		
		public function set dateTimeCenterPreMove(value:Date):void
		{
			_dateTimeCenterPreMove = value;
		}
		
		public function get dateTimeStartPreMove():Date
		{
			return _dateTimeStartPreMove;
		}
		
		public function set dateTimeStartPreMove(value:Date):void
		{
			_dateTimeStartPreMove = value;
		}
		
		public function get dateTimeEndPreMove():Date
		{
			return _dateTimeEndPreMove;
		}
		
		public function set dateTimeEndPreMove(value:Date):void
		{
			_dateTimeEndPreMove = value;
		}
		
		public function get containerMouseDownX():Number
		{
			return _containerMouseDownX;
		}
		
		public function set containerMouseDownX(value:Number):void
		{
			_containerMouseDownX = value;
		}
		
		public function get containerMouseDownY():Number
		{
			return _containerMouseDownY;
		}
		
		public function set containerMouseDownY(value:Number):void
		{
			_containerMouseDownY = value;
		}
		
		public function get yPreMove():Number
		{
			return _yPreMove;
		}
		
		public function set yPreMove(value:Number):void
		{
			_yPreMove = value;
		}
		
		public function get yPosition():Number
		{
			return _yPosition;
		}
		
		public function set yPosition(value:Number):void
		{
			_yPosition = value;
		}
				
		public function get scheduleGroupsStacked():Number
		{
			return _scheduleGroupsStacked;
		}
		
		public function set scheduleGroupsStacked(value:Number):void
		{
			_scheduleGroupsStacked = value;
		}
		
		public function get scheduleItemsStacked():Number
		{
			return _scheduleItemsStacked;
		}
		
		public function set scheduleItemsStacked(value:Number):void
		{
			_scheduleItemsStacked = value;
		}
		
		public function get stackingUpdated():Boolean
		{
			return _stackingUpdate;
		}
		
		public function set stackingUpdated(value:Boolean):void
		{
			_stackingUpdate = value;
		}
		
		public function get scheduleItemsCollection():ArrayCollection
		{
			return _scheduleItemsCollection;
		}
		
		public function addScheduleItem(scheduleItem:ScheduleItemBase):void
		{
			_scheduleItemsCollection.addItem(scheduleItem);
		}
	}
}