<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://hl7.org/fhir" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cda="urn:hl7-org:v3" xmlns:fhir="http://hl7.org/fhir" xmlns:sdtc="urn:hl7-org:sdtc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:lcg="http://www.lantanagroup.com" version="2.0">


    <xsl:template
        match="cda:*"
        mode="reference" priority="-1">
        <xsl:comment>
			<xsl:text>Unmapped entry reference: </xsl:text>
			<xsl:value-of select="local-name(.)"/>
			<xsl:for-each select="cda:templateId">
				<xsl:text> urn:hl7ii:</xsl:text>
				<xsl:value-of select="@root"/>
				<xsl:if test="@extension">
					<xsl:text>:</xsl:text>
					<xsl:value-of select="@extension"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:comment>
    </xsl:template>

    <!-- swallow unmapped entry and entryRelationship children -->

    <xsl:template match="*[parent::cda:entry] | *[parent::cda:entryRelationship] | *[parent::act[cda:templateId[@root='2.16.840.1.113883.10.20.22.4.132'][@extension='2015-08-01']]]" priority="-1"
        mode="bundle-entry">
        <xsl:choose>
            
        <xsl:when test="cda:templateId">
            <xsl:for-each select="cda:templateId">
                <xsl:message terminate="no"><xsl:text>No template match for </xsl:text>
                    <xsl:value-of select="@root"/>
                    <xsl:if test="@extension">
                        <xsl:text>: </xsl:text><xsl:value-of select="@extension"/>
                    </xsl:if>
                </xsl:message>
                
                <xsl:comment><xsl:text>No template match for </xsl:text>
                    <xsl:value-of select="@root"/>
                    <xsl:if test="@extension">
                        <xsl:text>: </xsl:text><xsl:value-of select="@extension"/>
                    </xsl:if>
                </xsl:comment>
            </xsl:for-each>
        </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="no"><text>No match for </text>
                    <xsl:value-of select="."/>
                </xsl:message>
                <xsl:comment><text>No match for </text>
                    <xsl:value-of select="."/>
                </xsl:comment>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
