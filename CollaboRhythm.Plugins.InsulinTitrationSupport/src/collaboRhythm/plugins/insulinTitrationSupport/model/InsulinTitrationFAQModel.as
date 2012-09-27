package collaboRhythm.plugins.insulinTitrationSupport.model
{
	[Bindable]
	public class InsulinTitrationFAQModel
	{
		private var _faqRichEditableTextScrollPosition:Number;

		public function InsulinTitrationFAQModel()
		{
		}

		public function setFaqRichEditableTextScrollPosition(verticalScrollPosition:Number):void
		{
			_faqRichEditableTextScrollPosition = verticalScrollPosition;
		}

		public function get faqRichEditableTextScrollPosition():Number
		{
			return _faqRichEditableTextScrollPosition;
		}

		public function set faqRichEditableTextScrollPosition(value:Number):void
		{
			_faqRichEditableTextScrollPosition = value;
		}
	}
}
