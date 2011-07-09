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

    import collaboRhythm.plugins.schedule.shared.model.*;
	import collaboRhythm.plugins.schedule.shared.view.ScheduleItemTimelineViewBase;
	import collaboRhythm.plugins.schedule.view.ScheduleGroupTimelineView;
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
    import collaboRhythm.shared.model.EquipmentModel;
    import collaboRhythm.shared.model.EquipmentScheduleItem;
    import collaboRhythm.shared.model.MedicationScheduleItem;
    import collaboRhythm.shared.model.MedicationsModel;
    import collaboRhythm.shared.model.Record;
    import collaboRhythm.shared.model.ScheduleItemBase;
    import collaboRhythm.shared.model.ScheduleItemOccurrence;
    import collaboRhythm.shared.model.ScheduleItemOccurrenceBase;
    import collaboRhythm.shared.model.User;
    import collaboRhythm.shared.model.services.IComponentContainer;
    import collaboRhythm.shared.model.services.ICurrentDateSource;
    import collaboRhythm.shared.model.services.WorkstationKernel;

    import flash.desktop.NativeApplication;
    import flash.events.InvokeEvent;
    import flash.net.URLVariables;

    import flash.utils.Dictionary;
    import flash.utils.getQualifiedClassName;

    import j2as3.collection.HashMap;

    import mx.binding.utils.BindingUtils;

    import mx.collections.ArrayCollection;
    import mx.logging.ILogger;
    import mx.logging.Log;

    [Bindable]
    public class ScheduleModel
    {
        private var _isInitialized:Boolean = false;
        private var _scheduleGroupsHashMap:HashMap = new HashMap();
        private var _scheduleGroupsCollection:ArrayCollection = new ArrayCollection();
        private var _scheduleItemOccurrencesHashMap:HashMap = new HashMap();
        private var _currentScheduleGroup:ScheduleGroup;
        private var _timeWidth:Number;
        private var _containerHeight:Number;
        private var _stackingUpdated:Boolean = false;

        private var _logger:ILogger;

        private var _locked:Boolean = false;

        private var _currentDateSource:ICurrentDateSource;
        public static const SCHEDULE_KEY:String = "schedule";
        private var _viewFactory:IScheduleViewFactory;
        private var _record:Record;

        public function ScheduleModel(componentContainer:IComponentContainer, record:Record)
        {
            _record = record;

            BindingUtils.bindSetter(medicationOrdersModelStitchedHandler, _record.medicationOrdersModel, "isStitched");
            BindingUtils.bindSetter(medicationScheduleItemsModelStitchedHandler, _record.medicationScheduleItemsModel,
                                    "isStitched");
            BindingUtils.bindSetter(equipmentModelStitchedHandler, _record.equipmentModel, "isStitched");
            BindingUtils.bindSetter(equipmentScheduleItemsModelStitchedHandler, _record.equipmentScheduleItemsModel,
                                    "isStitched");
            BindingUtils.bindSetter(adherenceItemsModelStitchedHandler, _record.adherenceItemsModel, "isStitched");

            _logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));

            _currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
            _viewFactory = new MasterScheduleViewFactory(componentContainer);
        }

        private function medicationOrdersModelStitchedHandler(isStitched:Boolean):void
        {
            areNecessaryClassesStitched();
        }

        private function medicationScheduleItemsModelStitchedHandler(isStitched:Boolean):void
        {
            areNecessaryClassesStitched();
        }

        private function equipmentScheduleItemsModelStitchedHandler(isStitched:Boolean):void
        {
            areNecessaryClassesStitched();
        }

        private function equipmentModelStitchedHandler(isStitched:Boolean):void
        {
            areNecessaryClassesStitched();
        }

        private function adherenceItemsModelStitchedHandler(isStitched:Boolean):void
        {
            areNecessaryClassesStitched();
        }

        private function areNecessaryClassesStitched():void
        {
            if (_record.medicationOrdersModel.isStitched && _record.medicationScheduleItemsModel.isStitched && _record.equipmentModel.isStitched && _record.equipmentScheduleItemsModel.isStitched && _record.adherenceItemsModel.isStitched)
            {
                var dateNow:Date = _currentDateSource.now();
                var dateStart:Date = new Date(dateNow.getFullYear(), dateNow.getMonth(), dateNow.getDate());
                var dateEnd:Date = new Date(dateNow.getFullYear(), dateNow.getMonth(), dateNow.getDate(), 23, 59);
                for each (var medicationScheduleItem:MedicationScheduleItem in _record.medicationScheduleItemsModel.medicationScheduleItems)
                {
                    var medicationScheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence> = medicationScheduleItem.getScheduleItemOccurrences(dateStart,
                                                                                                                                                    dateEnd);
                    for each (var medicationScheduleItemOccurrence:ScheduleItemOccurrence in medicationScheduleItemOccurrencesVector)
                    {
                        medicationScheduleItemOccurrence.scheduleItem = medicationScheduleItem;
                        addToScheduleGroup(medicationScheduleItemOccurrence);
                    }
                }
                for each (var equipmentScheduleItem:EquipmentScheduleItem in _record.equipmentScheduleItemsModel.equipmentScheduleItems)
                {
                    var equipmentScheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence> = equipmentScheduleItem.getScheduleItemOccurrences(dateStart,
                                                                                                                                                  dateEnd);
                    for each (var equipmentScheduleItemOccurrence:ScheduleItemOccurrence in equipmentScheduleItemOccurrencesVector)
                    {
                        equipmentScheduleItemOccurrence.scheduleItem = equipmentScheduleItem;
                        addToScheduleGroup(equipmentScheduleItemOccurrence);
                    }
                }
                determineStacking();
                isInitialized = true;

                NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);
            }
        }


        private function onInvoke(event:InvokeEvent):void
        {
            if (event.arguments.length != 0)
            {
                var urlString:String = event.arguments[0];
                var urlVariablesString:String = urlString.split("//")[1];
                var urlVariables:URLVariables = new URLVariables(urlVariablesString);
                _logger.debug(urlVariables.systolic);

                createBloodPressureAdherenceItem();
            }
        }

        private function createBloodPressureAdherenceItem():void
        {
            var closestScheduleItemOccurrence:ScheduleItemOccurrence;
            for each (var scheduleItemOccurrence:ScheduleItemOccurrence in _scheduleItemOccurrencesHashMap)
            {
                if (scheduleItemOccurrence.scheduleItem.schedueItemType() == EquipmentScheduleItem.EQUIPMENT)
                {
                    if (_currentDateSource.now() > scheduleItemOccurrence.dateStart && _currentDateSource.now() < scheduleItemOccurrence.dateEnd)
                    {
                        closestScheduleItemOccurrence = scheduleItemOccurrence;
                        break;
                    }
                    else
                    {
                        if (closestScheduleItemOccurrence)
                        {
                            if ((_currentDateSource.now().time - scheduleItemOccurrence.dateEnd.time < _currentDateSource.now().time - closestScheduleItemOccurrence.dateEnd.time)
                             || (scheduleItemOccurrence.dateStart.time - _currentDateSource.now().time < closestScheduleItemOccurrence.dateStart.time - _currentDateSource.now().time))
                            {
                                closestScheduleItemOccurrence = scheduleItemOccurrence;
                            }
                        }
                        else
                        {
                            closestScheduleItemOccurrence = scheduleItemOccurrence;
                        }
                    }
                }
            }
            var adherenceItem:AdherenceItem = new AdherenceItem();
            var name:CodedValue = new CodedValue();
            name.text = "Fora D40b";
            //TODO: add vital sign
            adherenceItem.init(name, "rpoole@records.media.mit.edu", _currentDateSource.now(),
                               closestScheduleItemOccurrence.recurrenceIndex, true);
            closestScheduleItemOccurrence.adherenceItem = adherenceItem;
        }

        private function addToScheduleGroup(scheduleItemOccurrence:ScheduleItemOccurrence):void
        {
            var isMatchingScheduleGroup:Boolean = false;
            for each (var scheduleGroup:ScheduleGroup in _scheduleGroupsCollection)
            {
                if (isMatchingTime(scheduleGroup, scheduleItemOccurrence))
                {
                    scheduleGroup.addScheduleItemOccurrence(scheduleItemOccurrence);
                    isMatchingScheduleGroup = true;
                }
            }
            if (!isMatchingScheduleGroup)
            {
                createScheduleGroup(scheduleItemOccurrence, false);
            }
            _scheduleItemOccurrencesHashMap[scheduleItemOccurrence.scheduleItem.id + scheduleItemOccurrence.recurrenceIndex] = scheduleItemOccurrence;
        }

        private function createScheduleGroup(scheduleItemOccurrence:ScheduleItemOccurrence, moving:Boolean,
                                             yPosition:int = NaN):ScheduleGroup
        {
            var scheduleGroup:ScheduleGroup = new ScheduleGroup(scheduleItemOccurrence.dateStart,
                                                                scheduleItemOccurrence.dateEnd);
            scheduleGroup.addScheduleItemOccurrence(scheduleItemOccurrence);
            scheduleGroup.moving = moving;
            if (yPosition)
            {
                scheduleGroup.yPosition = yPosition;
            }
            _scheduleGroupsCollection.addItem(scheduleGroup);
            // TODO: use a GUID for the scheduleGroup so it will work with remote collaboration
            scheduleGroup.id = scheduleItemOccurrence.scheduleItem.id + scheduleItemOccurrence.recurrenceIndex + _scheduleGroupsHashMap.keys.length;
            _scheduleGroupsHashMap[scheduleGroup.id] = scheduleGroup;

            return scheduleGroup;
        }

        private function isMatchingTime(scheduleGroup:ScheduleGroup,
                                        scheduleItemOccurrence:ScheduleItemOccurrence):Boolean
        {
            return (scheduleGroup.dateStart.hoursUTC == scheduleItemOccurrence.dateStart.hoursUTC &&
                    scheduleGroup.dateStart.minutesUTC == scheduleItemOccurrence.dateStart.minutesUTC &&
                    scheduleGroup.dateStart.secondsUTC == scheduleItemOccurrence.dateStart.secondsUTC &&
                    scheduleGroup.dateEnd.hoursUTC == scheduleItemOccurrence.dateEnd.hoursUTC &&
                    scheduleGroup.dateEnd.minutesUTC == scheduleItemOccurrence.dateEnd.minutesUTC &&
                    scheduleGroup.dateEnd.secondsUTC == scheduleItemOccurrence.dateEnd.secondsUTC);
        }

        public function get isInitialized():Boolean
        {
            return _isInitialized;
        }

        public function set isInitialized(value:Boolean):void
        {
            _isInitialized = value;
        }

        public function get scheduleGroupsCollection():ArrayCollection
        {
            return _scheduleGroupsCollection;
        }

        public function get currentScheduleGroup():ScheduleGroup
        {
            return _currentScheduleGroup;
        }

        public function set currentScheduleGroup(value:ScheduleGroup):void
        {
            _currentScheduleGroup = value;
        }

        public function get timeWidth():Number
        {
            return _timeWidth;
        }

        public function set timeWidth(value:Number):void
        {
            _timeWidth = value;
        }

        public function get stackingUpdated():Boolean
        {
            return _stackingUpdated;
        }

        public function set stackingUpdated(value:Boolean):void
        {
            _stackingUpdated = value;
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
            var scheduleGroup:ScheduleGroup = _scheduleGroupsHashMap[moveData.id];
            scheduleGroup.moving = true;
            storePreMoveInfo(scheduleGroup, moveData);
            stackingUpdated = false;
        }

        public function moveScheduleGroup(moveData:MoveData, scheduleFullViewWidth:Number,
                                          scheduleFullViewHeight:Number, timeWidth:Number):void
        {
            var scheduleGroup:ScheduleGroup = _scheduleGroupsHashMap[moveData.id];
            var scaleFactorX:Number = moveData.containerWidth / scheduleFullViewWidth;
            var scaleFactorY:Number = moveData.containerHeight / scheduleFullViewHeight;
            var hourChange:Number = Math.round(((moveData.containerX - scheduleGroup.containerMouseDownX) * scaleFactorX) / timeWidth);
            if (hourChange + scheduleGroup.dateStartPreMove.hours >= 0 && hourChange + scheduleGroup.dateEndPreMove.hours <= 23)
            {
                //dateTimeStart and dateTimeEnd are updated in this setter to prevent a state where are of them are not updated
                scheduleGroup.dateCenter = new Date(scheduleGroup.dateCenterPreMove.time + (hourChange * 60 * 60 * 1000));
            }
            scheduleGroup.yPosition = scheduleGroup.yPreMove + (moveData.containerY - scheduleGroup.containerMouseDownY) * scaleFactorY;
//			var yChange:Number = (moveData.y - scheduleGroup.mouseDownY) * scaleFactorY;
//			if (scheduleGroup.yPreMove + yChange >= 0 && scheduleGroup.yPreMove + yChange <= scheduleFullViewHeight)
//			{
//				scheduleGroup.y = scheduleGroup.yPreMove + yChange;
//			}
        }

        public function dropScheduleGroup(moveData:MoveData):void
        {
            var scheduleGroup:ScheduleGroup = _scheduleGroupsHashMap[moveData.id];
            scheduleGroup.changed = true;
            if (scheduleGroup.scheduleItemsOccurrencesCollection.length == 1)
            {
                scheduleGroup.scheduleItemsOccurrencesCollection[0].moving = false;
            }
            determineStacking();
        }

        public function grabScheduleGroupSpotlight(moveData:MoveData):void
        {
            var scheduleGroup:ScheduleGroup = _scheduleGroupsHashMap[moveData.id];
            storePreMoveInfo(scheduleGroup, moveData);
        }

        public function resizeScheduleGroupSpotlight(moveData:MoveData, scheduleFullViewWidth:Number,
                                                     scheduleFullViewHeight:Number, timeWidth:Number,
                                                     leftEdge:Boolean):void
        {
            var scheduleGroup:ScheduleGroup = _scheduleGroupsHashMap[moveData.id];
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
            var scheduleGroup:ScheduleGroup = _scheduleGroupsHashMap[moveData.id];
            scheduleGroup.changed = true;
        }

        public function grabScheduleItemOccurrence(moveData:MoveData):void
        {

            var scheduleItemOccurrence:ScheduleItemOccurrence = _scheduleItemOccurrencesHashMap[moveData.id];
            var oldScheduleGroup:ScheduleGroup;
            for each (var scheduleGroup:ScheduleGroup in scheduleGroupsCollection)
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
                        var scheduleGroupIndex:int = scheduleGroupsCollection.getItemIndex(scheduleGroup);
                        scheduleGroupsCollection.removeItemAt(scheduleGroupIndex);
                        _scheduleGroupsHashMap.remove(scheduleGroup.id);
                        scheduleGroup = null;
                    }
                }
            }
            var newScheduleGroup:ScheduleGroup = createScheduleGroup(scheduleItemOccurrence, true, yPosition);
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
        }

        public function determineStacking():void
        {
            scheduleGroupsCollection.source.sortOn("dateCenter", Array.DESCENDING);

            var previousScheduleGroup:ScheduleGroup;
            var stackNumber:Number = 0;

            var scheduleGroupsStacked:Number = 0;
            var scheduleItemsStacked:Number = 0;

            var scheduleGroupToRemove:ScheduleGroup;


            var previousStackHasAdherenceGroup:Boolean = false;
            //TODO: fix static medication width reference;
            var scheduleItemsPerHour:Number = Math.ceil((ScheduleItemTimelineViewBase.SCHEDULE_ITEM_TIMELINE_VIEW_WIDTH - ScheduleItemTimelineViewBase.SCHEDULE_ITEM_TIMELINE_VIEW_PICTURE_WIDTH / 2 + ScheduleGroupTimelineView.SCHEDULE_GROUP_TIMELINE_VIEW_BUFFER_WIDTH) / timeWidth);

            for each (var scheduleGroup:ScheduleGroup in scheduleGroupsCollection)
            {
                if (previousScheduleGroup && previousScheduleGroup.dateCenter.hours == scheduleGroup.dateCenter.hours)
                {
                    if (scheduleGroup.moving)
                    {
                        scheduleGroupToRemove = scheduleGroup;
                        transferScheduleItemOccurrences(scheduleGroup, previousScheduleGroup);
                    }
                    else
                    {
                        scheduleGroupToRemove = previousScheduleGroup;
                        for each (var scheduleItemOccurrence:ScheduleItemOccurrence in previousScheduleGroup.scheduleItemsOccurrencesCollection)
                        {
                            scheduleItemsStacked -= 1;
                        }
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
                    if (previousStackHasAdherenceGroup)
                    {
                        scheduleGroupsStacked += 1;
                    }
                }

                previousScheduleGroup = scheduleGroup;

                scheduleGroup.stackNumber = stackNumber;
                scheduleGroup.scheduleGroupsStacked = scheduleGroupsStacked;
                scheduleGroup.scheduleItemsStacked = scheduleItemsStacked;

                previousStackHasAdherenceGroup = (scheduleGroup.scheduleItemsOccurrencesCollection.length > 1);

                for each (var scheduleItemOccurrence:ScheduleItemOccurrence in scheduleGroup.scheduleItemsOccurrencesCollection)
                {
                    scheduleItemsStacked += 1;
                }
                if (scheduleGroup.moving)
                {
                    scheduleGroup.moving = false;
                }
            }
            if (scheduleGroupToRemove)
            {
                var scheduleGroupIndex:int = scheduleGroupsCollection.getItemIndex(scheduleGroupToRemove);
                scheduleGroupsCollection.removeItemAt(scheduleGroupIndex);
                _scheduleGroupsHashMap.remove(scheduleGroupToRemove.id);
            }
            stackingUpdated = true;
        }

        public function get locked():Boolean
        {
            return _locked;
        }

        public function set locked(value:Boolean):void
        {
            _locked = value;
        }

        public function get now():Date
        {
            return _currentDateSource.now();
        }

        public function get viewFactory():IScheduleViewFactory
        {
            return _viewFactory;
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