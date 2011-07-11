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
	import collaboRhythm.shared.model.EquipmentScheduleItem;
	import collaboRhythm.shared.model.MedicationScheduleItem;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
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
	public class ScheduleModel extends EventDispatcher
	{
		private var _record:Record;
		private var _viewFactory:IScheduleViewFactory;
		private var _isInitialized:Boolean = false;
		private var _scheduleGroupsHashMap:HashMap = new HashMap();
		private var _scheduleGroupsCollection:ArrayCollection = new ArrayCollection();
		private var _scheduleItemOccurrencesHashMap:HashMap = new HashMap();

		private var _scheduleReportingModel:ScheduleReportingModel;
		private var _scheduleTimelineModel:ScheduleTimelineModel;

		private var _currentDateSource:ICurrentDateSource;

		private var _logger:ILogger;

		private var _changeWatchers:Vector.<ChangeWatcher> = new Vector.<ChangeWatcher>();

		public function ScheduleModel(componentContainer:IComponentContainer, record:Record)
		{
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));

			_record = record;

			_changeWatchers.push(BindingUtils.bindSetter(init, _record.medicationOrdersModel, "isStitched"));
			_changeWatchers.push(BindingUtils.bindSetter(init, _record.medicationScheduleItemsModel,
														 "isStitched"));
			_changeWatchers.push(BindingUtils.bindSetter(init, _record.equipmentModel, "isStitched"));
			_changeWatchers.push(BindingUtils.bindSetter(init, _record.equipmentScheduleItemsModel,
														 "isStitched"));
			_changeWatchers.push(BindingUtils.bindSetter(init, _record.adherenceItemsModel, "isStitched"));

			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
			_viewFactory = new MasterScheduleViewFactory(componentContainer);
		}

		private function init(isStitched:Boolean):void
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
			_scheduleItemOccurrencesHashMap[scheduleItemOccurrence.scheduleItem.id + scheduleItemOccurrence.recurrenceIndex] = scheduleItemOccurrence;
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
				_scheduleReportingModel = new ScheduleReportingModel(this);
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
	}
}