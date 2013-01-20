package collaboRhythm.shared.pluginsDeployment
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;

	public class PluginsDeployUtil
	{
		private static const SETTINGS_FILE_NAME:String = "settings.xml";
		private static const ANDROID_CAPABILITIES_VERSION_PREFIX:String = "AND";
		private static const COLLABO_RHYTHM_TABLET_DATA_DIRECTORY_NAME:String = "CollaboRhythm.Tablet.debug";
		private static const EXTERNAL_PLUGINS_DIRECTORY_NAME:String = "external_plugins";
		private static const collaboRhythmLocalStorePath:String = "/data/local/air.CollaboRhythm.Tablet.debug/CollaboRhythm.Tablet.debug/Local Store";
		private static const collaboRhythmLocalStorePathEmulator:String = "CollaboRhythm.Tablet.debug/Local Store";

		public function PluginsDeployUtil()
		{
		}

		private static function readXmlFile(sourceFile:File):XML
		{
			var xml:XML;
			if (sourceFile.exists)
			{
				var stream:FileStream = new FileStream();
				stream.open(sourceFile, FileMode.READ);
				XML.ignoreComments = false;
				XML.ignoreWhitespace = false;
				XML.prettyPrinting = false;
				var fileString:String = stream.readUTFBytes(stream.bytesAvailable);
				xml = new XML(fileString);
				stream.close();
			}
			return xml;
		}

		private static function saveXmlFile(xml:XML, file:File):Boolean
		{
			var outputStringHeader:String = '<?xml version="1.0" encoding="utf-8"?>' + File.lineEnding;
			var outputString:String = xml.toXMLString();
			outputString = outputStringHeader + outputString;
			var stream:FileStream = new FileStream();
			var openSucceeded:Boolean = false;
			try
			{
				stream.open(file, FileMode.WRITE);
				openSucceeded = true;
			} catch (e:Error)
			{
				var message:String = "Failed to write file: " + file.nativePath;
//				logger.error(message);
//				Alert.show(message, "Failed to Save");
				throw new Error(message);
			}

			if (openSucceeded)
			{
				stream.writeUTFBytes(outputString);
			}
			stream.close();
			return openSucceeded;
		}

		public static function enablePlugin(resetPluginSearchPaths:Boolean, resetAppGroups:Boolean,
											pluginFileName:String, pluginName:String, pluginAppDescriptor:String = null,
											appGroupId:String = "buttonWidgets"):Boolean
		{
			trace("Capabilities.playerType", Capabilities.playerType);
			trace("Capabilities.isDebugger", Capabilities.isDebugger);
			trace("Capabilities.os", Capabilities.os);
			trace("Capabilities.version", Capabilities.version);

			var isAndroid:Boolean = Capabilities.version.substr(0, 3) == ANDROID_CAPABILITIES_VERSION_PREFIX;
			var collaboRhythmStorageDirectory:File = isAndroid ?
					new File(collaboRhythmLocalStorePath) :
					new File(File.applicationStorageDirectory.nativePath).parent.parent.resolvePath(collaboRhythmLocalStorePathEmulator);
			var settingsFile:File = collaboRhythmStorageDirectory.resolvePath(SETTINGS_FILE_NAME);
			var defaultSettingsFile:File = File.applicationDirectory.resolvePath(SETTINGS_FILE_NAME);
			var saveSucceeded:Boolean = false;

			if (collaboRhythmStorageDirectory.exists)
			{
				if (settingsFile.exists)
				{
					default xml namespace = "http://collaborhythm.org/application/settings";
					var settingsXml:XML = readXmlFile(settingsFile);
					var defaultSettingsXml:XML = readXmlFile(defaultSettingsFile);
					if (settingsXml.localName().toString() == "settings")
					{
						if (resetPluginSearchPaths) // && (settingsXml.pluginSearchPaths as XMLList).length() != 0)
						{
							delete settingsXml.pluginSearchPaths[0];
						}

						// make sure that the settings includes pluginSearchPaths; if it does not, inject the default
						if ((settingsXml.pluginSearchPaths as XMLList).length() == 0)
						{
							settingsXml.appendChild(defaultSettingsXml.pluginSearchPaths);
						}

						var pluginFilePath:String;
						if (isAndroid)
						{
//							var mobilePluginDirectory:File = collaboRhythmStorageDirectory.resolvePath("external_plugins");
							var mobilePluginDirectory:File = File.desktopDirectory.resolvePath(COLLABO_RHYTHM_TABLET_DATA_DIRECTORY_NAME).resolvePath(EXTERNAL_PLUGINS_DIRECTORY_NAME);
							if (!mobilePluginDirectory.exists)
							{
								mobilePluginDirectory.createDirectory();
							}

							var pluginDestinationFile:File = mobilePluginDirectory.resolvePath(pluginFileName);
							File.applicationDirectory.resolvePath(pluginFileName).copyTo(pluginDestinationFile, true);
							pluginFilePath = pluginDestinationFile.url;
						}
						else
						{
							pluginFilePath = new File(File.applicationDirectory.nativePath).parent.resolvePath(pluginName).resolvePath(pluginFileName).nativePath;
						}
						if (!(settingsXml.pluginSearchPaths.pluginSearchPath as XMLList).contains(pluginFilePath))
						{
							(settingsXml.pluginSearchPaths as
									XMLList).appendChild(<pluginSearchPath>{pluginFilePath}</pluginSearchPath>);
						}

						if (resetAppGroups) // && (settingsXml.appGroups as XMLList).length() != 0)
						{
							delete settingsXml.appGroups[0];
						}

						if (pluginAppDescriptor != null)
						{
							// make sure that the settings includes appGroups; if it does not, inject the default
							if ((settingsXml.appGroups as XMLList).length() == 0)
							{
								settingsXml.appendChild(defaultSettingsXml.appGroups);
							}

							var appDescriptors:XMLList = settingsXml.appGroups.appGroup.(@id ==
									appGroupId).appDescriptors;
							if (!(appDescriptors.appDescriptor as XMLList).contains(pluginAppDescriptor))
							{
								appDescriptors.appendChild(<appDescriptor>{pluginAppDescriptor}</appDescriptor>);
							}
						}

						saveSucceeded = saveXmlFile(settingsXml, settingsFile);
					}
				}
			}

			return saveSucceeded;
		}
	}
}
