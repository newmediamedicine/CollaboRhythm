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
package collaboRhythm.core.controller
{
	import collaboRhythm.core.view.WorkstationCommandBarView;
	import collaboRhythm.shared.controller.CollaborationEvent;
	import collaboRhythm.shared.model.Settings;
	import collaboRhythm.shared.model.User;
	import collaboRhythm.shared.model.UsersModel;
	import collaboRhythm.shared.model.WorkstationCommandBarModel;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;
	
	import flash.events.EventDispatcher;
	
	import mx.events.EffectEvent;

	/**
	 * Coordinates interactions between the WorkstationCommandBarView and the UserModel classes.
	 * Currently, this simply includes setting the remoteUser currently active in the workstationCommandBarView.  
	 * It dispatches an event for sending a collaboration request that is listened for by the CollaborationMediator in order to coordinate interaction with the RemoteUserController. 
	 * 
	 * @author jom
	 * 
	 */
	public class WorkstationCommandBarController extends EventDispatcher
	{
		private var _workstationCommandBarView:WorkstationCommandBarView;
		private var _usersModel:UsersModel;
		private var _remoteUser:User;
		private var _currentDateSource:ICurrentDateSource;
		private var _model:WorkstationCommandBarModel;
		private var _settings:Settings;
		
		public function WorkstationCommandBarController(view:WorkstationCommandBarView, usersModel:UsersModel, settings:Settings)
		{
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
			_settings = settings;

			_model = new WorkstationCommandBarModel();
			_model.currentDateSource = _currentDateSource;
			_model.subjectUser = remoteUser;
			_model.usersModel = usersModel;
			_model.allowCloseRecord = settings.isClinicianMode;
			
			_workstationCommandBarView = view;
			_workstationCommandBarView.y = _workstationCommandBarView.y - _workstationCommandBarView.height;
			_workstationCommandBarView.initializeController(this, _model);
			_usersModel = usersModel;
		}

		[Bindable]
		public function get remoteUser():User
		{
			return _remoteUser;
		}

		public function set remoteUser(value:User):void
		{
			_remoteUser = value;
			_model.subjectUser = _remoteUser;
			_model.allowCloseRecord = (_remoteUser != null && _settings.isClinicianMode);
		}
		
		public function get usersModel():UsersModel
		{
			return _usersModel;
		}

		public function closeRecord():void
		{
			if (_remoteUser != null)
				dispatchEvent(new CollaborationEvent(CollaborationEvent.CLOSE_RECORD, _remoteUser));
		}
		
		public function collaborateWithUser():void 
		{
			dispatchEvent(new CollaborationEvent(CollaborationEvent.COLLABORATE_WITH_USER, _remoteUser));
		}
		
		public function hideEndHandler(event:EffectEvent):void
		{
			dispatchEvent(new CollaborationEvent(CollaborationEvent.RECORD_CLOSED, _remoteUser));
		}
		
		public function hide():void
		{		
			_workstationCommandBarView.hideEffect.play();	
		}
		
		public function show():void
		{
			_workstationCommandBarView.validateNow();
			_workstationCommandBarView.showEffect.play();	
		}
		
		public function get currentDateSource():ICurrentDateSource
		{
			return _currentDateSource;
		}
		
	}
}