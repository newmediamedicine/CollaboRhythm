package collaboRhythm.shared.model.healthRecord
{

	import mx.collections.ArrayCollection;

	[Bindable]
	public class DocumentBase implements IDocument
	{
		public static const ACTION_CREATE:String = "create";
		public static const ACTION_UPDATE:String = "update";
		public static const ACTION_DELETE:String = "delete";
		public static const ACTION_VOID:String = "void";
		public static const ACTION_ARCHIVE:String = "archive";
		private var _meta:DocumentMetadata = new DocumentMetadata();
		private var _pendingAction:String; // create, update, delete, void, archive, or null
		private var _pendingActionReason:String; // reason for void or archive
		private var _relatesTo:ArrayCollection = new ArrayCollection();
		private var _isRelatedFrom:ArrayCollection = new ArrayCollection();
		private var _isBeingProcessed:Boolean;

		public function DocumentBase()
		{
		}

		/**
		 * This property getter was added to allow documents to be viewed as a hierarchy in HealthRecordTree.
		 * If this causes a collision with any field names on future Indivo data types, this field can be removed.
		 */
		public function get documents():ArrayCollection
		{
			return relatesTo;
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

		public function get pendingAction():String
		{
			return _pendingAction;
		}

		public function set pendingAction(value:String):void
		{
			_pendingAction = value;
		}

		public function get pendingActionReason():String
		{
			return _pendingActionReason;
		}

		public function set pendingActionReason(value:String):void
		{
			_pendingActionReason = value;
		}

		public function get meta():IDocumentMetadata
		{
			return _meta;
		}

		public function clearRelationships():void
		{
			for each (var relationship:Relationship in this.isRelatedFrom)
			{
				if (relationship.relatesFrom != null)
				{
					var otherDocument:IDocument = relationship.relatesFrom;
					if (otherDocument.isRelatedFrom.contains(relationship))
					{
						otherDocument.isRelatedFrom.removeItemAt(otherDocument.isRelatedFrom.getItemIndex(relationship));
					}
				}
			}
			for each (relationship in this.relatesTo)
			{
				if (relationship.relatesTo != null)
				{
					otherDocument = relationship.relatesTo;
					if (otherDocument.relatesTo.contains(relationship))
					{
						otherDocument.relatesTo.removeItemAt(otherDocument.relatesTo.getItemIndex(relationship));
					}
				}
			}
		}

		public function isPendingActionRemoval():Boolean
		{
			return pendingAction == ACTION_ARCHIVE || pendingAction == ACTION_DELETE || pendingAction == ACTION_VOID;
		}

		/**
		 * Compare function for sorting documents based on the value of the createdAt property in its metaData.
		 *
		 * @param documentBaseA
		 * @param documentBaseB
		 * @return
		 */
		public static function compareDocumentsByCreatedAtValue(documentBaseA:DocumentBase, documentBaseB:DocumentBase):int
		{
			if (documentBaseA.meta.createdAt.valueOf() < documentBaseB.meta.createdAt.valueOf())
			{
				return 1;
			}
			else if (documentBaseA.meta.createdAt.valueOf() == documentBaseB.meta.createdAt.valueOf())
			{
				return 0;
			}
			return -1;
		}

		public function get isBeingSaved():Boolean
		{
			return _isBeingProcessed;
		}

		public function set isBeingSaved(value:Boolean):void
		{
			_isBeingProcessed = value;
		}
	}
}
