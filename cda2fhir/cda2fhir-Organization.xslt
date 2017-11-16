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
        <xsl:for-each select="cda:assignedCustodian/cda:representedCustodianOrganization">
            <xsl:apply-templates select="." mode="bundle-entry"></xsl:apply-templates>
        </xsl:for-each>
   </xsl:template>
    
    <xsl:template match="cda:representedCustodianOrganization | cda:representedOrganization" mode="bundle-entry">
        <xsl:call-template name="create-bundle-entry"/>
    </xsl:template>
    
    <xsl:template
        match="cda:custodian"
        mode="reference">
        <xsl:for-each select="cda:assignedCustodian/cda:representedCustodianOrganization">
            <xsl:apply-templates select="." mode="reference"></xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template
        match="cda:representedCustodianOrganization | cda:representedOrganization"
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
            <xsl:apply-templates select="."/>
            <!--
            <xsl:call-template name="create-organization"/>
            -->
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="cda:representedCustodianOrganization | cda:representedOrganization">
        <xsl:call-template name="create-organization"/>
    </xsl:template>
    
    <xsl:template name="create-organization">
        <Organization>
            <xsl:choose>
                <xsl:when test="cda:id">
                    <xsl:apply-templates select="cda:id"/>
                </xsl:when>
                <xsl:otherwise>
                    <identifier>
                        <system value="urn:ietf:rfc:3986"/>
                        <value value="urn:uuid:{@lcg:uuid}"/>
                    </identifier>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="cda:code">
                <xsl:with-param name="elementName">type</xsl:with-param>
            </xsl:apply-templates>
            <xsl:for-each select="cda:standardIndustryClassCode">
                <xsl:call-template name="newCreateCodableConcept">
                    <xsl:with-param name="elementName">type</xsl:with-param>
                </xsl:call-template>
            </xsl:for-each>
            <xsl:if test="cda:name">
                <name>
                    <xsl:attribute name="value">
                        <xsl:value-of select="cda:name"/>
                    </xsl:attribute>
                </name>
            </xsl:if>
            <xsl:apply-templates select="cda:telecom"/>
            <xsl:apply-templates select="cda:addr"/>
        </Organization>
    </xsl:template>
</xsl:stylesheet>