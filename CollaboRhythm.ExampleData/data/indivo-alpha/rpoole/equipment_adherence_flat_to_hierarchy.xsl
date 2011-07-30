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
		<xsl:variable name="dateStart">2010-01-15T13:00:00Z</xsl:variable>
		<xsl:variable name="equipmentName" select="IndivoDocuments/d:VitalSign[1]/d:name"/>
		<xsl:variable name="reportedBy" select="IndivoDocuments/d:VitalSign[1]/d:reportedBy"/>
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
									<dateScheduled>2010-01-14T19:13:11Z</dateScheduled>
									<dateStart>
										<xsl:value-of select="$dateStart"/>
									</dateStart>
									<dateEnd>2010-01-15T17:00:00Z</dateEnd>
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
									<xsl:for-each select="IndivoDocuments/d:AdherenceItem">
										<xsl:variable name="adherenceCount" select="position() - 1"/>
										<LoadableIndivoDocument>
											<document>
												<AdherenceItem xmlns="http://indivo.org/vocab/xml/documents#">
													<xsl:copy-of select="$equipmentName"/>
													<xsl:copy-of select="$reportedBy"/>
													<dateReported>
														<xsl:value-of select="d:dateReported"/>
													</dateReported>
													<recurrenceIndex>
														<xsl:value-of
																select="fn:days-from-duration(xs:dateTime(d:dateReported) - xs:dateTime($dateStart))"/>
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
																<VitalSign
																		xmlns="http://indivo.org/vocab/xml/documents#">
																	<xsl:copy-of select="$equipmentName"/>
																	<xsl:copy-of select="$reportedBy"/>
																	<dateReported>
																		<xsl:value-of select="d:dateReported"/>
																	</dateReported>
																	<dateAdministered>
																		<xsl:value-of select="d:dateReported"/>
																	</dateAdministered>
																	<amountAdministered>
																		<value>1</value>
																		<unit>tablet</unit>
																	</amountAdministered>
																	<!--Note that this value will be off if we have any "false" adherence values-->
																	<!--
																				 <current><xsl:value-of select="current()" /></current>
																				 <preceding0><xsl:value-of select="preceding::*[.='true']" /></preceding0>
																				 <precedingName><xsl:value-of select="name(preceding::*[.='true'][1])" /></precedingName>
																				 <precedingTrue><xsl:value-of select="count(preceding::*[.='true'])" /></precedingTrue>
																				 <precedingAdherenceTrue><xsl:value-of select="count(preceding::adherence[.='true'])" /></precedingAdherenceTrue>
																				 <precedingAdherenceTrue><xsl:value-of select="count(preceding::*[adherence='true'])" /></precedingAdherenceTrue>
																				 <precedingAdherenceCount><xsl:value-of select="('adherence', count(preceding::*/adherence))" /></precedingAdherenceCount>
																				 <amountRemainingvalue><xsl:value-of select="('all preceding', count(preceding::*))" /></amountRemainingvalue>
																				 <amountRemainingvalue><xsl:value-of select="('AdIt', count(preceding::*[@adherence]))" /></amountRemainingvalue>
																				 <amountRemainingvalue><xsl:value-of select="count(preceding::*='true')" /></amountRemainingvalue>
																				 <amountRemainingvalue><xsl:value-of select="$numPillsOrdered - count(current()/preceding::AdherenceItem) - 1" /></amountRemainingvalue>
																				 <amountRemainingvalue2><xsl:value-of select="$numPillsOrdered - count(current()/following::AdherenceItem) - 1" /></amountRemainingvalue2>
																				 <xsl:value-of select="$numPillsOrdered - count(preceding::AdherenceItem/adherence='true') - 1" />
																				 <precedingTrue><xsl:value-of select="count(preceding::*[.='true'])" /></precedingTrue>
																				 <amountRemaining><value><xsl:value-of select="$numPillsOrdered - count(preceding::d:adherence[.='true']) - 1" /></value>
				 -->
																	<amountRemaining>
																		<value>
																			<xsl:value-of
																					select="$numPillsOrdered - count(preceding::d:adherence[.='true']) - 1"/>
																		</value>
																		<unit>tablet</unit>
																	</amountRemaining>
																</VitalSign>
															</document>
														</LoadableIndivoDocument>
													</relation>
												</relatesTo>
											</xsl:if>
										</LoadableIndivoDocument>
									</xsl:for-each>
								</relation>
							</relatesTo>
						</LoadableIndivoDocument>
					</relation>
				</relatesTo>
			</LoadableIndivoDocument>
		</IndivoDocuments>
	</xsl:template>

</xsl:stylesheet>