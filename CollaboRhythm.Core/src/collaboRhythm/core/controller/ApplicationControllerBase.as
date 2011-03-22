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
	import collaboRhythm.shared.controller.apps.AppControllerInfo;
	import collaboRhythm.shared.model.Settings;
	import collaboRhythm.shared.model.User;
	import collaboRhythm.shared.model.services.DemoCurrentDateSource;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;
	import collaboRhythm.shared.pluginsSupport.IComponentContainer;
	import collaboRhythm.shared.view.CollaborationRoomView;
	import collaboRhythm.shared.view.RecordVideoView;
	
	import com.daveoncode.logging.LogFileTarget;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.getQualifiedClassName;
	
	import mx.core.IVisualElementContainer;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;

	public class ApplicationControllerBase
	{
		protected var _kernel:IKernel;
		protected var _settings:Settings;
		protected var _collaborationMediator:CollaborationMediatorBase;
		protected var logger:ILogger;
		protected var _componentContainer:IComponentContainer;
		protected var _pluginLoader:PluginLoader;
		
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

		protected function initLogging():void
		{
			// The log file will be placed under applicationStorageDirectory folder
			var path:String = File.applicationStorageDirectory.resolvePath("collaboRhythm.log").nativePath;

			var targetFile:File = new File(path);
			
			/* Create a target. */
			//			var logTarget:TraceTarget = new TraceTarget();
			
			// get LogFileTarget's instance (LogFileTarget is a singleton)
			var logTarget:LogFileTarget = LogFileTarget.getInstance();
			
			logTarget.file = targetFile;
			//			logTarget.file = new File("C:\\Users\\sgilroy\\AppData\\Roaming\\collaboRhythm.workstation\\Local Store\\collaboRhythm.log");
			
			// optional (default to "MM/DD/YY")
			//			target.dateFormat = "DD/MM/YY";
			
			// optional  (default to 1024)
			//			target.sizeLimit = 2048;
			
			// Trace all (default Flex's framework features)
			//			target.filters = ["*"];
			//			target.level = LogEventLevel.ALL;
			
			/* Log only messages for the classes in the collaboRhythm.workstation.* packages. */
//			logTarget.filters=["collaboRhythm.workstation.*"];
			
			/* Log all log levels. */
			logTarget.level = LogEventLevel.ALL;
			
			/* Add date, time, category, and log level to the output. */
			//			logTarget.includeDate = true;
			//			logTarget.includeTime = true;
			//			logTarget.includeCategory = true;
			//			logTarget.includeLevel = true;
			
			/* Begin logging. */
			Log.addTarget(logTarget);
			
			logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
		}
		
		protected function testLogging():void
		{
			logger.info("Testing logger");
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
		
		protected function initializeComponents():void
		{
			_kernel = WorkstationKernel.instance;
			
			//			_kernel.registerComponentInstance("CurrentDateSource", ICurrentDateSource, new DefaultCurrentDateSource());
			var dateSource:DemoCurrentDateSource = new DemoCurrentDateSource();
			dateSource.targetDate = _settings.targetDate;
			_kernel.registerComponentInstance("CurrentDateSource", ICurrentDateSource, dateSource);
			
			_componentContainer = new DefaultComponentContainer();
			_pluginLoader = new PluginLoader();
			_pluginLoader.addEventListener(Event.COMPLETE, pluginLoader_complete);
			_pluginLoader.componentContainer = componentContainer;
			_pluginLoader.loadPlugins();
		}
		
		public function reloadPlugins():void
		{
			_reloadWithUser = _collaborationMediator.subjectUser;
			
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
		}
	}
}