package collaboRhythm.shared.model.healthRecord
{

	import mx.collections.ArrayCollection;

	public class DocumentBase extends DocumentMetadata implements IDocument
	{
		private var _relatesTo:ArrayCollection = new ArrayCollection();
		private var _isRelatedFrom:ArrayCollection = new ArrayCollection();

		public function DocumentBase()
		{
		}

		public function get relatesTo():ArrayCollection
		{
			return _relatesTo;
		}

		public function set relatesTo(value:ArrayCollection):void
		{
			_relatesTo = value;
		}

		public function get isRelatedFrom():ArrayCollection
		{
			return _isRelatedFrom;
		}

		public function set isRelatedFrom(value:ArrayCollection):void
		{
			_isRelatedFrom = value;
		}
	}
}
