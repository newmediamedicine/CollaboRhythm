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
	import flash.events.Event;
	
	public class HealthRecordServiceEvent extends Event
	{
		/**
		 * Indicates that the login operation has completed successfully.  
		 */
		public static const LOGIN_COMPLETE:String = "loginComplete";

		/**
		 * Indicates that the primary operation of the service has completed successfully.  
		 */
		public static const COMPLETE:String = "complete";
		
		/**
		 * Indicates that an operation of the service has completed successfully.  
		 */
		public static const UPDATE:String = "update";
		
		private var _user:User;
		
		public function HealthRecordServiceEvent(type:String, user:User=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_user = user;
		}

		/**
		 * The user associated with the event, if applicable. (Optional)
		 * @return the User object, or null if not applicable
		 * 
		 */
		public function get user():User
		{
			return _user;
		}

		public function set user(value:User):void
		{
			_user = value;
		}

	}
}