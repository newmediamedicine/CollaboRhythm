package collaboRhythm.shared.model.healthRecord.document.xml
{

	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;

	/**
	 * Responsible for converting AdherenceItem instances to/from XML.
	 */
	public interface IAdherenceItemXmlMarshaller
	{
		function initFromReportXML(adherenceItemReportXML:XML, adherenceItem:AdherenceItem):void;

		function convertToXML(adherenceItem:AdherenceItem):XML;
	}
}
