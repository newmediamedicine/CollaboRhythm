package collaboRhythm.shared.model.healthRecord
{

	import mx.collections.ArrayCollection;

	public interface IDocument
	{
		/**
		 * Metadata associated with the document.
		 */
		function get meta():IDocumentMetadata;

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

		/**
		 * Action for the document which has not been persisted to the server.
		 */
		function get pendingAction():String;

		function set pendingAction(value:String):void;

		/**
		 * Reason for voiding or archiving
		 */
		function get pendingActionReason():String;

		function set pendingActionReason(value:String):void;
	}
}
