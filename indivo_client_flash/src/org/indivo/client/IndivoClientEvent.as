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

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.net.URLRequest;

	public class IndivoClientEvent extends Event
	{
		public static const COMPLETE:String = "indivo_client_complete";
		public static const ERROR:String = "indivo_client_error";
		public var _response:XML;
		private var _urlRequest:URLRequest;
		private var _userData:Object;
		private var _relativePath:String;
		private var _requestXml:String;
		private var _params:Object;
		private var _errorEvent:ErrorEvent;
		private var _httpStatusEvent:HTTPStatusEvent;
		public static const HTTP_STATUS_OK:int = 200;

		public function IndivoClientEvent(type:String, response:XML, urlRequest:URLRequest, relativePath:String,
										  requestXml:String, params:Object, userData:Object,
										  errorEvent:ErrorEvent = null, httpStatusEvent:HTTPStatusEvent = null,
										  bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			_response = response;
			_urlRequest = urlRequest;
			_relativePath = relativePath;
			_requestXml = requestXml;
			_params = params;
			_userData = userData;
			_errorEvent = errorEvent;
			_httpStatusEvent = httpStatusEvent;
		}

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
			return new IndivoClientEvent(type, response, urlRequest, relativePath, requestXml, params, userData,
										 errorEvent, httpStatusEvent, bubbles, cancelable);
		}
		
		/**
		 * Returns a String containing all the properties of the current
		 * instance.
		 * @return A string representation of the current instance.
		 */
		public override function toString():String
		{
			return formatToString("IndivoClientEvent", "type", "bubbles", "cancelable", "eventPhase", "response", "urlRequest", "relativePath", "requestXml", "params", "userData", "errorEvent", "httpStatusEvent");
		}

		public function get relativePath():String
		{
			return _relativePath;
		}

		public function set relativePath(value:String):void
		{
			_relativePath = value;
		}

		public function get requestXml():String
		{
			return _requestXml;
		}

		public function set requestXml(value:String):void
		{
			_requestXml = value;
		}

		public function get params():Object
		{
			return _params;
		}

		public function set params(value:Object):void
		{
			_params = value;
		}

		public function get errorEvent():ErrorEvent
		{
			return _errorEvent;
		}

		public function set errorEvent(value:ErrorEvent):void
		{
			_errorEvent = value;
		}

		public function get httpStatusEvent():HTTPStatusEvent
		{
			return _httpStatusEvent;
		}

		public function set httpStatusEvent(value:HTTPStatusEvent):void
		{
			_httpStatusEvent = value;
		}
	}
}