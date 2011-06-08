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
    import collaboRhythm.shared.model.AdherenceItem;
    import collaboRhythm.shared.model.EquipmentModel;
    import collaboRhythm.shared.model.EquipmentScheduleItem;
    import collaboRhythm.shared.model.MedicationScheduleItem;
    import collaboRhythm.shared.model.MedicationsModel;
    import collaboRhythm.shared.model.ScheduleItemBase;
    import collaboRhythm.shared.model.User;
    import collaboRhythm.shared.model.services.IComponentContainer;
    import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;
	
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

    import j2as3.collection.HashMap;

    import mx.collections.ArrayCollection;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	[Bindable]
	public class ScheduleModel
	{
		public static const SCHEDULE_CLOCK_VIEW:String = "ScheduleClockView";
		public static const SCHEDULE_GROUP_REPORTING_VIEW:String = "ScheduleGroupReportingView";
		public static const BLOOD_PRESSURE_REPORTING_VIEW:String = "BloodPressureReportingView";
		
//		private var _user:User;
		private var _isInitialized:Boolean = false;
		private var _scheduleGroupsReportXML:XML;
        private var _scheduleGroupsHashMap:HashMap = new HashMap();
		private var _scheduleGroupsCollection:ArrayCollection = new ArrayCollection();
		private var _currentWidgetView:String = SCHEDULE_CLOCK_VIEW;
		private var _currentScheduleGroup:ScheduleGroup;
		private var _timeWidth:Number;
		private var _stackingUpdated:Boolean = false;
		
		private var logger:ILogger;
		
		private var _closeDrawer:Boolean = true;
		private var _drawerX:Number = -340;
		private var _drawerColor:String = "0xFFFFFF";
		private var _scheduleItemsCollection:ArrayCollection = new ArrayCollection();
		private var _scheduleItemsDictionary:Dictionary = new Dictionary();
		private var _adherenceGroupsCollection:ArrayCollection = new ArrayCollection();
		private var _adherenceGroupsVector:Vector.<AdherenceGroup> = new Vector.<AdherenceGroup>(24);

        private var _medicationsModel:MedicationsModel;
        private var _equipmentModel:EquipmentModel;

		private var _locked:Boolean = false;

		private var _currentDateSource:ICurrentDateSource;
		public static const SCHEDULE_KEY:String = "schedule";
        private var _viewFactory:IScheduleViewFactory;

		public function ScheduleModel(componentContainer:IComponentContainer)
		{
			logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
//			_user = user;
//			_medicationsModel = medicationsModel;
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
//			if (!_medicationsModel.initialized)
//			{
//				BindingUtils.bindSetter(addMedicationsToScheduleItems, _medicationsModel, "initialized");
//			}
//			else
//			{
//				addMedicationsToScheduleItems(true);
//			}
            _viewFactory = new MasterScheduleViewFactory(componentContainer);
		}

        public function medicationsModelInitializedHandler(medicationsModel:MedicationsModel):void
        {
            _medicationsModel = medicationsModel;
            for each (var medicationScheduleItem:MedicationScheduleItem in medicationsModel.medicationScheduleItems)
            {
                addToScheduleGroup(medicationScheduleItem);
            }
            isInitializedCheck();
        }

        public function equipmentModelInitializedHandler(equipmentModel:EquipmentModel):void
        {
            _equipmentModel = equipmentModel;
            for each (var equipmentScheduleItem:EquipmentScheduleItem in equipmentModel.equipmentScheduleItems)
            {
                addToScheduleGroup(equipmentScheduleItem);
            }
            isInitializedCheck();
        }

        private function isInitializedCheck():void
        {
            if (_medicationsModel && _equipmentModel)
            {
                isInitialized = true;
                determineStacking();
            }
        }

        private function addToScheduleGroup(scheduleItem:ScheduleItemBase):void
        {
            var isMatchingScheduleGroup:Boolean = false;
            for each (var scheduleGroup:ScheduleGroup in _scheduleGroupsCollection)
            {
                if (isMatchingTime(scheduleGroup, scheduleItem))
                {
                    scheduleGroup.addScheduleItem(scheduleItem);
                    isMatchingScheduleGroup = true;
                }
            }
            if (!isMatchingScheduleGroup)
            {
                var scheduleGroup:ScheduleGroup = new ScheduleGroup(this, scheduleItem.dateStart, scheduleItem.dateEnd);
                scheduleGroup.addScheduleItem(scheduleItem);
                _scheduleGroupsCollection.addItem(scheduleGroup);
                // TODO: use a GUID for the scheduleGroup so it will work with remote collaboration
                _scheduleGroupsHashMap[scheduleItem.id] = scheduleGroup;
                scheduleGroup.id = scheduleItem.id;
            }
        }

        private function isMatchingTime(scheduleGroup:ScheduleGroup, scheduleItem:ScheduleItemBase):Boolean
        {
            return (scheduleGroup.dateTimeStart.hoursUTC == scheduleItem.dateStart.hoursUTC &&
                scheduleGroup.dateTimeStart.minutesUTC == scheduleItem.dateStart.minutesUTC &&
                scheduleGroup.dateTimeStart.secondsUTC == scheduleItem.dateStart.secondsUTC &&
                scheduleGroup.dateTimeEnd.hoursUTC == scheduleItem.dateEnd.hoursUTC &&
                scheduleGroup.dateTimeEnd.minutesUTC == scheduleItem.dateEnd.minutesUTC &&
                scheduleGroup.dateTimeEnd.secondsUTC == scheduleItem.dateEnd.secondsUTC);
        }

		public function get isInitialized():Boolean
		{
			return _isInitialized;
		}
		
		public function set isInitialized(value:Boolean):void
		{
			_isInitialized = value;
		}

		public function get scheduleGroupsReportXML():XML
		{
			return _scheduleGroupsReportXML;
		}

		public function set scheduleGroupsReportXML(value:XML):void
		{
			_scheduleGroupsReportXML = value;
			createScheduleGroupsCollection();
			determineStacking();
			_isInitialized = true;
		}
		
		public function get scheduleGroupsCollection():ArrayCollection
		{
			return _scheduleGroupsCollection;
		}
		
		public function get currentWidgetView():String
		{
			return _currentWidgetView;
		}
		
		public function set currentWidgetView(value:String):void
		{
			_currentWidgetView = value;
		}
		
		public function get currentScheduleGroup():ScheduleGroup
		{
			return _currentScheduleGroup;
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
		
		private function createScheduleGroupsCollection():void
		{
//			for each (var scheduleGroupReport:XML in _scheduleGroupsReportXML.Report)
//			{
//				var scheduleGroup:ScheduleGroup = new ScheduleGroup(this, scheduleGroupReport);
//				_user.registerDocument(scheduleGroup, scheduleGroup);
//				_scheduleGroupsCollection.addItem(scheduleGroup);
//			}
		}
		
		public function openScheduleGroupReportingView(scheduleGroup:ScheduleGroup):void
		{
			_currentScheduleGroup = scheduleGroup;
//			currentWidgetView = SCHEDULE_GROUP_REPORTING_VIEW;
		}
		
		public function closeScheduleGroupReportingView():void
		{
//			currentWidgetView = SCHEDULE_CLOCK_VIEW;
		}
		
		public function createAdherenceItem(scheduleGroup:ScheduleGroup, scheduleItem:ScheduleItemBase, adherenceItem:AdherenceItem):void
		{
//			scheduleItem.adherenceItem = adherenceItem;
//			var reportingCompleted:Boolean = true;
//			for each (var scheduleItem:ScheduleItemBase in scheduleGroup.scheduleItemsCollection)
//			{
//				if (!scheduleItem.adherenceItem)
//				{
//					reportingCompleted = false;
//				}
//			}
//			if (reportingCompleted)
//			{
//				currentWidgetView = SCHEDULE_CLOCK_VIEW;
//			}
		}
		
		public function grabScheduleGroup(moveData:MoveData):void
		{
			var scheduleGroup:ScheduleGroup = _scheduleGroupsHashMap[moveData.id];
			scheduleGroup.dateTimeCenterPreMove = scheduleGroup.dateTimeCenter;
			scheduleGroup.dateTimeStartPreMove = scheduleGroup.dateTimeStart;
			scheduleGroup.dateTimeEndPreMove = scheduleGroup.dateTimeEnd;
			scheduleGroup.yPreMove = scheduleGroup.yPosition;
			scheduleGroup.containerMouseDownX = moveData.containerMouseX;
			scheduleGroup.containerMouseDownY = moveData.containerMouseY;
			scheduleGroup.moving = true;
		}
		
		public function moveScheduleGroup(moveData:MoveData, scheduleFullViewWidth:Number, scheduleFullViewHeight:Number, timeWidth:Number):void
		{
			var scheduleGroup:ScheduleGroup = _scheduleGroupsHashMap[moveData.id];
			var scaleFactorX:Number = moveData.containerWidth / scheduleFullViewWidth;
			var scaleFactorY:Number = moveData.containerHeight / scheduleFullViewHeight;
			var hourChange:Number = Math.round(((moveData.containerMouseX - scheduleGroup.containerMouseDownX) * scaleFactorX) / timeWidth);
			if (hourChange + scheduleGroup.dateTimeStartPreMove.hours >= 0 && hourChange + scheduleGroup.dateTimeEndPreMove.hours <= 23)
			{
				//dateTimeStart and dateTimeEnd are updated in this setter to prevent a state where are of them are not updated
				scheduleGroup.dateTimeCenter = new Date(scheduleGroup.dateTimeCenterPreMove.time + (hourChange * 60 * 60 * 1000));
			}
			scheduleGroup.yPosition = scheduleGroup.yPreMove + (moveData.containerMouseY - scheduleGroup.containerMouseDownY) * scaleFactorY;
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
			scheduleGroup.moving = false;
			determineStacking();
		}
		
		public function determineStacking():void
		{
			scheduleGroupsCollection.source.sortOn("dateTimeCenter");

			var lastHour:Number = 100;
			var stackNumber:Number = 0;
			var scheduleItemsStacked:Number = 0;
			var scheduleGroupsStacked:Number = 0;
			var groupFromRight:Number = 0;
			var previousStackHasAdherenceGroup:Boolean = false;
			//TODO: fix static medication width reference;
			var scheduleItemsPerHour:Number = 5;//Math.ceil((FullMedicationView.MEDICATION_WIDTH - FullMedicationView.MEDICATION_PICTURE_WIDTH / 2 + FullAdherenceGroupView.ADHERENCE_GROUP_BUFFER_WIDTH) / timeWidth);

			for each (var scheduleGroup:ScheduleGroup in scheduleGroupsCollection)
			{
				if (lastHour - scheduleGroup.dateTimeCenter.hours > scheduleItemsPerHour)
				{
					stackNumber = 0;
					scheduleItemsStacked = 0;
					scheduleGroupsStacked = 0;
				}
				else
				{
					stackNumber += 1;
					if (previousStackHasAdherenceGroup) {
						scheduleGroupsStacked += 1;
					}
				}

				lastHour = scheduleGroup.dateTimeCenter.hours;

				scheduleGroup.scheduleGroupsStacked = scheduleGroupsStacked;
				scheduleGroup.scheduleItemsStacked = scheduleItemsStacked;

				if (scheduleGroup.scheduleItemsCollection.length > 1)
				{
					previousStackHasAdherenceGroup = true;
//					adherenceGroup.show = true;
				}
				else
				{
					previousStackHasAdherenceGroup = false;
				}

				for each (var scheduleItem:ScheduleItemBase in scheduleGroup.scheduleItemsCollection)
				{
					scheduleItemsStacked += 1;
				}

				scheduleGroup.stackingUpdated = true;
			}
			stackingUpdated = true;
		}
		
		public function grabScheduleGroupSpotlight(moveData:MoveData):void
		{
//			var scheduleGroup:ScheduleGroup = _user.resolveDocumentById(moveData.id, ScheduleGroup) as ScheduleGroup;
//			scheduleGroup.dateTimeCenterPreMove = scheduleGroup.dateTimeCenter;
//			scheduleGroup.dateTimeStartPreMove = scheduleGroup.dateTimeStart;
//			scheduleGroup.dateTimeEndPreMove = scheduleGroup.dateTimeEnd;
//			scheduleGroup.containerMouseDownX = moveData.containerMouseX;
//			scheduleGroup.containerMouseDownY = moveData.containerMouseY;
		}
		
		public function resizeScheduleGroupSpotlight(moveData:MoveData, scheduleFullViewWidth:Number, scheduleFullViewHeight:Number, timeWidth:Number, leftEdge:Boolean):void
		{
//			var scheduleGroup:ScheduleGroup = _user.resolveDocumentById(moveData.id, ScheduleGroup) as ScheduleGroup;
//			var scaleFactorX:Number = moveData.containerWidth / scheduleFullViewWidth;
//			var scaleFactorY:Number = moveData.containerHeight / scheduleFullViewHeight;
//			var hourChange:Number = Math.round(((moveData.containerMouseX - scheduleGroup.containerMouseDownX) * scaleFactorX) / timeWidth);
//			logger.info(String(hourChange));
//			if (leftEdge)
//			{
//				hourChange *= -1;
//			}
//			var durationPreMove:Number = (scheduleGroup.dateTimeEndPreMove.time - scheduleGroup.dateTimeStartPreMove.time) / (60 * 60 * 1000);
//			if (scheduleGroup.dateTimeStartPreMove.hours - hourChange >= 0 && scheduleGroup.dateTimeEndPreMove.hours + hourChange <= 23 && hourChange * 2 + durationPreMove <= 6 && hourChange * 2 + durationPreMove >= 2 )
//			{
//				scheduleGroup.dateTimeStart = new Date(scheduleGroup.dateTimeStartPreMove.time - (hourChange * 60 * 60 * 1000));
//				scheduleGroup.dateTimeEnd = new Date(scheduleGroup.dateTimeEndPreMove.time + (hourChange * 60 * 60 * 1000));
//			}
		}
		
		public function dropScheduleGroupSpotlight(moveData:MoveData):void
		{
//			var scheduleGroup:ScheduleGroup = _user.resolveDocumentById(moveData.id, ScheduleGroup) as ScheduleGroup;
//			scheduleGroup.changed = true;
		}
		
		
		

		public function get closeDrawer():Boolean
		{
			return _closeDrawer;
		}

		public function set closeDrawer(value:Boolean):void
		{
			_closeDrawer = value;
		}

		public function get drawerColor():String
		{
			return _drawerColor;
		}

		public function set drawerColor(value:String):void
		{
			_drawerColor = value;
		}

		public function get drawerX():Number
		{
			return _drawerX;
		}

		public function set drawerX(value:Number):void
		{
			_drawerX = value;
			for each (var scheduleItem:ScheduleItemBaseOld in _scheduleItemsCollection)
			{
				if (scheduleItem.scheduled == false)
				{
					scheduleItem.xPosition = value + 10;
				}
			}
		}

		public function get scheduleItemsCollection():ArrayCollection
		{
			return _scheduleItemsCollection;
		}
		
		public function set scheduleItemsCollection(value:ArrayCollection):void
		{
			_scheduleItemsCollection = value;
		}
		
		public function get adherenceGroupsCollection():ArrayCollection
		{
			return _adherenceGroupsCollection;
		}
		
		public function set adherenceGroupsCollection(value:ArrayCollection):void
		{
			_adherenceGroupsCollection = value;
		}
		
		public function get locked():Boolean
		{
			return _locked;
		}
		
		public function set locked(value:Boolean):void
		{
			_locked = value;
		}
		

		
//		public function addScheduleGroup(documentID:String, scheduleGroupXML:XML):void
//		{
//			var scheduleGroup:ScheduleGroup = new ScheduleGroup(documentID, scheduleGroupXML);
//		}
		
		public function addScheduleItem(documentID:String, scheduleItem:ScheduleItemBaseOld):void
		{
			// TODO: Revise scheduled vs. unscheduled
			scheduleItem.scheduled = true;
			if (scheduleItem.scheduled)
			{
				var adherenceGroup:AdherenceGroup;
				if (_adherenceGroupsVector[scheduleItem.hour-1] == null)
				{
					adherenceGroup = addScheduleItemToNewAdherenceGroup(scheduleItem, scheduleItem.hour, 0, 2);
					_adherenceGroupsVector[scheduleItem.hour-1] = adherenceGroup;
				}
				else
				{
					adherenceGroup = _adherenceGroupsVector[scheduleItem.hour-1];
					adherenceGroup.scheduleItems.push(scheduleItem);
				}
				scheduleItem.adherenceGroup = adherenceGroup;
			}
			_scheduleItemsCollection.addItem(scheduleItem);
			_scheduleItemsDictionary[documentID] = scheduleItem;
		}
				
		public function moveSmartDrawerStart(moveData:MoveData, collaborationColor:String):void
		{
			drawerColor = collaborationColor;
		}
		
		public function moveSmartDrawer(moveData:MoveData, collaborationColor:String):void
		{
			drawerX = moveData.xPosition;
		}
		
		public function moveSmartDrawerEnd(moveData:MoveData, collaborationColor:String):void
		{
			drawerColor = "0xFFFFFF";
			closeDrawer = !_closeDrawer;
		}
		
		public function moveScheduleItemStart(moveData:MoveData, collaborationColor:String):void
		{
			var scheduleItem:ScheduleItemBaseOld = _scheduleItemsDictionary[moveData.id];
			if (scheduleItem.scheduled == true)
			{
				closeDrawer = true;
			}
			scheduleItem.active = true;
			scheduleItem.firstMove = true;
			scheduleItem.collaborationColor = collaborationColor;
			for each (var adherenceGroup:AdherenceGroup in _adherenceGroupsCollection)
			{
				adherenceGroup.show = false;
			}
		}
		
		private function removeScheduleItemFromAdherenceGroup(scheduleItem:ScheduleItemBaseOld):void
		{
			if (scheduleItem.adherenceGroup.scheduleItems.length == 1)
			{
				removeAdherenceGroup(scheduleItem.adherenceGroup);
			}
			else
			{
				var scheduleItemIndex:Number = scheduleItem.adherenceGroup.scheduleItems.indexOf(scheduleItem);
				scheduleItem.adherenceGroup.scheduleItems.splice(scheduleItemIndex, 1);
			}
		}
		
		private function removeAdherenceGroup(adherenceGroup:AdherenceGroup):void
		{
			var adherenceGroupIndex:Number = _adherenceGroupsCollection.getItemIndex(adherenceGroup);
			_adherenceGroupsCollection.removeItemAt(adherenceGroupIndex);
		}
		
		private function addScheduleItemToNewAdherenceGroup(scheduleItem:ScheduleItemBaseOld, hour:Number, yBottomPosition:Number, adherenceWindow:Number):AdherenceGroup
		{
			var scheduleItems:Vector.<ScheduleItemBaseOld> = new Vector.<ScheduleItemBaseOld>;
			scheduleItems.push(scheduleItem);
			var adherenceGroup:AdherenceGroup = new AdherenceGroup(hour, scheduleItems);
			adherenceGroup.adherenceWindow = adherenceWindow;
			adherenceGroup.yBottomPosition = yBottomPosition;
			scheduleItem.adherenceGroup = adherenceGroup;
			_adherenceGroupsCollection.addItem(adherenceGroup);
			
			return adherenceGroup;
		}
		
		public function moveScheduleItem(moveData:MoveData):void
		{
			var scheduleItem:ScheduleItemBaseOld = _scheduleItemsDictionary[moveData.id];
			scheduleItem.yBottomPosition = moveData.yBottomPosition;
				
			if (moveData.hour < 1)
			{
				if (scheduleItem.scheduled == true)
				{
					
					// HACK
//					var className:String = getQualifiedClassName(scheduleItem);
//					if (className == "collaboRhythm.workstation.apps.medications.model::Medication")
//					{
//						closeDrawer = false;
//						var itemIndex:Number = _medicationsModel.shortMedicationsCollection.getItemIndex(scheduleItem);
//						_medicationsModel.shortMedicationsCollection.removeItemAt(itemIndex);
//						scheduleItem.scheduled = false;
//						removeScheduleItemFromAdherenceGroup(scheduleItem);
//					}
					
				}
				scheduleItem.xPosition = moveData.xPosition;
			}
			else if (scheduleItem.hour <= 24)
			{
				if (scheduleItem.scheduled == true)
				{
					if (moveData.hour != scheduleItem.hour)
					{
						if (scheduleItem.adherenceGroup.scheduleItems.length == 1)
						{
							if (scheduleItem.firstMove == true)
							{
								_adherenceGroupsVector[scheduleItem.hour-1] = null;
							}
						}
						else
						{
							var adherenceWindow:Number = scheduleItem.adherenceGroup.adherenceWindow;
							removeScheduleItemFromAdherenceGroup(scheduleItem);
//							addScheduleItemToNewAdherenceGroup(scheduleItem, moveData.hour, moveData.yBottomPosition, adherenceWindow);
						}
												
						scheduleItem.updateHour(moveData.hour);
						scheduleItem.firstMove = false;
					}
					
					if (scheduleItem.adherenceGroup.scheduleItems.length == 1)
					{
						scheduleItem.adherenceGroup.moveAdherenceGroup(moveData);
					}
				}
				else
				{
					
					// HACK
//					className = getQualifiedClassName(scheduleItem);
//					if (className == "collaboRhythm.workstation.apps.medications.model::Medication")
//					{
//						closeDrawer = true;
//						_medicationsModel.shortMedicationsCollection.addItem(scheduleItem);
//						scheduleItem.scheduled = true
//						addScheduleItemToNewAdherenceGroup(scheduleItem, moveData.hour, moveData.yBottomPosition, 2);
//						scheduleItem.updateHour(moveData.hour);
//					}
					
				}
			}	
		}
		
		public function moveScheduleItemEnd(moveData:MoveData):void
		{
			var scheduleItem:ScheduleItemBaseOld = _scheduleItemsDictionary[moveData.id];
			if (scheduleItem.firstMove == false && scheduleItem.scheduled == true)
			{
				if (_adherenceGroupsVector[scheduleItem.hour - 1] == null)
				{
					_adherenceGroupsVector[scheduleItem.hour - 1] = scheduleItem.adherenceGroup;
				}
				else
				{
					removeAdherenceGroup(scheduleItem.adherenceGroup);
					
					_adherenceGroupsVector[scheduleItem.hour - 1].scheduleItems.push(scheduleItem);
					scheduleItem.adherenceGroup = _adherenceGroupsVector[scheduleItem.hour - 1];
				}
			}
			scheduleItem.collaborationColor = "0xFFFFFF";
			determineStacking();
		}
		
		public function moveAdherenceGroupStart(moveData:MoveData, collaborationColor:String):void
		{
			var adherenceGroup:AdherenceGroup = _adherenceGroupsCollection[moveData.itemIndex];
			if (adherenceGroup.scheduled == true)
			{
				closeDrawer = true;
			}
			adherenceGroup.active = true;
			adherenceGroup.firstMove = true;
			adherenceGroup.collaborationColor = collaborationColor;
			for each (var otherAdherenceGroup:AdherenceGroup in _adherenceGroupsCollection)
			{
				if (otherAdherenceGroup != adherenceGroup)
				{
					otherAdherenceGroup.show = false;
				}
			}
		}
		
		public function moveAdherenceGroup(moveData:MoveData):void
		{
			var adherenceGroup:AdherenceGroup = _adherenceGroupsCollection[moveData.itemIndex];
			adherenceGroup.yBottomPosition = moveData.yBottomPosition;
			if (moveData.hour != adherenceGroup.hour)
			{
				if (adherenceGroup.firstMove == true)
				{
					_adherenceGroupsVector[adherenceGroup.hour-1] = null;
					adherenceGroup.firstMove = false;
				}
				adherenceGroup.updateHour(moveData.hour);
			}
			
			adherenceGroup.moveScheduledItems(moveData);
		}
		
		public function moveAdherenceGroupEnd(moveData:MoveData):void
		{
			var adherenceGroup:AdherenceGroup = _adherenceGroupsCollection[moveData.itemIndex];
			if (_adherenceGroupsVector[adherenceGroup.hour-1] != null && adherenceGroup.firstMove == false)
			{
				var newAdherenceGroup:AdherenceGroup = _adherenceGroupsVector[adherenceGroup.hour-1];
				var adherenceGroupIndex:Number = _adherenceGroupsCollection.getItemIndex(adherenceGroup);
				_adherenceGroupsCollection.removeItemAt(adherenceGroupIndex);
				for each (var scheduleItem:ScheduleItemBaseOld in adherenceGroup.scheduleItems)
				{
//					newAdherenceGroup.addScheduleItem(scheduleItem);
					scheduleItem.adherenceGroup = newAdherenceGroup;
				}
			}
			else
			{
				_adherenceGroupsVector[adherenceGroup.hour-1] = adherenceGroup;
			}
			adherenceGroup.collaborationColor = "0xFFFFFF";
			determineStacking();
		}
		
		public function resizeAdherenceWindow(moveData:MoveData):void
		{
			var adherenceGroup:AdherenceGroup = _adherenceGroupsCollection[moveData.itemIndex];
			adherenceGroup.adherenceWindow = moveData.adherenceWindow;
		}
		
//		public function calculateScheduleItemXPosition(hour:Number)
//		{
//			Math.floor((hour + 1) * timeWidth + (timeWidth / 2) - (FullMedicationView.MEDICATION_PICTURE_WIDTH / 2));
//		}
//		
//		public function calculateAdherenceGroupXPosition(hour:Number)
//		{
//			Math.floor((hour + 1) * timeWidth + (timeWidth / 2) - (FullMedicationView.MEDICATION_PICTURE_WIDTH / 2) - ADHERENCE_GROUP_BUFFER_WIDTH);
//		}
//			
//		public function calculateScheduleItemYPosition(stackNumber:Number, scheduleItemsStacked:Number, adherenceGroupsStacked:Number):Number
//		{
//			return Math.floor(_scheduleFullView.scheduleItemCanvas.height - ScheduleFullView.ADHERENCE_WINDOW_INITIAL_HEIGHT - stackNumber * FullAdherenceGroupView.ADHERENCE_GROUP_BUFFER_WIDTH - scheduleItemsStacked * (FullMedicationView.MEDICATION_HEIGHT + FullAdherenceGroupView.ADHERENCE_GROUP_BUFFER_WIDTH) - adherenceGroupsStacked * FullAdherenceGroupView.ADHERENCE_GROUP_TOP_WIDTH);
//		}
//		
//		public function calculateAdherenceGroupYPosition(stackNumber:Number, scheduleItemsStacked:Number, adherenceGroupsStacked:Number, scheduledItemsLength:Number):Number
//		{
//			return Math.floor(_scheduleFullView.scheduleItemCanvas.height - ScheduleFullView.ADHERENCE_WINDOW_INITIAL_HEIGHT - stackNumber * FullAdherenceGroupView.ADHERENCE_GROUP_BUFFER_WIDTH - (scheduleItemsStacked + scheduledItemsLength) * (FullMedicationView.MEDICATION_HEIGHT + FullAdherenceGroupView.ADHERENCE_GROUP_BUFFER_WIDTH) - FullAdherenceGroupView.ADHERENCE_GROUP_TOP_WIDTH - adherenceGroupsStacked * FullAdherenceGroupView.ADHERENCE_GROUP_TOP_WIDTH);
//		}
		

		
		public function get now():Date
		{
			return _currentDateSource.now();
		}

        public function get viewFactory():IScheduleViewFactory
        {
            return _viewFactory;
        }
    }
}