<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:hl7-org:v3"
   xmlns:lcg="http://www.lantanagroup.com" xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
   xmlns:cda="urn:hl7-org:v3" xmlns:fhir="http://hl7.org/fhir"
   version="2.0"
   
   exclude-result-prefixes="lcg xsl cda fhir">

   <xsl:template match="fhir:address">
      <addr>
         <xsl:apply-templates select="*" mode="address"/>
      </addr>
   </xsl:template>
   
   <xsl:template match="fhir:line" mode="address">
      <streetAddressLine><xsl:value-of select="@value"/></streetAddressLine>
   </xsl:template>
   
   <xsl:template match="fhir:city" mode="address">
      <city><xsl:value-of select="@value"/></city>
   </xsl:template>
   
   <xsl:template match="fhir:state" mode="address">
      <state><xsl:value-of select="@value"/></state>
   </xsl:template>
   
   <xsl:template match="fhir:postalCode" mode="address">
      <postalCode><xsl:value-of select="@value"/></postalCode>
   </xsl:template>
   
   <xsl:template match="fhir:country" mode="address">
      <country><xsl:value-of select="@value"/></country>
   </xsl:template>
   
</xsl:stylesheet>