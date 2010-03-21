<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" 
  xmlns:x="xsl-layout-engine"
  xmlns="http://www.w3.org/1999/xhtml">

  <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"
              doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>

  <xsl:variable name="settings" select="document('./_config.xml')/x:settings"/>
  
  <xsl:template match="/x:page">
    
    <xsl:variable name="page-uri" select="string(/x:page/@uri)"/>
    <xsl:variable name="locale">
      <xsl:call-template name="extract-locale">
        <xsl:with-param name="uri" select="substring-before($page-uri, '.xml')"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="layout-uri">
      <xsl:choose>
        <xsl:when test="count(/x:page/@layout)=0">layouts/default.xml</xsl:when>
        <xsl:otherwise>layouts/<xsl:value-of select="string(/x:page/@layout)"/>.xml</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="template-uri">
      <xsl:choose>
        <xsl:when test="count(/x:page/@template)=0">templates/<xsl:value-of select="substring-before($page-uri, concat('-', $locale, '.xml'))"/>.xml</xsl:when>
        <xsl:otherwise>templates/<xsl:value-of select="/x:page/@template"/>.xml</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!--
    page-uri=<xsl:value-of select="$page-uri"/>
    locale=<xsl:value-of select="$locale"/>
    layout-uri=<xsl:value-of select="$layout-uri"/>
    template-uri=<xsl:value-of select="$template-uri"/>
    -->
    
    <xsl:variable name="layout" select="document($layout-uri)/x:layout"/>
    <xsl:variable name="template" select="document(normalize-space($template-uri))/x:template"/>
    <xsl:variable name="page" select="document($page-uri)/x:page"/>
    
    <xsl:apply-templates select="$layout">
      <xsl:with-param name="layout" select="$layout"/>
      <xsl:with-param name="template" select="$template"/>
      <xsl:with-param name="page" select="$page"/>
      <xsl:with-param name="locale" select="$locale"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <!-- ======================================================================================== -->
  <!-- TRANSFORM -->
  <!-- ======================================================================================== -->
  
  <xsl:template match="x:layout">
    <xsl:param name="layout"/>
    <xsl:param name="template"/>
    <xsl:param name="page"/>
    <xsl:param name="locale"/>
    <xsl:apply-templates>
      <xsl:with-param name="layout" select="$layout"/>
      <xsl:with-param name="template" select="$template"/>
      <xsl:with-param name="page" select="$page"/>
      <xsl:with-param name="locale" select="$locale"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="x:define"/>
  <xsl:template match="x:template|x:page|x:yield-t|x:yield-p|x:content|x:import|x:include">
    <xsl:param name="layout"/>
    <xsl:param name="template"/>
    <xsl:param name="page"/>
    <xsl:param name="locale"/>
    <xsl:apply-templates>
      <xsl:with-param name="layout" select="$layout"/>
      <xsl:with-param name="template" select="$template"/>
      <xsl:with-param name="page" select="$page"/>
      <xsl:with-param name="locale" select="$locale"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="x:get[@content][@from]">
    <xsl:param name="layout"/>
    <xsl:param name="template"/>
    <xsl:param name="page"/>
    <xsl:param name="locale"/>
    <xsl:choose>
      <xsl:when test="@from='layout'">
        <xsl:apply-templates select="$layout/x:content[@for=current()/@content]">
          <xsl:with-param name="layout" select="$layout"/>
          <xsl:with-param name="template" select="$template"/>
          <xsl:with-param name="page" select="$page"/>
          <xsl:with-param name="locale" select="$locale"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="@from='template'">
        <xsl:apply-templates select="$template/x:content[@for=current()/@content]">
          <xsl:with-param name="layout" select="$layout"/>
          <xsl:with-param name="template" select="$template"/>
          <xsl:with-param name="page" select="$page"/>
          <xsl:with-param name="locale" select="$locale"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="@from='page'">
        <xsl:apply-templates select="$page/x:content[@for=current()/@content]">
          <xsl:with-param name="layout" select="$layout"/>
          <xsl:with-param name="template" select="$template"/>
          <xsl:with-param name="page" select="$page"/>
          <xsl:with-param name="locale" select="$locale"/>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="x:show-if[@defined][@in]">
    <xsl:param name="layout"/>
    <xsl:param name="template"/>
    <xsl:param name="page"/>
    <xsl:param name="locale"/>
    <xsl:param name="continue">
      <xsl:choose>
        <xsl:when test="@in='layout'">
          <xsl:value-of select="boolean($layout/x:define/@*[local-name()=current()/@defined])"/>
        </xsl:when>
        <xsl:when test="@in='template'">
          <xsl:value-of select="boolean($template/x:define/@*[local-name()=current()/@defined])"/>
        </xsl:when>
        <xsl:when test="@in='page'">
          <xsl:value-of select="boolean($page/x:define/@*[local-name()=current()/@defined])"/>
        </xsl:when>
        <xsl:when test="@in='any'">
          <xsl:value-of select=
            "boolean($layout/x:define/@*[local-name()=current()/@defined]) or
             boolean($template/x:define/@*[local-name()=current()/@defined]) or
             boolean($page/x:define/@*[local-name()=current()/@defined])"/>
        </xsl:when>
        <xsl:when test="@in='all'">
          <xsl:value-of select=
            "boolean($layout/x:define/@*[local-name()=current()/@defined]) and
            boolean($template/x:define/@*[local-name()=current()/@defined]) and
            boolean($page/x:define/@*[local-name()=current()/@defined])"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:if test="$continue=string(true())">
      <xsl:apply-templates>
        <xsl:with-param name="layout" select="$layout"/>
        <xsl:with-param name="template" select="$template"/>
        <xsl:with-param name="page" select="$page"/>
        <xsl:with-param name="locale" select="$locale"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="x:import-if[@defined][@in]">
    <xsl:param name="layout"/>
    <xsl:param name="template"/>
    <xsl:param name="page"/>
    <xsl:param name="locale"/>
    <xsl:param name="continue">
      <xsl:choose>
        <xsl:when test="@in='layout'">
          <xsl:value-of select="boolean($layout/x:define/@*[local-name()=current()/@defined])"/>
        </xsl:when>
        <xsl:when test="@in='template'">
          <xsl:value-of select="boolean($template/x:define/@*[local-name()=current()/@defined])"/>
        </xsl:when>
        <xsl:when test="@in='page'">
          <xsl:value-of select="boolean($page/x:define/@*[local-name()=current()/@defined])"/>
        </xsl:when>
        <xsl:when test="@in='any'">
          <xsl:value-of select=
            "boolean($layout/x:define/@*[local-name()=current()/@defined]) or
            boolean($template/x:define/@*[local-name()=current()/@defined]) or
            boolean($page/x:define/@*[local-name()=current()/@defined])"/>
        </xsl:when>
        <xsl:when test="@in='all'">
          <xsl:value-of select=
            "boolean($layout/x:define/@*[local-name()=current()/@defined]) and
            boolean($template/x:define/@*[local-name()=current()/@defined]) and
            boolean($page/x:define/@*[local-name()=current()/@defined])"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:if test="$continue=string(true())">
      <xsl:apply-templates select="./*|./text()">
        <xsl:with-param name="layout" select="$layout"/>
        <xsl:with-param name="template" select="$template"/>
        <xsl:with-param name="page" select="$page"/>
        <xsl:with-param name="locale" select="$locale"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="x:include-if[@defined][@in]">
    <xsl:param name="layout"/>
    <xsl:param name="template"/>
    <xsl:param name="page"/>
    <xsl:param name="locale"/>
    <xsl:param name="continue">
      <xsl:choose>
        <xsl:when test="@in='layout'">
          <xsl:value-of select="boolean($layout/x:define/@*[local-name()=current()/@defined])"/>
        </xsl:when>
        <xsl:when test="@in='template'">
          <xsl:value-of select="boolean($template/x:define/@*[local-name()=current()/@defined])"/>
        </xsl:when>
        <xsl:when test="@in='page'">
          <xsl:value-of select="boolean($page/x:define/@*[local-name()=current()/@defined])"/>
        </xsl:when>
        <xsl:when test="@in='any'">
          <xsl:value-of select=
            "boolean($layout/x:define/@*[local-name()=current()/@defined]) or
            boolean($template/x:define/@*[local-name()=current()/@defined]) or
            boolean($page/x:define/@*[local-name()=current()/@defined])"/>
        </xsl:when>
        <xsl:when test="@in='all'">
          <xsl:value-of select=
            "boolean($layout/x:define/@*[local-name()=current()/@defined]) and
            boolean($template/x:define/@*[local-name()=current()/@defined]) and
            boolean($page/x:define/@*[local-name()=current()/@defined])"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:if test="$continue=string(true())">
      <xsl:copy-of select="./*|./text()"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="x:import[@uri]">
    <xsl:param name="layout"/>
    <xsl:param name="template"/>
    <xsl:param name="page"/>
    <xsl:param name="locale"/>
    <xsl:variable name="to-process" select="document(concat('./', @uri))"/>
    <xsl:apply-templates select="$to-process/*|$to-process/text()">
      <xsl:with-param name="layout" select="$layout"/>
      <xsl:with-param name="template" select="$template"/>
      <xsl:with-param name="page" select="$page"/>
      <xsl:with-param name="locale" select="$locale"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="x:include[@uri]">
    <xsl:param name="layout"/>
    <xsl:param name="template"/>
    <xsl:param name="page"/>
    <xsl:param name="locale"/>
    <xsl:variable name="to-process" select="document(./@uri)"/>
    <xsl:copy-of select="$to-process/*|$to-process/text()"/>
  </xsl:template>
  
  <xsl:template match="x:route[@to]">
    <xsl:param name="layout"/>
    <xsl:param name="template"/>
    <xsl:param name="page"/>
    <xsl:param name="locale"/>
    <xsl:variable name="route" select="$settings/x:routes/x:route[@id=current()/@to]"/>
    <a href="{concat(substring-before($route/@uri, '.xml'), '-', $locale, '.xml')}">
      <xsl:call-template name="i18n">
        <xsl:with-param name="locale" select="$locale"/>
        <xsl:with-param name="path" select="$route/@i18n"/>
      </xsl:call-template>
    </a>
  </xsl:template>
  
  <xsl:template match="x:link-to[@locale]">
    <xsl:param name="layout"/>
    <xsl:param name="template"/>
    <xsl:param name="page"/>
    <xsl:param name="locale"/>
    <xsl:variable name="route" select="$settings/x:routes/x:route[@id=current()/@to]"/>
    <a href="{concat(substring-before($page/@uri, concat('-', $locale, '.xml')), '-', @locale, '.xml')}">
      <xsl:value-of select="@locale"/>
    </a>
  </xsl:template>
  
  <xsl:template match="x:url-to[@locale]">
    <xsl:param name="layout"/>
    <xsl:param name="template"/>
    <xsl:param name="page"/>
    <xsl:param name="locale"/>
    <xsl:variable name="route" select="$settings/x:routes/x:route[@id=current()/@to]"/>
    <xsl:value-of select="concat(substring-before($page/@uri, concat('-', $locale, '.xml')), '-', @locale, '.xml')"/>
  </xsl:template>
  
  <xsl:template match="*">
    <xsl:param name="layout"/>
    <xsl:param name="template"/>
    <xsl:param name="page"/>
    <xsl:param name="locale"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates>
        <xsl:with-param name="layout" select="$layout"/>
        <xsl:with-param name="template" select="$template"/>
        <xsl:with-param name="page" select="$page"/>
        <xsl:with-param name="locale" select="$locale"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@*">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  <!-- ======================================================================================== -->
  <!-- INCLUDES -->
  <!-- ======================================================================================== -->
  <xsl:include href="xsl/plugins.xsl"/>
</xsl:stylesheet>
