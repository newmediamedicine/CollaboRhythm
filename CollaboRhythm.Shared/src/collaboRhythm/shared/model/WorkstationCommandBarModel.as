/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see <http://www.gnu.org/licenses/>.
*/
package collaboRhythm.shared.model
{
	import collaboRhythm.shared.model.services.ICurrentDateSource;

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