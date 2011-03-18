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
	import collaboRhythm.plugins.schedule.shared.model.AdherenceItem;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleGroup;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleItemBase;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleModel;
	import collaboRhythm.plugins.schedule.view.ScheduleFullView;
	import collaboRhythm.plugins.schedule.view.ScheduleGroupReportingView;
	import collaboRhythm.plugins.schedule.view.ScheduleWidgetView;
	import collaboRhythm.shared.model.CollaborationRoomNetConnectionServiceProxy;

	public class ScheduleWidgetViewController
	{
		private var _isWorkstationMode:Boolean;
		private var _scheduleModel:ScheduleModel;
		private var _scheduleWidgetView:ScheduleWidgetView;
		private var _localUserName:String;
		private var _collaborationRoomNetConnectionServiceProxy:CollaborationRoomNetConnectionServiceProxy;
		
		public function ScheduleWidgetViewController(isWorkstationMode:Boolean, scheduleModel:ScheduleModel, scheduleWidgetView:ScheduleWidgetView, localUserName:String, collaborationRoomNetConnectionServiceProxy:CollaborationRoomNetConnectionServiceProxy)
		{
			_isWorkstationMode = isWorkstationMode;
			_scheduleModel = scheduleModel;
			_scheduleWidgetView = scheduleWidgetView;
			_localUserName = localUserName;
			_collaborationRoomNetConnectionServiceProxy = collaborationRoomNetConnectionServiceProxy;
			_collaborationRoomNetConnectionServiceProxy.synchronizeHandler = this;
		}
		
		public function openScheduleGroupReportingView(scheduleGroup:ScheduleGroup):void
		{
			if (!_isWorkstationMode)
			{
				_scheduleModel.openScheduleGroupReportingView(scheduleGroup);
			}
		}
		
		public function closeScheduleGroupReportingView():void
		{
			_scheduleModel.closeScheduleGroupReportingView();
		}
		
		public function createAdherenceItem(scheduleGroup:ScheduleGroup, scheduleItem:ScheduleItemBase, adherenceItem:AdherenceItem):void
		{
			_scheduleModel.createAdherenceItem(scheduleGroup, scheduleItem, adherenceItem);		
		}
	}
}