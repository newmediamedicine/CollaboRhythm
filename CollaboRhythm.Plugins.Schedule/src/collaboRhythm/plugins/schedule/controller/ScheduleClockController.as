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
package collaboRhythm.plugins.schedule.controller
{

	import collaboRhythm.plugins.schedule.model.ScheduleModel;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleGroup;
	import collaboRhythm.plugins.schedule.view.ScheduleClockWidgetView;
	import collaboRhythm.shared.controller.apps.AppEvent;

	import flash.events.EventDispatcher;

	public class ScheduleClockController extends EventDispatcher
	{
		private var _scheduleModel:ScheduleModel;
		private var _scheduleWidgetView:ScheduleClockWidgetView;

		public function ScheduleClockController(scheduleModel:ScheduleModel, scheduleWidgetView:ScheduleClockWidgetView)
		{
			_scheduleModel = scheduleModel;
			_scheduleWidgetView = scheduleWidgetView;
		}

		public function openScheduleReportingFullView(scheduleGroup:ScheduleGroup):void
		{
			_scheduleModel.scheduleReportingModel.currentScheduleGroup = scheduleGroup;
			dispatchEvent(new AppEvent(AppEvent.SHOW_FULL_VIEW, null, null, "Schedule"));
		}
	}
}