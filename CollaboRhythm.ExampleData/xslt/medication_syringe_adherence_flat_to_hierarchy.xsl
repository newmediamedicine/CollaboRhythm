<!--~
  ~ Copyright 2012 John Moore, Scott Gilroy
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
		<xsl:variable name="amountOrderedValue" select="2"/>
		<xsl:variable name="unitsPerSyringe" select="1000"/>
		<xsl:variable name="dateStart">2011-07-15T13:00:00Z</xsl:variable>
		<xsl:variable name="dateEnd">2011-07-15T17:00:00Z</xsl:variable>
		<xsl:variable name="dateStartEvening">2011-07-15T22:00:00Z</xsl:variable>
		<xsl:variable name="dateEndEvening">2011-07-16T02:00:00Z</xsl:variable>
		<xsl:variable name="medicationName" select="IndivoDocuments/d:AdherenceItem[1]/d:name"/>
		<xsl:variable name="reportedBy" select="IndivoDocuments/d:AdherenceItem[1]/d:reportedBy"/>
		<xsl:variable name="ndc" select="IndivoDocuments/d:AdherenceItem[1]/d:ndc"/>
		<xsl:variable name="indication" select="IndivoDocuments/d:AdherenceItem[1]/d:indication"/>
		<xsl:variable name="twiceDaily" select="IndivoDocuments/d:AdherenceItem[1]/d:twiceDaily"/>
		<IndivoDocuments>
			<LoadableIndivoDocument>
				<document>
					<MedicationOrder xmlns="http://indivo.org/vocab/xml/documents#">
						<xsl:copy-of select="$medicationName"/>
						<orderType>prescribed</orderType>
						<orderedBy>jking@records.media.mit.edu</orderedBy>
						<dateOrdered>2011-07-14T09:00:00-04:00</dateOrdered>
						<dateExpires>2012-07-14T09:00:00-04:00</dateExpires>
						<xsl:copy-of select="$indication"/>
						<amountOrdered>
							<value><xsl:value-of select="$amountOrderedValue"/></value>
                            <unit type="http://indivo.org/codes/units#" value="prefilled syringe" abbrev="prefilled syringe">prefilled syringe</unit>
						</amountOrdered>
                        <substitutionPermitted>false</substitutionPermitted>
                       	<instructions>take in the evening</instructions>
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
										<value><xsl:value-of select="$amountOrderedValue"/></value>
                                        <unit type="http://indivo.org/codes/units#" value="prefilled syringe" abbrev="prefilled syringe">prefilled syringe</unit>
									</amountFilled>
									<xsl:copy-of select="$ndc"/>
                                    <instructions>keep in a cold place</instructions>
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
										<frequency>DAILY</frequency>
										<xsl:choose>
											<xsl:when test="$twiceDaily = 'true'">
												<count><xsl:value-of select="$amountOrderedValue div 2"/></count>
											</xsl:when>
											<xsl:otherwise>
													<count><xsl:value-of select="$amountOrderedValue"/></count>
											</xsl:otherwise>
										</xsl:choose>
									</recurrenceRule>
									<dose>
                                        <value>12</value>
                                        <unit type="http://indivo.org/codes/units#" value="Units" abbrev="U">Units</unit>
									</dose>
                                    <instructions>rotate injection sites</instructions>
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
																		<value>12</value>
																		<unit type="http://indivo.org/codes/units#" value="Units" abbrev="U">Units</unit>
																	</amountAdministered>
																	<!--Note that this value will be off if we have any "false" adherence values-->
																	<amountRemaining>
<!--
																		<value><xsl:value-of select="$amountOrderedValue * $unitsPerSyringe - (count(preceding::d:adherence[.='true']) - 1) * 12" /></value>
																		<unit type="http://indivo.org/codes/units#" value="Units" abbrev="U">Units</unit>
-->
																		<value><xsl:value-of select="($amountOrderedValue * $unitsPerSyringe - (count(preceding::d:adherence[.='true'])) * 12) div $unitsPerSyringe" /></value>
																		<unit type="http://indivo.org/codes/units#" value="prefilled syringe" abbrev="prefilled syringe">prefilled syringe</unit>
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
											<count><xsl:value-of select="$amountOrderedValue div 2"/></count>
										</recurrenceRule>
										<dose>
											<value>12</value>
											<unit type="http://indivo.org/codes/units#" value="Units" abbrev="U">Units</unit>
										</dose>
										<instructions>rotate injection sites</instructions>
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
																			<value>12</value>
																			<unit type="http://indivo.org/codes/units#" value="Units" abbrev="U">Units</unit>
																		</amountAdministered>
																		<!--Note that this value will be off if we have any "false" adherence values-->
																		<amountRemaining>
																			<value><xsl:value-of select="$amountOrderedValue * $unitsPerSyringe - (count(preceding::d:adherence[.='true']) - 1) * 12" /></value>
																			<unit type="http://indivo.org/codes/units#" value="Units" abbrev="U">Units</unit>
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
										<count><xsl:value-of select="$amountOrderedValue"/></count>
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
											<count><xsl:value-of select="$amountOrderedValue"/></count>
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