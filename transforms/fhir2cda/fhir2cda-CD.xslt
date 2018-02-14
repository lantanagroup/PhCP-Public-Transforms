<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:hl7-org:v3"
   xmlns:lcg="http://www.lantanagroup.com" xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
   xmlns:cda="urn:hl7-org:v3" xmlns:fhir="http://hl7.org/fhir"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   version="2.0"
   exclude-result-prefixes="lcg xsl cda fhir">

   <xsl:template name="CodeableConcept2CD">
      <xsl:param name="cd-target-name">code</xsl:param>
      <xsl:param name="xsi-type"/>
      <xsl:choose>
         <xsl:when test="fhir:coding">
            <xsl:element name="{$cd-target-name}">
               <xsl:if test="$xsi-type">
                  <xsl:attribute name="xsi:type" select="$xsi-type"/>
               </xsl:if>
               <xsl:for-each select="fhir:coding">
                  <xsl:choose>
                     <xsl:when test="position() = 1">
                        <xsl:apply-templates select="."/>
                     </xsl:when>
                     <xsl:otherwise>
                        <translation>
                           <xsl:apply-templates select="."/>
                        </translation>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:for-each>
            </xsl:element>
         </xsl:when>
         <xsl:otherwise>
            <xsl:element name="{$cd-target-name}">
            <xsl:choose>
               <xsl:when test="fhir:text">
                  <xsl:attribute name="nullFlavor">OTH</xsl:attribute>
                  <originalText>
                     <xsl:value-of select="fhir:text/@value"/>
                  </originalText>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:attribute name="nullFlavor">NI</xsl:attribute>
               </xsl:otherwise>
            </xsl:choose>
            </xsl:element>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <xsl:template match="fhir:coding">
      <xsl:variable name="codeSystem">
         <xsl:call-template name="convertURI">
            <xsl:with-param name="uri" select="fhir:system/@value"/>
         </xsl:call-template>
      </xsl:variable>
      <xsl:attribute name="code">
         <xsl:value-of select="fhir:code/@value"/>
      </xsl:attribute>
      <xsl:attribute name="codeSystem">
         <xsl:value-of select="$codeSystem"/>
      </xsl:attribute>
      <xsl:if test="fhir:displayName">
         <xsl:attribute name="displayName">
            <xsl:value-of select="fhir:display/@value"/>
         </xsl:attribute>
      </xsl:if>
      
   </xsl:template>
   

   
</xsl:stylesheet>