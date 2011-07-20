package collaboRhythm.core.model.healthRecord.stitchers
{

	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.StringUtils;
	import collaboRhythm.shared.model.healthRecord.DocumentMetadata;
	import collaboRhythm.shared.model.healthRecord.IDocument;
	import collaboRhythm.shared.model.healthRecord.IDocumentCollection;
	import collaboRhythm.shared.model.healthRecord.IDocumentStitcher;
	import collaboRhythm.shared.model.healthRecord.Relationship;

	import flash.utils.getQualifiedClassName;

	import mx.binding.utils.BindingUtils;
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class DocumentStitcherBase implements IDocumentStitcher
	{
		protected var _logger:ILogger;
		private var _record:Record;
		private var _documentTypeToStitch:String;
		private var _unstitchedRelationships:Vector.<Relationship> = new Vector.<Relationship>();
		private var _stitchedRelationships:Vector.<Relationship> = new Vector.<Relationship>();
		private var _requiredDocumentTypes:Vector.<String> = new Vector.<String>();
		private var _documentCollectionToStitch:IDocumentCollection;

		public function DocumentStitcherBase(record:Record, documentTypeToStitch:String)
		{
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			_record = record;
			_documentTypeToStitch = documentTypeToStitch;
			_documentCollectionToStitch = getDocumentCollection(documentTypeToStitch);
			addRequiredDocumentType(documentTypeToStitch);
		}

		/**
		 * Adds the specified documentType to the list of requiredDocumentTypes which are used when
		 * listenForPrerequisites() is called. Each base class should use this method in the constructor to specify
		 * all documentTypes which the documentTypeToStitch can have a relation to.
		 * @param documentType
		 */
		protected function addRequiredDocumentType(documentType:String):void
		{
			requiredDocumentTypes.push(documentType);
		}

		public function listenForPrerequisites():void
		{
			// bind to the isInitialized setter for each applicable document collection
			for each (var documentCollection:IDocumentCollection in requiredDocumentCollections)
			{
				BindingUtils.bindSetter(documentCollection_isInitializedChangeHandler, documentCollection,
										"isInitialized");
			}
		}

		private function documentCollection_isInitializedChangeHandler(value:Boolean):void
		{
			if (!documentCollectionToStitch.isStitched)
			{
				// all required document collections must be initialized before we will stitch
				for each (var documentCollection:IDocumentCollection in requiredDocumentCollections)
				{
					if (!documentCollection.isInitialized)
					{
						return;
					}
				}

				stitchAllDocuments();
			}
		}

		/**
		 * Document types (fully qualified, such as "http://indivo.org/vocab/xml/documents#MedicationFill") for which
		 * the corresponding document collections on the record must be initialized before
		 * this stitcher can stitch. Note that the primary documentType associated with this stitcher is automatically
		 * added to the requiredDocumentTypes by the constructor. Thus, for example, MedicationOrderStitcher should
		 * NOT add MedicationOrder to requiredDocumentTypes.
		 */
		protected function get requiredDocumentTypes():Vector.<String>
		{
			return _requiredDocumentTypes;
		}

		private function get requiredDocumentCollections():Vector.<IDocumentCollection>
		{
			var collections:Vector.<IDocumentCollection> = new Vector.<IDocumentCollection>();
			for each (var documentType:String in requiredDocumentTypes)
			{
				var documentCollection:IDocumentCollection = getDocumentCollection(documentType);
				collections.push(documentCollection);
			}
			return collections;
		}

		protected function getDocumentCollection(documentType:String):IDocumentCollection
		{
			var documentCollection:IDocumentCollection = record.documentCollections.getItem(documentType);
			if (!documentCollection)
				throw new Error("Failed to find document collection for type \"" + documentType + "\"");
			return documentCollection;
		}

		protected function stitchAllDocuments():void
		{
			_unstitchedRelationships = new Vector.<Relationship>();
			_stitchedRelationships = new Vector.<Relationship>();
			var documentsCollection:IDocumentCollection = record.documentCollections.getItem(documentTypeToStitch);

			if (!documentsCollection)
				throw new Error("Expected documents collection for \"" + documentTypeToStitch + "\" not found in the Record");

			for each (var document:IDocument in documentsCollection.documents)
			{
				stitchDocument(document);
			}

			_logger.info("Stitching COMPLETE for " + getShortDocumentType(documentTypeToStitch) + " documents. " +
						 "Relationships stitched/unstitched: " + stitchedRelationships.length + "/" + unstitchedRelationships.length +
						 " (" + getShortDocumentTypes(requiredDocumentTypes) + " initialized)");

			documentCollectionToStitch.isStitched = true;
		}

		private function getShortDocumentTypes(types:Vector.<String>):String
		{
			var shortTypes:Array = new Array();
			for each (var type:String in types)
			{
				shortTypes.push(getShortDocumentType(type));
			}
			return shortTypes.join(", ");
		}

		private function getShortDocumentType(documentTypeToStitch:String):String
		{
			var parts:Array = documentTypeToStitch.split("#");
			return parts[parts.length - 1];
		}

		protected function stitchDocument(document:IDocument):void
		{
			for each (var relationship:Relationship in document.relatesTo)
			{
				// ignore relationships which have not been persisted yet
				if (relationship.pendingAction != Relationship.ACTION_CREATE)
				{
					if (relationship.relatesFrom != document)
						throw new Error("Relationship.relatesFrom should already be set to the parent document when stitching");

					if (relationship.relatesTo != null)
						throw new Error("Relationship.relatesTo should be null when stitching");

					if (StringUtils.isEmpty(relationship.relatesFromId))
						throw new Error("Relationship.relatesFromId must not be null when stitching");

					if (StringUtils.isEmpty(relationship.relatesToId))
						throw new Error("Relationship.relatesToId must not be null when stitching");

					// find the document to stitch to
					var otherDocument:IDocument = record.currentDocumentsById.getItem(relationship.relatesToId);
					if (otherDocument)
					{
						relationship.relatesTo = otherDocument;
						otherDocument.isRelatedFrom.addItem(relationship);
						stitchedRelationships.push(relationship);
					}
					else
					{
						// failed to stitch
						unstitchedRelationships.push(relationship);
					}
				}
			}

			stitchSpecialReferencesOnDocument(document);
		}

		/**
		 * Sets any "special" references on the document. This method will be called by the base class for each document
		 * in the documents collection that this stitcher is associated with after performing the "standard" stitching
		 * on all of the relatesTo Relationship instances on the document. The document will have the same
		 * documentType that this stitcher is exclusively for. For example, the stitcher for MedicationOrder
		 * (MedicationOrderStitcher) should set the medicationFill to the appropriate MedicationFill document.
		 *
		 * @param document the document to stitch
		 */
		protected function stitchSpecialReferencesOnDocument(document:IDocument):void
		{
			// To be implemented by subclasses
		}

		public function get record():Record
		{
			return _record;
		}

		public function get documentTypeToStitch():String
		{
			return _documentTypeToStitch;
		}

		public function get unstitchedRelationships():Vector.<Relationship>
		{
			return _unstitchedRelationships;
		}

		public function get documentCollectionToStitch():IDocumentCollection
		{
			return _documentCollectionToStitch;
		}

		protected function logSpecialFailedStitches(parentDocument:IDocument, failedStitch:Vector.<String>,
													relationshipType:String, otherDocumentShortType:String):void
		{
			if (failedStitch.length > 0)
				_logger.warn("Warning: Failed to stitch " + failedStitch.length +
									 " " + relationshipType + " \"special\" relationship(s) on " + parentDocument.meta.shortType + " " + parentDocument.meta.id +
									 ". " + otherDocumentShortType + " not found with id(s) [" + failedStitch.join(", ") + "]");
		}

		public function get stitchedRelationships():Vector.<Relationship>
		{
			return _stitchedRelationships;
		}
	}
}
