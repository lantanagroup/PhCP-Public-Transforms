<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://hl7.org/fhir" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cda="urn:hl7-org:v3" 
    xmlns:fhir="http://hl7.org/fhir" 
    xmlns:sdtc="urn:hl7-org:sdtc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:lcg="http://www.lantanagroup.com"
    exclude-result-prefixes="lcg xsl cda fhir xs xsi sdtc xhtml"
    version="2.0">

    <xsl:template
        match="cda:encompassingEncounter"
        mode="bundle-entry">
        <xsl:call-template name="create-bundle-entry"/>
    </xsl:template>
    
    <xsl:template
        match="cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.49' or cda:templateId/@root='2.16.840.1.113883.10.20.22.4.40']"
        mode="bundle-entry">
        <xsl:call-template name="create-bundle-entry"/>
    </xsl:template>
    

    
    <xsl:template
        match="cda:encompassingEncounter"
        mode="reference">
        <xsl:param name="sectionEntry">false</xsl:param>
        <xsl:param name="listEntry">false</xsl:param>
        <reference value="urn:uuid:{@lcg:uuid}"/>
    </xsl:template>
    
    <xsl:template
        match="cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.49' or cda:templateId/@root='2.16.840.1.113883.10.20.22.4.40']"
        mode="reference">
        <xsl:param name="sectionEntry">false</xsl:param>
        <xsl:param name="listEntry">false</xsl:param>
        <xsl:choose>
            <xsl:when test="$sectionEntry='true'">
                <entry>
                    <reference value="urn:uuid:{@lcg:uuid}"/>
                </entry></xsl:when>
            <xsl:when test="$listEntry='true'">
                <entry><item>
                    <reference value="urn:uuid:{@lcg:uuid}"/></item>
                </entry></xsl:when>
            <xsl:otherwise>
                <reference value="urn:uuid:{@lcg:uuid}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template
        match="cda:encompassingEncounter | cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.49' or cda:templateId/@root='2.16.840.1.113883.10.20.22.4.40']">
        <Encounter>
            <xsl:choose>
                <xsl:when test="@moodCode='EVN'">
                    <status value="finished"/>
                </xsl:when>
                <xsl:when test="@moodCode='INT' or moodCode='RQO'">
                    <status value="planned"/>
                </xsl:when>
                <xsl:otherwise>
                    <status value="unknown"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="cda:code" mode="encounter"/>
            <xsl:call-template name="subject-reference"/>
            <xsl:for-each select="cda:performer">
                <participant>
                    <type>
                        <coding>
                            <system value="http://hl7.org/fhir/v3/ParticipationType"/>
                            <code value="PPRF"/>
                        </coding>
                    </type>
                    <individual>
                        <reference value="urn:uuid:{@lcg:uuid}"/>
                    </individual>
                </participant>
            </xsl:for-each>
            <xsl:apply-templates select="cda:effectiveTime" mode="period"/>
        </Encounter>
    </xsl:template>
    

    <xsl:template match="cda:code" mode="encounter">
        <xsl:call-template name="newCreateCodableConcept">
            <xsl:with-param name="elementName">type</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
</xsl:stylesheet>
