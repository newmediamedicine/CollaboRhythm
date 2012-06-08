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
	import collaboRhythm.shared.collaboration.model.CollaborationViewSynchronizationEvent;

	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;

	import spark.components.ViewNavigator;

	public class ScheduleClockController extends EventDispatcher
	{
		private var _scheduleAppController:ScheduleAppController;
		private var _scheduleModel:ScheduleModel;
		private var _scheduleWidgetView:ScheduleClockWidgetView;
		private var _viewNavigator:ViewNavigator;

		private var _collaborationLobbyNetConnectionServiceProxy:CollaborationLobbyNetConnectionServiceProxy;

		public function ScheduleClockController(scheduleAppController:ScheduleAppController,
												scheduleModel:ScheduleModel, scheduleWidgetView:ScheduleClockWidgetView,
												viewNavigator:ViewNavigator)
		{
			_scheduleAppController = scheduleAppController;
			_scheduleModel = scheduleModel;
			_scheduleWidgetView = scheduleWidgetView;
			_viewNavigator = viewNavigator;

			_collaborationLobbyNetConnectionServiceProxy = _scheduleAppController.collaborationLobbyNetConnectionServiceProxy as
					CollaborationLobbyNetConnectionServiceProxy;
			_collaborationLobbyNetConnectionServiceProxy.addEventListener(getQualifiedClassName(this),
					collaborationViewSynchronization_eventHandler);
		}

		private function collaborationViewSynchronization_eventHandler(event:CollaborationViewSynchronizationEvent):void
		{
			if (event.synchronizeData)
			{
				this[event.synchronizeFunction]("remote", event.synchronizeData);
			}
			else
			{
				this[event.synchronizeFunction]("remote");
			}
		}

		public function openScheduleReportingFullView(source:String, selectedScheduleGroup:ScheduleGroup):void
		{
//			if (source == "local")
//			{
//				_collaborationLobbyNetConnectionServiceProxy.sendCollaborationViewSynchronization(getQualifiedClassName(this),
//						"openScheduleReportingFullView",
//						selectedScheduleGroup);
//			}
//
//			for each (var scheduleGroup:ScheduleGroup in _scheduleModel.scheduleGroupsCollection)
//			{
//				if (scheduleGroup.dateStart.getTime() == selectedScheduleGroup.dateStart.getTime() &&
//						scheduleGroup.dateEnd.getTime() == selectedScheduleGroup.dateEnd.getTime())
//				{
//					_scheduleModel.scheduleReportingModel.currentScheduleGroup = scheduleGroup;
//				}
//			}

			_scheduleModel.scheduleReportingModel.currentScheduleGroup = selectedScheduleGroup;

			var scheduleViewInitializationParameters:ScheduleViewInitializationParameters = new ScheduleViewInitializationParameters(_scheduleAppController,
					_scheduleModel);

			_viewNavigator.pushView(ScheduleReportingFullView, scheduleViewInitializationParameters);
		}
	}
}