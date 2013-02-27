package collaboRhythm.plugins.bloodPressure.model
{
[Bindable]
	public class BloodPressureMedicationTitrationFAQModel
	{
		private var _faqRichEditableTextScrollPosition:Number;

		public function BloodPressureMedicationTitrationFAQModel()
		{
		}

		public function setFaqRichEditableTextScrollPosition(verticalScrollPosition:Number):void
		{
			faqRichEditableTextScrollPosition = verticalScrollPosition;
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

