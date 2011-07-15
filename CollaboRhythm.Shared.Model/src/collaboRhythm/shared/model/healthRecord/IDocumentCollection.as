package collaboRhythm.shared.model.healthRecord
{

	import mx.collections.ArrayCollection;

	public interface IDocumentCollection
	{
		/**
		 * The collection of documents (implementing IDocument). The documents will all be of type documentType
		 */
		function get documents():ArrayCollection;

		/**
		 * The fully qualified type of the document from the health record which this collection class supports, such as
		 * "http://indivo.org/vocab/xml/documents#MedicationAdministration".
		 */
		function get documentType():String;

		function get isInitialized():Boolean;

		function set isInitialized(value:Boolean):void;

		function get isStitched():Boolean;

		function set isStitched(value:Boolean):void;
	}
}
