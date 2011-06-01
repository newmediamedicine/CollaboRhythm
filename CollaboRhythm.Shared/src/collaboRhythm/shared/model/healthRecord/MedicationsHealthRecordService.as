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
//            healthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_MEDICATIONADMINISTRATIONS_REPORT, null, record);
//            _pha.reports_minimal_X_GET(null, null, null, null, record.id, "medicationadministrations", _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
//            healthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_MEDICATIONFILLS_REPORT, null, record);
//            _pha.reports_minimal_X_GET(null, null, null, null, record.id, "medicationfills", _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
        }

        protected override function handleResponse(event:IndivoClientEvent, responseXml:XML, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
            _apiCallsCompleted += 1;

            if (healthRecordServiceRequestDetails.indivoApiCall == GET_MEDICATIONORDERS_REPORT)
            {
                // TODO: Fix once the report is working
                healthRecordServiceRequestDetails.record.medicationsModel.medicationOrdersReportXml = _fakeMedicationOrdersReportXml;
            }
            else if (healthRecordServiceRequestDetails.indivoApiCall == GET_MEDICATIONSCHEDULEITEMS_REPORT)
            {
                healthRecordServiceRequestDetails.record.medicationsModel.medicationScheduleItemsReportXml = responseXml;
            }
            else if (healthRecordServiceRequestDetails.indivoApiCall == GET_MEDICATIONADMINISTRATIONS_REPORT)
            {
                healthRecordServiceRequestDetails.record.medicationsModel.medicationAdministrationsReportXml = responseXml;
            }
            else if (healthRecordServiceRequestDetails.indivoApiCall == GET_MEDICATIONFILLS_REPORT)
            {
                healthRecordServiceRequestDetails.record.medicationsModel.medicationFillsReportXml = responseXml;
            }

            if (_apiCallsCompleted == 2)
            {
                dispatchEvent(new HealthRecordServiceEvent(HealthRecordServiceEvent.COMPLETE));
            }
        }

        private var _fakeMedicationOrdersReportXml:XML = <Reports>
  <Summary total_document_count="2" limit="100" offset="0" order_by="-created_at"/>
  <Report>
    <Meta>
      <Document id="2fffda4e-5b39-4703-b044-6468c66efa05" type="http://indivo.org/vocab/xml/documents#Medication" size="908" digest="0bf5cd51c9c3db6183a6bea43fe4aad4a048f7d426f30b2165a7ce1ee26f8f3f" record_id=" 6d4d246f-b518-4d03-a353-07b2f84f65ca">
        <createdAt>
          2011-02-16T22:20:35Z
        </createdAt>
        <creator id="gwhite@records.media.mit.edu" type="Account">
          <fullname>
            George White
          </fullname>
        </creator>
        <original id="2fffda4e-5b39-4703-b044-6468c66efa05"/>
        <latest id="2fffda4e-5b39-4703-b044-6468c66efa05" createdAt="2011-02-16T22:20:35Z" createdBy="gwhite@records.media.mit.edu"/>
        <status>
          active
        </status>
        <nevershare>
          false
        </nevershare>
        <relatesTo>
          <relation type="http://indivo.org/vocab/documentrels#medicationFill" count="1">
            <relatedDocument id="224a12fb-14b4-48bb-a71a-9db2742354gh"/>
          </relation>
    <relation type="http://indivo.org/vocab/documentrels#scheduleItem" count="1">
            <relatedDocument id="1678dbac-3ba8-4de8-9d22-d702a0d79352"/>
          </relation>
        </relatesTo>
      </Document>
    </Meta>
    <Item>
      <MedicationOrder junk="http://indivo.org/vocab/xml/documents#">
        <name type="http://rxnav.nlm.nih.gov/REST/rxcui/" value="617320">
          Atorvastatin 40 MG Oral Tablet [Lipitor]
        </name>
        <orderType>
          prescribed
        </orderType>
        <orderedBy>
          jking@records.media.mit.edu
        </orderedBy>
        <dateOrdered>
          2011-02-14T09:00:00-04:00
        </dateOrdered>
        <dateExpires>
          2011-05-14T09:00:00-04:00
        </dateExpires>
        <indication>
          elevated LDL cholesterol
        </indication>
        <amountOrdered>
          <value>
            30
          </value>
          <unit type="http://indivo.org/codes/units#" value="tab" abbrev="tab">
            tablet
          </unit>
        </amountOrdered>
        <substitutionPermitted>
          true
        </substitutionPermitted>
        <instructions>
          take in the evening for maximum benefit
        </instructions>
      </MedicationOrder>
    </Item>
  </Report>
  <Report>
    <Meta>
      <Document id="79bd9d8d-9948-43dc-9a6b-4327ae083da7" type="http://indivo.org/vocab/xml/documents#Medication" size="905" digest="2564baadd4916203cf972213c375d894842dc793ebfe01b7a138c7d4a96cd41e" record_id="6d4d246f-b518-4d03-a353-07b2f84f65ca">
        <createdAt>
          2011-02-16T22:20:59Z
        </createdAt>
        <creator id="gwhite@records.media.mit.edu" type="Account">
          <fullname>
            George White
          </fullname>
        </creator>
        <original id="79bd9d8d-9948-43dc-9a6b-4327ae083da7"/>
        <latest id="79bd9d8d-9948-43dc-9a6b-4327ae083da7" createdAt="2011-02-16T22:20:59Z" createdBy="gwhite@records.media.mit.edu"/>
        <status>
          active
        </status>
        <nevershare>
          false
        </nevershare>
        <relatesTo>
          <relation type="http://indivo.org/vocab/documentrels#medicationFill" count="1">
            <relatedDocument id="975a12fb-14b4-48bb-a71a-9db2742354ha"/>
          </relation>
    <relation type="http://indivo.org/vocab/documentrels#scheduleItem" count="1">
            <relatedDocument id="ffa5d028-56ad-438f-afe9-cec601927e38"/>
          </relation>
        </relatesTo>
      </Document>
    </Meta>
    <Item>
      <MedicationOrder junk="http://indivo.org/vocab/xml/documents#">
        <name type="http://rxnav.nlm.nih.gov/REST/rxcui/" value="310798">
          Hydrochlorothiazide 25 MG Oral Tablet
        </name>
        <orderType>
          prescribed
        </orderType>
        <orderedBy>
          jking@records.media.mit.edu
        </orderedBy>
        <dateOrdered>
          2011-02-14T09:00:00-04:00
        </dateOrdered>
        <dateExpires>
          2011-05-14T09:00:00-04:00
        </dateExpires>
        <indication>
          hypertension
        </indication>
        <amountOrdered>
          <value>
            30
          </value>
          <unit type="http://indivo.org/codes/units#" value="tab" abbrev="tab">
            tablet
          </unit>
        </amountOrdered>
        <substitutionPermitted>
          true
        </substitutionPermitted>
        <instructions>
          take with water
        </instructions>
      </MedicationOrder>
    </Item>
  </Report>
</Reports>

	}
}