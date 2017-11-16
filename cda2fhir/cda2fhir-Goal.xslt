<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://hl7.org/fhir" 
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

    <xsl:template
        match="cda:observation[cda:templateId[@root = '2.16.840.1.113883.10.20.22.4.121']]"
        mode="bundle-entry">
        <xsl:choose>
            <xsl:when test="@negationInd = 'true'">
                <xsl:comment>Negated goal</xsl:comment>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="create-bundle-entry"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template
        match="cda:observation[cda:templateId[@root = '2.16.840.1.113883.10.20.22.4.121']]"
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

    <xsl:template
        match="cda:observation[cda:templateId[@root = '2.16.840.1.113883.10.20.22.4.121']]">
        <Goal>
            <xsl:call-template name="add-meta"/>
            <xsl:apply-templates select="cda:id"/>
            <xsl:apply-templates select="cda:statusCode" mode="goal"/>
            <xsl:apply-templates select="cda:code" mode="goal"/>
            <xsl:call-template name="subject-reference"/>
            
            <xsl:apply-templates select="cda:effectiveTime" mode="goal"/>
            
            <xsl:call-template name="author-reference">
                <xsl:with-param name="element-name">expressedBy</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="goal-conditions"/>
            <xsl:call-template name="goal-outcomes"/>
        </Goal>
    </xsl:template>

    <xsl:template match="cda:statusCode" mode="goal">
        <!-- TODO: actually map the status codes, not always the same between CDA and FHIR -->
        <!-- TODO: the status might be better pulled from the outcome observation -->
        <xsl:choose>
            <xsl:when test="@code = 'active'">
                <status value="in-progress"/>
            </xsl:when>
            <xsl:otherwise>
                <status value="{@code}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="cda:effectiveTime" mode="goal">
        <xsl:choose>
            <xsl:when test="cda:low/@value">
                <statusDate value="{lcg:cdaTS2date(cda:low/@value)}"/>
            </xsl:when>
            <xsl:when test="@value">
                <statusDate value="{lcg:cdaTS2date(@value)}"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="cda:value" mode="goal">
        <xsl:call-template name="newCreateCodableConcept">
            <xsl:with-param name="elementName">category</xsl:with-param>
            <xsl:with-param name="includeCoding" select="true()"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="cda:code" mode="goal">
        <xsl:call-template name="newCreateCodableConcept">
            <xsl:with-param name="elementName">description</xsl:with-param>
            <xsl:with-param name="includeCoding" select="true()"/>
        </xsl:call-template>
    </xsl:template>
    
    
    <xsl:template name="goal-conditions">
        <xsl:for-each select="cda:entryRelationship[@typeCode='REFR']/cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.122']">
            <xsl:variable name="root" select="cda:id/@root"/>
            <xsl:variable name="extension" select="cda:id/@extension"/>
            <xsl:variable name="has-extension">
                <xsl:choose>
                    <xsl:when test="@extension">true</xsl:when>
                    <xsl:otherwise>false</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <!--
            <xsl:comment>Found reference in Goal: @root=<xsl:value-of select="$root"/> @extension=<xsl:value-of select="@extension"/></xsl:comment>
            -->
            <xsl:for-each select="//cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.4'][@extension='2015-08-01']][cda:id[@root=$root]]">
                <!--
                <xsl:comment> - Found referenced observation</xsl:comment>
                -->
                <xsl:choose>
                    <xsl:when test="@extension and $has-extension='true'">
                        <!--
                        <xsl:comment>   * Found linked problem observation with extension</xsl:comment>
                        -->
                        <addresses>
                            <xsl:apply-templates select="." mode="reference"/>
                        </addresses>
                    </xsl:when>
                    <xsl:when test="not(@extension) and $has-extension='false'">
                        <!--
                        <xsl:comment>   * Found linked problem observation without extension</xsl:comment>
                        -->
                        <addresses>
                            <xsl:apply-templates select="." mode="reference"/>
                        </addresses>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:comment>Found problem observation, but did not match both root and extension</xsl:comment>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            
        </xsl:for-each>
    </xsl:template>
    
    
    <xsl:template name="goal-outcomes">
        <xsl:variable name="root" select="cda:id/@root"/>
        <xsl:variable name="extension" select="cda:id/@extension"/>
        <xsl:variable name="has-extension">
            <xsl:choose>
                <xsl:when test="@extension">true</xsl:when>
                <xsl:otherwise>false</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="//cda:observation
            [cda:templateId/@root='2.16.840.1.113883.10.20.22.4.144']
            [cda:entryRelationship[@typeCode='GEVL']/cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.122']/cda:id[@root=$root]]">
            <xsl:choose>
                <xsl:when test="@extension and $has-extension='true'">
                    <xsl:comment>Found linked outcome observation</xsl:comment>
                    <outcomeReference>
                        <xsl:apply-templates select="." mode="reference"/>
                    </outcomeReference>
                </xsl:when>
                <xsl:when test="not(@extension) and $has-extension='false'">
                    <xsl:comment>Found linked outcome observation</xsl:comment>
                    <outcomeReference>
                        <xsl:apply-templates select="." mode="reference"/>
                    </outcomeReference>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:comment>Found outcome observation, but did not match both root and extension</xsl:comment>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    
    
</xsl:stylesheet>
