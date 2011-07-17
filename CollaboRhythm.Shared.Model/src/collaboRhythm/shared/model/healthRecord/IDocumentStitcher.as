package collaboRhythm.shared.model.healthRecord
{

	/**
	 * A stitcher is responsible for setting references on documents and document relationships that correspond to the
	 * relationships defined in the health record.
	 *
	 * @see IDocument
	 * @see Relationship
	 */
	public interface IDocumentStitcher
	{
		/**
		 * Adds listeners on the appropriate model classes (document collections) to detect when the prerequisites for
		 * stitching are complete. When the prerequisites are met, stitching will be completed automatically.
		 */
		function listenForPrerequisites():void;
	}
}
