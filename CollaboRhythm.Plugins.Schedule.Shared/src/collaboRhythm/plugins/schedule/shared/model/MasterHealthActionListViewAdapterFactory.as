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
package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.IComponentContainer;

	import mx.collections.ArrayCollection;

	public class MasterHealthActionListViewAdapterFactory
	{
		private var _factoryArray:Array;

		public function MasterHealthActionListViewAdapterFactory(componentContainer:IComponentContainer)
		{
			_factoryArray = componentContainer.resolveAll(IHealthActionListViewAdapterFactory);
		}
		
		public function createUnscheduledHealthActionViewAdapters(record:Record):ArrayCollection
		{
			var unscheduledHealthActionViewAdapters:ArrayCollection = new ArrayCollection();
			for each (var healthActionListViewAdapterFactory:IHealthActionListViewAdapterFactory in _factoryArray)
			{
				healthActionListViewAdapterFactory.createUnscheduledHealthActionViewAdapters(record, unscheduledHealthActionViewAdapters);
			}

			return unscheduledHealthActionViewAdapters;
		}

		public function createScheduledHealthActionViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
															   scheduleModel:IScheduleModel):IHealthActionListViewAdapter
		{
			var currentHealthActionListViewAdapter:IHealthActionListViewAdapter = null;
			for each (var healthActionListViewAdapterFactory:IHealthActionListViewAdapterFactory in _factoryArray)
			{
				var healthActionListViewAdapter:IHealthActionListViewAdapter = healthActionListViewAdapterFactory.createScheduledHealthActionViewAdapter(scheduleItemOccurrence,
						scheduleModel, currentHealthActionListViewAdapter);
				if (healthActionListViewAdapter)
					currentHealthActionListViewAdapter = healthActionListViewAdapter;
			}

			return currentHealthActionListViewAdapter;
		}
	}
}
