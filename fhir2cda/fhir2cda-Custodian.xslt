<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:hl7-org:v3"
    xmlns:lcg="http://www.lantanagroup.com" xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
    xmlns:cda="urn:hl7-org:v3" xmlns:fhir="http://hl7.org/fhir" xmlns:uuid="java:java.util.UUID"
    version="2.0"
    exclude-result-prefixes="lcg xsl cda fhir">
    
    
    <xsl:template match="fhir:custodian[parent::fhir:Composition]">
        <xsl:for-each select="fhir:reference">
            <xsl:variable name="referenceURI">
                <xsl:call-template name="resolve-to-full-url">
                    <xslt:with-param name="referenceURI" select="@value"></xslt:with-param>
                </xsl:call-template>
            </xsl:variable>
            <xsl:for-each select="//fhir:entry[fhir:fullUrl/@value=$referenceURI]">
                <xsl:apply-templates select="fhir:resource/fhir:*" mode="custodian"/>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="fhir:entry/fhir:resource/fhir:Organization" mode="custodian">
        <xsl:call-template name="make-custodian"/>
    </xsl:template>
    
    <xsl:template name="make-custodian">
        <custodian>
            <assignedCustodian>
                <representedCustodianOrganization>
                    <xsl:choose>
                        <xsl:when test="fhir:identifier">
                            <xsl:apply-templates select="fhir:identifier"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <id nullFlavor="NI"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="fhir:name">
                            <name><xsl:value-of select="fhir:name/@value"/></name>
                        </xsl:when>
                        <xsl:otherwise>
                            <name nullFlavor="NI"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="fhir:telecom">
                            <xsl:apply-templates select="fhir:telecom"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <telecom nullFlavor="NI"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="fhir:address">
                            <xsl:apply-templates select="fhir:address"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <addr nullFlavor="NI"/>
                        </xsl:otherwise>
                    </xsl:choose>
              </representedCustodianOrganization>
            </assignedCustodian>
        </custodian>
    </xsl:template>
    
</xsl:stylesheet>