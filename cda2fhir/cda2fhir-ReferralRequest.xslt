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
    
        
    <xsl:template match="cda:act[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.140']]" mode="bundle-entry">
      <xsl:call-template name="create-bundle-entry"/>
   </xsl:template>
    
    <xsl:template
        match="cda:act[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.140']]"
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
    
    
    <xsl:template match="cda:act[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.140']]">
        <ReferralRequest>
            <!--
            <id value="{@lcg:uuid}"/>
            -->
            <xsl:apply-templates select="cda:id"/>
            <status value="active"/>
            <xsl:choose>
                <xsl:when test="@moodCode='INT'">
                    <intent value="plan"/>
                </xsl:when>
                <xsl:when test="@moodCode='RQO'">
                    <intent value="order"/>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="cda:code">
                <xsl:with-param name="elementName">type</xsl:with-param>
            </xsl:apply-templates>
            <xsl:call-template name="subject-reference"/>
            <xsl:if test="cda:author[1]/cda:time">
                <authoredOn value="{lcg:cdaTS2date(cda:author/cda:time/@value)}"/>
            </xsl:if>
            <xsl:for-each select="cda:author">
                <requester>
                    <agent>
                        <reference value="urn:uuid:{@lcg:uuid}"/>
                    </agent>
                </requester>
            </xsl:for-each>
        </ReferralRequest>
    </xsl:template>
    
    <xsl:template match="cda:effectiveTime[@xsi:type='IVL_TS']" mode="medication-request">
        <boundsPeriod>
            <xsl:if test="cda:low[not(@nullFlavor)]">
                <start value="{lcg:cdaTS2date(cda:low/@value)}"/>
            </xsl:if>
            <xsl:if test="cda:high[not(@nullFlavor)]">
                <end value="{lcg:cdaTS2date(cda:high/@value)}"/>
            </xsl:if>
        </boundsPeriod>
    </xsl:template>
    
    <xsl:template match="cda:doseQuantity" mode="medication-request">
        <doseQuantity>
            <value value="{@value}"/>
        </doseQuantity>
    </xsl:template>
    
    <xsl:template match="cda:effectiveTime[@operator='A'][@xsi:type='PIVL_TS']" mode="medication-request">
        <xsl:if test="cda:period">
            <period value="{cda:period/@value}"/>
            <periodUnit value="{cda:period/@unit}"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="cda:effectiveTime[@operator='A']" mode="medication-request" priority="-1">
        <xsl:comment>Unknown effectiveTime pattern: 
            <cda:effectiveTime>
                <xsl:copy></xsl:copy>
            </cda:effectiveTime>
        </xsl:comment>
    </xsl:template>
    
    <xsl:template match="cda:consumable" mode="medication-request">
        <medicationCodeableConcept>
            <xsl:for-each select="cda:manufacturedProduct/cda:manufacturedMaterial/cda:code[@code][@codeSystem]">
                <xsl:message>TODO: Replace with actual content, not placeholder data</xsl:message>
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
            <xsl:for-each select="cda:manufacturedProduct/cda:manufacturedMaterial/cda:code/cda:translation[@code][@codeSystem]">
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
        </medicationCodeableConcept>
    </xsl:template>
    
</xsl:stylesheet>