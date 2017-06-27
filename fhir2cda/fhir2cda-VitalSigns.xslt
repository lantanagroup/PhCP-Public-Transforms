<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:hl7-org:v3"
    xmlns:lcg="http://www.lantanagroup.com" xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
    xmlns:cda="urn:hl7-org:v3" xmlns:fhir="http://hl7.org/fhir" xmlns:uuid="java:java.util.UUID"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0"
    exclude-result-prefixes="lcg xsl cda fhir">
    
    <xsl:template match="fhir:Observation[fhir:category/fhir:coding[fhir:system/@value='http://hl7.org/fhir/observation-category'][fhir:code/@value='vital-signs']]" mode="entry">
        <xsl:param name="generated-narrative">additional</xsl:param>
        <entry>
            <xsl:if test="$generated-narrative = 'generated'">
                <xsl:attribute name="typeCode">DRIV</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="make-vitalsign"/>
        </entry>
    </xsl:template>
    
    <xsl:template name="make-vitalsign">
        <act classCode="ACT" moodCode="EVN">
            <!-- [C-CDA R2.1] Health Concern Act (V2) -->
            <templateId root="2.16.840.1.113883.10.20.22.4.132" extension="2015-08-01" />
            <!-- [PCP R1 STU1] Health Concern Act (Pharmacist Care Plan) -->
            <templateId root="2.16.840.1.113883.10.20.37.3.8" extension="2017-08-01" />
            <id nullFlavor="NI"/>
            <code code="75310-3" codeSystem="2.16.840.1.113883.6.1" displayName="Health Concern" codeSystemName="LOINC" />
            <statusCode code="active"/>
            <entryRelationship typeCode="REFR">
                <observation classCode="OBS" moodCode="EVN">
                    <!-- [C-CDA R2.0] Vital sign observation -->
                    <templateId root="2.16.840.1.113883.10.20.22.4.27" extension="2014-06-09" />
                    <xsl:choose>
                        <xsl:when test="fhir:identifier">
                            <xsl:apply-templates select="fhir:identifier"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <id nullFlavor="NI"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <code>
                        <xsl:apply-templates select="fhir:code"/>
                    </code>
                    <statusCode code="{fhir:status/@value}"/>
                    <xsl:choose>
                        <xsl:when test="fhir:effectiveDateTime">
                            <effectiveTime>
                                <xsl:attribute name="value">
                                    <xsl:call-template name="Date2TS">
                                        <xsl:with-param name="date" select="fhir:effectiveDateTime/@value"/>
                                        <xsl:with-param name="includeTime" select="true()" />
                                    </xsl:call-template>
                                </xsl:attribute>
                            </effectiveTime>
                        </xsl:when>
                        <xsl:otherwise>
                            <effectiveTime nullFlavor="NI"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:for-each select="fhir:valueQuantity">
                        <value xsi:type="PQ" value="{fhir:value/@value}" unit="{fhir:unit/@value}"/>
                    </xsl:for-each>
                    <xsl:for-each select="fhir:interpretation">
                    	<xsl:call-template name="CodeableConcept2CD">
                    		<xsl:with-param name="cd-target-name">interpretationCode</xsl:with-param>
                    	</xsl:call-template>
                    </xsl:for-each>
                </observation>
            </entryRelationship>
        </act>
    </xsl:template>
    
</xsl:stylesheet>
