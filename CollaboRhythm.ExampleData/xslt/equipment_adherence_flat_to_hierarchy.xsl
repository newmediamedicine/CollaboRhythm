<!--~
  ~ Copyright 2011 John Moore, Scott Gilroy
  ~
  ~ This file is part of CollaboRhythm.
  ~
  ~ CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
  ~ License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
  ~ version.
  ~
  ~ CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
  ~ warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  ~ details.
  ~
  ~ You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see
  ~ <http://www.gnu.org/licenses/>.
  -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"

				xmlns:fn="http://www.w3.org/2005/xpath-functions"
				xmlns:d="http://indivo.org/vocab/xml/documents#">
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="/">
		<xsl:variable name="dateStart">2011-07-15T13:00:00Z</xsl:variable>
		<xsl:variable name="equipmentName" select="IndivoDocuments/BloodPressureAdherenceItem[1]/name"/>
		<xsl:variable name="reportedBy" select="IndivoDocuments/BloodPressureAdherenceItem[1]/reportedBy"/>
		<IndivoDocuments>
			<LoadableIndivoDocument>
				<document>
					<Equipment xmlns="http://indivo.org/vocab/xml/documents#">
						<dateStarted>2009-12-15</dateStarted>
						<type>blood pressure monitor</type>
						<xsl:copy-of select="$equipmentName"/>
					</Equipment>
				</document>
				<relatesTo>
					<relation type="scheduleItem">
						<!-- child elements can be either (1) IndivoDocumentWithRelationships or (2) IndivoDocument document type -->
						<LoadableIndivoDocument>
							<document>
								<EquipmentScheduleItem xmlns="http://indivo.org/vocab/xml/documents#">
									<xsl:copy-of select="$equipmentName"/>
									<scheduledBy>jking@records.media.mit.edu</scheduledBy>
									<dateScheduled>2011-07-14T19:13:11Z</dateScheduled>
									<dateStart>
										<xsl:value-of select="$dateStart"/>
									</dateStart>
									<dateEnd>2011-07-15T17:00:00Z</dateEnd>
									<recurrenceRule>
										<frequency>DAILY</frequency>
										<count>90</count>
									</recurrenceRule>
									<instructions>press the power button and wait several seconds to take reading
									</instructions>
								</EquipmentScheduleItem>
							</document>
							<relatesTo>
								<relation type="adherenceItem">
									<xsl:for-each select="IndivoDocuments/BloodPressureAdherenceItem">
										<xsl:variable name="adherenceCount" select="position() - 1"/>
										<LoadableIndivoDocument>
											<document>
												<AdherenceItem xmlns="http://indivo.org/vocab/xml/documents#">
													<xsl:copy-of select="$equipmentName"/>
													<xsl:copy-of select="$reportedBy"/>
													<dateReported>
														<xsl:value-of select="dateReported"/>
													</dateReported>
													<recurrenceIndex>
														<xsl:value-of
																select="fn:days-from-duration(xs:dateTime(dateReported) - xs:dateTime($dateStart))"/>
<!--
														<xsl:value-of
																select="xs:dateTime(dateReported)"/>
-->
<!--
														<xsl:value-of
																select="xs:dateTime($dateStart)"/>
-->
<!--
														<xsl:value-of
																select="$dateStart"/>
-->
<!--
														<xsl:value-of
																select="fn:days-from-duration(xs:dateTime($dateStart) - xs:dateTime($dateStart))"/>
-->
													</recurrenceIndex>
													<adherence>
														<xsl:value-of select="adherence"/>
													</adherence>
												</AdherenceItem>
											</document>
											<xsl:if test="adherence='true'">
												<relatesTo>
													<relation type="adherenceResult">
														<!-- TODO: test if contains for each of the vitals; add bloodGlucose-->
														<xsl:if test="systolic">
															<LoadableIndivoDocument>
																<document>
																	<VitalSign
																			xmlns="http://indivo.org/vocab/xml/documents#">
																		<name type="http://codes.indivo.org/vitalsigns/" value="123" abbrev="BPsys">Blood Pressure Systolic</name>
																		<measuredBy><xsl:value-of select="$reportedBy"/></measuredBy>
																		<dateMeasuredStart>
																			<xsl:value-of select="dateReported"/>
																		</dateMeasuredStart>
																		<result>
																			<value><xsl:value-of select="systolic"/></value>
																			<unit type="http://codes.indivo.org/units/" value="31" abbrev="mmHg">millimeters of mercury</unit>
																		</result>
																		<site>left arm</site>
																		<position>sitting</position>
																	</VitalSign>
																</document>
															</LoadableIndivoDocument>
														</xsl:if>
														<xsl:if test="diastolic">
															<LoadableIndivoDocument>
																<document>
																	<VitalSign
																			xmlns="http://indivo.org/vocab/xml/documents#">
																		<name type="http://codes.indivo.org/vitalsigns/" value="124" abbrev="BPdia">Blood Pressure Diastolic</name>
																		<measuredBy><xsl:value-of select="$reportedBy"/></measuredBy>
																		<dateMeasuredStart>
																			<xsl:value-of select="dateReported"/>
																		</dateMeasuredStart>
																		<result>
																			<value><xsl:value-of select="diastolic"/></value>
																			<unit type="http://codes.indivo.org/units/" value="31" abbrev="mmHg">millimeters of mercury</unit>
																		</result>
																		<site>left arm</site>
																		<position>sitting</position>
																	</VitalSign>
																</document>
															</LoadableIndivoDocument>
														</xsl:if>
														<xsl:if test="heartRate">
															<LoadableIndivoDocument>
																<document>
																	<VitalSign
																			xmlns="http://indivo.org/vocab/xml/documents#">
																		<name type="http://codes.indivo.org/vitalsigns/" value="125" abbrev="HR">Heart Rate</name>
																		<measuredBy><xsl:value-of select="$reportedBy"/></measuredBy>
																		<dateMeasuredStart>
																			<xsl:value-of select="dateReported"/>
																		</dateMeasuredStart>
																		<result>
																			<value><xsl:value-of select="heartRate"/></value>
																			<unit type="http://codes.indivo.org/units/" value="30" abbrev="bpm">beats per minute</unit>
																		</result>
																		<site>left arm</site>
																		<position>sitting</position>
																	</VitalSign>
																</document>
															</LoadableIndivoDocument>
														</xsl:if>
														<xsl:if test="bloodGlucose">
															<LoadableIndivoDocument>
																<document>
																	<VitalSign
																			xmlns="http://indivo.org/vocab/xml/documents#">
																		<name>Blood Glucose</name>
																		<measuredBy><xsl:value-of select="$reportedBy"/></measuredBy>
																		<dateMeasuredStart>
																			<xsl:value-of select="dateReported"/>
																		</dateMeasuredStart>
																		<result>
																			<value><xsl:value-of select="bloodGlucose"/></value>
																			<unit abbrev="mg/dL">milligrams per deciliter</unit>
																		</result>
																		<site>abdomen</site>
																	</VitalSign>
																</document>
															</LoadableIndivoDocument>
														</xsl:if>
													</relation>
												</relatesTo>
											</xsl:if>
										</LoadableIndivoDocument>
									</xsl:for-each>
								</relation>
							</relatesTo>
						</LoadableIndivoDocument>
<!--
						<LoadableIndivoDocument>
							<document>
								<EquipmentScheduleItem xmlns="http://indivo.org/vocab/xml/documents#">
									<xsl:copy-of select="$equipmentName"/>
									<scheduledBy>jking@records.media.mit.edu</scheduledBy>
									<dateScheduled>2011-07-28T19:13:11Z</dateScheduled>
									<dateStart>2011-07-29T13:00:00Z</dateStart>
									<dateEnd>2011-07-29T17:00:00Z</dateEnd>
									<recurrenceRule>
										<frequency>DAILY</frequency>
										<count>90</count>
									</recurrenceRule>
									<instructions>press the power button and wait several seconds to take reading
									</instructions>
								</EquipmentScheduleItem>
							</document>
						</LoadableIndivoDocument>
-->
					</relation>
				</relatesTo>
			</LoadableIndivoDocument>
		</IndivoDocuments>
	</xsl:template>

</xsl:stylesheet>