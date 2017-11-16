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
    
    <xsl:template match="cda:act[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.140']] | 
        cda:act[@moodCode='INT'][cda:templateId[@root='2.16.840.1.113883.10.20.22.4.12'][@extension='2014-06-09']]" 
        mode="bundle-entry">
        <xsl:call-template name="create-bundle-entry"/>
    </xsl:template>
    
    <xsl:template
        match="cda:act[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.140']] | 
        cda:act[@moodCode='INT'][cda:templateId[@root='2.16.840.1.113883.10.20.22.4.12'][@extension='2014-06-09']]"
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
    
    <xsl:template match="cda:act[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.140']] | 
        cda:act[@moodCode='INT'][cda:templateId[@root='2.16.840.1.113883.10.20.22.4.12'][@extension='2014-06-09']]">
        <ProcedureRequest xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns="http://hl7.org/fhir">
            <xsl:apply-templates select="cda:id"/>
            <status value="{cda:statusCode/@code}"/>
            <xsl:choose>
                <xsl:when test="@moodCode='INT'">
                    <intent value="plan"/>
                </xsl:when>
                <xsl:when test="@moodCode='RQO'">
                    <intent value="order"/>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="cda:code" mode="procedure-request"/>
            <xsl:call-template name="subject-reference"/>
            <xsl:if test="cda:effectiveTime/@value">
            	<occurrenceDateTime value="{lcg:cdaTS2date(cda:effectiveTime/@value)}"/>
            </xsl:if>
            <xsl:if test="cda:author">
                <requester>
                    <xsl:call-template name="author-reference">
                        <xsl:with-param name="element-name">agent</xsl:with-param>
                    </xsl:call-template>
                </requester>
            </xsl:if>
        </ProcedureRequest>
    </xsl:template>
    
    <xsl:template match="cda:code" mode="procedure-request">
        <xsl:call-template name="newCreateCodableConcept">
            <xsl:with-param name="elementName">code</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>