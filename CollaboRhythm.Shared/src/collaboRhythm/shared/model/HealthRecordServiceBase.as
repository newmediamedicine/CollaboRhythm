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
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;
	
	import com.brooksandrus.utils.ISO8601Util;
	
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.xml.XMLDocument;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.rpc.xml.SimpleXMLDecoder;
	import mx.utils.ArrayUtil;
	import mx.utils.URLUtil;
	
	import org.indivo.client.Admin;
	import org.indivo.client.IndivoClientEvent;
	import org.indivo.client.Pha;

	[Event(name="loginComplete", type="collaboRhythm.shared.model.HealthRecordServiceEvent")]
	[Event(name="complete", type="collaboRhythm.shared.model.HealthRecordServiceEvent")]
	
	public class HealthRecordServiceBase extends EventDispatcher
	{
		private var _consumerKey:String;
		private var _consumerSecret:String;
		private var _baseURL:String;
		protected var _pha:Pha;
		protected var _adminClient:Admin;
//		private var _accessTokenKey:String;
//		private var _accessTokenSecret:String;
		protected var _currentDateSource:ICurrentDateSource;
		
		private var _accessKey:String;
		private var _accessSecret:String;
		private var _accountId:String;
		protected var _isLoginComplete:Boolean;
		
		public function HealthRecordServiceBase(consumerKey:String, consumerSecret:String, baseURL:String)
		{
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;

//			var consumerKey:String = "authentication-helper@apps.nmm.media.mit.edu";
//			var consumerSecret:String = "authentication-helper-nmm86565";
//			var baseURL:String = "http://records.media.mit.edu:8000";
//			_accessTokenKey = "X86K0TyFu459FPiUpFLb";
//			_accessTokenSecret = "hvVhp1Fc9jUdhTvvzyix";

			_consumerKey = consumerKey;
			_consumerSecret = consumerSecret;
			_baseURL = baseURL;
			
			_pha = new Pha(consumerKey, consumerSecret, baseURL);
			_pha.addEventListener(IndivoClientEvent.COMPLETE, indivoClientEventHandler);
			_pha.addEventListener(IndivoClientEvent.ERROR, indivoClientEventHandler);
		}
		
		public function copyLoginResults(source:HealthRecordServiceBase):void
		{
			this.accountId = source.accountId;
			this.accessKey = source.accessKey;
			this.accessSecret = source.accessSecret;
			_isLoginComplete = source.isLoginComplete;
		}
		
		public function get accountId():String
		{
			return _accountId;
		}

		public function set accountId(value:String):void
		{
			_accountId = value;
		}

		public function get consumerKey():String
		{
			return _consumerKey;
		}

		public function set consumerKey(value:String):void
		{
			_consumerKey = value;
		}

		public function get consumerSecret():String
		{
			return _consumerSecret;
		}

		public function set consumerSecret(value:String):void
		{
			_consumerSecret = value;
		}

		public function get baseURL():String
		{
			return _baseURL;
		}

		public function get isLoginComplete():Boolean
		{
			return _isLoginComplete;
		}
		
		public function get accessKey():String
		{
			return _accessKey;
		}

		public function set accessKey(value:String):void
		{
			_accessKey = value;
		}

		public function get accessSecret():String
		{
			return _accessSecret;
		}

		public function set accessSecret(value:String):void
		{
			_accessSecret = value;
		}

		public function get pha():Pha
		{
			return _pha;
		}
		
		/**
		 * Starts an asynchronous login operation.
		 *  
		 * @param chromeConsumerKey The oauthConsumerKey for the admin (chrome) client.
		 * @param chromeConsumerSecret The oauthConsumerSecret for the admin (chrome) client.
		 * @param username The username of the user that is using the application.
		 * @param password The password of the user that is using the application.
		 * 
		 */
		public function login(chromeConsumerKey:String, chromeConsumerSecret:String, username:String, password:String):void
		{
			_adminClient = new Admin(chromeConsumerKey, chromeConsumerSecret, _pha.defaultURL());
			_adminClient.addEventListener(IndivoClientEvent.COMPLETE, loginIndivoClientEventHandler);
			_adminClient.addEventListener(IndivoClientEvent.ERROR, loginIndivoClientEventHandler);
			
			_adminClient.create_session(username, password);
		}
		
		private function loginIndivoClientEventHandler(event:IndivoClientEvent):void
		{
			if (event.type == IndivoClientEvent.COMPLETE)
			{
				var responseXml:XML = event.response;
				var responseText:String = responseXml.toString();
				
				var appInfo:Object = URLUtil.stringToObject(responseText, "&");
				
				accessKey = appInfo["oauth_token"];
				accessSecret = appInfo["oauth_token_secret"];
				accountId = appInfo["account_id"];
				
				_isLoginComplete = true;
				this.dispatchEvent(new HealthRecordServiceEvent(HealthRecordServiceEvent.LOGIN_COMPLETE));
			}
			else
			{
				// TODO: handle failed login errors
				
				var innerError:XMLList = event.response.InnerError;
				var errorStatus:String;
				
				if (innerError != null)
				{
					errorStatus = innerError.text;
				}
				else
				{
					errorStatus = "Unhandled error occurred."
				}
				
				//				this.status = errorStatus;
				trace(errorStatus);
			}
		}
		
		/**
		 * Simple parsing function to convert the date strings in our dataset to the equivalent Date object.
		 */
		public function dateParse(value:String):Date
		{
			var dateArray:Array = value.split('-');
			return new Date(dateArray[0], dateArray[1] - 1, dateArray[2]);
		}
		
		private function indivoClientEventHandler(event:IndivoClientEvent):void
		{
//			_pha.removeEventListener(IndivoClientEvent.COMPLETE, indivoClientEventHandler);
//			_pha.removeEventListener(IndivoClientEvent.ERROR, indivoClientEventHandler);
			
			if (event.type == IndivoClientEvent.COMPLETE)
			{
				if (event.urlRequest.method == URLRequestMethod.POST)
				{
				}

				var responseXml:XML = event.response;
				var fixedString:String = event.response.toXMLString().split("xmlns=").join("junk="); 
				responseXml = new XML(fixedString);
				
				if (responseXml != null)
				{
					handleResponse(event, responseXml);
				}
			}
			else
			{
				var innerError:XMLList = event.response.InnerError;
				var errorStatus:String;
				
				if (innerError != null)
				{
					errorStatus = innerError.text;
				}
				else
				{
					errorStatus = "Unhandled error occurred."
				}
				
//				this.status = errorStatus;
				trace(errorStatus);
				handleError(event);
			}
		}
		
		/**
		 * Virtual method which subclasses should override in order to handle the asynchronous response to a request.
		 *  
		 * @param event
		 * @param responseXml
		 * 
		 */
		protected function handleResponse(event:IndivoClientEvent, responseXml:XML):void
		{
			// Base class does nothing. Subclasses should override.
		}

		/**
		 * Virtual method which subclasses should override in order to handle the asynchronous error response to a request.
		 *  
		 * @param event
		 * 
		 */
		protected function handleError(event:IndivoClientEvent):void
		{
			// Base class does nothing. Subclasses should override.
		}
		
		/**
		 * Parses an Indivo date in the format "YYYY-MM-DD".  
		 * @param str
		 * @return The corresponding date, if str is non-null; otherwise null.
		 */
		public static function parseDate( str : String ) : Date
		{
			if (str != null && str.length > 0)
			{
				var matches : Array = str.match(/(\d\d\d\d)-(\d\d)-(\d\d)/);
				// TODO: avoid using the current time
				var d : Date = new Date();
				
				d.setUTCFullYear(int(matches[1]), int(matches[2]) - 1, int(matches[3]));
				return d;
			}
			else
				return null;
		}
		
		private function dateToAge(start:Date):Number
		{
			var now:Date = _currentDateSource.now();
			var nowMs:Number = now.getTime();
			var startMs:Number = start.getTime();
			var difference:Date = new Date(nowMs - startMs);
			return (difference.getFullYear() - 1970);
		}
		
	}
}