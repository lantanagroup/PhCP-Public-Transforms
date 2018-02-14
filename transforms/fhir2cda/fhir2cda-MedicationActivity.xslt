<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns="urn:hl7-org:v3"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:lcg="http://www.lantanagroup.com" 
    xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
    xmlns:cda="urn:hl7-org:v3" 
    xmlns:fhir="http://hl7.org/fhir" 
    exclude-result-prefixes="lcg xsl cda fhir"
    version="2.0">
    
    <xsl:template match="fhir:MedicationRequest" mode="entry">
        <xsl:param name="generated-narrative">additional</xsl:param>
        <entry>
            <xsl:if test="$generated-narrative = 'generated'">
                <xsl:attribute name="typeCode">DRIV</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="make-medication-activity">
                <xsl:with-param name="moodCode">INT</xsl:with-param>
            </xsl:call-template>
        </entry>
    </xsl:template>
    
    <xsl:template match="fhir:MedicationRequest" mode="entry-relationship">
        <xsl:param name="typeCode"/>
        <entryRelationship>
            <xsl:if test="$typeCode">
                   <xsl:attribute name="typeCode" select="$typeCode"/>
            </xsl:if>
            <xsl:call-template name="make-medication-activity">
                <xsl:with-param name="moodCode">INT</xsl:with-param>
            </xsl:call-template>
        </entryRelationship>
    </xsl:template>
    
    <xsl:template name="make-medication-activity">
        <xsl:param name="moodCode">EVN</xsl:param>
        <substanceAdministration classCode="SBADM" moodCode="{$moodCode}">
            <templateId root="2.16.840.1.113883.10.20.37.3.10" extension="2017-08-01" />
            <templateId root="2.16.840.1.113883.10.20.22.4.16" extension="2014-06-09" />
            <xsl:choose>
                <xsl:when test="fhir:identifer">
                    <xsl:apply-templates select="fhir:identifier"/>
                </xsl:when>
                <xsl:otherwise>
                    <id nullFlavor="NI"/>
                </xsl:otherwise>
            </xsl:choose>
            <code code="16076005" codeSystem="2.16.840.1.113883.6.96" displayName="Prescription"/>
            <xsl:choose>
                <xsl:when test="fhir:status">
                    <xsl:apply-templates select="fhir:status" mode="medication-activity"/>
                </xsl:when>
                <xsl:otherwise>
                    <statusCode nullFlavor="NI"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="fhir:dosageInstruction/fhir:timing">
                    <xsl:apply-templates select="fhir:dosageInstruction/fhir:timing" mode="medication-activity"/>
                </xsl:when>
                <xsl:when test="fhir:authoredOn">
                    <xsl:apply-templates select="fhir:authoredOn" mode="medication-activity"/>
                </xsl:when>
                <xsl:otherwise>
                    <effectiveTime xsi:type="IVL_TS" nullFlavor="NI"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="fhir:dosageInstruction/fhir:doseQuantity/fhir:value/@value">
                    <doseQuantity value="{fhir:dosageInstruction/fhir:doseQuantity/fhir:value/@value}"/>
                </xsl:when>
                <xsl:otherwise>
                    <doseQuantity nullFlavor="NI"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:for-each select="fhir:medicationCodeableConcept">
                    <consumable>
                        <manufacturedProduct classCode="MANU">
                            <!-- [C-CDA R2.0] Medication information (V2) -->
                            <templateId root="2.16.840.1.113883.10.20.22.4.23" extension="2014-06-09" />
                            <id root="4b355395-790c-405d-826f-f5a8e242db89" />
                            <manufacturedMaterial>
                                <xsl:call-template name="CodeableConcept2CD"/>
                            </manufacturedMaterial>
                        </manufacturedProduct>
                    </consumable>
            </xsl:for-each>
        </substanceAdministration>
    </xsl:template>
    
    <xsl:template match="fhir:status" mode="medication-activity">
        <statusCode>
            <xsl:choose>
                <xsl:when test="@value='active'">
                    <xsl:attribute name="code">active</xsl:attribute> 
                </xsl:when>
                <xsl:when test="@value='completed'">
                    <xsl:attribute name="code">completed</xsl:attribute> 
                </xsl:when>
                <xsl:when test="@value='cancelled'">
                    <xsl:attribute name="code">cancelled</xsl:attribute> 
                </xsl:when>
                <xsl:when test="@value='unknown'">
                    <xsl:attribute name="nullFlavor">UNK</xsl:attribute> 
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="nullFlavor">OTH</xsl:attribute> 
                </xsl:otherwise>
            </xsl:choose>
        </statusCode>
    </xsl:template>
    
    <xsl:template match="fhir:timing" mode="medication-activity">
        
        <xsl:for-each select="fhir:event">
            <effectiveTime>
                <xsl:attribute name="value">
                    <xsl:call-template name="Date2TS">
                        <xsl:with-param name="date" select="@value"/>
                        <xsl:with-param name="includeTime" select="true()" />
                    </xsl:call-template>
                </xsl:attribute>
            </effectiveTime>
        </xsl:for-each>
        <xsl:for-each select="fhir:repeat">
            <xsl:choose>
                <xsl:when test="fhir:boundsPeriod">
                    <xsl:for-each select="fhir:boundsPeriod">
                        <effectiveTime xsi:type="IVL_TS">
                            <low>
                                <xsl:attribute name="value">
                                    <xsl:call-template name="Date2TS">
                                        <xsl:with-param name="date" select="fhir:start/@value"/>
                                        <xsl:with-param name="includeTime" select="true()" />
                                    </xsl:call-template>
                                </xsl:attribute>
                            </low>
                            <high>
                                <xsl:attribute name="value">
                                    <xsl:call-template name="Date2TS">
                                        <xsl:with-param name="date" select="fhir:end/@value"/>
                                        <xsl:with-param name="includeTime" select="true()" />
                                    </xsl:call-template>
                                </xsl:attribute>
                            </high>
                        </effectiveTime>
                    </xsl:for-each>
                    
                </xsl:when>
                <xsl:otherwise>
                    <effectiveTime xsi:type="IVL_TS">
                        <low nullFlavor="NI"/>
                    </effectiveTime>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="fhir:period and fhir:periodUnit">
                <effectiveTime xsi:type="PIVL_TS" operator="A">
                    <period xsi:type="PQ" value="{fhir:period/@value}" unit="{fhir:periodUnit/@value}" />
                </effectiveTime>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="fhir:authoredOn" mode="medication-activity">
        <effectiveTime xsi:type="IVL_TS">
            <low>
                <xsl:attribute name="value">
                    <xsl:call-template name="Date2TS">
                        <xsl:with-param name="date" select="@value"/>
                        <xsl:with-param name="includeTime" select="true()" />
                    </xsl:call-template>
                </xsl:attribute>
            </low>
            <high>
                <xsl:attribute name="value">
                    <xsl:call-template name="Date2TS">
                        <xsl:with-param name="date" select="@value"/>
                        <xsl:with-param name="includeTime" select="true()" />
                    </xsl:call-template>
                </xsl:attribute>
            </high>
        </effectiveTime>
    </xsl:template>
    
</xsl:stylesheet>