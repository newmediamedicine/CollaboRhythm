package collaboRhythm.core.model.healthRecord.service
{
	import collaboRhythm.core.model.XmlMarshaller;
	import collaboRhythm.core.model.healthRecord.Schemas;
	import collaboRhythm.shared.model.demographics.Address;
	import collaboRhythm.shared.model.demographics.Name;
	import collaboRhythm.shared.model.demographics.Telephone;
	import collaboRhythm.shared.model.healthRecord.*;

	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.Contact;
	import collaboRhythm.shared.model.demographics.Demographics;
	import collaboRhythm.shared.model.Record;

	import j2as3.collection.HashMap;

	import org.indivo.client.IndivoClientEvent;

	public class DemographicsHealthRecordService extends PhaHealthRecordServiceBase
    {
         // Indivo Api calls used in this healthRecordService
        public static const GET_DEMOGRAPHICS:String = "Get Demographics";
        public static const GET_CONTACT:String = "Get Contact";

		private var _pendingDemographics:HashMap = new HashMap();
		private var _pendingContacts:HashMap = new HashMap();
		protected var _xmlMarshaller:XmlMarshaller;

		private var _demographicsQName:QName = new QName("http://indivo.org/vocab/xml/documents#", "Demographics");

        public function DemographicsHealthRecordService(oauthChromeConsumerKey:String,
                                                         oauthChromeConsumerSecret:String, indivoServerBaseURL:String,
                                                         account:Account)
        {
            super(oauthChromeConsumerKey, oauthChromeConsumerSecret, indivoServerBaseURL, account);
			initializeXmlMarshaller();
		}

		/**
		 * Initializes the XmlMarshaller used by this service for marshalling and unmarshalling the document type
		 * that this service targets.
		 */
		protected function initializeXmlMarshaller():void
		{
			_xmlMarshaller = new XmlMarshaller();
			_xmlMarshaller.addSchema(Schemas.CodedValuesSchema);
			_xmlMarshaller.addSchema(Schemas.ValuesSchema);
			_xmlMarshaller.addSchema(Schemas.DemographicsSchema);
			_xmlMarshaller.registerClass(_demographicsQName, Demographics);
			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents#", "Name"), Name);
			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents#", "Telephone"), Telephone);
			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents#", "Address"), Address);
			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents#", "CollaboRhythmCodedValue"), CodedValue);
			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents#", "CollaboRhythmValueAndUnit"),
										 ValueAndUnit);
		}

        // get the demographics for a record
        public function getDemographics(record:Record):void
        {
			_pendingDemographics.put(record.id, record);
			_pendingContacts.put(record.id, record);

            var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_DEMOGRAPHICS,
					null, record);
            _pha.special_demographicsGET(null, null, null, record.id, _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
            healthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_CONTACT, null, record);
            _pha.special_contactGET(null, null, null, record.id, _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
        }

        protected override function handleResponse(event:IndivoClientEvent, responseXml:XML, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
            if (healthRecordServiceRequestDetails.indivoApiCall == GET_DEMOGRAPHICS)
			{
				healthRecordServiceRequestDetails.record.demographics = _xmlMarshaller.unmarshallXml(responseXml, _demographicsQName) as Demographics;
			}
            else if (healthRecordServiceRequestDetails.indivoApiCall == GET_CONTACT)
			{
				healthRecordServiceRequestDetails.record.contact = new Contact(responseXml);
			}

			handleFinishedRequest(healthRecordServiceRequestDetails, event);
        }

		override protected function handleError(event:IndivoClientEvent, errorStatus:String,
												healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):Boolean
		{
			// TODO: only ignore 404 Not Found error (which will happen if the record has no Demographics); otherwise dispatch an error
			if (super.handleError(event, errorStatus, healthRecordServiceRequestDetails))
				return true;
			else
			{
				handleFinishedRequest(healthRecordServiceRequestDetails, event);
				return false;
			}
		}

		private function handleFinishedRequest(healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails,
											   indivoClientEvent:IndivoClientEvent):void
		{
			if (healthRecordServiceRequestDetails.indivoApiCall == GET_DEMOGRAPHICS)
			{
				_pendingDemographics.remove(healthRecordServiceRequestDetails.record.id);
			}
			else if (healthRecordServiceRequestDetails.indivoApiCall == GET_CONTACT)
			{
				_pendingContacts.remove(healthRecordServiceRequestDetails.record.id);
			}

			checkComplete(indivoClientEvent);
		}

		private function checkComplete(indivoClientEvent:IndivoClientEvent):void
		{
			if (_pendingContacts.size() == 0 && _pendingDemographics.size() == 0)
			{
				dispatchEvent(new HealthRecordServiceEvent(HealthRecordServiceEvent.COMPLETE, indivoClientEvent));
			}
		}
    }
}
