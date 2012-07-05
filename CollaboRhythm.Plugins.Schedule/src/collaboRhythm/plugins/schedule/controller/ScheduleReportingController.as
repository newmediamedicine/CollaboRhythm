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
	import collaboRhythm.shared.controller.apps.AppEvent;
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
		}

		public function closeScheduleReportingFullView(viaMechanism:String):void
		{
			saveChangesToRecord();
			dispatchEvent(new AppEvent(AppEvent.HIDE_FULL_VIEW, null, null, null, viaMechanism));
		}

		public function saveChangesToRecord():void
		{
			_scheduleModel.saveChangesToRecord();
		}

        public function get viewNavigator():ViewNavigator
        {
            return _viewNavigator;
        }

        public function set viewNavigator(value:ViewNavigator):void
        {
            _viewNavigator = value;
        }

		public function goBack():void
		{
			_viewNavigator.popView();
		}

		public function get collaborationLobbyNetConnectionServiceProxy():ICollaborationLobbyNetConnectionServiceProxy
		{
			return _collaborationLobbyNetConnectionServiceProxy;
		}
	}
}