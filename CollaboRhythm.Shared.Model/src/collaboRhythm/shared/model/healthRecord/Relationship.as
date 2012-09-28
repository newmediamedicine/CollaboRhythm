package collaboRhythm.shared.model.healthRecord
{
	import mx.collections.ArrayCollection;

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
		
		/**
		 * This property getter was added to allow documents to be viewed as a hierarchy in HealthRecordTree.
		 */
		[Transient]
		public function get documents():ArrayCollection
		{
			if (relatesTo)
				return new ArrayCollection([relatesTo]);
			else
				return null;
		}

		public function get pendingAction():String
		{
			return _pendingAction;
		}

		public function set pendingAction(value:String):void
		{
			_pendingAction = value;
		}

		/**
		 * The type of the relationship, such as "http://indivo.org/vocab/documentrels#scheduleItem"
		 */
		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}

		public function get shortType():String
		{
			var parts:Array = type.split("#");
			return parts[parts.length - 1];
		}


		/**
		 * The document that the relatesTo document is related from.
		 */
		[Transient]
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

		/**
		 * The other document that the relatesFrom document is related to.
		 */
		[Transient]
		public function get relatesTo():IDocument
		{
			return _relatesTo;
		}

		public function set relatesTo(value:IDocument):void
		{
			if (value == null)
				trace("############### Relationship set relatesTo null");
			_relatesTo = value;
		}

		/**
		 * The id of the other document that the relatesFrom document is related to.
		 */
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
