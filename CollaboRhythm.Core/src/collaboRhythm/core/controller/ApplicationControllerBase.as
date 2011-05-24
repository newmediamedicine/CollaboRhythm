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

    import collaboRhythm.core.pluginsManagement.DefaultComponentContainer;
    import collaboRhythm.core.pluginsManagement.PluginLoader;
    import collaboRhythm.core.view.RemoteUsersListView;
    import collaboRhythm.shared.controller.CollaborationController;
    import collaboRhythm.shared.controller.apps.AppControllerInfo;
    import collaboRhythm.shared.model.Account;
    import collaboRhythm.shared.model.Record;
    import collaboRhythm.shared.model.User;
    import collaboRhythm.shared.model.healthRecord.CreateSessionHealthRecordService;
    import collaboRhythm.shared.model.healthRecord.DemographicsHealthRecordService;
    import collaboRhythm.shared.model.healthRecord.HealthRecordServiceEvent;
    import collaboRhythm.shared.model.healthRecord.RecordsHealthRecordService;
    import collaboRhythm.shared.model.healthRecord.SharesHealthRecordService;
    import collaboRhythm.shared.model.services.DemoCurrentDateSource;
    import collaboRhythm.shared.model.services.ICurrentDateSource;
    import collaboRhythm.shared.model.services.WorkstationKernel;
    import collaboRhythm.shared.model.settings.Settings;
    import collaboRhythm.shared.model.settings.SettingsFileStore;
    import collaboRhythm.shared.pluginsSupport.IComponentContainer;
    import collaboRhythm.shared.view.CollaborationRoomView;
    import collaboRhythm.shared.view.RecordVideoView;

    import com.coltware.airxlib.log.FileTarget;
    import com.coltware.airxlib.log.UDPSyslogTarget;

    import flash.events.Event;
    import flash.filesystem.File;
    import flash.utils.getQualifiedClassName;

    import mx.core.IVisualElementContainer;
    import mx.logging.ILogger;
    import mx.logging.Log;
    import mx.logging.targets.TraceTarget;

    public class ApplicationControllerBase
    {
        private static const DEFAULT_SYSLOG_PORT:int = 514;

        protected var _kernel:IKernel;
        protected var _settingsFileStore:SettingsFileStore;
        protected var _settings:Settings;
        protected var _activeAccount:Account;
        private var _collaborationController:CollaborationController;
        protected var _collaborationMediator:CollaborationMediatorBase;
        protected var logger:ILogger;
        protected var _componentContainer:IComponentContainer;
        protected var _pluginLoader:PluginLoader;
        protected var _reloadWithFullView:String;

        public function get componentContainer():IComponentContainer
        {
            return _componentContainer;
        }

        public function get settings():Settings
        {
            return _settings;
        }

        public function get collaborationRoomView():CollaborationRoomView
        {
            throw new Error("virtual function must be overriden in subclass");
        }

        public function get recordVideoView():RecordVideoView
        {
            throw new Error("virtual function must be overriden in subclass");
        }

        public function get remoteUsersView():RemoteUsersListView
        {
            throw new Error("virtual function must be overriden in subclass");
        }

        public function get widgetsContainer():IVisualElementContainer
        {
            throw new Error("virtual function must be overriden in subclass");
        }

        public function get scheduleWidgetContainer():IVisualElementContainer
        {
            throw new Error("virtual function must be overriden in subclass");
        }

        public function get fullContainer():IVisualElementContainer
        {
            throw new Error("virtual function must be overriden in subclass");
        }

        public function ApplicationControllerBase()
        {

        }

        // To be overridden by subclasses with the super method called at the beginning
        // subclasses can then perform appropriate actions after settings, logging, and components have been initialized
        public function main():void
        {
            _activeAccount = new Account();

            initSettings();

            initLogging();
            logger.info("Logging initialized");

            // initSettings needs to be called prior to initLogging because the settings for logging need to be loaded first
            logger.info("Settings initialized");
            logger.info("  Application settings file: " + _settingsFileStore.applicationSettingsFile.nativePath);
            logger.info("  User settings file: " + _settingsFileStore.userSettingsFile.nativePath);
            logger.info("  Mode: " + _settings.mode);
            logger.info("  Username: " + _settings.username);

            initComponents();
            logger.info("Components initialized. Asynchronous plugin loading initiated.");
            logger.info("  User plugins directory: " + _pluginLoader.userPluginsDirectoryPath);
            logger.info("  Number of loaded plugins: " + _pluginLoader.numPluginsLoaded);
        }

        private function initSettings():void
        {
            _settingsFileStore = new SettingsFileStore();
            _settingsFileStore.readSettings();
            _settings = _settingsFileStore.settings;
        }

        private function initLogging():void
        {
            // TODO: Determine what action is taken when the log file exceeds a certain size
            // TODO: Add settings for controlling logging to the settings file
            // TODO: Handle exceptions is using a fileTarget, on several occasions an exceptions has occured where the file is in use
            // create a file target for logging
//            var fileTarget:FileTarget = new FileTarget();
//            // the file log will be stored in the application storage directory
//            fileTarget.directory = File.applicationStorageDirectory;
//            fileTarget.filename = "collaboRhythm.log";
//            // append the log information to the file rather than create a new file each time the application is run
//            fileTarget.append = true;
//            // add the file target to the log
//            Log.addTarget(fileTarget);

            // create a trace target for logging
//            var traceTarget:TraceTarget = new TraceTarget();
            // add the trace target to the log
//            Log.addTarget(traceTarget);

            // create a syslog target for logging and get the ip address from the settings file
            // Kiwi Syslog server has a free version http://www.kiwisyslog.com/kiwi-syslog-server-overview/
            // set the syslogServerIpAddress in your settings file to the IP address where the syslog server is running
            var udpSyslogTarget:UDPSyslogTarget = new UDPSyslogTarget(_settings.syslogServerIpAddress,
                                                                      DEFAULT_SYSLOG_PORT);
            // add the syslog target to the log
            Log.addTarget(udpSyslogTarget);

            logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
        }

        protected function testLogging():void
        {
            logger.info("Testing logger");
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
         * Virtual method which subclasses should override in order create a session with the Indivo backend server.
         */
        protected function createSession():void
        {
            logger.info("Creating session in Indivo...");
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
            logger.info("Creating session in Indivo - SUCCEEDED");
            // TODO: retrieve the account information for the account actively in session
            // this may be useful if accounts are implemented to have credentials, such as MD or RN
//            var accountInformationHealthRecordService:AccountInformationHealthRecordService = new AccountInformationHealthRecordService(_settings.oauthChromeConsumerKey, _settings.oauthChromeConsumerSecret, _settings.indivoServerBaseURL);
//            accountInformationHealthRecordService.retrieveAccountInformation(_account);

            connectCollaborationServer();

            logger.info("Retrieving records from Indivo...");
            // retrieve the records for the account actively in session, this includes records that have been shared with the account
            var recordsHealthRecordService:RecordsHealthRecordService = new RecordsHealthRecordService(_settings.oauthChromeConsumerKey,
                                                                                                       _settings.oauthChromeConsumerSecret,
                                                                                                       _settings.indivoServerBaseURL,
                                                                                                       _activeAccount);
            recordsHealthRecordService.addEventListener(HealthRecordServiceEvent.COMPLETE,
                                                        retrieveRecordsCompleteHandler);
            recordsHealthRecordService.getRecords();
        }

        // Connect to the collaboration server, which is currently a Flash Media Server
        // This server allows the user to see when other account owners are online
        // It also allows collaboration with these account owners and sending and viewing of asynchronous video
        private function connectCollaborationServer():void
        {

        }

        private function createSessionFailedHandler(event:HealthRecordServiceEvent):void
        {
            // TODO: add UI feedback for when creating a session fails
            logger.info("Creating session in Indivo - FAILED - " + event.errorStatus);
        }

        private function retrieveRecordsCompleteHandler(event:HealthRecordServiceEvent):void
        {
            // No matter what mode the application is in, the demographics for the account actively in session are needed
            var demographicsHealthRecordService:DemographicsHealthRecordService = new DemographicsHealthRecordService(_settings.oauthChromeConsumerKey,
                                                                                                                      _settings.oauthChromeConsumerSecret,
                                                                                                                      _settings.indivoServerBaseURL,
                                                                                                                      _activeAccount);
            demographicsHealthRecordService.getDemographics(_activeAccount.primaryRecord);

            if (_settings.isPatientMode)
            {
                // If the application is in patient mode, then it needs to know with what accounts
                // the primary record is shared so that it can inform the collaboration server
                var sharesHealthRecordService:SharesHealthRecordService = new SharesHealthRecordService(_settings.oauthChromeConsumerKey,
                                                                                                        _settings.oauthChromeConsumerSecret,
                                                                                                        _settings.indivoServerBaseURL,
                                                                                                        _activeAccount);
                sharesHealthRecordService.addEventListener(HealthRecordServiceEvent.COMPLETE,
                                                           retrieveSharesCompleteHandler);
                sharesHealthRecordService.getShares(_activeAccount.primaryRecord);
            }
            else if (_settings.isClinicianMode)
            {
                // If the application is in clinician mode, it is necessary to get the demographics data for each of the shared record
                for each (var account:Account in _activeAccount.sharedRecordAccounts)
                {
                    demographicsHealthRecordService.getDemographics(account.primaryRecord);
                }
            }
        }

        private function retrieveSharesCompleteHandler(event:HealthRecordServiceEvent):void
        {

        }

        /**
         * Virtual method which subclasses should override to dictate what happens when a record is opened
         *
         * @param recordAccount
         *
         */
        public function openRecordAccount(recordAccount:Account):void
        {

        }

        protected function set targetDate(value:Date):void
        {
            _settings.targetDate = value;
            var dateSource:DemoCurrentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as DemoCurrentDateSource;
            if (dateSource != null)
            {
                dateSource.targetDate = value;
                changeDemoDate();
            }
        }

        protected function changeDemoDate():void
        {
            _collaborationMediator.changeDemoDate();
        }

        public function reloadPlugins():void
        {
            _reloadWithUser = _collaborationMediator.subjectUser;
            _reloadWithFullView = _collaborationMediator.currentFullView;

            _collaborationMediator.closeRecord();
            _componentContainer.removeAllComponents();
            _pluginLoader.unloadPlugins();

            _pluginLoader.loadPlugins();
        }

        private function pluginLoader_complete(event:Event):void
        {
            handlePluginsLoaded();
        }

        protected var _reloadWithUser:User;

        protected function handlePluginsLoaded():void
        {
            logger.info("Plugins loaded.");
            var array:Array = _componentContainer.resolveAll(AppControllerInfo);
            logger.info("  Number of registered AppControllerInfo objects (apps): " + (array ? array.length : 0));

            if (_reloadWithUser)
                _collaborationMediator.openRecord(_reloadWithUser);

            if (_reloadWithFullView)
                _collaborationMediator.appControllersMediator.showFullView(_reloadWithFullView);
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
    }
}