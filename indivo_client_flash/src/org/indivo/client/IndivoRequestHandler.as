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

	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	internal class IndivoRequestHandler
	{
		private var _urlRequest:URLRequest;
		private var _eventDispatcher:EventDispatcher;
		private var _phaAdminUtils:PhaAdminUtils;
		private var _userData:Object;
		private var _httpStatusEvent:HTTPStatusEvent;
		private var _relativePath:String;
		private var _requestXml:String;
		private var _params:Object;
		private var _httpResponseStatusEvent:HTTPStatusEvent;

		public function IndivoRequestHandler(eventDispatcher:EventDispatcher, phaAdminUtils:PhaAdminUtils)
		{
			_eventDispatcher = eventDispatcher;
			_phaAdminUtils = phaAdminUtils;
		}

		public function get phaAdminUtils():PhaAdminUtils
		{
			return _phaAdminUtils;
		}

		public function set phaAdminUtils(value:PhaAdminUtils):void
		{
			_phaAdminUtils = value;
		}

		public function get eventDispatcher():EventDispatcher
		{
			return _eventDispatcher;
		}

		public function set eventDispatcher(value:EventDispatcher):void
		{
			_eventDispatcher = value;
		}

		public function get urlRequest():URLRequest
		{
			return _urlRequest;
		}

		public function set urlRequest(value:URLRequest):void
		{
			_urlRequest = value;
		}

		public function handle(urlRequest:URLRequest, relativePath:String, requestXml:String, params:Object,
							   userData:Object):void
		{
			_urlRequest = urlRequest;
			_relativePath = relativePath;
			_requestXml = requestXml;
			_params = params;
			_userData = userData;
			_httpStatusEvent = null;

			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, completeHandler);
			urlLoader.addEventListener(Event.OPEN, openHandler);
			urlLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusEventHandler);
			urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusEventHandler);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorEventHandler);
			urlLoader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			urlLoader.load(urlRequest);
		}

		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			dispatchErrorEvent(event);
		}

		private function progressHandler(event:ProgressEvent):void
		{
			eventDispatcher.dispatchEvent(event);
		}

		private function openHandler(event:Event):void
		{
			eventDispatcher.dispatchEvent(event);
		}

		private function completeHandler(event:Event):void
		{
			if (!_httpResponseStatusEvent)
				throw new Error("Unable to determine HTTP response status");

			if (_httpResponseStatusEvent.status != IndivoClientEvent.HTTP_STATUS_OK || event.type != Event.COMPLETE)
			{
				dispatchErrorEvent(event);
			}
			else
			{
				var urlLoader:URLLoader = event.currentTarget as URLLoader;

				eventDispatcher.dispatchEvent(new IndivoClientEvent(IndivoClientEvent.COMPLETE,
																	phaAdminUtils.docFromResponse(urlLoader.data),
																	urlLoader.data,
																	urlRequest, relativePath, requestXml, params,
																	_userData, null, _httpStatusEvent));
			}
		}

		private function httpResponseStatusEventHandler(event:HTTPStatusEvent):void
		{
			_httpResponseStatusEvent = event;
		}

		private function httpStatusEventHandler(httpStatusEvent:HTTPStatusEvent):void
		{
			_httpStatusEvent = httpStatusEvent;
		}
		
		private function ioErrorEventHandler(event:IOErrorEvent):void
		{
			dispatchErrorEvent(event);
		}

		private function dispatchErrorEvent(event:Event):void
		{
			var response:XML =
					<Error>
						<InnerError>
							<type>{event.type}</type>
						</InnerError>
					</Error>;

			if (event is ErrorEvent)
			{
				var errorEvent:ErrorEvent = event as ErrorEvent;
				response.InnerError[0].appendChild(<text>{errorEvent.text}</text>);
				response.InnerError[0].appendChild(<errorID>{errorEvent.errorID}</errorID>);
			}

			if (_httpStatusEvent != null && _httpStatusEvent.status != 0)
			{
				response.appendChild(
						<HTTPStatusEvent>
							<status>{_httpStatusEvent.status}</status>
							<data>{(_httpStatusEvent.currentTarget as URLLoader).data}</data>
						</HTTPStatusEvent>
				);
			}

			var urlLoader:URLLoader = event.currentTarget as URLLoader;
			eventDispatcher.dispatchEvent(new IndivoClientEvent(IndivoClientEvent.ERROR,
					response, urlLoader.data, urlRequest, relativePath, requestXml, params,
																_userData, event as ErrorEvent, _httpStatusEvent));
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
	}
}