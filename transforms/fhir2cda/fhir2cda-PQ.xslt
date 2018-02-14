<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
   xmlns="urn:hl7-org:v3"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xmlns:lcg="http://www.lantanagroup.com" 
   xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
   xmlns:cda="urn:hl7-org:v3" 
   xmlns:fhir="http://hl7.org/fhir" 
   version="2.0"
   exclude-result-prefixes="lcg xsl cda fhir">

   <xsl:template match="fhir:quantity">
      <xsl:param name="element-name">value</xsl:param>
      <xsl:param name="include-datatype">true</xsl:param>
      <xsl:element name="{$element-name}">
         <xsl:if test="$include-datatype='true'">
            <xsl:attribute name="xsi:type">PQ</xsl:attribute>
         </xsl:if>
         <xsl:choose>
            <xsl:when test="fhir:value">
               <xsl:attribute name="value" select="fhir:value/@value"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:attribute name="nullFlavor">NI</xsl:attribute>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:choose>
            <xsl:when test="fhir:unit">
               <xsl:attribute name="unit" select="fhir:unit/@value"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:attribute name="unit">1</xsl:attribute>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   
</xsl:stylesheet>