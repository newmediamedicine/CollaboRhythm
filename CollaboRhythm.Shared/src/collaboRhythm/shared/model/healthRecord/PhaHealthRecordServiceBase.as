package collaboRhythm.shared.model.healthRecord
{
    import collaboRhythm.shared.model.Account;

    import org.indivo.client.IndivoClientEvent;
    import org.indivo.client.Pha;

    public class PhaHealthRecordServiceBase extends HealthRecordServiceBase
    {
        protected var _pha:Pha;

        public function PhaHealthRecordServiceBase(oauthPhaConsumerKey:String, oauthPhaConsumerSecret:String,
                                                   indivoServerBaseURL:String, account:Account)
        {
            super(oauthPhaConsumerKey, oauthPhaConsumerSecret, indivoServerBaseURL, account);

            _pha = new Pha(oauthPhaConsumerKey, oauthPhaConsumerSecret, indivoServerBaseURL);
            _pha.addEventListener(IndivoClientEvent.COMPLETE, indivoClientEventHandler);
            _pha.addEventListener(IndivoClientEvent.ERROR, indivoClientEventHandler)
        }

//        protected override function handleResponse(event:IndivoClientEvent, responseXml:XML, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
//        {
//            _pha.dispatchEvent(new HealthRecordServiceEvent(healthRecordServiceRequestDetails.healthRecordServiceCompleteEventType, null, null, healthRecordServiceRequestDetails, responseXml));
//        }
//
//        protected override function handleError(event:IndivoClientEvent, errorStatus:String, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
//        {
//            _pha.dispatchEvent(new HealthRecordServiceEvent(healthRecordServiceRequestDetails.healthRecordServiceErrorEventType, null, null, healthRecordServiceRequestDetails, null, errorStatus));
//        }
//        		private function addPendingRequest(requestType:String, id:String):void
//		{
//			var key:String = getPendingRequestKey(requestType, id);
//			if (_pendingRequests.keys.contains(key))
//			{
//				throw new Error("request with matching key is already pending: " + key);
//			}
//
//			_pendingRequests.put(key, key);
//		}
//
//		private function removePendingRequest(requestType:String, id:String):void
//		{
//			var key:String = getPendingRequestKey(requestType, id);
//			if (_pendingRequests.keys.contains(key))
//			{
//				_pendingRequests.remove(key);
//				if (_pendingRequests.size() == 0)
//					this.dispatchEvent(new HealthRecordServiceEvent(HealthRecordServiceEvent.COMPLETE));
//			}
//		}
//
//		private function getPendingRequestKey(requestType:String, id:String):String
//		{
//			return requestType + " " + id;
//		}
    }
}
