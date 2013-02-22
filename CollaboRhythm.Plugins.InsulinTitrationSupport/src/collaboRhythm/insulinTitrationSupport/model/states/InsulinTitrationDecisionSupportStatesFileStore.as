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
package collaboRhythm.insulinTitrationSupport.model.states
{
	import collaboRhythm.shared.insulinTitrationSupport.model.states.*;
	import collaboRhythm.shared.model.settings.XmlDecoderEx2;

	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;

	import mx.collections.ArrayCollection;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.xml.Schema;
	import mx.rpc.xml.SchemaManager;
	import mx.rpc.xml.SchemaTypeRegistry;
	import mx.rpc.xml.XMLEncoder;
	import mx.utils.ObjectUtil;

	public class InsulinTitrationDecisionSupportStatesFileStore implements ITitrationDecisionSupportStatesFileStore
	{
		[Embed("/assets/strings/titrationDecisionSupportStates.xsd", mimeType="application/octet-stream")]
		private var titrationDecisionSupportStatesSchema:Class;

		[Embed("/assets/strings/insulinTitrationDecisionSupportStates.xml", mimeType="application/octet-stream")]
		private var insulinTitrationDecisionSupportStatesEmbeddedFile:Class;

        private var schema:Schema;

		private var schemaManager:SchemaManager;
        private var _titrationDecisionSupportStates:ArrayCollection;
        private var traceXmlEncodeDecode:Boolean = false;
        protected var _logger:ILogger;
        private var _isLoaded:Boolean;

		public function InsulinTitrationDecisionSupportStatesFileStore()
		{
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			loadSchema();
		}

		private function loadSchema():void
		{
			var byteArray:ByteArray = new titrationDecisionSupportStatesSchema;
			if (byteArray.length == 0)
				byteArray = new titrationDecisionSupportStatesSchema();
			
			if (byteArray.length == 0)
				throw new Error("Failed to load embedded titrationDecisionSupportStates.xsd schema.");
				
			schema = new Schema(new XML(byteArray.readUTFBytes(byteArray.length)));

			schemaManager = new SchemaManager();
			schemaManager.addSchema(schema);

			var schemaTypeRegistry:SchemaTypeRegistry;
			schemaTypeRegistry = SchemaTypeRegistry.getInstance();
//			schemaTypeRegistry.registerClass(new QName(schema.targetNamespace.uri,
//					"titrationDecisionSupportStates"), TitrationDecisionSupportStates);
			schemaTypeRegistry.registerClass(new QName(schema.targetNamespace.uri, "titrationDecisionSupportState"), TitrationDecisionSupportState);
			schemaTypeRegistry.registerClass(new QName(schema.targetNamespace.uri, "step"), Step);
		}

		public function readStates():void
		{
			_isLoaded = readTitrationDecisionSupportStatesFromEmbeddedFile(insulinTitrationDecisionSupportStatesEmbeddedFile);
		}

		private function readTitrationDecisionSupportStatesFromEmbeddedFile(embeddedFile:Class):Boolean
		{
			if (!embeddedFile)
				throw new Error("Failed to load embedded file");

            // TODO: determine why this does not work properly in FlashBuilder
			var byteArray:ByteArray = new embeddedFile;
			if (byteArray.length == 0)
				byteArray = new embeddedFile();

			if (byteArray.length == 0)
				throw new Error("Failed to load embedded titrationDecisionSupportStates.xml file.");

			var embeddedXML:XML = XML(byteArray.readUTFBytes(byteArray.length));
			return decodeXML("Embedded (application level) titrationDecisionSupportStates.xml file", embeddedXML);
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
				var message:String = "Warning: all titrationDecisionSupportStates will be ignored. " + fileSourceDescription + " must be updated to include expected namespace: " + schema.namespaces[""].uri;
				_logger.warn(message);
                return false;
			}

			var qName:QName;
			var xmlDecoder:XmlDecoderEx2;

			qName = new QName(schema.targetNamespace.uri, "titrationDecisionSupportStates");
			xmlDecoder = new XmlDecoderEx2();
			xmlDecoder.schemaManager = schemaManager;
			xmlDecoder.makeObjectsBindable = true;

/*
			var test:TitrationDecisionSupportState = new TitrationDecisionSupportState();
			test.selectors = new ArrayCollection();
			var aliasName:String = ReflectionUtils.getClassInfo(TitrationDecisionSupportState).name;
			registerClassAlias(aliasName, TitrationDecisionSupportState);
			var currentDomain:ApplicationDomain = ApplicationDomain.currentDomain;
			trace(currentDomain);
			var definition:Object = currentDomain.getDefinition(aliasName);
			trace(definition);
*/

			if (!titrationDecisionSupportStates)
			{
				var result:*;
				result = xmlDecoder.decode(xml, qName, qName);
				titrationDecisionSupportStates = result as ArrayCollection;
			}
			else
			{
				xmlDecoder.decodeType(qName, titrationDecisionSupportStates, qName, xml);
			}

			if (traceXmlEncodeDecode)
				trace(ObjectUtil.toString(titrationDecisionSupportStates));

            return true;
		}

		public function encodeToXML():String
		{
			if (traceXmlEncodeDecode)
				trace("encodeToXML()");

			var qName:QName;
			var xmlEncoder:XMLEncoder;
			var xmlList:XMLList;


			qName = new QName(schema.targetNamespace.uri, "titrationDecisionSupportStates");
			xmlEncoder = new XMLEncoder();
			xmlEncoder.schemaManager = schemaManager;

			xmlList = xmlEncoder.encode(titrationDecisionSupportStates, qName);

			xmlEncoder.setAttribute(xmlList[0], "xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance");
			xmlEncoder.setAttribute(xmlList[0], "xmlns", schema.namespaces[""].uri);

			if (traceXmlEncodeDecode)
				trace(xmlList.toXMLString());

			return xmlList.toXMLString();
		}

		public function get titrationDecisionSupportStates():ArrayCollection
		{
			return _titrationDecisionSupportStates;
		}

		public function set titrationDecisionSupportStates(value:ArrayCollection):void
		{
			_titrationDecisionSupportStates = value;
		}

		public function get isLoaded():Boolean
        {
            return _isLoaded;
        }
    }
}
