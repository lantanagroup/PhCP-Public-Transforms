<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    version="1.0" 
    xmlns="http://hl7.org/fhir"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:fhir="http://hl7.org/fhir"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="xsl fhir xsi">
    
    <xsl:param name="type">transaction</xsl:param>
    
    <xsl:output method="xml" indent="yes" encoding="UTF-8" />
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="fhir:type[parent::fhir:Bundle]">
        <type value="{$type}"/>
    </xsl:template>
    
    <xsl:template match="fhir:entry[parent::fhir:Bundle]">
        <xsl:variable name="url" select="local-name(fhir:resource/fhir:*[1])"/>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <request>
                <method value="POST"/>
                <url value="{$url}"/>
            </request>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@xsi:schemaLocation"></xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>