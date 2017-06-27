<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:hl7-org:v3"
    xmlns:lcg="http://www.lantanagroup.com" xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
    xmlns:cda="urn:hl7-org:v3" xmlns:fhir="http://hl7.org/fhir" xmlns:uuid="java:java.util.UUID"
    version="2.0"
    exclude-result-prefixes="lcg xsl cda fhir">
    
    <xsl:template match="fhir:attester[parent::fhir:Composition]">
        <xsl:for-each select="fhir:party/fhir:reference">
            <xsl:variable name="referenceURI">
                <xsl:call-template name="resolve-to-full-url">
                    <xslt:with-param name="referenceURI" select="@value"></xslt:with-param>
                </xsl:call-template>
            </xsl:variable>
            <xsl:for-each select="//fhir:entry[fhir:fullUrl/@value=$referenceURI]">
                <xsl:apply-templates select="fhir:resource/fhir:*" mode="legal"/>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="fhir:entry/fhir:resource/fhir:Practitioner" mode="legal">
        <xsl:call-template name="make-legal-authenticator"/>
    </xsl:template>
    
    <xsl:template name="make-legal-authenticator">
        <legalAuthenticator>
            <time>
                <xsl:attribute name="value">
                    <xsl:call-template name="Date2TS">
                        <xsl:with-param name="date" select="//fhir:Composition[1]/fhir:attester/fhir:time/@value"/>
                        <xsl:with-param name="includeTime" select="true()" />
                    </xsl:call-template>
                </xsl:attribute>
            </time>
            <signatureCode code="S"/>
            <assignedEntity>
                <xsl:choose>
                    <xsl:when test="fhir:identifier">
                        <xsl:apply-templates select="fhir:identifier"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <id nullFlavor="NI"/>
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
                <xsl:for-each select="fhir:telecom">
                    <telecom value="{fhir:value/@value}">
                        <xsl:call-template name="telecomUse"/>
                    </telecom>
                </xsl:for-each>
                <assignedPerson>
                    <xsl:for-each select="fhir:name">
                        <xsl:variable name="use">
                            <xsl:choose>
                                <xsl:when test="fhir:use/@value = 'usual'">L</xsl:when>
                                <xsl:when test="fhir:use/@value = 'nickname'">P</xsl:when>
                                <!-- Not sure of the exact condition of when to use this label -->
                                <!-- xsl:when test="fhir:use/@value = 'maiden'">BR</xsl:when -->
                            </xsl:choose>
                        </xsl:variable>
                        <name>
                            <xsl:if test="string-length($use) > 0">
                                <xsl:attribute name="use">
                                    <xsl:value-of select="$use"/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:for-each select="fhir:given">
                                <given>
                                    <xsl:value-of select="@value"/>
                                </given>
                            </xsl:for-each>
                            <family>
                                <xsl:value-of select="fhir:family/@value"/>
                            </family>
                            <suffix>
                                <xsl:value-of select="fhir:suffix/@value"/>
                            </suffix>
                        </name>
                    </xsl:for-each>
                </assignedPerson>
            </assignedEntity>
        </legalAuthenticator>
    </xsl:template>
</xsl:stylesheet>