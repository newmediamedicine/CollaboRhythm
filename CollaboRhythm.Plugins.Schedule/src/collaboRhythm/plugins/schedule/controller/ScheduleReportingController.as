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
	import collaboRhythm.shared.collaboration.model.CollaborationModel;
	import collaboRhythm.shared.collaboration.model.CollaborationViewSynchronizationEvent;
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
		private var _collaborationLobbyNetConnectionServiceProxy:CollaborationLobbyNetConnectionServiceProxy;

		public function ScheduleReportingController(scheduleModel:ScheduleModel,
													scheduleReportingFullView:ScheduleReportingFullView,
													viewNavigator:ViewNavigator,
													collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy)
		{
			_viewNavigator = viewNavigator;
			_collaborationLobbyNetConnectionServiceProxy = collaborationLobbyNetConnectionServiceProxy as
					CollaborationLobbyNetConnectionServiceProxy;
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			_scheduleModel = scheduleModel;
			_scheduleReportingFullView = scheduleReportingFullView;
			_scheduleReportingModel = _scheduleModel.scheduleReportingModel;

			_collaborationLobbyNetConnectionServiceProxy.addEventListener(getQualifiedClassName(this),
					collaborationViewSynchronization_eventHandler);
		}

		private function collaborationViewSynchronization_eventHandler(event:CollaborationViewSynchronizationEvent):void
		{
			if (event.synchronizeData != null && !isNaN(event.synchronizeData))
			{
				this[event.synchronizeFunction]("remote", event.synchronizeData);
			}
			else
			{
				this[event.synchronizeFunction]("remote");
			}
		}

		public function get viewNavigator():ViewNavigator
		{
			return _viewNavigator;
		}

		public function set viewNavigator(value:ViewNavigator):void
		{
			_viewNavigator = value;
		}

		public function goBack(source:String):void
		{
			if (source == CollaborationLobbyNetConnectionServiceProxy.LOCAL &&
					_collaborationLobbyNetConnectionServiceProxy.collaborationState ==
							CollaborationModel.COLLABORATION_ACTIVE)
			{
				_collaborationLobbyNetConnectionServiceProxy.sendCollaborationViewSynchronization(getQualifiedClassName(this),
						"goBack");
			}

			viewNavigator.popView();
		}

		public function get collaborationLobbyNetConnectionServiceProxy():ICollaborationLobbyNetConnectionServiceProxy
		{
			return _collaborationLobbyNetConnectionServiceProxy;
		}

		public function synchronizeSaving(source:String):void
		{
			if (source == CollaborationLobbyNetConnectionServiceProxy.LOCAL &&
					_collaborationLobbyNetConnectionServiceProxy.collaborationState ==
							CollaborationModel.COLLABORATION_ACTIVE)
			{
				_collaborationLobbyNetConnectionServiceProxy.sendCollaborationViewSynchronization(getQualifiedClassName(this),
						"synchronizeSaving");
			}

			if (_scheduleModel.accountId == _scheduleModel.activeAccount.accountId)
			{
				_scheduleModel.saveChangesToRecord();
			}
		}

		public function synchronizeScheduleGroupReportingViewScrollPosition(source:String,
																			verticalScrollPosition:Number):void
		{
			if (source == CollaborationLobbyNetConnectionServiceProxy.LOCAL &&
					_collaborationLobbyNetConnectionServiceProxy.collaborationState ==
							CollaborationModel.COLLABORATION_ACTIVE)
			{
				_collaborationLobbyNetConnectionServiceProxy.sendCollaborationViewSynchronization(getQualifiedClassName(this),
						"synchronizeScheduleGroupReportingViewScrollPosition", verticalScrollPosition);
			}

			if (source == CollaborationLobbyNetConnectionServiceProxy.REMOTE)
			{
				_scheduleReportingModel.synchronizeScheduleGroupReportingViewScrollPosition(verticalScrollPosition);
			}
		}
	}
}