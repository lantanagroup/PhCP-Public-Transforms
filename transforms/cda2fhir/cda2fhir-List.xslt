<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://hl7.org/fhir" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cda="urn:hl7-org:v3" xmlns:fhir="http://hl7.org/fhir" xmlns:sdtc="urn:hl7-org:sdtc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:lcg="http://www.lantanagroup.com"
    exclude-result-prefixes="lcg xsl cda fhir xs xsi sdtc xhtml" version="2.0">

    <xsl:template match="cda:act[cda:templateId[@root = '2.16.840.1.113883.10.20.22.4.131']]" mode="bundle-entry">
        <xsl:call-template name="create-bundle-entry"/>
        <xsl:for-each select="cda:entryRelationship">
            <xsl:apply-templates select="cda:*" mode="bundle-entry"/>
        </xsl:for-each>
    </xsl:template>
    
    
    
	<!--
    <xsl:template
        match="cda:act[cda:templateId[@root = '2.16.840.1.113883.10.20.22.4.131']]"
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
        match="cda:act[cda:templateId[@root = '2.16.840.1.113883.10.20.22.4.131']]">
        <xsl:call-template name="create-list"/>
    </xsl:template>
    
    <xsl:template name="create-list">
        <List xmlns="http://hl7.org/fhir">
            <!--
            <id value="{@lcg:uuid}"/>
            -->
            <xsl:apply-templates select="cda:id"/>
            <status value="current"/>
            <xsl:choose>
                <xsl:when test="@moodCode='INT'">
                    <mode value="working"/>
                </xsl:when>
                <xsl:otherwise>
                    <mode value="snapshot"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="cda:code">
                <xsl:with-param name="elementName">code</xsl:with-param>
            </xsl:apply-templates>
            <xsl:if test="cda:effectiveTime">
                <xsl:choose>
                    <xsl:when test="cda:effectiveTime/@value">
                        <date value="{lcg:cdaTS2date(cda:effectiveTime/@value)}"/>
                    </xsl:when>
                    <xsl:when test="cda:effectiveTime/cda:high/@value">
                        <date value="{lcg:cdaTS2date(cda:effectiveTime/cda:high/@value)}"/>
                    </xsl:when>
                    <xsl:when test="cda:effectiveTime/cda:low/@value">
                        <date value="{lcg:cdaTS2date(cda:effectiveTime/cda:low/@value)}"/>
                    </xsl:when>
                    <xsl:when test="cda:effectiveTime/cda:center/@value">
                        <date value="{lcg:cdaTS2date(cda:effectiveTime/cda:center/@value)}"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
            <xsl:for-each select="cda:entryRelationship/cda:*">
                <!-- TODO: export only supported entries -->
                <xsl:apply-templates select="." mode="reference">
                    <xsl:with-param name="listEntry">true</xsl:with-param>
                </xsl:apply-templates>        
                <xsl:for-each select="cda:entryRelationship/cda:supply[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.18']]">
                    <!-- In FHIR, MedicationDispense references MedicationRequest (the opposite direction of CDA), so need to add the dispense to the list or section -->
                    <xsl:apply-templates select="." mode="reference">
                        <xsl:with-param name="listEntry">true</xsl:with-param>
                    </xsl:apply-templates>
                </xsl:for-each>
                <xsl:for-each select="cda:entryRelationship/cda:act[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.122']]">
                    <xsl:variable name="id" select="./cda:id/@root"/>
                    <xsl:for-each select="//cda:observation[cda:id[@root=$id]]">
                        <xsl:apply-templates select="." mode="reference">
                            <xsl:with-param name="listEntry">true</xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:for-each>
        </List>
    </xsl:template>

</xsl:stylesheet>
