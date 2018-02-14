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
    version="2.0"
    exclude-result-prefixes="lcg xsl cda fhir xs xsi sdtc xhtml">
    
    <xsl:import href="c-to-fhir-utility.xslt"/>
    <xsl:import href="cda2fhir-Narrative.xslt"/>
    
    <xsl:template match="cda:ClinicalDocument" mode="bundle-entry">
       <xsl:call-template name="create-bundle-entry"/>
    </xsl:template>
    
    <xsl:template match="cda:ClinicalDocument">
        <xsl:variable name="newSetIdUUID">
            <xsl:choose>
                <xsl:when test="cda:setId"><xsl:value-of select="cda:setId/@lcg:uuid"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="@lcg:uuid"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <Composition>
            <xsl:call-template name="add-meta"/>
            <language>
                <xsl:attribute name="value">
                    <xsl:value-of select="cda:languageCode/@code"/>
                </xsl:attribute>
            </language> 
            <text>
                <status value="generated"/>
                <div xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:call-template name="CDAtext"/>
                </div>
             </text>
            <identifier>
                <system value="urn:ietf:rfc:3986"/>
                <value value="urn:uuid:{$newSetIdUUID}"/>
            </identifier>
            <!-- TODO: add versionNumber once we create a C-CDA on FHIR extension to hold it -->
            <status value="final"/>
            <xsl:apply-templates select="cda:code">
                <xsl:with-param name="elementName">type</xsl:with-param>
            </xsl:apply-templates>
            <subject>
                <!-- TODO: handle multiple record targets (record as a group) --> 
                <reference value="urn:uuid:{cda:recordTarget/@lcg:uuid}"/>
            </subject>
            <xsl:if test="cda:componentOf/cda:encompassingEncounter">
                <encounter>
                    <xsl:apply-templates select="cda:componentOf/cda:encompassingEncounter" mode="reference"/>
                </encounter>
            </xsl:if>
            <date>
                <xsl:attribute name="value">
                    <xsl:value-of select="lcg:cdaTS2date(cda:effectiveTime/@value)"/>
                </xsl:attribute>
            </date>
            <author>
                <xsl:apply-templates select="cda:author" mode="reference"/>
            </author>
            <title>
                <xsl:attribute name="value">
                    <xsl:value-of select="cda:title"/>
                </xsl:attribute>
            </title>
            <confidentiality>
                <xsl:attribute name="value">
                    <xsl:value-of select="cda:confidentialityCode/@code"/>
                </xsl:attribute>
            </confidentiality>
            <xsl:if test="cda:legalAuthenticator">
                <attester>
                    <mode value="legal"/>
                    <xsl:if test="cda:legalAuthenticator/cda:time/@value">
                        <time value="{lcg:cdaTS2date(cda:legalAuthenticator/cda:time/@value)}"/>
                    </xsl:if>
                    <party>
                        <reference value="urn:uuid:{cda:legalAuthenticator/@lcg:uuid}"/>
                    </party>
                </attester>
            </xsl:if>
            
            <custodian>
                <xsl:apply-templates select="cda:custodian" mode="reference"/>
            </custodian>
            <relatesTo>
                <code value="transforms"/>
                <xsl:apply-templates select="cda:id">
                    <xsl:with-param name="elementName">targetIdentifier</xsl:with-param>
                </xsl:apply-templates>
            </relatesTo>
            <xsl:apply-templates select="cda:documentationOf/cda:serviceEvent" mode="composition-event"/>
            <xsl:apply-templates select="cda:component/cda:structuredBody/cda:component/cda:section"/>
            
        </Composition>
    </xsl:template>
    
    <xsl:template match="cda:section">
        <section>
            <title value="{cda:title}"/>
            <xsl:apply-templates select="cda:code">
                <xsl:with-param name="elementName">code</xsl:with-param>
            </xsl:apply-templates>
            <text>
                <xsl:choose>
                    <xsl:when test="count(cda:entry) = count(cda:entry[@typeCode='DRIV'])">
                        <status value="generated"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <status value="additional"/>
                    </xsl:otherwise>
                </xsl:choose>
                <div xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:apply-templates select="cda:text"/>
                </div>
            </text>
            <xsl:for-each select="cda:entry">
                <xsl:apply-templates select="cda:*" mode="reference">
                    <xsl:with-param name="sectionEntry">true</xsl:with-param>
                </xsl:apply-templates>
            </xsl:for-each>
            <xsl:apply-templates select="cda:component/cda:section"/>
        </section>
    </xsl:template>
    
    <xsl:template match="cda:serviceEvent" mode="composition-event">
        <event>
            <xsl:comment>Add CCDA-on-FHIR-Performer extension after C-CDA on FHIR is published</xsl:comment>
            
            <xsl:for-each select="cda:performer">
                <extension url="http://hl7.org/fhir/ccda/StructureDefinition/CCDA-on-FHIR-Performer">
                    <valueReference><reference value="urn:uuid:{@lcg:uuid}"/></valueReference>
                </extension>
            </xsl:for-each>
            <xsl:apply-templates select="cda:effectiveTime" mode="period"/>
            <!-- CarePlan resource not strictly needed for ONC-HIP use casem, but added at Clinician's on FHIR event.  -->
            <!--
            <detail>
                <xsl:apply-templates select="." mode="reference"/>
            </detail>
            -->
            
        </event>
    </xsl:template>
    
</xsl:stylesheet>