<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns="urn:hl7-org:v3"
    xmlns:lcg="http://www.lantanagroup.com" 
    xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
    xmlns:cda="urn:hl7-org:v3" 
    xmlns:fhir="http://hl7.org/fhir" 
    xmlns:sdtc="urn:hl7-org:sdtc"
    version="2.0"
    exclude-result-prefixes="lcg xsl cda fhir sdtc">
    
    <xsl:template match="fhir:subject[parent::fhir:Composition]">
        <xsl:for-each select="fhir:reference">
            <xsl:variable name="referenceURI">
                <xsl:call-template name="resolve-to-full-url">
                    <xslt:with-param name="referenceURI" select="@value"></xslt:with-param>
                </xsl:call-template>
            </xsl:variable>
            <xsl:for-each select="//fhir:entry[fhir:fullUrl/@value=$referenceURI]">
    	        <xsl:apply-templates select="fhir:resource/fhir:*" mode="record-target"/>
    	    </xsl:for-each>
    	</xsl:for-each>
    </xsl:template>
    
    <xsl:template match="fhir:entry/fhir:resource/fhir:Patient" mode="record-target">
        <xsl:call-template name="make-record-target"/>
    </xsl:template>
    
    <xsl:template name="make-record-target">
        <recordTarget>
            <patientRole>
                <xsl:choose>
                    <xsl:when test="fhir:identifier">
                        <xsl:apply-templates select="fhir:identifier"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <id nullFlavor="NI"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="fhir:address">
                        <xsl:apply-templates select="fhir:address"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <addr nullFlavor="NI"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="fhir:telecom">
                        <xsl:for-each select="fhir:telecom">
                            <telecom value="{fhir:value/@value}">
                                <xsl:call-template name="telecomUse"/>
                            </telecom>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <telecom nullFlavor="NI"/>
                    </xsl:otherwise>
                </xsl:choose>
                <patient>
                    <xsl:for-each select="fhir:name">
                        <xsl:variable name="use">
                            <xsl:choose>
                                <xsl:when test="fhir:use/@value = 'usual'">L</xsl:when>
                                <xsl:when test="fhir:use/@value = 'nickname'">P</xsl:when>
                                <!-- Not sure of the exact condition of when to use this label -->
                                <!-- xsl:when test="fhir:use/@value = 'maiden'">BR</xsl:when -->
                            </xsl:choose>
                        </xsl:variable>
                        <name>
                            <xsl:if test="string-length($use) > 0">
                                <xsl:attribute name="use">
                                    <xsl:value-of select="$use"/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:for-each select="fhir:given">
                                <given>
                                    <xsl:value-of select="@value"/>
                                </given>
                            </xsl:for-each>
                            <family>
                                <xsl:value-of select="fhir:family/@value"/>
                            </family>
                            <xsl:if test="fhir:suffix">
                                <suffix>
                                    <xsl:value-of select="fhir:suffix/@value"/>
                                </suffix>
                            </xsl:if>
                        </name>
                    </xsl:for-each>
                    <administrativeGenderCode codeSystem="2.16.840.1.113883.5.1" codeSystemName="AdministrativeGender">
                        <xsl:choose>
                            <xsl:when test="lower-case(fhir:gender/@value) = 'female'">
                                <xsl:attribute name="code">F</xsl:attribute>
                                <xsl:attribute name="displayName">Female</xsl:attribute>
                            </xsl:when>
                            <xsl:when test="lower-case(fhir:gender/@value) = 'male'">
                                <xsl:attribute name="code">M</xsl:attribute>
                                <xsl:attribute name="displayName">Male</xsl:attribute>
                            </xsl:when>
                            <xsl:when test="lower-case(fhir:gender/@value) = 'undifferentiated'">
                                <xsl:attribute name="code">UN</xsl:attribute>
                                <xsl:attribute name="displayName">Undifferentiated</xsl:attribute>
                            </xsl:when>
                        </xsl:choose>
                    </administrativeGenderCode>
                    <xsl:choose>
                        <xsl:when test="fhir:birthDate">
                            <birthTime>
                                <xsl:attribute name="value">
                                    <xsl:call-template name="Date2TS">
                                        <xsl:with-param name="date" select="fhir:birthDate/@value"/>
                                        <xsl:with-param name="includeTime" select="true()" />
                                    </xsl:call-template>
                                </xsl:attribute>
                            </birthTime>
                        </xsl:when>
                        <xsl:otherwise>
                            <birthTime nullFlavor="NI"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:call-template name="add-race-codes"/>
                    <xsl:call-template name="add-ethnicity-codes"/>
                </patient>
            </patientRole>
        </recordTarget>
    </xsl:template>
    
    
    <xsl:template name="add-race-codes">
        <xsl:for-each select="fhir:extension[@url='http://hl7.org/fhir/us/core/StructureDefinition/us-core-race']">
            <xsl:for-each select="fhir:extension[@url='ombCategory']">
                <xsl:choose>
                    <xsl:when test="position()=1">
                        <raceCode 
                            code="{fhir:valueCoding/fhir:code/@value}" 
                            displayName="{fhir:valueCoding/fhir:code/@value}"
                            codeSystem="2.16.840.1.113883.6.238"
                            codeSystemName="{fhir:valueCoding/fhir:system/@value}"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <sdtc:raceCode 
                            code="{fhir:valueCoding/fhir:code/@value}" 
                            displayName="{fhir:valueCoding/fhir:code/@value}"
                            codeSystem="2.16.840.1.113883.6.238"
                            codeSystemName="{fhir:valueCoding/fhir:system/@value}"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <xsl:for-each select="fhir:extension[@url='detailed']">
                <sdtc:raceCode 
                    code="{fhir:valueCoding/fhir:code/@value}" 
                    displayName="{fhir:valueCoding/fhir:code/@value}"
                    codeSystem="2.16.840.1.113883.6.238"
                    codeSystemName="{fhir:valueCoding/fhir:system/@value}"
                />
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="add-ethnicity-codes">
        <xsl:for-each select="fhir:extension[@url='http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity']">
            <xsl:for-each select="fhir:extension[@url='ombCategory']">
                <xsl:choose>
                    <xsl:when test="position()=1">
                        <ethnicGroupCode 
                            code="{fhir:valueCoding/fhir:code/@value}" 
                            displayName="{fhir:valueCoding/fhir:code/@value}"
                            codeSystem="2.16.840.1.113883.6.238"
                            codeSystemName="{fhir:valueCoding/fhir:system/@value}"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <sdtc:ethnicGroupCode 
                            code="{fhir:valueCoding/fhir:code/@value}" 
                            displayName="{fhir:valueCoding/fhir:code/@value}"
                            codeSystem="2.16.840.1.113883.6.238"
                            codeSystemName="{fhir:valueCoding/fhir:system/@value}"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <xsl:for-each select="fhir:extension[@url='detailed']">
                <sdtc:ethnicGroupCode 
                    code="{fhir:valueCoding/fhir:code/@value}" 
                    displayName="{fhir:valueCoding/fhir:code/@value}"
                    codeSystem="2.16.840.1.113883.6.238"
                    codeSystemName="{fhir:valueCoding/fhir:system/@value}"
                />
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    
    
</xsl:stylesheet>