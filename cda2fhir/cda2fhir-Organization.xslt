<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://hl7.org/fhir"
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
    
   <xsl:template match="cda:custodian" mode="bundle-entry">
      <xsl:call-template name="create-bundle-entry"/>
   </xsl:template>
    
    <xsl:template
        match="cda:custodian"
        mode="reference">
        <xsl:param name="sectionEntry">false</xsl:param>
        <xsl:param name="listEntry">false</xsl:param>
        <xsl:choose>
            <xsl:when test="$sectionEntry='true'">
                <entry>
                    <reference value="urn:uuid:{@lcg:uuid}"/>
                </entry>
            </xsl:when>
            <xsl:when test="$listEntry='true'">
                <entry><item>
                    <reference value="urn:uuid:{@lcg:uuid}"/></item>
                </entry>
            </xsl:when>
            <xsl:otherwise>
                <reference value="urn:uuid:{@lcg:uuid}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="cda:custodian">
        <xsl:for-each select="cda:assignedCustodian/cda:representedCustodianOrganization">
            <xsl:call-template name="create-organization"></xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="create-organization">
        <Organization>
            <xsl:apply-templates select="cda:id"/>
            <name>
                <xsl:attribute name="value">
                    <xsl:value-of select="cda:name"/>
                </xsl:attribute>
            </name>
            <xsl:apply-templates select="cda:telecom"/>
            <address>
                <line>
                    <xsl:attribute name="value">
                        <xsl:value-of select="cda:addr/cda:streetAddressLine"/>
                    </xsl:attribute>
                </line>
                <city>
                    <xsl:attribute name="value">
                        <xsl:value-of select="cda:addr/cda:city"/>
                    </xsl:attribute>
                </city>
                <state>
                    <xsl:attribute name="value">
                        <xsl:value-of select="cda:addr/cda:state"/>
                    </xsl:attribute>
                </state>
                <postalCode>
                    <xsl:attribute name="value">
                        <xsl:value-of select="cda:addr/cda:postalCode"/>
                    </xsl:attribute>
                </postalCode>
                <country>
                    <xsl:attribute name="value">
                        <xsl:value-of select="cda:addr/cda:country"/>
                    </xsl:attribute>
                </country>
            </address>
        </Organization>
    </xsl:template>
</xsl:stylesheet>