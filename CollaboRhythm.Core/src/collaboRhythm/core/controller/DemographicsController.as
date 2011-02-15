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
	import collaboRhythm.shared.model.User;
	import collaboRhythm.shared.view.DemographicsFullView;
	
	import mx.core.IVisualElementContainer;
	
	import spark.effects.Move;

	public class DemographicsController
	{
		private var _demographicsFullView:DemographicsFullView;
		private var _remoteUser:User;
		
		public function DemographicsController(parentContainer:IVisualElementContainer)
		{
			_demographicsFullView = new DemographicsFullView();
			_demographicsFullView.visible = false;
			parentContainer.addElement(_demographicsFullView);
		}

		public function get remoteUser():User
		{
			return _remoteUser;
		}
		
		public function set remoteUser(value:User):void
		{
			_remoteUser = value;
			_demographicsFullView.user = value;
			_demographicsFullView.validateNow();
		}
		
		public function hide():void
		{
			//_remoteUsersView.visible = false;
			var move:Move = new Move(_demographicsFullView);
			move.xTo = -_demographicsFullView.width;
			move.xFrom = _demographicsFullView.x;
			move.play();
		}
		
		public function show():void
		{
			var move:Move = new Move(_demographicsFullView);
			move.xFrom = -_demographicsFullView.width;
			move.xTo = 0;
			move.play();
			_demographicsFullView.visible = true;
		}
	}
}