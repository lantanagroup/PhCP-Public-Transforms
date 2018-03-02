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
    
    <xsl:import href="c-to-fhir-utility.xslt"/>
        
    <xsl:template match="cda:supply[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.18']]" mode="bundle-entry">
        <xsl:call-template name="create-bundle-entry"/>
    </xsl:template>


	<!-- 
    <xsl:template
        match="cda:supply[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.18']]"
        mode="reference">
        <xsl:param name="sectionEntry">false</xsl:param>
        <xsl:param name="listEntry">false</xsl:param>
        <xsl:choose>
            <xsl:when test="$sectionEntry='true'">
                <entry>
                    <reference value="urn:uuid:{@lcg:uuid}"/>
                </entry>
            </xsl:when>
            <xsl:when test="$listEntry='true'">
                <entry><item>
                    <reference value="urn:uuid:{@lcg:uuid}"/></item>
                </entry>
            </xsl:when>
            <xsl:otherwise>
                <reference value="urn:uuid:{@lcg:uuid}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
     -->
    
    <xsl:template match="cda:supply[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.18']]">
        <MedicationDispense>
            <xsl:apply-templates select="cda:id"/>
            <xsl:choose>
                <xsl:when test="cda:statusCode/@code = 'completed'">
                    <status value="completed"/>
                </xsl:when>
                <xsl:when test="cda:statusCode/@code = 'aborted'">
                    <status value="stopped"/>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="cda:product" mode="medication-dispense"/>
            <xsl:call-template name="subject-reference"/>
            <xsl:if test="cda:performer">
                <performer>
                    <actor>
                        <xsl:apply-templates select="cda:performer" mode="reference"/>
                    </actor>
                    <xsl:for-each select="cda:performer/cda:assignedEntity/cda:representedOrganization">
                        <onBehalfOf>
                            <xsl:apply-templates select="." mode="reference"/>
                        </onBehalfOf>
                    </xsl:for-each>
                </performer>
            </xsl:if>
            <xsl:if test="ancestor::cda:substanceAdministration[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.16'][@moodCode='INT']">
                <!-- TODO: Add the MedicationDispense directly to the parent of the prescription (i.e. the section, intervention, or care plan). If not, it may not get pulled in via $document -->
                <authorizingPrescription>
                    <xsl:apply-templates select="ancestor::cda:substanceAdministration[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.16'][@moodCode='INT'][1]" mode="reference"/>
                </authorizingPrescription>
            </xsl:if>
            <xsl:apply-templates select="cda:quantity" mode="medication-dispense"/>
            <xsl:apply-templates select="ancestor::cda:substanceAdministration/cda:effectiveTime[@xsi:type='IVL_TS']" mode="medication-dispense"/>
            <xsl:if test="cda:effectiveTime/@value">
                <whenHandedOver value="{lcg:cdaTS2date(cda:effectiveTime/@value)}"/>
            </xsl:if>
        </MedicationDispense>
    </xsl:template>
    
    <xsl:template match="cda:effectiveTime[@xsi:type='IVL_TS'][cda:high/@value][cda:low/@value]" mode="medication-dispense">
        <xsl:variable name="days">
            <xsl:value-of select="days-from-duration(xs:date(lcg:cdaTS2date(cda:high/@value)) -
                xs:date(lcg:cdaTS2date(cda:low/@value)))"/>
        </xsl:variable>
        <daysSupply>
            <value value="{$days}"/>
        </daysSupply> 
    </xsl:template>
    
    <xsl:template match="cda:quantity" mode="medication-dispense">
        <quantity>
            <xsl:if test="@value">
                <value value="{@value}"/>
            </xsl:if>
            <xsl:if test="@unit">
                <unit value="{@unit}"/>
            </xsl:if>
            <xsl:if test="@nullFlavor">
                <code value="{@nullFlavor}"/>
                <system value="http://hl7.org/fhir/v3/NullFlavor"/>
            </xsl:if>
        </quantity>
    </xsl:template>
    
    <xsl:template match="cda:product" mode="medication-dispense">            
        <xsl:for-each select="cda:manufacturedProduct/cda:manufacturedMaterial/cda:code">
            <xsl:call-template name="newCreateCodableConcept">
                <xsl:with-param name="elementName">medicationCodeableConcept</xsl:with-param>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>