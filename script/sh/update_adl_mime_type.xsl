<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8"/>

<xsl:template match="mime-type">
  <xsl:choose>
    <xsl:when test="text()='application/x-opera-widgets'">
      <mime-type><xsl:text disable-output-escaping="yes">application/widget</xsl:text></mime-type>
    </xsl:when>
    <xsl:when test="text()='application/x-opera-widget'">
      <mime-type><xsl:text disable-output-escaping="yes">application/widget</xsl:text></mime-type>
    </xsl:when>
    <xsl:otherwise>
      <mime-type><xsl:apply-templates/></mime-type>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*|text()|@*">
   <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
   </xsl:copy>
</xsl:template>

</xsl:stylesheet>
