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
	import collaboRhythm.plugins.schedule.model.ScheduleReportingModel;
	import collaboRhythm.plugins.schedule.view.ScheduleReportingFullView;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;

	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;

	import mx.logging.ILogger;
	import mx.logging.Log;

	import spark.components.ViewNavigator;

	public class ScheduleReportingController extends EventDispatcher
	{
		private var _scheduleModel:ScheduleModel;
		private var _scheduleReportingFullView:ScheduleReportingFullView;
		[Bindable]
		private var _scheduleReportingModel:ScheduleReportingModel;
		protected var _logger:ILogger;
		private var _viewNavigator:ViewNavigator;

		private var _collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy;
		private var _synchronizationService:SynchronizationService;

		public function ScheduleReportingController(scheduleModel:ScheduleModel,
													scheduleReportingFullView:ScheduleReportingFullView,
													viewNavigator:ViewNavigator,
													collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy)
		{
			_viewNavigator = viewNavigator;
			_collaborationLobbyNetConnectionServiceProxy = collaborationLobbyNetConnectionServiceProxy;
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			_scheduleModel = scheduleModel;
			_scheduleReportingFullView = scheduleReportingFullView;
			_scheduleReportingModel = _scheduleModel.scheduleReportingModel;

			_synchronizationService = new SynchronizationService(this, collaborationLobbyNetConnectionServiceProxy as
					CollaborationLobbyNetConnectionServiceProxy);
		}

		public function goBack():void
		{
			viewNavigator.popView();
		}

		public function save():void
		{
			if (_scheduleModel.accountId == _scheduleModel.activeAccount.accountId)
			{
				if (_synchronizationService.synchronize("save"))
				{
					return;
				}

				_scheduleModel.saveChangesToRecord();
			}
		}

		public function setScheduleGroupReportingViewScrollPosition(verticalScrollPosition:Number):void
		{
			if (_synchronizationService.synchronize("setScheduleGroupReportingViewScrollPosition",
					verticalScrollPosition, false))
			{
				return;
			}

			_scheduleReportingModel.setScheduleGroupReportingViewScrollPosition(verticalScrollPosition);
		}

		public function get collaborationLobbyNetConnectionServiceProxy():ICollaborationLobbyNetConnectionServiceProxy
		{
			return _collaborationLobbyNetConnectionServiceProxy;
		}

		public function get viewNavigator():ViewNavigator
		{
			return _viewNavigator;
		}

		public function set viewNavigator(value:ViewNavigator):void
		{
			_viewNavigator = value;
		}

		public function destroy():void
		{
			if (_synchronizationService)
			{
				_synchronizationService.removeEventListener(this);
			}
		}
	}
}