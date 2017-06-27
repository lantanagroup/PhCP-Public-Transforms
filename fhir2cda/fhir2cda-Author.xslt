<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:hl7-org:v3"
    xmlns:lcg="http://www.lantanagroup.com" xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
    xmlns:cda="urn:hl7-org:v3" xmlns:fhir="http://hl7.org/fhir" xmlns:uuid="java:java.util.UUID"
    version="2.0"
    exclude-result-prefixes="lcg xsl cda fhir"
    >
    
    <xsl:template match="fhir:author[parent::fhir:Composition]">
        <xsl:for-each select="fhir:reference">
            <xsl:variable name="referenceURI">
                <xsl:call-template name="resolve-to-full-url">
                    <xslt:with-param name="referenceURI" select="@value"></xslt:with-param>
                </xsl:call-template>
            </xsl:variable>
            <xsl:for-each select="//fhir:entry[fhir:fullUrl/@value=$referenceURI]">
                <xsl:apply-templates select="fhir:resource/fhir:*" mode="author"/>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="fhir:entry/fhir:resource/fhir:Practitioner" mode="author">
        <xsl:param name="author-time">
            <xsl:call-template name="Date2TS">
                <xsl:with-param name="date" select="//fhir:Composition[1]/fhir:date/@value"/>
                <xsl:with-param name="includeTime" select="true()" />
            </xsl:call-template>
        </xsl:param>
        <xsl:call-template name="make-author">
            <xsl:with-param name="author-time" select="$author-time"/>
        </xsl:call-template>
    </xsl:template>
    

    
</xsl:stylesheet>