package collaboRhythm.core.model
{

	import collaboRhythm.core.model.healthRecord.TypeSchemaRegistry;
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmCodedValue;

	import mx.rpc.xml.SchemaTypeRegistry;

	import mx.rpc.xml.TypeIterator;
	import mx.rpc.xml.XMLEncoder;

	public class XmlEncoderEx extends XMLEncoder
	{
		private var schemaTypeRegistry:SchemaTypeRegistry;
		private var _typeSchemaRegistry:TypeSchemaRegistry;
		private var _usedXsiPrefix:Boolean;
		private var _targetNamespace:Namespace;

		public function XmlEncoderEx()
		{
			schemaTypeRegistry = SchemaTypeRegistry.getInstance();
		}

		// Added special handling for CollaboRhythmCodedValue type which has both attributes (which already map correctly to
		// properties) and a child/content/value element that needs to be mapped explicitly to the "text" property of
		// the CollaboRhythmCodedValue class.
		override public function getSimpleValue(parent:*, name:*):*
		{
			var codedValue:CollaboRhythmCodedValue = parent as CollaboRhythmCodedValue;
			if (codedValue != null)
			{
				return codedValue.text;
			}
			return super.getSimpleValue(parent, name);
		}

		/**
		 * Sets the xsi:nil attribute when necessary
		 *
		 * @param definition The Schema definition of the expected type. If
		 * nillable is strictly enforced, this definition must explicitly
		 * specify nillable=true.
		 *
		 * @param name The name of the element to be created
		 *
		 * @param value The value to check
		 *
		 * @return content The element where xsi:nil was set, or null if xsi:nil was
		 * not set.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		override public function encodeXSINil(definition:XML, name:QName, value:*, isRequired:Boolean = true):XML
		{
			var minOccurs:uint = getMinOccurs(definition);
			isRequired = isRequired && minOccurs > 0;

			// Check for nillable in the definition only if strictNillability is true.
			// Otherwise assume nillable=true.
			var nillable:Boolean = true;
			if (strictNillability)
			{
				if (definition != null)
					nillable = definition.@nillable.toString() == "true" ? true : false;
				else
					nillable = false; //XML schema default for nillable
			}

			var item:XML;

			// <element fixed="...">
			// Fixed is forbidden when nillable="true". We enforce that only if
			// strictNillability==true. Otherwise we take the fixed value if it
			// is provided.
			var fixedValue:String = getAttributeFromNode("fixed", definition);
			if (!(strictNillability && nillable) && fixedValue != null)
			{
				item = createElement(name);
				setValue(item, schemaManager.marshall(fixedValue, schemaManager.schemaDatatypes.stringQName));
				return item;
			}

			// After we are done with fixed, which can replace even a non-null value,
			// we only care about cases where value is null, so we can return otherwise.
			if (value != null)
				return null;

			// <element default="...">
			var defaultValue:String = getAttributeFromNode("default", definition);
			if (value == null && defaultValue != null)
			{
				item = createElement(name);
				setValue(item, schemaManager.marshall(defaultValue, schemaManager.schemaDatatypes.stringQName));
				return item;
			}

			// If null or undefined, and nillable, we set xsi:nil="true"
			// and return the element
			if (nillable && value === null && isRequired == true)
			{
				item = createElement(name);
				setValue(item, null);
				return item;
			}

			return null;
		}

		protected function getSpecificType(value:*):QName
		{
			var type:QName;

			if (value != null)
			{
				type = _typeSchemaRegistry.getSchema(value);
			}

			return type;
		}

		override public function encodeType(type:QName, parent:XML, name:QName, value:*, restriction:XML = null):void
		{
			var specificType:QName = getSpecificType(value);
			if (specificType != null && type != specificType)
			{
				// TODO: make this work for both the current default namespace and a specific namespace (when a prefix must be specified)
				parent.@[constants.getXSIToken(constants.typeAttrQName)] = specificType.localName;
				_usedXsiPrefix = true;

				type = specificType;
			}

			name = new QName(type.uri, name.localName);

			super.encodeType(type, parent, name, value, restriction);
		}

		/**
		 * Registry for looking up
		 */
		public function get typeSchemaRegistry():TypeSchemaRegistry
		{
			return _typeSchemaRegistry;
		}

		public function set typeSchemaRegistry(value:TypeSchemaRegistry):void
		{
			_typeSchemaRegistry = value;
		}

		/**
		 * Indicates that the "xsi" prefix was used on some element while encoding.
		 */
		public function get usedXsiPrefix():Boolean
		{
			return _usedXsiPrefix;
		}

		public function set usedXsiPrefix(value:Boolean):void
		{
			_usedXsiPrefix = value;
		}

		// Override the default to achieve the behavior we want with elements that have a different namespace
		override public function encodeGroupElement(definition:XML, siblings:XMLList, name:QName, value:*, isRequired:Boolean = true):Boolean
		{
			// <element minOccurs="..." maxOccurs="..."> occur on the local element,
			// not on a referent, so we capture this information first.
			var maxOccurs:uint = getMaxOccurs(definition);
			var minOccurs:uint = getMinOccurs(definition);

			// If the maximum occurence is 0 this element must not be present.
			if (maxOccurs == 0)
				return true;

			isRequired = isRequired && minOccurs > 0;

			// <element ref="..."> may be used to point to a top-level element definition
			var ref:QName;
			if (definition.attribute("ref").length() == 1)
			{
				ref = schemaManager.getQNameForPrefixedName(definition.@ref, definition, true);
				definition = schemaManager.getNamedDefinition(ref, constants.elementTypeQName);
				if (definition == null)
					throw new Error("Cannot resolve element definition for ref '" + ref + "'");
			}

			var elementName:String = definition.@name.toString();
			var elementQName:QName = schemaManager.getQNameForElement(elementName,
					getAttributeFromNode("form", definition));

			// Use the uri from the name if it doesn't match the targetNamespace (Scott Gilroy, 07/20/2012)
			var targetNamespaceUri:String = targetNamespace ? targetNamespace.uri : null;
			if (name.uri != targetNamespaceUri && elementQName.uri != name.uri)
			{
				elementQName = new QName(name.uri, elementQName.localName);
			}

			// Now that we've resolved the real element name, look for the element's
			// value on the provided value.
			var elementValue:* = getValue(value, elementQName);
			var encodedElement:XML;

			// If minOccurs == 0 the element is optional so we can omit it if
			// a value was not provided.
			if (elementValue == null)
			{
				encodedElement = encodeElementTopLevel(definition, elementQName, elementValue);
				if (encodedElement != null)
					appendValue(siblings, encodedElement);

				// If we found our element by reference, we now release the schema scope
				if (ref != null)
					schemaManager.releaseScope();

				// if required, but no value was encoded, the definition is not
				// satisfied
				if (isRequired && encodedElement == null)
					return false;

				// Otherwise we can return true
				return true;
			}

			// We treat maxOccurs="1" as a special case and not check the
			// occurence because we need to pass through values to SOAP
			// encoded Arrays which do not rely on minOccurs/maxOccurs
			if (maxOccurs == 1)
			{
				encodedElement = encodeElementTopLevel(definition, elementQName, elementValue);
				if (encodedElement != null)
				{
					appendValue(siblings, encodedElement);
				}
				// ...else we just skip the element as a value wasn't provided.
			}
			else if (maxOccurs > 1)
			{
				var valueOccurence:uint = getValueOccurence(elementValue);

				// If maxOccurs is greater than 1 then we would expect an
				// Array of values
				if (valueOccurence < minOccurs)
				{
					throw new Error("Value supplied for element '" + elementQName +
							"' occurs " + valueOccurence + " times which falls short of minOccurs " +
							minOccurs + ".");
				}

				if (valueOccurence > maxOccurs)
				{
					throw new Error("Value supplied for element of type '" + elementQName +
							"' occurs " + valueOccurence + " times which exceeds maxOccurs " +
							maxOccurs + ".");
				}

				// Promote non-iterable values to an Array to handle the MXML
				// single-child property case where the compiler doesn't promote
				// a property to an Array until two items are present.
				if (!TypeIterator.isIterable(elementValue))
					elementValue = [elementValue];

				// Encode element based on occurence within the bounds of
				// minOccurs and maxOccurs
				var iter:TypeIterator = new TypeIterator(elementValue);

				for (var i:uint = 0; i < maxOccurs && i < valueOccurence; i++)
				{
					var item:*;
					if (iter.hasNext())
					{
						item = iter.next();
					}
					else if (i > minOccurs)
					{
						break;
					}

					encodedElement = encodeElementTopLevel(definition, elementQName, item);
					// encodedElement is null if encodeXSINil inside encodeElementTopLevel
					// was not allowed to create element with xsi:nil for a null or undefined
					// value. We must still force xsi:nil, because we are encoding an array
					// and we need to preserve the index.
					if (encodedElement == null)
					{
						encodedElement = createElement(elementQName);
						setValue(encodedElement, null);
					}
					appendValue(siblings, encodedElement);
				}
			}

			// If we found our element by reference, we now release the schema scope
			if (ref != null)
				schemaManager.releaseScope();

			return true;
		}

		// Override the default to achieve the behavior we want with elements that have a different namespace. This
		// will add the desired prefix for elements that are not in the target namespace.
		override public function createElement(name:*):XML
		{
			var element:XML;
			var elementName:QName;
			if (name is QName)
				elementName = name as QName;
			else
				elementName = new QName("", name.toString());

			element = <{elementName.localName} />;
			if (elementName.uri != null && elementName.uri.length > 0)
			{
				var prefix:String = schemaManager.getOrCreatePrefix(elementName.uri);
				var ns:Namespace = new Namespace(prefix, elementName.uri);
				element.setNamespace(ns);
			}
			return element;
		}

		public function get targetNamespace():Namespace
		{
			return _targetNamespace;
		}

		public function set targetNamespace(value:Namespace):void
		{
			_targetNamespace = value;
		}
	}
}
