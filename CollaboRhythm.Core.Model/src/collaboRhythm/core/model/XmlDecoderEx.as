package collaboRhythm.core.model
{

	import collaboRhythm.shared.model.healthRecord.CodedValue;

	import mx.rpc.xml.ContentProxy;
	import mx.rpc.xml.XMLDecoder;
	import mx.utils.object_proxy;

	use namespace object_proxy;

	public class XmlDecoderEx extends XMLDecoder
	{
		public function XmlDecoderEx()
		{
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
		 override public function setSimpleValue(parent:*, name:*, value:*, type:Object=null):void
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

	}
}
