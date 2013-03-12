package collaboRhythm.core.model.tests.healthRecord.service
{
	import collaboRhythm.core.model.healthRecord.HealthRecordServiceFacade;
	import collaboRhythm.core.model.healthRecord.service.DocumentStorageServiceBase;
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmCodedValue;
	import collaboRhythm.shared.model.healthRecord.document.Equipment;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionResult;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.ActionStepResult;
	import collaboRhythm.shared.model.services.DefaultCurrentDateSource;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import mx.collections.ArrayCollection;

	import org.flexunit.asserts.assertEquals;
	import org.hamcrest.date.dateAfter;

	public class MarshallEquipmentTest
	{
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
			serviceFacade = new HealthRecordServiceFacade(null, null, "", null, false,
					null);
		}

		public function MarshallEquipmentTest()
		{
		}

		[Test]
		public function marshallHealthActionResult():void
		{
			var expected:XML =
					<Equipment xmlns="http://indivo.org/vocab/xml/documents#">
						<dateStarted>2009-12-15</dateStarted>
						<type>blood pressure monitor</type>
						<name xmlns="">FORA D40b</name>
					</Equipment>;

			var service:DocumentStorageServiceBase = serviceFacade.getService("http://indivo.org/vocab/xml/documents#Equipment");
			var document:Equipment = new Equipment();
			document.name = "FORA D40b";
			document.type = "blood pressure monitor";
			var date:Date = new Date();
			date.setUTCFullYear(2009, 12 - 1, 15);
			date.setUTCHours(0, 0, 0, 0);
			document.dateStarted = date;

			var resultXml = service.marshallToXml(document);

			assertEquals(expected, resultXml);
		}
	}
}
