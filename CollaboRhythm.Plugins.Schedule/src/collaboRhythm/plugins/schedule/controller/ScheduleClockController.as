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
	import collaboRhythm.plugins.schedule.model.ScheduleViewInitializationParameters;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleGroup;
	import collaboRhythm.plugins.schedule.view.ScheduleClockWidgetView;
	import collaboRhythm.plugins.schedule.view.ScheduleReportingFullView;

	import flash.events.EventDispatcher;

	import spark.components.ViewNavigator;

	public class ScheduleClockController extends EventDispatcher
	{
		private var _scheduleAppController:ScheduleAppController;
		private var _scheduleModel:ScheduleModel;
		private var _scheduleWidgetView:ScheduleClockWidgetView;
		private var _viewNavigator:ViewNavigator;

		public function ScheduleClockController(scheduleAppController:ScheduleAppController,
												scheduleModel:ScheduleModel,
												scheduleWidgetView:ScheduleClockWidgetView,
												viewNavigator:ViewNavigator)
		{
			_scheduleAppController = scheduleAppController;
			_scheduleModel = scheduleModel;
			_scheduleWidgetView = scheduleWidgetView;
			_viewNavigator = viewNavigator;
		}

		public function openScheduleReportingFullView(scheduleGroup:ScheduleGroup, viaMechanism:String):void
		{
			_scheduleModel.scheduleReportingModel.currentScheduleGroup = scheduleGroup;

			var scheduleViewInitializationParameters:ScheduleViewInitializationParameters = new ScheduleViewInitializationParameters(_scheduleAppController, _scheduleModel);

			_viewNavigator.pushView(ScheduleReportingFullView, scheduleViewInitializationParameters);
//			dispatchEvent(new AppEvent(AppEvent.SHOW_FULL_VIEW, null, null, "Schedule", viaMechanism));
		}
	}
}