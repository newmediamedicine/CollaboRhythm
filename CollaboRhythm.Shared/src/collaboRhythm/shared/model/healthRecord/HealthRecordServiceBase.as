package collaboRhythm.shared.model.healthRecord
{

    import collaboRhythm.shared.model.Account;
    import collaboRhythm.shared.model.services.ICurrentDateSource;
    import collaboRhythm.shared.model.services.WorkstationKernel;

    import flash.events.EventDispatcher;

    import flash.utils.getQualifiedClassName;

    import mx.logging.ILogger;
    import mx.logging.Log;

    import org.indivo.client.IndivoClientEvent;

    public class HealthRecordServiceBase extends EventDispatcher
    {
        protected var _logger:ILogger;
        protected var _activeAccount:Account;
        protected var _currentDateSource:ICurrentDateSource;

        public function HealthRecordServiceBase(oauthConsumerKey:String, oauthConsumerSecret:String, indivoServerBaseURL:String, account:Account)
        {
            _logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
            _activeAccount = account;
            _currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
        }

        public function indivoClientEventHandler(event:IndivoClientEvent):void
        {
            var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = event.userData as HealthRecordServiceRequestDetails;
            if (event.type == IndivoClientEvent.COMPLETE)
            {
                var responseXml:XML = event.response;

                // TODO: what if responseXml is null
                if (responseXml != null)
                {
                    handleResponse(event, responseXml, healthRecordServiceRequestDetails);
                }
                else
                {
                    handleError(event, errorStatus, healthRecordServiceRequestDetails);
                }
            }
            else
            {
                var innerError:XMLList = event.response.InnerError;
                var errorStatus:String;

                if (innerError != null)
                {
                    errorStatus = innerError.text;
                }
                else
                {
                    errorStatus = "Undefined error occurred."
                }

                handleError(event, errorStatus, healthRecordServiceRequestDetails);
            }
        }

        /**
         * Virtual method which subclasses should override in order to handle the asynchronous response to a request.
         *
         * @param event
         * @param responseXml
         *
         */
        protected function handleResponse(event:IndivoClientEvent, responseXml:XML, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
            // Base class does nothing. Subclasses should override.
        }

        /**
         * Virtual method which subclasses should override in order to handle the asynchronous error response to a request.
         *
         * @param event
         * @param errorStatus
         *
         */
        protected function handleError(event:IndivoClientEvent, errorStatus:String, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
            // Base class does nothing. Subclasses should override.
            _logger.info("Unhandled IndivoClientEvent error: " + errorStatus);
        }
    }
}