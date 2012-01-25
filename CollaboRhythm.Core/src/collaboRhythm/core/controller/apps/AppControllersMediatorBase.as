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
package collaboRhythm.core.controller.apps
{

	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.problems.controller.ProblemsAppController;
	import collaboRhythm.shared.apps.allergies.controller.AllergiesAppController;
	import collaboRhythm.shared.apps.familyHistory.controller.FamilyHistoryAppController;
	import collaboRhythm.shared.apps.genetics.controller.GeneticsAppController;
	import collaboRhythm.shared.apps.imaging.controller.ImagingAppController;
	import collaboRhythm.shared.apps.immunizations.controller.ImmunizationsAppController;
	import collaboRhythm.shared.apps.labs.controller.LabsAppController;
	import collaboRhythm.shared.apps.procedures.controller.ProceduresAppController;
	import collaboRhythm.shared.apps.socialHistory.controller.SocialHistoryAppController;
	import collaboRhythm.shared.apps.vitals.controller.VitalsAppController;
	import collaboRhythm.shared.controller.apps.AppControllerInfo;
	import collaboRhythm.shared.controller.apps.AppEvent;
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerFactory;
	import collaboRhythm.shared.model.*;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.model.settings.AppGroupDescriptor;
	import collaboRhythm.shared.model.settings.Settings;

	import com.theory9.data.types.OrderedMap;

	import flash.desktop.NativeApplication;
	import flash.events.KeyboardEvent;
	import flash.net.registerClassAlias;
	import flash.ui.Keyboard;
	import flash.utils.getQualifiedClassName;

	import mx.collections.ArrayCollection;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.logging.ILogger;
	import mx.logging.Log;

	/**
	 * Responsible for creating the collection of workstation apps and adding them to the parent container.
	 *
	 */
	public class AppControllersMediatorBase
	{
		private var _widgetContainers:Vector.<IVisualElementContainer>;
		private var _fullContainer:IVisualElementContainer;
		private var _settings:Settings;
		private var _apps:OrderedMap;
		private var _appsById:OrderedMap;
		private var _collaborationRoomNetConnectionService:CollaborationRoomNetConnectionService;
		private var _factory:AppControllerFactory;
		private var _componentContainer:IComponentContainer;
		private static const STANDARD_APP_GROUP:String = "standard";
		private static const CUSTOM_APP_GROUP:String = "custom";
		private var _currentAppGroup:AppGroup;
		private var _appGroups:OrderedMap; // of AppGroup
		private var dynamicAppDictionary:OrderedMap;
		protected var _logger:ILogger;
		private var _currentFullView:String;
		private var _collaborationLobbyNetConnectionService:CollaborationLobbyNetConnectionService;
		private var _appsInitialized:ArrayCollection;

		public function AppControllersMediatorBase(widgetContainers:Vector.<IVisualElementContainer>,
												   fullParentContainer:IVisualElementContainer, settings:Settings,
												   componentContainer:IComponentContainer, collaborationLobbyNetConnectionService:CollaborationLobbyNetConnectionService)
		{
			_collaborationLobbyNetConnectionService = collaborationLobbyNetConnectionService;
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			_widgetContainers = widgetContainers;
			_fullContainer = fullParentContainer;
			_settings = settings;
//			_healthRecordService = healthRecordService;
//			_collaborationRoomNetConnectionService = collaborationRoomNetConnectionService;
			_componentContainer = componentContainer;

//			_collaborationRoomNetConnectionService.netConnection.client.showFullView = showFullView;

			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}

		protected function get componentContainer():IComponentContainer
		{
			return _componentContainer;
		}

		public function get apps():OrderedMap
		{
			return _apps;
		}

		/**
		 * Creates and starts (shows widgets for) all the apps for CollaboRhythm.Workstation and CollaboRhythm.Tablet.
		 * Apps in the settings.appGroups (if any) are put into corresponding widgetContainers
		 * put in scheduleWidgetParentContainer.
		 * @param activeAccount The account to initialize the apps for.
		 * @param activeRecordAccount The account owning the record to initialize the apps for.
		 */
		public function createAndStartApps(activeAccount:Account, activeRecordAccount:Account):void
		{
			initializeForAccount(activeAccount, activeRecordAccount);

			// TODO: find the groups by id instead of index
			var widgetContainerIndex:uint = 0;
			for each (var widgetContainer:IVisualElementContainer in _widgetContainers)
			{
				_factory.widgetContainer = widgetContainer;
				createAppsForGroup(widgetContainerIndex);
				widgetContainerIndex++;
			}

			if (_appGroups.length > _widgetContainers.length)
			{
				_logger.warn("Warning: a container was not provided for at least one app group specified in settings.xml.");
			}

			initializeApps();
			showAllWidgets();
		}

		public function showWidgetsInNewContainers():void
		{
			if (_appGroups)
			{
				var widgetContainerIndex:uint = 0;
				for each (var appGroup:AppGroup in _appGroups.values())
				{
					var widgetContainer:IVisualElementContainer = _widgetContainers[widgetContainerIndex];
					createWidgetViewsForGroup(appGroup, widgetContainer);
					widgetContainerIndex++;
				}

				if (_appGroups.length > _widgetContainers.length)
				{
					_logger.warn("Warning: a container was not provided for at least one app group specified in settings.xml.");
				}

				showAllWidgets();
			}
		}

		private function createWidgetViewsForGroup(appGroup:AppGroup, widgetContainer:IVisualElementContainer):void
		{
			for each (var app:AppControllerBase in appGroup.apps)
			{
				app.widgetContainer = widgetContainer;
				app.createAndPrepareWidgetView();
			}
		}

		private function initializeApps():void
		{
			var infoArray:Array = componentContainer.resolveAll(AppControllerInfo);

			if (infoArray)
			{
				infoArray = AppControllersSorter.orderAppsByInitializationOrderConstraints(infoArray);
				_appsInitialized = new ArrayCollection();

				_logger.info("Initializing {0} apps", _appsById.length);
				for each (var info:AppControllerInfo in infoArray)
				{
					var app:AppControllerBase = _appsById.getValueByKey(info.appId);
					if (app)
					{
						app.initialize();
						_appsInitialized.addItem(app);
					}
				}
			}
			else
			{
				_logger.warn("No apps to initialize. There were 0 AppControllerInfo instances registered by the plugins.");
			}
		}

		/**
		 * Creates all the apps for CollaboRhythm.Mobile. Apps in the first group in settings.appGroups (if any) are
		 * created and initialized, ready for navigation. If no groups are specified in settings.appGroups, a group
		 * is automatically created from all dynamic apps.
		 * @param user The user to initialize the apps for.
		 */
		public function createMobileApps(activeAccount:Account, activeRecordAccount:Account):void
		{
			initializeForAccount(activeAccount, activeRecordAccount);
			if (_settings.appGroups && _settings.appGroups.length > 0)
				createAppsForGroup(0);
			else
				createDynamicApps();

			initializeApps();
		}

		private function createAppsForGroup(groupIndex:int):void
		{
			// TODO: find another way to load the static app controller classes dynamically
			// the following "force" variables exist only to ensure that subsequent calls to getClassByAlias() will work
			var forceProblems:ProblemsAppController;
			var forceProcedures:ProceduresAppController;
			var forceImmunizations:ImmunizationsAppController;
			var forceAllergies:AllergiesAppController;
			var forceGenetics:GeneticsAppController;
			var forceFamilyHistory:FamilyHistoryAppController;
			var forceSocialHistory:SocialHistoryAppController;
			var forceVitals:VitalsAppController;
			var forceLabs:LabsAppController;
			var forceImaging:ImagingAppController;

			if (_settings.appGroups && _settings.appGroups.length > groupIndex)
			{
				var appGroupDescriptor:AppGroupDescriptor = _settings.appGroups[groupIndex] as AppGroupDescriptor;

				initializeAppGroup(appGroupDescriptor.id);

				_logger.info("Creating {0} apps for group {1}", appGroupDescriptor.appDescriptors.length,
							appGroupDescriptor.id);
				for each (var appDescriptor:String in appGroupDescriptor.appDescriptors)
				{
					var appClass:Class = dynamicAppDictionary.getValueByKey(appDescriptor);

					if (appClass == null)
					{
						try
						{
							appClass = ReflectionUtils.getClassByName(appDescriptor.replace("::", "."));
						}
						catch(e:Error)
						{
							_logger.error("Error attempting to getClassByAlias: " + e.message);
						}
					}

					if (appClass)
						createApp(appClass);
					else
						_logger.error("Failed to get instance of app controller class: " + appDescriptor + " for app group #" + groupIndex + " (" + appGroupDescriptor.id + ")");
				}
			}
		}

		private function showAllWidgets():void
		{
			var app:AppControllerBase;
			for each (app in _apps.values())
			{
				app.showWidget();
			}
		}

		private function initializeAppGroup(appGroupId:String):void
		{
			_currentAppGroup = new AppGroup();
			_currentAppGroup.id = appGroupId;
			_appGroups.addKeyValue(appGroupId, _currentAppGroup);
		}

		private function createDynamicApps():void
		{
			_logger.warn("Warning: no app groups specified in settings; creating standard app group from all dynamic apps");

			initializeAppGroup(STANDARD_APP_GROUP);

			var infoArray:Array = componentContainer.resolveAll(AppControllerInfo);

			infoArray = AppControllersSorter.orderAppsByInitializationOrderConstraints(infoArray);

			_logger.info("Creating {0} dynamic apps", infoArray.length);
			for each (var info:AppControllerInfo in infoArray)
			{
				createApp(info.appControllerClass);
			}
		}

		public function get numDynamicApps():int
		{
			var infoArray:Array = componentContainer.resolveAll(AppControllerInfo);
			return infoArray.length;
		}

		protected function initializeForAccount(activeAccount:Account, activeRecordAccount:Account):void
		{
			closeApps();

			_appGroups = new OrderedMap();
			initializeDynamicAppLookup();
			_apps = new OrderedMap();
			_appsById = new OrderedMap();
			_factory = new AppControllerFactory();
			_factory.fullContainer = _fullContainer;
//			_factory.healthRecordService = _healthRecordService;
//			_factory.collaborationRoomNetConnectionServiceProxy = _collaborationRoomNetConnectionService.createProxy();
			_factory.modality = _settings.modality;
			_factory.activeAccount = activeAccount;
			_factory.activeRecordAccount = activeRecordAccount;
			_factory.settings = _settings;
			_factory.componentContainer = _componentContainer;
			_factory.collaborationLobbyNetConnectionService = _collaborationLobbyNetConnectionService;
		}

		private function initializeDynamicAppLookup():void
		{
			dynamicAppDictionary = new OrderedMap();

			var infoArray:Array = componentContainer.resolveAll(AppControllerInfo);

			for each (var info:AppControllerInfo in infoArray)
			{
				dynamicAppDictionary.addKeyValue(info.appId, info.appControllerClass);
				registerClassAlias(info.appId.replace("::", "."), info.appControllerClass)
			}
		}

		public function reloadUserData():void
		{
			for each (var app:AppControllerBase in _appsInitialized)
			{
				app.reloadUserData();
			}
		}

		public function createApp(appClass:Class, appName:String = null):AppControllerBase
		{
			var app:AppControllerBase = _factory.createApp(appClass, appName);
			if (_currentAppGroup)
				_currentAppGroup.apps.push(app);
			appName = app.name;

			if (appName == null)
				throw new Error("appName must not be null; app controller should override defaultName property");

			app.addEventListener(AppEvent.SHOW_FULL_VIEW, showFullViewHandler);
			_apps.addKeyValue(appName, app);
			_appsById.addKeyValue(app.appId, app);
			return app;
		}

		private function showFullViewHandler(event:AppEvent):void
		{
			var appInstance:AppControllerBase;
			if (event.appController == null)
			{
				// TODO: use constant instead of magic string
				appInstance = showFullView(event.applicationName, "local");
			}
			else
			{
				appInstance = showFullViewResolved(event.appController, "local");
			}

			if (appInstance)
				InteractionLogUtil.logAppInstance(_logger, "Show full view", event.viaMechanism, appInstance);
		}

		public function showFullView(applicationName:String, source:String = "local"):AppControllerBase
		{
			var appController:AppControllerBase = _apps.getValueByKey(applicationName);
			if (appController != null)
				return showFullViewResolved(appController, source);
			else
				return null;
		}

		protected function showFullViewResolved(appController:AppControllerBase, source:String):AppControllerBase
		{
			var appInstance:AppControllerBase;

			// TODO: use app id instead of name
			currentFullView = appController.name;

			for each (var app:AppControllerBase in _apps.values())
			{
				if (app != appController)
					app.hideFullView();
				else
				{
					if (app.showFullView(null))
						appInstance = app;
				}
			}

			for each (var widgetContainer:IVisualElementContainer in _widgetContainers)
			{
				(widgetContainer as UIComponent).validateNow();
			}

//			if (source == "local")
//			{
//				_collaborationRoomNetConnectionService.netConnection.call("showFullView", null, _collaborationRoomNetConnectionService.localUserName, appController.name);
//			}
			return appInstance;
		}

		private function keyDownHandler(event:KeyboardEvent):void
		{
/*
			if (event.keyCode == Keyboard.BACK)
			{
				if (currentFullView)
				{
					event.preventDefault();
					hideFullViews("back key pressed");
				}
			}
*/
		}

		public function hideFullViews(viaMechanism:String):void
		{
			currentFullView = null;

			for each (var app:AppControllerBase in _apps.values())
			{
				if (app.hideFullView())
					InteractionLogUtil.logAppInstance(_logger, "Hide full view", viaMechanism, app);
			}
		}

		public function get currentFullView():String
		{
			return _currentFullView;
		}

		public function set currentFullView(currentFullView:String):void
		{
			_currentFullView = currentFullView;
		}

		public function closeApps():void
		{
			if (_apps != null)
			{
				for each (var app:AppControllerBase in _apps.values())
				{
					app.close();
				}
			}

			_currentFullView = null;
			_currentAppGroup = null;
			_appGroups = null;
		}

		/**
		 * Updates settings.appGroups with AppGroupDescriptor instances based on the AppGroup instances currently in use.
		 */
		public function updateAppGroupSettings():void
		{
			_settings.appGroups = new ArrayCollection();

			if (_appGroups)
			{
				for each (var appGroup:AppGroup in _appGroups.values())
				{
					_settings.appGroups.addItem(new AppGroupDescriptor(appGroup.id,
																	   appGroup.appDescriptors));
				}
			}
		}

		public function get showingFullView():Boolean
		{
			return currentFullView != null;
		}

		public function get widgetContainers():Vector.<IVisualElementContainer>
		{
			return _widgetContainers;
		}

		public function set widgetContainers(value:Vector.<IVisualElementContainer>):void
		{
			_widgetContainers = value;
		}

		protected function get factory():AppControllerFactory
		{
			return _factory;
		}
	}
}
