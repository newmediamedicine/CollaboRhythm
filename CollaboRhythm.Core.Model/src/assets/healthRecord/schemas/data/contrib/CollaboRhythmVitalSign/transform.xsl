<?xml version="1.0"?>
<xsl:stylesheet xmlns:indivodoc="http://indivo.org/vocab/xml/documents#" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="1.0">
  <xsl:template match="indivodoc:CollaboRhythmVitalSign">
    <Models>
      <Model name="CollaboRhythmVitalSign">
<Field name="name_text"><xsl:value-of select="indivodoc:name/text()"/></Field><xsl:if test="indivodoc:name/@type"><Field name="name_type"><xsl:value-of select="indivodoc:name/@type"/></Field></xsl:if><xsl:if test="indivodoc:name/@value"><Field name="name_value"><xsl:value-of select="indivodoc:name/@value"/></Field></xsl:if><xsl:if test="indivodoc:name/@abbrev"><Field name="name_abbrev"><xsl:value-of select="indivodoc:name/@abbrev"/></Field></xsl:if>
<xsl:if test="indivodoc:measuredBy"><Field name="measuredBy"><xsl:value-of select="indivodoc:measuredBy/text()"/></Field></xsl:if>
<Field name="dateMeasuredStart"><xsl:value-of select="indivodoc:dateMeasuredStart/text()"/></Field>
<xsl:if test="indivodoc:dateMeasuredEnd"><Field name="dateMeasuredEnd"><xsl:value-of select="indivodoc:dateMeasuredEnd/text()"/></Field></xsl:if>
<xsl:if test="indivodoc:result/indivodoc:value"><Field name="result_value"><xsl:value-of select="indivodoc:result/indivodoc:value"/></Field></xsl:if><xsl:if test="indivodoc:result/indivodoc:textValue"><Field name="result_textValue"><xsl:value-of select="indivodoc:result/indivodoc:textValue"/></Field></xsl:if><xsl:if test="indivodoc:result/indivodoc:unit"><Field name="result_unit_text"><xsl:value-of select="indivodoc:result/indivodoc:unit/text()"/></Field><xsl:if test="indivodoc:result/indivodoc:unit/@type"><Field name="result_unit_type"><xsl:value-of select="indivodoc:result/indivodoc:unit/@type"/></Field></xsl:if><xsl:if test="indivodoc:result/indivodoc:unit/@value"><Field name="result_unit_value"><xsl:value-of select="indivodoc:result/indivodoc:unit/@value"/></Field></xsl:if><xsl:if test="indivodoc:result/indivodoc:unit/@abbrev"><Field name="result_unit_abbrev"><xsl:value-of select="indivodoc:result/indivodoc:unit/@abbrev"/></Field></xsl:if></xsl:if>
<xsl:if test="indivodoc:site"><Field name="site"><xsl:value-of select="indivodoc:site/text()"/></Field></xsl:if>
<xsl:if test="indivodoc:position"><Field name="position"><xsl:value-of select="indivodoc:position/text()"/></Field></xsl:if>
<xsl:if test="indivodoc:technique"><Field name="technique"><xsl:value-of select="indivodoc:technique/text()"/></Field></xsl:if>
<xsl:if test="indivodoc:comments"><Field name="comments"><xsl:value-of select="indivodoc:comments/text()"/></Field></xsl:if>
</Model>
    </Models>
  </xsl:template>
</xsl:stylesheet>
