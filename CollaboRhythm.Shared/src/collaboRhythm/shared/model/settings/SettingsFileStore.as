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
package collaboRhythm.shared.model.settings
{

    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;
    import flash.utils.getQualifiedClassName;

    import mx.logging.ILogger;
    import mx.logging.Log;
    import mx.rpc.xml.Schema;
    import mx.rpc.xml.SchemaManager;
    import mx.rpc.xml.SchemaTypeRegistry;
    import mx.rpc.xml.XMLDecoder;
    import mx.rpc.xml.XMLEncoder;
    import mx.utils.ObjectUtil;

    public class SettingsFileStore
	{
		private const SETTINGS_FILE_NAME:String = "settings.xml";

		[Embed("/resources/settings.xsd", mimeType="application/octet-stream")]
		private var settingsSchema:Class;

        private var _applicationSettingsEmbeddedFile:Class;

        private var schema:Schema;

		private var schemaManager:SchemaManager;
        private var _settings:Settings;
        private var traceXmlEncodeDecode:Boolean = false;
        protected var logger:ILogger;
        private var _isApplicationSettingsLoaded:Boolean;
        private var _isUserSettingsLoaded:Boolean;

		public function SettingsFileStore()
		{
			logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			loadSchema();
		}

		private function loadSchema():void
		{
			var byteArray:ByteArray = new settingsSchema;
			if (byteArray.length == 0)
				byteArray = new settingsSchema();
			
			if (byteArray.length == 0)
				throw new Error("Failed to load embedded settings.xsd schema.");
				
			schema = new Schema(new XML(byteArray.readUTFBytes(byteArray.length)));

			schemaManager = new SchemaManager();
			schemaManager.addSchema(schema);

			var schemaTypeRegistry:SchemaTypeRegistry;
			schemaTypeRegistry = SchemaTypeRegistry.getInstance();
			schemaTypeRegistry.registerClass(getSettingsQName(), Settings);
			schemaTypeRegistry.registerClass(getAppGroupQName(), AppGroupDescriptor);
		}

		private function getSettingsQName():QName
		{
			return new QName(schema.targetNamespace.uri, "settings");
		}

		private function getAppGroupQName():QName
		{
			return new QName(schema.targetNamespace.uri, "appGroup");
		}

		public function readSettings():void
        {
            _isApplicationSettingsLoaded = readSettingsFromEmbeddedFile(applicationSettingsEmbeddedFile);

            _isUserSettingsLoaded = readSettingsFromFile(userSettingsFile);
        }

		public function get userSettingsFile():File
		{
			// Use /data/local instead of /data/data because attempting to write to /data/data fails with the error "failed to copy '<source>' to '<dest>': Permission denied"
			// TODO: figure out how to write to the appropriate /data/data directory using "adb push" and avoid using /data/local
			var nativePath:String = File.applicationStorageDirectory.resolvePath(SETTINGS_FILE_NAME).nativePath;
			nativePath = nativePath.replace("/data/data", "/data/local");
			return new File(nativePath);
		}

        private function readSettingsFromFile(file:File):Boolean
		{
			if (!file.exists)
				return false;

			var fileStream:FileStream = new FileStream();

			try
			{
				fileStream.open(file, FileMode.READ);
			}
			catch (error:Error)
			{
				trace("File exists but could not be read: ", file.nativePath);
				return false;
			}

			var preferencesXML:XML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
			fileStream.close();
			return decodeXML("Settings file \"" + file.nativePath + "\"", preferencesXML);
		}

		private function readSettingsFromEmbeddedFile(embeddedFile:Class):Boolean
		{
			if (!embeddedFile)
				throw new Error("Failed to load embedded file");

            // TODO: determine why this does not work properly in FlashBuilder
			var byteArray:ByteArray = new embeddedFile;
			if (byteArray.length == 0)
				byteArray = new embeddedFile();

			if (byteArray.length == 0)
				throw new Error("Failed to load embedded settings.xml file.");

			var preferencesXML:XML = XML(byteArray.readUTFBytes(byteArray.length));
			return decodeXML("Embedded (application level) settings.xml file", preferencesXML);
		}

		/**
		 * Decodes XML into ActionScript objects using the schema definitions within SchemaManager
		 */
		private function decodeXML(fileSourceDescription:String, xml:XML):Boolean
		{
			if (traceXmlEncodeDecode)
				trace("decodeXML()");

			// make sure the XML has the expected namespace uri
			if (xml.namespaceDeclarations().length == 0 ||
					xml.namespace("").uri != schema.namespaces[""].uri)
			{
				var message:String = "Warning: all settings will be ignored. " + fileSourceDescription + " must be updated to include expected namespace: " + schema.namespaces[""].uri;
				trace(message);
				logger.warn(message);
				// TODO: figure out how to add the namespace so the settings.xml will load; the following seems to have no effect
//				xml = xml.addNamespace(schema.namespaces[""]);

                return false;
			}

			var qName:QName;
			var xmlDecoder:XmlDecoderEx;

			qName = getSettingsQName();

			xmlDecoder = new XmlDecoderEx();
			xmlDecoder.schemaManager = schemaManager;
			xmlDecoder.makeObjectsBindable = true;

			if (!settings)
			{
				var result:*;
				result = xmlDecoder.decode(xml, qName, qName);
				settings = result as Settings;
			}
			else
			{
				xmlDecoder.decodeType(qName, settings, qName, xml);
			}

			if (traceXmlEncodeDecode)
				trace(ObjectUtil.toString(settings));

            return true;
		}

		public function encodeToXML():String
		{
			if (traceXmlEncodeDecode)
				trace("encodeToXML()");

			var qName:QName;
			var xmlEncoder:XMLEncoder;
			var xmlList:XMLList;


			qName = getSettingsQName();

			xmlEncoder = new XMLEncoder();
			xmlEncoder.schemaManager = schemaManager;

			xmlList = xmlEncoder.encode(settings, qName);

			xmlEncoder.setAttribute(xmlList[0], "xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance");
			xmlEncoder.setAttribute(xmlList[0], "xmlns", schema.namespaces[""].uri);

			if (traceXmlEncodeDecode)
				trace(xmlList.toXMLString());

			return xmlList.toXMLString();
		}

		public function get settings():Settings
		{
			return _settings;
		}

		public function set settings(value:Settings):void
		{
			_settings = value;
		}

        public function get applicationSettingsEmbeddedFile():Class
        {
            return _applicationSettingsEmbeddedFile;
        }

        public function set applicationSettingsEmbeddedFile(applicationSettingsEmbededFile:Class):void
        {
            _applicationSettingsEmbeddedFile = applicationSettingsEmbededFile;
        }

        public function get isApplicationSettingsLoaded():Boolean
        {
            return _isApplicationSettingsLoaded;
        }

        public function get isUserSettingsLoaded():Boolean
        {
            return _isUserSettingsLoaded;
        }
    }
}
