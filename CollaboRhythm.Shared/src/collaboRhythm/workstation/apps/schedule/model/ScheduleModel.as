package collaboRhythm.workstation.apps.schedule.model
{
	import collaboRhythm.workstation.apps.medications.model.Medication;
	import collaboRhythm.workstation.apps.medications.model.MedicationsModel;
	import collaboRhythm.workstation.apps.schedule.view.FullAdherenceGroupView;
	import collaboRhythm.workstation.apps.schedule.view.FullMedicationView;
	import collaboRhythm.workstation.apps.schedule.view.FullScheduleItemViewBase;
	import collaboRhythm.workstation.model.services.ICurrentDateSource;
	import collaboRhythm.workstation.model.services.WorkstationKernel;
	
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.rpc.xml.SchemaTypeRegistry;
	
	[Bindable]
	public class ScheduleModel
	{
		private var _closeDrawer:Boolean = true;
		private var _drawerX:Number = -340;
		private var _drawerColor:String = "0xFFFFFF";
		private var _medicationsModel:MedicationsModel;
		private var _scheduleItemsCollection:ArrayCollection = new ArrayCollection();
		private var _scheduleItemsDictionary:Dictionary = new Dictionary();
		private var _adherenceGroupsCollection:ArrayCollection = new ArrayCollection();
		private var _adherenceGroupsVector:Vector.<AdherenceGroup> = new Vector.<AdherenceGroup>(24);
		private var _timeWidth:Number;
		private var _locked:Boolean = false;
		private var _initialized:Boolean = false;
		private var _currentDateSource:ICurrentDateSource;
		
		public function ScheduleModel(medicationsModel:MedicationsModel)
		{		
			_medicationsModel = medicationsModel;
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
			if (!_medicationsModel.initialized)
			{
				BindingUtils.bindSetter(addMedicationsToScheduleItems, _medicationsModel, "initialized");
			}
			else
			{
				addMedicationsToScheduleItems(true);
			}
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
			for each (var scheduleItem:ScheduleItemBase in _scheduleItemsCollection)
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
		
		public function get timeWidth():Number
		{
			return _timeWidth;
		}
		
		public function set timeWidth(value:Number):void
		{
			_timeWidth = value;
		}
		
		public function get locked():Boolean
		{
			return _locked;
		}
		
		public function set locked(value:Boolean):void
		{
			_locked = value;
		}
		
		public function get initialized():Boolean
		{
			return _initialized;
		}
		
		public function set initialized(value:Boolean):void
		{
			_initialized = value;
		}
		
		private function addScheduleItem(documentID:String, scheduleItem:ScheduleItemBase):void
		{
			_scheduleItemsCollection.addItem(scheduleItem);
			_scheduleItemsDictionary[documentID] = scheduleItem;
			if (scheduleItem.scheduled == true)
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
		}
		
		private function addMedicationsToScheduleItems(initialized:Boolean):void
		{
			if (initialized == true)
			{
				for each (var medication:Medication in _medicationsModel.medicationsCollection)
				{
					// HACK
//					if (medication.brandName == "Hydrochlorothiazide")
//					{
//						medication.scheduled = false;
//					}
//					else
//					{
//						medication.scheduled = true;
//					}
					medication.scheduled = true;
					medication.scheduleModel = this;
					addScheduleItem(medication.documentID, medication);
				}
				
				// HACK
				var bloodPressureMeasurement:Measurement = new Measurement();
				bloodPressureMeasurement.scheduled = true;
				bloodPressureMeasurement.scheduleModel = this;
				addScheduleItem(bloodPressureMeasurement.documentID, bloodPressureMeasurement);
				
				determineStacking();
			}
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
			var scheduleItem:ScheduleItemBase = _scheduleItemsDictionary[moveData.documentID];
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
		
		private function removeScheduleItemFromAdherenceGroup(scheduleItem:ScheduleItemBase):void
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
		
		private function addScheduleItemToNewAdherenceGroup(scheduleItem:ScheduleItemBase, hour:Number, yBottomPosition:Number, adherenceWindow:Number):AdherenceGroup
		{
			var scheduleItems:Vector.<ScheduleItemBase> = new Vector.<ScheduleItemBase>;
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
			var scheduleItem:ScheduleItemBase = _scheduleItemsDictionary[moveData.documentID];
			scheduleItem.yBottomPosition = moveData.yBottomPosition;
				
			if (moveData.hour < 1)
			{
				if (scheduleItem.scheduled == true)
				{
					
					// HACK
					var className:String = getQualifiedClassName(scheduleItem);
					if (className == "collaboRhythm.workstation.apps.medications.model::Medication")
					{
						closeDrawer = false;
						var itemIndex:Number = _medicationsModel.shortMedicationsCollection.getItemIndex(scheduleItem);
						_medicationsModel.shortMedicationsCollection.removeItemAt(itemIndex);
						scheduleItem.scheduled = false;
						removeScheduleItemFromAdherenceGroup(scheduleItem);
					}
					
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
							addScheduleItemToNewAdherenceGroup(scheduleItem, moveData.hour, moveData.yBottomPosition, adherenceWindow);
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
					className = getQualifiedClassName(scheduleItem);
					if (className == "collaboRhythm.workstation.apps.medications.model::Medication")
					{
						closeDrawer = true;
						_medicationsModel.shortMedicationsCollection.addItem(scheduleItem);
						scheduleItem.scheduled = true
						addScheduleItemToNewAdherenceGroup(scheduleItem, moveData.hour, moveData.yBottomPosition, 2);
						scheduleItem.updateHour(moveData.hour);
					}
					
				}
			}	
		}
		
		public function moveScheduleItemEnd(moveData:MoveData):void
		{
			var scheduleItem:ScheduleItemBase = _scheduleItemsDictionary[moveData.documentID];
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
				for each (var scheduleItem:ScheduleItemBase in adherenceGroup.scheduleItems)
				{
					newAdherenceGroup.addScheduleItem(scheduleItem);
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
		
		public function determineStacking():void
		{
			var lastHour:Number = 100;
			var stackNumber:Number = 0;
			var scheduleItemsStacked:Number = 0;
			var adherenceGroupsStacked:Number = 0;
			var groupFromRight:Number = 0;
			var previousStackHasAdherenceGroup:Boolean = false;
			var scheduleItemsPerHour:Number = Math.ceil((FullMedicationView.MEDICATION_WIDTH - FullMedicationView.MEDICATION_PICTURE_WIDTH / 2 + FullAdherenceGroupView.ADHERENCE_GROUP_BUFFER_WIDTH) / timeWidth);
			
			for (var currentHour:Number = 24; currentHour >= 1; currentHour--) {
				if (_adherenceGroupsVector[currentHour-1] != null)
				{
					var adherenceGroup:AdherenceGroup = _adherenceGroupsVector[currentHour-1];
					adherenceGroup.groupFromRight = groupFromRight;
					groupFromRight += 1;
					
					if (lastHour - currentHour > scheduleItemsPerHour)
					{
						stackNumber = 0;
						scheduleItemsStacked = 0;
						adherenceGroupsStacked = 0;
					}
					else
					{
						stackNumber += 1;
						if (previousStackHasAdherenceGroup == true) {
							adherenceGroupsStacked += 1;
						}
					}
					
					lastHour = currentHour;
					
					adherenceGroup.stackNumber = stackNumber;
					adherenceGroup.scheduleItemsStacked = scheduleItemsStacked;
					adherenceGroup.adherenceGroupsStacked = adherenceGroupsStacked;
					adherenceGroup.stackingUpdated = true;
//					adherenceGroup.xPosition = calculateAdherenceGroupXPosition(adherenceGroup.hour);
//					adherenceGroup.yPosition = calculateAdherenceGroupYPosition(stackNumber, scheduleItemsStacked, adherenceGroupsStacked, adherenceGroup.scheduleItems.length);
					
					if (adherenceGroup.scheduleItems.length > 1)
					{
						previousStackHasAdherenceGroup = true;
						adherenceGroup.show = true;
					}
					else
					{
						previousStackHasAdherenceGroup = false;
					}
					
					for each (var adherenceGroupScheduleItem:ScheduleItemBase in adherenceGroup.scheduleItems)
					{
						scheduleItemsStacked += 1;
						adherenceGroupScheduleItem.stackNumber = stackNumber;
						adherenceGroupScheduleItem.scheduleItemsStacked = scheduleItemsStacked;
						adherenceGroupScheduleItem.adherenceGroupsStacked = adherenceGroupsStacked;
						adherenceGroupScheduleItem.stackingUpdated = true;
//						scheduleItem.xPosition = calculateScheduleItemXPosition(scheduleItem.hour);
//						scheduleItem.yPosition = calculateScheduleItemYPosition(stackNumber, scheduleItemsStacked, adherenceGroupsStacked);
					}
				}
			}
			
			for each (var scheduleItem:ScheduleItemBase in _scheduleItemsCollection)
			{
				if (scheduleItem.scheduled == false)
				{
					scheduleItem.xPosition = drawerX + 10;
					scheduleItem.stackingUpdated = true;
				}
			}
		}
		
		public function get now():Date
		{
			return _currentDateSource.now();
		}
	}
}