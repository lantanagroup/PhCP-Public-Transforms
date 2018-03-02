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
    
    <xsl:template match="cda:act[@moodCode='EVN'][cda:templateId[@root='2.16.840.1.113883.10.20.22.4.12'][@extension='2014-06-09']]" mode="bundle-entry">
        <xsl:call-template name="create-bundle-entry"/>
    </xsl:template>
    
    <!--  
    <xsl:template
        match="cda:act[@moodCode='EVN'][cda:templateId[@root='2.16.840.1.113883.10.20.22.4.12'][@extension='2014-06-09']]"
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
    
    <xsl:template match="cda:act[@moodCode='EVN'][cda:templateId[@root='2.16.840.1.113883.10.20.22.4.12'][@extension='2014-06-09']]">
        <Procedure xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns="http://hl7.org/fhir">
            <meta>
                <profile value="http://hl7.org/fhir/us/core/StructureDefinition/us-core-procedure"/>
            </meta>
            <xsl:apply-templates select="cda:id"/>
            <xsl:apply-templates select="cda:statusCode" mode="procedure"/>
            <xsl:apply-templates select="cda:code">
                <xsl:with-param name="elementName">code</xsl:with-param>
            </xsl:apply-templates>
            <xsl:call-template name="subject-reference"/>
            <!--
            <performedDateTime value="{lcg:cdaTS2date(cda:effectiveTime/@value)}"/>
            -->
            <xsl:apply-templates select="cda:effectiveTime" mode="period">
                <xsl:with-param name="element-name">performedPeriod</xsl:with-param>
            </xsl:apply-templates>
        </Procedure>
    </xsl:template>
    
    
    <xsl:template match="cda:statusCode" mode="procedure">
        <status>
            <xsl:choose>
                <xsl:when test="@code='active'">
                    <xsl:attribute name="value">in-progress</xsl:attribute>
                </xsl:when>
                <xsl:when test="@code='cancelled'">
                    <!-- Should really map to "not-done" but due to a FHIR bug that is not showing as valid in the schema even though it is in the Event Status value set -->
                    <!-- 
                    <xsl:attribute name="value">not-done</xsl:attribute>
                    -->
                    <xsl:attribute name="value">aborted</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="value" select="@code"/>
                </xsl:otherwise>
            </xsl:choose>
        </status>
    </xsl:template>
    
</xsl:stylesheet>