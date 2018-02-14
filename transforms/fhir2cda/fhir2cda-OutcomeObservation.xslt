<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:hl7-org:v3"
    xmlns:lcg="http://www.lantanagroup.com" xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
    xmlns:cda="urn:hl7-org:v3" xmlns:fhir="http://hl7.org/fhir" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0"
    exclude-result-prefixes="lcg xsl cda fhir">
    
    <xsl:key name="outcome-references" match="fhir:Goal[fhir:outcomeReference]" use="fhir:outcomeReference/fhir:reference/@value"/>
    
    

    <xsl:template match="fhir:Observation[ancestor::fhir:entry/fhir:fullUrl/@value=//fhir:Goal/fhir:outcomeReference/fhir:reference/@value]" mode="entry">
        <xsl:param name="generated-narrative">additional</xsl:param>
        <xsl:comment>Outcome Observation</xsl:comment>
        <entry>
            <xsl:if test="$generated-narrative = 'generated'">
                <xsl:attribute name="typeCode">DRIV</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="make-outcome-observation"/>
        </entry>
    </xsl:template>
    
    <xsl:template name="make-outcome-observation">
        
        <observation classCode="OBS" moodCode="EVN">
            <!-- [CCDA R2.0] Outcome Observation -->
            <templateId root="2.16.840.1.113883.10.20.22.4.144" />
            <!-- [PCP R1 STU1] Outcome Observation -->
            <templateId root="2.16.840.1.113883.10.20.37.3.16" extension="2017-08-01" />
                <xsl:choose>
                    <xsl:when test="fhir:identifer">
                        <xsl:apply-templates select="fhir:identifier"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <id nullFlavor="NI"/>
                    </xsl:otherwise>
                </xsl:choose>
        
                <xsl:for-each select="fhir:code">
                    <xsl:call-template name="CodeableConcept2CD"/>
                </xsl:for-each>
                <statusCode code="completed"/>
                <effectiveTime>
                    <xsl:choose>
                        
                        <xsl:when test="fhir:effectiveDateTime/@value">
                            <low>
                                <xsl:attribute name="value">
                                    <xsl:call-template name="Date2TS">
                                        <xsl:with-param name="date" select="fhir:effectiveDateTime/@value"/>
                                        <xsl:with-param name="includeTime" select="true()" />
                                    </xsl:call-template>
                                </xsl:attribute>
                            </low>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="nullFlavor">NI</xsl:attribute>
                            <low nullFlavor="NI"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </effectiveTime>
            </observation>
    </xsl:template>
    
</xsl:stylesheet>
