package collaboRhythm.shared.model.settings
{

	import collaboRhythm.shared.model.healthRecord.CodedValue;

	import mx.logging.ILogger;
	import mx.logging.Log;

	import mx.rpc.xml.ContentProxy;
	import mx.rpc.xml.TypeIterator;
	import mx.rpc.xml.XMLDecoder;
	import mx.utils.object_proxy;

	use namespace object_proxy;

	public class XmlDecoderEx extends XMLDecoder
	{
		private var log:ILogger;

		public function XmlDecoderEx()
		{
			log = Log.getLogger("collaboRhythm.shared.model.settings.XmlDecoderEx");
		}

		override protected function parseValue(name:*, value:XMLList):*
		{
			var result:* = value;

			// We unwrap simple content and get the value as a String
			if (value.hasSimpleContent() && value.attributes().length() == 0)
			{
				if (isXSINil(value))
					result = null;
				else
					result = value.toString();
			}
			// Otherwise, as a convenience we unwrap an XMLList containing only one
			// XML node...
			else if (value.length() == 1)
			{
				result = value[0];
			}

			return result;
		}

		/**
		 * @private
		 */
		override public function getAttribute(parent:*, name:*):*
		{
			var result:*;
			var attribute:XMLList;
			if (parent is XML)
			{
				attribute = XML(parent).attribute(name);
				if (attribute.length() == 0)
					result = null;
				else
					result = parseValue(name, attribute);
			}
			else if (parent is XMLList)
			{
				attribute = XMLList(parent).attribute(name);
				result = parseValue(name, attribute);
			}

			return result;
		}

		/**
		 * @private
		 */
		override public function setSimpleValue(parent:*, name:*, value:*, type:Object = null):void
		{
			if (parent is ContentProxy)
			{
				var parentProxy:ContentProxy = parent as ContentProxy;

				if (parentProxy.content is CodedValue)
				{
					parentProxy.object_proxy::isSimple = false;
					var codedValue:CodedValue = parentProxy.content;
					codedValue.text = value;
					return;
				}
				else if (parentProxy.object_proxy::isSimple)
				{
					parentProxy.object_proxy::content = value;
					return;
				}
			}

			setValue(parent, name, value, type)
		}


		override public function setValue(parent:*, name:*, value:*, type:Object = null):void
		{
			if (parent != null)
			{
				// Unwrap any proxied values
				if (value is ContentProxy)
					value = ContentProxy(value).object_proxy::content;

				var existingValue:*;

				// We already have an array of values, so just add to this list
				if (TypeIterator.isIterable(parent))
				{
					TypeIterator.push(parent, value);
				}
				else if (name != null)
				{
					var propertyName:String;
					if (name is ContentProxy)
						name = ContentProxy(name).object_proxy::content;

					if (name is QName)
						propertyName = QName(name).localName;
					else
						propertyName = Object(name).toString();



					if (parent is ContentProxy && ContentProxy(parent).object_proxy::isSimple)
					{
						var simpleContent:* = ContentProxy(parent).object_proxy::content;
						if (simpleContent != null)
						{
							if (isSimpleValue(simpleContent) || TypeIterator.isIterable(simpleContent))
							{
								existingValue = simpleContent;
							}
							else
							{
								// TODO: Remove these hacks and establish a convention
								// for simple property values on strongly typed values

								// HACK for SDK-14800:
								// Flash Builder may generate a strongly typed class for simpleContent extensions
								// or restrictions, which uses the convention of "_" + typeName for the simpleContent
								// value.
								var localName:String = getUnqualifiedClassName(simpleContent);
								var simplePropName:String = "_" + localName;
								if (Object(simpleContent).hasOwnProperty(simplePropName))
								{
									simpleContent[simplePropName] = value;
									return;
								}

								// HACK for SDK-22327:
								// Flash Builder may alternatively generate a property
								// name with camel case for a simpleType enumeration
								simplePropName = localName.charAt(0).toLowerCase() + localName.substr(1);
								if (Object(simpleContent).hasOwnProperty(simplePropName))
								{
									simpleContent[simplePropName] = value;
									return;
								}
							}
						}
					}
					else
					{
						if (Object(parent).hasOwnProperty(propertyName))
							existingValue = getExistingValue(parent, propertyName);

						else if (Object(parent).hasOwnProperty("_" + propertyName))
							existingValue = getExistingValue(parent, "_" + propertyName);
					}

					// FIXME: How would we handle building up an Array of null
					// values from a sequence? If the type was * then it would
					// allow undefined to be checked, but this is a rare type
					// for users to declare... perhaps more context is needed
					// here.
					if (existingValue != null)
					{
//						existingValue = promoteValueToArray(existingValue, type);
//						TypeIterator.push(existingValue, value);
//						value = existingValue;
					}

					try
					{
						if (parent is ContentProxy && ContentProxy(parent).object_proxy::isSimple)
						{
							ContentProxy(parent).object_proxy::content = value;
						}
						else
						{
							try
							{
								parent[propertyName] = value;
							}
							catch(e:Error)
							{
								parent["_"+propertyName] = value;
							}
						}
					}
					catch(e:Error)
					{
						log.warn("Unable to set property '{0}' on parent.", propertyName);
					}
				}
				// If not an array, and without a name, we assume this may be the
				// first of potentially many items, or perhaps it is the second
				// item requiring us to promote the the existing item to an array.
				else if (parent is ContentProxy)
				{
					var proxyParent:ContentProxy = parent as ContentProxy;
					existingValue = proxyParent.object_proxy::content;
					if (existingValue !== undefined)
					{
						existingValue = promoteValueToArray(existingValue, type);
						proxyParent.object_proxy::content = existingValue;
						TypeIterator.push(existingValue, value);
						value = existingValue;
					}

					proxyParent.object_proxy::content = value;
				}
			}
		}
	}
}
