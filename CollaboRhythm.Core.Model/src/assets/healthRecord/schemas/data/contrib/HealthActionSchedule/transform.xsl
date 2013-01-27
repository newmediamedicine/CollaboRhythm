<?xml version="1.0"?>
<xsl:stylesheet xmlns:indivodoc="http://indivo.org/vocab/xml/documents#" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="1.0">
  <xsl:template match="indivodoc:HealthActionSchedule">
    <Models>
      <Model name="HealthActionSchedule">
<Field name="name_text"><xsl:value-of select="indivodoc:name/text()"/></Field><xsl:if test="indivodoc:name/@type"><Field name="name_type"><xsl:value-of select="indivodoc:name/@type"/></Field></xsl:if><xsl:if test="indivodoc:name/@value"><Field name="name_value"><xsl:value-of select="indivodoc:name/@value"/></Field></xsl:if><xsl:if test="indivodoc:name/@abbrev"><Field name="name_abbrev"><xsl:value-of select="indivodoc:name/@abbrev"/></Field></xsl:if>
<Field name="scheduledBy"><xsl:value-of select="indivodoc:scheduledBy/text()"/></Field>
<Field name="dateScheduled"><xsl:value-of select="indivodoc:dateScheduled/text()"/></Field>
<Field name="dateStart"><xsl:value-of select="indivodoc:dateStart/text()"/></Field>
<xsl:if test="indivodoc:dateEnd"><Field name="dateEnd"><xsl:value-of select="indivodoc:dateEnd/text()"/></Field></xsl:if>
<xsl:if test="indivodoc:recurrenceRule"><Field name="recurrenceRule_frequency"><xsl:value-of select="indivodoc:recurrenceRule/indivodoc:frequency/text()"/></Field><xsl:if test="indivodoc:recurrenceRule/indivodoc:interval"><Field name="recurrenceRule_interval"><xsl:value-of select="indivodoc:recurrenceRule/indivodoc:interval/text()"/></Field></xsl:if><xsl:if test="indivodoc:recurrenceRule/indivodoc:count"><Field name="recurrenceRule_count"><xsl:value-of select="indivodoc:recurrenceRule/indivodoc:count/text()"/></Field></xsl:if></xsl:if>
<xsl:if test="indivodoc:instructions"><Field name="instructions"><xsl:value-of select="indivodoc:instructions/text()"/></Field></xsl:if>
</Model>
    </Models>
  </xsl:template>
</xsl:stylesheet>
