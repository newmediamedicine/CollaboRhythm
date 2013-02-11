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

	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import mx.collections.ArrayCollection;

	/**
	 * Factory interface which a CollaboRhythm plugin can use to provide custom IHealthActionListViewAdapter instances.
	 * Each factory can support one or more type of health actions. All registered factories will be given a chance to
	 * create or modify the list view adapter for a given health action.
	 * @see IHealthActionListViewAdapter
	 */
	public interface IHealthActionListViewAdapterFactory
    {
		/**
		 * Creates one or more view adapters which will be used for creating the list of unscheduled health actions
		 * in the health actions app.
		 * @param healthActionModelDetailsProvider Details the factory can use to create the adapter(s)
		 * @param adapters The list of adapters to update
		 */
		function createUnscheduledHealthActionViewAdapters(healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
														   adapters:ArrayCollection):void;

		/**
		 * Creates or modifies a view adapter for the specified schedule item occurrence (the scheduled health action).
		 * @param scheduleItemOccurrence The occurrence corresponding to the scheduled health action
		 * @param healthActionModelDetailsProvider Details the factory can use to create or modify the adapter
		 * @param currentHealthActionListViewAdapter The current adapter which can be modified or replaced by this factory
		 * @return The new or modified adapter. The currentHealthActionListViewAdapter should be returned if this factory
		 * does not want to create or modify an adapter for the specified health action.
		 */
		function createScheduledHealthActionViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
														healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
														currentHealthActionListViewAdapter:IHealthActionListViewAdapter):IHealthActionListViewAdapter;
    }
}
