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

	import castle.flexbridge.reflection.ClassInfo;
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.schedule.shared.model.IScheduleReportingModel;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleViewFactory;
	import collaboRhythm.plugins.schedule.shared.view.ScheduleItemClockViewBase;
	import collaboRhythm.plugins.schedule.shared.view.ScheduleItemReportingViewBase;
	import collaboRhythm.plugins.schedule.shared.view.ScheduleItemTimelineViewBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.IComponentContainer;

	import flash.events.InvokeEvent;
	import flash.utils.Dictionary;

	public class MasterScheduleViewFactory implements IScheduleViewFactory
	{
		private var _factoryDictionary:Dictionary = new Dictionary();

		public function MasterScheduleViewFactory(componentContainer:IComponentContainer)
		{
			var factoryArray:Array = componentContainer.resolveAll(IScheduleViewFactory);

			for each (var factory:IScheduleViewFactory in factoryArray)
			{
				_factoryDictionary[factory.scheduleItemType.name] = factory;
			}
		}

		public function get scheduleItemType():ClassInfo
		{
			return null;
		}

		public function createScheduleItemClockView(scheduleItemOccurrence:ScheduleItemOccurrence):ScheduleItemClockViewBase
		{
			return _factoryDictionary[ReflectionUtils.getClassInfo(ReflectionUtils.getClass(scheduleItemOccurrence.scheduleItem)).name].createScheduleItemClockView(scheduleItemOccurrence);
		}

		public function createScheduleItemReportingView(scheduleItemOccurrence:ScheduleItemOccurrence,
														scheduleReportingModel:IScheduleReportingModel,
														activeAccountId:String,
														handledInvokeEvents:Vector.<String>):ScheduleItemReportingViewBase
		{
			return _factoryDictionary[ReflectionUtils.getClassInfo(ReflectionUtils.getClass(scheduleItemOccurrence.scheduleItem)).name].createScheduleItemReportingView(scheduleItemOccurrence,
																																										scheduleReportingModel,
																																										activeAccountId, handledInvokeEvents);
		}

		public function createScheduleItemTimelineView(scheduleItemOccurrence:ScheduleItemOccurrence):ScheduleItemTimelineViewBase
		{
			return _factoryDictionary[ReflectionUtils.getClassInfo(ReflectionUtils.getClass(scheduleItemOccurrence.scheduleItem)).name].createScheduleItemTimelineView(scheduleItemOccurrence);
		}
	}
}
