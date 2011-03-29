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
package collaboRhythm.shared.model.settings
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class Settings
	{
		private var _username:String;
		private var _password:String;
		private var _chromeConsumerKey:String;
		private var _chromeConsumerSecret:String;
		private var _indivoServerBaseURL:String;
		private var _mode:String;
		private var _rtmpBaseURI:String;
		private var _useSingleScreen:Boolean;
		private var _resetWindowSettings:Boolean;
		private var _targetDate:Date;
		private var _isWorkstationMode:Boolean;
		private var _demoDatePresets:ArrayCollection;
		private var _appGroups:ArrayCollection;

		public function Settings()
		{
		}

		public function get isWorkstationMode():Boolean
		{
			return _isWorkstationMode;
		}

		public function set isWorkstationMode(value:Boolean):void
		{
			_isWorkstationMode = value;
		}

		public function get indivoServerBaseURL():String
		{
			return _indivoServerBaseURL;
		}

		public function set indivoServerBaseURL(value:String):void
		{
			_indivoServerBaseURL = value;
		}

		public function get chromeConsumerKey():String
		{
			return _chromeConsumerKey;
		}

		public function set chromeConsumerKey(value:String):void
		{
			_chromeConsumerKey = value;
		}

		public function get chromeConsumerSecret():String
		{
			return _chromeConsumerSecret;
		}

		public function set chromeConsumerSecret(value:String):void
		{
			_chromeConsumerSecret = value;
		}

		public function get password():String
		{
			return _password;
		}

		public function set password(value:String):void
		{
			_password = value;
		}

		public function get username():String
		{
			return _username;
		}

		public function set username(value:String):void
		{
			_username = value;
		}

		public function get mode():String
		{
			return _mode;
		}

		public function set mode(value:String):void
		{
			_mode = value;
		}

		public function get rtmpBaseURI():String
		{
			return _rtmpBaseURI;
		}

		public function set rtmpBaseURI(value:String):void
		{
			_rtmpBaseURI = value;
		}

		public function get useSingleScreen():Boolean
		{
			return _useSingleScreen;
		}

		public function set useSingleScreen(value:Boolean):void
		{
			_useSingleScreen = value;
		}

		public function get resetWindowSettings():Boolean
		{
			return _resetWindowSettings;
		}

		public function set resetWindowSettings(value:Boolean):void
		{
			_resetWindowSettings = value;
		}

		public function get targetDate():Date
		{
			return _targetDate;
		}

		public function set targetDate(value:Date):void
		{
			_targetDate = value;
		}

		public function get isClinicianMode():Boolean
		{
			return _mode == "clinician";
		}

		public function get isPatientMode():Boolean
		{
			return _mode == "patient";
		}

		/**
		 * Collection of Date values (dateTime) which can be used to simulate changing the current date/time
		 * to an arbitrary date/time for demo purposes.
		 */
		public function get demoDatePresets():ArrayCollection
		{
			return _demoDatePresets;
		}

		public function set demoDatePresets(value:ArrayCollection):void
		{
			_demoDatePresets = value;
		}

		/**
		 * Collection of AppGroupDescriptors describing the groups of apps used in the application, and the order in
		 * which the apps should appear.
		 */
		public function get appGroups():ArrayCollection
		{
			return _appGroups;
		}

		public function set appGroups(value:ArrayCollection):void
		{
			_appGroups = value;
		}
	}
}