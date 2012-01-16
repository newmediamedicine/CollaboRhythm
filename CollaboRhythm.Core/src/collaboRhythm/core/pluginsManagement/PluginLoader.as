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
package collaboRhythm.core.pluginsManagement
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.shared.controller.apps.AppControllerInfo;
	import collaboRhythm.shared.model.StringUtils;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.model.settings.Settings;
	import collaboRhythm.shared.pluginsSupport.IPlugin;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;

	import mx.collections.ArrayCollection;
	import mx.core.IFlexModuleFactory;
	import mx.events.ModuleEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.modules.IModuleInfo;
	import mx.modules.ModuleLoader;

	[Event(name="complete", type="flash.events.Event")]
	public class PluginLoader extends EventDispatcher
	{
		private var loadedPlugins:Vector.<IPlugin> = new Vector.<IPlugin>();
		private var moduleLoaders:ArrayCollection = new ArrayCollection();
		private var pendingModuleLoaders:ArrayCollection; // list of loaders which are in the middle of loading
		private var _applicationPluginsDirectoryPath:String;
		private var _userPluginsDirectoryPath:String;
		private var _componentContainer:IComponentContainer;
		private var _moduleApplicationDomain:ApplicationDomain;

		private static const PLUGINS_DIRECTORY_NAME:String = "plugins";
		private static const APPLICATION_STORAGE_DIRECTORY_VARIABLE:String = "$APPLICATION_STORAGE_DIRECTORY$/";
		private static const APPLICATION_DIRECTORY_VARIABLE:String = "$APPLICATION_DIRECTORY$/";

		private var completedModuleLoaders:ArrayCollection;
		protected var _logger:ILogger;
		private var _settings:Settings;

		public function get numPluginsLoaded():int
		{
			return loadedPlugins.length;
		}

		public function PluginLoader(settings:Settings)
		{
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));

			_settings = settings;
			_applicationPluginsDirectoryPath = File.applicationDirectory.resolvePath(PLUGINS_DIRECTORY_NAME).nativePath;
			_userPluginsDirectoryPath = File.applicationStorageDirectory.resolvePath(PLUGINS_DIRECTORY_NAME).nativePath;

			// Use /data/local instead of /data/data because attempting to write to /data/data fails with the error "failed to copy '<source>' to '<dest>': Permission denied"
			// TODO: figure out how to write to the appropriate /data/data directory using "adb push" and avoid using /data/local
			_userPluginsDirectoryPath = _userPluginsDirectoryPath.replace("/data/data", "/data/local");
		}
		
		public function get componentContainer():IComponentContainer
		{
			return _componentContainer;
		}

		public function set componentContainer(value:IComponentContainer):void
		{
			_componentContainer = value;
		}

		public function get userPluginsDirectoryPath():String
		{
			return _userPluginsDirectoryPath;
		}

		public function get applicationPluginsDirectoryPath():String
		{
			return _applicationPluginsDirectoryPath;
		}

		public function loadPlugins():void
		{
			var pluginSearchFiles:Array = getPluginSearchFiles();
			_logger.info("Preparing to load plugins from the following directories/files: \n" + fileArrayToStringForTrace(pluginSearchFiles));
			var files:Array = findPluginFiles(pluginSearchFiles);
			
			var pluginFilesMessage:String =
				"Loading plugin files:\n" +
				fileArrayToStringForTrace(files);
			_logger.info(pluginFilesMessage);

			loadedPlugins = new Vector.<IPlugin>(files.length);
			pendingModuleLoaders = new ArrayCollection();
			completedModuleLoaders = new ArrayCollection();
			_moduleApplicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);

			for each (var file:File in files)
			{
				loadPlugin(file);
			}
		}

		private function findPluginFiles(pluginSearchFiles:Array):Array
		{
			var files:Array = new Array();
			var fileNames:ArrayCollection = new ArrayCollection();

			for each (var pluginSearchFile:File in pluginSearchFiles)
			{
				if (pluginSearchFile.exists)
				{
					if (pluginSearchFile.isDirectory)
					{
						var directoryListing:Array = pluginSearchFile.getDirectoryListing();
						// TODO: remove (or recursively load) directories from the list
						// TODO: remove Array.DESCENDING, this is a hack for ordering loading
						directoryListing.sortOn("url", Array.DESCENDING);

						for each (var file:File in directoryListing)
						{
							var fileName:String = file.name;
							if (file.exists && !file.isDirectory && !fileNames.contains(fileName) && isPluginFile(file))
							{
								files.push(file);
								fileNames.addItem(fileName);
							}
						}
					}
					else
					{
						fileName = pluginSearchFile.name;
						if (!fileNames.contains(fileName))
						{
							files.push(pluginSearchFile);
							fileNames.addItem(fileName);
						}
					}
				}
			}
			return files;
		}

		private function getPluginSearchFiles():Array
		{
			var searchFiles:Array = new Array();
			for each (var pluginSearchPath:String in _settings.pluginSearchPaths)
			{

				var pluginSearchFile:File = resolvePluginSearchPath(pluginSearchPath);
				if (pluginSearchFile)
				{
					searchFiles.push(pluginSearchFile);
				}
			}
			return searchFiles;
		}

		private function resolvePluginSearchPath(pluginSearchPath:String):File
		{
			var pluginSearchPathResolved:String = null;
			var startDirectory:File;
			var subPath:String;
			var pluginSearchFile:File;

			if (pluginSearchPath.indexOf(APPLICATION_STORAGE_DIRECTORY_VARIABLE) == 0)
			{
				startDirectory = File.applicationStorageDirectory;
				subPath = pluginSearchPath.substring(APPLICATION_STORAGE_DIRECTORY_VARIABLE.length);
			}
			else if (pluginSearchPath.indexOf(APPLICATION_DIRECTORY_VARIABLE) == 0)
			{
				startDirectory = File.applicationDirectory;
				subPath = pluginSearchPath.substring(APPLICATION_DIRECTORY_VARIABLE.length);
			}
			else
			{
				pluginSearchPathResolved = pluginSearchPath;
				pluginSearchFile = new File(pluginSearchPathResolved);
			}

			if (pluginSearchFile == null)
			{
				var currentFile:File = startDirectory;
				var subPathParts:Array = subPath.split("/");
				for each (var subPathPart:String in subPathParts)
				{
					if (subPathPart == "..")
					{
						// Note that we don't just use currentFile.parent because if we are using the app: or
						// appStorage: URL scheme then .parent may return null
						if (StringUtils.isEmpty(currentFile.nativePath))
						{
							// This is expected if a path such as $APPLICATION_DIRECTORY$/../ is used
							_logger.warn("Failed to resolve plugin search path: " + pluginSearchPath);
							currentFile = null;
							break;
						}
						else
						{
							currentFile = new File(currentFile.nativePath).parent;
						}
					}
					else
					{
						currentFile = currentFile.resolvePath(subPathPart);
					}
				}

				pluginSearchFile = currentFile;
			}

			return pluginSearchFile;
		}

		private static function isPluginFile(file:File):Boolean
		{
			// TODO: come up with a more robust way to exclude non-module swf files or added error handling that will catch these
			return file.extension && file.extension.toLowerCase() == "swf" && file.name.toLowerCase().indexOf("pluginmodule") != -1;
		}
		
		private static function fileArrayToStringForTrace(array:Array):String
		{
			var result:String = "";
			for each (var file:File in array)
			{
				result += "  " + (StringUtils.isEmpty(file.nativePath) ? file.url : file.nativePath) + "\n";
			}
			return result;
		}

		private function loadPlugin(file:File):void
		{
			var moduleLoader:ModuleLoader = new ModuleLoader();
			moduleLoader.addEventListener(ModuleEvent.READY, moduleLoader_readyHandler);
			moduleLoader.addEventListener(ModuleEvent.ERROR, moduleLoader_errorHandler);

			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			var moduleBytes:ByteArray = new ByteArray();
			stream.readBytes(moduleBytes);
			stream.close();
			
			moduleLoaders.addItem(moduleLoader);
			pendingModuleLoaders.addItem(moduleLoader);
			// TODO: determine if this is the best approach for resolving the application domain issue; perhaps use a
			// new child domain for all modules, or selectively include modules in the appropriate domains based on what
			// the plugin specifies that it needs to inter-operate with.
			// The problem is that, if two different plugins create instances of the same class from a shared library, 
			// but there is no instance of that class in the shared library, then they will each have their own version
			// of that class.
			// Changing the application domain from the child domain to the current domain resolves this problem because
			// all of the modules are in the same domain.
			// http://livedocs.adobe.com/flex/3/html/help.html?content=modular_2.html
			moduleLoader.applicationDomain = _moduleApplicationDomain;
			moduleLoader.loadModule(file.url, moduleBytes);
		}
		
		protected function moduleLoader_readyHandler(event:ModuleEvent):void
		{
			var moduleInfo:IModuleInfo = event.module;

			var flexModuleFactory:IFlexModuleFactory = moduleInfo.factory;
			var moduleLoader:ModuleLoader = getModuleLoader(event);
			completedModuleLoaders.addItem(moduleLoader);

			var plugin:IPlugin = flexModuleFactory.create() as IPlugin;
			if (plugin)
			{
				var loaderIndex:int = moduleLoaders.getItemIndex(moduleLoader);
				if (loaderIndex == -1)
					throw new Error("loader not found in moduleLoaders");

				loadedPlugins[loaderIndex] = plugin;

				_logger.info("Plugin " + getQualifiedClassName(plugin) + " loaded successfully from " + moduleInfo.url);

				// Note that we do not register components yet; wait and register components for each plugin in the same
				// order that the plugins were read from file
			}
			else
			{
				_logger.warn("Failed to create a module from " + moduleInfo.url + " or module is not an instance of " + ReflectionUtils.getClassInfo(IPlugin).name);

				// TODO: handle failed plugin loading gracefully
			}

			finishWithModuleLoader(moduleLoader);
		}

		private function getModuleLoader(event:ModuleEvent):ModuleLoader
		{
			var moduleLoader:ModuleLoader = event.target as ModuleLoader;
			if (!moduleLoader)
				throw new Error("event.target was not a ModuleLoader");
			return moduleLoader;
		}

		private function finishWithModuleLoader(moduleLoader:ModuleLoader):void
		{
			var pendingLoaderIndex:int = pendingModuleLoaders.getItemIndex(moduleLoader);
			if (pendingLoaderIndex == -1)
			{
				var message:String = "Error: module loader " + moduleLoader.url + " not found in pendingModuleLoaders.";
				_logger.error(message);
				throw new Error(message);
			}

			pendingModuleLoaders.removeItemAt(pendingLoaderIndex);

			if (pendingModuleLoaders.length == 0)
			{
				registerComponents();
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}

		private function registerComponents():void
		{
			loadedPlugins = removeNullItems(loadedPlugins);

			// Note that loadedPlugins should have the same order as moduleLoaders, so we should be registering
			// components in the same order that the plugins were read from file
			for each (var plugin:IPlugin in loadedPlugins)
			{
				plugin.registerComponents(componentContainer);
			}

			_logger.info("Registered all components. Num AppControllerInfo: " + componentContainer.resolveAll(AppControllerInfo).length);
		}

		private function removeNullItems(plugins:Vector.<IPlugin>):Vector.<IPlugin>
		{
			var filteredPlugins:Vector.<IPlugin> = new Vector.<IPlugin>();

			for each (var plugin:IPlugin in plugins)
			{
				if (plugin != null)
					filteredPlugins.push(plugin);
			}

			return filteredPlugins;
		}
		
		protected function moduleLoader_errorHandler(event:ModuleEvent):void
		{
			var moduleLoader:ModuleLoader = getModuleLoader(event);

			// First, check if this is an expected error from attempting to create a DisplayObject from the module and
			// add it as a child of the ModuleLoader (which is expected to fail). We assume this is an expected error
			// if the corresponding moduleLoader has been added to completedModuleLoaders.
			if (event.bytesLoaded == event.bytesTotal && event.module != null && completedModuleLoaders.contains(moduleLoader))
			{
				// expected error; just ignore it
				return;
			}

			trace(event.errorText);
			_logger.error("Error loading module " + moduleLoader.url + " " + event.errorText);

			// TODO: update pendingModuleLoaders as in moduleLoader_readyHandler
			finishWithModuleLoader(moduleLoader);
		}
		
		public function unloadPlugins():void
		{
			for each (var moduleLoader:ModuleLoader in moduleLoaders)
			{
				moduleLoader.unloadModule();
			}
//			_moduleApplicationDomain.domainMemory.clear();
			moduleLoaders = new ArrayCollection();
			loadedPlugins = new Vector.<IPlugin>();
			pendingModuleLoaders = null;
			completedModuleLoaders = null;
		}

		public function getNumPluginFiles():int
		{
			var files:Array = findPluginFiles(getPluginSearchFiles());
			return files.length;
		}
	}
}
