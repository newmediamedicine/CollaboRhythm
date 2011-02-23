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
	import collaboRhythm.shared.model.CollaborationRoomNetConnectionServiceProxy;
	import collaboRhythm.shared.model.CommonHealthRecordService;
	import collaboRhythm.shared.model.User;
	
	import flash.net.getClassByAlias;
	
	import mx.core.IVisualElementContainer;
	
	import org.indivo.client.Pha;

	/**
	 * Creates workstation apps and prepares them for use in a parent container.
	 * 
	 */
	public class WorkstationAppControllerFactory
	{
		private var _widgetParentContainer:IVisualElementContainer;
		private var _fullParentContainer:IVisualElementContainer;
		private var _healthRecordService:CommonHealthRecordService;
		private var _user:User;
		private var _collaborationRoomNetConnectionServiceProxy:CollaborationRoomNetConnectionServiceProxy;
		
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

		public function get healthRecordService():CommonHealthRecordService
		{
			return _healthRecordService;
		}

		public function set healthRecordService(value:CommonHealthRecordService):void
		{
			_healthRecordService = value;
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

		public function createApp(appClass:Class, appName:String=null):WorkstationAppControllerBase
		{
			// TODO:
//			var appClass:Class = getClassByAlias(appType);
//			if (appClass == null)
//				throw new Error("Unable to get class for app: " + appType);
			
			// TODO: eliminate constructor parameters and just use properties instead to make it easier to implement/maintain sub-classes of WorkstationAppController
			var appObject:Object = new appClass(_widgetParentContainer, _fullParentContainer);
			if (appObject == null)
				throw new Error("Unable to create instance of app: " + appClass);
			
			var app:WorkstationAppControllerBase = appObject as WorkstationAppControllerBase; 
			
			if (appName != null)
				app.name = appName;
			
			app.healthRecordService = _healthRecordService;
			app.user = _user;
			app.collaborationRoomNetConnectionServiceProxy = _collaborationRoomNetConnectionServiceProxy;
			app.initialize();
			
			return app;
		}
	}
}