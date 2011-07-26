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
package collaboRhythm.core.controller
{

	import castle.flexbridge.kernel.IKernel;

	import collaboRhythm.core.controller.apps.AppControllersMediatorBase;
	import collaboRhythm.core.model.ApplicationControllerModel;
	import collaboRhythm.core.model.healthRecord.HealthRecordServiceFacade;
	import collaboRhythm.core.pluginsManagement.DefaultComponentContainer;
	import collaboRhythm.core.pluginsManagement.PluginLoader;
	import collaboRhythm.shared.controller.CollaborationController;
	import collaboRhythm.shared.controller.apps.AppControllerInfo;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.CollaborationLobbyNetConnectionEvent;
	import collaboRhythm.shared.model.CollaborationLobbyNetConnectionService;
	import collaboRhythm.shared.model.healthRecord.AccountInformationHealthRecordService;
	import collaboRhythm.shared.model.healthRecord.CreateSessionHealthRecordService;
	import collaboRhythm.shared.model.healthRecord.DemographicsHealthRecordService;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceEvent;
	import collaboRhythm.shared.model.healthRecord.RecordsHealthRecordService;
	import collaboRhythm.shared.model.healthRecord.SharesHealthRecordService;
	import collaboRhythm.shared.model.services.DemoCurrentDateSource;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;
	import collaboRhythm.shared.model.settings.Settings;
	import collaboRhythm.shared.model.settings.SettingsFileStore;
	import collaboRhythm.shared.view.CollaborationView;

	import com.coltware.airxlib.log.TCPSyslogTarget;

	import com.daveoncode.logging.LogFileTarget;

	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.system.Security;
	import flash.system.System;
	import flash.utils.getQualifiedClassName;

	import mx.binding.utils.BindingUtils;

	import mx.core.IVisualElementContainer;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	import mx.logging.targets.TraceTarget;

	public class ApplicationControllerBase
	{
		protected var _applicationControllerModel:ApplicationControllerModel;
		protected var _kernel:IKernel;
		protected var _settingsFileStore:SettingsFileStore;
		protected var _settings:Settings;
		protected var _hasActiveNetworkInterface:Boolean = false;
		protected var _activeAccount:Account;
		protected var _activeRecordAccount:Account;
		protected var _collaborationController:CollaborationController;
		protected var _logger:ILogger;
		protected var _componentContainer:IComponentContainer;
		protected var _pluginLoader:PluginLoader;
		protected var _reloadWithRecordAccount:Account;
		protected var _reloadWithFullView:String;
		protected var _healthRecordServiceFacade:HealthRecordServiceFacade;

		public function ApplicationControllerBase()
		{
		}

		// To be overridden by subclasses with the super method called at the beginning
		// subclasses can then perform appropriate actions after settings, logging, and components have been initialized
		public function main():void
		{
			_applicationControllerModel = new ApplicationControllerModel();

			initSettings();

			// TODO: provide feedback if there is not an active NetworkInterface
			checkNetworkStatus();

			initLogging();
			_logger.info("Logging initialized");

			// initSettings needs to be called prior to initLogging because the settings for logging need to be loaded first
			_logger.info("Settings initialized");
			_logger.info("  Application settings file loaded: " + _settingsFileStore.isApplicationSettingsLoaded);
			_logger.info("  User settings file loaded: " + _settingsFileStore.isUserSettingsLoaded + " path=" + _settingsFileStore.userSettingsFile.nativePath);
			_logger.info("  Mode: " + _settings.mode);
			_logger.info("  Username: " + _settings.username);

			initComponents();
			_logger.info("Components initialized. Asynchronous plugin loading initiated.");
			_logger.info("  User plugins directory: " + _pluginLoader.userPluginsDirectoryPath);
			_logger.info("  Number of loaded plugins: " + _pluginLoader.numPluginsLoaded);

			// the activeAccount is that which is actively in session with the Indivo server, there can only be one active account at a time
			// create an instance of this model class before creating a session so that the results are tracked by that instance
			_activeAccount = new Account();
		}

		private function initSettings():void
		{
			_settingsFileStore = new SettingsFileStore();
			_settingsFileStore.applicationSettingsEmbeddedFile = applicationSettingsEmbeddedFile;
			_settingsFileStore.readSettings();
			_settings = _settingsFileStore.settings;
		}

		private function checkNetworkStatus():void
		{
			if (NetworkInfo.isSupported)
			{
				var networkInterfacesVector:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
				for each (var networkInterface:NetworkInterface in networkInterfacesVector)
				{
					if (networkInterface.active)
					{
						_hasActiveNetworkInterface = true;
					}
				}
			}
		}

		private function initLogging():void
		{
			// create a file target for logging if specified in the settings file
			if (_settings.useFileTarget)
			{
				// The log file will be placed under applicationStorageDirectory folder
				var path:String = File.applicationStorageDirectory.resolvePath("collaboRhythm.log").nativePath;
				var targetFile:File = new File(path);
				// get LogFileTarget's instance (LogFileTarget is a singleton)
				var fileTarget:LogFileTarget = LogFileTarget.getInstance();
				fileTarget.file = targetFile;
				/* Log all log levels. */
				fileTarget.level = LogEventLevel.ALL;
				Log.addTarget(fileTarget);
			}

			// create a trace target for logging if specified in the settings file
			if (_settings.useTraceTarget)
			{
				var traceTarget:TraceTarget = new TraceTarget();
				// add the trace target to the log
				Log.addTarget(traceTarget);
			}

			// create a syslog target for logging if specified in the settings file and get the ip address from the settings file
			// Kiwi Syslog server has a free version http://www.kiwisyslog.com/kiwi-syslog-server-overview/
			// set the syslogServerIpAddress in your settings file to the IP address where the syslog server is running
			if (_settings.useSyslogTarget)
			{
				var tcpSyslogTarget:TCPSyslogTarget = new TCPSyslogTarget(_settings.syslogServerIpAddress);
				tcpSyslogTarget.level = LogEventLevel.ALL;
				tcpSyslogTarget.includeDate = true;
				tcpSyslogTarget.includeTime = true;
				tcpSyslogTarget.userName = _settings.username;
				tcpSyslogTarget.includeCategory = true;
				tcpSyslogTarget.fieldSeparator = "\t";

				// add the syslog target to the log
				Log.addTarget(tcpSyslogTarget);
			}

			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
		}

		protected function testLogging():void
		{
			_logger.info("Testing logger");
		}

		private function initComponents():void
		{
			_kernel = WorkstationKernel.instance;

			//	_kernel.registerComponentInstance("CurrentDateSource", ICurrentDateSource, new DefaultCurrentDateSource());
			var dateSource:DemoCurrentDateSource = new DemoCurrentDateSource();
			dateSource.targetDate = _settings.targetDate;
			_kernel.registerComponentInstance("CurrentDateSource", ICurrentDateSource, dateSource);

			_componentContainer = new DefaultComponentContainer();
			_pluginLoader = new PluginLoader();
			_pluginLoader.addEventListener(Event.COMPLETE, pluginLoader_complete);
			_pluginLoader.componentContainer = componentContainer;
			_pluginLoader.loadPlugins();
		}

		/**
		 * Method that should be called by subclasses to create a session with the Indivo backend server.
		 */
		protected function initCollaborationController(collaborationView:CollaborationView = null):void
		{
			// the collaborationController coordinates interaction between the CollaborationModel and the CollaborationView and its children the RecordVideoView and CollaborationRoomView.
			// The CollaborationModel, through its services, connects to the collaboration server, which is currently a Flash Media Server
			// This server allows the user to see when other account owners are online
			// It also allows collaboration with these account owners and sending and viewing of asynchronous video

			_collaborationController = new CollaborationController(_activeAccount, collaborationView, _settings);
			_collaborationController.addEventListener(CollaborationLobbyNetConnectionEvent.SYNCHRONIZE, synchronizeHandler);
			if (collaborationView != null)
				collaborationView.init(_collaborationController);
		}

		private function synchronizeHandler(event:CollaborationLobbyNetConnectionEvent):void
		{

		}

		/**
		 * Method that should be called by subclasses to create a session with the Indivo backend server.
		 */
		protected function createSession():void
		{
			_logger.info("Creating session in Indivo...");
			_applicationControllerModel.createSessionStatus = ApplicationControllerModel.CREATE_SESSION_STATUS_ATTEMPTING;
			var createSessionHealthRecordService:CreateSessionHealthRecordService = new CreateSessionHealthRecordService(_settings.oauthChromeConsumerKey,
																														 _settings.oauthChromeConsumerSecret,
																														 _settings.indivoServerBaseURL,
																														 _activeAccount);
			createSessionHealthRecordService.addEventListener(HealthRecordServiceEvent.COMPLETE,
															  createSessionSucceededHandler);
			createSessionHealthRecordService.addEventListener(HealthRecordServiceEvent.ERROR,
															  createSessionFailedHandler);
			createSessionHealthRecordService.createSession(_settings.username, _settings.password);
		}

		private function createSessionSucceededHandler(event:HealthRecordServiceEvent):void
		{
			_logger.info("Creating session in Indivo - SUCCEEDED");
			_applicationControllerModel.createSessionStatus = ApplicationControllerModel.CREATE_SESSION_STATUS_SUCCEEDED;

			// get information for the account actively in session, this may be useful if accounts are implemented to have credentials, such as MD or RN
			// currently it is not useful, so the function is never called
			// TODO: add the ability to retrieve credentials if they are implemented
//            getAccountInformation();

			openActiveAccount(_activeAccount);

			// get the records for the account actively in session, this includes records that have been shared with the account
			getRecords();
		}

		private function createSessionFailedHandler(event:HealthRecordServiceEvent):void
		{
			// TODO: add UI feedback for when creating a session fails
			_logger.info("Creating session in Indivo - FAILED - " + event.errorStatus);
			_applicationControllerModel.createSessionStatus = ApplicationControllerModel.CREATE_SESSION_STATUS_FAILED;
		}

		/**
		 * Virtual method which subclasses should override to dictate what happens when the active account is opened
		 *
		 * @param activeAccount
		 *
		 */
		protected function openActiveAccount(activeAccount:Account):void
		{

		}

		private function getAccountInformation():void
		{
			var accountInformationHealthRecordService:AccountInformationHealthRecordService = new AccountInformationHealthRecordService(_settings.oauthChromeConsumerKey,
																																		_settings.oauthChromeConsumerSecret,
																																		_settings.indivoServerBaseURL,
																																		_activeAccount);
			accountInformationHealthRecordService.retrieveAccountInformation(_activeAccount);
		}

		// get the records for the account actively in session, this includes records that have been shared with the account
		private function getRecords():void
		{
			_logger.info("Getting records from Indivo...");

			var recordsHealthRecordService:RecordsHealthRecordService = new RecordsHealthRecordService(_settings.oauthChromeConsumerKey,
																									   _settings.oauthChromeConsumerSecret,
																									   _settings.indivoServerBaseURL,
																									   _activeAccount,
																									   _settings);
			recordsHealthRecordService.addEventListener(HealthRecordServiceEvent.COMPLETE,
														getRecordsCompleteHandler);
			recordsHealthRecordService.getRecords();
		}

		private function getRecordsCompleteHandler(event:HealthRecordServiceEvent):void
		{
			_logger.info("Getting records from Indivo - SUCCEEDED");

			if (_settings.isPatientMode)
			{
				// If the application is in patient mode, then it needs to know with what accounts
				// the primary record of the active account is shared so that it can inform the collaboration server
				getShares();
			}
			else if (_settings.isClinicianMode)
			{
				// enter the collaboration lobby, since all of the necessary accountIds are known, a clinician does not have any shares
				enterCollaborationLobby();

				// get the demographics for the active account all of the shared records
				getDemographics();
			}
		}

		// if the application is in patient mode, get the accounts with which the primary record of the active account is shared
		private function getShares():void
		{
			_logger.info("Getting shares from Indivo...");

			var sharesHealthRecordService:SharesHealthRecordService = new SharesHealthRecordService(_settings.oauthChromeConsumerKey,
																									_settings.oauthChromeConsumerSecret,
																									_settings.indivoServerBaseURL,
																									_activeAccount);
			sharesHealthRecordService.addEventListener(HealthRecordServiceEvent.COMPLETE,
													   getSharesCompleteHandler);
			sharesHealthRecordService.getShares(_activeAccount.primaryRecord);
		}

		private function getSharesCompleteHandler(event:HealthRecordServiceEvent):void
		{
			_logger.info("Getting shares from Indivo - SUCCEEDED");

			// enter the collaboration lobby, since all of the necessary accountIds are known
			enterCollaborationLobby();

			// open the primary record of the active account, since the application is in patient mode
			openRecordAccount(_activeAccount);

			// get the demographics for the active account
			getDemographics();
		}

		// get the demographics for the active account and all of the sharing accounts
		private function getDemographics():void
		{
			var demographicsHealthRecordService:DemographicsHealthRecordService = new DemographicsHealthRecordService(_settings.oauthChromeConsumerKey,
																													  _settings.oauthChromeConsumerSecret,
																													  _settings.indivoServerBaseURL,
																													  _activeAccount);
			demographicsHealthRecordService.getDemographics(_activeAccount.primaryRecord);

			for each (var account:Account in _activeAccount.allSharingAccounts)
			{
				demographicsHealthRecordService.getDemographics(account.primaryRecord);
			}
		}

		// Enter the collaboration lobby so that the user can see which other users are online
		// This must be done after all of the shared records and record shares have been retrieved so that the accountIds are known
		private function enterCollaborationLobby():void
		{
			// Enter the collaboration lobby, so that the user can see when other account owners are online
			collaborationController.collaborationModel.collaborationLobbyNetConnectionService.enterCollaborationLobby();
		}

		/**
		 * Virtual method which subclasses should override to dictate what happens when a record is opened
		 *
		 * @param recordAccount
		 *
		 */
		public function openRecordAccount(recordAccount:Account):void
		{
			_activeRecordAccount = recordAccount;
			_collaborationController.setActiveRecordAccount(recordAccount);
		}

		/**
		 * Virtual method which subclasses should override to dictate what happens when a record is closed
		 *
		 * @param recordAccount
		 *
		 */
		public function closeRecordAccount(recordAccount:Account):void
		{

		}

		public function set targetDate(value:Date):void
		{
			_settings.targetDate = value;
			var dateSource:DemoCurrentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as DemoCurrentDateSource;
			if (dateSource != null)
			{
				_logger.info("Changing demo date from " + getTargetDateString(dateSource.targetDate) + " to " + getTargetDateString(value) + "...");
				dateSource.targetDate = value;
				changeDemoDate();
			}
		}

		private function getTargetDateString(value:Date):String
		{
			if (value)
				return value.toDateString();
			else
				return "null (demo mode off)";
		}

		public function reloadPlugins():void
		{
			_reloadWithRecordAccount = _activeRecordAccount;
			_reloadWithFullView = currentFullView;

			closeRecordAccount(_activeRecordAccount);
			_componentContainer.removeAllComponents();
			_pluginLoader.unloadPlugins();

			_pluginLoader.loadPlugins();
		}

		private function pluginLoader_complete(event:Event):void
		{
			handlePluginsLoaded();
		}

		protected function handlePluginsLoaded():void
		{
			_logger.info("Plugins loaded.");
			var array:Array = _componentContainer.resolveAll(AppControllerInfo);
			_logger.info("  Number of registered AppControllerInfo objects (apps): " + (array ? array.length : 0));

			if (_reloadWithRecordAccount)
				openRecordAccount(_reloadWithRecordAccount);
		}

		protected function get appControllersMediator():AppControllersMediatorBase
		{
			throw new Error("virtual function must be overridden in subclass");
		}

		protected function changeDemoDate():void
		{
			throw new Error("virtual function must be overridden in subclass");
		}

		public function get settingsFileStore():SettingsFileStore
		{
			return _settingsFileStore;
		}

		public function get collaborationController():CollaborationController
		{
			return _collaborationController;
		}

		public function set collaborationController(value:CollaborationController):void
		{
			_collaborationController = value;
		}

		public function get componentContainer():IComponentContainer
		{
			return _componentContainer;
		}

		public function get settings():Settings
		{
			return _settings;
		}

		public function get currentFullView():String
		{
			throw new Error("virtual function must be overriden in subclass");
		}

		public function get fullContainer():IVisualElementContainer
		{
			throw new Error("virtual function must be overriden in subclass");
		}

		public function get applicationSettingsEmbeddedFile():Class
		{
			throw new Error("Virtual method must be overridden in subclasses");
		}

		protected function loadDocuments(recordAccount:Account):void
		{
			// TODO: What if we are already saving or loading? What if there are unsaved pending changes?
			_healthRecordServiceFacade = new HealthRecordServiceFacade(settings.oauthChromeConsumerKey,
																	   settings.oauthChromeConsumerSecret,
																	   settings.indivoServerBaseURL,
																	   _activeAccount);
			BindingUtils.bindSetter(serviceIsLoading_changeHandler, _healthRecordServiceFacade, "isLoading");
			BindingUtils.bindSetter(serviceIsSaving_changeHandler, _healthRecordServiceFacade, "isSaving");
			BindingUtils.bindSetter(serviceHasFailedSaveOperations_changeHandler, _healthRecordServiceFacade, "hasFailedSaveOperations");
			_healthRecordServiceFacade.loadDocuments(recordAccount.primaryRecord);
		}

		protected function reloadDocuments(recordAccount:Account):void
		{
			// TODO: What if we are already saving or loading? What if there are unsaved pending changes?
			recordAccount.primaryRecord.clearDocuments();
			_healthRecordServiceFacade.loadDocuments(recordAccount.primaryRecord);
		}

		/**
		 * Virtual method which subclasses should override to reflect a change in the isLoading flag
		 */
		protected function serviceIsLoading_changeHandler(isLoading:Boolean):void
		{
		}

		/**
		 * Virtual method which subclasses should override to reflect a change in the hasFailedSaveOperations flag
		 */
		protected function serviceHasFailedSaveOperations_changeHandler(hasFailedSaveOperations:Boolean):void
		{
		}

		/**
		 * Virtual method which subclasses should override to reflect a change in the isSaving flag
		 */
		protected function serviceIsSaving_changeHandler(isSaving:Boolean):void
		{
		}
	}
}