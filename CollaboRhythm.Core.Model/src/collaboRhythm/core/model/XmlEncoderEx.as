package collaboRhythm.core.model
{

	import collaboRhythm.shared.model.healthRecord.CodedValue;

	import mx.rpc.xml.TypeIterator;
	import mx.rpc.xml.XMLEncoder;

	public class XmlEncoderEx extends XMLEncoder
	{
		public function XmlEncoderEx()
		{
		}

		/**
		 * @private
		 */
		override public function getValue(parent:*, name:*):*
		{
			var value:*;

			if (parent is XML || parent is XMLList)
			{
				var node:XMLList = parent[name];
				if (node.length() > 0)
					value = node;
			}
			else if (TypeIterator.isIterable(parent))
			{
				// We may have an associative Array
				if (parent.hasOwnProperty(name) && parent[name] !== undefined)
				{
					value = resolveNamedProperty(parent, name);
				}
				else
				{
					// Otherwise, we just return the value as this may be for an
					// ArrayOfSomeType that needs special casing to map directly
					// to an Array without a wrapper type
					value = parent;
				}
			}
			else if (parent is CodedValue && name is QName && (name as QName).localName != "type" && (name as QName).localName != "value" && (name as QName).localName != "abbrev")
			{
				var codedValue:CodedValue = parent as CodedValue;
				value = codedValue.text;
			}
			else if (!isSimpleValue(parent))
			{
				// We only support the public namespace for now
				if (name is QName)
					name = QName(name).localName;

				value = resolveNamedProperty(parent, name);
			}
			else
			{
				// FIXME: Shouldn't this be an error condition?
				value = parent;
			}

			return value;
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
	}
}
