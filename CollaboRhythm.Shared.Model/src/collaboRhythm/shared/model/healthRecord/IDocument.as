package collaboRhythm.shared.model.healthRecord
{

	import mx.collections.ArrayCollection;

	public interface IDocument extends IDocumentMetadata
	{

		/**
		 * A collection of all Relationships that are from this document and to another document.
		 */
		function get relatesTo():ArrayCollection;

		function set relatesTo(value:ArrayCollection):void;

		/**
		 * A collection of all Relationships that are from another document and to this document.
		 */
		function get isRelatedFrom():ArrayCollection;

		function set isRelatedFrom(value:ArrayCollection):void;
	}
}
