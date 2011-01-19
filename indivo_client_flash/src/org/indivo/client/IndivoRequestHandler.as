package org.indivo.client
{
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
		public function IndivoRequestHandler(eventDispatcher:EventDispatcher, phaAdminUtils:PhaAdminUtils)
		{
			_eventDispatcher = eventDispatcher;
			_phaAdminUtils = phaAdminUtils;
		}
		
		private var _urlRequest:URLRequest;
		private var _eventDispatcher:EventDispatcher;
		private var _phaAdminUtils:PhaAdminUtils;
		private var _userData:Object;
		private var _httpStatusEvent:HTTPStatusEvent;

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

		public function handle(urlRequest:URLRequest, userData:Object):void
		{
			this.urlRequest = urlRequest;
			this._userData = userData;
			
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, eventHandler);
			urlLoader.addEventListener(Event.OPEN, eventHandler);
			urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusEventHandler);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorEventHandler);
			urlLoader.addEventListener(ProgressEvent.PROGRESS, eventHandler);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, eventHandler);
			urlLoader.load(urlRequest);
		}
			
		private function eventHandler(event:Event):void {
			//arrColl.addItem({type:event.type, idx:arrColl.length+1, eventString:event.toString()});
			
			switch (event.type) {
				case Event.COMPLETE:
					var urlLoader:URLLoader = event.currentTarget as URLLoader;

//					/* If the load was successful, create a URLVariables object from the URLLoader.data property and populate the paramColl ArrayCollection object. */
//					var urlVariables:URLVariables = new URLVariables(urlLoader.data);
//					var key:String;
//					
//					for (key in urlVariables) {
//						//paramColl.addItem({key:key, value:urlVariables[key]});
//					}
					
					//params.visible = true;
					
					eventDispatcher.dispatchEvent(new IndivoClientEvent(phaAdminUtils.docFromResponse(urlLoader.data), urlRequest, _userData));
					
					break;
				default:
					//this.dispatchEvent(new IndivoClientEvent(phaAdminUtils.docFromResponse(urlLoader.data)));
					//trace(event);
					eventDispatcher.dispatchEvent(event);
					break;
			}
		}
		
		private function httpStatusEventHandler(httpStatusEvent:HTTPStatusEvent):void
		{
			_httpStatusEvent = httpStatusEvent;
		}
		
		private function ioErrorEventHandler(event:IOErrorEvent):void
		{
			//trace(event);
			//eventDispatcher.dispatchEvent(event);
			var response:XML = 
				<Error>
					<InnerError>
						<type>{event.type}</type>
						<text>{event.text}</text>
						<eventPhase>{event.eventPhase}</eventPhase>
					</InnerError>
				</Error>;
			
			if (_httpStatusEvent != null && _httpStatusEvent.status != 0)
			{
				response.appendChild(
					<HTTPStatusEvent>
						<status>{_httpStatusEvent.status}</status>
					</HTTPStatusEvent>
				);
			}
			
			//						<errorID>{ErrorEvent(event).errorID}</errorID>
			
			eventDispatcher.dispatchEvent(new IndivoClientEvent(response, urlRequest, _userData, IndivoClientEvent.ERROR));
		}
		
	}
}