package collaboRhythm.workstation.model
{
	import collaboRhythm.workstation.model.services.ICurrentDateSource;

	[Bindable]
	public class WorkstationCommandBarModel
	{
		private var _allowCloseRecord:Boolean;
		private var _subjectUser:User;
		private var _currentDateSource:ICurrentDateSource;
		private var _usersModel:UsersModel;

		public function WorkstationCommandBarModel()
		{
		}

		public function get usersModel():UsersModel
		{
			return _usersModel;
		}

		public function set usersModel(value:UsersModel):void
		{
			_usersModel = value;
		}

		public function get allowCloseRecord():Boolean
		{
			return _allowCloseRecord;
		}

		public function set allowCloseRecord(value:Boolean):void
		{
			_allowCloseRecord = value;
		}

		public function get subjectUser():User
		{
			return _subjectUser;
		}

		public function set subjectUser(value:User):void
		{
			_subjectUser = value;
		}

		public function get currentDateSource():ICurrentDateSource
		{
			return _currentDateSource;
		}

		public function set currentDateSource(value:ICurrentDateSource):void
		{
			_currentDateSource = value;
		}

		public function get allowCollaboration():Boolean
		{
			if (_subjectUser.collaborationLobbyConnectionStatus == User.COLLABORATION_LOBBY_AVAILABLE && _subjectUser != _usersModel.localUser)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
	}
}