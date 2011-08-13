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
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
	import collaboRhythm.shared.model.healthRecord.document.EquipmentScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;

	import j2as3.collection.HashMap;

	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import mx.logging.ILogger;
	import mx.logging.Log;

	[Bindable]
	public class ScheduleModel extends EventDispatcher implements IScheduleGroupsProvider
	{
		/**
		 * Key to the ScheduleModel instance in Record.appData
		 */
		public static const SCHEDULE_MODEL_KEY:String = "scheduleModel";
		private var _record:Record;
		private var _accountId:String;
		private var _viewFactory:IScheduleViewFactory;
		private var _isInitialized:Boolean = false;
		private var _scheduleGroupsHashMap:HashMap = new HashMap();
		private var _scheduleGroupsCollection:ArrayCollection = new ArrayCollection();
		private var _scheduleItemOccurrencesHashMap:HashMap = new HashMap();

		private var _scheduleReportingModel:ScheduleReportingModel;
		private var _scheduleTimelineModel:ScheduleTimelineModel;
		private var _currentPerformanceModel:CurrentPerformanceModel;

		private var _currentDateSource:ICurrentDateSource;

		private var _logger:ILogger;

		private var _changeWatchers:Vector.<ChangeWatcher> = new Vector.<ChangeWatcher>();
		private var _handledInvokeEvents:Vector.<String>;


		public function ScheduleModel(componentContainer:IComponentContainer, record:Record, accountId:String,
									  handledInvokeEvents:Vector.<String>)
		{
			_accountId = accountId;
			_handledInvokeEvents = handledInvokeEvents;
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));

			_record = record;

			_changeWatchers.push(BindingUtils.bindSetter(init, _record.medicationOrdersModel, "isStitched"));
			_changeWatchers.push(BindingUtils.bindSetter(init, _record.medicationScheduleItemsModel,
														 "isStitched"));
			_changeWatchers.push(BindingUtils.bindSetter(init, _record.equipmentModel, "isStitched"));
			_changeWatchers.push(BindingUtils.bindSetter(init, _record.equipmentScheduleItemsModel,
														 "isStitched"));
			_changeWatchers.push(BindingUtils.bindSetter(init, _record.adherenceItemsModel, "isStitched"));
			_changeWatchers.push(BindingUtils.bindSetter(init, _record.vitalSignsModel, "isInitialized"));

			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
			_viewFactory = new MasterScheduleViewFactory(componentContainer);
		}

		private function init(isStitched:Boolean):void
		{
			if (_record.medicationOrdersModel.isStitched && _record.medicationScheduleItemsModel.isStitched && _record.equipmentModel.isStitched && _record.equipmentScheduleItemsModel.isStitched && _record.adherenceItemsModel.isStitched && _record.vitalSignsModel.isInitialized)
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
//				currentPerformanceModel.determineAdherence();
				// TODO: isInitialized = true should probably be done after scheduleTimelineModel.determineStacking(), but this needs to be tested
				isInitialized = true;
				scheduleTimelineModel.determineStacking();
				dispatchEvent(new ScheduleModelEvent(ScheduleModelEvent.INITIALIZED));
			}
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
			_scheduleItemOccurrencesHashMap.put(scheduleItemOccurrence.id, scheduleItemOccurrence);
		}

		public function createScheduleGroup(scheduleItemOccurrence:ScheduleItemOccurrence, moving:Boolean,
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

		public function get now():Date
		{
			return _currentDateSource.now();
		}

		public function get viewFactory():IScheduleViewFactory
		{
			return _viewFactory;
		}

		public function createAdherenceItem(scheduleItemOccurrence:ScheduleItemOccurrence,
											adherenceItem:AdherenceItem):void
		{
			scheduleItemOccurrence.adherenceItem = adherenceItem;
			adherenceItem.pendingAction = DocumentBase.ACTION_CREATE;
			_record.addDocument(adherenceItem);
			_record.addNewRelationship(ScheduleItemBase.RELATION_TYPE_ADHERENCE_ITEM, scheduleItemOccurrence.scheduleItem, adherenceItem);
			for each (var adherenceResult:DocumentBase in adherenceItem.adherenceResults)
			{
				adherenceResult.pendingAction = DocumentBase.ACTION_CREATE;
				_record.addDocument(adherenceResult);
				_record.addNewRelationship(AdherenceItem.RELATION_TYPE_ADHERENCE_RESULT, adherenceItem, adherenceResult)
			}
//			currentPerformanceModel.determineAdherence();
		}

		public function voidAdherenceItem(scheduleItemOccurrence:ScheduleItemOccurrence):void
		{
			_record.removeDocument(scheduleItemOccurrence.adherenceItem, DocumentBase.ACTION_VOID, "deleted by user", true);
			scheduleItemOccurrence.adherenceItem = null;
//			currentPerformanceModel.determineAdherence();
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
				_scheduleReportingModel = new ScheduleReportingModel(this, _accountId, _handledInvokeEvents);
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

		public function get currentPerformanceModel():CurrentPerformanceModel
		{
			if (!_currentPerformanceModel)
			{
				_currentPerformanceModel = new CurrentPerformanceModel(this, _record);
			}
			return _currentPerformanceModel;
		}

		public function destroy():void
		{
			_record = null;
			_scheduleReportingModel = null;
			_scheduleTimelineModel = null;
			for each (var changeWatcher:ChangeWatcher in _changeWatchers)
			{
				changeWatcher.unwatch();
			}
		}

		public function updateScheduleItems(scheduleGroup:ScheduleGroup):void
		{
			for each (var scheduleItemOccurrence:ScheduleItemOccurrence in scheduleGroup.scheduleItemsOccurrencesCollection)
			{
				var scheduleItem:ScheduleItemBase = scheduleItemOccurrence.scheduleItem;
				scheduleItem.rescheduleItem(_currentDateSource.now(), scheduleGroup.dateStart, scheduleGroup.dateEnd);
				scheduleItem.pendingAction = DocumentBase.ACTION_UPDATE;
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
	}
}