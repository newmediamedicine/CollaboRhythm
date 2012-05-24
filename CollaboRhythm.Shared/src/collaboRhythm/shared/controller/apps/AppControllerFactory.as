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
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.model.settings.Settings;

	import flash.utils.getQualifiedClassName;

	import mx.core.IVisualElementContainer;
	import mx.logging.ILogger;
	import mx.logging.Log;

	import spark.components.ViewNavigator;

	/**
	 * Creates apps and prepares them for use in a parent container.
	 * 
	 */
	public class AppControllerFactory
	{
		private var _widgetContainer:IVisualElementContainer;
		private var _fullContainer:IVisualElementContainer;
		private var _componentContainer:IComponentContainer;
		private var _modality:String;
		private var _activeAccount:Account;
		private var _activeRecordAccount:Account;
		private var _settings:Settings;
		private var _appControllerConstructorParams:AppControllerConstructorParams;
		private var _viewNavigator:ViewNavigator;
		protected var logger:ILogger;


		public function AppControllerFactory()
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

		public function get modality():String
		{
			return _modality;
		}

		public function set modality(value:String):void
		{
			_modality = value;
		}

		public function createApp(appClass:Class, appName:String=null):AppControllerBase
		{
			_appControllerConstructorParams.widgetContainer = _widgetContainer;
			_appControllerConstructorParams.fullContainer = _fullContainer;
			_appControllerConstructorParams.componentContainer = _componentContainer;
			_appControllerConstructorParams.modality = _modality;
			_appControllerConstructorParams.activeAccount = _activeAccount;
			_appControllerConstructorParams.activeRecordAccount = _activeRecordAccount;
			_appControllerConstructorParams.settings = _settings;
			_appControllerConstructorParams.viewNavigator = _viewNavigator;

			var appObject:Object = new appClass(_appControllerConstructorParams);
			if (appObject == null)
				throw new Error("Unable to create instance of app: " + appClass);
			
			var app:AppControllerBase = appObject as AppControllerBase;

			if (appName != null)
				app.name = appName;

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

		public function get viewNavigator():ViewNavigator
		{
			return _viewNavigator;
		}

		public function set viewNavigator(value:ViewNavigator):void
		{
			_viewNavigator = value;
		}

		public function get appControllerConstructorParams():AppControllerConstructorParams
		{
			return _appControllerConstructorParams;
		}

		public function set appControllerConstructorParams(value:AppControllerConstructorParams):void
		{
			_appControllerConstructorParams = value;
		}
	}
}