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
package collaboRhythm.plugins.medications.model
{
	import collaboRhythm.plugins.schedule.shared.model.ScheduleModel;
	import collaboRhythm.shared.model.ReportRequestDetails;
	import collaboRhythm.shared.model.HealthRecordServiceBase;
	import collaboRhythm.shared.model.User;
	import collaboRhythm.shared.model.UsersModel;
	
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import org.indivo.client.IndivoClientEvent;
	
	public class MedicationsHealthRecordService extends HealthRecordServiceBase
	{
		private var _numMedicationDocuments:Number;		
		private var _currentMedicationDocument:Number;
		private var _medicationsModel:MedicationsModel;
		
		public function MedicationsHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String)
		{
			super(consumerKey, consumerSecret, baseURL);
		}
		
		public function loadAllMedications(remoteUserModel:UsersModel):void
		{
			for each (var user:User in remoteUserModel.remoteUsers)
			{
				loadMedications(user);
			}
			loadMedications(remoteUserModel.localUser);
		}
		
		private function getMedicationsModel(user:User):MedicationsModel
		{
			if (user != null)
			{
				if (user.appData[MedicationsModel.MEDICATIONS_KEY] == null)
				{
					user.appData[MedicationsModel.MEDICATIONS_KEY] = new MedicationsModel(user);
				}
				return user.getAppData(MedicationsModel.MEDICATIONS_KEY, MedicationsModel) as MedicationsModel;
			}
			return null;
		}
		
		public function loadMedications(user:User):void
		{			
			var params:URLVariables = new URLVariables();
//			params["order_by"] = "-date_onset";
			
			// now the user already had an empty MedicationsModel when created, and a variable called initialized is used to see if it has been populated, allowing for early binding -- start with an empty MedicationsModel so that views can bind to the instance before the data is finished loading
			//			user.medicationsModel = new MedicationsModel();
			if (user.recordId != null && accessKey != null && accessSecret != null)
			{
//				TODO: currently this is a hack imitating the medications report that we want to implement
//				_pha.reports_minimal_X_GET(params, null, null, null, user.recordId, "medications", accessKey, accessSecret, new DocumentRequestDetails(user, "medications"));
				handleMedicationsReport(user, getMedicationsModel(user), medicationsReportXml);
			}	
		}
		
		private function handleMedicationsReport(user:User, medicationsModel:MedicationsModel, responseXML:XML):void
		{
			medicationsModel.medicationsReportXML = responseXML;
			
//			TODO: currently this is a hack imitating the medicationScheduleItems report that we want to implement			
//			_pha.reports_minimal_X_GET(params, null, null, null, user.recordId, "medicationScheduleItems", accessKey, accessSecret, new DocumentRequestDetails(user, "medicationScheduleItems"));
			handleMedicationScheduleItemsReport(user, medicationsModel, medicationScheduleItemsXml);
		}
		
		private function handleMedicationScheduleItemsReport(user:User, medicationsModel:MedicationsModel, responseXML:XML):void
		{
			medicationsModel.medicationScheduleItemsReportXML = responseXML;
		}
		
		protected override function handleResponse(event:IndivoClientEvent, responseXML:XML):void
		{
			var user:User = event.userData.user as User;
			var medicationsModel:MedicationsModel = getMedicationsModel(user);

			if (responseXML.name() == "Reports")
			{
				if (event.userData.reportType == "medications")
				{
					handleMedicationsReport(user, medicationsModel, responseXML);
				}
				else if (event.userData.reportType == "medicationScheduleItems")
				{
					handleMedicationScheduleItemsReport(user, medicationsModel, responseXML);
				}
			}
//			if (responseXml.name() == "Documents")
//			{			
//				user = event.userData as User;
//				if (user == null)
//					throw new Error("userData must be a User object");
//				
//				if (responseXml.Document.length() > 0)
//				{
//					_currentMedicationDocument = 0;
//					_numMedicationDocuments = responseXml.Document.length();
//					
//					if (responseXml.Document[0].attribute("id").length() != 1)
//						throw new Error("Document does not have expected id attribute");
//					
//					for each (var responseDocument:XML in responseXml.Document)
//					{
//						_pha.documents_XGET(null, null, null, user.recordId, responseDocument.@id.toString(), accessKey, accessSecret, new DocumentRequestDetails(user, responseDocument.@id.toString()));
//					}
//				}
//			}
//			else if (responseXml.name() == "Medication")
//			{
//				user = event.userData.user as User;
//				if (user == null)
//					throw new Error("userData must be a User object");
//
//				medicationsModel = getMedicationsModel(user);
//				medicationsModel.addMedication(event.userData.documentID, responseXml);
//				
//				_currentMedicationDocument += 1;
//				if (_currentMedicationDocument == _numMedicationDocuments - 1)
//				{
//					medicationsModel.initialized = true;
//				}
//			}
//			else if (responseXml.name() == "MedicationScheduleItem")
//			{
//				user = event.userData.user as User;
//				if (user == null)
//					throw new Error("userData must be a User object");
//
//				medicationsModel = getMedicationsModel(user);
//				medicationsModel.addMedicationScheduleItem(event.userData.documentID, responseXml);
//				
//				_pha.removeEventListener(IndivoClientEvent.COMPLETE, indivoClientEventHandler);
//				_pha.removeEventListener(IndivoClientEvent.ERROR, indivoClientEventHandler);
//				
//				_pha.addEventListener(IndivoClientEvent.COMPLETE, relationshipsEventHandler);
//				_pha.addEventListener(IndivoClientEvent.ERROR, relationshipsEventHandler);
//				
//				_pha.documents_X_rels_X_GET(null, null, null, null, user.recordId, responseXml.@id.toString(), "scheduledAction", accessKey, accessSecret, new DocumentRequestDetails(user, responseXml.@id.toString()));
//				
//				_currentMedicationDocument += 1;
//				if (_currentMedicationDocument == _numMedicationDocuments - 1)
//				{
//					medicationsModel.initialized = true;
//				}
//			}
			else
			{
				throw new Error("Unhandled response data: " + responseXML.name() + " " + responseXML);
			}
		}
		
		private var medicationsReportXml:XML = <Reports>
  <Summary total_document_count="2" limit="100" offset="0" order_by="-created_at"/>
<Report>
    <Meta>
      <Document id="2fffda4e-5b39-4703-b044-6468c66efa05" type="http://indivo.org/vocab/xml/documents#Medication" size="908" digest="0bf5cd51c9c3db6183a6bea43fe4aad4a048f7d426f30b2165a7ce1ee26f8f3f" record_id=" 6d4d246f-b518-4d03-a353-07b2f84f65ca">
        <createdAt>2011-02-16T22:20:35Z</createdAt>
        <creator id="gwhite@records.media.mit.edu" type="Account">
          <fullname>George White</fullname>
        </creator>
        <original id="2fffda4e-5b39-4703-b044-6468c66efa05"/>
        <latest id="2fffda4e-5b39-4703-b044-6468c66efa05" createdAt="2011-02-16T22:20:35Z" createdBy="gwhite@records.media.mit.edu"/>
        <status>active</status>
        <nevershare>false</nevershare>
        <isRelatedFrom>
               <relation type="http://indivo.org/vocab/documentrels#scheduledAction" count="1">
<relatedDocument id="138a12fb-14b4-48bb-a71a-9db2742354ce"/>
               </relation>
        </isRelatedFrom>	
      </Document>
    </Meta>
    <Item>
      <Medication junk="http://indivo.org/vocab/xml/documents#">
  <name type="http://rxnav.nlm.nih.gov/REST/rxcui/" value="617320">Atorvastatin 40 MG Oral Tablet [Lipitor]</name>
  <orderType>prescribed</orderType>
  <orderedBy>jking@records.media.mit.edu</orderedBy>
  <dateTimeOrdered>2011-02-14T09:00:00-04:00</dateTimeOrdered>
  <dateTimeExpiration>2011-05-14T09:00:00-04:00</dateTimeExpiration>
  <indication>elevated LDL cholesterol</indication>
  <activeIngredients>
    <activeIngredient>
      <name type="http://rxnav.nlm.nih.gov/REST/rxcui/" value="83367">atorvastatin</name>
      <strength>
        <value>40</value>
        <unit type="http://indivo.org/codes/units#" value="mg" abbrev="mg">milligram</unit>
      </strength>
    </activeIngredient>
  </activeIngredients>
  <dose>
    <value>1</value>
    <unit type="http://indivo.org/codes/units#" value="tab" abbrev="tab">tablet</unit>
  </dose>
  <form type="http://indivo.org/codes/form#" value="tab" abbrev="tab">tablet</form>
  <route type="http://indivo.org/codes/routes#" value="PO" abbrev="PO">by mouth</route>
  <frequency type="http://indivo.org/codes/frequency#" value="qd" abbrev="qd">once a day</frequency>
  <amountOrdered>
    <value>30</value>
    <unit type="http://indivo.org/codes/units#" value="tab" abbrev="tab">tablet</unit>
  </amountOrdered>
  <refills>3</refills>
  <substitutionPermitted>true</substitutionPermitted>
  <instructions>take in the evening for maximum benefit</instructions>
</Medication>
    </Item>
  </Report>
  <Report>
    <Meta>
      <Document id="79bd9d8d-9948-43dc-9a6b-4327ae083da7" type="http://indivo.org/vocab/xml/documents#Medication" size="905" digest="2564baadd4916203cf972213c375d894842dc793ebfe01b7a138c7d4a96cd41e" record_id="6d4d246f-b518-4d03-a353-07b2f84f65ca">
        <createdAt>2011-02-16T22:20:59Z</createdAt>
        <creator id="gwhite@records.media.mit.edu" type="Account">
          <fullname>George White</fullname>
        </creator>
        <original id="79bd9d8d-9948-43dc-9a6b-4327ae083da7"/>
	<latest id="79bd9d8d-9948-43dc-9a6b-4327ae083da7" createdAt="2011-02-16T22:20:59Z" createdBy="gwhite@records.media.mit.edu"/>
        <status>active</status>
        <nevershare>false</nevershare>
        <isRelatedFrom>
               <relation type="http://indivo.org/vocab/documentrels#scheduledAction" count="1">
<relatedDocument id="298323ab-e0b2-4bd6-8d1a-f964d242fb7c"/>
               </relation>
        </isRelatedFrom>
      </Document>
    </Meta>
    <Item>
<Medication junk="http://indivo.org/vocab/xml/documents#">
  <name type="http://rxnav.nlm.nih.gov/REST/rxcui/" value="310798">Hydrochlorothiazide 25 MG Oral Tablet</name>
  <orderType>prescribed</orderType>
  <orderedBy>jking@records.media.mit.edu</orderedBy>
  <dateTimeOrdered>2011-02-14T09:00:00-04:00</dateTimeOrdered>
  <dateTimeExpiration>2011-05-14T09:00:00-04:00</dateTimeExpiration>
  <indication>elevated LDL cholesterol</indication>
  <activeIngredients>
    <activeIngredient>
      <name type="http://rxnav.nlm.nih.gov/REST/rxcui/" value="5487">hydrochlorothiazide</name>
      <strength>
        <value>25</value>
        <unit type="http://indivo.org/codes/units#" value="mg" abbrev="mg">milligram</unit>
      </strength>
    </activeIngredient>
  </activeIngredients>
  <dose>
    <value>1</value>
    <unit type="http://indivo.org/codes/units#" value="tab" abbrev="tab">tablet</unit>
  </dose>
  <form type="http://indivo.org/codes/form#" value="tab" abbrev="tab">tablet</form>
  <route type="http://indivo.org/codes/routes#" value="PO" abbrev="PO">by mouth</route>
  <frequency type="http://indivo.org/codes/frequency#" value="qd" abbrev="qd">once a day</frequency>
  <amountOrdered>
    <value>30</value>
    <unit type="http://indivo.org/codes/units#" value="tab" abbrev="tab">tablet</unit>
  </amountOrdered>
  <refills>3</refills>
  <substitutionPermitted>true</substitutionPermitted>
  <instructions>take in the evening for maximum benefit</instructions>
</Medication>
</Item>
  </Report>
</Reports>
			
		private var medicationScheduleItemsXml:XML = <Reports>
  <Summary total_document_count="2" limit="100" offset="0" order_by="-created_at"/>
<Report>
    <Meta>
       <Document id="138a12fb-14b4-48bb-a71a-9db2742354ce" type="http://indivo.org/vocab/xml/documents#MedicationScheduleItem" size="524" digest="fc62023160649d46272b158989fb2d7cc5d17d52a0fafbcbbd3d3cc84ba44068" record_id="6d4d246f-b518-4d03-a353-07b2f84f65ca">
    <createdAt>2011-02-16T22:19:26Z</createdAt>
    <creator id="gwhite@records.media.mit.edu" type="Account">
      <fullname>George White</fullname>
    </creator>
    <original id="138a12fb-14b4-48bb-a71a-9db2742354ce"/>
    <latest id="138a12fb-14b4-48bb-a71a-9db2742354ce" createdAt="2011-02-16T22:19:26Z" createdBy="gwhite@records.media.mit.edu"/>
    <status>active</status>
    <nevershare>false</nevershare>
    <relatesTo>
      <relation type="http://indivo.org/vocab/documentrels#scheduledAction" count="1">
<relatedDocument id="2fffda4e-5b39-4703-b044-6468c66efa05"/>
      </relation>
    </relatesTo>
    <isRelatedFrom>
      <relation type="http://indivo.org/vocab/documentrels#scheduleItem" count="1">
	<relatedDocument id="b5390d4f-1f20-45fe-8be2-a4f08d4ee7ce"/>
      </relation>
    </isRelatedFrom>
  </Document>
    </Meta>
    <Item>
      <MedicationScheduleItem junk="http://indivo.org/vocab/xml/documents#">
  <name type="http://rxnav.nlm.nih.gov/REST/rxcui/" value="617320">Atorvastatin 40 MG Oral Tablet [Lipitor]</name>
  <scheduledBy>jking@records.media.mit.edu</scheduledBy>
  <dateTimeScheduled>2011-02-14T09:00:00-04:00</dateTimeScheduled>
  <dose>
    <value>1</value>
    <unit type="http://indivo.org/codes/units#" value="tab" abbrev="tab">tablet</unit>
  </dose>
  <instructions>take in the evening for maximum benefit</instructions>
</MedicationScheduleItem>
   </Item>
  </Report>
  <Report>
    <Meta>
<Document id="298323ab-e0b2-4bd6-8d1a-f964d242fb7c" type="http://indivo.org/vocab/xml/documents#MedicationScheduleItem" size="496" digest="f546a17c2b6c9e83474c719a811c40af021bb5d97dbe7421e428fae1bfe3f091" record_id="6d4d246f-b518-4d03-a353-07b2f84f65ca">
    <createdAt>2011-02-16T22:19:45Z</createdAt>
    <creator id="gwhite@records.media.mit.edu" type="Account">
      <fullname>George White</fullname>
    </creator>
    <original id="298323ab-e0b2-4bd6-8d1a-f964d242fb7c"/>
    <latest id="298323ab-e0b2-4bd6-8d1a-f964d242fb7c" createdAt="2011-02-16T22:19:45Z" createdBy="gwhite@records.media.mit.edu"/>
    <status>active</status>
    <nevershare>false</nevershare>
    <relatesTo>
      <relation type="http://indivo.org/vocab/documentrels#scheduledAction" count="1">
<relatedDocument id="79bd9d8d-9948-43dc-9a6b-4327ae083da7"/>
      </relation>
    </relatesTo>
    <isRelatedFrom>
      <relation type="http://indivo.org/vocab/documentrels#scheduleItem" count="1">
	<relatedDocument id="b5390d4f-1f20-45fe-8be2-a4f08d4ee7ce"/>
      </relation>
    </isRelatedFrom>
  </Document>
    </Meta>
    <Item>
<MedicationScheduleItem junk="http://indivo.org/vocab/xml/documents#">
  <name type="http://rxnav.nlm.nih.gov/REST/rxcui/" value="310798">Hydrochlorothiazide 25 MG Oral Tablet</name>
  <scheduledBy>jking@records.media.mit.edu</scheduledBy>
  <dateTimeScheduled>2011-02-14T09:00:00-04:00</dateTimeScheduled>
  <dose>
    <value>1</value>
    <unit type="http://indivo.org/codes/units#" value="tab" abbrev="tab">tablet</unit>
  </dose>
  <instructions>take with water</instructions>
</MedicationScheduleItem>
</Item>
  </Report>
</Reports>

	}
}