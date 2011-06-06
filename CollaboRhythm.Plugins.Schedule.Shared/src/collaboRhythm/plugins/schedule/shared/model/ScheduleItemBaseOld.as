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


    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemTimelineViewBase;
	import collaboRhythm.plugins.schedule.shared.view.ScheduleItemClockViewBase;
	
	[Bindable]
	public class ScheduleItemBaseOld
	{
//		private var _scheduleModel:ScheduleModel;
		private var _documentID:String;
		private var _scheduled:Boolean = false;
		private var _hour:Number = 9;
		private var _adherenceGroup:AdherenceGroup;
		private var _xPosition:Number = 0;
		private var _yBottomPosition:Number = 0;
		private var _yMovement:Number = 0;		
		private var _stackNumber:Number = 0;
		private var _scheduleItemsStacked:Number = 0;
		private var _adherenceGroupsStacked:Number = 0;
		private var _stackingUpdated:Boolean = false;
		private var _active:Boolean = false;
		private var _firstMove:Boolean = false;
		private var _collaborationColor:String = "0xFFFFFF";
		
//		public function get scheduleModel():ScheduleModel
//		{
//			return _scheduleModel;
//		}
//
//		public function set scheduleModel(value:ScheduleModel):void
//		{
//			_scheduleModel = value;
//		}
		
		public function get yBottomPosition():Number
		{
			return _yBottomPosition;
		}
		
		public function set yBottomPosition(value:Number):void
		{
			_yBottomPosition = value;
		}
		
		public function get xPosition():Number
		{
			return _xPosition;
		}
		
		public function set xPosition(value:Number):void
		{
			_xPosition = value;
		}
		
		public function ScheduleItemBaseOld():void
		{
		}
		
		public function get documentID():String
		{
			return _documentID;
		}
		
		private function set documentID(value:String):void
		{
			_documentID = value;
		}
		
		public function get scheduled():Boolean
		{
			return _scheduled;
		}
		
		public function set scheduled(value:Boolean):void
		{
			_scheduled = value;
		}
		
		public function get hour():Number
		{
			return _hour;
		}
		
		public function set hour(value:Number):void
		{
			_hour = value;
		}
		
		public function get adherenceGroup():AdherenceGroup
		{
			return _adherenceGroup;
		}
		
		public function set adherenceGroup(value:AdherenceGroup):void
		{
			_adherenceGroup = value;
		}
		
		public function get yMovement():Number
		{
			return _yMovement;
		}
		
		public function set yMovement(value:Number):void
		{
			_yMovement = value;
		}
		
		public function get stackNumber():Number
		{
			return _stackNumber;
		}
		
		public function set stackNumber(value:Number):void
		{
			_stackNumber = value;
		}
		
		public function get scheduleItemsStacked():Number
		{
			return _scheduleItemsStacked;
		}
		
		public function set scheduleItemsStacked(value:Number):void
		{
			_scheduleItemsStacked = value;
		}
		
		public function get adherenceGroupsStacked():Number
		{
			return _adherenceGroupsStacked;
		}
		
		public function set adherenceGroupsStacked(value:Number):void
		{
			_adherenceGroupsStacked = value;
		}
		
		public function get stackingUpdated():Boolean
		{
			return _stackingUpdated;
		}
		
		public function set stackingUpdated(value:Boolean):void
		{
			_stackingUpdated = value;
		}
		
		public function get active():Boolean
		{
			return _active;
		}
		
		public function set active(value:Boolean):void
		{
			_active = value;
		}
		
		public function get firstMove():Boolean
		{
			return _firstMove;
		}
		
		public function set firstMove(value:Boolean):void
		{
			_firstMove = value;
		}
		
		public function get collaborationColor():String
		{
			return _collaborationColor;
		}
		
		public function set collaborationColor(value:String):void
		{
			_collaborationColor = value;
		}
		
		public function updateHour(newHour:Number):void
		{
			if (newHour < 1)
			{
				hour = 1;
			}
			else if (newHour > 24)
			{
				hour = 24;
			}
			else
			{
				hour = newHour;
			}
		}
		
		public function createScheduleItemWidgetView():ScheduleItemClockViewBase
		{
			// to be implemented by subclasses
			var scheduleItemWidgetView:ScheduleItemClockViewBase = new ScheduleItemClockViewBase();
			return scheduleItemWidgetView;
		}
		
		public function createScheduleItemFullView():ScheduleItemTimelineViewBase
		{
			// to be implemented by subclasses
			var fullScheduleItemView:ScheduleItemTimelineViewBase = new ScheduleItemTimelineViewBase();
			return fullScheduleItemView;
		}
	}
}