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

    import collaboRhythm.shared.model.Account;
    import collaboRhythm.shared.model.CollaborationRoomNetConnectionServiceProxy;
    import collaboRhythm.shared.model.User;
    import collaboRhythm.shared.model.services.IComponentContainer;
    import collaboRhythm.shared.model.settings.Settings;

    import mx.core.IVisualElementContainer;

    /**
	 * Creates workstation apps and prepares them for use in a parent container.
	 * 
	 */
	public class WorkstationAppControllerFactory
	{
		private var _widgetParentContainer:IVisualElementContainer;
		private var _fullParentContainer:IVisualElementContainer;
//		private var _healthRecordService:CommonHealthRecordService;
		private var _user:User;
		private var _collaborationRoomNetConnectionServiceProxy:CollaborationRoomNetConnectionServiceProxy;
		private var _isWorkstationMode:Boolean;
        private var _activeAccount:Account;
        private var _activeRecordAccount:Account;
        private var _settings:Settings;
        private var _componentContainer:IComponentContainer;

		public function WorkstationAppControllerFactory()
		{
		}

		public function get widgetParentContainer():IVisualElementContainer
		{
			return _widgetParentContainer;
		}

		public function set widgetParentContainer(value:IVisualElementContainer):void
		{
			_widgetParentContainer = value;
		}

		public function get fullParentContainer():IVisualElementContainer
		{
			return _fullParentContainer;
		}

		public function set fullParentContainer(value:IVisualElementContainer):void
		{
			_fullParentContainer = value;
		}

//		public function get healthRecordService():CommonHealthRecordService
//		{
//			return _healthRecordService;
//		}

//		public function set healthRecordService(value:CommonHealthRecordService):void
//		{
//			_healthRecordService = value;
//		}

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

		public function get isWorkstationMode():Boolean
		{
			return _isWorkstationMode;
		}

		public function set isWorkstationMode(value:Boolean):void
		{
			_isWorkstationMode = value;
		}

		public function createApp(appClass:Class, appName:String=null):WorkstationAppControllerBase
		{
			var constructorParams:AppControllerConstructorParams = new AppControllerConstructorParams();
			constructorParams.widgetParentContainer = _widgetParentContainer;
			constructorParams.fullParentContainer = _fullParentContainer;
			constructorParams.isWorkstationMode = _isWorkstationMode;
            constructorParams.activeAccount = _activeAccount;
            constructorParams.activeRecordAccount = _activeRecordAccount;
            constructorParams.settings = _settings;
            constructorParams.componentContainer = _componentContainer;

			var appObject:Object = new appClass(constructorParams);
			if (appObject == null)
				throw new Error("Unable to create instance of app: " + appClass);
			
			var app:WorkstationAppControllerBase = appObject as WorkstationAppControllerBase;

			if (appName != null)
				app.name = appName;
			
//			app.healthRecordService = _healthRecordService;
			app.user = _user;
			app.collaborationRoomNetConnectionServiceProxy = _collaborationRoomNetConnectionServiceProxy;
			app.initialize();
			
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
    }
}