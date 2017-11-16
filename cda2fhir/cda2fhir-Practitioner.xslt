<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://hl7.org/fhir" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cda="urn:hl7-org:v3" 
    xmlns:fhir="http://hl7.org/fhir" 
    xmlns:sdtc="urn:hl7-org:sdtc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:lcg="http://www.lantanagroup.com" 
    exclude-result-prefixes="lcg xsl cda fhir xs xsi sdtc xhtml"
    version="2.0">

    <xsl:template match="cda:author | cda:legalAuthenticator | cda:performer | cda:participant" mode="bundle-entry">
        <xsl:call-template name="create-bundle-entry"/>
    </xsl:template>
    
    <xsl:template
        match="cda:author | cda:legalAuthenticator | cda:performer | cda:participant"
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

    <xsl:template match="cda:author">
        <xsl:call-template name="make-practitioner">
            <xsl:with-param name="id" select="cda:assignedAuthor/cda:id"></xsl:with-param>
            <xsl:with-param name="name" select="cda:assignedAuthor/cda:assignedPerson/cda:name"></xsl:with-param>
            <xsl:with-param name="telecom" select="cda:assignedAuthor/cda:telecom"></xsl:with-param>
            <xsl:with-param name="address" select="cda:assignedAuthor/cda:addr"></xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="cda:legalAuthenticator">
        <xsl:call-template name="make-practitioner">
            <xsl:with-param name="id" select="cda:assignedEntity/cda:id"></xsl:with-param>
            <xsl:with-param name="name" select="cda:assignedEntity/cda:assignedPerson/cda:name"></xsl:with-param>
            <xsl:with-param name="telecom" select="cda:assignedEntity/cda:telecom"></xsl:with-param>
            <xsl:with-param name="address" select="cda:assignedEntity/cda:addr"></xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="cda:performer">
        <xsl:call-template name="make-practitioner">
            <xsl:with-param name="id" select="cda:assignedEntity/cda:id"></xsl:with-param>
            <xsl:with-param name="name" select="cda:assignedEntity/cda:assignedPerson/cda:name"></xsl:with-param>
            <xsl:with-param name="telecom" select="cda:assignedEntity/cda:telecom"></xsl:with-param>
            <xsl:with-param name="address" select="cda:assignedEntity/cda:addr"></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="cda:participant">
        <xsl:call-template name="make-practitioner">
            <xsl:with-param name="id" select="cda:participantRole/cda:id"></xsl:with-param>
            <xsl:with-param name="name" select="cda:participantRole/cda:playingEntity/cda:name"></xsl:with-param>
            <xsl:with-param name="telecom" select="cda:participantRole/cda:telecom"></xsl:with-param>
            <xsl:with-param name="address" select="cda:participantRole/cda:addr"></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="make-practitioner">
        <xsl:param name="id"></xsl:param>
        <xsl:param name="name"></xsl:param>
        <xsl:param name="telecom"></xsl:param>
        <xsl:param name="address"></xsl:param>
        <Practitioner>
            <!--
            <id value="{@lcg:uuid}"/>
            -->
            <text>
                <status value="generated"/>
                <!-- Not sure how you'd like the ID info generated in the html output. I can output them in the way the rest of it is done but wanted to double check. -->
                <div xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:for-each select="$name">
                        <p>Name: <xsl:value-of select="cda:family"/>, <xsl:value-of
                                select="cda:given"/></p>
                    </xsl:for-each>
                    <p>---TODO: ID info---</p>
                    <p>Telephone: <xsl:value-of select="$telecom/@value"/></p>
                </div>

            </text>
            <xsl:apply-templates select="$id"/>
            <xsl:apply-templates select="$name"/>
            <!--
            <xsl:for-each select="$name">
                <name>
                    <xsl:for-each select="cda:family">
                        <family>
                            <xsl:attribute name="value">
                                <xsl:value-of select="."/>
                            </xsl:attribute>
                        </family>
                    </xsl:for-each>
                    <xsl:for-each select="cda:given">
                        <given>
                            <xsl:attribute name="value">
                                <xsl:value-of select="."/>
                            </xsl:attribute>
                        </given>
                    </xsl:for-each>
                    <xsl:for-each select="cda:prefix">
                        <prefix>
                            <xsl:attribute name="value">
                                <xsl:value-of select="."/>
                            </xsl:attribute>
                        </prefix>
                    </xsl:for-each>
                    <xsl:for-each select="cda:suffix">
                        <suffix>
                            <xsl:attribute name="value">
                                <xsl:value-of select="."/>
                            </xsl:attribute>
                        </suffix>
                    </xsl:for-each>
                </name>
            </xsl:for-each>
            -->
            <xsl:apply-templates select="$telecom"/>
            <xsl:apply-templates select="$address"/>
            <!-- Qualification -->
            <xsl:choose>
                <xsl:when test="cda:participantRole">
                    <xsl:apply-templates select="cda:participantRole/cda:code" mode="practitioner"/>
                </xsl:when>
                <xsl:when test="cda:assignedAuthor">
                    <xsl:apply-templates select="cda:assignedAuthor/cda:code" mode="practitioner"/>
                </xsl:when>
            </xsl:choose>
        </Practitioner>
    </xsl:template>
    
    <xsl:template match="cda:code" mode="practitioner">
        <qualification>
            <xsl:call-template name="newCreateCodableConcept">
                <xsl:with-param name="elementName">code</xsl:with-param>
            </xsl:call-template>
        </qualification>
    </xsl:template>
</xsl:stylesheet>
