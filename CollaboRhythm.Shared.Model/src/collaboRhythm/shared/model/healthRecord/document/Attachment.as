package collaboRhythm.shared.model.healthRecord.document
{
	public class Attachment
	{
		private var _num:int;
		private var _type:String;
		private var _size:int;
		private var _doc_id:String;

		public function Attachment()
		{
		}

		public function get num():int
		{
			return _num;
		}

		public function set num(value:int):void
		{
			_num = value;
		}

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}

		public function get size():int
		{
			return _size;
		}

		public function set size(value:int):void
		{
			_size = value;
		}

		public function get doc_id():String
		{
			return _doc_id;
		}

		public function set doc_id(value:String):void
		{
			_doc_id = value;
		}
	}
}
