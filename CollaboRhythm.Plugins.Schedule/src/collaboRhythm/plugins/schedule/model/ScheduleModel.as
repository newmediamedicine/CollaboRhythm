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
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.services.DateUtil;
	import collaboRhythm.shared.model.IApplicationNavigationProxy;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.DocumentCollectionBase;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;
	import collaboRhythm.shared.model.settings.Settings;

	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;

	import j2as3.collection.HashMap;

	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;

	import spark.components.ViewNavigator;

	[Bindable]
	public class ScheduleModel extends EventDispatcher implements IScheduleCollectionsProvider, IHealthActionModelDetailsProvider
	{
		// Key to the ScheduleModel instance in Record.appData is in ScheduleModelKey Class in CollaboRhythm.Plugins.Schedule.Shared
		// so that it is available to other plugins

		private static const MILLISECONDS_IN_HOUR:Number = 1000 * 60 * 60;
		private static const MILLISECONDS_IN_DAY:Number = 1000 * 60 * 60 * 24;

		private var _record:Record;
		private var _accountId:String;
		private var _isInitialized:Boolean = false;
		private var _scheduleGroupsHashMap:HashMap = new HashMap();
		private var _scheduleGroupsCollection:ArrayCollection = new ArrayCollection();
		private var _scheduleItemOccurrencesHashMap:HashMap = new HashMap();
		private var _scheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence> = new Vector.<ScheduleItemOccurrence>();
		private var _scheduleReportingModel:ScheduleReportingModel;

		private var _scheduleTimelineModel:ScheduleTimelineModel;
		private var _adherencePerformanceModel:AdherencePerformanceModel;
		private var _currentDateSource:ICurrentDateSource;

		private var _logger:ILogger;

		private var _documentCollectionDependenciesArray:Array = new Array();

		private var _scheduleItemsCollectionsArray:Array = new Array();
		private var _inputDocumentCollectionsArray:Array = new Array();
		private var _changeWatchers:Vector.<ChangeWatcher> = new Vector.<ChangeWatcher>();

		private var _healthActionListViewAdapterFactory:MasterHealthActionListViewAdapterFactory;
		private var _healthActionInputControllerFactory:MasterHealthActionInputControllerFactory;
		private var _healthActionCreationControllers:ArrayCollection;

		private var _navigationProxy:IApplicationNavigationProxy;
		private var _viewNavigator:ViewNavigator;
		private var _settings:Settings;
		private var _activeAccount:Account;
		private var _collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy;
		private var _componentContainer:IComponentContainer;
		private var _inputDocumentsChanged:Boolean;

		public function ScheduleModel(componentContainer:IComponentContainer, activeAccount:Account,
									  activeRecordAccount:Account, navigationProxy:IApplicationNavigationProxy,
									  settings:Settings,
									  collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy,
									  viewNavigator:ViewNavigator)
		{
			_componentContainer = componentContainer;
			_accountId = activeRecordAccount.accountId;
			_navigationProxy = navigationProxy;
			_viewNavigator = viewNavigator;
			_settings = settings;
			_collaborationLobbyNetConnectionServiceProxy = collaborationLobbyNetConnectionServiceProxy;
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;

			_record = activeRecordAccount.primaryRecord;
			_activeAccount = activeAccount;

			_documentCollectionDependenciesArray = [_record.medicationOrdersModel, _record.medicationScheduleItemsModel, _record.equipmentModel, _record.healthActionSchedulesModel, _record.adherenceItemsModel];
			_scheduleItemsCollectionsArray = [_record.medicationScheduleItemsModel.medicationScheduleItemCollection, _record.healthActionSchedulesModel.healthActionScheduleCollection];
			_inputDocumentCollectionsArray = [_record.medicationScheduleItemsModel.medicationScheduleItemCollection, _record.healthActionSchedulesModel.healthActionScheduleCollection, _record.adherenceItemsModel.documents];

			for each (var documentCollection:DocumentCollectionBase in _documentCollectionDependenciesArray)
			{
				_changeWatchers.push(BindingUtils.bindSetter(init, documentCollection, "isStitched"));
			}

			_healthActionListViewAdapterFactory = new MasterHealthActionListViewAdapterFactory(componentContainer);
			_healthActionInputControllerFactory = new MasterHealthActionInputControllerFactory(componentContainer);
			var healthActionCreationControllerFactory:MasterHealthActionCreationControllerFactory = new MasterHealthActionCreationControllerFactory(componentContainer);
			_healthActionCreationControllers = healthActionCreationControllerFactory.createHealthActionCreationControllers(activeAccount,
					activeRecordAccount, _viewNavigator);
		}

		private function init(isStitched:Boolean):void
		{
			if (!isInitialized)
			{
				if (isStitched)
				{
					for each (var documentCollection:DocumentCollectionBase in _documentCollectionDependenciesArray)
					{
						if (!documentCollection.isStitched)
						{
							return;
						}
					}
				}
				else
				{
					return;
				}
				addCollectionChangeEventListeners();
				addRecordChangeEventListener();
				updateScheduleModelForToday();
				isInitialized = true;
				dispatchEvent(new ScheduleModelEvent(ScheduleModelEvent.INITIALIZED));
			}
		}

		private function addRecordChangeEventListener():void
		{
			_record.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, record_propertyChangeHandler)
		}

		private function addCollectionChangeEventListeners():void
		{
			for each (var scheduleItemsCollectionsArray:ArrayCollection in _inputDocumentCollectionsArray)
			{
				// Use as higher priority value of 1 so that the schedule model will be updated before other listeners
				scheduleItemsCollectionsArray.addEventListener(CollectionEvent.COLLECTION_CHANGE,
						documentCollection_changeHandler, false, 1);
			}
		}

		private function documentCollection_changeHandler(event:CollectionEvent):void
		{
			if (event.kind == CollectionEventKind.ADD || event.kind == CollectionEventKind.REMOVE ||
					event.kind == CollectionEventKind.RESET)
			{
				if (_record.isLoading)
				{
					_inputDocumentsChanged = true;
				}
				else
				{
					// TODO: support incremental changes so that a view (such as the timeline view) can be updated just for the change without being recreated/reset
					/*
					 if (event.items[0] is ScheduleItemBase)
					 {
					 if (event.kind == CollectionEventKind.REMOVE)
					 {
					 removeScheduleItems(event.items);
					 return;
					 }
					 else if (event.kind == CollectionEventKind.ADD)
					 {
					 addScheduleItems(event.items);
					 return;
					 }
					 }
					 */
					updateScheduleModelForToday();
				}
			}
		}

		private function addScheduleItems(items:Array):void
		{
			var now:Date = currentDateSource.now();
			var dateEnd:Date = DateUtil.roundTimeToNextDay(now);
			var dateStart:Date = new Date(dateEnd.valueOf() - DateUtil.MILLISECONDS_IN_DAY);
			for each (var item:ScheduleItemBase in items)
			{
				var newScheduleItemOccurrences:Vector.<ScheduleItemOccurrence> = item.getScheduleItemOccurrences(dateStart,
						dateEnd);
				for each (var scheduleItemOccurrence:ScheduleItemOccurrence in newScheduleItemOccurrences)
				{
					_scheduleItemOccurrencesHashMap.put(scheduleItemOccurrence.id, scheduleItemOccurrence);
					addToScheduleGroup(scheduleItemOccurrence);
				}
			}
		}

		private function removeScheduleItems(items:Array):void
		{
			for each (var item:ScheduleItemBase in items)
			{
				for each (var scheduleItemOccurrence:ScheduleItemOccurrence in
						_scheduleItemOccurrencesHashMap.values())
				{
					if (scheduleItemOccurrence.scheduleItem == item)
					{
						_scheduleItemOccurrencesHashMap.remove(scheduleItemOccurrence.id);
					}
				}
				for each (var group:ScheduleGroup in _scheduleGroupsHashMap.values())
				{
					var index:int = group.scheduleItemsOccurrencesCollection.getItemIndex(item);
					if (index != -1)
					{
						group.scheduleItemsOccurrencesCollection.removeItemAt(index);
						if (group.scheduleItemsOccurrencesCollection.length == 0)
						{
							_scheduleGroupsHashMap.remove(group.id);
							var groupIndex:int = _scheduleGroupsCollection.getItemIndex(group);
							if (groupIndex != -1)
							{
								_scheduleGroupsCollection.removeItemAt(groupIndex);
							}
						}
					}
				}
			}
			// we can't easily remove individual items from the existing vector, so recreate it
			//						_scheduleItemOccurrencesVector = getScheduleItemOccurrencesForToday();
			_scheduleItemOccurrencesVector = new Vector.<ScheduleItemOccurrence>(_scheduleItemOccurrencesHashMap.values().toArray());
		}

		private function updateScheduleModelForToday():void
		{
			_scheduleGroupsHashMap.clear();
			_scheduleGroupsCollection.removeAll();
			_scheduleItemOccurrencesHashMap.clear();
			_scheduleItemOccurrencesVector = getScheduleItemOccurrencesForToday();
			for each (var scheduleItemOccurrence:ScheduleItemOccurrence in scheduleItemOccurrencesVector)
			{
				_scheduleItemOccurrencesHashMap.put(scheduleItemOccurrence.id, scheduleItemOccurrence);
				addToScheduleGroup(scheduleItemOccurrence);
			}
			adherencePerformanceModel.scheduleModelIsInitialized = true;
			scheduleTimelineModel.determineStacking();
		}

		private function getScheduleItemOccurrencesForToday():Vector.<ScheduleItemOccurrence>
		{
			var currentDate:Date = _currentDateSource.now();
			var dateStart:Date = new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate());
			var dateEnd:Date = new Date(dateStart.valueOf() + MILLISECONDS_IN_DAY - 1);
			return getScheduleItemOccurrences(dateStart, dateEnd);
		}

		/**
		 * Returns all of the occurrences for all of the scheduleItems in the record during the specified interval.
		 *
		 * @param dateStart Start date of the interval.
		 * @param dateEnd End date of the interval.
		 * @return A vector containing the scheduleItemOccurrences for the specified interval.
		 */
		public function getScheduleItemOccurrences(dateStart:Date, dateEnd:Date):Vector.<ScheduleItemOccurrence>
		{
			var scheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence> = new Vector.<ScheduleItemOccurrence>();
			for each (var scheduleItemCollection:ArrayCollection in _scheduleItemsCollectionsArray)
			{
				for each (var scheduleItem:ScheduleItemBase in scheduleItemCollection)
				{
					var newScheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence> = scheduleItem.getScheduleItemOccurrences(dateStart,
							dateEnd);
					scheduleItemOccurrencesVector = scheduleItemOccurrencesVector.concat(newScheduleItemOccurrencesVector);
				}
			}
			return scheduleItemOccurrencesVector;
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
		}

		public function createScheduleGroup(scheduleItemOccurrence:ScheduleItemOccurrence, moving:Boolean,
											yPosition:int = NaN):ScheduleGroup
		{
			var scheduleGroup:ScheduleGroup = new ScheduleGroup();
			scheduleGroup.dateStart = scheduleItemOccurrence.dateStart;
			scheduleGroup.dateEnd = scheduleItemOccurrence.dateEnd;
			scheduleGroup.addScheduleItemOccurrence(scheduleItemOccurrence);
			scheduleGroup.moving = moving;
			if (yPosition)
			{
				scheduleGroup.yPosition = yPosition;
			}
			_scheduleGroupsCollection.addItem(scheduleGroup);
			_scheduleGroupsHashMap.put(scheduleGroup.id, scheduleGroup);

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

		public function saveChangesToRecord():void
		{
			// TODO: Determine why this is occasionally called with _record equal to null
			if (_record)
				_record.saveAllChanges();
		}

		public function get scheduleGroupsHashMap():HashMap
		{
			return _scheduleGroupsHashMap;
		}

		public function get scheduleItemOccurrencesHashMap():HashMap
		{
			return _scheduleItemOccurrencesHashMap;
		}

		public function get scheduleReportingModel():ScheduleReportingModel
		{
			if (!_scheduleReportingModel)
			{
				_scheduleReportingModel = new ScheduleReportingModel(this, _accountId);
			}
			return _scheduleReportingModel;
		}

		public function get scheduleTimelineModel():ScheduleTimelineModel
		{
			if (!_scheduleTimelineModel)
			{
				_scheduleTimelineModel = new ScheduleTimelineModel(this);
			}
			return _scheduleTimelineModel;
		}

		public function get adherencePerformanceModel():AdherencePerformanceModel
		{
			if (!_adherencePerformanceModel)
			{
				_adherencePerformanceModel = new AdherencePerformanceModel(this, _record);
			}
			return _adherencePerformanceModel;
		}

		public function destroy():void
		{
			_record = null;
			_scheduleReportingModel = null;
			_scheduleTimelineModel = null;
			_adherencePerformanceModel.destroy();
			_adherencePerformanceModel = null;
			for each (var changeWatcher:ChangeWatcher in _changeWatchers)
			{
				changeWatcher.unwatch();
			}
		}

		public function updateScheduleItems(scheduleGroup:ScheduleGroup):void
		{
			for each (var scheduleItemOccurrence:ScheduleItemOccurrence in
					scheduleGroup.scheduleItemsOccurrencesCollection)
			{
				var scheduleItemInGroup:ScheduleItemBase = scheduleItemOccurrence.scheduleItem;
				if (scheduleItemInGroup.dateStart.valueOf() != scheduleGroup.dateStart.valueOf() ||
						scheduleItemInGroup.dateEnd.valueOf() != scheduleGroup.dateEnd.valueOf())
				{
					var scheduleDetails:ScheduleDetails = ScheduleDetailsResolver.getCurrentScheduleDetails(new <String>[scheduleItemInGroup.name.value],
							false, getScheduleItemCollection(scheduleItemInGroup), currentDateSource.now());
					if (scheduleDetails && scheduleDetails.currentSchedule)
					{
						var scheduleChanger:ScheduleChanger = new ScheduleChanger(record, accountId, currentDateSource);
						// the next scheduleable occurrence may be from tomorrow, in which case we need to add 24 hours offset to the dateStart/dateEnd
						var offset:Number = DateUtil.roundTimeToNextDay(scheduleDetails.occurrence.dateStart).valueOf() -
								DateUtil.roundTimeToNextDay(scheduleGroup.dateStart).valueOf();
						scheduleChanger.updateScheduleItem(scheduleDetails.currentSchedule, scheduleDetails.occurrence,
								function (scheduleItem:ScheduleItemBase):void
								{
									var dateStart:Date = new Date(scheduleGroup.dateStart.valueOf() + offset);
									var dateEnd:Date = new Date(scheduleGroup.dateEnd.valueOf() + offset);
									scheduleItem.dateStart = dateStart;
									scheduleItem.dateEnd = dateEnd;
								}, true);
					}
				}
			}
		}

		private function getScheduleItemCollection(scheduleItem:ScheduleItemBase):ArrayCollection
		{
			if (scheduleItem is MedicationScheduleItem)
			{
				return record.medicationScheduleItemsModel.medicationScheduleItemCollection;
			}
			else
			{
				return record.healthActionSchedulesModel.healthActionScheduleCollection;
			}
		}

		/**
		 * Removes the schedule item occurrence from the group. If the occurrence is the only one in the group,
		 * the group will also be removed from the list of groups. Otherwise, if the occurrence is the first of
		 * multiple occurrences in the group, removing it will change the group id, so the group will be removed and
		 * then re-added to the list of groups (with its new id).
		 *
		 * @param scheduleGroup The group that the schedule item occurrence should be removed from.
		 * @param scheduleItemOccurrenceIndex The index of the schedule item occurrence in the specified group.
		 */
		public function removeScheduleItemOccurrenceFromGroup(scheduleGroup:ScheduleGroup,
															  scheduleItemOccurrenceIndex:int):void
		{
			if (scheduleItemOccurrenceIndex == 0 && scheduleGroup.scheduleItemsOccurrencesCollection.length == 1)
			{
				var scheduleGroupIndex:int = scheduleGroupsCollection.getItemIndex(scheduleGroup);
				scheduleGroupsCollection.removeItemAt(scheduleGroupIndex);
				scheduleGroupsHashMap.remove(scheduleGroup.id);
				scheduleGroup.scheduleItemsOccurrencesCollection.removeItemAt(scheduleItemOccurrenceIndex);
			}
			else
			{
				if (scheduleItemOccurrenceIndex == 0)
				{
					scheduleGroupsHashMap.remove(scheduleGroup.id);
				}
				scheduleGroup.scheduleItemsOccurrencesCollection.removeItemAt(scheduleItemOccurrenceIndex);
				if (scheduleItemOccurrenceIndex == 0)
				{
					scheduleGroupsHashMap.put(scheduleGroup.id, scheduleGroup);
				}
			}
		}

		public function get scheduleItemsCollectionsArray():Array
		{
			return _scheduleItemsCollectionsArray;
		}

		public function get scheduleItemOccurrencesVector():Vector.<ScheduleItemOccurrence>
		{
			return _scheduleItemOccurrencesVector;
		}

		public function get record():Record
		{
			return _record;
		}

		public function get accountId():String
		{
			return _accountId;
		}

		public function get healthActionListViewAdapterFactory():MasterHealthActionListViewAdapterFactory
		{
			return _healthActionListViewAdapterFactory;
		}

		public function get healthActionInputControllerFactory():MasterHealthActionInputControllerFactory
		{
			return _healthActionInputControllerFactory;
		}

		public function findClosestScheduleItemOccurrence(name:String, dateStartString:String):ScheduleItemOccurrence
		{
			var dateStart:Date = DateUtil.parseW3CDTF(dateStartString);
			var closestScheduleItemOccurrence:ScheduleItemOccurrence;
			var now:Date = _currentDateSource.now();
			if (dateStart && dateStart.date == now.date && dateStart.month == now.month && dateStart.fullYear == now.fullYear)
			{
				for each (var scheduleItemOccurrence:ScheduleItemOccurrence in scheduleItemOccurrencesHashMap)
				{
					if (scheduleItemOccurrence.scheduleItem.name.text == name &&
							scheduleItemOccurrence.adherenceItem == null)
					{
						if (dateStart > scheduleItemOccurrence.dateStart &&
								dateStart < scheduleItemOccurrence.dateEnd)
						{
							closestScheduleItemOccurrence = scheduleItemOccurrence;
							break;
						}
						else
						{
							if (closestScheduleItemOccurrence)
							{
								if ((dateStart.time - scheduleItemOccurrence.dateEnd.time <
										dateStart.time - closestScheduleItemOccurrence.dateEnd.time)
										||
										(scheduleItemOccurrence.dateStart.time - dateStart.time <
												closestScheduleItemOccurrence.dateStart.time -
														dateStart.time))
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
			}
			return closestScheduleItemOccurrence;
		}

		public function get navigationProxy():IApplicationNavigationProxy
		{
			return _navigationProxy;
		}

		public function get settings():Settings
		{
			return _settings;
		}

		public function set settings(value:Settings):void
		{
			_settings = value;
		}

		public function get activeAccount():Account
		{
			return _activeAccount;
		}

		public function get collaborationLobbyNetConnectionServiceProxy():ICollaborationLobbyNetConnectionServiceProxy
		{
			return _collaborationLobbyNetConnectionServiceProxy;
		}

		public function get healthActionCreationControllers():ArrayCollection
		{
			return _healthActionCreationControllers;
		}

		public function get componentContainer():IComponentContainer
		{
			return _componentContainer;
		}

		public function get currentDateSource():ICurrentDateSource
		{
			return _currentDateSource;
		}

		private function record_propertyChangeHandler(event:PropertyChangeEvent):void
		{
			if (_inputDocumentsChanged && (event.property == "isLoading") && !_record.isLoading)
			{
				updateScheduleModelForToday();
				_inputDocumentsChanged = false;
			}
		}
	}
}