<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:hl7-org:v3"
   xmlns:lcg="http://www.lantanagroup.com" xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
   xmlns:cda="urn:hl7-org:v3" xmlns:fhir="http://hl7.org/fhir" 
   version="2.0"
   
   exclude-result-prefixes="lcg xsl cda fhir">

   <xsl:template match="fhir:telecom">
      <telecom>
         <xsl:variable name="uri-prefix">
            <xsl:choose>
               <xsl:when test="fhir:system/@value='phone'">tel:</xsl:when>
               <xsl:when test="fhir:system/@value='email'">mailto:</xsl:when>
            </xsl:choose>
         </xsl:variable>
         <xsl:attribute name="value">
            <xsl:value-of select="$uri-prefix"/><xsl:value-of select="fhir:value/@value"/>
         </xsl:attribute>
      </telecom>
   </xsl:template>
   
</xsl:stylesheet>