package collaboRhythm.workstation.controller
{
	import castle.flexbridge.reflection.Void;
	
	import collaboRhythm.workstation.model.Settings;
	import collaboRhythm.workstation.model.User;
	import collaboRhythm.workstation.model.UsersModel;
	import collaboRhythm.workstation.view.RemoteUserView;
	import collaboRhythm.workstation.view.RemoteUsersListView;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.core.IVisualElementContainer;
	
	import spark.effects.Move;
	
	/**
	 * 
	 * @author jom
	 * 
	 * Coordinates interaction between the RemoteUserList view and the UserModel classes.
	 * It listens for events from the RemotUserNetConnection class including receiving collaboration requests, cancellations (including rejections), and acceptances. 
	 * It updates the status of the corresponding remote user on receiving these events and dispatches events to interested observers.
	 * Currently, the CollaborationMediator listens for events from this class.  It also calls functions in this class to coordinate activity with the CollaborationController and WorkstationCommandBarController.
	 * This includes sending collaboration requests, cancellations (including rejections), and acceptances.
	 * 
	 */
	public class RemoteUserController extends EventDispatcher
	{
		private var _usersModel:UsersModel;
		private var _remoteUserListView:RemoteUsersListView;
		
		public function RemoteUserController(remoteUserListView:RemoteUsersListView, usersModel:UsersModel)
		{
			_usersModel = usersModel;
			
			_remoteUserListView = remoteUserListView;
			_remoteUserListView.initializeControllerModel(this, _usersModel);
		}	
		
		public function get usersModel():UsersModel
		{
			return _usersModel;
		}
		
		public function get remoteUserListView():RemoteUsersListView
		{
			return _remoteUserListView;
		}
		
		public function openRecord(remoteUser:User):void
		{
			dispatchEvent(new CollaborationEvent(CollaborationEvent.OPEN_RECORD, remoteUser));
		}
		
		public function hide(isImmediately:Boolean=false):void
		{
			_remoteUserListView.hide(isImmediately);
		}
		
		public function show():void
		{
			_remoteUserListView.show();
		}
		
		public function updateView():void
		{
			_remoteUserListView.remoteUserList.dataProvider = _usersModel.remoteUsers.values();
		}
		
		public function sortView():void
		{
			_remoteUserListView.sortListByName();
		}
	}
}