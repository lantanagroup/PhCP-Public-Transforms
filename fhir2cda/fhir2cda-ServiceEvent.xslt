<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:hl7-org:v3"
    xmlns:lcg="http://www.lantanagroup.com" xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
    xmlns:cda="urn:hl7-org:v3" xmlns:fhir="http://hl7.org/fhir"
    version="2.0"
    exclude-result-prefixes="lcg xsl cda fhir">

    <xsl:template match="fhir:event[parent::fhir:Composition]">
        <documentationOf>
            <serviceEvent classCode="PCPR">
                <effectiveTime>
                    <low>
                        <xsl:attribute name="value">
                            <xsl:call-template name="Date2TS">
                                <xsl:with-param name="date" select="fhir:period/fhir:start/@value"/>
                                <xsl:with-param name="includeTime" select="true()" />
                            </xsl:call-template>
                        </xsl:attribute>
                    </low>
                    <xsl:if test="fhir:period/fhir:end">
                        <high>
                            <xsl:attribute name="value">
                                <xsl:call-template name="Date2TS">
                                    <xsl:with-param name="date" select="fhir:period/fhir:end/@value"/>
                                    <xsl:with-param name="includeTime" select="true()" />
                                </xsl:call-template>
                            </xsl:attribute>
                        </high>
                    </xsl:if>
                </effectiveTime>
                <xsl:for-each select="fhir:extension[@url='http://hl7.org/fhir/ccda/StructureDefinition/CCDA-on-FHIR-Performer']/fhir:valueReference">
                   
                        <xsl:variable name="referenceURI">
                            <xsl:call-template name="resolve-to-full-url">
                                <xslt:with-param name="referenceURI" select="fhir:reference/@value"></xslt:with-param>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:for-each select="//fhir:entry[fhir:fullUrl/@value=$referenceURI]">
                            <xsl:apply-templates select="fhir:resource/fhir:*" mode="event-performer"/>
                        </xsl:for-each>
                </xsl:for-each>
            </serviceEvent>
        </documentationOf>
    </xsl:template>
    
    
    <xsl:template match="fhir:entry/fhir:resource/fhir:Practitioner" mode="event-performer">
        <xsl:call-template name="make-performer"/>
    </xsl:template>
    
    
</xsl:stylesheet>