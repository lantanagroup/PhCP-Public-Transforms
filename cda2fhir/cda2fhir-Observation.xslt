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
    
    
    <!-- VITAL SIGN OBSERVATION -->
    
    <xsl:template match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.27']]" mode="bundle-entry">
        <xsl:call-template name="create-bundle-entry"/>
    </xsl:template>
    
    
    <xsl:template
        match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.27']]"
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
    
    
    <xsl:template match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.27']]">
        <Observation>
            <!--
            <id value="{@lcg:uuid}"/>
            -->
            
            <xsl:call-template name="add-meta"/>
            <xsl:apply-templates select="cda:id"/>
            <status value="final"/>
            <category>
                <coding>
                    <system value="http://hl7.org/fhir/observation-category"/>
                    <code value="vital-signs"/>
                    <display value="Vital Signs"/>
                </coding>
                <text value="Vital Signs"/>
            </category>
            
            <xsl:apply-templates select="cda:code">
                <xsl:with-param name="elementName">code</xsl:with-param>
            </xsl:apply-templates>
            <xsl:call-template name="subject-reference"/>
            <effectiveDateTime>
                <xsl:attribute name="value">
                    <xsl:value-of select="lcg:cdaTS2date(cda:effectiveTime/@value)"/>
                </xsl:attribute>
            </effectiveDateTime>
            <xsl:call-template name="author-reference">
                <xsl:with-param name="element-name">performer</xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates select="cda:value"/>
            
            <xsl:apply-templates select="cda:interpretationCode">
                <xsl:with-param name="elementName">interpretation</xsl:with-param>
            </xsl:apply-templates>
        </Observation>
    </xsl:template>
    
  
  
    <!-- OUTCOME OBSERVATION -->
    
    <xsl:template match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.144']]" mode="bundle-entry">
        <xsl:call-template name="create-bundle-entry"/>
    </xsl:template>
    
    
    <xsl:template
        match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.144']]"
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
    
    
    
    <xsl:template match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.144']]">
        <Observation>
            <!--
            <id value="{@lcg:uuid}"/>
            -->
            
            <xsl:call-template name="add-meta"/>
            <xsl:apply-templates select="cda:id"/>
            <status value="final"/>
            <xsl:apply-templates select="cda:code">
                <xsl:with-param name="elementName">code</xsl:with-param>
            </xsl:apply-templates>
            <subject>
                <!-- TODO: check for overridden subject at section or entry level --> 
                <reference value="urn:uuid:{//cda:recordTarget/@lcg:uuid}"/>
            </subject>
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
            <xsl:apply-templates select="cda:value"/>
            <!-- TODO process entryRelationships -->
        </Observation>
    </xsl:template>
    
    
    
    <!-- Mental Status Observation  -->
    
    <xsl:template match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.74']]" mode="bundle-entry">
        <xsl:call-template name="create-bundle-entry"/>
    </xsl:template>
    
    
    <xsl:template
        match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.74']]"
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
    
    
    
    <xsl:template match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.74']]">
        <Observation>
            <!--
            <id value="{@lcg:uuid}"/>
            -->
            
            <xsl:call-template name="add-meta"/>
            <xsl:apply-templates select="cda:id"/>
            <status value="final"/>
            <xsl:apply-templates select="cda:code">
                <xsl:with-param name="elementName">code</xsl:with-param>
            </xsl:apply-templates>
            <subject>
                <!-- TODO: check for overridden subject at section or entry level --> 
                <reference value="urn:uuid:{//cda:recordTarget/@lcg:uuid}"/>
            </subject>
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
            <xsl:apply-templates select="cda:value"/>
            <!-- TODO process entryRelationships -->
        </Observation>
    </xsl:template>
    
    
    <!-- Self Care Activities  -->
    
    <xsl:template match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.128']]" mode="bundle-entry">
        <xsl:call-template name="create-bundle-entry"/>
    </xsl:template>
    
    
    <xsl:template
        match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.128']]"
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
    
    
    
    <xsl:template match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.128']]">
        <Observation>
            <!--
            <id value="{@lcg:uuid}"/>
            -->
            
            <xsl:call-template name="add-meta"/>
            <xsl:apply-templates select="cda:id"/>
            <status value="final"/>
            <xsl:apply-templates select="cda:code">
                <xsl:with-param name="elementName">code</xsl:with-param>
            </xsl:apply-templates>
            <subject>
                <!-- TODO: check for overridden subject at section or entry level --> 
                <reference value="urn:uuid:{//cda:recordTarget/@lcg:uuid}"/>
            </subject>
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
            <xsl:apply-templates select="cda:value"/>
            <!-- TODO process entryRelationships -->
        </Observation>
    </xsl:template>
    

</xsl:stylesheet>