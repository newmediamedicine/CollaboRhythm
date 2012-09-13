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
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.controller.apps.AppEvent;

	import flash.events.EventDispatcher;

	import spark.components.ViewNavigator;

	public class ScheduleClockController extends EventDispatcher
	{
		private var _scheduleAppController:ScheduleAppController;
		private var _scheduleModel:ScheduleModel;
		private var _scheduleWidgetView:ScheduleClockWidgetView;
		private var _viewNavigator:ViewNavigator;

		private var _synchronizationService:SynchronizationService;

		public function ScheduleClockController(scheduleAppController:ScheduleAppController,
												scheduleModel:ScheduleModel, scheduleWidgetView:ScheduleClockWidgetView,
												viewNavigator:ViewNavigator)
		{
			_scheduleAppController = scheduleAppController;
			_scheduleModel = scheduleModel;
			_scheduleWidgetView = scheduleWidgetView;
			_viewNavigator = viewNavigator;

			_synchronizationService = new SynchronizationService(this,
					scheduleAppController.collaborationLobbyNetConnectionServiceProxy as
							CollaborationLobbyNetConnectionServiceProxy);
		}

		public function openScheduleReportingFullView(calledLocally:Boolean, selectedScheduleGroup:ScheduleGroup):void
		{
			if (_synchronizationService.synchronize("openScheduleReportingFullView", calledLocally,
					selectedScheduleGroup))
			{
				return;
			}

			for each (var scheduleGroup:ScheduleGroup in _scheduleModel.scheduleGroupsCollection)
			{
				if (scheduleGroup.dateStart.getTime() == selectedScheduleGroup.dateStart.getTime() &&
						scheduleGroup.dateEnd.getTime() == selectedScheduleGroup.dateEnd.getTime())
				{
					_scheduleModel.scheduleReportingModel.currentScheduleGroup = scheduleGroup;
				}
			}

			var scheduleViewInitializationParameters:ScheduleViewInitializationParameters = new ScheduleViewInitializationParameters(_scheduleAppController,
					_scheduleModel);

			_viewNavigator.pushView(ScheduleReportingFullView, scheduleViewInitializationParameters);
		}

		public function showScheduleTimelineFullView(calledLocally:Boolean, viaMechanism:String):void
		{
			if (_synchronizationService.synchronize("showScheduleTimelineFullView", calledLocally,
					viaMechanism))
			{
				return;
			}

			dispatchEvent(new AppEvent(AppEvent.SHOW_FULL_VIEW, _scheduleAppController, null, null, viaMechanism));
		}
	}
}