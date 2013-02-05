<?xml version="1.0"?>
<xsl:stylesheet xmlns:indivodoc="http://indivo.org/vocab/xml/documents#" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="1.0">
  <xsl:template match="indivodoc:AdherenceItem">
    <Models>
      <Model name="AdherenceItem">
<Field name="name_text"><xsl:value-of select="indivodoc:name/text()"/></Field><xsl:if test="indivodoc:name/@type"><Field name="name_type"><xsl:value-of select="indivodoc:name/@type"/></Field></xsl:if><xsl:if test="indivodoc:name/@value"><Field name="name_value"><xsl:value-of select="indivodoc:name/@value"/></Field></xsl:if><xsl:if test="indivodoc:name/@abbrev"><Field name="name_abbrev"><xsl:value-of select="indivodoc:name/@abbrev"/></Field></xsl:if>
<Field name="reportedBy"><xsl:value-of select="indivodoc:reportedBy/text()"/></Field>
<Field name="dateReported"><xsl:value-of select="indivodoc:dateReported/text()"/></Field>
<xsl:if test="indivodoc:recurrenceIndex"><Field name="recurrenceIndex"><xsl:value-of select="indivodoc:recurrenceIndex/text()"/></Field></xsl:if>
<Field name="adherence"><xsl:value-of select="indivodoc:adherence/text()"/></Field>
<xsl:if test="indivodoc:nonadherenceReason"><Field name="nonadherenceReason"><xsl:value-of select="indivodoc:nonadherenceReason/text()"/></Field></xsl:if>
</Model>
    </Models>
  </xsl:template>
</xsl:stylesheet>
