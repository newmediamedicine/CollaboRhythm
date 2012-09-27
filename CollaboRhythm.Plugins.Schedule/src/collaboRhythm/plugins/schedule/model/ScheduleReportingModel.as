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
	import collaboRhythm.plugins.schedule.shared.model.ScheduleGroup;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionSchedule;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import spark.collections.Sort;

	[Bindable]
	public class ScheduleReportingModel
	{
		private var _scheduleModel:ScheduleModel;
		private var _accountId:String;
		private var _currentScheduleGroup:ScheduleGroup;
		private var _currentDateSource:ICurrentDateSource;
		private var _scheduleGroupReportingViewScrollPosition:Number;

		public function ScheduleReportingModel(scheduleModel:ScheduleModel, accountId:String)
		{
			_scheduleModel = scheduleModel;
			_accountId = accountId;
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

		public function sortScheduleItemOccurrences():void
		{
			var sort:Sort = new Sort();
			sort.compareFunction = scheduleGroupReportingViewCompareFunction;

			for each (var scheduleGroup:ScheduleGroup in _scheduleModel.scheduleGroupsCollection)
			{
				if (scheduleGroup.scheduleItemsOccurrencesCollection.sort == null)
				{
					scheduleGroup.scheduleItemsOccurrencesCollection.sort = sort;
					scheduleGroup.scheduleItemsOccurrencesCollection.refresh();
				}
			}
		}

		// TODO: Update once we update to new schemas
		private function scheduleGroupReportingViewCompareFunction(aScheduleItemOccurrence:ScheduleItemOccurrence,
																   bScheduleItemOccurrence:ScheduleItemOccurrence,
																   array:Array = null):int
		{
			if (aScheduleItemOccurrence.scheduleItem.schedueItemType() == MedicationScheduleItem.MEDICATION)
			{
				if (bScheduleItemOccurrence.scheduleItem.schedueItemType() == MedicationScheduleItem.MEDICATION)
				{
					if (aScheduleItemOccurrence.scheduleItem.name.text ==
							bScheduleItemOccurrence.scheduleItem.name.text)
					{
						return 0;
					}
					else if (aScheduleItemOccurrence.scheduleItem.name.text >
							bScheduleItemOccurrence.scheduleItem.name.text)
					{
						return 1;
					}
					else
					{
						return -1;
					}
				}
				else
				{
					return -1;
				}
			}
			else
			{
				if (bScheduleItemOccurrence.scheduleItem.schedueItemType() == MedicationScheduleItem.MEDICATION)
				{
					return 1;
				}
				else
				{
					var aHealthActionSchedule:HealthActionSchedule = aScheduleItemOccurrence.scheduleItem as
							HealthActionSchedule;
					if (aHealthActionSchedule.scheduledEquipment != null)
					{
						return -1;
					}
					else
					{
						return 1;
					}
				}

			}
		}

		public function get currentScheduleGroup():ScheduleGroup
		{
			return _currentScheduleGroup;
		}

		public function set currentScheduleGroup(value:ScheduleGroup):void
		{
			_currentScheduleGroup = value;
		}

		public function setScheduleGroupReportingViewScrollPosition(verticalScrollPosition:Number):void
		{
			scheduleGroupReportingViewScrollPosition = verticalScrollPosition;
		}

		public function get scheduleGroupReportingViewScrollPosition():Number
		{
			return _scheduleGroupReportingViewScrollPosition;
		}

		public function set scheduleGroupReportingViewScrollPosition(value:Number):void
		{
			_scheduleGroupReportingViewScrollPosition = value;
		}
	}
}
