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
	import collaboRhythm.plugins.schedule.shared.model.ScheduleChanger;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleDetails;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleGroup;
	import collaboRhythm.plugins.schedule.view.ScheduleGroupTimelineView;
	import collaboRhythm.plugins.schedule.view.ScheduleItemOccurrenceTimelineView;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.MedicationFill;
	import collaboRhythm.shared.model.healthRecord.document.MedicationOrder;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.medications.MedicationTitrationHelper;

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

		private function storePreMoveInfo(scheduleGroup:ScheduleGroup, moveData:MoveData):void
		{
			scheduleGroup.dateCenterPreMove = scheduleGroup.dateCenter;
			scheduleGroup.dateStartPreMove = scheduleGroup.dateStart;
			scheduleGroup.dateEndPreMove = scheduleGroup.dateEnd;
			scheduleGroup.containerMouseDownX = moveData.containerX;
			scheduleGroup.containerMouseDownY = moveData.containerY;
			scheduleGroup.containerWidth = moveData.containerWidth;
			scheduleGroup.containerHeight = moveData.containerHeight;
			scheduleGroup.yPreMove = scheduleGroup.yPosition;
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
			var hourChange:Number = Math.round(((moveData.containerX - scheduleGroup.containerMouseDownX) *
					scaleFactorX) / timeWidth);
			if (hourChange + scheduleGroup.dateStartPreMove.hours >= 0 &&
					hourChange + scheduleGroup.dateEndPreMove.hours <= 23)
			{
				//dateTimeStart and dateTimeEnd are updated in this setter to prevent a state where are of them are not updated
				scheduleGroup.dateCenter = new Date(scheduleGroup.dateCenterPreMove.time +
						(hourChange * 60 * 60 * 1000));
			}
			scheduleGroup.yPosition = scheduleGroup.yPreMove +
					(moveData.containerY - scheduleGroup.containerMouseDownY) * scaleFactorY;
		}

		public function dropScheduleGroup(moveData:MoveData):void
		{
			var scheduleGroup:ScheduleGroup = _scheduleModel.scheduleGroupsHashMap[moveData.id];
//			_scheduleModel.updateScheduleItems(scheduleGroup);
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
			var hourChange:Number = Math.round(((moveData.containerX - scheduleGroup.containerMouseDownX) *
					scaleFactorX) / timeWidth);
			if (leftEdge)
			{
				hourChange *= -1;
			}
			var durationPreMove:Number = (scheduleGroup.dateEndPreMove.time - scheduleGroup.dateStartPreMove.time) /
					(60 * 60 * 1000);
			if (scheduleGroup.dateStartPreMove.hours - hourChange >= 0 &&
					scheduleGroup.dateEndPreMove.hours + hourChange <= 23 && hourChange * 2 + durationPreMove <= 6 &&
					hourChange * 2 + durationPreMove >= 2)
			{
				scheduleGroup.dateStart = new Date(scheduleGroup.dateStartPreMove.time - (hourChange * 60 * 60 * 1000));
				scheduleGroup.dateEnd = new Date(scheduleGroup.dateEndPreMove.time + (hourChange * 60 * 60 * 1000));
			}
		}

		public function dropScheduleGroupSpotlight(moveData:MoveData):void
		{
			var scheduleGroup:ScheduleGroup = _scheduleModel.scheduleGroupsHashMap[moveData.id];
//			_scheduleModel.updateScheduleItems(scheduleGroup);
		}

		public function grabScheduleItemOccurrence(moveData:MoveData):void
		{
			var scheduleItemOccurrence:ScheduleItemOccurrence = _scheduleModel.scheduleItemOccurrencesHashMap[moveData.id];
			if (!scheduleItemOccurrence)
			{
				throw new Error("The specified scheduleItemOccurrence does not exist in the HashMap.");
			}
			var oldScheduleGroup:ScheduleGroup;
			for each (var scheduleGroup:ScheduleGroup in _scheduleModel.scheduleGroupsCollection)
			{
				var scheduleItemOccurrenceIndex:int = scheduleGroup.scheduleItemsOccurrencesCollection.getItemIndex(scheduleItemOccurrence);
				if (scheduleItemOccurrenceIndex != -1)
				{
					oldScheduleGroup = scheduleGroup;
					scheduleItemOccurrence.dateStart = oldScheduleGroup.dateStart;
					scheduleItemOccurrence.dateEnd = oldScheduleGroup.dateEnd;
					var yPosition:int = oldScheduleGroup.yPosition +
							(oldScheduleGroup.scheduleItemsOccurrencesCollection.length - 1 -
									scheduleItemOccurrenceIndex) *
									(ScheduleItemOccurrenceTimelineView.SCHEDULE_ITEM_TIMELINE_VIEW_HEIGHT +
											ScheduleGroupTimelineView.SCHEDULE_GROUP_TIMELINE_VIEW_BUFFER_WIDTH);
					scheduleItemOccurrence.moving = true;

					_scheduleModel.removeScheduleItemOccurrenceFromGroup(scheduleGroup, scheduleItemOccurrenceIndex);
				}
			}
			var newScheduleGroup:ScheduleGroup = _scheduleModel.createScheduleGroup(scheduleItemOccurrence, true,
					yPosition);
			storePreMoveInfo(newScheduleGroup, moveData);
			stackingUpdated = false;
		}

		private function transferScheduleItemOccurrences(fromScheduleGroup:ScheduleGroup,
														 toScheduleGroup:ScheduleGroup):void
		{
			// Removed the group from _scheduleModel.scheduleGroupsHashMap before modifying the collection of
			// occurrences in the group because removing occurrences will invalidate the group's id
			_scheduleModel.scheduleGroupsHashMap.remove(fromScheduleGroup.id);
			var scheduleItemOccurrenceIndex:int = 0;
			for each (var scheduleItemOccurrence:ScheduleItemOccurrence in
					fromScheduleGroup.scheduleItemsOccurrencesCollection)
			{
				scheduleItemOccurrence.yPosition = fromScheduleGroup.yPosition +
						ScheduleGroupTimelineView.SCHEDULE_GROUP_TIMELINE_VIEW_TOP_WIDTH +
						(fromScheduleGroup.scheduleItemsOccurrencesCollection.length - 1 -
								scheduleItemOccurrenceIndex) *
								(ScheduleItemOccurrenceTimelineView.SCHEDULE_ITEM_TIMELINE_VIEW_HEIGHT +
										ScheduleGroupTimelineView.SCHEDULE_GROUP_TIMELINE_VIEW_BUFFER_WIDTH);
				toScheduleGroup.scheduleItemsOccurrencesCollection.addItem(scheduleItemOccurrence);
				scheduleItemOccurrenceIndex += 1;
			}
			fromScheduleGroup.scheduleItemsOccurrencesCollection.removeAll();
		}

		/**
		 * Updates the stacking of all schedule groups. This involves (1) combining groups together that have the same
		 * time and (2) updating the stacking properties of each group so that the layout of the groups can be updated.
		 * The groups are first sorted in descending order (corresponding to the order from right to left).
		 */
		public function determineStacking():void
		{
			_scheduleModel.scheduleGroupsCollection.source.sortOn("dateCenterValue", Array.DESCENDING);

			var previousScheduleGroup:ScheduleGroup;
			var stackNumber:Number = 0;

			var scheduleGroupsStacked:Number = 0;
			var scheduleItemsStacked:Number = 0;

			var scheduleGroupToRemove:ScheduleGroup;

			//TODO: fix static medication width reference;
			var scheduleItemsPerHour:Number = Math.ceil((ScheduleItemOccurrenceTimelineView.SCHEDULE_ITEM_TIMELINE_VIEW_WIDTH -
					ScheduleItemOccurrenceTimelineView.SCHEDULE_ITEM_TIMELINE_VIEW_PICTURE_WIDTH / 2 +
					ScheduleGroupTimelineView.SCHEDULE_GROUP_TIMELINE_VIEW_BUFFER_WIDTH) / timeWidth);

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
				else if (!previousScheduleGroup ||
						(previousScheduleGroup &&
								previousScheduleGroup.dateCenter.hours - scheduleGroup.dateCenter.hours >
										scheduleItemsPerHour))
				{
					stackNumber = 0;
					scheduleItemsStacked = 0;
					scheduleGroupsStacked = 0;
				}
				else
				{
					stackNumber += 1;
					if (previousScheduleGroup.scheduleItemsOccurrencesCollection.length > 1 ||
							(scheduleGroupToRemove && scheduleGroupToRemove == previousScheduleGroup))
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
				// Note that scheduleGroupToRemove was removed from _scheduleModel.scheduleGroupsHashMap by transferScheduleItemOccurrences
				// because we needed to remove it before modifying the collection of occurrences in the group to avoid
				// changing the group's id.
			}
			stackingUpdated = true;
		}

		private function stackItemsFromPreviousGroup(scheduleItemsStacked:Number,
													 previousScheduleGroup:ScheduleGroup):Number
		{
			for each (var scheduleItemOccurrence:ScheduleItemOccurrence in
					previousScheduleGroup.scheduleItemsOccurrencesCollection)
			{
				scheduleItemsStacked += 1;
			}
			return scheduleItemsStacked
		}

		public function unscheduleItem(moveData:MoveData):void
		{
			stackingUpdated = false;

			var scheduleItemOccurrence:ScheduleItemOccurrence = _scheduleModel.scheduleItemOccurrencesHashMap[moveData.id];
			if (scheduleItemOccurrence)
			{
				for each (var scheduleGroup:ScheduleGroup in _scheduleModel.scheduleGroupsCollection)
				{
					var scheduleItemOccurrenceIndex:int = scheduleGroup.scheduleItemsOccurrencesCollection.getItemIndex(scheduleItemOccurrence);
					if (scheduleItemOccurrenceIndex != -1)
					{
						_scheduleModel.removeScheduleItemOccurrenceFromGroup(scheduleGroup,
								scheduleItemOccurrenceIndex);
					}
				}

				// If there is no data for the scheduleItem, it can be voided. Otherwise, the recurrenceRule of the scheduleItem should be changed as appropriate
				var scheduleChanger:ScheduleChanger = new ScheduleChanger(_scheduleModel.record, _scheduleModel.accountId, _scheduleModel.currentDateSource);
				scheduleChanger.endSchedule(scheduleItemOccurrence.scheduleItem, scheduleItemOccurrence, true);
			}

			stackingUpdated = true;
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

		public function save():void
		{
			for each (var scheduleGroup:ScheduleGroup in _scheduleModel.scheduleGroupsCollection)
			{
				_scheduleModel.updateScheduleItems(scheduleGroup);
			}
			_scheduleModel.saveChangesToRecord();
		}
	}
}
