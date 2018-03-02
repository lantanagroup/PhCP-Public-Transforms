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
    
    
    
    <xsl:template match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.7']]" mode="bundle-entry">
        <xsl:call-template name="create-bundle-entry"/>
    </xsl:template>
    
    <!--  
    <xsl:template
        match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.7']]"
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

    <xsl:template match="cda:observation[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.7']]">
        <AllergyIntolerance xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns="http://hl7.org/fhir">
            
            <xsl:call-template name="add-meta"/>
            <xsl:apply-templates select="cda:id"/>
            <xsl:apply-templates select="ancestor::cda:entry/cda:act/cda:statusCode" mode="allergy"/>
            <verificationStatus value="confirmed"/>
            <type>
                <xsl:attribute name="value">
                    <xsl:choose>
                        <xsl:when test="cda:value/@code='419199007' and cda:value/@codeSystem='2.16.840.1.113883.6.96'">allergy</xsl:when>
                        <xsl:otherwise>intolerance</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </type>
            <xsl:comment>Should be no category here</xsl:comment>
            <xsl:choose>
                <xsl:when test="@negationInd='true'">
                    <code>
                        <xsl:comment>Original negated code: <xsl:value-of select="cda:value/@code"/></xsl:comment>
                        <coding>
                            <system value="http://snomed.info/sct"/>
                            <code value="716186003"/>
                            <display value="No known allergy"/>
                        </coding>
                    </code>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="cda:participant[@typeCode='CSM']" mode="allergy"/>
                </xsl:otherwise>
            </xsl:choose>
            <patient>
                <!-- TODO: find the nearest subject in the CDA, or the record target if none present --> 
                <reference value="urn:uuid:{//cda:recordTarget/@lcg:uuid}"/>
            </patient>
            <xsl:apply-templates select="cda:effectiveTime" mode="allergy"/>
            <xsl:choose>
                <xsl:when test="cda:author">
                    <!-- TODO -->
                </xsl:when>
                <xsl:otherwise>
                    <!-- TODO: navigate up the ancestry and find the nearest author -->
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="@negationInd='true'">
                    <xsl:comment>Negated manifestation not currently supported</xsl:comment>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="cda:entryRelationship/cda:observation/cda:value" mode="reaction"/>                    
                </xsl:otherwise>
            </xsl:choose>
        </AllergyIntolerance>
    </xsl:template>
    
    <xsl:template match="cda:value" mode="reaction">
        <reaction>
            <xsl:call-template name="newCreateCodableConcept">
                <xsl:with-param name="elementName">manifestation</xsl:with-param>
            </xsl:call-template>
        </reaction>
    </xsl:template>
    
    <xsl:template match="cda:value" mode="type">
        <xsl:call-template name="newCreateCodableConcept">
            <xsl:with-param name="elementName">type</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="cda:statusCode" mode="allergy">
        <!-- TODO: actually map the status codes, not always the same between CDA and FHIR --> 
        <xsl:if test="@code">
            <clinicalStatus value="{@code}"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="cda:effectiveTime" mode="allergy">
        <xsl:choose>
            <xsl:when test="cda:low and cda:high">
                <xsl:apply-templates select="." mode="period">
                    <xsl:with-param name="element-name">onsetPeriod</xsl:with-param>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="cda:low/@value">
                <onsetDateTime value="{lcg:cdaTS2date(cda:low/@value)}"/>
            </xsl:when>
            <xsl:when test="@value">
                <onsetDateTime value="{lcg:cdaTS2date(@value)}"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!--
    <xsl:template match="cda:value" mode="allergy">
        <xsl:comment>Should be no category here</xsl:comment>
        <type>
            <coding>
                <system>
                    <xsl:attribute name="value">
                        <xsl:call-template name="convertOID">
                            <xsl:with-param name="oid" select="@codeSystem"/>
                        </xsl:call-template>
                    </xsl:attribute>
                </system>
                <code value="{@code}"/>
                <xsl:if test="@displayName">
                    <display value="{@displayName}"/>
                </xsl:if>
            </coding>
        </type>
    </xsl:template>
    -->
    <xsl:template match="cda:participant[@typeCode='CSM']" mode="allergy">
        <xsl:if test="cda:participantRole/cda:playingEntity/cda:code[not(@nullFlavor)]">
            <code>
                    <xsl:for-each select="cda:participantRole/cda:playingEntity/cda:code[not(@nullFlavor)]">
                        <coding>
                            <system>
                                <xsl:attribute name="value">
                                    <xsl:call-template name="convertOID">
                                        <xsl:with-param name="oid" select="@codeSystem"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                            </system>
                            <code value="{@code}"/>
                            <xsl:if test="@displayName">
                                <display value="{@displayName}"/>
                            </xsl:if>
                        </coding>
                    </xsl:for-each>
                
            </code>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>