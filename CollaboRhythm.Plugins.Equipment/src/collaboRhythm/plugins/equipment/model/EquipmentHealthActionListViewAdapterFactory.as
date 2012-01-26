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
package collaboRhythm.plugins.equipment.model
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapterFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.document.EquipmentScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import mx.collections.ArrayCollection;

	public class EquipmentHealthActionListViewAdapterFactory implements IHealthActionListViewAdapterFactory
	{
		public function EquipmentHealthActionListViewAdapterFactory()
		{
		}

		public function createUnscheduledHealthActionViewAdapters(record:Record, adapters:ArrayCollection):void
		{

		}

		public function createScheduledHealthActionViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
															   healthActionModelDetailsProviderModel:IHealthActionModelDetailsProvider,
															   currentHealthActionListViewAdapter:IHealthActionListViewAdapter):IHealthActionListViewAdapter
		{
			if (ReflectionUtils.getClass(scheduleItemOccurrence.scheduleItem) == EquipmentScheduleItem)
				return new EquipmentHealthActionListViewAdapter(scheduleItemOccurrence, healthActionModelDetailsProviderModel);
			else
				return currentHealthActionListViewAdapter;
		}
	}
}
