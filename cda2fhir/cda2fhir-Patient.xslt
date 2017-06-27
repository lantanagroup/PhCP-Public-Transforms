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
                    <xsl:for-each select="cda:patientRole/cda:patient/cda:name">
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
                    <xsl:comment>TODO: finish Patient.text (add contact info, etc.)</xsl:comment>
                    <xsl:message>TODO: finish Patient.text (add contact info, etc.)</xsl:message>
                </div>
            </text>
            <xsl:call-template name="add-race-codes"/>
            <xsl:call-template name="add-ethnicity-codes"/>
            <xsl:for-each select="cda:patientRole/cda:id | cda:patientRole/cda:patient/cda:id">
                <identifier>
                    <system value="urn:oid:{@root}"/>
                    <value value="{@extension}"/>
                </identifier>
            </xsl:for-each>

            <xsl:apply-templates select="cda:patientRole/cda:patient/cda:name"/>
            <xsl:apply-templates select="cda:patientRole/cda:telecom"/>
            <!--
            <xsl:for-each select="cda:patientRole/cda:patient/cda:name">
                <name>
                    <family>
                        <xsl:attribute name="value">
                            <xsl:value-of select="cda:family"/>
                        </xsl:attribute>
                    </family>
                    <xsl:for-each select="cda:given">
                        <given>
                            <xsl:attribute name="value">
                                <xsl:value-of select="."/>
                            </xsl:attribute>
                        </given>
                    </xsl:for-each>
                </name>
            </xsl:for-each>
            -->
            <!--  
            <telecom>
                <value>
                    <xsl:attribute name="value">
                        <xsl:value-of select="cda:patientRole/cda:telecom/@value"/>
                    </xsl:attribute>
                    <xsl:message>TODO: parse CDA telecom URL to populate system with phone, email, etc., then strip URI prefix off of value. </xsl:message>
                </value>
            </telecom>
            -->
            <gender>
                <xsl:variable name="cda-gender"
                    select="cda:patientRole/cda:patient/cda:administrativeGenderCode/@code"/>

                <xsl:choose>
                    <xsl:when test="$cda-gender = 'M'">
                        <xsl:attribute name="value">male</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="$cda-gender = 'F'">
                        <xsl:attribute name="value">female</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="$cda-gender = 'UN'">
                        <xsl:attribute name="value">other</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="value">unknown</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>

            </gender>
            <xsl:if test="cda:patientRole/cda:patient/cda:birthTime">
                <birthDate value="{lcg:cdaTS2date(cda:patientRole/cda:patient/cda:birthTime/@value)}"/>
            </xsl:if>
            <address>
                <line>
                    <xsl:attribute name="value">
                        <xsl:value-of select="cda:patientRole/cda:addr/cda:streetAddressLine"/>
                    </xsl:attribute>
                </line>
                <city>
                    <xsl:attribute name="value">
                        <xsl:value-of select="cda:patientRole/cda:addr/cda:city"/>
                    </xsl:attribute>
                </city>
                <state>
                    <xsl:attribute name="value">
                        <xsl:value-of select="cda:patientRole/cda:addr/cda:state"/>
                    </xsl:attribute>
                </state>
                <postalCode>
                    <xsl:attribute name="value">
                        <xsl:value-of select="cda:patientRole/cda:addr/cda:postalCode"/>
                    </xsl:attribute>
                </postalCode>
                <country>
                    <xsl:attribute name="value">
                        <xsl:value-of select="cda:patientRole/cda:addr/cda:country"/>
                    </xsl:attribute>
                </country>
            </address>
        </Patient>
    </xsl:template>

    <xsl:template name="add-race-codes">
        <xsl:if test="cda:patientRole/cda:patient/cda:raceCode or cda:patientRole/cda:patient/sdtc:raceCode">
            <extension url="http://hl7.org/fhir/us/core/StructureDefinition/us-core-race">
                <xsl:for-each select="cda:patientRole/cda:patient/cda:raceCode[1]">
                    <extension url="ombCategory">
                        <valueCoding>
                            <system value="http://hl7.org/fhir/v3/Race"/>
                            <code value="{@code}"/>
                            <display value="{@displayName}"/>
                        </valueCoding>
                    </extension>
                    <extension url="text">
                        <valueString value="{@displayName}"/>
                    </extension>
                </xsl:for-each>
                <xsl:for-each select="cda:patientRole/cda:patient/sdtc:raceCode">
                    <extension url="detailed">
                        <valueCoding>
                            <system value="http://hl7.org/fhir/v3/Race"/>
                            <code value="{@code}"/>
                            <display value="{@displayName}"/>
                        </valueCoding>
                    </extension>
                </xsl:for-each>
            </extension>
        </xsl:if>
    </xsl:template>

    <xsl:template name="add-ethnicity-codes">
        <xsl:if test="cda:patientRole/cda:patient/cda:ethnicGroupCode or cda:patientRole/cda:patient/sdtc:ethnicGroupCode">
            <extension url="http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity">
                <xsl:for-each select="cda:patientRole/cda:patient/cda:ethnicGroupCode[1]">
                    <extension url="ombCategory">
                        <valueCoding>
                            <system value="http://hl7.org/fhir/v3/Ethnicity"/>
                            <code value="{@code}"/>
                            <display value="{@displayName}"/>
                        </valueCoding>
                    </extension>
                    <extension url="text">
                        <valueString value="{@displayName}"/>
                    </extension>
                </xsl:for-each>
                <xsl:for-each select="cda:patientRole/cda:patient/sdtc:ethnicGroupCode">
                    <extension url="detailed">
                        <valueCoding>
                            <system value="http://hl7.org/fhir/v3/Ethnicity"/>
                            <code value="{@code}"/>
                            <display value="{@displayName}"/>
                        </valueCoding>
                    </extension>
                </xsl:for-each>
            </extension>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
