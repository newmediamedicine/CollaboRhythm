package collaboRhythm.shared.model.healthRecord
{

	/**
	 * Represents a relationship between documents in a health record.
	 */
	public class Relationship
	{
		public static const ACTION_CREATE:String = "create";
		private var _pendingAction:String; // create or null
		private var _type:String;
		private var _relatesFrom:IDocument;
		private var _relatesFromId:String;
		private var _relatesTo:IDocument;
		private var _relatesToId:String;

		public function Relationship()
		{
		}

		public function get pendingAction():String
		{
			return _pendingAction;
		}

		public function set pendingAction(value:String):void
		{
			_pendingAction = value;
		}

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}

		public function get relatesFrom():IDocument
		{
			return _relatesFrom;
		}

		public function set relatesFrom(value:IDocument):void
		{
			_relatesFrom = value;
		}

		public function get relatesFromId():String
		{
			return _relatesFromId;
		}

		public function set relatesFromId(value:String):void
		{
			_relatesFromId = value;
		}

		public function get relatesTo():IDocument
		{
			return _relatesTo;
		}

		public function set relatesTo(value:IDocument):void
		{
			_relatesTo = value;
		}

		public function get relatesToId():String
		{
			return _relatesToId;
		}

		public function set relatesToId(value:String):void
		{
			_relatesToId = value;
		}
	}
}
