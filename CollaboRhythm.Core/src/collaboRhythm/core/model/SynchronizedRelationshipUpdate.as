package collaboRhythm.core.model
{
	import collaboRhythm.shared.model.healthRecord.Relationship;

	public class SynchronizedRelationshipUpdate
	{
		private var _ownerAccountId:String;
		private var _relationship:Relationship;
		private var _isSynchronizing:Boolean;

		public function SynchronizedRelationshipUpdate(ownerAccountId:String=null,
													   relationship:Relationship=null,
													   isSynchronizing:Boolean=false)
		{
			_ownerAccountId = ownerAccountId;
			_relationship = relationship;
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

		public function get relationship():Relationship
		{
			return _relationship;
		}

		public function set relationship(value:Relationship):void
		{
			_relationship = value;
		}

		public function get isSynchronizing():Boolean
		{
			return _isSynchronizing;
		}

		public function set isSynchronizing(value:Boolean):void
		{
			_isSynchronizing = value;
		}

		public function toString():String
		{
			return "SynchronizedRelationshipUpdate{_relationship=" + String(_relationship) + ",_isSynchronizing=" +
					String(_isSynchronizing) + "}";
		}
	}
}
