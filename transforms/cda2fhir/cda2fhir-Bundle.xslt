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
   
    <xsl:template match="/" mode="convert">
        <Bundle>
            <identifier>
                <system value="urn:ietf:rfc:3986"/>
                <value value="urn:uuid:{cda:ClinicalDocument/cda:id/@lcg:uuid}"/>
            </identifier>
            <type value="document"/>
            <xsl:apply-templates select="cda:ClinicalDocument" mode="bundle-entry"/>
            <xsl:apply-templates select="cda:ClinicalDocument/cda:recordTarget" mode="bundle-entry"/>
            <!-- CarePlan resource not needed for ONC-HIP use case. Revisit later. -->
            <!--
            <xsl:apply-templates select="cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent" mode="bundle-entry"/>
            -->
            <xsl:apply-templates select="cda:ClinicalDocument/cda:componentOf/cda:encompassingEncounter" mode="bundle-entry"/>
            <xsl:apply-templates select="//cda:author" mode="bundle-entry"/>
            <xsl:apply-templates select="//cda:performer" mode="bundle-entry"/>
            <xsl:apply-templates select="//cda:participant[@typeCode='IRCP']" mode="bundle-entry"/>
            <xsl:apply-templates select="//cda:performer/cda:assignedEntity/cda:representedOrganization" mode="bundle-entry"/>
            <xsl:apply-templates select="cda:ClinicalDocument/cda:custodian" mode="bundle-entry"/>
            <xsl:apply-templates select="cda:ClinicalDocument/cda:legalAuthenticator" mode="bundle-entry"/>
            <xsl:message>TODO: Add remaining header resources</xsl:message>
            <xsl:for-each select="//descendant::cda:entry">
                <xsl:apply-templates select="cda:*[not(@nullFlavor)]" mode="bundle-entry"/>
            </xsl:for-each>
        </Bundle>
    </xsl:template>
    
    <!-- Remove Concern wrappers --> 
    <xsl:template match="cda:act[
        cda:templateId[@root='2.16.840.1.113883.10.20.22.4.132']
        or cda:templateId[@root='2.16.840.1.113883.10.20.22.4.3']
        or cda:templateId[@root='2.16.840.1.113883.10.20.22.4.30']
        or cda:templateId[@root='2.16.840.1.113883.10.20.22.4.136']
        ]" mode="reference">  
        <xsl:param name="sectionEntry">false</xsl:param>
        <xsl:param name="listEntry">false</xsl:param>
        <xsl:for-each select="cda:entryRelationship/cda:*[not(@nullFlavor)]">
            <xsl:apply-templates select="." mode="reference">
                <xsl:with-param name="sectionEntry" select="$sectionEntry"/>
                <xsl:with-param name="listEntry" select="$listEntry"/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Remove Concern wrappers --> 
    <xsl:template match="cda:act[
        cda:templateId[@root='2.16.840.1.113883.10.20.22.4.132']
        or cda:templateId[@root='2.16.840.1.113883.10.20.22.4.3']
        or cda:templateId[@root='2.16.840.1.113883.10.20.22.4.30']
        or cda:templateId[@root='2.16.840.1.113883.10.20.22.4.136']
        ]" mode="bundle-entry">
        <xsl:comment>Processing concern wrapper: <xsl:value-of select="cda:templateId[1]/@root"/></xsl:comment>
        <xsl:for-each select="cda:entryRelationship/cda:*[not(@nullFlavor)]">
            <xsl:apply-templates select="." mode="bundle-entry"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="cda:act[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.80']]" mode="reference">  
        <xsl:param name="sectionEntry">false</xsl:param>
        <xsl:param name="listEntry">false</xsl:param> 
        <!-- Remove Encounter Diagnosis wrappers, since maps to Condition.category -->  
        <xsl:for-each select="cda:entryRelationship/cda:*[not(@nullFlavor)]">
            <xsl:apply-templates select="." mode="reference">
                <xsl:with-param name="sectionEntry" select="$sectionEntry"/>
                <xsl:with-param name="listEntry" select="$listEntry"/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="cda:act[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.80']]" mode="bundle-entry">
        <!-- Remove Encounter Diagnosis wrappers, since maps to Condition.category --> 
        <xsl:comment>Removed Encounter diagnosis wrapper</xsl:comment>
        <xsl:for-each select="cda:entryRelationship/cda:*[not(@nullFlavor)]">
            <xsl:apply-templates select="." mode="bundle-entry"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="cda:*[@nullFlavor]" mode="bundle-entry">
        <!-- Suppress -->
    </xsl:template>
    
</xsl:stylesheet>