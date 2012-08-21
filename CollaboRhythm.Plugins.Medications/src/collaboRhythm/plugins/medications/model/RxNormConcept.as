package collaboRhythm.plugins.medications.model
{
	import mx.collections.ArrayCollection;

	public class RxNormConcept
	{
		private var _name:String;
		private var _rxcui:String;
		private var _ndcCodes:ArrayCollection = new ArrayCollection();

		public function RxNormConcept(conceptXML:XML = null)
		{
			if (conceptXML)
			{
				_name = conceptXML.name;
				_rxcui = conceptXML.rxcui;
			}
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public function get rxcui():String
		{
			return _rxcui;
		}

		public function set rxcui(value:String):void
		{
			_rxcui = value;
		}

		public function get ndcCodes():ArrayCollection
		{
			return _ndcCodes;
		}
	}
}
