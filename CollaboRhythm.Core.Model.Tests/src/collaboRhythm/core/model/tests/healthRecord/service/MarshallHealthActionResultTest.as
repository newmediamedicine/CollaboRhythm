package collaboRhythm.core.model.tests.healthRecord.service
{
	import collaboRhythm.core.model.healthRecord.HealthRecordServiceFacade;
	import collaboRhythm.core.model.healthRecord.service.DocumentStorageServiceBase;
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmCodedValue;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionResult;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.ActionStepResult;
	import collaboRhythm.shared.model.services.DefaultCurrentDateSource;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import mx.collections.ArrayCollection;

	import org.flexunit.asserts.assertEquals;
	import org.hamcrest.date.dateAfter;

	public class MarshallHealthActionResultTest
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

		public function MarshallHealthActionResultTest()
		{
		}
		[Test]
		public function marshallHealthActionResult():void
		{
			var expected:XML =
					<HealthActionResult xmlns="http://indivo.org/vocab/xml/documents/healthActionResult#"
										xmlns:indivo="http://indivo.org/vocab/xml/documents#"
										xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
						<name>Insulin Titration Decision</name>
						<planType>Prescribed</planType>
						<reportedBy>mbrooks@records.media.mit.edu</reportedBy>
						<dateReported>2011-08-15T17:42:05Z</dateReported>
						<actions>
							<action xsi:type="ActionStepResult">
								<name>Chose a new dose</name>
							</action>
						</actions>
					</HealthActionResult>;

			var service:DocumentStorageServiceBase = serviceFacade.getService("http://indivo.org/vocab/xml/documents/healthActionResult#HealthActionResult");
			var document:HealthActionResult = new HealthActionResult();
			document.name = new CollaboRhythmCodedValue(null, null, null, "Insulin Titration Decision");
			document.planType = "Prescribed";
			document.reportedBy = "mbrooks@records.media.mit.edu";
			var date:Date = new Date();
			date.setUTCFullYear(2011, 8 - 1, 15);
			date.setUTCHours(17, 42, 5, 0);
			document.dateReported = date;
			var actionStepResult:ActionStepResult = new ActionStepResult();
			actionStepResult.name = new CollaboRhythmCodedValue(null, null, null, "Chose a new dose");
			document.actions = new ArrayCollection([actionStepResult]);

			var resultXml = service.marshallToXml(document);

			assertEquals(expected, resultXml);
		}
	}
}
