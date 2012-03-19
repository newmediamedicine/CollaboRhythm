/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
 * version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
package collaboRhythm.shared.model.healthRecord
{
	import collaboRhythm.shared.model.Account;

	import flash.events.Event;

	import org.indivo.client.IndivoClientEvent;

	public class HealthRecordServiceEvent extends Event
    {
        /**
         * Indicates that the login operation has completed successfully.
         */
        public static const LOGIN_SUCCEEDED:String = "Succeeded";

		/**
		 * Indicates that the primary operation of the service has completed unsuccessfully.
		 */
		public static const FAILED:String = "Failed";

        /**
         * Indicates that the primary operation of the service has completed successfully.
         */
        public static const COMPLETE:String = "complete";

        /**
         * Indicates that an individual operation of the service has completed successfully. More updates and errors
		 * may occur before the primary operation is complete (or failed).
         */
        public static const UPDATE:String = "update";

		/**
		 * Indicates that an individual operation of the service has resulted in an error. More updates and errors
		 * may occur before the primary operation is complete (or failed).
		 */
        public static const ERROR:String = "error";

        private var _account:Account;
        private var _healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails;
        private var _responseXml:XML;
        private var _errorStatus:String;
		private var _indivoClientEvent:IndivoClientEvent;

        public function HealthRecordServiceEvent(type:String, indivoClientEvent:IndivoClientEvent = null,
												 account:Account = null,
												 healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = null,
												 responseXml:XML = null, errorStatus:String = null,
												 bubbles:Boolean = false, cancelable:Boolean = false)
        {
            super(type, bubbles, cancelable);
            _indivoClientEvent = indivoClientEvent;
            _account = account;
            _healthRecordServiceRequestDetails = healthRecordServiceRequestDetails;
            _responseXml = responseXml;
            _errorStatus = errorStatus;
        }

        /**
         * The account associated with the event, if applicable (Optional)
         * @return the String, or null if not applicable
         *
         */
        public function get account():Account
        {
            return _account;
        }

        public function set account(value:Account):void
        {
            _account = value;
        }

        public function get healthRecordServiceRequestDetails():HealthRecordServiceRequestDetails
        {
            return _healthRecordServiceRequestDetails;
        }

        public function get responseXml():XML
        {
            return _responseXml;
        }

        public function get errorStatus():String
        {
            return _errorStatus;
        }

        public function set errorStatus(value:String):void
        {
            _errorStatus = value;
        }

		public function get indivoClientEvent():IndivoClientEvent
		{
			return _indivoClientEvent;
		}

		public function set indivoClientEvent(value:IndivoClientEvent):void
		{
			_indivoClientEvent = value;
		}
	}
}