package collaboRhythm.core.model.tests.healthRecord.service
{

	import collaboRhythm.core.model.healthRecord.HealthRecordServiceFacade;
	import collaboRhythm.core.model.healthRecord.service.DocumentStorageServiceBase;
	import collaboRhythm.shared.model.healthRecord.IDocument;
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
				[
					"HealthActionPlan complex 1",
					"http://indivo.org/vocab/xml/documents/healthActionPlan#HealthActionPlan",
					<HealthActionPlan xmlns="http://indivo.org/vocab/xml/documents/healthActionPlan#"
										xmlns:indivo="http://indivo.org/vocab/xml/documents#"
										xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
						<name>Blood Pressure Plan</name>
						<planType>prescribed</planType>
						<plannedBy>rpoole@records.media.mit.edu </plannedBy>
						<datePlanned>2009-05-16T16:51:00Z</datePlanned>
						<dateExpires>2049-05-16T16:51:00Z</dateExpires>
						<indication>blood pressure measurementPlans protocol</indication>
						<!-- optional. allows you to specify that this plan has an specific indication -->
						<instructions>Put on the blood pressure monitor and Follow the protocol</instructions>
						<system type="http://system.repository.coded.values/" value="1">CollaboRhythm</system>
						<actions>
							<action xsi:type="ActionGroup">
								<position type="http://position.coded.values/" value="2">Seated</position>
								<repeatCount>3</repeatCount>
								<actions>
									<action xsi:type="ActionStep">
										<stopConditions>
											<stopCondition>
												<name type="http://actions.repository.coded.values/" value="3">time</name>
												<value>
													<indivo:value>3</indivo:value>
													<indivo:unit type="http://indivo.org/codes/units#" value="m" abbrev="m">minutes</indivo:unit>
												</value>
												<operator type="http://comparison.operators/" value="1">Greater or equal than</operator>
											</stopCondition>
										</stopConditions>
										<name type="http://actions.repository/" value="1">Rest</name>
										<type type="http://actions.repository.type/" value="1">Rest</type>
										<instructions>Sit for three minutes</instructions>
									</action>
									<action    xsi:type="ActionStep">
										<measurementPlans>
											<measurementPlan>
												<name type="http://measures.coded.values/" value="1">BP</name>
												<type type="http://measures.type.coded.values/" value="3">Systolic</type>
												<aggregationFunction type="http://aggregation.coded.values/">avg</aggregationFunction>
											</measurementPlan>
											<measurementPlan>
												<name type="http://measures.coded.values/" value="1">BP</name>
												<type type="http://measures.type.coded.values/" value="3">Diastolic</type>
												<aggregationFunction type="http://aggregation.coded.values/">avg</aggregationFunction>
											</measurementPlan>
											<measurementPlan>
												<name type="http://measures.coded.values/" value="1">HR</name>
												<aggregationFunction type="http://aggregation.coded.values/">avg</aggregationFunction>
											</measurementPlan>
										</measurementPlans>
										<name type="http://actions.repository/" value="1">Take Blood Pressure</name>
										<type type="http://actions.repository.type/" value="1">Blood Pressure</type>
										<instructions>Take Blood Pressure while Seated</instructions>
									</action>
								</actions>
							</action>
							<action xsi:type="ActionGroup">
								<position type="http://position.coded.values/" value="2">Lie down</position>
								<repeatCount>3</repeatCount>
								<actions>
									<action    xsi:type="ActionStep">
										<stopConditions>
											<stopCondition>
												<name type="http://actions.repository.coded.values/" value="3">time</name>
												<value>
													<indivo:value>3</indivo:value>
													<indivo:unit type="http://indivo.org/codes/units#" value="m" abbrev="m">minutes</indivo:unit>
												</value>
												<operator type="http://comparison.operators/" value="1">Greater or equal than</operator>
											</stopCondition>
										</stopConditions>
										<name type="http://actions.repository/" value="1">Rest</name>
										<type type="http://actions.repository.type/" value="1">Rest</type>
										<instructions>Sit for three minutes</instructions>
									</action>
									<action    xsi:type="ActionStep">
										<measurementPlans>
											<measurementPlan>
												<name type="http://measures.coded.values/" value="1">BP</name>
												<type type="http://measures.type.coded.values/" value="3">Systolic</type>
												<aggregationFunction type="http://aggregation.coded.values/">avg</aggregationFunction>
											</measurementPlan>
											<measurementPlan>
												<name type="http://measures.coded.values/" value="1">BP</name>
												<type type="http://measures.type.coded.values/" value="3">Diastolic</type>
												<aggregationFunction type="http://aggregation.coded.values/">avg</aggregationFunction>
											</measurementPlan>
											<measurementPlan>
												<name type="http://measures.coded.values/" value="1">HR</name>
												<aggregationFunction type="http://aggregation.coded.values/">avg</aggregationFunction>
											</measurementPlan>
										</measurementPlans>
										<name type="http://actions.repository/" value="1">Take Blood Pressure</name>
										<type type="http://actions.repository.type/" value="1">Blood Pressure</type>
										<instructions>Take Blood Pressure while Seated</instructions>
									</action>
								</actions>
							</action>
							<action xsi:type="ActionGroup">
								<position type="http://position.coded.values/" value="2">Stand</position>
								<repeatCount>3</repeatCount>
								<actions>
									<action    xsi:type="ActionStep">
										<stopConditions>
											<stopCondition>
												<name type="http://actions.repository.coded.values/" value="3">time</name>
												<value>
													<indivo:value>3</indivo:value>
													<indivo:unit type="http://indivo.org/codes/units#" value="m" abbrev="m">minutes</indivo:unit>
												</value>
												<operator type="http://comparison.operators/" value="1">Greater or equal than</operator>
											</stopCondition>
										</stopConditions>
										<name type="http://actions.repository/" value="1">Rest</name>
										<type type="http://actions.repository.type/" value="1">Rest</type>
										<instructions>Sit for three minutes</instructions>
									</action>
									<action    xsi:type="ActionStep">
										<measurementPlans>
											<measurementPlan>
												<name type="http://measures.coded.values/" value="1">BP</name>
												<type type="http://measures.type.coded.values/" value="3">Systolic</type>
												<aggregationFunction type="http://aggregation.coded.values/">avg</aggregationFunction>
											</measurementPlan>
											<measurementPlan>
												<name type="http://measures.coded.values/" value="1">BP</name>
												<type type="http://measures.type.coded.values/" value="3">Diastolic</type>
												<aggregationFunction type="http://aggregation.coded.values/">avg</aggregationFunction>
											</measurementPlan>
											<measurementPlan>
												<name type="http://measures.coded.values/" value="1">HR</name>
												<aggregationFunction type="http://aggregation.coded.values/">avg</aggregationFunction>
											</measurementPlan>
										</measurementPlans>
										<name type="http://actions.repository/" value="1">Take Blood Pressure</name>
										<type type="http://actions.repository.type/" value="1">Blood Pressure</type>
										<instructions>Take Blood Pressure while Seated</instructions>
									</action>
								</actions>
							</action>
						</actions>
					</HealthActionPlan>
				],
				[
					"HealthActionResult simple",
					"http://indivo.org/vocab/xml/documents/healthActionResult#HealthActionResult",
					<HealthActionResult xmlns="http://indivo.org/vocab/xml/documents/healthActionResult#"
										xmlns:indivo="http://indivo.org/vocab/xml/documents#"
										xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
						<name>Insulin Titration Decision</name>
						<planType>Prescribed</planType>
						<reportedBy>mbrooks@records.media.mit.edu</reportedBy>
						<dateReported>2011-07-15T13:42:05Z</dateReported>
						<actions>
							<action xsi:type="ActionStepResult">
								<name>Chose a new dose</name>
							</action>
						</actions>
					</HealthActionResult>
				],
				[
					"HealthActionResult complex 1",
					"http://indivo.org/vocab/xml/documents/healthActionResult#HealthActionResult",
					<HealthActionResult xmlns="http://indivo.org/vocab/xml/documents/healthActionResult#"
										xmlns:indivo="http://indivo.org/vocab/xml/documents#"
										xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
						<name>Knee Bend Test</name>
						<planType>Prescribed</planType>
						<reportedBy>mbrooks@records.media.mit.edu</reportedBy>
						<dateReported>2011-07-15T13:42:05Z</dateReported>
						<actions>
							<action xsi:type="ActionStepResult">
								<measurements>
									<measurement>
										<name type="http://measures.coded.values/" value="1">Knee Angle</name>
										<type type="http://measures.type.coded.values/" value="3">Extension</type>
										<value>
											<indivo:value>150</indivo:value>
											<indivo:unit type="http://indivo.org/codes/units#" value="m" abbrev="m">degrees</indivo:unit>
										</value>
										<aggregationFunction type="http://aggregation.coded.values/">max</aggregationFunction>
									</measurement>
								</measurements>
								<name>Bend knee</name>
							</action>
						</actions>
					</HealthActionResult>
				],
				[
					"HealthActionResult complex 2",
					"http://indivo.org/vocab/xml/documents/healthActionResult#HealthActionResult",
					<HealthActionResult xmlns="http://indivo.org/vocab/xml/documents/healthActionResult#"
										xmlns:indivo="http://indivo.org/vocab/xml/documents#"
										xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
						<name type="http://actions.repository.coded.values/" value="Exercise Plan">Exercise Plan 1</name>
						<planType>prescribed</planType>
						<reportedBy>rpoole</reportedBy>
						<dateReported>2012-04-05T12:00:35.835Z</dateReported>
						<actions>
							<action xsi:type="ActionGroupResult">
								<measurements>
									<measurement>
										<name type="http://measures.coded.values/" value="1">Knee Angle</name>
										<type type="http://measures.type.coded.values/" value="3">Extension</type>
										<value>
											<indivo:value>150</indivo:value>
											<indivo:unit type="http://indivo.org/codes/units#" value="m" abbrev="m">degrees</indivo:unit>
										</value>
										<aggregationFunction type="http://aggregation.coded.values/">max</aggregationFunction>
									</measurement>
									<measurement>
										<name type="http://measures.coded.values/" value="1">Knee Angle</name>
										<type type="http://measures.type.coded.values/" value="3">Flexion</type>
										<value>
											<indivo:value>30</indivo:value>
											<indivo:unit type="http://indivo.org/codes/units#" value="m" abbrev="m">degrees</indivo:unit>
										</value>
										<aggregationFunction type="http://aggregation.coded.values/">min</aggregationFunction>
									</measurement>
								</measurements>
								<deviceResults>
									<deviceResult>
										<name type="http://devices.repository.coded.values/" value="Wocket">Wocket</name>
										<type type="http://equipment.coded.values/" value="1">Accelerometer</type>
										<value/>
										<site type="http://equipment.coded.values/" value="1">Lower Leg</site>
									</deviceResult>
									<deviceResult>
										<name type="http://devices.repository.coded.values/" value="Wocket">Wocket</name>
										<type type="http://equipment.coded.values/" value="1">Accelerometer</type>
										<value/>
										<site type="http://equipment.coded.values/" value="1">Upper Leg</site>
									</deviceResult>
								</deviceResults>
								<medicationAdministrations />
								<actions>
									<action xsi:type="ActionStepResult">
										<measurements>
											<measurement>
												<name type="http://measures.coded.values/" value="1">Knee Angle</name>
												<type type="http://measures.type.coded.values/" value="3">Extension</type>
												<value>
													<indivo:value>150</indivo:value>
													<indivo:unit type="http://indivo.org/codes/units#" value="m" abbrev="m">degrees</indivo:unit>
												</value>
												<aggregationFunction type="http://aggregation.coded.values/">max</aggregationFunction>
											</measurement>
											<measurement>
												<name type="http://measures.coded.values/" value="1">Knee Angle</name>
												<type type="http://measures.type.coded.values/" value="3">Flexion</type>
												<value>
													<indivo:value>30</indivo:value>
													<indivo:unit type="http://indivo.org/codes/units#" value="m" abbrev="m">degrees</indivo:unit>
												</value>
												<aggregationFunction type="http://aggregation.coded.values/">min</aggregationFunction>
											</measurement>
										</measurements>
										<deviceResults>
											<deviceResult>
												<name type="http://devices.repository.coded.values/" value="Wocket">Wocket</name>
												<type type="http://equipment.coded.values/" value="1">Accelerometer</type>
												<value/>
												<site type="http://equipment.coded.values/" value="1">Lower Leg</site>
											</deviceResult>
											<deviceResult>
												<name type="http://devices.repository.coded.values/" value="Wocket">Wocket</name>
												<type type="http://equipment.coded.values/" value="1">Accelerometer</type>
												<value/>
												<site type="http://equipment.coded.values/" value="1">Upper Leg</site>
											</deviceResult>
										</deviceResults>
										<medicationAdministrations/>
										<name type="http://actions.repository/" value="2">Kick Balls</name>
										<occurrences>
											<occurrence>
												<startTime>2012-04-05T20:00:35.850Z</startTime>
												<endTime>2012-04-05T20:00:43.135Z</endTime>
												<stopCondition>
													<name type="http://measures.coded.values/" value="7">Repetitions</name>
													<value>
														<indivo:value>10</indivo:value>
														<indivo:unit type="http://indivo.org/codes/units#" value="t" abbrev="t">Times</indivo:unit>
													</value>
												</stopCondition>
												<measurements>
													<measurement>
														<name type="http://measures.coded.values/" value="1">Knee Angle</name>
														<type type="http://measures.type.coded.values/" value="3">Extension</type>
														<value>
															<indivo:value>150</indivo:value>
															<indivo:unit type="http://indivo.org/codes/units#" value="m" abbrev="m">degrees</indivo:unit>
														</value>
														<aggregationFunction type="http://aggregation.coded.values/">max</aggregationFunction>
													</measurement>
													<measurement>
														<name type="http://measures.coded.values/" value="1">Knee Angle</name>
														<type type="http://measures.type.coded.values/" value="3">Flexion</type>
														<value>
															<indivo:value>30</indivo:value>
															<indivo:unit type="http://indivo.org/codes/units#" value="m" abbrev="m">degrees</indivo:unit>
														</value>
														<aggregationFunction type="http://aggregation.coded.values/">min</aggregationFunction>
													</measurement>
													<measurement>
														<name type="http://measures.coded.values/" value="3">Adherence</name>
														<value>
															<indivo:value>0</indivo:value>
															<indivo:unit>%</indivo:unit>
														</value>
														<aggregationFunction type="http://aggregation.coded.values/">avg</aggregationFunction>
													</measurement>
													<measurement>
														<name type="http://measures.coded.values/" value="5">Repetitions</name>
														<value>
															<indivo:value>1</indivo:value>
															<indivo:unit>num</indivo:unit>
														</value>
														<aggregationFunction type="http://aggregation.coded.values/">sum</aggregationFunction>
													</measurement>
												</measurements>
												<deviceResults>
													<deviceResult>
														<name type="http://devices.repository.coded.values/" value="Wocket">Wocket</name>
														<type type="http://equipment.coded.values/" value="1">Accelerometer</type>
														<value/>
														<site type="http://equipment.coded.values/" value="1">Lower Leg</site>
													</deviceResult>
													<deviceResult>
														<name type="http://devices.repository.coded.values/" value="Wocket">Wocket</name>
														<type type="http://equipment.coded.values/" value="1">Accelerometer</type>
														<value/>
														<site type="http://equipment.coded.values/" value="1">Upper Leg</site>
													</deviceResult>
												</deviceResults>
												<medicationAdministrations />
											</occurrence>
										</occurrences>
									</action>
								</actions>
							</action>
						</actions>
					</HealthActionResult>
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
			serviceFacade = new HealthRecordServiceFacade(null, null, "", null, false);
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
