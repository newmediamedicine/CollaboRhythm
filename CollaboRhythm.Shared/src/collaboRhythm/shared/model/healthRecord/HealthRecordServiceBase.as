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
		protected static var httpStatusCodeUtil:HttpStatusCodeUtil = new HttpStatusCodeUtil();

        protected var _logger:ILogger;
        protected var _activeAccount:Account;
        protected var _currentDateSource:ICurrentDateSource;

		protected const MAX_FAILED_ATTEMPTS:int = 3;

		private var _automaticRetryEnabled:Boolean = true;
		private static const STREAM_ERROR_ID:int = 2032;

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
					_logger.info("Indivo response COMPLETE from {1} {2} ({0} bytes)", event.response.toString().length, event.urlRequest.method, event.relativePath);
                    handleResponse(event, responseXml, healthRecordServiceRequestDetails);
                }
                else
                {
                    handleError(event, "Complete event has no response data", healthRecordServiceRequestDetails);
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
         * Handles the asynchronous error response to a request by retrying (if automaticRetryEnabled).
         *
         * @param event
         * @param errorStatus
         * @returns true if the error handler is retrying the request (asynchronously); false otherwise. Subclasses should generally
		 * call super.handleError() and should ignore the error if the super class is retrying the request.
         */
        protected function handleError(event:IndivoClientEvent, errorStatus:String, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):Boolean
        {
			var errorDescriptionParts:Array = new Array();

			if (event.httpStatusEvent && event.httpStatusEvent.status != 0)
			{
				errorDescriptionParts.push(event.httpStatusEvent.status);
				var shortDescription:String = httpStatusCodeUtil.getShortDescription(event.httpStatusEvent.status);
				errorDescriptionParts.push(shortDescription ? shortDescription : "(unknown status)");
			}

			if (event.errorEvent)
			{
				errorDescriptionParts.push("{" + event.errorEvent.type + "}");
				errorDescriptionParts.push(event.errorEvent.errorID);
				errorDescriptionParts.push(event.errorEvent.text);
			}

			_logger.warn("Indivo response ERROR {0} from {1} {2}", errorDescriptionParts.join(" "), event.urlRequest.method, event.relativePath);
			return handleErrorWithRetry(healthRecordServiceRequestDetails, event);
        }

		protected function handleErrorWithRetry(healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails,
												event:IndivoClientEvent):Boolean
		{
			if (automaticRetryEnabled && shouldRetry(event))
			{
				if (healthRecordServiceRequestDetails == null)
					healthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails();
				healthRecordServiceRequestDetails.failedAttempts++;
				if (healthRecordServiceRequestDetails.failedAttempts < MAX_FAILED_ATTEMPTS)
				{
					_logger.warn("Failed attempt(s): {0}. Retrying...",
								 healthRecordServiceRequestDetails.failedAttempts);
					retryFailedRequest(event, healthRecordServiceRequestDetails);
					return true;
				}
				else
				{
					_logger.warn("Failed attempt(s): {0}. Giving up.",
								 healthRecordServiceRequestDetails.failedAttempts);
					return false;
				}
			}
			return false;
		}

		private function shouldRetry(event:IndivoClientEvent):Boolean
		{
			return (event.type == IndivoClientEvent.ERROR && event.errorEvent && event.errorEvent.errorID == STREAM_ERROR_ID);
		}

		protected function retryFailedRequest(event:IndivoClientEvent,
											  healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			// subclasses must override to implement retry
		}

		/**
		 * If true, each failed request will automatically be retried multiple times. Otherwise, when a request fails
		 * it there will not be any additional automatic attempts to complete the request.
		 */
		public function get automaticRetryEnabled():Boolean
		{
			return _automaticRetryEnabled;
		}

		public function set automaticRetryEnabled(value:Boolean):void
		{
			_automaticRetryEnabled = value;
		}
	}
}