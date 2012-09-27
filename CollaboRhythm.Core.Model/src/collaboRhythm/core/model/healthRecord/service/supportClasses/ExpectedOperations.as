package collaboRhythm.core.model.healthRecord.service.supportClasses
{
	public class ExpectedOperations
	{
		private var _updateDocumentsCount:int;
		private var _updateRelationshipsCount:int;

		public function ExpectedOperations(updateDocumentsCount:int=0, updateRelationshipsCount:int=0)
		{
			_updateDocumentsCount = updateDocumentsCount;
			_updateRelationshipsCount = updateRelationshipsCount;
		}

		public function get updateDocumentsCount():int
		{
			return _updateDocumentsCount;
		}

		public function set updateDocumentsCount(value:int):void
		{
			_updateDocumentsCount = value;
		}

		public function get updateRelationshipsCount():int
		{
			return _updateRelationshipsCount;
		}

		public function set updateRelationshipsCount(value:int):void
		{
			_updateRelationshipsCount = value;
		}
	}
}
