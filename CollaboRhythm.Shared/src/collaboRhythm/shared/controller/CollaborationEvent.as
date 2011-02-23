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
package collaboRhythm.shared.controller
{
	import collaboRhythm.shared.model.User;
	
	import flash.events.Event;

	public class CollaborationEvent extends Event
	{
		public static const COLLABORATE_WITH_USER:String = "CollaborateWithUser";

		public static const OPEN_RECORD:String = "OpenRecord";
		public static const CLOSE_RECORD:String = "CloseRecord";
		public static const RECORD_CLOSED:String = "RecordClosed";
		
		public static const LOCAL_USER_JOINED_COLLABORATION_ROOM_ANIMATION_COMPLETE:String = "LocalUserJoinedCollaborationRoom";
		
		private var _remoteUser:User;
		
		public function CollaborationEvent(type:String, remoteUser:User)
		{
			super(type);
			_remoteUser = remoteUser; 
		}

		public function get remoteUser():User 
		{
			return _remoteUser;
		}
	}
}