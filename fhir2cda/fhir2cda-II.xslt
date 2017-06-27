<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:hl7-org:v3"
   xmlns:lcg="http://www.lantanagroup.com" xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
   xmlns:cda="urn:hl7-org:v3" xmlns:fhir="http://hl7.org/fhir" xmlns:uuid="java:java.util.UUID"
   version="2.0"
   exclude-result-prefixes="lcg xsl cda fhir">

   <xsl:template match="fhir:identifier">
      <id>
         <xsl:choose>
            <xsl:when test="fhir:system/@value='urn:ietf:rfc:3986'">
               <xsl:choose>
                  <xsl:when test="starts-with(fhir:value/@value,'urn:oid:')">
                     <xsl:attribute name="root" select="substring-after(fhir:value/@value,'urn:oid:')"/>
                  </xsl:when>
                  <xsl:when test="starts-with(fhir:value/@value,'urn:uuid:')">
                     <xsl:attribute name="root" select="substring-after(fhir:value/@value,'urn:uuid:')"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:message>TODO: System is urn:ietf:rfc:3986 but did not start with urn:oid or urn:uuid. Need to handle other URI types.</xsl:message>
                     <xsl:attribute name="root" select="fhir:value/@value"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:when test="starts-with(fhir:system/@value,'urn:oid:')">
               <xsl:attribute name="root" select="substring-after(fhir:system/@value,'urn:oid:')"/>
               <xsl:attribute name="extension" select="fhir:value/@value"/>
            </xsl:when>
            <xsl:when test="starts-with(fhir:system/@value,'urn:uuid:')">
               <xsl:attribute name="root" select="substring-after(fhir:system/@value,'urn:uuid:')"/>
               <xsl:attribute name="extension" select="fhir:value/@value"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:attribute name="nullFlavor">OTH</xsl:attribute>
               <xsl:if test="fhir:value">
                  <xsl:attribute name="extension" select="fhir:value/@value"/>
               </xsl:if>
               <xsl:if test="fhir:system">
                  <xsl:attribute name="assigningAuthorityName" select="fhir:system/@value"/>
               </xsl:if>
               <xsl:comment>TODO: map other known URIs to OIDs</xsl:comment>
            </xsl:otherwise>
         </xsl:choose>
      </id>
   </xsl:template>
   
</xsl:stylesheet>