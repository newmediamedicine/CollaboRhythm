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
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="/">
		<IndivoDocuments>
			<xsl:for-each select="root/data">
				<xsl:if test="systolic">
					<CollaboRhythmVitalSign xmlns="http://indivo.org/vocab/xml/documents#">
						<name type="http://codes.indivo.org/vitalsigns/" value="123" abbrev="BPsys">Blood Pressure Systolic</name>
						<dateMeasuredStart>
							<xsl:value-of select="date"/>
						</dateMeasuredStart>
						<result>
							<value>
								<xsl:value-of select="systolic"/>
							</value>
							<unit type="http://codes.indivo.org/units/" value="31" abbrev="mmHg">millimeters of mercury</unit>
						</result>
						<site>left arm</site>
						<position>sitting down</position>
					</CollaboRhythmVitalSign>
				</xsl:if>
				<xsl:if test="diastolic">
					<CollaboRhythmVitalSign xmlns="http://indivo.org/vocab/xml/documents#">
						<name type="http://codes.indivo.org/vitalsigns/" value="124" abbrev="BPdia">Blood Pressure Diastolic</name>
						<dateMeasuredStart>
							<xsl:value-of select="date"/>
						</dateMeasuredStart>
						<result>
							<value>
								<xsl:value-of select="diastolic"/>
							</value>
							<unit type="http://codes.indivo.org/units/" value="31" abbrev="mmHg">millimeters of mercury</unit>
						</result>
						<site>left arm</site>
						<position>sitting down</position>
					</CollaboRhythmVitalSign>
				</xsl:if>
<!--
				<xsl:if test="adherence = 'yes' or adherence = 'no'">
					<AdherenceItem xmlns="http://indivo.org/vocab/xml/documents#">
						<name type="http://rxnav.nlm.nih.gov/REST/rxcui/" value="310798">Hydrochlorothiazide 25 MG Oral Tablet</name>
						<reportedBy>rpoole@records.media.mit.edu</reportedBy>
						<dateReported>
							<xsl:value-of select="date"/>
						</dateReported>
						<adherence>
							<xsl:choose>
								<xsl:when test="adherence = 'yes'">true</xsl:when>
								<xsl:otherwise>false</xsl:otherwise>
							</xsl:choose>
						</adherence>
					</AdherenceItem>
				</xsl:if>
-->
			</xsl:for-each>
		</IndivoDocuments>
	</xsl:template>

</xsl:stylesheet>