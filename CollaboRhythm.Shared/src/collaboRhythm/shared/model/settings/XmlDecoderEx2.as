package collaboRhythm.shared.model.settings
{

	import collaboRhythm.shared.model.healthRecord.CodedValue;

	import mx.logging.Log;
	import mx.rpc.xml.ContentProxy;
	import mx.utils.object_proxy;

	use namespace object_proxy;

	/**
	 * Adds a fix for decoding CodedValue which has both attributes and content (and would otherwise not be
	 * handled by XMLDecoder correctly).
	 */
	public class XmlDecoderEx2 extends XmlDecoderEx
	{

		public function XmlDecoderEx2()
		{
			log = Log.getLogger("collaboRhythm.shared.model.settings.XmlDecoderEx2");
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


	}
}
