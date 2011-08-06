package collaboRhythm.core.model.healthRecord.service.supportClasses
{

	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.IDocument;
	import collaboRhythm.shared.model.healthRecord.Relationship;

	import j2as3.collection.HashMap;

	import mx.collections.ArrayCollection;

	/**
	 * Represents a set of changes to a Record (changed documents and relationships). A ChangeSet could be used to
	 * represent the changes that are pending or have failed in some way.
	 */
	public class ChangeSet
	{
		private var _createDocuments:HashMap = new HashMap();
		private var _removeDocuments:HashMap = new HashMap();
		private var _updateDocuments:HashMap = new HashMap();
		private var _createRelationships:ArrayCollection = new ArrayCollection();

		public function ChangeSet()
		{
		}

		public function addDocument(document:IDocument):void
		{
			if (document.pendingAction == DocumentBase.ACTION_CREATE)
				createDocuments.put(document.meta.id, document);
			else if (document.isPendingActionRemoval())
				removeDocuments.put(document.meta.id, document);
			else if (document.pendingAction == DocumentBase.ACTION_UPDATE)
				updateDocuments.put(document.meta.id, document);
			else
				throw new Error("Attempted to add document " + document.meta.id + " to a change set, but pendingAction is " + document.pendingAction);
		}

		public function addRelationship(relationship:Relationship):void
		{
			createRelationships.addItem(relationship);
		}

		public function get createDocuments():HashMap
		{
			return _createDocuments;
		}

		public function get removeDocuments():HashMap
		{
			return _removeDocuments;
		}

		public function get updateDocuments():HashMap
		{
			return _updateDocuments;
		}

		public function get createRelationships():ArrayCollection
		{
			return _createRelationships;
		}

		public function clear():void
		{
			createDocuments.clear();
			removeDocuments.clear();
			updateDocuments.clear();
			createRelationships.removeAll();
		}

		public function get length():Number
		{
			return createDocuments.size() + removeDocuments.size() + updateDocuments.size() + createRelationships.length;
		}

		public function get summary():String
		{
			var parts:Array = new Array();
			if (createDocuments.size() > 0)
				parts.push("creating " + createDocuments.size() + " documents");
			if (updateDocuments.size() > 0)
				parts.push("updating " + updateDocuments.size() + " documents");
			if (removeDocuments.size() > 0)
				parts.push("removing " + removeDocuments.size() + " documents");
			if (createRelationships.length > 0)
				parts.push("creating " + createRelationships.length + " relationships");

			return parts.join(", ");
		}

		public function containsCreateDocument(documentId:String):Boolean
		{
			return createDocuments.getItem(documentId) != null;
		}
	}
}
