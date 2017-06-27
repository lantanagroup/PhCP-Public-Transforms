<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:hl7-org:v3"
    xmlns:lcg="http://www.lantanagroup.com" xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
    xmlns:cda="urn:hl7-org:v3" xmlns:fhir="http://hl7.org/fhir" xmlns:uuid="java:java.util.UUID"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0"
    exclude-result-prefixes="lcg xsl cda fhir">
    
    <xsl:template match="fhir:AllergyIntolerance" mode="entry">
        <xsl:param name="generated-narrative">additional</xsl:param>
        <xsl:comment>TODO: replace match with profile id when available</xsl:comment>
        <entry>
            <xsl:if test="$generated-narrative = 'generated'">
                <xsl:attribute name="typeCode">DRIV</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="make-allergyintolerance"/>
        </entry>
    </xsl:template>
    
    <xsl:template name="make-allergyintolerance">
        <xsl:variable name="no-known-allergy">
            <xsl:choose>
                <!-- All children of 716186003, no known allergy -->
                <xsl:when test="fhir:code/fhir:coding/fhir:system/@value='http://snomed.info/sct' and (
                    fhir:code/fhir:coding/fhir:code/@value='716186003' or
                    fhir:code/fhir:coding/fhir:code/@value='716220001' or
                    fhir:code/fhir:coding/fhir:code/@value='428197003' or
                    fhir:code/fhir:coding/fhir:code/@value='409137002' or
                    fhir:code/fhir:coding/fhir:code/@value='428607008' or
                    fhir:code/fhir:coding/fhir:code/@value='429625007' or
                    fhir:code/fhir:coding/fhir:code/@value='716184000' 
                    )">
                    <xsl:text>true</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <act classCode="ACT" moodCode="EVN">
            <!-- [C-CDA R2.1] Health Concern Act (V2) -->
            <templateId root="2.16.840.1.113883.10.20.22.4.132" extension="2015-08-01" />
            <!-- [PCP R1 STU1] Health Concern Act (Pharmacist Care Plan) -->
            <templateId root="2.16.840.1.113883.10.20.37.3.8" extension="2017-08-01" />
            <xsl:comment>TODO: map declared profiles to templates</xsl:comment>
            <id nullFlavor="NI" />
            <code code="75310-3" codeSystem="2.16.840.1.113883.6.1" displayName="Health Concern" codeSystemName="LOINC" />
            <statusCode code="active"/>
            <entryRelationship typeCode="REFR">
                <observation classCode="OBS" moodCode="EVN">
                    <xsl:if test="$no-known-allergy='true'">
                        <xsl:attribute name="negationInd">true</xsl:attribute>
                    </xsl:if>
                    <!--
                    <xsl:for-each select="fhir:code/fhir:coding">
                        <xsl:choose>
                            <xsl:when test="fhir:system/@value='http://snomed.info/sct' and (
                                fhir:code/@value='716186003' or
                                fhir:code/@value='716220001' or
                                fhir:code/@value='428197003' or
                                fhir:code/@value='409137002' or
                                fhir:code/@value='428607008' or
                                fhir:code/@value='429625007' or
                                fhir:code/@value='716184000' 
                                )">
                                <xsl:attribute name="negationInd">true</xsl:attribute>
                            </xsl:when>
                        </xsl:choose>   
                    </xsl:for-each>  
                    -->
                    <!-- [C-CDA R2.0] Allergy - Intolerance Observation (V2) -->
                    <templateId root="2.16.840.1.113883.10.20.22.4.7" extension="2014-06-09" />
                    <xsl:choose>
                    	<xsl:when test="fhir:identifier">
                    		<xsl:apply-templates select="fhir:identifier"/>
                    	</xsl:when>
                		<xsl:otherwise>
                			<id nullFlavor="NI"/>
                		</xsl:otherwise>
                    </xsl:choose>
                    <code code="ASSERTION" codeSystem="2.16.840.1.113883.5.4"/>
                    <statusCode code="completed"></statusCode>
                    <xsl:if test="fhir:onsetDateTime">
                        <effectiveTime>
                            <low>
                                <xsl:attribute name="value">
                                    <xsl:call-template name="Date2TS">
                                        <xsl:with-param name="date" select="fhir:onsetDateTime/@value"/>
                                        <xsl:with-param name="includeTime" select="true()" />
                                    </xsl:call-template>
                                </xsl:attribute>
                            </low>
                        </effectiveTime>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="fhir:code/fhir:extension/@url='http://hl7.org/fhir/StructureDefinition/cda-negated-code'">
                            <xsl:comment>TODO: Replace line below with code from extension http://hl7.org/fhir/StructureDefinition/cda-negated-code</xsl:comment>
                            <value xsi:type="CD" code="419199007" codeSystem="2.16.840.1.113883.6.96" displayName="Allergy to Substance" codeSystemName="SNOMED" />
                        </xsl:when>
                        <xsl:otherwise>
                            <value xsi:type="CD" code="419199007" codeSystem="2.16.840.1.113883.6.96" displayName="Allergy to Substance" codeSystemName="SNOMED" />
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="$no-known-allergy='true'">
                            <participant typeCode="CSM">
                                <participantRole classCode="MANU">
                                    <playingEntity classCode="MMAT">
                                        <code nullFlavor="NI" />
                                    </playingEntity>
                                </participantRole>
                            </participant>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="fhir:code">
                                <participant typeCode="CSM">
                                    <participantRole classCode="MANU">
                                        <playingEntity classCode="MMAT">
                                            <xsl:call-template name="CodeableConcept2CD"/>
                                        </playingEntity>
                                    </participantRole>
                                </participant>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </observation>
            </entryRelationship>
        </act>
    </xsl:template>
    
</xsl:stylesheet>
