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
    

    
    
    <xsl:template match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.4']]" mode="bundle-entry">
        <xsl:call-template name="create-bundle-entry"/>
    </xsl:template>
    
    
    <xsl:template
        match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.4']]"
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

    <xsl:template match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.4'][@extension='2015-08-01']]">
        <Condition xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns="http://hl7.org/fhir">
            
            <xsl:call-template name="add-meta"/>
            <xsl:apply-templates select="cda:id"/>
            <xsl:apply-templates select="ancestor::cda:entry/cda:act/cda:statusCode" mode="condition"/>
            <verificationStatus value="confirmed"/>
           
            
            <xsl:apply-templates select="cda:code" mode="condition"/>
            <xsl:apply-templates select="cda:value" mode="condition"/>
            
            <xsl:call-template name="subject-reference"/>
            <xsl:apply-templates select="cda:effectiveTime" mode="condition"/>
            <xsl:call-template name="author-reference">
                <xsl:with-param name="element-name">asserter</xsl:with-param>
            </xsl:call-template>
            <xsl:if test="cda:text">
                <note>
                    <text value="{cda:text}"/>
                </note>
            </xsl:if>
        </Condition>
    </xsl:template>
    
    <xsl:template match="cda:statusCode" mode="condition">
        <!-- TODO: actually map the status codes, not always the same between CDA and FHIR --> 
        <clinicalStatus value="{@code}"/>
    </xsl:template>
    
    <xsl:template match="cda:effectiveTime" mode="condition">
        <xsl:if test="cda:low">
            <onsetDateTime value="{lcg:cdaTS2date(cda:low/@value)}"/>
        </xsl:if>
        <xsl:if test="cda:high">
            <abatementDateTime value="{lcg:cdaTS2date(cda:high/@value)}"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="cda:code" mode="condition">
        <xsl:call-template name="newCreateCodableConcept">
            <xsl:with-param name="elementName">category</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="cda:value" mode="condition">
        <xsl:call-template name="newCreateCodableConcept">
            <xsl:with-param name="elementName">code</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    
</xsl:stylesheet>