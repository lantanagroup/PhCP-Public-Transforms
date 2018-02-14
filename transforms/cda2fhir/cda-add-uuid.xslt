<?xml version="1.0" encoding="UTF-8"?>
<!-- This transform adds UUID extensions to to elements that need to become discrete resources when converted to FHIR. Used as a pre-processor in the cda2fhir.xslt file. -->
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://hl7.org/fhir"
	xmlns:lcg="http://www.lantanagroup.com"
	xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
	xmlns:cda="urn:hl7-org:v3"
	xmlns:fhir="http://hl7.org/fhir"
	xmlns:uuid="java:java.util.UUID"
	version="2.0">
   
   <xsl:template match="/" priority="-1">
      <xsl:apply-templates select="*" mode="add-uuids"/>
   </xsl:template>
   
   <xsl:template match="cda:*" mode="add-uuids">
      <xsl:copy>
         <xsl:if test="not(@lcg:uuid)">
            <xsl:attribute name="lcg:uuid">
               <xsl:value-of select="uuid:randomUUID()"/>
            </xsl:attribute>
         </xsl:if>
         <xsl:apply-templates select="@*|node()" mode="add-uuids"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="@*|node()"  mode="add-uuids">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="add-uuids"/>
      </xsl:copy>
   </xsl:template>
 
</xsl:stylesheet>
