package collaboRhythm.core.model
{
	import avmplus.factoryXml;

	import collaboRhythm.shared.model.healthRecord.IDocument;

	public class SynchronizedDocumentUpdate
	{
		private var _ownerAccountId:String;
		private var _document:IDocument;
		private var _oldId:String;
		private var _isUpdate:Boolean;
		private var _newId:String;
		private var _isSynchronizing:Boolean;

		public function SynchronizedDocumentUpdate(ownerAccountId:String=null,
												   document:IDocument=null,
												   oldId:String=null, newId:String=null, isUpdate:Boolean=false,
												   isSynchronizing:Boolean=false)
		{
			_ownerAccountId = ownerAccountId;
			_document = document;
			_oldId = oldId;
			_newId = newId;
			_isUpdate = isUpdate;
			_isSynchronizing = isSynchronizing;
		}

		public function get ownerAccountId():String
		{
			return _ownerAccountId;
		}

		public function set ownerAccountId(value:String):void
		{
			_ownerAccountId = value;
		}

		public function get document():IDocument
		{
			return _document;
		}

		public function set document(value:IDocument):void
		{
			_document = value;
		}

		public function get oldId():String
		{
			return _oldId;
		}

		public function set oldId(value:String):void
		{
			_oldId = value;
		}

		public function get isUpdate():Boolean
		{
			return _isUpdate;
		}

		public function set isUpdate(value:Boolean):void
		{
			_isUpdate = value;
		}

		public function get newId():String
		{
			return _newId;
		}

		public function set newId(value:String):void
		{
			_newId = value;
		}

		public function get isSynchronizing():Boolean
		{
			return _isSynchronizing;
		}

		public function set isSynchronizing(value:Boolean):void
		{
			_isSynchronizing = value;
		}
	}
}
