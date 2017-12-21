<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:hl7-org:v3"
    xmlns:lcg="http://www.lantanagroup.com" xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
    xmlns:cda="urn:hl7-org:v3" xmlns:fhir="http://hl7.org/fhir" 
    version="2.0"
    exclude-result-prefixes="lcg xsl cda fhir">
    
    <xsl:template match="fhir:List[fhir:code/fhir:coding[fhir:system/@value='http://snomed.info/sct'][fhir:code/@value='362956003']]" mode="entry">
        <xsl:param name="generated-narrative">additional</xsl:param>
        <xsl:comment>TODO: replace match with profile id when available</xsl:comment>
        <entry>
            <xsl:if test="$generated-narrative = 'generated'">
                <xsl:attribute name="typeCode">DRIV</xsl:attribute>
            </xsl:if>
            
            <xsl:call-template name="make-intervention-list"/>
        </entry>
    </xsl:template>
    
    <xsl:template match="fhir:RequestGroup" mode="entry">
        <xsl:param name="generated-narrative">additional</xsl:param>
        <xsl:comment>TODO: replace match with profile id when available</xsl:comment>
        <entry>
            <xsl:if test="$generated-narrative = 'generated'">
                <xsl:attribute name="typeCode">DRIV</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="make-intervention-request"/>        
        </entry>
    </xsl:template>
    
    <xsl:template name="make-intervention-request">
        <xsl:param name="time">
            <xsl:call-template name="Date2TS">
                <xsl:with-param name="date" select="fhir:authoredOn/@value"/>
                <xsl:with-param name="includeTime" select="true()" />
            </xsl:call-template>
        </xsl:param>
        <act classCode="ACT" moodCode="INT">
            <templateId extension="2015-08-01" root="2.16.840.1.113883.10.20.22.4.146" />
            <templateId extension="2017-08-01" root="2.16.840.1.113883.10.20.37.3.12" />
            <xsl:choose>
                <xsl:when test="fhir:identifier">
                    <xsl:apply-templates select="fhir:identifier"/>
                </xsl:when>
                <xsl:otherwise>
                    <id nullFlavor="NI"/>
                </xsl:otherwise>
            </xsl:choose>
            <code code="362956003" displayName="Intervention" codeSystemName="SNOMED" codeSystem="2.16.840.1.113883.6.96" />
            <statusCode code="active" />
            <xsl:if test="fhir:authoredOn">
                <effectiveTime value="{$time}"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="fhir:reasonReference">
                    <xsl:variable name="referenceURI">
                        <xsl:call-template name="resolve-to-full-url">
                            <xslt:with-param name="referenceURI" select="fhir:reasonReference/fhir:reference/@value"></xslt:with-param>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:for-each select="//fhir:entry[fhir:fullUrl/@value=$referenceURI]">
                        <xsl:apply-templates select="fhir:resource/fhir:*" mode="entry-relationship"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <entryRelationship typeCode="RSON">
                        <act classCode="ACT" moodCode="EVN" nullFlavor="RSON">
                            <templateId root="2.16.840.1.113883.10.20.22.4.122" />
                            <id nullFlavor="NI"/>
                            <code nullFlavor="NI"/>
                            <statusCode code="completed"/>
                        </act>
                    </entryRelationship>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:for-each select="fhir:action/fhir:resource">
                <xsl:if test="fhir:reference">
                    <xsl:for-each select="fhir:reference">
                        <xsl:variable name="referenceURI">
                            <xsl:call-template name="resolve-to-full-url">
                                <xslt:with-param name="referenceURI" select="@value"></xslt:with-param>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:for-each select="//fhir:entry[fhir:fullUrl/@value=$referenceURI]">
                            <xsl:apply-templates select="fhir:resource/fhir:*" mode="entry-relationship">
                                <xsl:with-param name="typeCode">REFR</xsl:with-param>
                            </xsl:apply-templates>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:if>
            </xsl:for-each>
        </act>
    </xsl:template>
    
    <xsl:template name="make-intervention-list">
        <xsl:param name="time">
            <xsl:call-template name="Date2TS">
                <xsl:with-param name="date" select="fhir:date/@value"/>
                <xsl:with-param name="includeTime" select="true()" />
            </xsl:call-template>
        </xsl:param>
        <act classCode="ACT" moodCode="EVN">
            <templateId extension="2015-08-01" root="2.16.840.1.113883.10.20.22.4.131" />
            <templateId extension="2017-08-01" root="2.16.840.1.113883.10.20.37.3.15" />
            <xsl:choose>
                <xsl:when test="fhir:identifier">
                    <xsl:apply-templates select="fhir:identifier"/>
                </xsl:when>
                <xsl:otherwise>
                    <id nullFlavor="NI"/>
                </xsl:otherwise>
            </xsl:choose>
            <code code="362956003" displayName="Procedure/intervention" codeSystemName="SNOMED" codeSystem="2.16.840.1.113883.6.96" />
            <statusCode code="completed" />
            <effectiveTime value="{$time}"/>
            <xsl:for-each select="fhir:entry/fhir:item">
                <xsl:for-each select="fhir:reference">
                    <xsl:variable name="referenceURI">
                        <xsl:call-template name="resolve-to-full-url">
                            <xslt:with-param name="referenceURI" select="@value"></xslt:with-param>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:for-each select="//fhir:entry[fhir:fullUrl/@value=$referenceURI]">
                        <xsl:apply-templates select="fhir:resource/fhir:*" mode="entry-relationship">
                            <xsl:with-param name="typeCode">REFR</xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:for-each>
        </act>
    </xsl:template>
    
</xsl:stylesheet>