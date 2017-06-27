<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://hl7.org/fhir" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cda="urn:hl7-org:v3" xmlns:fhir="http://hl7.org/fhir" xmlns:sdtc="urn:hl7-org:sdtc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:lcg="http://www.lantanagroup.com"
    xmlns:uuid="http://www.uuid.org"
    exclude-result-prefixes="lcg xsl cda fhir xs xsi sdtc xhtml" version="2.0">
    
    <xsl:import href="c-to-fhir-utility.xslt"/>
    

    <xsl:template match="cda:act[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.136']]" mode="bundle-entry">
        <xsl:variable name="risk-concern-wrapper" select="."/>
        <!--
        <xsl:call-template name="create-bundle-entry"/>
        -->

        <xsl:for-each select="cda:entryRelationship[cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.4']]]">
           
            <!-- Add a RiskAssessment with a reference to the item in the entryRelationship -->
            <entry>
                <fullUrl value="urn:uuid:{@lcg:uuid}"/>
                <resource>
                    <xsl:apply-templates select="$risk-concern-wrapper" mode="#default">
                        <xsl:with-param name="condition" select="cda:*"/>
                    </xsl:apply-templates>
                </resource>
            </entry>
            <xsl:apply-templates select="cda:*" mode="bundle-entry"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template
        match="cda:act[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.136']]"
        mode="reference">
        <xsl:param name="sectionEntry">false</xsl:param>
        <xsl:param name="listEntry">false</xsl:param>
        <xsl:for-each select="cda:entryRelationship[cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.4']]]">
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
        </xsl:for-each>
    </xsl:template>


    <xsl:template
        match="cda:act[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.136']]">
        <xsl:param name="condition" required="yes"/>
        <xsl:if test="$condition">
            <xsl:call-template name="create-risk">
                <xsl:with-param name="condition" select="$condition"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="create-risk">
        <xsl:param name="condition"/>
        <RiskAssessment>
            <!--
            <id value="{@lcg:uuid}"/>
            -->
            <xsl:apply-templates select="cda:id"/>
            <status value="final"/>
            <xsl:apply-templates select="cda:code">
                <xsl:with-param name="elementName">code</xsl:with-param>
            </xsl:apply-templates>
            <xsl:call-template name="subject-reference"/>
            <xsl:if test="cda:effectiveTime">
                <xsl:choose>
                    <xsl:when test="@nullFlavor">
                        <xsl:comment>Null effectiveTime</xsl:comment>
                    </xsl:when>
                    <xsl:when test="cda:effectiveTime/@value">
                        <xsl:apply-templates select="." mode="instant">
                            <xsl:with-param name="elementName">occuranceDateTime</xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <occurencePeriod>
                            <xsl:if test="cda:effectiveTime/cda:low/@value">
                                <start value="{lcg:cdaTS2date(cda:effectiveTime/cda:low/@value)}"/>
                            </xsl:if>
                            <xsl:if test="cda:effectiveTime/cda:high/@value">
                                <end value="{lcg:cdaTS2date(cda:effectiveTime/cda:high/@value)}"/>
                            </xsl:if>
                        </occurencePeriod>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <condition>
                <xsl:apply-templates select="$condition" mode="reference"/>
            </condition>
            <xsl:call-template name="author-reference">
                <xsl:with-param name="element-name">performer</xsl:with-param>
            </xsl:call-template>
        </RiskAssessment>
    </xsl:template>

</xsl:stylesheet>
