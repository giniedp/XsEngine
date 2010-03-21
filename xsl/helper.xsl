<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" 
  xmlns:x="xsl-layout-engine"
  xmlns="http://www.w3.org/1999/xhtml" >

  <xsl:template name="extract-locale">
    <xsl:param name="uri"/>
    <xsl:choose>
      <xsl:when test="contains($uri, '-')">
        <xsl:call-template name="extract-locale">
          <xsl:with-param name="uri" select="substring-after($uri, '-')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="string($uri)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="x:javascript">
    <xsl:choose>
      <xsl:when test="string(./@src)=''">
        <script type="text/javascript">
          <xsl:value-of select="."/>    
        </script>
      </xsl:when>
      <xsl:otherwise>
        <script type="text/javascript" src="{./@src}" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="x:css">
    <xsl:choose>
      <xsl:when test="string(./@src)=''">
        <style type="text/css"><xsl:value-of select="."/></style>
      </xsl:when>
      <xsl:otherwise>
        <link href="{concat('stylesheets/', @src, '.css')}" rel="stylesheet" type="text/css" ></link>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="i18n">
    <xsl:param name="path"/>
    <xsl:param name="locale"/>
    <xsl:call-template name="i18n-para">
      <xsl:with-param name="context" select="$settings/x:i18n"/>
      <xsl:with-param name="path" select="$path"/>
      <xsl:with-param name="original" select="$path"/>
      <xsl:with-param name="locale" select="$locale"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="i18n-para">
    <xsl:param name="original"/>
    <xsl:param name="path"/>
    <xsl:param name="context"/>
    <xsl:param name="locale"/>
    <xsl:choose>
      <xsl:when test="$path=''"><xsl:value-of select="$original"/></xsl:when>
      <xsl:when test="count($context)=0"><xsl:value-of select="$original"/></xsl:when>
      <xsl:when test="contains($path, '/')">
        <xsl:call-template name="i18n-para">
          <xsl:with-param name="original" select="$original"/>
          <xsl:with-param name="path" select="substring-after($path, '/')"/>
          <xsl:with-param name="context" select="$context/*[1][local-name(.)=substring-before($path, '/')]"/>
          <xsl:with-param name="locale" select="$locale"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="t-node" select="$context/*[local-name(.)=$path][@locale=$locale]"/>
        <xsl:if test="count($t-node)=0"><xsl:value-of select="$original"/></xsl:if>
        <xsl:if test="count($t-node)!=0"><xsl:value-of select="$t-node"/></xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="x:link">
    <xsl:variable name="link" select="$settings/x:settings/x:link[@id=current()/@to]"/>
    <a href="{$link/@target}"><xsl:value-of select="$link/@text"/></a>
  </xsl:template>
  
  <xsl:template match="x:image">
    <xsl:variable name="image" select="$settings//x/image[@name=current()/@src]"/>
   <img src="{$image/src}" alt="{$image/alt}"/>
  </xsl:template>
  
  <xsl:template match="x:imagelink">
    <xsl:variable name="image" select="$settings//x/image[@name=current()/@src]"/>
    <xsl:variable name="link" select="$settings//x/link[@name=current()/@link]"/>
    <a href="{$link/@href}"><img src="{$image/src}" alt="{$image/alt}"/></a>
  </xsl:template>
  
</xsl:stylesheet>
