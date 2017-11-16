<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://hl7.org/fhir" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cda="urn:hl7-org:v3" xmlns:fhir="http://hl7.org/fhir" xmlns:sdtc="urn:hl7-org:sdtc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:lcg="http://www.lantanagroup.com"
    exclude-result-prefixes="lcg xsl cda fhir xs xsi sdtc xhtml" version="2.0">
    
    <xsl:import href="c-to-fhir-utility.xslt"/>

    <xsl:template match="cda:recordTarget" mode="bundle-entry">
        <xsl:call-template name="create-bundle-entry"/>
    </xsl:template>

    <xsl:template match="cda:recordTarget">
        <Patient>
            <!--
            <id value="{@lcg:uuid}"/>
            -->
            <meta>
                <profile value="http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient"/>
            </meta>
            <text>
                <status value="generated"/>
                <div xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:for-each select="cda:patientRole/cda:patient/cda:name[not(@nullFlavor)]">
                        <xsl:choose>
                            <xsl:when test="position() = 1">
                                <h1><xsl:value-of select="cda:family"/>, <xsl:value-of
                                        select="cda:given"/></h1>
                            </xsl:when>
                            <xsl:otherwise>
                                <p>Alternate name: <xsl:value-of select="cda:family"/>,
                                        <xsl:value-of select="cda:given"/></p>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                    <xsl:for-each select="cda:patientRole/cda:telecom[not(@nullFlavor)]">
                        <p>Telecom: <xsl:value-of select="@value"/></p>
                    </xsl:for-each>
                    <xsl:for-each select="cda:patientRole/cda:addr[not(@nullFlavor)]">
                        <p>
                        <xsl:text>Address: </xsl:text>
                        <xsl:for-each select="*|text()">
                            <xsl:value-of select="."/>
                            <xsl:if test="not(position()=last())"><br/></xsl:if>
                        </xsl:for-each>
                        </p>
                    </xsl:for-each>
                    <xsl:for-each select="cda:patientRole/cda:patient/cda:administrativeGenderCode[not(@nullFlavor)]">
                        <p>Gender: <xsl:value-of select="@code"/></p>
                    </xsl:for-each>
                    <xsl:for-each select="cda:patientRole/cda:patient/cda:birthTime[not(@nullFlavor)]">
                        <p>Birthdate: <xsl:value-of select="lcg:cdaTS2date(@value)"/></p>
                    </xsl:for-each>
                </div>
            </text>
            <xsl:call-template name="add-race-codes"/>
            <xsl:call-template name="add-ethnicity-codes"/>
            <xsl:call-template name="add-birthtime-extension"/>
            <xsl:apply-templates select="cda:patientRole/cda:id"/>
            <xsl:apply-templates select="cda:patientRole/cda:patient/cda:id"/>
            <xsl:apply-templates select="cda:patientRole/cda:patient/cda:name"/>
            <xsl:apply-templates select="cda:patientRole/cda:telecom"/>
            <xsl:apply-templates select="cda:patientRole/cda:patient/cda:administrativeGenderCode"/>
            <xsl:apply-templates select="cda:patientRole/cda:patient/cda:birthTime"/>
            <xsl:apply-templates select="cda:patientRole/cda:addr"/>
            <xsl:if test="cda:patientRole/cda:patient/cda:guardian">
                <contact>
                    <xsl:apply-templates select="cda:patientRole/cda:patient/cda:guardian/cda:guardianPerson/cda:name"/>
                    <xsl:apply-templates select="cda:patientRole/cda:patient/cda:guardian/cda:telecom"/>
                    <xsl:apply-templates select="cda:patientRole/cda:patient/cda:guardian/cda:addr"/>
                </contact>
            </xsl:if>
        </Patient>
    </xsl:template>

    <xsl:template name="add-race-codes">
        <!-- Race -->
        <xsl:if test="cda:patientRole/cda:patient/cda:raceCode[not(@nullFlavor)] or cda:patientRole/cda:patient/sdtc:raceCode[not(@nullFlavor)]">
            <extension url="http://hl7.org/fhir/us/core/StructureDefinition/us-core-race">
                
                <xsl:for-each select="cda:patientRole/cda:patient/cda:raceCode[not(@nullFlavor)]">
                    <xsl:variable name="code">
                        <xsl:choose>
                            <xsl:when test="@code='1002-5' or @code='2028-9' 
                                or @code='2054-5' or @code='2076-8' or @code='2106-3'">
                                <xsl:value-of>1000-9</xsl:value-of>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@code"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <extension url="ombCategory">
                        <valueCoding>
                            <system value="urn:oid:2.16.840.1.113883.6.238"/>
                            <code value="{$code}"/>
                            <display value="{@displayName}"/>
                        </valueCoding>
                    </extension>
                    <extension url="text">
                        <valueString value="{@displayName}"/>
                    </extension>
                </xsl:for-each>
                <xsl:for-each select="cda:patientRole/cda:patient/sdtc:raceCode[not(@nullFlavor)]">
                    <xsl:variable name="code">
                        <xsl:choose>
                            <xsl:when test="@code='1002-5' or @code='2028-9' 
                                or @code='2054-5' or @code='2076-8' or @code='2106-3'">
                                <xsl:value-of>1000-9</xsl:value-of>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@code"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <extension url="detailed">
                        <valueCoding>
                            <system value="urn:oid:2.16.840.1.113883.6.238"/>
                            <code value="{$code}"/>
                            <display value="{@displayName}"/>
                        </valueCoding>
                    </extension>
                </xsl:for-each>
            </extension>
        </xsl:if>
    </xsl:template>

    <xsl:template name="add-ethnicity-codes">
        <!-- Ethnicity -->
        <xsl:if test="cda:patientRole/cda:patient/cda:ethnicGroupCode[not(@nullFlavor)] or cda:patientRole/cda:patient/sdtc:ethnicGroupCode[not(@nullFlavor)]">
            <extension url="http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity">
                <xsl:for-each select="cda:patientRole/cda:patient/cda:ethnicGroupCode[not(@nullFlavor)]">
                    <xsl:variable name="code">
                        <xsl:choose>
                            <xsl:when test="@code='2135-2' or @code='2186-5'">
                                <xsl:value-of>2133-7</xsl:value-of>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@code"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <extension url="ombCategory">
                        <valueCoding>
                            <system value="urn:oid:2.16.840.1.113883.6.238"/>
                            <code value="{$code}"/>
                            <display value="{@displayName}"/>
                        </valueCoding>
                    </extension>
                    <extension url="text">
                        <valueString value="{@displayName}"/>
                    </extension>
                </xsl:for-each>
                <xsl:for-each select="cda:patientRole/cda:patient/sdtc:ethnicGroupCode[not(@nullFlavor)]">
                    <xsl:variable name="code">
                        <xsl:choose>
                            <xsl:when test="@code='2135-2' or @code='2186-5'">
                                <xsl:value-of>2133-7</xsl:value-of>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@code"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <extension url="detailed">
                        <valueCoding>
                            <system value="urn:oid:2.16.840.1.113883.6.238"/>
                            <code value="{$code}"/>
                            <display value="{@displayName}"/>
                        </valueCoding>
                    </extension>
                </xsl:for-each>
            </extension>
        </xsl:if>
    </xsl:template>


    <xsl:template name="add-birthtime-extension">
        <xsl:for-each select="cda:patientRole/cda:patient/cda:birthTime[string-length(@value) > 8]">
            <extension url="http://hl7.org/fhir/StructureDefinition/patient-birthTime" >
                <valueDateTime value="{lcg:cdaTS2date(@value)}"/>
            </extension>
        </xsl:for-each>
    </xsl:template>
    

</xsl:stylesheet>
