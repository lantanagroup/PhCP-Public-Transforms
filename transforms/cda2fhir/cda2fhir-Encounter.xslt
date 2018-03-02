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
        <xsl:if test="cda:location[not(@nullFlavor)]">
            <xsl:call-template name="create-location-entry"/>
        </xsl:if>
        <xsl:if test="cda:responsibleParty[not(@nullFlavor)]/cda:assignedEntity[not(@nullFlavor)]">
            <xsl:call-template name="create-service-performer-entry"/>
        </xsl:if>
        <xsl:call-template name="create-bundle-entry"/>
    </xsl:template>
    
    <xsl:template name="create-location-entry">
        <entry>
            <fullUrl value="urn:uuid:{cda:location/@lcg:uuid}"/>
            <resource>
                <xsl:apply-templates select="cda:location"/>
            </resource>
        </entry>
    </xsl:template>
    
    <xsl:template name="create-service-performer-entry">
        <entry>
            <fullUrl value="urn:uuid:{cda:responsibleParty/cda:assignedEntity/@lcg:uuid}"/>
            <resource>
                <xsl:apply-templates select="cda:responsibleParty/cda:assignedEntity"/>
            </resource>
        </entry>
    </xsl:template>
    
    <xsl:template
        match="cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.49' or cda:templateId/@root='2.16.840.1.113883.10.20.22.4.40']"
        mode="bundle-entry">
        <xsl:call-template name="create-bundle-entry"/>
    </xsl:template>
    
    <xsl:template
        match="cda:encompassingEncounter[not(@nullFlavor)]"
        mode="reference">
        <xsl:param name="sectionEntry">false</xsl:param>
        <xsl:param name="listEntry">false</xsl:param>
        <reference value="urn:uuid:{@lcg:uuid}"/>
    </xsl:template>
    
    <!--  
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
	-->
    

    <xsl:template
        match="cda:encompassingEncounter[not(@nullFlavor)] | cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.49' or cda:templateId/@root='2.16.840.1.113883.10.20.22.4.40']">
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
            <class>
                <system value="http://hl7.org/fhir/v3/NullFlavor"/>
                <code value="NI"/>
            </class>
            <xsl:apply-templates select="cda:code">
                <xsl:with-param name="elementName">type</xsl:with-param>
            </xsl:apply-templates>
            <xsl:call-template name="subject-reference"/>
            <xsl:for-each select="cda:performer[not(@nullFlavor)]">
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
            <xsl:if test="cda:responsibleParty[not(@nullFlavor)]/cda:assignedEntity[not(@nullFlavor)]">
                <participant>
                    <xsl:apply-templates select="cda:responsibleParty/cda:assignedEntity/cda:code">
                        <xsl:with-param name="elementName">type</xsl:with-param>
                    </xsl:apply-templates>
                    <individual>
                        <reference value="urn:uuid:{cda:responsibleParty/cda:assignedEntity/@lcg:uuid}"/>
                    </individual>
                </participant>
            </xsl:if>
            <xsl:apply-templates select="cda:effectiveTime" mode="period"/>
            <xsl:apply-templates select="/cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:code">
                <xsl:with-param name="elementName">reason</xsl:with-param>
            </xsl:apply-templates>
            <xsl:if test="cda:location[not(@nullFlavor)]">
                <location>
                    <location>
                        <reference value="urn:uuid:{cda:location/@lcg:uuid}"/>
                    </location>
                </location>
            </xsl:if>
        </Encounter>
    </xsl:template>
    
    <xsl:template match="cda:location[not(@nullFlavor)]">
        <Location>
            <xsl:apply-templates select="cda:healthCareFacility/cda:id"/>
            <xsl:if test="cda:healthCareFacility/cda:location/cda:name">
                <name value="{cda:healthCareFacility/cda:location/cda:name}"/>
            </xsl:if>
            <xsl:apply-templates select="cda:healthCareFacility/cda:location/cda:addr"/>
        </Location>
    </xsl:template>
    
    <xsl:template match="cda:assignedEntity[not(@nullFlavor)]">
        <Practitioner>
            <xsl:apply-templates select="cda:id"/>
            <xsl:apply-templates select="cda:assignedPerson/cda:name"/>
            <xsl:for-each select="cda:telecom">
                <xsl:apply-templates select="."/>
            </xsl:for-each>
            <xsl:apply-templates select="cda:addr"/>
        </Practitioner>
    </xsl:template>

    <xsl:template match="cda:code" mode="encounter">
        <xsl:call-template name="newCreateCodableConcept">
            <xsl:with-param name="elementName">type</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
</xsl:stylesheet>
