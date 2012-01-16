package collaboRhythm.core.model.tests.healthRecord.service
{

	import collaboRhythm.core.model.healthRecord.service.AdherenceItemsHealthRecordService;
	import collaboRhythm.shared.model.DateUtil;
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.IDocument;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
	import collaboRhythm.shared.model.services.DefaultCurrentDateSource;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import org.flexunit.asserts.assertEquals;

	import org.flexunit.asserts.assertNotNull;

	public class AdherenceItemsHealthRecordServiceTest
	{
		public function AdherenceItemsHealthRecordServiceTest()
		{
		}

		private static var service:AdherenceItemsHealthRecordService;

		[BeforeClass]
		public static function init():void
		{
			if (WorkstationKernel.instance.getComponentHandlers(ICurrentDateSource).length == 0)
			{
				var dateSource:DefaultCurrentDateSource = new DefaultCurrentDateSource();
				WorkstationKernel.instance.registerComponentInstance("CurrentDateSource", ICurrentDateSource,
																	 dateSource);
			}
			service = new AdherenceItemsHealthRecordService(null, null, "", null, null);
		}

		[Test(description = "Tests that unmarshalling from XML results in the expected document")]
		public function adherenceItemXmlUnmarshall():void
		{
			var documentXml:XML = <AdherenceItem xmlns="http://indivo.org/vocab/xml/documents#">
				<name>Atorvastatin 40 MG Oral Tablet [Lipitor]</name>
				<reportedBy>rpoole@records.media.mit.edu</reportedBy>
				<dateReported>2009-05-17T12:52:21Z</dateReported>
				<recurrenceIndex>10</recurrenceIndex>
				<adherence>true</adherence>
			</AdherenceItem>;

			var document:AdherenceItem = service.unmarshallDocumentXml(documentXml) as AdherenceItem;

			assertNotNull("service.unmarshallDocumentXml(documentXml)", document);

			if (document)
			{
				assertEquals(null, document.name.abbrev);
				assertEquals(null, document.name.type);
				assertEquals(null, document.name.value);
				assertEquals("Atorvastatin 40 MG Oral Tablet [Lipitor]", document.name.text);
			}
		}

		[Test(description = "Tests that unmarshalling from XML with a value for abrev results in the expected document")]
		public function adherenceItemAbrevXmlUnmarshall():void
		{
			var documentXml:XML = <AdherenceItem xmlns="http://indivo.org/vocab/xml/documents#">
				<name abbrev="lipitor40">Atorvastatin 40 MG Oral Tablet [Lipitor]</name>
				<reportedBy>rpoole@records.media.mit.edu</reportedBy>
				<dateReported>2009-05-17T12:52:21Z</dateReported>
				<recurrenceIndex>10</recurrenceIndex>
				<adherence>true</adherence>
			</AdherenceItem>;

			var document:AdherenceItem = service.unmarshallDocumentXml(documentXml) as AdherenceItem;

			assertNotNull("service.unmarshallDocumentXml(documentXml)", document);

			if (document)
			{
				assertEquals("lipitor40", document.name.abbrev);
				assertEquals(null, document.name.type);
				assertEquals(null, document.name.value);
				assertEquals("Atorvastatin 40 MG Oral Tablet [Lipitor]", document.name.text);
			}
		}

		[Test(description = "Tests that unmarshalling from XML and then back results in the exact same string")]
		public function adherenceItemXmlUnmarshallMarshall():void
		{
			var documentXml:XML = <AdherenceItem xmlns="http://indivo.org/vocab/xml/documents#">
				<name>Atorvastatin 40 MG Oral Tablet [Lipitor]</name>
				<reportedBy>rpoole@records.media.mit.edu</reportedBy>
				<dateReported>2009-05-17T12:52:21Z</dateReported>
				<recurrenceIndex>10</recurrenceIndex>
				<adherence>true</adherence>
			</AdherenceItem>;

			var document:IDocument = service.unmarshallDocumentXml(documentXml);

			assertNotNull("service.unmarshallDocumentXml(documentXml)", document);

			if (document)
			{
				var resultXml = service.marshallToXml(document);

				assertEquals(documentXml, resultXml);
			}
		}

		[Test(description = "Tests that marshalling to xml results in the expected string")]
		public function adherenceItemMarshallToXml():void
		{
			var documentXml:XML = <AdherenceItem xmlns="http://indivo.org/vocab/xml/documents#">
				<name>Atorvastatin 40 MG Oral Tablet [Lipitor]</name>
				<reportedBy>rpoole@records.media.mit.edu</reportedBy>
				<dateReported>2009-05-17T12:52:21Z</dateReported>
				<recurrenceIndex>10</recurrenceIndex>
				<adherence>true</adherence>
			</AdherenceItem>;

			var document:AdherenceItem = new AdherenceItem();
			var date:Date = new Date();
			date.setTime(DateUtil.parseW3CDTF("2009-05-17T12:52:21-00:00"));
			document.init(new CodedValue(null, null, null, "Atorvastatin 40 MG Oral Tablet [Lipitor]"),
					"rpoole@records.media.mit.edu", date, 10);

			var resultXml = service.marshallToXml(document);

			assertEquals(documentXml, resultXml);
		}

		[Test(description = "Tests that marshalling to xml results in the expected string when nonadherencReason is specified")]
		public function adherenceItemWithNonadherenceReasonMarshallToXml():void
		{
			var documentXml:XML = <AdherenceItem xmlns="http://indivo.org/vocab/xml/documents#">
				<name>Atorvastatin 40 MG Oral Tablet [Lipitor]</name>
				<reportedBy>rpoole@records.media.mit.edu</reportedBy>
				<dateReported>2009-05-17T12:52:21Z</dateReported>
				<recurrenceIndex>10</recurrenceIndex>
				<adherence>false</adherence>
				<nonadherenceReason>upset stomach</nonadherenceReason>
			</AdherenceItem>;

			var document:AdherenceItem = new AdherenceItem();
			var date:Date = new Date();
			date.setTime(DateUtil.parseW3CDTF("2009-05-17T12:52:21-00:00"));
			document.init(new CodedValue(null, null, null, "Atorvastatin 40 MG Oral Tablet [Lipitor]"),
					"rpoole@records.media.mit.edu", date, 10);

			var resultXml = service.marshallToXml(document);

			assertEquals(documentXml, resultXml);
		}
	}
}
