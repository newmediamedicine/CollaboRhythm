package collaboRhythm.core.model.healthRecord
{

	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.IDocument;
	import collaboRhythm.shared.model.healthRecord.Relationship;

	public class RelationshipXmlMarshaller
	{
		private var _record:Record;

		public function RelationshipXmlMarshaller()
		{
		}

		public function get record():Record
		{
			return _record;
		}

		public function set record(value:Record):void
		{
			_record = value;
		}

		public function unmarshallRelationships(reportXml:XML, document:IDocument):void
		{
			default xml namespace = "http://indivo.org/vocab/xml/documents#";
			unmarshallRelationshipsFromMetadata(reportXml.Meta.Document[0], document);
		}

		public function unmarshallRelationshipsFromMetadata(metadataXml:XML, document:IDocument):void
		{
			default xml namespace = "http://indivo.org/vocab/xml/documents#";
			for each (var relationXml:XML in metadataXml.relatesTo.relation)
			{
				var type:String = relationXml.@type;
				for each (var relatedDocumentXml:XML in relationXml.relatedDocument)
				{
					var relationship:Relationship = new Relationship();
					relationship.type = type;
					relationship.relatesFrom = document;
					relationship.relatesFromId = document.meta.id;
					relationship.relatesToId = relatedDocumentXml.@id;
					document.relatesTo.addItem(relationship);
				}
			}
		}
	}
}
