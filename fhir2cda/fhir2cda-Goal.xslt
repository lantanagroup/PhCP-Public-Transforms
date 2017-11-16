<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:hl7-org:v3"
    xmlns:lcg="http://www.lantanagroup.com" xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
    xmlns:cda="urn:hl7-org:v3" xmlns:fhir="http://hl7.org/fhir" 
    version="2.0"
    exclude-result-prefixes="lcg xsl cda fhir">

    <xsl:template match="fhir:Goal" mode="entry">
        <xsl:param name="generated-narrative">additional</xsl:param>
        <xsl:comment>TODO: replace match with profile id when available</xsl:comment>
        <entry>
            <xsl:if test="$generated-narrative = 'generated'">
                <xsl:attribute name="typeCode">DRIV</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="make-goal"/>
        </entry>
    </xsl:template>
    
    <xsl:template match="fhir:Goal" mode="entry-relationship">
        <entryRelationship typeCode="RSON">
            <act classCode="ACT" moodCode="EVN">
                <!-- [C-CDA R2.0] Entry Reference -->
                <templateId root="2.16.840.1.113883.10.20.22.4.122" />
                <xsl:choose>
                    <xsl:when test="fhir:identifier">
                        <xsl:apply-templates select="fhir:identifier"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <id nullFlavor="NI"/>
                    </xsl:otherwise>
                </xsl:choose>
                <code nullFlavor="NP"/>
                <statusCode code="completed"/>
            </act>
        </entryRelationship>
    </xsl:template>

    <xsl:template name="make-goal">
        <observation classCode="OBS" moodCode="GOL">
            <!-- [C-CDA R2.0] Goal Observation -->
            <templateId root="2.16.840.1.113883.10.20.22.4.121"/>
            <!-- [PCP R1 STU1] Goal Observation (Pharmacist Care Plan)  -->
            <templateId root="2.16.840.1.113883.10.20.37.3.7" extension="2017-08-01"/>
            <xsl:choose>
                <xsl:when test="fhir:identifier">
                    <xsl:apply-templates select="fhir:identifier"/>
                </xsl:when>
                <xsl:otherwise>
                    <id nullFlavor="NI"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:for-each select="fhir:description">
                <xsl:call-template name="CodeableConcept2CD"/>
            </xsl:for-each>
            <xsl:apply-templates select="fhir:status" mode="goal"/>
            <xsl:if test="fhir:outcomeReference">
                <xslt:variable name="ref">
                    <xslt:value-of select="fhir:outcomeReference/fhir:reference/@value"/>
                </xslt:variable>
                <effectiveTime>
                    <low>
                        <xsl:attribute name="value">
                            <xsl:call-template name="Date2TS">
                                <xsl:with-param name="date" select="//fhir:entry[fhir:fullUrl[@value=$ref]]/fhir:resource/fhir:Observation/fhir:effectiveDateTime/@value"/>
                                <xsl:with-param name="includeTime" select="true()" />
                            </xsl:call-template>
                        </xsl:attribute>
                    </low>
                </effectiveTime>
            </xsl:if>
            <xsl:apply-templates select="fhir:subject"/>
            <xsl:apply-templates select="fhir:expressedBy"/>
            
            <xsl:for-each select="fhir:entry/fhir:item">
                <xsl:for-each select="fhir:reference">
                    <xsl:variable name="referenceURI">
                <xsl:call-template name="resolve-to-full-url">
                    <xslt:with-param name="referenceURI" select="@value"></xslt:with-param>
                </xsl:call-template>
            </xsl:variable>
                    <xsl:for-each select="//fhir:entry[fhir:fullUrl/@value = $referenceURI]">
                        <xsl:apply-templates select="fhir:resource/fhir:*" mode="entry-relationship">
                            <xsl:with-param name="typeCode">REFR</xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:for-each>
        </observation>
    </xsl:template>
    
    <xsl:template match="fhir:status" mode="goal">
        <!-- TODO: actually map the status codes, not always the same between CDA and FHIR -->
        <!-- TODO: the status might be better pulled from the outcome observation -->
        <xsl:choose>
            <xsl:when test="@value = 'in-progress'">
                <statusCode code="active"/>
            </xsl:when>
            <xsl:otherwise>
                <statusCode code="{@value}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="fhir:expressedBy[parent::fhir:Goal]">
        <xsl:for-each select="fhir:reference">
            <xsl:variable name="referenceURI">
                <xsl:call-template name="resolve-to-full-url">
                    <xslt:with-param name="referenceURI" select="@value"></xslt:with-param>
                </xsl:call-template>
            </xsl:variable>
            <xsl:for-each select="//fhir:entry[fhir:fullUrl/@value=$referenceURI]">
                <xsl:variable name="author-time">
                    <xsl:choose>
                        <xsl:when test="parent::fhir:assertedDate/@value">
                            <xsl:call-template name="Date2TS">
                                <xsl:with-param name="date" select="//parent::fhir:assertedDate/@value"/>
                                <xsl:with-param name="includeTime" select="true()" />
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="Date2TS">
                                <xsl:with-param name="date" select="//fhir:Composition[1]/fhir:date/@value"/>
                                <xsl:with-param name="includeTime" select="true()" />
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:apply-templates select="fhir:resource/fhir:*" mode="author">
                    <xsl:with-param name="author-time" select="$author-time"/>
                </xsl:apply-templates>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
