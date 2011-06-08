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
	import collaboRhythm.shared.model.AdherenceItem;
	import collaboRhythm.plugins.schedule.model.ScheduleGroup;
	import collaboRhythm.shared.model.ScheduleItemBase;
	import collaboRhythm.plugins.schedule.model.ScheduleModel;
	import collaboRhythm.plugins.schedule.view.ScheduleFullView;
	import collaboRhythm.plugins.schedule.view.ScheduleGroupReportingView;
	import collaboRhythm.plugins.schedule.view.ScheduleWidgetView;
	import collaboRhythm.shared.model.CollaborationRoomNetConnectionServiceProxy;

    import mx.core.IVisualElementContainer;

    public class ScheduleWidgetViewController
	{
		private var _isWorkstationMode:Boolean;
		private var _scheduleModel:ScheduleModel;
		private var _scheduleWidgetView:ScheduleWidgetView;
        private var _fullParentContainer:IVisualElementContainer;
		private var _localUserName:String;
		private var _collaborationRoomNetConnectionServiceProxy:CollaborationRoomNetConnectionServiceProxy;
		
		public function ScheduleWidgetViewController(isWorkstationMode:Boolean, scheduleModel:ScheduleModel, scheduleWidgetView:ScheduleWidgetView, fullParentContainer:IVisualElementContainer)//, localUserName:String, collaborationRoomNetConnectionServiceProxy:CollaborationRoomNetConnectionServiceProxy)
		{
			_isWorkstationMode = isWorkstationMode;
			_scheduleModel = scheduleModel;
			_scheduleWidgetView = scheduleWidgetView;
            _fullParentContainer = fullParentContainer;
//			_localUserName = localUserName;
//			_collaborationRoomNetConnectionServiceProxy = collaborationRoomNetConnectionServiceProxy;
//			_collaborationRoomNetConnectionServiceProxy.synchronizeHandler = this;
		}
		
		public function get isWorkstationMode():Boolean
		{
			return _isWorkstationMode;
		}

		public function openScheduleGroupReportingView(scheduleGroup:ScheduleGroup):void
		{
			if (!_isWorkstationMode)
			{
                _scheduleModel.openScheduleGroupReportingView(scheduleGroup);
				_scheduleWidgetView.showScheduleGroupReportingView();
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