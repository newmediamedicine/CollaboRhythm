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
	import collaboRhythm.core.model.AboutApplicationModel;
	import collaboRhythm.core.model.ApplicationControllerModel;
	import collaboRhythm.core.model.ApplicationNavigationProxy;
	import collaboRhythm.core.model.healthRecord.HealthRecordServiceFacade;
	import collaboRhythm.core.model.healthRecord.service.MessagesHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.ProblemsHealthRecordService;
	import collaboRhythm.core.pluginsManagement.DefaultComponentContainer;
	import collaboRhythm.core.pluginsManagement.PluginLoader;
	import collaboRhythm.core.view.AboutApplicationView;
	import collaboRhythm.core.view.ConnectivityEvent;
	import collaboRhythm.core.view.ConnectivityView;
	import collaboRhythm.shared.collaboration.controller.CollaborationController;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionEvent;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionService;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.collaboration.model.MessageEvent;
	import collaboRhythm.shared.collaboration.view.CollaborationView;
	import collaboRhythm.shared.controller.IApplicationControllerBase;
	import collaboRhythm.shared.controller.ICollaborationController;
	import collaboRhythm.shared.controller.apps.AppControllerInfo;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.BackgroundProcessCollectionModel;
	import collaboRhythm.shared.model.IApplicationNavigationProxy;
	import collaboRhythm.shared.model.InteractionLogUtil;
	import collaboRhythm.shared.model.healthRecord.AccountInformationHealthRecordService;
	import collaboRhythm.shared.model.healthRecord.CreateSessionHealthRecordService;
	import collaboRhythm.shared.model.healthRecord.DemographicsHealthRecordService;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceBase;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceEvent;
	import collaboRhythm.shared.model.healthRecord.RecordsHealthRecordService;
	import collaboRhythm.shared.model.healthRecord.SharesHealthRecordService;
	import collaboRhythm.shared.model.healthRecord.document.Message;
	import collaboRhythm.shared.model.services.DefaultCurrentDateSource;
	import collaboRhythm.shared.model.services.DefaultImageCacheService;
	import collaboRhythm.shared.model.services.DefaultMedicationColorSource;
	import collaboRhythm.shared.model.services.DemoCurrentDateSource;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.IImageCacheService;
	import collaboRhythm.shared.model.services.IMedicationColorSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;
	import collaboRhythm.shared.model.settings.Settings;
	import collaboRhythm.shared.model.settings.SettingsFileStore;

	import com.coltware.airxlib.log.TCPSyslogTarget;
	import com.daveoncode.logging.LogFileTarget;

	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;

	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.core.IVisualElementContainer;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	import mx.logging.targets.TraceTarget;

	import spark.components.ViewNavigator;

	[Bindable]
	public class ApplicationControllerBase implements IApplicationControllerBase, IErrorDetailsProvider
	{
		private static const ONE_MINUTE:int = 1000 * 60;

		protected var _applicationControllerModel:ApplicationControllerModel;
		protected var _kernel:IKernel;
		protected var _settingsFileStore:SettingsFileStore;
		private var _settings:Settings;
		protected var _hasActiveNetworkInterface:Boolean = false;
		private var _activeAccount:Account;
		private var _activeRecordAccount:Account;
		protected var _collaborationController:CollaborationController;
		protected var _logger:ILogger;
		protected var _componentContainer:IComponentContainer;
		protected var _pluginLoader:PluginLoader;
		protected var _reloadWithRecordAccount:Account;
		protected var _reloadWithFullView:String;
		protected var _healthRecordServiceFacade:HealthRecordServiceFacade;
		protected var _collaborationLobbyNetConnectionService:CollaborationLobbyNetConnectionService;
		private var _serviceIsSavingPrevious:Boolean = false;

		private var _pendingReloadData:Boolean;
		private var _pendingExit:Boolean;
		private var _pendingCloseRecordAccount:Account;

		protected var _connectivityView:ConnectivityView;
		protected var _aboutApplicationView:AboutApplicationView;
		private var _pendingServices:ArrayCollection = new ArrayCollection();
		private var failedRequestEvent:HealthRecordServiceEvent;

		private var _nextAutoSyncTime:Date;
		private var _autoSyncTimer:Timer;
		protected var _currentDateSource:ICurrentDateSource;

		private var _backgroundProcessModel:BackgroundProcessCollectionModel = new BackgroundProcessCollectionModel();
		protected var _navigationProxy:IApplicationNavigationProxy;
		protected var _collaborationLobbyNetConnectionServiceProxy:CollaborationLobbyNetConnectionServiceProxy;

		public function ApplicationControllerBase()
		{
			// TODO: add event listener to handle the fast forward mode of the date source
			_autoSyncTimer = new Timer(0);
			_autoSyncTimer.addEventListener(TimerEvent.TIMER, autoSyncTimer_timerHandler);
		}

		private function updateAutoSyncTime():void
		{
			_autoSyncTimer.stop();

			_nextAutoSyncTime = _currentDateSource.now();
			// move the time ahead to midnight tonight
			_nextAutoSyncTime.setHours(24, 0, 0, 0);
			var now:Date = _currentDateSource.now();
			// one minute cushion to ensure that the timer does not go off before midnight; slightly after is better than before
			var cushionDelay:Number = ONE_MINUTE;
			var delay:Number = _nextAutoSyncTime.getTime() - now.getTime() + cushionDelay;

			_logger.info("Automatic synchronization timer set to go off at or after " + _nextAutoSyncTime +
					" in " + delay / ONE_MINUTE + " minutes");
			_autoSyncTimer.delay = delay;
			_autoSyncTimer.start();
		}

		private function autoSyncTimer_timerHandler(event:TimerEvent):void
		{
			var now:Date = new Date();
			if (now.getTime() < _nextAutoSyncTime.getTime())
			{
				_logger.warn("Automatic synchronization timer went off before the expected time.");
			}

			_logger.info("Performing automatic synchronization from timer event. Local time: " + now.toString() +
					". Expected auto sync time: " + _nextAutoSyncTime.toString() +
					". Previous timer delay (minutes): " + _autoSyncTimer.delay / ONE_MINUTE);
			synchronize();
			updateAutoSyncTime();
		}

		/**
		 * Main function to start the application running.
		 * This method should be overridden by subclasses with the super method called at the beginning subclasses
		 * can then perform appropriate actions after settings, logging, and components have been initialized.
		 */
		public function main():void
		{
			_applicationControllerModel = new ApplicationControllerModel();
			_applicationControllerModel.isLoading = true;
			BindingUtils.bindSetter(applicationControllerModel_isLoadingChangeHandler, _applicationControllerModel,
					"isLoading");
			BindingUtils.bindSetter(applicationControllerModel_hasErrorsChangeHandler, _applicationControllerModel,
					"hasErrors");

			// initSettings needs to be called prior to initLogging because the settings for logging need to be loaded first
			initSettings();

			// TODO: provide feedback if there is not an active NetworkInterface
			checkNetworkStatus();

			initLogging();

			var applicationInfo:AboutApplicationModel = new AboutApplicationModel();
			applicationInfo.initialize();
			_logger.info("Application: " + applicationInfo.appName);
			_logger.info("  " + applicationInfo.appCopyright);
			_logger.info("  Version " + applicationInfo.appVersion);
			if (applicationInfo.appModificationDateString)
			{
				_logger.info("  Updated " + applicationInfo.appModificationDateString);
			}
			_logger.info("  " + applicationInfo.deviceDetails);

			/*
			 <s:Label id="applicationNameLabel" text="{_applicationInfo.appName}" fontSize="36"/>
			 <s:Label id="applicationCopyrightLabel" text="{_applicationInfo.appCopyright}"/>
			 <s:Label id="applicationVersionLabel" text="Version {_applicationInfo.appVersion}"/>
			 <s:Label id="applicationModificationLabel" text="Updated {_applicationInfo.appModificationDateString}"
			 */


			_logger.info("Settings initialized");
			_logger.info("  Application settings file loaded: " + _settingsFileStore.isApplicationSettingsLoaded);
			_logger.info("  User settings file loaded: " + _settingsFileStore.isUserSettingsLoaded + " path=" +
					_settingsFileStore.userSettingsFile.nativePath);
			_logger.info("  Mode: " + _settings.mode);
			_logger.info("  Username: " + _settings.username);
			if (_settings.demoModeEnabled)
				_logger.info("  Demo mode ON; target date: " + (_settings.targetDate ? _settings.targetDate.toLocaleString() : "(not specified)"));
			else
				_logger.info("  Demo mode OFF");

			initNativeApplicationEventListeners();

			initComponents();
			_logger.info("Components initialized. Asynchronous plugin loading initiated.");
			_logger.info("  User plugins directory: " + _pluginLoader.userPluginsDirectoryPath);
			_logger.info("  Number of loaded plugins: " + _pluginLoader.numPluginsLoaded);

			// the activeAccount is that which is actively in session with the Indivo server, there can only be one active account at a time
			// create an instance of this model class before creating a session so that the results are tracked by that instance
			_activeAccount = new Account();

			_navigationProxy = new ApplicationNavigationProxy(this);
		}

		protected function initNativeApplicationEventListeners():void
		{
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, nativeApplication_exitingHandler);

			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, nativeApplication_activateHandler);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, nativeApplication_deactivateHandler);

			// User idle/resent events don't work on mobile devices. Note that default NativeApplication.nativeApplication.idleThreshold = 300 (5 minutes)
			NativeApplication.nativeApplication.addEventListener(Event.USER_IDLE, nativeApplication_userIdleHandler);
			NativeApplication.nativeApplication.addEventListener(Event.USER_PRESENT,
					nativeApplication_userPresentHandler);
		}

		private function nativeApplication_exitingHandler(event:Event):void
		{
			if (activeRecordAccount)
			{
				autoSave();
				if (activeRecordAccount.primaryRecord.isSaving)
				{
					event.preventDefault();
					_pendingExit = true;
				}
				else
				{
					prepareToExit();
				}
			}
			else
			{
				prepareToExit();
			}
		}

		private function autoSave():void
		{
			// Don't try to auto-save on quit if we just tried to save and had errors (allow the user to force quit)
			if (activeRecordAccount && !hasErrorsSaving && !isSaving && _activeAccount.accountId == _activeRecordAccount.accountId)
				activeRecordAccount.primaryRecord.saveAllChanges();
		}

		/**
		 * Prepares the application for exit by doing any cleanup. No asynchronous processes should be started here
		 * as they will not be given a chance to complete. Subclasses should override to implement modality-specific behavior.
		 */
		protected function prepareToExit():void
		{
		}

		private function nativeApplication_activateHandler(event:Event):void
		{
			InteractionLogUtil.log(_logger, "Application activate");
		}

		private function nativeApplication_deactivateHandler(event:Event):void
		{
			InteractionLogUtil.log(_logger, "Application deactivate");

			if (isAutoSaveOnDeactivateEnabled && activeRecordAccount)
			{
				autoSave();
				if (activeRecordAccount.primaryRecord.isSaving)
				{
					// TODO: can we or should we prevent/delay deactivate while saving?
				}
				else
				{
					prepareToDeactivate();
				}
			}
		}

		private function get isAutoSaveOnDeactivateEnabled():Boolean
		{
			return !_settings.debuggingToolsEnabled;
		}

		private function prepareToDeactivate():void
		{
		}

		private function nativeApplication_userIdleHandler(event:Event):void
		{
			InteractionLogUtil.log(_logger,
					"User idle timeSinceLastUserInput=" + NativeApplication.nativeApplication.timeSinceLastUserInput);
		}

		private function nativeApplication_userPresentHandler(event:Event):void
		{
			InteractionLogUtil.log(_logger, "User present");
		}

		private function applicationControllerModel_isLoadingChangeHandler(value:Boolean):void
		{
			updateConnectivityView();
		}

		private function applicationControllerModel_hasErrorsChangeHandler(value:Boolean):void
		{
			updateConnectivityView();
		}

		private function initSettings():void
		{
			_settingsFileStore = new SettingsFileStore();
			_settingsFileStore.applicationSettingsEmbeddedFile = applicationSettingsEmbeddedFile;
			_settingsFileStore.readSettings();
			_settings = _settingsFileStore.settings;
		}

		/**
		 * Determines if the device has an available network interface, which is necessary to have a network connection.
		 * This feature is not supported for all mobile devices.
		 */
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

		/**
		 * Initializes the logging capabilities of CollaboRhythm (trace, file, and syslog) based on settings.
		 */
		private function initLogging():void
		{
			// create a file target for logging if specified in the settings file
			if (_settings.useFileTarget)
			{
				// The log file will be placed under applicationStorageDirectory folder
				var oldPath:String = File.applicationStorageDirectory.resolvePath("collaboRhythm.log").nativePath;

				// Use /data/local instead of /data/data because attempting to read the log from /data/data (on a non-rooted Android device) is problematic
				// TODO: figure out how to access the appropriate /data/data directory using "adb pull" and avoid using /data/local
//				var path:String = oldPath.replace("/data/data", "/data/local");
				var path:String = oldPath;
				if (path.indexOf("/data/data") == 0)
				{
					path = File.documentsDirectory.resolvePath(NativeApplication.nativeApplication.applicationID).resolvePath("collaboRhythm.log").nativePath;
				}

				var migrationMessage:String = copyOldLogFileToAccessiblePath(oldPath, path);

				var targetFile:File = new File(path);

				// get LogFileTarget's instance (LogFileTarget is a singleton)
				var fileTarget:LogFileTarget = LogFileTarget.getInstance();
				fileTarget.file = targetFile;
				/* Log all log levels. */
				fileTarget.level = LogEventLevel.ALL;
				fileTarget.sizeLimit = 1024;
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
				tcpSyslogTarget.logSourceIdentifier = _settings.logSourceIdentifier;
				tcpSyslogTarget.includeCategory = true;
				tcpSyslogTarget.fieldSeparator = "\t";

				// add the syslog target to the log
				Log.addTarget(tcpSyslogTarget);
			}

			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));

			_logger.info("Logging initialized");
			_logger.info("  Use file target: " + _settings.useFileTarget +
					(_settings.useFileTarget ? " path=" + path : ""));
			_logger.info("  Use trace target: " + _settings.useTraceTarget);
			_logger.info("  Use syslog target: " + _settings.useSyslogTarget +
					(_settings.useSyslogTarget ? " address=" + _settings.syslogServerIpAddress : ""));
			if (migrationMessage)
				_logger.info("  " + migrationMessage);
		}

		private function copyOldLogFileToAccessiblePath(oldPath:String, path:String):String
		{
			var message:String;
			var destinationFile:File = new File(path);
			var sourceFile:File = new File(oldPath);
			if (oldPath != path)
			{
				if (sourceFile.exists)
				{
					message = "Copying old log file " + oldPath + " to accessible path " + path;
					sourceFile.copyTo(destinationFile, true);
					var backupFile:File = sourceFile.parent.resolvePath("collaboRhythm.log.backup");
					sourceFile.moveTo(backupFile);
				}
				else
				{
					message = "Log file was not copied to accessible path because log file does not exist at: " +
							oldPath;
				}

				var directoryListing:Array = sourceFile.parent.getDirectoryListing();
				message += File.lineEnding + "Files in old log file directory: ";
				for each (var directoryFile:File in directoryListing)
				{
					message += File.lineEnding + "  " + directoryFile.name;
					if (!directoryFile.isDirectory && directoryFile.name.indexOf("collaboRhythm") != -1)
					{
						directoryFile.copyTo(destinationFile.parent.resolvePath("old_logs").resolvePath(directoryFile.name));
						message += " (copied)";
					}
				}
			}
			else
			{
				message = "Old log file migration unnecessary. Log file was not copied to accessible path because log file is not in a path that is known to be inaccessible: " +
						path;
			}
			return message;
		}

		protected function testLogging():void
		{
			_logger.info("Testing logger");
		}

		private function initComponents():void
		{
			_kernel = WorkstationKernel.instance;

			//	_kernel.registerComponentInstance("CurrentDateSource", ICurrentDateSource, new DefaultCurrentDateSource());
			var dateSource:ICurrentDateSource;
			if (_settings.demoModeEnabled || _settings.debuggingToolsEnabled)
			{
				var demoCurrentDateSource:DemoCurrentDateSource = new DemoCurrentDateSource();
				if (_settings.demoModeEnabled)
				{
					demoCurrentDateSource.targetDate = _settings.targetDate;
				}
				dateSource = demoCurrentDateSource;
			}
			else
			{
				dateSource = new DefaultCurrentDateSource();
			}
			_kernel.registerComponentInstance("CurrentDateSource", ICurrentDateSource, dateSource);
			_currentDateSource = dateSource;

			var medicationColorSource:DefaultMedicationColorSource = new DefaultMedicationColorSource();
			_kernel.registerComponentInstance("MedicationColorSource", IMedicationColorSource, medicationColorSource);

			var imageCacheService:DefaultImageCacheService = new DefaultImageCacheService();
			_kernel.registerComponentInstance("ImageCacheService", IImageCacheService, imageCacheService);

			_componentContainer = new DefaultComponentContainer();
			_pluginLoader = new PluginLoader(_settings);
			_pluginLoader.addEventListener(Event.COMPLETE, pluginLoader_complete);
			_pluginLoader.componentContainer = componentContainer;
			_pluginLoader.loadPlugins();
		}

		/**
		 * Method that should be called by subclasses to create a connection with the Flash Media Server.
		 */
		protected function initCollaborationController(collaborationView:CollaborationView = null):void
		{
			// the collaborationController coordinates interaction between the CollaborationModel and the CollaborationView and its children the RecordVideoView and CollaborationRoomView.
			// The CollaborationModel, through its services, connects to the collaboration server, which is currently a Flash Media Server
			// This server allows the user to see when other account owners are online
			// It also allows collaboration with these account owners and sending and viewing of asynchronous video

			_collaborationController = new CollaborationController(_activeAccount, collaborationView, _settings);
			_collaborationLobbyNetConnectionService = _collaborationController.collaborationModel.collaborationLobbyNetConnectionService as
					CollaborationLobbyNetConnectionService;
			_collaborationLobbyNetConnectionServiceProxy = _collaborationController.collaborationModel.collaborationLobbyNetConnectionService.createProxy(_pluginLoader.pluginsApplicationDomain);
			_collaborationController.addEventListener(CollaborationLobbyNetConnectionEvent.SYNCHRONIZE,
					synchronizeDataHandler);
			BindingUtils.bindSetter(collaborationLobbyIsConnecting_changeHandler,
					_collaborationLobbyNetConnectionService, "isConnecting");
			BindingUtils.bindSetter(collaborationLobbyHasConnectionFailed_changeHandler,
					_collaborationLobbyNetConnectionService, "hasConnectionFailed");
			if (collaborationView != null)
				collaborationView.init(_collaborationController);
		}

		protected function synchronizeDataHandler(event:CollaborationLobbyNetConnectionEvent):void
		{
			if (!activeRecordAccount.primaryRecord.isLoading && !activeRecordAccount.primaryRecord.isSaving &&
					!_pendingExit && !_pendingReloadData)
				reloadData();
		}

		public function sendCollaborationInvitation():void
		{
			if (_settings.mode == Settings.MODE_CLINICIAN)
			{
				_collaborationController.sendCollaborationInvitation(activeRecordAccount, activeRecordAccount);
			}
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
			addPendingService(createSessionHealthRecordService);
			createSessionHealthRecordService.addEventListener(HealthRecordServiceEvent.COMPLETE,
					createSessionSucceededHandler);
			createSessionHealthRecordService.addEventListener(HealthRecordServiceEvent.FAILED,
					createSessionFailedHandler);
			createSessionHealthRecordService.createSession(_settings.username, _settings.password);
		}

		protected function addPendingService(service:HealthRecordServiceBase):void
		{
			_pendingServices.addItem(service);
			_applicationControllerModel.isLoading = true;
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

			removePendingService(event.target);
		}

		private function createSessionFailedHandler(event:HealthRecordServiceEvent):void
		{
			// TODO: add UI feedback for when creating a session fails
			_logger.info("Creating session in Indivo - FAILED - " + event.errorStatus);
			_applicationControllerModel.createSessionStatus = ApplicationControllerModel.CREATE_SESSION_STATUS_FAILED;
			handleServiceFailed(event,
					"Failed to authenticate with health record service. Check settings and internet connection and try again.");
		}

		protected function handleServiceFailed(event:HealthRecordServiceEvent, errorMessage:String):void
		{
			// TODO: distinguish between (1) connection/stream errors, (2) permission errors (bad credentials), and (3) unexpected errors
			_applicationControllerModel.errorMessage = errorMessage;
			_applicationControllerModel.hasErrors = true;
			failedRequestEvent = event;
			removePendingService(event.target);
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
			addPendingService(recordsHealthRecordService);

			recordsHealthRecordService.addEventListener(HealthRecordServiceEvent.COMPLETE,
					getRecordsCompleteHandler);
			recordsHealthRecordService.addEventListener(HealthRecordServiceEvent.FAILED,
					getRecordsFailedHandler);
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
				showSelectRecordView();

				// enter the collaboration lobby, since all of the necessary accountIds are known, a clinician does not have any shares
				enterCollaborationLobby();

				// get the demographics for the active account all of the shared records
				getDemographics();

				// get the problems for all of the shared records
				getProblems();

				// get the messages for the account actively in session
				// do this after the records have been retrieved so that the number of new messages from each record can be tracked
				getMessages();
			}
			removePendingService(event.target);
		}

		private function getRecordsFailedHandler(event:HealthRecordServiceEvent):void
		{
			_applicationControllerModel.errorMessage = "Failed to get records.";
			_applicationControllerModel.hasErrors = true;
			removePendingService(event.target);
		}

		// get the messages for the account actively in session
		private function getMessages():void
		{
			_logger.info("Getting messages from Indivo...");

			var messagesHealthRecordService:MessagesHealthRecordService = new MessagesHealthRecordService(_settings.oauthChromeConsumerKey,
					_settings.oauthChromeConsumerSecret,
					_settings.indivoServerBaseURL,
					_activeAccount);
			addPendingService(messagesHealthRecordService);

			messagesHealthRecordService.addEventListener(HealthRecordServiceEvent.COMPLETE, getMessagesCompleteHandler);
			messagesHealthRecordService.addEventListener(HealthRecordServiceEvent.FAILED, getMessagesFailedHandler);
			messagesHealthRecordService.getMessages(_activeAccount.accountId);
		}

		private function getMessagesCompleteHandler(event:HealthRecordServiceEvent):void
		{
			removePendingService(event.target);
		}

		private function getMessagesFailedHandler(event:HealthRecordServiceEvent):void
		{
			removePendingService(event.target);
		}

		public function showSelectRecordView():void
		{

		}

		// if the application is in patient mode, get the accounts with which the primary record of the active account is shared
		private function getShares():void
		{
			_logger.info("Getting shares from Indivo...");

			var sharesHealthRecordService:SharesHealthRecordService = new SharesHealthRecordService(_settings.oauthChromeConsumerKey,
					_settings.oauthChromeConsumerSecret,
					_settings.indivoServerBaseURL,
					_activeAccount);
			addPendingService(sharesHealthRecordService);
			sharesHealthRecordService.addEventListener(HealthRecordServiceEvent.COMPLETE,
					getSharesCompleteHandler);
			sharesHealthRecordService.addEventListener(HealthRecordServiceEvent.FAILED,
					getSharesFailedHandler);
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

			// get the messages for the account actively in session
			getMessages();

			removePendingService(event.target);
		}

		private function getSharesFailedHandler(event:HealthRecordServiceEvent):void
		{
			_applicationControllerModel.errorMessage = "Failed to get shares.";
			_applicationControllerModel.hasErrors = true;
			removePendingService(event.target);
		}

		// get the demographics for the active account and all of the sharing accounts
		private function getDemographics():void
		{
			var demographicsHealthRecordService:DemographicsHealthRecordService =
					new DemographicsHealthRecordService(_settings.oauthChromeConsumerKey,
							_settings.oauthChromeConsumerSecret,
							_settings.indivoServerBaseURL,
							_activeAccount);

			addPendingService(demographicsHealthRecordService);
			demographicsHealthRecordService.addEventListener(HealthRecordServiceEvent.COMPLETE,
					demographicsHealthRecordService_completeHandler, false, 0, true);
			// TODO: add support to DemographicsHealthRecordService for failing and retrying; currently, this event is not being dispatched
			demographicsHealthRecordService.addEventListener(HealthRecordServiceEvent.FAILED,
					demographicsHealthRecordService_failedHandler, false, 0, true);
			demographicsHealthRecordService.getDemographics(_activeAccount.primaryRecord);

			for each (var account:Account in _activeAccount.allSharingAccounts)
			{
				if (account.primaryRecord)
					demographicsHealthRecordService.getDemographics(account.primaryRecord);
				else
					_logger.warn("Record from account " + account.accountId +
							" is not available (probably not shared) to account " + _activeAccount.accountId +
							". You may need to share this record.");
			}
		}

		// get the problems for each of the sharedRecords when in clinician mode
		private function getProblems():void
		{
			var problemsHealthRecordService:ProblemsHealthRecordService = new ProblemsHealthRecordService(_settings.oauthChromeConsumerKey,
					_settings.oauthChromeConsumerSecret, _settings.indivoServerBaseURL, _activeAccount,
					_settings.debuggingToolsEnabled);
			addPendingService(problemsHealthRecordService);
			problemsHealthRecordService.addEventListener(HealthRecordServiceEvent.COMPLETE,
					problemsHealthRecordService_completeHandler, false, 0, true);
			problemsHealthRecordService.addEventListener(HealthRecordServiceEvent.FAILED,
					problemsHealthRecordService_failedHandler, false, 0, true);

			for each (var account:Account in _activeAccount.sharedRecordAccounts)
			{
				if (account.primaryRecord)
					problemsHealthRecordService.loadDocuments(account.primaryRecord);
				else
					_logger.warn("Record from account " + account.accountId +
							" is not available (probably not shared) to account " + _activeAccount.accountId +
							". You may need to share this record.");
			}
		}

		private function demographicsHealthRecordService_completeHandler(event:HealthRecordServiceEvent):void
		{
			_activeAccount.sharedRecordAccountsCollection.refresh();
			_activeAccount.isInitialized = true;
			removePendingService(event.target);
		}

		private function demographicsHealthRecordService_failedHandler(event:HealthRecordServiceEvent):void
		{
			_applicationControllerModel.errorMessage = "Failed to load demographics.";
			_applicationControllerModel.hasErrors = true;
			removePendingService(event.target);
		}

		private function problemsHealthRecordService_completeHandler(event:HealthRecordServiceEvent):void
		{
			removePendingService(event.target);
		}

		private function problemsHealthRecordService_failedHandler(event:HealthRecordServiceEvent):void
		{
			_applicationControllerModel.errorMessage = "Failed to load problems.";
			_applicationControllerModel.hasErrors = true;
			removePendingService(event.target);
		}

		private function removePendingService(service:Object):void
		{
			var index:int = _pendingServices.getItemIndex(service);
			if (index != -1)
			{
				_pendingServices.removeItemAt(index);
			}

			checkPendingServices();
		}

		private function checkPendingServices():void
		{
			if (_applicationControllerModel.isLoading && _pendingServices.length == 0)
			{
				_applicationControllerModel.isLoading = false;
			}
		}

		// Enter the collaboration lobby so that the user can see which other users are online
		// This must be done after all of the shared records and record shares have been retrieved so that the accountIds are known
		private function enterCollaborationLobby():void
		{
			// Enter the collaboration lobby, so that the user can see when other account owners are online
			_collaborationLobbyNetConnectionService.enterCollaborationLobby();

			_collaborationLobbyNetConnectionServiceProxy.addEventListener(MessageEvent.MESSAGE, collaborationMessage_eventHandler);
		}

		private function collaborationMessage_eventHandler(event:MessageEvent):void
		{
			var message:Message = event.messageData as Message;
			message.received_at = new Date();
			message.type = Message.INBOX;

			_activeAccount.messagesModel.addInboxMessage(message);

			var senderAccount:Account = _activeAccount.allSharingAccounts[message.sender];
			senderAccount.messagesModel.addInboxMessage(message);
		}

		/**
		 * Virtual method which subclasses should override to dictate what happens when a record is opened
		 *
		 * @param recordAccount
		 *
		 */
		public function openRecordAccount(recordAccount:Account):void
		{
			activeRecordAccount = recordAccount;
			_collaborationController.setActiveRecordAccount(recordAccount);

			// TODO: Rework document retrieval
			loadDocuments(recordAccount);

			updateAutoSyncTime();
		}

		public function tryCloseRecordAccount(recordAccount:Account):void
		{
			InteractionLogUtil.log(_logger, "Close record", "close record button");

			if (activeRecordAccount)
			{
				autoSave();
				if (activeRecordAccount.primaryRecord.isSaving)
				{
					_pendingCloseRecordAccount = recordAccount;
				}
				else
				{
					closeRecordAccount(recordAccount);
				}
			}

		}

		/**
		 * Virtual method which subclasses should override to dictate what happens when a record is closed
		 *
		 * @param recordAccount
		 *
		 */
		public function closeRecordAccount(recordAccount:Account):void
		{
			_autoSyncTimer.stop();
			if (_healthRecordServiceFacade)
				_healthRecordServiceFacade.closeRecord();
		}

		public function set targetDate(value:Date):void
		{
			_settings.targetDate = value;
			var dateSource:DemoCurrentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as
					DemoCurrentDateSource;
			if (dateSource != null)
			{
				_logger.info("Changing demo date from " + getTargetDateString(dateSource.targetDate) + " to " +
						getTargetDateString(value) + "...");
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
			_reloadWithRecordAccount = activeRecordAccount;
			_reloadWithFullView = currentFullView;

			closeRecordAccount(activeRecordAccount);
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

		public function get appControllersMediator():AppControllersMediatorBase
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
					settings.oauthChromeConsumerSecret, settings.indivoServerBaseURL, _activeAccount,
					settings.debuggingToolsEnabled);
			BindingUtils.bindSetter(serviceIsLoading_changeHandler, _healthRecordServiceFacade, "isLoading");
			BindingUtils.bindSetter(serviceIsSaving_changeHandler, _healthRecordServiceFacade, "isSaving");
			BindingUtils.bindSetter(serviceHasConnectionErrorsSaving_changeHandler, _healthRecordServiceFacade,
					"hasConnectionErrorsSaving");
			BindingUtils.bindSetter(serviceHasUnexpectedErrorsSaving_changeHandler, _healthRecordServiceFacade,
					"hasUnexpectedErrorsSaving");
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
			updateConnectivityView();
		}

		/**
		 * Virtual method which subclasses should override to reflect a change in the hasConnectionErrorsSaving flag
		 */
		protected function serviceHasConnectionErrorsSaving_changeHandler(hasConnectionErrorsSaving:Boolean):void
		{
			updateConnectivityView();
		}

		/**
		 * Virtual method which subclasses should override to reflect a change in the hasUnexpectedErrorsSaving flag
		 */
		protected function serviceHasUnexpectedErrorsSaving_changeHandler(hasUnexpectedErrorsSaving:Boolean):void
		{
			updateConnectivityView();
		}

		/**
		 * Virtual method which subclasses should override to reflect a change in the isSaving flag
		 */
		protected function serviceIsSaving_changeHandler(isSaving:Boolean):void
		{
			if (!isSaving && (isSaving != _serviceIsSavingPrevious) && !hasErrorsSaving)
			{
				_collaborationLobbyNetConnectionService.sendSynchronizationMessage();
				if (_pendingExit)
				{
					_pendingExit = false;
					exitApplication("delayed exit after save");
				}
				else if (_pendingCloseRecordAccount)
				{
					closeRecordAccount(_pendingCloseRecordAccount);
					_pendingCloseRecordAccount = null
				}
				else if (_pendingReloadData)
				{
					_pendingReloadData = false;
					reloadData();
				}
			}
			_serviceIsSavingPrevious = isSaving;
			updateConnectivityView();
			updateBackgroundProcess();
		}

		private function updateBackgroundProcess():void
		{
			backgroundProcessModel.updateProcess("healthRecordServiceFacade", "Saving...",
					_healthRecordServiceFacade && _healthRecordServiceFacade.isSaving);
		}

		private function get hasErrorsSaving():Boolean
		{
			return _healthRecordServiceFacade &&
					(_healthRecordServiceFacade.hasConnectionErrorsSaving ||
							_healthRecordServiceFacade.hasUnexpectedErrorsSaving);
		}

		private function get isSaving():Boolean
		{
			return _healthRecordServiceFacade && _healthRecordServiceFacade.isSaving;
		}

		/**
		 * Virtual method which subclasses should override to reflect a change in the isSaving flag
		 */
		protected function collaborationLobbyIsConnecting_changeHandler(isConnecting:Boolean):void
		{
			updateConnectivityView();
		}

		/**
		 * Virtual method which subclasses should override to reflect a change in the isSaving flag
		 */
		protected function collaborationLobbyHasConnectionFailed_changeHandler(failedConnection:Boolean):void
		{
			updateConnectivityView();
		}

		public function reloadData():void
		{
			if (activeRecordAccount != null)
			{
				reloadDocuments(activeRecordAccount);
				appControllersMediator.reloadUserData();
			}
		}

		public function synchronize():void
		{
			if (activeRecordAccount)
			{
				if (activeAccount.accountId == activeRecordAccount.accountId)
				{
					activeRecordAccount.primaryRecord.saveAllChanges();
				}
				if (activeRecordAccount.primaryRecord.isSaving)
					_pendingReloadData = true;
				else
					reloadData();
			}
			if (!_collaborationLobbyNetConnectionService.isConnected)
			{
				_collaborationLobbyNetConnectionService.enterCollaborationLobby();
			}
		}

		protected function updateConnectivityView():void
		{
			if (_connectivityView)
			{
				// TODO: perhaps we should have different states for saving vs loading
				_connectivityView.isLoading = _healthRecordServiceFacade && _healthRecordServiceFacade.isLoading;
				_connectivityView.isSaving = _healthRecordServiceFacade && _healthRecordServiceFacade.isSaving;

				var connectivityState:String;
				if (_applicationControllerModel && _applicationControllerModel.isLoading)
				{
					connectivityState = ConnectivityView.CONNECT_IN_PROGRESS_STATE;
					_connectivityView.detailsMessage = "Connecting to health record server...";
				}
				else if (_applicationControllerModel && _applicationControllerModel.hasErrors)
				{
					connectivityState = ConnectivityView.CONNECT_FAILED_STATE;
					_connectivityView.detailsMessage = "Connection to health record server " +
							settings.indivoServerBaseURL +
							" failed. You will not be able to access your health record until this is resolved. " +
							_applicationControllerModel.errorMessage;
				}
				else if (_collaborationLobbyNetConnectionService &&
						_collaborationLobbyNetConnectionService.isConnecting)
				{
					connectivityState = ConnectivityView.CONNECT_IN_PROGRESS_STATE;
					_connectivityView.detailsMessage = "Connecting to collaboration server...";
				}
				else if (_healthRecordServiceFacade && _healthRecordServiceFacade.isLoading)
				{
					connectivityState = ConnectivityView.CONNECT_IN_PROGRESS_STATE;
					_connectivityView.detailsMessage = "Loading data from health record server...";
				}
				else if (_healthRecordServiceFacade && _healthRecordServiceFacade.isSaving)
				{
//					connectivityState = ConnectivityView.CONNECT_IN_PROGRESS_STATE;
//					_connectivityView.detailsMessage = "Saving data to health record server...";
				}
				else if (_healthRecordServiceFacade && _healthRecordServiceFacade.hasConnectionErrorsSaving)
				{
					connectivityState = ConnectivityView.CONNECTION_ERRORS_SAVING_STATE;
					_connectivityView.detailsMessage = "Connection to health record server " +
							settings.indivoServerBaseURL + " failed. " + _healthRecordServiceFacade.errorsSavingSummary;
				}
				else if (_healthRecordServiceFacade && _healthRecordServiceFacade.hasUnexpectedErrorsSaving)
				{
					connectivityState = ConnectivityView.UNEXPECTED_ERRORS_SAVING_STATE;
					_connectivityView.detailsMessage = "Unexpected errors occurred while saving changes to health record server " +
							settings.indivoServerBaseURL + ". " + _healthRecordServiceFacade.errorsSavingSummary;
				}
				else if (_collaborationLobbyNetConnectionService &&
						_collaborationLobbyNetConnectionService.hasConnectionFailed)
				{
					connectivityState = ConnectivityView.CONNECT_FAILED_STATE;
					_connectivityView.detailsMessage = "Connection to collaboration server " + settings.rtmpBaseURI +
							" failed. You will not be able to access video messages or synchronization messages if data is changed from another device.";
				}

				if (connectivityState)
					_connectivityView.setCurrentState(connectivityState);

				_connectivityView.visible = connectivityState != null;
			}
		}

		protected function initializeConnectivityView():void
		{
			_connectivityView.errorDetailsProvider = this;
			_connectivityView.addEventListener(ConnectivityEvent.IGNORE, connectivityView_ignoreHandler);
			_connectivityView.addEventListener(ConnectivityEvent.QUIT, connectivityView_quitHandler);
			_connectivityView.addEventListener(ConnectivityEvent.RETRY, connectivityView_retryHandler);
		}

		public function getExtendedErrorDetails():String
		{
			var parts:Array = new Array();
			var applicationInfo:AboutApplicationModel = new AboutApplicationModel();
			applicationInfo.initialize();
			parts.push("Application: " + applicationInfo.appName);
			parts.push("  " + applicationInfo.appCopyright);
			parts.push("  Version " + applicationInfo.appVersion);
			if (applicationInfo.appModificationDateString)
			{
				parts.push("  Updated " + applicationInfo.appModificationDateString);
			}
			var settingsSourceClause:String = settingsFileStore.isUserSettingsLoaded ? (" (based on a combination of the default settings and user settings from " +
					settingsFileStore.userSettingsFile.nativePath +
					"):") : " (based on the default settings; user settings not loaded):";
			parts.push("\nSettings" + settingsSourceClause);
			parts.push(settingsFileStore.encodeToXML());
			var logFile:File = LogFileReader.getLogFile();
			var logFilePath:String = logFile ? logFile.nativePath : "";
			parts.push("\nLog (last part of file \"" + logFilePath + "\"):");
			parts.push(LogFileReader.getLogFileText());
			return parts.join("\n");
		}

		private function connectivityView_retryHandler(event:ConnectivityEvent):void
		{
			if (failedRequestEvent)
			{
				var service:HealthRecordServiceBase = failedRequestEvent.target as HealthRecordServiceBase;
				if (service == null)
					throw new Error("Attempted to retry request, but failed request event did not have a HealthRecordServiceBase as its target");

				// set isLoading = true first so that the ConnectivityView does not get hidden and then re-shown
				_applicationControllerModel.isLoading = true;
				service.resetAndRetryFailedRequest(failedRequestEvent.indivoClientEvent);
				failedRequestEvent = null;
				_applicationControllerModel.hasErrors = false;
			}
			if (_healthRecordServiceFacade && _healthRecordServiceFacade.currentRecord)
			{
				_healthRecordServiceFacade.isSaving = true;
				_healthRecordServiceFacade.resetConnectionErrorChangeSet();
				_healthRecordServiceFacade.saveAllChanges(_healthRecordServiceFacade.currentRecord);
			}
			if (_collaborationLobbyNetConnectionService && _collaborationLobbyNetConnectionService.hasConnectionFailed)
			{
				_collaborationLobbyNetConnectionService.enterCollaborationLobby();
			}
		}

		private function connectivityView_quitHandler(event:ConnectivityEvent):void
		{
			exitApplication("ConnectivityView Quit button");
		}

		private function connectivityView_ignoreHandler(event:ConnectivityEvent):void
		{
			_healthRecordServiceFacade.resetErrorChangeSets();
			_collaborationLobbyNetConnectionService.hasConnectionFailed = false;
			restoreFocus();
		}

		/**
		 * Virtual method which subclasses should override to allow focus to be restored in cases where the app loses
		 * focus
		 */
		protected function restoreFocus():void
		{

		}

		public function get pendingServices():ArrayCollection
		{
			return _pendingServices;
		}

		public function exitApplication(exitMethod:String):void
		{
			InteractionLogUtil.log(_logger, "Application exit", exitMethod);
			ApplicationExitUtil.exit();
		}

		public function showAboutApplicationView():void
		{
			if (_aboutApplicationView)
				_aboutApplicationView.visible = true;
		}

		[Bindable]
		public function get fastForwardEnabled():Boolean
		{
			var fastForwardEnabled:Boolean;
			var demoCurrentDateSource:DemoCurrentDateSource = _currentDateSource as DemoCurrentDateSource;
			if (demoCurrentDateSource)
			{
				fastForwardEnabled = demoCurrentDateSource.fastForwardEnabled;

			}
			return fastForwardEnabled;
		}

		public function set fastForwardEnabled(value:Boolean):void
		{
			var demoCurrentDateSource:DemoCurrentDateSource = _currentDateSource as DemoCurrentDateSource;
			if (demoCurrentDateSource)
			{
				demoCurrentDateSource.fastForwardEnabled = value;
			}
		}

		[Bindable]
		public function get backgroundProcessModel():BackgroundProcessCollectionModel
		{
			return _backgroundProcessModel;
		}

		public function set backgroundProcessModel(value:BackgroundProcessCollectionModel):void
		{
			_backgroundProcessModel = value;
		}

		public function useDemoPreset(demoPresetIndex:int):void
		{
			if (_settings.demoDatePresets && _settings.demoDatePresets.length > demoPresetIndex)
				targetDate = _settings.demoDatePresets[demoPresetIndex];
		}

		public function get activeRecordAccount():Account
		{
			return _activeRecordAccount;
		}

		public function set activeRecordAccount(value:Account):void
		{
			_activeRecordAccount = value;
		}

		public function get navigator():ViewNavigator
		{
			return null;
		}

		public function get iCollaborationController():ICollaborationController
		{
			return _collaborationController;
		}

		public function get activeAccount():Account
		{
			return _activeAccount;
		}

		public function set activeAccount(value:Account):void
		{
			_activeAccount = value;
		}

		public function navigateHome(source:String):void
		{
		}

		public function synchronizeBack(source:String):void
		{
		}
	}
}