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

	public class InsulinTitrationDecisionSupportStatesFileStore implements IInsulinTitrationDecisionSupportStatesFileStore
	{
		[Embed("/assets/strings/insulinTitrationDecisionSupportStates.xsd", mimeType="application/octet-stream")]
		private var insulinTitrationDecisionSupportStatesSchema:Class;

		[Embed("/assets/strings/insulinTitrationDecisionSupportStates.xml", mimeType="application/octet-stream")]
		private var insulinTitrationDecisionSupportStatesEmbeddedFile:Class;

        private var schema:Schema;

		private var schemaManager:SchemaManager;
        private var _insulinTitrationDecisionSupportStates:ArrayCollection;
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
			var byteArray:ByteArray = new insulinTitrationDecisionSupportStatesSchema;
			if (byteArray.length == 0)
				byteArray = new insulinTitrationDecisionSupportStatesSchema();
			
			if (byteArray.length == 0)
				throw new Error("Failed to load embedded insulinTitrationDecisionSupportStates.xsd schema.");
				
			schema = new Schema(new XML(byteArray.readUTFBytes(byteArray.length)));

			schemaManager = new SchemaManager();
			schemaManager.addSchema(schema);

			var schemaTypeRegistry:SchemaTypeRegistry;
			schemaTypeRegistry = SchemaTypeRegistry.getInstance();
//			schemaTypeRegistry.registerClass(new QName(schema.targetNamespace.uri,
//					"insulinTitrationDecisionSupportStates"), InsulinTitrationDecisionSupportStates);
			schemaTypeRegistry.registerClass(new QName(schema.targetNamespace.uri, "insulinTitrationDecisionSupportState"), InsulinTitrationDecisionSupportState);
			schemaTypeRegistry.registerClass(new QName(schema.targetNamespace.uri, "step"), Step);
		}

		public function readStates():void
		{
			_isLoaded = readInsulinTitrationDecisionSupportStatesFromEmbeddedFile(insulinTitrationDecisionSupportStatesEmbeddedFile);
		}

		private function readInsulinTitrationDecisionSupportStatesFromEmbeddedFile(embeddedFile:Class):Boolean
		{
			if (!embeddedFile)
				throw new Error("Failed to load embedded file");

            // TODO: determine why this does not work properly in FlashBuilder
			var byteArray:ByteArray = new embeddedFile;
			if (byteArray.length == 0)
				byteArray = new embeddedFile();

			if (byteArray.length == 0)
				throw new Error("Failed to load embedded insulinTitrationDecisionSupportStates.xml file.");

			var embeddedXML:XML = XML(byteArray.readUTFBytes(byteArray.length));
			return decodeXML("Embedded (application level) insulinTitrationDecisionSupportStates.xml file", embeddedXML);
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
				var message:String = "Warning: all insulinTitrationDecisionSupportStates will be ignored. " + fileSourceDescription + " must be updated to include expected namespace: " + schema.namespaces[""].uri;
				_logger.warn(message);
                return false;
			}

			var qName:QName;
			var xmlDecoder:XmlDecoderEx2;

			qName = new QName(schema.targetNamespace.uri, "insulinTitrationDecisionSupportStates");
			xmlDecoder = new XmlDecoderEx2();
			xmlDecoder.schemaManager = schemaManager;
			xmlDecoder.makeObjectsBindable = true;

/*
			var test:InsulinTitrationDecisionSupportState = new InsulinTitrationDecisionSupportState();
			test.selectors = new ArrayCollection();
			var aliasName:String = ReflectionUtils.getClassInfo(InsulinTitrationDecisionSupportState).name;
			registerClassAlias(aliasName, InsulinTitrationDecisionSupportState);
			var currentDomain:ApplicationDomain = ApplicationDomain.currentDomain;
			trace(currentDomain);
			var definition:Object = currentDomain.getDefinition(aliasName);
			trace(definition);
*/

			if (!insulinTitrationDecisionSupportStates)
			{
				var result:*;
				result = xmlDecoder.decode(xml, qName, qName);
				insulinTitrationDecisionSupportStates = result as ArrayCollection;
			}
			else
			{
				xmlDecoder.decodeType(qName, insulinTitrationDecisionSupportStates, qName, xml);
			}

			if (traceXmlEncodeDecode)
				trace(ObjectUtil.toString(insulinTitrationDecisionSupportStates));

            return true;
		}

		public function encodeToXML():String
		{
			if (traceXmlEncodeDecode)
				trace("encodeToXML()");

			var qName:QName;
			var xmlEncoder:XMLEncoder;
			var xmlList:XMLList;


			qName = new QName(schema.targetNamespace.uri, "insulinTitrationDecisionSupportStates");
			xmlEncoder = new XMLEncoder();
			xmlEncoder.schemaManager = schemaManager;

			xmlList = xmlEncoder.encode(insulinTitrationDecisionSupportStates, qName);

			xmlEncoder.setAttribute(xmlList[0], "xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance");
			xmlEncoder.setAttribute(xmlList[0], "xmlns", schema.namespaces[""].uri);

			if (traceXmlEncodeDecode)
				trace(xmlList.toXMLString());

			return xmlList.toXMLString();
		}

		public function get insulinTitrationDecisionSupportStates():ArrayCollection
		{
			return _insulinTitrationDecisionSupportStates;
		}

		public function set insulinTitrationDecisionSupportStates(value:ArrayCollection):void
		{
			_insulinTitrationDecisionSupportStates = value;
		}

		public function get isLoaded():Boolean
        {
            return _isLoaded;
        }
    }
}
