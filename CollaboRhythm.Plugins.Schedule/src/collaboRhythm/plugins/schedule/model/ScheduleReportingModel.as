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
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	[Bindable]
	public class ScheduleReportingModel
	{
		private var _scheduleModel:ScheduleModel;
		private var _accountId:String;
		private var _currentScheduleGroup:ScheduleGroup;
		private var _currentDateSource:ICurrentDateSource;

		public function ScheduleReportingModel(scheduleModel:ScheduleModel, accountId:String)
		{
			_scheduleModel = scheduleModel;
			_accountId = accountId;
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

		public function findClosestScheduleItemOccurrence(name:String):ScheduleItemOccurrence
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

		public function get currentScheduleGroup():ScheduleGroup
		{
			return _currentScheduleGroup;
		}

		public function set currentScheduleGroup(value:ScheduleGroup):void
		{
			_currentScheduleGroup = value;
		}
	}
}
