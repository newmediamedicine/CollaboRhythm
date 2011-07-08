package collaboRhythm.core.model
{

	import flash.utils.ByteArray;

	import mx.rpc.xml.Schema;
	import mx.rpc.xml.SchemaManager;
	import mx.rpc.xml.SchemaTypeRegistry;
	import mx.rpc.xml.XMLDecoder;
	import mx.rpc.xml.XMLEncoder;
	import mx.utils.ObjectUtil;

	public class XmlMarshaller
	{
		private var schemaManager:SchemaManager;
		private var schemaTypeRegistry:SchemaTypeRegistry;
		private var traceXmlEncodeDecode:Boolean = false;

		public function XmlMarshaller()
		{
			schemaManager = new SchemaManager();
			schemaTypeRegistry = SchemaTypeRegistry.getInstance();
		}

		public function addSchema(embeddedSchemaFile:Class):void
		{
			var byteArray:ByteArray = new embeddedSchemaFile;
			if (byteArray.length == 0)
				byteArray = new embeddedSchemaFile();

			if (byteArray.length == 0)
				throw new Error("Failed to load embedded schema.");

			var schema:Schema = new Schema(new XML(byteArray.readUTFBytes(byteArray.length)));

//			// cumulatively include the previously added schema
//			var currentScope:Array = schemaManager.currentScope();
//			if (currentScope.length > 0)
//			{
//				var otherSchema:Schema = currentScope[currentScope.length - 1];
//				schema.addInclude(otherSchema.xml.children());
//			}

			schemaManager.addSchema(schema);
		}

		public function registerClass(qName:QName, definition:Object):void
		{
			schemaTypeRegistry.registerClass(qName, definition);
		}

		/**
		 * Decodes XML into ActionScript objects using the schema definitions within SchemaManager
		 */
		public function unmarshallXml(xml:XML, qName:QName, targetObject:Object=null):Object
		{
			if (traceXmlEncodeDecode)
				trace("decodeXML()");

			// make sure the XML has the expected namespace uri
			if (xml.namespaceDeclarations().length == 0 ||
					xml.namespace("").uri != qName.uri)
			{
				var message:String = "Failed to decode XML. XML must include expected namespace: " + qName.uri;
				trace(message);
//				logger.warn(message);
				// TODO: figure out how to add the namespace so the settings.xml will load; the following seems to have no effect
//				xml = xml.addNamespace(schema.namespaces[""]);

                return null;
			}

			var xmlDecoder:XMLDecoder;

			xmlDecoder = new XmlDecoderEx();
			xmlDecoder.schemaManager = schemaManager;
			xmlDecoder.makeObjectsBindable = true;

			if (!targetObject)
			{
				var result:*;
				result = xmlDecoder.decode(xml, qName, qName);
				targetObject = result;
			}
			else
			{
				xmlDecoder.decodeType(qName, targetObject, qName, xml);
			}

			if (traceXmlEncodeDecode)
				trace(ObjectUtil.toString(targetObject));

            return targetObject;
		}

		public function encodeToXML(qName:QName, targetObject:Object=null):String
		{
			if (traceXmlEncodeDecode)
				trace("encodeToXML()");

			var xmlEncoder:XMLEncoder;
			var xmlList:XMLList;

			xmlEncoder = new XMLEncoder();
			xmlEncoder.schemaManager = schemaManager;

			xmlList = xmlEncoder.encode(targetObject, qName);

			xmlEncoder.setAttribute(xmlList[0], "xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance");
			xmlEncoder.setAttribute(xmlList[0], "xmlns", qName.uri);

			if (traceXmlEncodeDecode)
				trace(xmlList.toXMLString());

			return xmlList.toXMLString();
		}
	}
}
