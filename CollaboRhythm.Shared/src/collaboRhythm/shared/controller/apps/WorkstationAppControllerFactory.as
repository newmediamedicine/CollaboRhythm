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
package collaboRhythm.shared.controller.apps
{

	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.CollaborationLobbyNetConnectionService;
	import collaboRhythm.shared.model.CollaborationRoomNetConnectionServiceProxy;
    import collaboRhythm.shared.model.User;
    import collaboRhythm.shared.model.services.IComponentContainer;
    import collaboRhythm.shared.model.settings.Settings;

	import flash.utils.getQualifiedClassName;

	import mx.core.IVisualElementContainer;
	import mx.logging.ILogger;
	import mx.logging.Log;

	import spark.components.ViewNavigator;

	/**
	 * Creates workstation apps and prepares them for use in a parent container.
	 * 
	 */
	public class WorkstationAppControllerFactory
	{
		private var _widgetContainer:IVisualElementContainer;
		private var _fullContainer:IVisualElementContainer;
		private var _user:User;
		private var _collaborationRoomNetConnectionServiceProxy:CollaborationRoomNetConnectionServiceProxy;
		private var _modality:String;
        private var _activeAccount:Account;
        private var _activeRecordAccount:Account;
        private var _settings:Settings;
        private var _componentContainer:IComponentContainer;
		private var _collaborationLobbyNetConnectionService:CollaborationLobbyNetConnectionService;
		private var _viewNavigator:ViewNavigator;
		protected var logger:ILogger;


		public function WorkstationAppControllerFactory()
		{
			logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
		}

		public function get widgetContainer():IVisualElementContainer
		{
			return _widgetContainer;
		}

		public function set widgetContainer(value:IVisualElementContainer):void
		{
			_widgetContainer = value;
		}

		public function get fullContainer():IVisualElementContainer
		{
			return _fullContainer;
		}

		public function set fullContainer(value:IVisualElementContainer):void
		{
			_fullContainer = value;
		}

		public function get user():User
		{
			return _user;
		}

		public function set user(value:User):void
		{
			_user = value;
		}
		
		public function get collaborationRoomNetConnectionServiceProxy():CollaborationRoomNetConnectionServiceProxy
		{
			return _collaborationRoomNetConnectionServiceProxy;
		}
		
		public function set collaborationRoomNetConnectionServiceProxy(value:CollaborationRoomNetConnectionServiceProxy):void
		{
			_collaborationRoomNetConnectionServiceProxy = value;
		}

		public function get modality():String
		{
			return _modality;
		}

		public function set modality(value:String):void
		{
			_modality = value;
		}

		public function createApp(appClass:Class, appName:String=null):WorkstationAppControllerBase
		{
			var constructorParams:AppControllerConstructorParams = new AppControllerConstructorParams();
			constructorParams.widgetContainer = _widgetContainer;
			constructorParams.fullContainer = _fullContainer;
			constructorParams.modality = _modality;
            constructorParams.activeAccount = _activeAccount;
            constructorParams.activeRecordAccount = _activeRecordAccount;
            constructorParams.settings = _settings;
            constructorParams.componentContainer = _componentContainer;
			constructorParams.collaborationLobbyNetConnectionService = _collaborationLobbyNetConnectionService;
			constructorParams.viewNavigator = _viewNavigator;

			var appObject:Object = new appClass(constructorParams);
			if (appObject == null)
				throw new Error("Unable to create instance of app: " + appClass);
			
			var app:WorkstationAppControllerBase = appObject as WorkstationAppControllerBase;

			if (appName != null)
				app.name = appName;
			
			app.user = _user;
			app.collaborationRoomNetConnectionServiceProxy = _collaborationRoomNetConnectionServiceProxy;

			logger.info("  App created: " + ReflectionUtils.getClassInfo(appClass).name);
			return app;
		}

        public function get activeAccount():Account {
            return _activeAccount;
        }

        public function set activeAccount(value:Account):void {
            _activeAccount = value;
        }

        public function get settings():Settings
        {
            return _settings;
        }

        public function set settings(value:Settings):void
        {
            _settings = value;
        }

        public function get activeRecordAccount():Account
        {
            return _activeRecordAccount;
        }

        public function set activeRecordAccount(value:Account):void
        {
            _activeRecordAccount = value;
        }

        public function get componentContainer():IComponentContainer
        {
            return _componentContainer;
        }

        public function set componentContainer(value:IComponentContainer):void
        {
            _componentContainer = value;
        }

		public function get collaborationLobbyNetConnectionService():CollaborationLobbyNetConnectionService
		{
			return _collaborationLobbyNetConnectionService;
		}

		public function set collaborationLobbyNetConnectionService(value:CollaborationLobbyNetConnectionService):void
		{
			_collaborationLobbyNetConnectionService = value;
		}

		public function get viewNavigator():ViewNavigator
		{
			return _viewNavigator;
		}

		public function set viewNavigator(value:ViewNavigator):void
		{
			_viewNavigator = value;
		}
	}
}