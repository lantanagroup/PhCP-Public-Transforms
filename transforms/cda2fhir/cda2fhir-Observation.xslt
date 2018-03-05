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
    <!--
    <xsl:template match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.27']]" mode="bundle-entry">
        <xsl:call-template name="create-bundle-entry"/>
    </xsl:template>
    
    <xsl:template match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.27']]">
        <Observation>
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
    -->
  
  
    <!-- OUTCOME OBSERVATION -->
    <!--
    <xsl:template match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.144']]" mode="bundle-entry">
        <xsl:call-template name="create-bundle-entry"/>
    </xsl:template>
    
    
    <xsl:template match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.144']]">
        <Observation>
            <xsl:call-template name="add-meta"/>
            <xsl:apply-templates select="cda:id"/>
            <status value="final"/>
            <xsl:apply-templates select="cda:code">
                <xsl:with-param name="elementName">code</xsl:with-param>
            </xsl:apply-templates>
            <subject>
                <reference value="urn:uuid:{//cda:recordTarget/@lcg:uuid}"/>
            </subject>

			<xsl:if test="cda:entryRelationship[@typeCode='SPRT']/cda:observation/cda:effectiveTime/@value">
	            <effectiveDateTime>
	                <xsl:attribute name="value">
	                    <xsl:value-of select="lcg:cdaTS2date(cda:entryRelationship[@typeCode='SPRT']/cda:observation/cda:effectiveTime/@value)"/>
	                </xsl:attribute>
	            </effectiveDateTime>
            </xsl:if>
            <xsl:call-template name="author-reference">
                <xsl:with-param name="element-name">performer</xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates select="cda:value"/>
        </Observation>
    </xsl:template>
    -->
    
    
    <!-- Mental Status Observation  -->
    <!--
    <xsl:template match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.74']]" mode="bundle-entry">
        <xsl:call-template name="create-bundle-entry"/>
    </xsl:template>
    
    
    <xsl:template match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.74']]">
        <Observation>
            <xsl:call-template name="add-meta"/>
            <xsl:apply-templates select="cda:id"/>
            <status value="final"/>
            <xsl:apply-templates select="cda:code">
                <xsl:with-param name="elementName">code</xsl:with-param>
            </xsl:apply-templates>
            <subject>
                <reference value="urn:uuid:{//cda:recordTarget/@lcg:uuid}"/>
            </subject>
            <xsl:if test="cda:effectiveTime/cda:low/@value">
                <effectiveDateTime>
                    <xsl:attribute name="value">
                        <xsl:value-of select="lcg:cdaTS2date(cda:effectiveTime/cda:low/@value)"/>
                    </xsl:attribute>
                </effectiveDateTime>
            </xsl:if>
            <xsl:call-template name="author-reference">
                <xsl:with-param name="element-name">performer</xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates select="cda:value"/>
        </Observation>
    </xsl:template>
    -->
    
    <!-- Self Care Activities  -->
    <!--
    <xsl:template match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.128']]" mode="bundle-entry">
        <xsl:call-template name="create-bundle-entry"/>
    </xsl:template>
    
    
    
    <xsl:template match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.128']]">
        <Observation>
            <xsl:call-template name="add-meta"/>
            <xsl:apply-templates select="cda:id"/>
            <status value="final"/>
            <xsl:apply-templates select="cda:code">
                <xsl:with-param name="elementName">code</xsl:with-param>
            </xsl:apply-templates>
            <subject>
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
        </Observation>
    </xsl:template>
    -->
    
    <!-- RESULT/VITAL-SIGN ORGANIZER/OBSERVATION -->
    
    <xsl:template match="cda:organizer[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.1' or @root='2.16.840.1.113883.10.20.22.4.26']]" mode="bundle-entry">
        <xsl:call-template name="create-bundle-entry"/>
        <xsl:for-each select="cda:component/cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.2' or @root='2.16.840.1.113883.10.20.22.4.27']]">
            <xsl:call-template name="create-bundle-entry"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="cda:organizer[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.1' or @root='2.16.840.1.113883.10.20.22.4.26']]">
        <Observation>
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
            <xsl:for-each select="cda:component/cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.2' or @root='2.16.840.1.113883.10.20.22.4.27']]">
                <related>
                    <type value="has-member"/>
                    <target>
                        <xsl:apply-templates select="." mode="reference"/>
                    </target>
                </related>
            </xsl:for-each>
        </Observation>
    </xsl:template>
    
    
    <xsl:template match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.2' or @root='2.16.840.1.113883.10.20.22.4.27']]">
        <xsl:variable name="category">
            <xsl:choose>
                <xsl:when test="cda:templateId[@root='2.16.840.1.113883.10.20.22.4.2']">laboratory</xsl:when>
                <xsl:when test="cda:templateId[@root='2.16.840.1.113883.10.20.22.4.27']">vital-signs</xsl:when>
            </xsl:choose>
        </xsl:variable>        
        <xsl:variable name="profile">
            <xsl:choose>
                <xsl:when test="cda:templateId[@root='2.16.840.1.113883.10.20.22.4.2']">http://hl7.org/fhir/us/core/StructureDefinition/us-core-observationresults</xsl:when>
                <xsl:when test="cda:templateId[@root='2.16.840.1.113883.10.20.22.4.27']">http://hl7.org/fhir/StructureDefinition/vitalsigns</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <Observation>
            <xsl:call-template name="add-meta"/>
            <xsl:apply-templates select="cda:id"/>
            <status value="final"/>
            <category>
                <coding>
                    <system value="http://hl7.org/fhir/observation-category"/>
                    <code value="{$category}"/>
                </coding>
            </category>
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
    

</xsl:stylesheet>