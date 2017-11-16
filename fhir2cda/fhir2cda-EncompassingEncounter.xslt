<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns="urn:hl7-org:v3"
    xmlns:lcg="http://www.lantanagroup.com" 
    xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
    xmlns:cda="urn:hl7-org:v3" 
    xmlns:fhir="http://hl7.org/fhir" 
    version="2.0"
    exclude-result-prefixes="lcg xsl cda fhir">
    
    <xsl:template match="fhir:encounter[parent::fhir:Composition]">
        <xsl:for-each select="fhir:reference">
            <xsl:variable name="referenceURI" select="@value"></xsl:variable>
            <xsl:for-each select="//fhir:entry[fhir:fullUrl/@value=$referenceURI]">
                <xsl:apply-templates select="fhir:resource/fhir:*" mode="encounter"/>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="fhir:entry/fhir:resource/fhir:Encounter" mode="encounter">
        <xsl:call-template name="make-encounter"/>
    </xsl:template>
    
    <xsl:template name="make-encounter">
        <componentOf>
            <encompassingEncounter>
                <xsl:for-each select="fhir:type">
                    <xsl:call-template name="CodeableConcept2CD"/>
                </xsl:for-each>
                <effectiveTime>
                    <low>
                        <xsl:attribute name="value">
                            <xsl:call-template name="Date2TS">
                                <xsl:with-param name="date" select="fhir:period/fhir:start/@value"/>
                                <xsl:with-param name="includeTime" select="true()" />
                            </xsl:call-template>
                        </xsl:attribute>
                    </low>
                    <xsl:if test="fhir:period/fhir:end">
                        <high>
                            <xsl:attribute name="value">
                                <xsl:call-template name="Date2TS">
                                    <xsl:with-param name="date" select="fhir:period/fhir:end/@value"/>
                                    <xsl:with-param name="includeTime" select="true()" />
                                </xsl:call-template>
                            </xsl:attribute>
                        </high>
                    </xsl:if>
                </effectiveTime>
                <responsibleParty>
                    <assignedEntity>
                        <xsl:for-each select="fhir:participant/fhir:individual/fhir:reference">
                            <xsl:variable name="referenceURI" select="@value"></xsl:variable>
                            <xsl:for-each select="//fhir:entry[fhir:fullUrl/@value=$referenceURI]">
                                <xsl:apply-templates select="fhir:resource/fhir:*" mode="encounter"/>
                            </xsl:for-each>
                        </xsl:for-each>
                    </assignedEntity>
                </responsibleParty>
            <!-- TODO: Location -->
            </encompassingEncounter>
        </componentOf>
    </xsl:template>
    
    <xsl:template match="fhir:entry/fhir:resource/fhir:Practitioner" mode="encounter">
        <xsl:call-template name="get-encounter-practitioner"/>
    </xsl:template>
    
    <xsl:template name="get-encounter-practitioner">
        <xsl:choose>
            <xsl:when test="fhir:identifier">
                <xsl:apply-templates select="fhir:identifier"/>
            </xsl:when>
            <xsl:otherwise>
                <id nullFlavor="NI"/>
            </xsl:otherwise>
        </xsl:choose>
        <addr>
            <streetAddressLine><xsl:value-of select="fhir:address/fhir:line/@value"/></streetAddressLine>
            <city><xsl:value-of select="fhir:address/fhir:city/@value"/></city>
            <state><xsl:value-of select="fhir:address/fhir:state/@value"/></state>
            <postalCode><xsl:value-of select="fhir:address/fhir:postalCode/@value"/></postalCode>
            <country><xsl:value-of select="fhir:address/fhir:country/@value"/></country>
        </addr>
        <xsl:for-each select="fhir:telecom">
            <telecom value="{fhir:value/@value}">
                <xsl:call-template name="telecomUse"/>
            </telecom>
        </xsl:for-each>
        <assignedPerson>
            <name>
                <family><xsl:value-of select="fhir:name/fhir:family/@value"/></family>
                <xsl:for-each select="fhir:name/fhir:given">
                    <given><xsl:value-of select="fhir:name/fhir:given/@value"/></given>
                </xsl:for-each>
                <suffix><xsl:value-of select="fhir:name/fhir:suffix/@value"/></suffix>
            </name>
        </assignedPerson>
    </xsl:template>
    
</xsl:stylesheet>