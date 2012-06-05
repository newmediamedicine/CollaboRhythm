package collaboRhythm.core.model.tests.healthRecord.service
{

	import collaboRhythm.core.model.healthRecord.HealthRecordServiceFacade;
	import collaboRhythm.core.model.healthRecord.service.AdherenceItemsHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.DocumentStorageServiceBase;
	import collaboRhythm.shared.model.healthRecord.IDocument;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
	import collaboRhythm.shared.model.services.DefaultCurrentDateSource;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import org.flexunit.asserts.assertEquals;

	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.runners.Parameterized;

	[RunWith("org.flexunit.runners.Parameterized")]
	public class MarshallDocumentTypesTest
	{
		private var foo:Parameterized;

		[Parameters]
		public static function data():Array
		{
			return [
				[
					"AdherenceItem simple",
					"http://indivo.org/vocab/xml/documents#AdherenceItem",
					<AdherenceItem xmlns="http://indivo.org/vocab/xml/documents#">
						<name>Atorvastatin 40 MG Oral Tablet [Lipitor]</name>
						<reportedBy>rpoole@records.media.mit.edu</reportedBy>
						<dateReported>2009-05-17T12:52:21Z</dateReported>
						<recurrenceIndex>10</recurrenceIndex>
						<adherence>true</adherence>
					</AdherenceItem>
				],
				[
					"AdherenceItem with abrev",
					"http://indivo.org/vocab/xml/documents#AdherenceItem",
					<AdherenceItem xmlns="http://indivo.org/vocab/xml/documents#">
						<name abbrev="lipitor40">Atorvastatin 40 MG Oral Tablet [Lipitor]</name>
						<reportedBy>rpoole@records.media.mit.edu</reportedBy>
						<dateReported>2009-05-17T12:52:21Z</dateReported>
						<recurrenceIndex>10</recurrenceIndex>
						<adherence>true</adherence>
					</AdherenceItem>
				],
				[
					"AdherenceItem with nonadherence",
					"http://indivo.org/vocab/xml/documents#AdherenceItem",
					<AdherenceItem xmlns="http://indivo.org/vocab/xml/documents#">
						<name>Atorvastatin 40 MG Oral Tablet [Lipitor]</name>
						<reportedBy>rpoole@records.media.mit.edu</reportedBy>
						<dateReported>2009-05-17T12:52:21Z</dateReported>
						<recurrenceIndex>10</recurrenceIndex>
						<adherence>true</adherence>
						<nonadherenceReason>upset stomach</nonadherenceReason>
					</AdherenceItem>
				],
				[
					"MedicationOrder with refills",
					"http://indivo.org/vocab/xml/documents#MedicationOrder",
					<MedicationOrder xmlns="http://indivo.org/vocab/xml/documents#">
						<name type="http://rxnav.nlm.nih.gov/REST/rxcui/" value="310798">Hydrochlorothiazide 25 MG Oral Tablet</name>
						<orderType>prescribed</orderType>
						<orderedBy>jking@records.media.mit.edu </orderedBy>
						<dateOrdered>2011-02-14T13:00:00Z</dateOrdered>
						<dateExpires>2011-05-14T13:00:00Z</dateExpires>
						<indication>hypertension</indication>
						<amountOrdered>
							<value>30</value>
							<unit type="http://indivo.org/codes/units#" value="tab" abbrev="tab">tablet</unit>
						</amountOrdered>
						<refills>3</refills>
						<substitutionPermitted>true</substitutionPermitted>
						<instructions>take with water</instructions>
					</MedicationOrder>
				],
				[
					"MedicationAdministration",
					"http://indivo.org/vocab/xml/documents#MedicationAdministration",
					<MedicationAdministration xmlns="http://indivo.org/vocab/xml/documents#">
						<name type="http://rxnav.nlm.nih.gov/REST/rxcui/" value="617320">Atorvastatin 40 MG Oral Tablet [Lipitor]</name>
						<reportedBy>rpoole@records.media.mit.edu</reportedBy>
						<dateReported>2009-05-17T12:52:21Z</dateReported>
						<dateAdministered>2009-05-17T12:52:21Z</dateAdministered>
						<amountAdministered>
							<value>1</value>
							<unit>tablet</unit>
						</amountAdministered>
						<amountRemaining>
							<value>29</value>
							<unit>tablet</unit>
						</amountRemaining>
					</MedicationAdministration>
				],
				[
					"VitalSign",
					"http://indivo.org/vocab/xml/documents#VitalSign",
					<VitalSign xmlns="http://indivo.org/vocab/xml/documents#">
						<name type="http://codes.indivo.org/vitalsigns/" value="123" abbrev="BPsys">Blood Pressure Systolic</name>
						<measuredBy>rpoole@records.media.mit.edu</measuredBy>
						<dateMeasuredStart>2009-05-16T19:23:21Z</dateMeasuredStart>
						<result>
							<value>145</value>
							<unit type="http://codes.indivo.org/units/" value="31" abbrev="mmHg">millimeters of mercury</unit>
						</result>
						<site>left arm</site>
						<position>sitting</position>
					</VitalSign>
				],
				[
					"MedicationScheduleItem",
					"http://indivo.org/vocab/xml/documents#MedicationScheduleItem",
					<MedicationScheduleItem xmlns="http://indivo.org/vocab/xml/documents#">
						<name type="http://rxnav.nlm.nih.gov/REST/rxcui/" value="617320">Atorvastatin 40 MG Oral Tablet [Lipitor]</name>
						<scheduledBy>jking@records.media.mit.edu</scheduledBy>
						<dateScheduled>2011-02-14T17:00:00Z</dateScheduled>
						<dateStart>2011-02-15T14:00:00Z</dateStart>
						<dateEnd>2011-03-15T18:00:00Z</dateEnd>
						<recurrenceRule>
							<frequency>DAILY</frequency>
							<count>30</count>
						</recurrenceRule>
						<dose>
							<value>1</value>
							<unit type="http://indivo.org/codes/units#" value="tab" abbrev="tab">tablet</unit>
						</dose>
						<instructions>take in the evening for maximum benefit</instructions>
					</MedicationScheduleItem>
				],
				[
					"HealthActionSchedule",
					"http://indivo.org/vocab/xml/documents#HealthActionSchedule",
					<HealthActionSchedule xmlns="http://indivo.org/vocab/xml/documents#">
						<name> FORA D15b </name>
						<scheduledBy>jking@records.media.mit.edu</scheduledBy>
						<dateScheduled>2011-02-14T17:00:00Z</dateScheduled>
						<dateStart>2011-02-15T14:00:00Z</dateStart>
						<dateEnd>2011-03-15T18:00:00Z</dateEnd>
						<recurrenceRule>
							<frequency>DAILY</frequency>
							<count>30</count>
						</recurrenceRule>
						<instructions>press the big blue button</instructions>
					</HealthActionSchedule>
				],
				[
					"VideoMessage",
					"http://indivo.org/vocab/xml/documents#VideoMessage",
					<VideoMessage xmlns="http://indivo.org/vocab/xml/documents#">
						<fileId>rpoole1</fileId>
						<storageType>FlashMediaServer</storageType>
						<subject>Nice Job Robert</subject>
						<from>jking@records.media.mit.edu</from>
						<dateRecorded>2009-05-17T12:52:21Z</dateRecorded>
						<dateSent>2009-05-17T12:52:21Z</dateSent>
					</VideoMessage>
				],
			];
		}

		public static function dataExpectedFailures():Array
		{
			return [
				[
					"MedicationOrder with no refills",
					"http://indivo.org/vocab/xml/documents#MedicationOrder",
					<MedicationOrder xmlns="http://indivo.org/vocab/xml/documents#">
						<name type="http://rxnav.nlm.nih.gov/REST/rxcui/" value="310798">Hydrochlorothiazide 25 MG Oral Tablet</name>
						<orderType>prescribed</orderType>
						<orderedBy>jking@records.media.mit.edu </orderedBy>
						<dateOrdered>2011-02-14T13:00:00Z</dateOrdered>
						<dateExpires>2011-05-14T13:00:00Z</dateExpires>
						<indication>hypertension</indication>
						<amountOrdered>
							<value>30</value>
							<unit type="http://indivo.org/codes/units#" value="tab" abbrev="tab">tablet</unit>
						</amountOrdered>
						<substitutionPermitted>true</substitutionPermitted>
						<instructions>take with water</instructions>
					</MedicationOrder>
				],
				[
					"MedicationScheduleItem with dateUntil",
					"http://indivo.org/vocab/xml/documents#MedicationScheduleItem",
					<MedicationScheduleItem xmlns="http://indivo.org/vocab/xml/documents#">
						<name type="http://rxnav.nlm.nih.gov/REST/rxcui/" value="617320">Atorvastatin 40 MG Oral Tablet [Lipitor]</name>
						<scheduledBy>jking@records.media.mit.edu</scheduledBy>
						<dateScheduled>2011-02-14T17:00:00Z</dateScheduled>
						<dateStart>2011-02-15T14:00:00Z</dateStart>
						<dateEnd>2011-03-15T18:00:00Z</dateEnd>
						<recurrenceRule>
							<frequency>DAILY</frequency>
							<dateUntil>2011-03-15T18:00:00Z</count>
						</recurrenceRule>
						<dose>
							<value>1</value>
							<unit type="http://indivo.org/codes/units#" value="tab" abbrev="tab">tablet</unit>
						</dose>
						<instructions>take in the evening for maximum benefit</instructions>
					</MedicationScheduleItem>
				],
			];
		}

		private var _documentType:String;
		private var _documentXml:XML;

		public function MarshallDocumentTypesTest(testDescription:String, documentType:String, documentXml:XML)
		{
			_documentType = documentType;
			_documentXml = documentXml;
		}

		private static var serviceFacade:HealthRecordServiceFacade;

		[BeforeClass]
		public static function init():void
		{
			if (WorkstationKernel.instance.getComponentHandlers(ICurrentDateSource).length == 0)
			{
				var dateSource:DefaultCurrentDateSource = new DefaultCurrentDateSource();
				WorkstationKernel.instance.registerComponentInstance("CurrentDateSource", ICurrentDateSource,
																	 dateSource);
			}
			serviceFacade = new HealthRecordServiceFacade(null, null, "", null, settings.debuggingToolsEnabled);
		}

//		[Test(dataProvider="data", description = "Tests that unmarshalling from XML and then back results in the exact same string")]
		[Test(description = "Tests that unmarshalling from XML and then back results in the exact same string")]
		public function marshallXml():void
		{
			var service:DocumentStorageServiceBase = serviceFacade.getService(_documentType);
			var document:IDocument = service.unmarshallDocumentXml(_documentXml);

			assertNotNull("service.unmarshallDocumentXml(documentXml)", document);

			if (document)
			{
				var resultXml = service.marshallToXml(document);

				assertEquals(_documentXml, resultXml);
			}
		}

	}
}
