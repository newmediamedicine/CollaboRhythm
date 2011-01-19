package collaboRhythm.workstation.apps.schedule.controller
{
	import collaboRhythm.workstation.apps.schedule.model.MoveData;
	import collaboRhythm.workstation.apps.schedule.model.ScheduleModel;
	import collaboRhythm.workstation.apps.schedule.view.ScheduleFullView;
	import collaboRhythm.workstation.model.CollaborationRoomNetConnectionServiceProxy;
	import collaboRhythm.workstation.model.User;
	
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
		
		public function moveSmartDrawerStart(moveData:MoveData, userName:String = "", collaborationColor:String = "0xFFFFFF"):void
		{
			if (userName == "")
			{
				_collaborationRoomNetConnectionServiceProxy.sendCollaborationSynchronization("moveSmartDrawerStart", moveData);	
				collaborationColor = _collaborationRoomNetConnectionServiceProxy.getLocalUserCollaborationColor();
			}
			
			_scheduleModel.moveSmartDrawerStart(moveData, collaborationColor);
			
			if (userName != "")
			{
				_scheduleModel.locked = true;		
			}	
		}
		
		public function moveSmartDrawer(moveData:MoveData, userName:String = "", collaborationColor:String = "0xFFFFFF"):void
		{		
			_scheduleModel.moveSmartDrawer(moveData, collaborationColor);
			
			if (userName == "")
			{
				_collaborationRoomNetConnectionServiceProxy.sendCollaborationSynchronization("moveSmartDrawer", moveData);	
			}
		}
		
		public function moveSmartDrawerEnd(moveData:MoveData, userName:String = "", collaborationColor:String = "0xFFFFFF"):void
		{
			_scheduleModel.moveSmartDrawerEnd(moveData, collaborationColor);
			
			if (userName == "")
			{
				_collaborationRoomNetConnectionServiceProxy.sendCollaborationSynchronization("moveSmartDrawerEnd", moveData);
			}
			else
			{
				_scheduleModel.locked = false;
			}
		}
		
		public function moveScheduleItemStart(moveData:MoveData, userName:String = "", collaborationColor:String = "0xFFFFFF"):void
		{	
			if (userName == "")
			{
				_collaborationRoomNetConnectionServiceProxy.sendCollaborationSynchronization("moveScheduleItemStart", moveData);	
				collaborationColor = _collaborationRoomNetConnectionServiceProxy.getLocalUserCollaborationColor();
			}
			
			_scheduleModel.moveScheduleItemStart(moveData, collaborationColor);
			
			if (userName != "")
			{
				_scheduleModel.locked = true;		
			}
		}
		
		public function moveScheduleItem(moveData:MoveData, userName:String = "", collaborationColor:String = "0xFFFFFF"):void
		{
			_scheduleModel.moveScheduleItem(moveData);
			
			if (userName == "")
			{
				_collaborationRoomNetConnectionServiceProxy.sendCollaborationSynchronization("moveScheduleItem", moveData);
			}
		}
		
		public function moveScheduleItemEnd(moveData:MoveData, userName:String = "", collaborationColor:String = "0xFFFFFF"):void
		{
			_scheduleModel.moveScheduleItemEnd(moveData);
			
			if (userName == "")
			{
				_collaborationRoomNetConnectionServiceProxy.sendCollaborationSynchronization("moveScheduleItemEnd", moveData);
			}
			else
			{
				_scheduleModel.locked = false;
			}
		}
		
		public function moveAdherenceGroupStart(moveData:MoveData, userName:String = "", collaborationColor:String = "0xFFFFFF"):void
		{
			if (userName == "")
			{
				_collaborationRoomNetConnectionServiceProxy.sendCollaborationSynchronization("moveAdherenceGroupStart", moveData);
				collaborationColor = _collaborationRoomNetConnectionServiceProxy.getLocalUserCollaborationColor();
			}
			
			_scheduleModel.moveAdherenceGroupStart(moveData, collaborationColor);
			
			if (userName != "")
			{
				_scheduleModel.locked = true;
			}
		}
		
		public function moveAdherenceGroup(moveData:MoveData, userName:String = "", collaborationColor:String = "0xFFFFFF"):void
		{
			_scheduleModel.moveAdherenceGroup(moveData);
			
			if (userName == "")
			{
				_collaborationRoomNetConnectionServiceProxy.sendCollaborationSynchronization("moveAdherenceGroup", moveData);
			}
		}
		
		public function moveAdherenceGroupEnd(moveData:MoveData, userName:String = "", collaborationColor:String = "0xFFFFFF"):void
		{
			_scheduleModel.moveAdherenceGroupEnd(moveData);
			
			if (userName == "")
			{
				_collaborationRoomNetConnectionServiceProxy.sendCollaborationSynchronization("moveAdherenceGroupEnd", moveData);
			}
			else
			{
				_scheduleModel.locked = false;
			}
		}	
		
		public function resizeAdherenceWindow(moveData:MoveData, userName:String = "", collaborationColor:String = "0xFFFFFF"):void
		{
			_scheduleModel.resizeAdherenceWindow(moveData);
			
			if (userName == "")
			{
				_collaborationRoomNetConnectionServiceProxy.sendCollaborationSynchronization("resizeAdherenceWindow", moveData);
			}
			else
			{
				_scheduleModel.locked = false;
			}
		}	
	}
}