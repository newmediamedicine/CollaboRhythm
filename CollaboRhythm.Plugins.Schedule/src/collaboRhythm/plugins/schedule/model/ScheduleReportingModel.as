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

    import collaboRhythm.plugins.schedule.shared.model.IScheduleReportingModel;
    import collaboRhythm.plugins.schedule.shared.model.PendingAdherenceItem;
    import collaboRhythm.plugins.schedule.shared.model.ScheduleGroup;
    import collaboRhythm.shared.model.healthRecord.CodedValue;
    import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
    import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
    import collaboRhythm.shared.model.services.ICurrentDateSource;
    import collaboRhythm.shared.model.services.WorkstationKernel;

    import flash.net.URLVariables;

    import mx.collections.ArrayCollection;
    import mx.core.UIComponent;

    [Bindable]
	public class ScheduleReportingModel implements IScheduleReportingModel
	{
		private var _scheduleModel:ScheduleModel;
		private var _accountId:String;
		private var _viewStack:ArrayCollection = new ArrayCollection();
		private var _isReportingCompleted:Boolean = false;
		private var _currentScheduleGroup:ScheduleGroup;
		private var _pendingAdherenceItem:PendingAdherenceItem;
		private var _currentDateSource:ICurrentDateSource;
		private var _handledInvokeEvents:Vector.<String>;

		public function ScheduleReportingModel(scheduleModel:ScheduleModel, accountId:String,
											   handledInvokeEvents:Vector.<String>)
		{
			_scheduleModel = scheduleModel;
			_accountId = accountId;
			_handledInvokeEvents = handledInvokeEvents;
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

		public function createAdherenceItem(scheduleGroup:ScheduleGroup, scheduleItemOccurrence:ScheduleItemOccurrence,
											adherenceItem:AdherenceItem, hideViews:Boolean, createAdherenceItem:Boolean):void
		{
			if (hideViews)
				viewStack.removeAll();
			if (createAdherenceItem)
				_scheduleModel.createAdherenceItem(scheduleItemOccurrence, adherenceItem);
			if (hideViews)
				isReportingCompletedCheck(scheduleGroup);
		}

		public function voidAdherenceItem(scheduleItemOccurrence:ScheduleItemOccurrence):void
		{
			_scheduleModel.voidAdherenceItem(scheduleItemOccurrence);
			isReportingCompleted = false;
		}

		private function isReportingCompletedCheck(scheduleGroup:ScheduleGroup):void
		{
			var isReportingCompletedCheck:Boolean = true;
			for each (var scheduleItemOccurrence:ScheduleItemOccurrence in scheduleGroup.scheduleItemsOccurrencesCollection)
			{
				if (!scheduleItemOccurrence.adherenceItem)
				{
					isReportingCompletedCheck = false;
				}
			}
			isReportingCompleted = isReportingCompletedCheck;
		}

		public function createPendingAdherenceItem(urlVariables:URLVariables):PendingAdherenceItem
		{
			var pendingAdherenceItem:PendingAdherenceItem;

			var name:String = urlVariables.name;
			var success:Boolean = (urlVariables.success == "true");
			if (success)
			{
				var closestScheduleItemOccurrence:ScheduleItemOccurrence = findClosestScheduleItemOccurrence(name, urlVariables.measurements);
				if (closestScheduleItemOccurrence)
				{
					var parentScheduleGroup:ScheduleGroup;
					for each (var scheduleGroup:ScheduleGroup in _scheduleModel.scheduleGroupsCollection)
					{
						for each (var scheduleItemOccurrence:ScheduleItemOccurrence in scheduleGroup.scheduleItemsOccurrencesCollection)
						{
							if (closestScheduleItemOccurrence == scheduleItemOccurrence)
							{
								parentScheduleGroup = scheduleGroup;
							}
						}
					}
					var adherenceItem:AdherenceItem = new AdherenceItem();
					var nameCodedValue:CodedValue = new CodedValue();
					nameCodedValue.text = name;
					adherenceItem.init(nameCodedValue, _accountId, _currentDateSource.now(),
									   closestScheduleItemOccurrence.recurrenceIndex, true);
					pendingAdherenceItem = new PendingAdherenceItem(parentScheduleGroup, closestScheduleItemOccurrence,
																	adherenceItem);
					this.pendingAdherenceItem = pendingAdherenceItem;
				}
			}
			else
			{
				//TODO: on failed reading, give the user feedback to repeat, toggle bluetooth, etc.
			}
			return pendingAdherenceItem;
		}

		public function findClosestScheduleItemOccurrence(name:String, measurements:String):ScheduleItemOccurrence
		{
			var closestScheduleItemOccurrence:ScheduleItemOccurrence;
			for each (var scheduleItemOccurrence:ScheduleItemOccurrence in _scheduleModel.scheduleItemOccurrencesHashMap)
			{
				if (scheduleItemOccurrence.scheduleItem.name.text == name)
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
			return closestScheduleItemOccurrence;
		}

		public function showAdditionalInformationView(additionalInformationView:UIComponent):void
		{
			viewStack.addItem(additionalInformationView);
		}

		public function get viewStack():ArrayCollection
		{
			return _viewStack;
		}

		public function set viewStack(value:ArrayCollection):void
		{
			_viewStack = value;
		}

		public function get isReportingCompleted():Boolean
		{
			return _isReportingCompleted;
		}

		public function set isReportingCompleted(value:Boolean):void
		{
			_isReportingCompleted = value;
		}

		public function get pendingAdherenceItem():PendingAdherenceItem
		{
			return _pendingAdherenceItem;
		}

		public function set pendingAdherenceItem(value:PendingAdherenceItem):void
		{
			_pendingAdherenceItem = value;
		}

		public function get currentScheduleGroup():ScheduleGroup
		{
			return _currentScheduleGroup;
		}

		public function set currentScheduleGroup(value:ScheduleGroup):void
		{
			_currentScheduleGroup = value;
		}

		public function get handledInvokeEvents():Vector.<String>
		{
			return _handledInvokeEvents;
		}
	}
}
