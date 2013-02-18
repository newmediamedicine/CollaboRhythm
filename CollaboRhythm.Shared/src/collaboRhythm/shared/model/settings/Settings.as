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
		public static const MODE_CLINICIAN:String = "clinician";
		public static const MODE_PATIENT:String = "patient";

		public static const MODALITY_WORKSTATION:String = "workstation";
		public static const MODALITY_MOBILE:String = "mobile";
		public static const MODALITY_TABLET:String = "tablet";

		private var _username:String;
		private var _password:String;
		private var _clinicianTeamMembers:ArrayCollection;
		private var _primaryClinicianTeamMember:String;
		private var _useFileTarget:Boolean;
		private var _useTraceTarget:Boolean;
		private var _useSyslogTarget:Boolean;
		private var _syslogServerIpAddress:String;
		private var _useGoogleAnalytics:Boolean;
		private var _googleAnalyticsTrackingId:String;
		private var _debuggingToolsEnabled:Boolean;
		private var _oauthChromeConsumerKey:String;
		private var _oauthChromeConsumerSecret:String;
		private var _indivoServerBaseURL:String;
		private var _logSourceIdentifier:String;
		private var _mode:String;
		private var _collaborationEnabled:Boolean = true;
		private var _rtmpBaseURI:String;
		private var _useSingleScreen:Boolean;

		private var _resetWindowSettings:Boolean;
		private var _demoModeEnabled:Boolean;
		private var _adherenceVoidingEnabled:Boolean;
		private var _includeAdherenceVoidingMenuItem:Boolean;
		private var _targetDate:Date;
		private var _modality:String;
		private var _demoDatePresets:ArrayCollection;
		private var _appGroups:ArrayCollection;
		private var _pluginSearchPaths:ArrayCollection;
		private var _applicationUpdateDescriptorURL:String;
		private var _clockAnimationMode:String;
		private var _deviceSimulatorEnabled:Boolean;

		public function Settings()
		{
		}

		public function get modality():String
		{
			return _modality;
		}

		public function set modality(value:String):void
		{
			_modality = value;
		}

		public function get isWorkstationMode():Boolean
		{
			return modality == MODALITY_WORKSTATION;
		}

		public function get indivoServerBaseURL():String
		{
			return _indivoServerBaseURL;
		}

		public function set indivoServerBaseURL(value:String):void
		{
			_indivoServerBaseURL = value;
		}

		public function get logSourceIdentifier():String
		{
			return _logSourceIdentifier;
		}

		public function set logSourceIdentifier(value:String):void
		{
			_logSourceIdentifier = value;
		}

		public function get oauthChromeConsumerKey():String
		{
			return _oauthChromeConsumerKey;
		}

		public function set oauthChromeConsumerKey(value:String):void
		{
			_oauthChromeConsumerKey = value;
		}

		public function get oauthChromeConsumerSecret():String
		{
			return _oauthChromeConsumerSecret;
		}

		public function set oauthChromeConsumerSecret(value:String):void
		{
			_oauthChromeConsumerSecret = value;
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

		public function get useFileTarget():Boolean
		{
			return _useFileTarget;
		}

		public function set useFileTarget(value:Boolean):void
		{
			_useFileTarget = value;
		}

		public function get useTraceTarget():Boolean
		{
			return _useTraceTarget;
		}

		public function set useTraceTarget(value:Boolean):void
		{
			_useTraceTarget = value;
		}

		public function get useSyslogTarget():Boolean
		{
			return _useSyslogTarget;
		}

		public function set useSyslogTarget(value:Boolean):void
		{
			_useSyslogTarget = value;
		}

		public function get syslogServerIpAddress():String
		{
			return _syslogServerIpAddress;
		}

		public function set syslogServerIpAddress(value:String):void
		{
			_syslogServerIpAddress = value;
		}

		public function get useGoogleAnalytics():Boolean
		{
			return _useGoogleAnalytics;
		}

		public function set useGoogleAnalytics(value:Boolean):void
		{
			_useGoogleAnalytics = value;
		}

		public function get googleAnalyticsTrackingId():String
		{
			return _googleAnalyticsTrackingId;
		}

		public function set googleAnalyticsTrackingId(value:String):void
		{
			_googleAnalyticsTrackingId = value;
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
			return _mode == MODE_CLINICIAN;
		}

		public function get isPatientMode():Boolean
		{
			return _mode == MODE_PATIENT;
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

		public function get debuggingToolsEnabled():Boolean
		{
			return _debuggingToolsEnabled;
		}

		public function set debuggingToolsEnabled(value:Boolean):void
		{
			_debuggingToolsEnabled = value;
		}

		public function get pluginSearchPaths():ArrayCollection
		{
			return _pluginSearchPaths;
		}

		public function set pluginSearchPaths(value:ArrayCollection):void
		{
			_pluginSearchPaths = value;
		}

		public function get applicationUpdateDescriptorURL():String
		{
			return _applicationUpdateDescriptorURL;
		}

		public function set applicationUpdateDescriptorURL(value:String):void
		{
			_applicationUpdateDescriptorURL = value;
		}

		public function get demoModeEnabled():Boolean
		{
			return _demoModeEnabled;
		}

		public function set demoModeEnabled(value:Boolean):void
		{
			_demoModeEnabled = value;
		}

		public function get adherenceVoidingEnabled():Boolean
		{
			return _adherenceVoidingEnabled;
		}

		public function set adherenceVoidingEnabled(value:Boolean):void
		{
			_adherenceVoidingEnabled = value;
		}

		public function get includeAdherenceVoidingMenuItem():Boolean
		{
			return _includeAdherenceVoidingMenuItem;
		}

		public function set includeAdherenceVoidingMenuItem(value:Boolean):void
		{
			_includeAdherenceVoidingMenuItem = value;
		}

		public function get clinicianTeamMembers():ArrayCollection
		{
			return _clinicianTeamMembers;
		}

		public function set clinicianTeamMembers(value:ArrayCollection):void
		{
			_clinicianTeamMembers = value;
		}

		public function get primaryClinicianTeamMember():String
		{
			return _primaryClinicianTeamMember;
		}

		public function set primaryClinicianTeamMember(value:String):void
		{
			_primaryClinicianTeamMember = value;
		}

		public function get clockAnimationMode():String
		{
			return _clockAnimationMode;
		}

		public function set clockAnimationMode(value:String):void
		{
			_clockAnimationMode = value;
		}

		public function get collaborationEnabled():Boolean
		{
			return _collaborationEnabled;
		}

		public function set collaborationEnabled(value:Boolean):void
		{
			_collaborationEnabled = value;
		}

		public function get deviceSimulatorEnabled():Boolean
		{
			return _deviceSimulatorEnabled;
		}

		public function set deviceSimulatorEnabled(value:Boolean):void
		{
			_deviceSimulatorEnabled = value;
		}
	}
}