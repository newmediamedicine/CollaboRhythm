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
package collaboRhythm.shared.collaboration.controller
{
	import flash.events.Event;

	public class CollaborationEvent extends Event
	{
		public static const COLLABORATE_WITH_USER:String = "CollaborateWithUser";
		public static const RECORD_VIDEO:String = "RecordVideo";

		public static const OPEN_RECORD:String = "OpenRecord";
		public static const CLOSE_RECORD:String = "CloseRecord";
		public static const RECORD_CLOSED:String = "RecordClosed";

		public static const LOCAL_USER_JOINED_COLLABORATION_ROOM_ANIMATION_COMPLETE:String = "LocalUserJoinedCollaborationRoom";
		public static const COLLABORATION_INVITATION_RECEIVED:String = "CollaborationInvitationReceived";
		public static const COLLABORATION_INVITATION_ACCEPTED:String = "CollaborationInvitationAccepted";
		public static const COLLABORATION_INVITATION_REJECTED:String = "CollaborationInvitationRejected";
		public static const COLLABORATION_INVITATION_CANCELLED:String = "CollaborationInvitationCancelled";
		public static const COLLABORATION_ENDED:String = "CollaborationEnded";

		private var _subjectAccountId:String;
		private var _sourceAccountId:String;
		private var _sourcePeerId:String;
		private var _passWord:String;
		
		public function CollaborationEvent(type:String, subjectAccountId:String, sourceAccountId:String, sourcePeerId:String, passWord:String)
		{
			super(type);

			_subjectAccountId = subjectAccountId;
			_sourceAccountId = sourceAccountId;
			_sourcePeerId = sourcePeerId;
			_passWord = passWord;
		}

		public function get subjectAccountId():String
		{
			return _subjectAccountId;
		}

		public function set subjectAccountId(value:String):void
		{
			_subjectAccountId = value;
		}

		public function get sourceAccountId():String
		{
			return _sourceAccountId;
		}

		public function set sourceAccountId(value:String):void
		{
			_sourceAccountId = value;
		}

		public function get sourcePeerId():String
		{
			return _sourcePeerId;
		}

		public function set sourcePeerId(value:String):void
		{
			_sourcePeerId = value;
		}

		public function get passWord():String
		{
			return _passWord;
		}

		public function set passWord(value:String):void
		{
			_passWord = value;
		}
	}
}