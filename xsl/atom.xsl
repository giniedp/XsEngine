<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
  xmlns:atom="http://www.w3.org/2005/Atom"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:output method="html"/>
  
  <xsl:template match="atom:feed">
    <xsl:apply-templates select="/atom:feed/atom:head"/>
    <xsl:apply-templates select="/atom:feed"/>
  </xsl:template>
  
  <xsl:template match="atom:feed/atom:head">
    <h1><xsl:value-of select="atom:title"/></h1>
    <xsl:if test="atom:tagline"><p><xsl:value-of select="atom:tagline"/></p></xsl:if>
    <xsl:if test="atom:subtitle"><p><xsl:value-of select="atom:subtitle"/></p></xsl:if>
  </xsl:template>
  
  <xsl:template match="/atom:feed">
    <h3><xsl:value-of select="atom:title"/></h3>
    <xsl:if test="atom:tagline"><p><xsl:value-of select="atom:tagline"/></p></xsl:if>
    <xsl:if test="atom:subtitle"><p><xsl:value-of select="atom:subtitle"/></p></xsl:if>
    <ul>
      <xsl:apply-templates select="atom:entry"/>
    </ul>
  </xsl:template>
  
  <xsl:template match="atom:entry">
    <li>
      <a href="{./atom:link/@href}" title="{substring(./atom:published, 0, 11)}"><xsl:value-of select="atom:title"/></a>
      <xsl:choose>
        <xsl:when test="atom:content != ''">
          <p><xsl:value-of select="atom:content" disable-output-escaping="yes" /></p>
        </xsl:when>
        <xsl:otherwise>
          <p><xsl:value-of select="atom:summary" disable-output-escaping="yes" /></p>
        </xsl:otherwise>
      </xsl:choose>
    </li>
  </xsl:template>

</xsl:stylesheet>