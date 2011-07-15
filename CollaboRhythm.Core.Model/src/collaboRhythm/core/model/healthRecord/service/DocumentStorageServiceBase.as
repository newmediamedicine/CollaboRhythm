package collaboRhythm.core.model.healthRecord.service
{

	import collaboRhythm.core.model.healthRecord.RelationshipXmlMarshaller;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceRequestDetails;
	import collaboRhythm.shared.model.healthRecord.PhaHealthRecordServiceBase;

	import flash.events.Event;

	import org.indivo.client.IndivoClientEvent;

	/**
	 * Event that is dispatched when the isLoading property changes.
	 */
	[Event("isLoadingChange")]

	/**
	 * Base class for implementing a document storage service, responsible for loading and persisting health record
	 * documents of a particular type (one service per type).
	 */
	public class DocumentStorageServiceBase extends PhaHealthRecordServiceBase
	{
		/**
		 * Event that is dispatched when the isLoading property changes.
		 */
		public static const IS_LOADING_CHANGE_EVENT:String = "isLoadingChange";
		private var _isLoading:Boolean;
		protected var _relationshipXmlMarshaller:RelationshipXmlMarshaller;

		public function DocumentStorageServiceBase(consumerKey:String, consumerSecret:String, baseURL:String, account:Account)
		{
			super(consumerKey, consumerSecret, baseURL, account);
		}

		[Bindable(event="isLoadingChange")]
		public function get isLoading():Boolean
		{
			return _isLoading;
		}

		public function set isLoading(value:Boolean):void
		{
			_isLoading = value;
			dispatchEvent(new Event(IS_LOADING_CHANGE_EVENT));
		}

		/**
		 * Loads all documents of the type supported by this service into the specified record.
		 * Subclasses should override and extend this to implement loading of the particular document type supported.
		 *
		 * @param record the record in which to load documents
		 */
		public function loadDocuments(record:Record):void
		{
			isLoading = true;
			_relationshipXmlMarshaller = new RelationshipXmlMarshaller();
			_relationshipXmlMarshaller.record = record;
		}

		override protected function handleResponse(event:IndivoClientEvent, responseXml:XML,
												   healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			super.handleResponse(event, responseXml, healthRecordServiceRequestDetails);
			isLoading = false;
		}

		override protected function handleError(event:IndivoClientEvent, errorStatus:String,
												healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):Boolean
		{
			var isRetrying:Boolean = super.handleError(event, errorStatus, healthRecordServiceRequestDetails);
			if (!isRetrying)
				isLoading = false;
			return isRetrying;
		}
	}
}
