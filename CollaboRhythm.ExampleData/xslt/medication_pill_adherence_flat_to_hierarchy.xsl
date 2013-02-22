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
		<xsl:variable name="numPillsOrdered" select="90"/>
		<xsl:variable name="dateStartCustom" select="IndivoDocuments/d:AdherenceItem[1]/d:scheduleDateStart"/>
		<xsl:variable name="dateStart">
			<xsl:choose>
				<xsl:when test="$dateStartCustom">
					<xsl:value-of select="xs:dateTime($dateStartCustom)"/>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="xs:dateTime('2011-07-15T13:00:00Z')"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="dateEndCustom" select="IndivoDocuments/d:AdherenceItem[1]/d:scheduleDateEnd"/>
		<xsl:variable name="dateEnd">
			<xsl:choose>
				<xsl:when test="$dateEndCustom">
					<xsl:value-of select="$dateEndCustom"/>
				</xsl:when>
				<xsl:otherwise>2011-07-15T17:00:00Z</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="dateStartEvening">2011-07-15T22:00:00Z</xsl:variable>
		<xsl:variable name="dateEndEvening">2011-07-16T02:00:00Z</xsl:variable>
		<xsl:variable name="medicationName" select="IndivoDocuments/d:AdherenceItem[1]/d:name"/>
		<xsl:variable name="medicationScheduleItemInstructionsCustom" select="IndivoDocuments/d:AdherenceItem[1]/d:instructions"/>
		<xsl:variable name="medicationScheduleItemInstructions">
			<xsl:choose>
				<xsl:when test="$medicationScheduleItemInstructionsCustom">
					<xsl:value-of select="$medicationScheduleItemInstructionsCustom"/>
				</xsl:when>
				<xsl:otherwise>Take with water</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="reportedBy" select="IndivoDocuments/d:AdherenceItem[1]/d:reportedBy"/>
		<xsl:variable name="ndc" select="IndivoDocuments/d:AdherenceItem[1]/d:ndc"/>
		<xsl:variable name="indication" select="IndivoDocuments/d:AdherenceItem[1]/d:indication"/>
		<xsl:variable name="twiceDaily" select="IndivoDocuments/d:AdherenceItem[1]/d:twiceDaily"/>
		<xsl:variable name="recurrenceFrequencyCustom" select="IndivoDocuments/d:AdherenceItem[1]/d:recurrenceFrequency"/>
		<xsl:variable name="recurrenceFrequency">
			<xsl:choose>
				<xsl:when test="$recurrenceFrequencyCustom">
					<xsl:value-of select="$recurrenceFrequencyCustom"/>
				</xsl:when>
				<xsl:otherwise>DAILY</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="recurrenceInterval" select="IndivoDocuments/d:AdherenceItem[1]/d:recurrenceInterval"/>
		<xsl:variable name="recurrenceCount" select="IndivoDocuments/d:AdherenceItem[1]/d:recurrenceCount"/>
		<IndivoDocuments>
			<LoadableIndivoDocument>
				<document>
					<MedicationOrder xmlns="http://indivo.org/vocab/xml/documents#">
						<xsl:copy-of select="$medicationName"/>
						<orderType>prescribed</orderType>
						<orderedBy>jking@records.media.mit.edu</orderedBy>
						<dateOrdered>2011-07-14T19:13:11Z</dateOrdered>
						<dateExpires>2012-07-14T09:00:00-04:00</dateExpires>
						<xsl:copy-of select="$indication"/>
						<amountOrdered>
							<value><xsl:value-of select="$numPillsOrdered"/></value>
							<unit type="http://indivo.org/codes/units#" value="tab" abbrev="tab">tablet</unit>
						</amountOrdered>
						<substitutionPermitted>true</substitutionPermitted>
						<instructions><xsl:value-of select="$medicationScheduleItemInstructions"/></instructions>
					</MedicationOrder>
				</document>
				<relatesTo>
					<relation type="medicationFill">
						<!-- child elements can be either (1) IndivoDocumentWithRelationships or (2) IndivoDocument document type -->
						<LoadableIndivoDocument>
							<document>
								<MedicationFill xmlns="http://indivo.org/vocab/xml/documents#">
									<xsl:copy-of select="$medicationName"/>
									<filledBy>ljohnson@records.media.mit.edu</filledBy>
									<dateFilled>2011-07-14T19:13:11Z</dateFilled>
									<amountFilled>
										<value><xsl:value-of select="$numPillsOrdered"/></value>
										<unit>tab</unit>
									</amountFilled>
									<xsl:copy-of select="$ndc"/>
									<instructions>Do not expose to direct sunlight</instructions>
								</MedicationFill>
							</document>
						</LoadableIndivoDocument>
					</relation>
					<relation type="scheduleItem">
						<!-- child elements can be either (1) IndivoDocumentWithRelationships or (2) IndivoDocument document type -->
						<LoadableIndivoDocument>
							<document>
								<MedicationScheduleItem xmlns="http://indivo.org/vocab/xml/documents#">
									<xsl:copy-of select="$medicationName"/>
									<scheduledBy>jking@records.media.mit.edu</scheduledBy>
									<dateScheduled>2011-07-14T19:13:11Z</dateScheduled>
									<dateStart><xsl:value-of select="$dateStart"/></dateStart>
									<dateEnd><xsl:value-of select="$dateEnd"/></dateEnd>
									<recurrenceRule>
										<frequency><xsl:value-of select="$recurrenceFrequency"/></frequency>
										<xsl:if test="$recurrenceInterval != ''">
											<interval><xsl:value-of select="$recurrenceInterval"/></interval>
										</xsl:if>
										<xsl:choose>
											<xsl:when test="$recurrenceCount">
												<count><xsl:value-of select="$recurrenceCount"/></count>
											</xsl:when>
											<xsl:when test="$twiceDaily = 'true'">
												<count><xsl:value-of select="$numPillsOrdered div 2"/></count>
											</xsl:when>
											<xsl:otherwise>
												<count><xsl:value-of select="$numPillsOrdered"/></count>
											</xsl:otherwise>
										</xsl:choose>
									</recurrenceRule>
									<dose>
										<value>1</value>
										<unit type="http://indivo.org/codes/units#" value="tab" abbrev="tab">tablet</unit>
									</dose>
									<instructions><xsl:value-of select="$medicationScheduleItemInstructions"/></instructions>
								</MedicationScheduleItem>
							</document>
							<relatesTo>
								<relation type="adherenceItem">
									<xsl:for-each select="IndivoDocuments/d:AdherenceItem">
										<xsl:if test="not($twiceDaily = 'true') or fn:hours-from-dateTime(xs:dateTime(d:dateReported)) >= 4">
											<xsl:variable name="adherenceCount" select="position() - 1"/>
											<LoadableIndivoDocument>
												<document>
													<AdherenceItem xmlns="http://indivo.org/vocab/xml/documents#">
														<xsl:copy-of select="$medicationName"/>
														<xsl:copy-of select="$reportedBy"/>
														<dateReported>
															<xsl:value-of select="d:dateReported"/>
														</dateReported>
														<recurrenceIndex>
															<xsl:choose>
																<xsl:when test="d:recurrenceIndex">
																	<xsl:value-of select="d:recurrenceIndex"/>
																</xsl:when>
																<xsl:otherwise>
																	<xsl:value-of
																			select="fn:days-from-duration(xs:dateTime(d:dateReported) - xs:dateTime($dateStart))"/>
																</xsl:otherwise>
															</xsl:choose>
														</recurrenceIndex>
														<adherence>
															<xsl:value-of select="d:adherence"/>
														</adherence>
													</AdherenceItem>
												</document>
												<xsl:if test="d:adherence='true'">
													<relatesTo>
													<relation type="adherenceResult">
														<LoadableIndivoDocument>
															<document>
																<MedicationAdministration xmlns="http://indivo.org/vocab/xml/documents#">
																	<xsl:copy-of select="$medicationName"/>
																	<xsl:copy-of select="$reportedBy"/>
																	<dateReported><xsl:value-of select="d:dateReported"/></dateReported>
																	<dateAdministered><xsl:value-of select="d:dateReported"/></dateAdministered>
																	<amountAdministered>
																		<value>
																			<xsl:choose>
																				<xsl:when test="d:amountAdministeredValue">
																					<xsl:value-of select="d:amountAdministeredValue"/>
																				</xsl:when>
																				<xsl:otherwise>1</xsl:otherwise>
																			</xsl:choose>
																		</value>
																		<unit>
																			<xsl:choose>
																				<xsl:when test="d:amountAdministeredUnit">
																					<xsl:value-of select="d:amountAdministeredUnit"/>
																				</xsl:when>
																				<xsl:otherwise>tablet</xsl:otherwise>
																			</xsl:choose>
																		</unit>
																	</amountAdministered>
																	<!--Note that this value will be off if we have any "false" adherence values-->
																	<amountRemaining><value><xsl:value-of select="$numPillsOrdered - count(preceding::d:adherence[.='true']) - 1" /></value>
																		<unit>tablet</unit>
																	</amountRemaining>
																</MedicationAdministration>
															</document>
															<xsl:if test="d:symptoms or d:trigger">
																<relatesTo>
																	<relation type="annotation">
																		<xsl:if test="d:symptoms">
																			<LoadableIndivoDocument>
																				<document>
																					<CollaboRhythmVitalSign
																							xmlns="http://indivo.org/vocab/xml/documents#">
																						<name>asthma symptom</name>
																						<measuredBy><xsl:value-of select="$reportedBy"/></measuredBy>
																						<dateMeasuredStart>
																							<xsl:value-of select="d:dateReported"/>
																						</dateMeasuredStart>
																						<result>
																							<value>1</value>
																							<textValue><xsl:value-of select="d:symptoms"/></textValue>
																							<unit>Count</unit>
																						</result>
																					</CollaboRhythmVitalSign>
																				</document>
																			</LoadableIndivoDocument>
																		</xsl:if>
																		<xsl:if test="d:trigger">
																			<LoadableIndivoDocument>
																				<document>
																					<CollaboRhythmVitalSign
																							xmlns="http://indivo.org/vocab/xml/documents#">
																						<name>asthma trigger</name>
																						<measuredBy><xsl:value-of select="$reportedBy"/></measuredBy>
																						<dateMeasuredStart>
																							<xsl:value-of select="d:dateReported"/>
																						</dateMeasuredStart>
																						<result>
																							<value>1</value>
																							<textValue><xsl:value-of select="d:trigger"/></textValue>
																							<unit>Count</unit>
																						</result>
																					</CollaboRhythmVitalSign>
																				</document>
																			</LoadableIndivoDocument>
																		</xsl:if>
																	</relation>
																</relatesTo>
															</xsl:if>
														</LoadableIndivoDocument>
													</relation>
												</relatesTo>
												</xsl:if>
											</LoadableIndivoDocument>
										</xsl:if>

									</xsl:for-each>
								</relation>
							</relatesTo>
						</LoadableIndivoDocument>
						<xsl:if test="$twiceDaily = 'true'">
							<LoadableIndivoDocument>
								<document>
									<MedicationScheduleItem xmlns="http://indivo.org/vocab/xml/documents#">
										<xsl:copy-of select="$medicationName"/>
										<scheduledBy>jking@records.media.mit.edu</scheduledBy>
										<dateScheduled>2011-07-14T19:13:11Z</dateScheduled>
										<dateStart><xsl:value-of select="$dateStartEvening"/></dateStart>
										<dateEnd><xsl:value-of select="$dateEndEvening"/></dateEnd>
										<recurrenceRule>
											<frequency>DAILY</frequency>
											<count><xsl:value-of select="$numPillsOrdered div 2"/></count>
										</recurrenceRule>
										<dose>
											<value>1</value>
											<unit type="http://indivo.org/codes/units#" value="tab" abbrev="tab">tablet</unit>
										</dose>
										<instructions>take with water</instructions>
									</MedicationScheduleItem>
								</document>
								<relatesTo>
									<relation type="adherenceItem">
										<xsl:for-each select="IndivoDocuments/d:AdherenceItem">
											<xsl:if test="fn:hours-from-dateTime(xs:dateTime(d:dateReported)) &lt; 4">
												<xsl:variable name="adherenceCount" select="position() - 1"/>
												<LoadableIndivoDocument>
													<document>
														<AdherenceItem xmlns="http://indivo.org/vocab/xml/documents#">
															<xsl:copy-of select="$medicationName"/>
															<xsl:copy-of select="$reportedBy"/>
															<dateReported>
																<xsl:value-of select="d:dateReported"/>
															</dateReported>
															<recurrenceIndex><xsl:value-of select="fn:days-from-duration(xs:dateTime(d:dateReported) - xs:dateTime($dateStart))" /></recurrenceIndex>
															<adherence>
																<xsl:value-of select="d:adherence"/>
															</adherence>
														</AdherenceItem>
													</document>
													<xsl:if test="d:adherence='true'">
														<relatesTo>
														<relation type="adherenceResult">
															<LoadableIndivoDocument>
																<document>
																	<MedicationAdministration xmlns="http://indivo.org/vocab/xml/documents#">
																		<xsl:copy-of select="$medicationName"/>
																		<xsl:copy-of select="$reportedBy"/>
																		<dateReported><xsl:value-of select="d:dateReported"/></dateReported>
																		<dateAdministered><xsl:value-of select="d:dateReported"/></dateAdministered>
																		<amountAdministered>
																			<value>1</value>
																			<unit>tablet</unit>
																		</amountAdministered>
																		<!--Note that this value will be off if we have any "false" adherence values-->
																		<amountRemaining><value><xsl:value-of select="$numPillsOrdered - count(preceding::d:adherence[.='true']) - 1" /></value>
																			<unit>tablet</unit>
																		</amountRemaining>
																	</MedicationAdministration>
																</document>
															</LoadableIndivoDocument>
														</relation>
													</relatesTo>
													</xsl:if>
												</LoadableIndivoDocument>
											</xsl:if>
										</xsl:for-each>

									</relation>
								</relatesTo>
							</LoadableIndivoDocument>

						</xsl:if>
<!--
						<LoadableIndivoDocument>
							<document>
								<MedicationScheduleItem xmlns="http://indivo.org/vocab/xml/documents#">
									<xsl:copy-of select="$medicationName"/>
									<scheduledBy>jking@records.media.mit.edu</scheduledBy>
									<dateScheduled>2011-07-28T19:13:11Z</dateScheduled>
									<dateStart>2011-07-29T13:00:00Z</dateStart>
									<dateEnd>2011-07-29T17:00:00Z</dateEnd>
									<recurrenceRule>
										<frequency>DAILY</frequency>
										<count><xsl:value-of select="$numPillsOrdered"/></count>
									</recurrenceRule>
									<dose>
										<value>1</value>
										<unit type="http://indivo.org/codes/units#" value="tab" abbrev="tab">tablet</unit>
									</dose>
									<instructions>take with water</instructions>
								</MedicationScheduleItem>
							</document>
						</LoadableIndivoDocument>
						<xsl:if test="$twiceDaily = 'true'">
							<LoadableIndivoDocument>
								<document>
									<MedicationScheduleItem xmlns="http://indivo.org/vocab/xml/documents#">
										<xsl:copy-of select="$medicationName"/>
										<scheduledBy>jking@records.media.mit.edu</scheduledBy>
										<dateScheduled>2011-07-28T19:13:11Z</dateScheduled>
										<dateStart>2011-07-29T22:00:00Z</dateStart>
										<dateEnd>2011-07-30T02:00:00Z</dateEnd>
										<recurrenceRule>
											<frequency>DAILY</frequency>
											<count><xsl:value-of select="$numPillsOrdered"/></count>
										</recurrenceRule>
										<dose>
											<value>1</value>
											<unit type="http://indivo.org/codes/units#" value="tab" abbrev="tab">tablet</unit>
										</dose>
										<instructions>take with water</instructions>
									</MedicationScheduleItem>
								</document>
							</LoadableIndivoDocument>
						</xsl:if>
-->
					</relation>
				</relatesTo>
			</LoadableIndivoDocument>
		</IndivoDocuments>
	</xsl:template>

</xsl:stylesheet>