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
	import collaboRhythm.plugins.schedule.shared.model.MoveData;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleModel;
	import collaboRhythm.plugins.schedule.view.ScheduleFullView;
	import collaboRhythm.shared.model.CollaborationRoomNetConnectionServiceProxy;
	import collaboRhythm.shared.model.User;
	
	public class ScheduleFullViewController
	{
		private var _scheduleModel:ScheduleModel;
		private var _scheduleFullView:ScheduleFullView;
		private var _localUserName:String;
		private var _collaborationRoomNetConnectionServiceProxy:CollaborationRoomNetConnectionServiceProxy;
		
		public function ScheduleFullViewController(scheduleModel:ScheduleModel, scheduleFullView:ScheduleFullView, localUserName:String, collaborationRoomNetConnectionServiceProxy:CollaborationRoomNetConnectionServiceProxy)
		{
			_scheduleModel = scheduleModel;
			_scheduleFullView = scheduleFullView;
			_localUserName = localUserName;
			_collaborationRoomNetConnectionServiceProxy = collaborationRoomNetConnectionServiceProxy;
			_collaborationRoomNetConnectionServiceProxy.synchronizeHandler = this;
		}
		
		public function highlightScheduleGroup(moveData:MoveData):void
		{
			_scheduleModel.highlightScheduleGroup(moveData);
		}
		
		public function moveScheduleGroup(moveData:MoveData):void
		{
			_scheduleModel.moveScheduleGroup(moveData);
		}
		
//		public function moveSmartDrawerStart(moveData:MoveData, userName:String = "", collaborationColor:String = "0xFFFFFF"):void
//		{
//			if (userName == "")
//			{
//				_collaborationRoomNetConnectionServiceProxy.sendCollaborationSynchronization("moveSmartDrawerStart", moveData);	
//				collaborationColor = _collaborationRoomNetConnectionServiceProxy.getLocalUserCollaborationColor();
//			}
//			
//			_scheduleModel.moveSmartDrawerStart(moveData, collaborationColor);
//			
//			if (userName != "")
//			{
//				_scheduleModel.locked = true;		
//			}	
//		}
//		
//		public function moveSmartDrawer(moveData:MoveData, userName:String = "", collaborationColor:String = "0xFFFFFF"):void
//		{		
//			_scheduleModel.moveSmartDrawer(moveData, collaborationColor);
//			
//			if (userName == "")
//			{
//				_collaborationRoomNetConnectionServiceProxy.sendCollaborationSynchronization("moveSmartDrawer", moveData);	
//			}
//		}
//		
//		public function moveSmartDrawerEnd(moveData:MoveData, userName:String = "", collaborationColor:String = "0xFFFFFF"):void
//		{
//			_scheduleModel.moveSmartDrawerEnd(moveData, collaborationColor);
//			
//			if (userName == "")
//			{
//				_collaborationRoomNetConnectionServiceProxy.sendCollaborationSynchronization("moveSmartDrawerEnd", moveData);
//			}
//			else
//			{
//				_scheduleModel.locked = false;
//			}
//		}
//		
//		public function moveScheduleItemStart(moveData:MoveData, userName:String = "", collaborationColor:String = "0xFFFFFF"):void
//		{	
//			if (userName == "")
//			{
//				_collaborationRoomNetConnectionServiceProxy.sendCollaborationSynchronization("moveScheduleItemStart", moveData);	
//				collaborationColor = _collaborationRoomNetConnectionServiceProxy.getLocalUserCollaborationColor();
//			}
//			
//			_scheduleModel.moveScheduleItemStart(moveData, collaborationColor);
//			
//			if (userName != "")
//			{
//				_scheduleModel.locked = true;		
//			}
//		}
//		
//		public function moveScheduleItem(moveData:MoveData, userName:String = "", collaborationColor:String = "0xFFFFFF"):void
//		{
//			_scheduleModel.moveScheduleItem(moveData);
//			
//			if (userName == "")
//			{
//				_collaborationRoomNetConnectionServiceProxy.sendCollaborationSynchronization("moveScheduleItem", moveData);
//			}
//		}
//		
//		public function moveScheduleItemEnd(moveData:MoveData, userName:String = "", collaborationColor:String = "0xFFFFFF"):void
//		{
//			_scheduleModel.moveScheduleItemEnd(moveData);
//			
//			if (userName == "")
//			{
//				_collaborationRoomNetConnectionServiceProxy.sendCollaborationSynchronization("moveScheduleItemEnd", moveData);
//			}
//			else
//			{
//				_scheduleModel.locked = false;
//			}
//		}
//		
//		public function moveAdherenceGroupStart(moveData:MoveData, userName:String = "", collaborationColor:String = "0xFFFFFF"):void
//		{
//			if (userName == "")
//			{
//				_collaborationRoomNetConnectionServiceProxy.sendCollaborationSynchronization("moveAdherenceGroupStart", moveData);
//				collaborationColor = _collaborationRoomNetConnectionServiceProxy.getLocalUserCollaborationColor();
//			}
//			
//			_scheduleModel.moveAdherenceGroupStart(moveData, collaborationColor);
//			
//			if (userName != "")
//			{
//				_scheduleModel.locked = true;
//			}
//		}
//		
//		public function moveAdherenceGroup(moveData:MoveData, userName:String = "", collaborationColor:String = "0xFFFFFF"):void
//		{
//			_scheduleModel.moveAdherenceGroup(moveData);
//			
//			if (userName == "")
//			{
//				_collaborationRoomNetConnectionServiceProxy.sendCollaborationSynchronization("moveAdherenceGroup", moveData);
//			}
//		}
//		
//		public function moveAdherenceGroupEnd(moveData:MoveData, userName:String = "", collaborationColor:String = "0xFFFFFF"):void
//		{
//			_scheduleModel.moveAdherenceGroupEnd(moveData);
//			
//			if (userName == "")
//			{
//				_collaborationRoomNetConnectionServiceProxy.sendCollaborationSynchronization("moveAdherenceGroupEnd", moveData);
//			}
//			else
//			{
//				_scheduleModel.locked = false;
//			}
//		}	
//		
//		public function resizeAdherenceWindow(moveData:MoveData, userName:String = "", collaborationColor:String = "0xFFFFFF"):void
//		{
//			_scheduleModel.resizeAdherenceWindow(moveData);
//			
//			if (userName == "")
//			{
//				_collaborationRoomNetConnectionServiceProxy.sendCollaborationSynchronization("resizeAdherenceWindow", moveData);
//			}
//			else
//			{
//				_scheduleModel.locked = false;
//			}
//		}	
	}
}