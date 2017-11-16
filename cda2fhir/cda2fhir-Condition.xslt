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
        <!-- Below is for medication therapy problems -->
        <!--
        <xsl:call-template name="create-medication-entry"/>
        -->
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

    <xsl:template match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.4']]">
        <Condition xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns="http://hl7.org/fhir">
            
            <xsl:call-template name="add-meta"/>
            <xsl:apply-templates select="cda:id"/>
            <xsl:apply-templates select="ancestor::cda:entry/cda:act/cda:statusCode" mode="condition"/>
            <verificationStatus value="confirmed"/>
            <xsl:choose>
                <xsl:when test="ancestor::cda:act[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.80']]">
                    <category>
                        <coding>
                            <system value="http://hl7.org/fhir/condition-category"/>
                            <code value="encounter-diagnosis"/>
                        </coding>
                    </category>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="cda:code" mode="condition"/>
            <xsl:apply-templates select="cda:value" mode="condition"/>
            
            <xsl:call-template name="subject-reference"/>
            <xsl:apply-templates select="cda:effectiveTime" mode="condition"/>
            <xsl:call-template name="author-reference">
                <xsl:with-param name="element-name">asserter</xsl:with-param>
            </xsl:call-template>
            
            <xsl:for-each select="cda:entryRelationship[@typeCode='REFR']/cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.122']">
                <evidence>
                    <detail>
                        <xsl:apply-templates select="." mode="reference"/>
                    </detail>
                </evidence>
            </xsl:for-each>
            <!--
            <xsl:for-each select="cda:entryRelationship[@typeCode='REFR']/cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.122']">
                <xsl:if test="cda:id/@root and cda:id/@extension">
                    <evidence>
                        <detail>
                            <reference value="urn:uuid:{@lcg:uuid}"/>
                        </detail>
                    </evidence>
                </xsl:if>
            </xsl:for-each>
            -->
            <xsl:if test="cda:text">
                <note>
                    <text value="{normalize-space(cda:text)}"/>
                </note>
            </xsl:if>
        </Condition>
    </xsl:template>
    
    <xsl:template match="cda:statusCode" mode="condition">
        <clinicalStatus>
            <xsl:choose>
                <xsl:when test="@code='completed'">
                    <xsl:attribute name="value">resolved</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="value" select="@code"/>
                </xsl:otherwise>
            </xsl:choose>
        </clinicalStatus>
    </xsl:template>
    
    <xsl:template match="cda:effectiveTime" mode="condition">
        <xsl:if test="cda:low/@value">
            <onsetDateTime value="{lcg:cdaTS2date(cda:low/@value)}"/>
        </xsl:if>
        <xsl:if test="cda:high/@value">
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
    
    <!-- Using the assumption that all ids of cda MTP medications always have a root and an extension as a way
                to distinguish when a medication reference is being made -->
    <!--
    <xsl:template name="create-medication-entry">
        <xsl:for-each select="cda:entryRelationship[@typeCode='REFR']/cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.122']">

            <xsl:if test="cda:id/@root and cda:id/@extension">
                <entry>
                    <fullUrl value="urn:uuid:{@lcg:uuid}"/>
                    <resource>
                        <xsl:apply-templates select="." mode="medication"/>
                    </resource>
                </entry>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="cda:act" mode="medication">
        <xsl:variable name="root" select="cda:id/@root"/>
        <xsl:variable name="extension" select="cda:id/@extension"/>
        <Medication>
            <xsl:for-each select="//cda:substanceAdministration
                [cda:templateId[@root='2.16.840.1.113883.10.20.37.3.10'][@extension='2017-08-01']]
                [cda:id[@root=$root][@extension=$extension]]">
                <xsl:apply-templates select="cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code">
                    <xsl:with-param name="elementName">code</xsl:with-param>
                </xsl:apply-templates>
                <status value="{cda:statusCode/@code}"/>
            </xsl:for-each>
        </Medication>
    </xsl:template>
    -->
</xsl:stylesheet>