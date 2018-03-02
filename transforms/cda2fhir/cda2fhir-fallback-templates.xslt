<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://hl7.org/fhir" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cda="urn:hl7-org:v3" xmlns:fhir="http://hl7.org/fhir" xmlns:sdtc="urn:hl7-org:sdtc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:lcg="http://www.lantanagroup.com" version="2.0"
    exclude-result-prefixes="lcg xsl cda fhir xs xsi sdtc xhtml">



    <!-- Generic Observation -->
    
    <xsl:template match="cda:observation" mode="bundle-entry" priority="-1">
        <xsl:if test="not(@nullFlavor)">
            <xsl:call-template name="create-bundle-entry"/>
        </xsl:if>
    </xsl:template>
    
    <!--
    <xsl:template
        match="cda:observation" mode="reference" priority="-1">
        <xsl:param name="sectionEntry">false</xsl:param>
        <xsl:param name="listEntry">false</xsl:param>
        <xsl:if test="not(@nullFlavor)">
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
        </xsl:if>
    </xsl:template>
    -->
    
    
    <xsl:template match="cda:observation" priority="-1">
        <Observation>
            <xsl:comment>Processing as generic observation</xsl:comment>
            <xsl:call-template name="add-meta"/>
            <xsl:apply-templates select="cda:id"/>
            <status value="final"/>
            <xsl:apply-templates select="cda:code">
                <xsl:with-param name="elementName">code</xsl:with-param>
            </xsl:apply-templates>
            <xsl:call-template name="subject-reference"/>
            <xsl:if test="cda:effectiveTime/@value">
                <effectiveDateTime>
                    <xsl:attribute name="value">
                        <xsl:value-of select="lcg:cdaTS2date(cda:effectiveTime/@value)"/>
                    </xsl:attribute>
                </effectiveDateTime>
            </xsl:if>
            <xsl:call-template name="author-reference">
                <xsl:with-param name="element-name">performer</xsl:with-param>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="cda:value[@xsi:type='INT']">
                    <!-- There is no valueInteger in observations. Assume is a scale instead -->
                    <xsl:apply-templates select="cda:value" mode="scale"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="cda:value"/>
                </xsl:otherwise>
            </xsl:choose>
            <!-- TODO process entryRelationships -->
        </Observation>
    </xsl:template>
    
    <xsl:template match="cda:value[@xsi:type = 'INT']" mode="scale">
        <xsl:param name="elementName" select="'valueQuantity'"/>
        <xsl:element name="{$elementName}">
            <value>
                <xsl:attribute name="value">
                    <xsl:value-of select="@value"/>
                </xsl:attribute>
            </value>
            <system value="http://unitsofmeasure.org"/> 
            <code>
                <xsl:attribute name="value">{score}</xsl:attribute>
            </code> 
        </xsl:element>
    </xsl:template>

	<!--  
    <xsl:template
        match="cda:*"
        mode="reference" priority="-10">
        <xsl:comment>
			<xsl:text>Unmapped entry reference: </xsl:text>
			<xsl:value-of select="local-name(.)"/>
			<xsl:for-each select="cda:templateId">
				<xsl:text> urn:hl7ii:</xsl:text>
				<xsl:value-of select="@root"/>
				<xsl:if test="@extension">
					<xsl:text>:</xsl:text>
					<xsl:value-of select="@extension"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:comment>
    </xsl:template>
	-->

    <xsl:template
        match="cda:*" mode="reference" priority="-1">
        <xsl:param name="sectionEntry">false</xsl:param>
        <xsl:param name="listEntry">false</xsl:param>
        <xsl:if test="not(@nullFlavor)">
        	<xsl:variable name="templateId" select="cda:templateId[1]/@root"/>
        	<xsl:if test="$templateId">
        	    <xsl:comment><xsl:value-of select="$templateId"/></xsl:comment>
        	</xsl:if>
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
        </xsl:if>
    </xsl:template>
    

    <!-- swallow unmapped entry and entryRelationship children -->

    <xsl:template match="*[parent::cda:entry] | *[parent::cda:entryRelationship] | *[parent::act[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.132'][@extension='2015-08-01']]]" priority="-10"
        mode="bundle-entry">
        <xsl:choose>
            
        <xsl:when test="cda:templateId">
            <xsl:for-each select="cda:templateId">
                <xsl:message terminate="no"><xsl:text>No template match for </xsl:text>
                    <xsl:value-of select="@root"/>
                    <xsl:if test="@extension">
                        <xsl:text>: </xsl:text><xsl:value-of select="@extension"/>
                    </xsl:if>
                </xsl:message>
                
                <xsl:comment><xsl:text>No template match for </xsl:text>
                    <xsl:value-of select="@root"/>
                    <xsl:if test="@extension">
                        <xsl:text>: </xsl:text><xsl:value-of select="@extension"/>
                    </xsl:if>
                </xsl:comment>
            </xsl:for-each>
        </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="no"><text>No match for </text>
                    <xsl:value-of select="."/>
                </xsl:message>
                <xsl:comment><text>No match for </text>
                    <xsl:value-of select="."/>
                </xsl:comment>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
