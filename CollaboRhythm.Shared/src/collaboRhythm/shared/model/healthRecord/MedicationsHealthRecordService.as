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
    import collaboRhythm.shared.model.Record;

    import org.indivo.client.IndivoClientEvent;

    public class MedicationsHealthRecordService extends PhaHealthRecordServiceBase
	{
        // Indivo Api calls used in this healthRecordService
        public static const GET_MEDICATIONORDERS_REPORT:String = "Get MedicationOrders Report";
        public static const GET_MEDICATIONSCHEDULEITEMS_REPORT:String = "Get MedicationScheduleItems Report";
        public static const GET_MEDICATIONADMINISTRATIONS_REPORT:String = "Get MedicationAdministrations Report";
        public static const GET_MEDICATIONFILLS_REPORT:String = "Get MedicationFills Report";

        private var _apiCallsCompleted:int;
        	
		public function MedicationsHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String, account:Account)
		{
			super(consumerKey, consumerSecret, baseURL, account);
		}

        public function getMedications(record:Record):void
        {
            _apiCallsCompleted = 0;

            var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_MEDICATIONORDERS_REPORT, null, record);
            _pha.reports_minimal_X_GET(null, null, null, null, record.id, "medicationorders", _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
            healthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_MEDICATIONSCHEDULEITEMS_REPORT, null, record);
            _pha.reports_minimal_X_GET(null, null, null, null, record.id, "medicationscheduleitems", _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
            healthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_MEDICATIONADMINISTRATIONS_REPORT, null, record);
            _pha.reports_minimal_X_GET(null, null, null, null, record.id, "medicationadministrations", _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
            healthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_MEDICATIONFILLS_REPORT, null, record);
            _pha.reports_minimal_X_GET(null, null, null, null, record.id, "medicationfills", _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
        }

        protected override function handleResponse(event:IndivoClientEvent, responseXml:XML, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
            _apiCallsCompleted += 1;

//            if (healthRecordServiceRequestDetails.indivoApiCall == GET_MEDICATIONORDERS_REPORT)
//            {
//                // TODO: Fix once the report is working
//                healthRecordServiceRequestDetails.record.medicationsModel.medicationOrdersReportXml = responseXml;
//            }
//            else if (healthRecordServiceRequestDetails.indivoApiCall == GET_MEDICATIONSCHEDULEITEMS_REPORT)
//            {
//                healthRecordServiceRequestDetails.record.medicationsModel.medicationScheduleItemsReportXml = responseXml;
//            }
//            else if (healthRecordServiceRequestDetails.indivoApiCall == GET_MEDICATIONADMINISTRATIONS_REPORT)
//            {
//                healthRecordServiceRequestDetails.record.medicationsModel.medicationAdministrationsReportXml = responseXml;
//            }
//            else if (healthRecordServiceRequestDetails.indivoApiCall == GET_MEDICATIONFILLS_REPORT)
//            {
//                healthRecordServiceRequestDetails.record.medicationsModel.medicationFillsReportXml = responseXml;
//            }

            if (_apiCallsCompleted == 4)
            {
                dispatchEvent(new HealthRecordServiceEvent(HealthRecordServiceEvent.COMPLETE));
            }
        }
	}
}