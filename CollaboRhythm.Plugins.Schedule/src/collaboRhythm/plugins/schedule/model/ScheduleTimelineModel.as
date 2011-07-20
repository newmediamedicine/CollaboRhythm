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
package collaboRhythm.plugins.schedule.model
{

	import collaboRhythm.plugins.schedule.shared.model.MoveData;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleGroup;
	import collaboRhythm.plugins.schedule.shared.view.ScheduleItemTimelineViewBase;
	import collaboRhythm.plugins.schedule.view.ScheduleGroupTimelineView;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrenceBase;

	[Bindable]
	public class ScheduleTimelineModel
	{
		private var _scheduleModel:ScheduleModel;
		private var _stackingUpdated:Boolean;
		private var _timeWidth:Number;
		private var _containerHeight:Number;

		public function ScheduleTimelineModel(scheduleModel:ScheduleModel)
		{
			_scheduleModel = scheduleModel;
			if (_scheduleModel.isInitialized)
			{
				determineStacking();
			}
		}

		private function storePreMoveInfo(scheduleItemOccurence:ScheduleItemOccurrenceBase, moveData:MoveData):void
		{
			scheduleItemOccurence.dateCenterPreMove = scheduleItemOccurence.dateCenter;
			scheduleItemOccurence.dateStartPreMove = scheduleItemOccurence.dateStart;
			scheduleItemOccurence.dateEndPreMove = scheduleItemOccurence.dateEnd;
			scheduleItemOccurence.containerMouseDownX = moveData.containerX;
			scheduleItemOccurence.containerMouseDownY = moveData.containerY;
			scheduleItemOccurence.containerWidth = moveData.containerWidth;
			scheduleItemOccurence.containerHeight = moveData.containerHeight;
			scheduleItemOccurence.yPreMove = scheduleItemOccurence.yPosition;
		}

		public function grabScheduleGroup(moveData:MoveData):void
		{
			var scheduleGroup:ScheduleGroup = _scheduleModel.scheduleGroupsHashMap[moveData.id];
			scheduleGroup.moving = true;
			storePreMoveInfo(scheduleGroup, moveData);
			stackingUpdated = false;
		}

		public function moveScheduleGroup(moveData:MoveData, scheduleFullViewWidth:Number,
										  scheduleFullViewHeight:Number, timeWidth:Number):void
		{
			var scheduleGroup:ScheduleGroup = _scheduleModel.scheduleGroupsHashMap[moveData.id];
			var scaleFactorX:Number = moveData.containerWidth / scheduleFullViewWidth;
			var scaleFactorY:Number = moveData.containerHeight / scheduleFullViewHeight;
			var hourChange:Number = Math.round(((moveData.containerX - scheduleGroup.containerMouseDownX) * scaleFactorX) / timeWidth);
			if (hourChange + scheduleGroup.dateStartPreMove.hours >= 0 && hourChange + scheduleGroup.dateEndPreMove.hours <= 23)
			{
				//dateTimeStart and dateTimeEnd are updated in this setter to prevent a state where are of them are not updated
				scheduleGroup.dateCenter = new Date(scheduleGroup.dateCenterPreMove.time + (hourChange * 60 * 60 * 1000));
			}
			scheduleGroup.yPosition = scheduleGroup.yPreMove + (moveData.containerY - scheduleGroup.containerMouseDownY) * scaleFactorY;
		}

		public function dropScheduleGroup(moveData:MoveData):void
		{
			var scheduleGroup:ScheduleGroup = _scheduleModel.scheduleGroupsHashMap[moveData.id];
			scheduleGroup.changed = true;
			if (scheduleGroup.scheduleItemsOccurrencesCollection.length == 1)
			{
				scheduleGroup.scheduleItemsOccurrencesCollection[0].moving = false;
			}
			determineStacking();
		}

		public function grabScheduleGroupSpotlight(moveData:MoveData):void
		{
			var scheduleGroup:ScheduleGroup = _scheduleModel.scheduleGroupsHashMap[moveData.id];
			storePreMoveInfo(scheduleGroup, moveData);
		}

		public function resizeScheduleGroupSpotlight(moveData:MoveData, scheduleFullViewWidth:Number,
													 scheduleFullViewHeight:Number, timeWidth:Number,
													 leftEdge:Boolean):void
		{
			var scheduleGroup:ScheduleGroup = _scheduleModel.scheduleGroupsHashMap[moveData.id];
			var scaleFactorX:Number = moveData.containerWidth / scheduleFullViewWidth;
			var scaleFactorY:Number = moveData.containerHeight / scheduleFullViewHeight;
			var hourChange:Number = Math.round(((moveData.containerX - scheduleGroup.containerMouseDownX) * scaleFactorX) / timeWidth);
			if (leftEdge)
			{
				hourChange *= -1;
			}
			var durationPreMove:Number = (scheduleGroup.dateEndPreMove.time - scheduleGroup.dateStartPreMove.time) / (60 * 60 * 1000);
			if (scheduleGroup.dateStartPreMove.hours - hourChange >= 0 && scheduleGroup.dateEndPreMove.hours + hourChange <= 23 && hourChange * 2 + durationPreMove <= 6 && hourChange * 2 + durationPreMove >= 2)
			{
				scheduleGroup.dateStart = new Date(scheduleGroup.dateStartPreMove.time - (hourChange * 60 * 60 * 1000));
				scheduleGroup.dateEnd = new Date(scheduleGroup.dateEndPreMove.time + (hourChange * 60 * 60 * 1000));
			}
		}

		public function dropScheduleGroupSpotlight(moveData:MoveData):void
		{
			var scheduleGroup:ScheduleGroup = _scheduleModel.scheduleGroupsHashMap[moveData.id];
			scheduleGroup.changed = true;
		}

		public function grabScheduleItemOccurrence(moveData:MoveData):void
		{
			var scheduleItemOccurrence:ScheduleItemOccurrence = _scheduleModel.scheduleItemOccurrencesHashMap[moveData.id];
			var oldScheduleGroup:ScheduleGroup;
			for each (var scheduleGroup:ScheduleGroup in _scheduleModel.scheduleGroupsCollection)
			{
				var scheduleItemOccurrenceIndex:int = scheduleGroup.scheduleItemsOccurrencesCollection.getItemIndex(scheduleItemOccurrence);
				if (scheduleItemOccurrenceIndex != -1)
				{
					oldScheduleGroup = scheduleGroup;
					scheduleItemOccurrence.dateStart = oldScheduleGroup.dateStart;
					scheduleItemOccurrence.dateEnd = oldScheduleGroup.dateEnd;
					var yPosition:int = oldScheduleGroup.yPosition + (oldScheduleGroup.scheduleItemsOccurrencesCollection.length - 1 - scheduleItemOccurrenceIndex) * (ScheduleItemTimelineViewBase.SCHEDULE_ITEM_TIMELINE_VIEW_HEIGHT + ScheduleGroupTimelineView.SCHEDULE_GROUP_TIMELINE_VIEW_BUFFER_WIDTH);
					scheduleItemOccurrence.moving = true;
					scheduleGroup.scheduleItemsOccurrencesCollection.removeItemAt(scheduleItemOccurrenceIndex);
					if (scheduleGroup.scheduleItemsOccurrencesCollection.length == 0)
					{
						var scheduleGroupIndex:int = _scheduleModel.scheduleGroupsCollection.getItemIndex(scheduleGroup);
						_scheduleModel.scheduleGroupsCollection.removeItemAt(scheduleGroupIndex);
						_scheduleModel.scheduleGroupsHashMap.remove(scheduleGroup.id);
						scheduleGroup = null;
					}
				}
			}
			var newScheduleGroup:ScheduleGroup = _scheduleModel.createScheduleGroup(scheduleItemOccurrence, true,
																					yPosition);
			newScheduleGroup.changed = true;
			storePreMoveInfo(newScheduleGroup, moveData);
			stackingUpdated = false;
		}

		private function transferScheduleItemOccurrences(fromScheduleGroup:ScheduleGroup,
														 toScheduleGroup:ScheduleGroup):void
		{
			var scheduleItemOccurrenceIndex:int = 0;
			for each (var scheduleItemOccurrence:ScheduleItemOccurrence in fromScheduleGroup.scheduleItemsOccurrencesCollection)
			{
				scheduleItemOccurrence.yPosition = fromScheduleGroup.yPosition + ScheduleGroupTimelineView.SCHEDULE_GROUP_TIMELINE_VIEW_TOP_WIDTH + (fromScheduleGroup.scheduleItemsOccurrencesCollection.length - 1 - scheduleItemOccurrenceIndex) * (ScheduleItemTimelineViewBase.SCHEDULE_ITEM_TIMELINE_VIEW_HEIGHT + ScheduleGroupTimelineView.SCHEDULE_GROUP_TIMELINE_VIEW_BUFFER_WIDTH);
				toScheduleGroup.scheduleItemsOccurrencesCollection.addItem(scheduleItemOccurrence);
				scheduleItemOccurrenceIndex += 1;
			}
			fromScheduleGroup.scheduleItemsOccurrencesCollection.removeAll();
		}

		public function determineStacking():void
		{
			_scheduleModel.scheduleGroupsCollection.source.sortOn("dateCenter", Array.DESCENDING);

			var previousScheduleGroup:ScheduleGroup;
			var stackNumber:Number = 0;

			var scheduleGroupsStacked:Number = 0;
			var scheduleItemsStacked:Number = 0;

			var scheduleGroupToRemove:ScheduleGroup;

			//TODO: fix static medication width reference;
			var scheduleItemsPerHour:Number = Math.ceil((ScheduleItemTimelineViewBase.SCHEDULE_ITEM_TIMELINE_VIEW_WIDTH - ScheduleItemTimelineViewBase.SCHEDULE_ITEM_TIMELINE_VIEW_PICTURE_WIDTH / 2 + ScheduleGroupTimelineView.SCHEDULE_GROUP_TIMELINE_VIEW_BUFFER_WIDTH) / timeWidth);

			for each (var scheduleGroup:ScheduleGroup in _scheduleModel.scheduleGroupsCollection)
			{
				if (previousScheduleGroup && previousScheduleGroup.dateCenter.hours == scheduleGroup.dateCenter.hours)
				{
					if (scheduleGroup.moving)
					{
						scheduleGroupToRemove = scheduleGroup;
						transferScheduleItemOccurrences(scheduleGroup, previousScheduleGroup);
						scheduleItemsStacked = stackItemsFromPreviousGroup(scheduleItemsStacked, previousScheduleGroup);
					}
					else
					{
						stackNumber -= 1;
						scheduleGroupToRemove = previousScheduleGroup;
						transferScheduleItemOccurrences(previousScheduleGroup, scheduleGroup);
					}
				}
				else if (!previousScheduleGroup || (previousScheduleGroup && previousScheduleGroup.dateCenter.hours - scheduleGroup.dateCenter.hours > scheduleItemsPerHour))
				{
					stackNumber = 0;
					scheduleItemsStacked = 0;
					scheduleGroupsStacked = 0;
				}
				else
				{
					stackNumber += 1;
					if (previousScheduleGroup.scheduleItemsOccurrencesCollection.length > 1 || (scheduleGroupToRemove && scheduleGroupToRemove == previousScheduleGroup))
					{
						scheduleGroupsStacked += 1;
					}
					scheduleItemsStacked = stackItemsFromPreviousGroup(scheduleItemsStacked, previousScheduleGroup);
				}

				scheduleGroup.stackNumber = stackNumber;
				scheduleGroup.scheduleGroupsStacked = scheduleGroupsStacked;
				scheduleGroup.scheduleItemsStacked = scheduleItemsStacked;

				if (scheduleGroup.moving)
				{
					scheduleGroup.moving = false;
				}

				previousScheduleGroup = scheduleGroup;
			}
			if (scheduleGroupToRemove)
			{
				var scheduleGroupIndex:int = _scheduleModel.scheduleGroupsCollection.getItemIndex(scheduleGroupToRemove);
				_scheduleModel.scheduleGroupsCollection.removeItemAt(scheduleGroupIndex);
				_scheduleModel.scheduleGroupsHashMap.remove(scheduleGroupToRemove.id);
			}
			stackingUpdated = true;
		}

		private function stackItemsFromPreviousGroup(scheduleItemsStacked:Number,
													 previousScheduleGroup:ScheduleGroup):Number
		{
			for each (var scheduleItemOccurrence:ScheduleItemOccurrence in previousScheduleGroup.scheduleItemsOccurrencesCollection)
			{
				scheduleItemsStacked += 1;
			}
			return scheduleItemsStacked
		}


		public function get stackingUpdated():Boolean
		{
			return _stackingUpdated;
		}

		public function set stackingUpdated(value:Boolean):void
		{
			_stackingUpdated = value;
		}

		public function get timeWidth():Number
		{
			return _timeWidth;
		}

		public function set timeWidth(value:Number):void
		{
			_timeWidth = value;
		}

		public function get containerHeight():Number
		{
			return _containerHeight;
		}

		public function set containerHeight(value:Number):void
		{
			_containerHeight = value;
		}
	}
}
