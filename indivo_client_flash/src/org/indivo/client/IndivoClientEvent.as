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
package org.indivo.client
{
	import flash.events.Event;
	import flash.net.URLRequest;
	
	public class IndivoClientEvent extends Event
	{
		public static const COMPLETE:String = "indivo_client_complete";
		public static const ERROR:String = "indivo_client_error";
		
		public function IndivoClientEvent(response:XML, urlRequest:URLRequest, userData:Object, type:String=COMPLETE, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_response = response;
			_urlRequest = urlRequest;
			_userData = userData;
		}
		
		public var _response:XML;
		private var _urlRequest:URLRequest;
		private var _userData:Object;
		
		public function get userData():Object
		{
			return _userData;
		}

		public function get urlRequest():URLRequest
		{
			return _urlRequest;
		}

		public function get response():XML
		{
			return _response;
		}
		
		/**
		 * Creates and returns a copy of the current instance.
		 * @return A copy of the current instance.
		 */
		public override function clone():Event
		{
			return new IndivoClientEvent(response, urlRequest, userData, type, bubbles, cancelable);
		}
		
		/**
		 * Returns a String containing all the properties of the current
		 * instance.
		 * @return A string representation of the current instance.
		 */
		public override function toString():String
		{
			return formatToString("IndivoClientEvent", "type", "bubbles", "cancelable", "eventPhase", "response", "urlRequest", "userData");
		}
		
	}
}