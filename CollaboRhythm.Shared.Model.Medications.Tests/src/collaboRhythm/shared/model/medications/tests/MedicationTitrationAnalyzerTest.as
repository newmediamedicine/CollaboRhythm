package collaboRhythm.shared.model.medications.tests
{
	import collaboRhythm.shared.model.RecurrenceRule;
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmCodedValue;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.medications.MedicationTitrationAnalyzer;
	import collaboRhythm.shared.model.services.DateUtil;
	import collaboRhythm.shared.model.services.DefaultCurrentDateSource;
	import collaboRhythm.shared.model.services.DemoCurrentDateSource;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import mx.collections.ArrayCollection;

	import org.flexunit.asserts.assertEquals;

	import org.flexunit.asserts.assertNull;
	import org.hamcrest.assertThat;
	import org.hamcrest.date.dateEqual;

	public class MedicationTitrationAnalyzerTest
	{
		private var analyzer:MedicationTitrationAnalyzer;
		private static var dateSource:DemoCurrentDateSource;

		public function MedicationTitrationAnalyzerTest()
		{
		}

		[BeforeClass]
		public static function init():void
		{
			if (WorkstationKernel.instance.getComponentHandlers(ICurrentDateSource).length == 0)
			{
				dateSource = new DemoCurrentDateSource();
				WorkstationKernel.instance.registerComponentInstance("CurrentDateSource", ICurrentDateSource,
																	 dateSource);
			}
		}

		[Before]
		public function init():void
		{
			dateSource.targetDate = DateUtil.parse("2011-02-01T09:00:00Z");
			analyzer = new MedicationTitrationAnalyzer(null, dateSource);
		}

		[Test(description = "Tests that null is returned if there are no medications in the collection")]
		public function noMedicationsNull():void
		{
			analyzer.medicationScheduleItemsCollection = new ArrayCollection();

			var result:Date = analyzer.getMostRecentDoseChange();

			assertNull(result);
		}

		[Test(description = "Tests that null is returned if one invalid medication (no occurrences) is in the collection")]
		public function invalidMedicationNull():void
		{
			var schedule:MedicationScheduleItem = new MedicationScheduleItem();

			analyzer.medicationScheduleItemsCollection = new ArrayCollection([schedule]);

			var result:Date = analyzer.getMostRecentDoseChange();

			assertNull(result);
		}

		[Test(description = "Tests that the dateEnd of the occurrence after the last occurrence is returned for a single medication that ends before now.")]
		public function oneMedicationEndingBeforeNow():void
		{
			var schedule:MedicationScheduleItem = createSchedule();

			analyzer.medicationScheduleItemsCollection = new ArrayCollection([schedule]);

			var result:Date = analyzer.getMostRecentDoseChange();

			assertThat(result, dateEqual(DateUtil.parse("2011-01-08T08:00:00Z")));
		}

		[Test(description = "Tests that the dateStart of the first occurrence is returned for a single medication that ends after now.")]
		public function oneMedicationEndingAfterNow():void
		{
			var schedule:MedicationScheduleItem = createSchedule();
			dateSource.targetDate = DateUtil.parse("2011-01-04T08:00:00Z");

			analyzer.medicationScheduleItemsCollection = new ArrayCollection([schedule]);

			var result:Date = analyzer.getMostRecentDoseChange();

			assertThat(result, dateEqual(DateUtil.parse("2011-01-01T06:00:00Z")));
		}

		[Test(description = "Tests that the dateStart of the first occurrence of the earlier medication is returned for two consecutive medications, the second of which ends after now.")]
		public function medicationEndingAfterNowWithAnotherBefore():void
		{
			var schedule1:MedicationScheduleItem = createSchedule("2010-12-01T12:00:00Z", "2010-12-01T14:00:00Z", 31);
			var schedule2:MedicationScheduleItem = createSchedule();
			dateSource.targetDate = DateUtil.parse("2011-01-04T08:00:00Z");

			analyzer.medicationScheduleItemsCollection = new ArrayCollection([schedule1, schedule2]);

			var result:Date = analyzer.getMostRecentDoseChange();

			assertThat(result, dateEqual(DateUtil.parse("2010-12-01T12:00:00Z")));
		}

		[Test(description = "Tests that the dateStart of the first occurrence of the later medication is returned for two non-consecutive medications, the second of which ends after now.")]
		public function medicationEndingAfterNowWithAnotherBeforeNonConsecutive():void
		{
			var schedule1:MedicationScheduleItem = createSchedule("2010-12-01T12:00:00Z", "2010-12-01T14:00:00Z", 30);
			var schedule2:MedicationScheduleItem = createSchedule();
			dateSource.targetDate = DateUtil.parse("2011-01-04T08:00:00Z");

			analyzer.medicationScheduleItemsCollection = new ArrayCollection([schedule1, schedule2]);

			var result:Date = analyzer.getMostRecentDoseChange();

			assertThat(result, dateEqual(DateUtil.parse("2011-01-01T06:00:00Z")));
		}

		[Test(description = "Tests that the dateEnd of the occurrence after the last occurrence of the later medication is returned for two medications which end before now.")]
		public function medicationEndingBeforeNowWithAnotherBefore():void
		{
			var schedule1:MedicationScheduleItem = createSchedule("2010-12-01T12:00:00Z", "2010-12-01T14:00:00Z", 31);
			var schedule2:MedicationScheduleItem = createSchedule();

			analyzer.medicationScheduleItemsCollection = new ArrayCollection([schedule1, schedule2]);

			var result:Date = analyzer.getMostRecentDoseChange();

			assertThat(result, dateEqual(DateUtil.parse("2011-01-08T08:00:00Z")));
		}

		private function createSchedule(dateStartString:String = "2011-01-01T06:00:00Z",
										dateEndString:String = "2011-01-01T08:00:00Z", recurrenceCount:int = 7):MedicationScheduleItem
		{
			var schedule:MedicationScheduleItem = new MedicationScheduleItem();
			schedule.name = new CollaboRhythmCodedValue("http://rxnav.nlm.nih.gov/REST/rxcui/", "617320", null,
					"Atorvastatin 40 MG Oral Tablet [Lipitor]");
			schedule.scheduledBy = "test@test.org";
			schedule.dateScheduled = DateUtil.parse("2011-01-01T05:00:00Z");
			schedule.dateStart = DateUtil.parse(dateStartString);
			schedule.dateEnd = DateUtil.parse(dateEndString);
			schedule.recurrenceRule = new RecurrenceRule();
			schedule.recurrenceRule.count = recurrenceCount;
			schedule.recurrenceRule.frequency = "DAILY";
			return schedule;
		}
	}
}
