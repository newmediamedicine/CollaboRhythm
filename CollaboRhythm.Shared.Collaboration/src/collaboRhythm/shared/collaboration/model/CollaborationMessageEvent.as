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
package collaboRhythm.shared.collaboration.model
{
	import flash.events.Event;

	public class CollaborationMessageEvent extends Event
	{
		public static const MESSAGE_RECEIVED:String = "MessageReceived";

		private var _messageType:String;
		private var _subjectAccountId:String;
		private var _sourceAccountId:String;
		private var _sourcePeerId:String;
		private var _passWord:String;

		public function CollaborationMessageEvent(type:String, messageType:String, subjectAccountId:String,
										   sourceAccountId:String, sourcePeerId:String, passWord:String)
		{
			super(type);

			_messageType = messageType;
			_subjectAccountId = subjectAccountId;
			_sourceAccountId = sourceAccountId;
			_sourcePeerId = sourcePeerId;
			_passWord = passWord;
		}

		public function get messageType():String
		{
			return _messageType;
		}

		public function get subjectAccountId():String
		{
			return _subjectAccountId;
		}

		public function get sourceAccountId():String
		{
			return _sourceAccountId;
		}

		public function get sourcePeerId():String
		{
			return _sourcePeerId;
		}

		public function get passWord():String
		{
			return _passWord;
		}
	}
}