<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:hl7-org:v3"
    xmlns:lcg="http://www.lantanagroup.com" xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
    xmlns:cda="urn:hl7-org:v3" xmlns:fhir="http://hl7.org/fhir" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    version="2.0"
    exclude-result-prefixes="lcg xsl cda fhir">
    
    <xsl:template match="fhir:Condition" mode="entry">
        <xsl:param name="generated-narrative">additional</xsl:param>
        <xsl:comment>TODO: replace match with profile id when available</xsl:comment>
        <entry>
            <xsl:if test="$generated-narrative = 'generated'">
                <xsl:attribute name="typeCode">DRIV</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="make-problemobservation"/>
        </entry>
    </xsl:template>
    
    <xsl:template name="make-problemobservation">
        <xsl:if test="fhir:category/@value='encounter-diagnosis'">
            <xsl:comment> TODO: if category is encounter-diagnosis, wrap with encounter diagnosis template (root="2.16.840.1.113883.10.20.22.4.80" extension="2015-08-01")</xsl:comment>
        </xsl:if>
        <act classCode="ACT" moodCode="EVN">
            <!-- [C-CDA R2.1] Health Concern Act (V2) -->
            <templateId root="2.16.840.1.113883.10.20.22.4.132" extension="2015-08-01" />
            <!-- [PCP R1 STU1] Health Concern Act (Pharmacist Care Plan) -->
            <templateId root="2.16.840.1.113883.10.20.37.3.8" extension="2017-08-01" />
            <id nullFlavor="NI" />
            <code code="75310-3" codeSystem="2.16.840.1.113883.6.1" displayName="Health Concern" codeSystemName="LOINC" />
            <statusCode code="active"/>
            <entryRelationship typeCode="REFR">
                <observation classCode="OBS" moodCode="EVN">
                    <!-- [C-CDA R2.1] Problem Observation Template -->
                    <templateId root="2.16.840.1.113883.10.20.22.4.4" extension="2015-08-01" />
                    <xsl:choose>
                        <xsl:when test="fhir:identifier">
                            <xsl:apply-templates select="fhir:identifier"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <id nullFlavor="NI"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <code code="ASSERTION" codeSystem="2.16.840.1.113883.5.4">
                        <translation code="75321-0" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="Clinical Finding" />
                    </code>
                    <xsl:if test="fhir:note">
                        <text><xsl:value-of select="fhir:note/fhir:text/@value"/></text>
                    </xsl:if>
                    <statusCode code="completed"/>
                    <effectiveTime>
                        <xsl:choose>
                            
                            <xsl:when test="fhir:onsetDateTime/@value">
                                <low>
                                    <xsl:attribute name="value">
                                        <xsl:call-template name="Date2TS">
                                            <xsl:with-param name="date" select="fhir:onsetDateTime/@value"/>
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
                    <xsl:for-each select="fhir:code">
                        <xsl:call-template name="CodeableConcept2CD">
                            <xsl:with-param name="cd-target-name">value</xsl:with-param>
                            <xsl:with-param name="xsi-type">CD</xsl:with-param>
                        </xsl:call-template>
                    </xsl:for-each>
                </observation>
            </entryRelationship>
        </act>
    </xsl:template>
    
</xsl:stylesheet>
