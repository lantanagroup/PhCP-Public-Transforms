<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:hl7-org:v3"
    xmlns:lcg="http://www.lantanagroup.com" xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
    xmlns:cda="urn:hl7-org:v3" 
    xmlns:fhir="http://hl7.org/fhir" 
    xmlns:xhtml="http://www.w3.org/1999/xhtml" 
    version="2.0"
    exclude-result-prefixes="lcg xsl cda fhir xhtml">
    
    <xsl:template name="Date2TS">
        <xsl:param name="date"/>
        <xsl:param name="includeTime" select="true()"></xsl:param>
        
        <xsl:variable name="date-part">
            <xsl:choose>
                <xsl:when test="contains($date,'T')">
                    <xsl:value-of select="substring-before($date,'T')"/>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="$date"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="time-and-offset-part" select="substring-after($date,'T')" />
        <xsl:variable name="time-part">
            <xsl:choose>
                <xsl:when test="contains($time-and-offset-part,'-')">
                    <xsl:value-of select="substring-before($time-and-offset-part,'-')"/>
                </xsl:when>
                <xsl:when test="contains($time-and-offset-part,'+')">
                    <xsl:value-of select="substring-before($time-and-offset-part,'+')"/>
                </xsl:when>
                <xsl:when test="contains($time-and-offset-part,'Z')">
                    <xsl:value-of select="substring-before($time-and-offset-part,'Z')"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="offset-part">
            <xsl:if test="contains($time-and-offset-part,'-')">
                <xsl:text>-</xsl:text>
                <xsl:value-of select="substring-after($time-and-offset-part,'-')"/>
            </xsl:if>
            <xsl:if test="contains($time-and-offset-part,'+')">
                <xsl:text>+</xsl:text>
                <xsl:value-of select="substring-after($time-and-offset-part,'+')"/>
            </xsl:if>
            <xsl:if test="contains($time-and-offset-part,'Z')">+0000</xsl:if>
        </xsl:variable>
        <xsl:if test="$date-part">
            <xsl:value-of select="translate($date-part,'-','')"/>
        </xsl:if>
        <xsl:if test="$time-part and $includeTime">
            <xsl:value-of select="translate($time-part,':','')"/>
        </xsl:if>
        <xsl:if test="$offset-part">
            <xsl:value-of select="translate($offset-part,':','')"/>
        </xsl:if>
    </xsl:template>
    
    
    <xsl:template name="convertURI">
        <xsl:param name="uri"/>
        <xsl:variable name="mapping" select="document('../oid-uri-mapping.xml')/mapping"/>
        <xsl:choose>
            <xsl:when test="$mapping/map[@uri = $uri]">
                <xsl:value-of select="$mapping/map[@uri = $uri][1]/@oid"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="starts-with($uri,'urn:oid')">
                        <xsl:value-of select="substring-after($uri,'urn:oid:')"/>
                    </xsl:when>
                    <xsl:when test="starts-with($uri,'urn:uuid')">
                        <xsl:value-of select="substring-after($uri,'urn:uuid:')"/>
                    </xsl:when>
                    <xsl:otherwise>
                		<xsl:message>Warning: Unmapped URI - <xsl:value-of select="$uri"/></xsl:message>
                        <xsl:value-of select="$uri"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="telecomUse">
        <xsl:param name="use"/>
        <xsl:attribute name="use">
            <xsl:choose>
                <xsl:when test="fhir:use/@value = 'home'">H</xsl:when>
                <xsl:when test="fhir:use/@value = 'work'">WP</xsl:when>
                <xsl:when test="fhir:use/@value = 'mobile'">MC</xsl:when>
                <!-- default to work -->
                <xsl:otherwise>WP</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    
    
    <xsl:template name="resolve-to-full-url">
        <xsl:param name="referenceURI"/>
        <xsl:param name="entryFullUrl">
            <xsl:value-of select="ancestor::fhir:entry/fhir:fullUrl/@value"/>
        </xsl:param>
        <xsl:param name="currentResourceType">
            <xsl:value-of select="local-name(ancestor::fhir:entry/fhir:resource/fhir:*)"/>
        </xsl:param>
        <xsl:choose>
            <xsl:when test="starts-with($referenceURI,'http:')">
                <xsl:call-template name="remove-history-from-url">
                    <xslt:with-param name="fullURL" select="$referenceURI"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="starts-with($referenceURI,'https:')">
                <xsl:call-template name="remove-history-from-url">
                    <xslt:with-param name="fullURL" select="$referenceURI"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="starts-with($referenceURI,'urn:')">
                <xsl:value-of select="$referenceURI"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="fhirBaseUrl" select="substring-before($entryFullUrl,$currentResourceType)"/>
                <xsl:value-of select="$fhirBaseUrl"/><xsl:value-of select="$referenceURI"/>
                <!--
                <xsl:message>TODO: Add support for relative URLs</xsl:message>
                <xsl:message>entryFullUrl = <xsl:value-of select="$entryFullUrl"/></xsl:message>
                <xsl:message>referenceUri = <xsl:value-of select="$referenceURI"/></xsl:message>
                <xsl:message>currentResourceType = <xsl:value-of select="$currentResourceType"/></xsl:message>
                <xsl:message>resolved URL = <xsl:value-of select="$fhirBaseUrl"/><xsl:value-of select="$referenceURI"/></xsl:message>
                -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="remove-history-from-url">
        <xsl:param name="fullURL"></xsl:param>
        <xsl:choose>
            <xsl:when test="contains($fullURL,'/_history/')">
                <xsl:value-of select="substring-before($fullURL,'/_history/')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$fullURL"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="make-author">
        <xsl:param name="element-name">author</xsl:param>
        <xsl:param name="author-time">
            <xsl:call-template name="Date2TS">
                <xsl:with-param name="date" select="//fhir:Composition[1]/fhir:date/@value"/>
                <xsl:with-param name="includeTime" select="true()" />
            </xsl:call-template>
        </xsl:param>
        <xsl:element name="{$element-name}">
            <templateId root="2.16.840.1.113883.10.20.22.4.119" />
            <time value="{$author-time}"/>
            <assignedAuthor>
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
                <telecom value="{fhir:telecom/fhir:value/@value}">
                    <xsl:call-template name="telecomUse">
                        <xsl:with-param name="use" select="fhir:telecom/@use"/>
                    </xsl:call-template>
                </telecom>
                <assignedPerson>
                    <name>
                        <given><xsl:value-of select="fhir:name/fhir:given/@value"/></given>
                        <family><xsl:value-of select="fhir:name/fhir:family/@value"/></family>
                        <suffix><xsl:value-of select="fhir:name/fhir:suffix/@value"/></suffix>
                    </name>
                </assignedPerson>
            </assignedAuthor>
        </xsl:element>
    </xsl:template>
    
    
    <xsl:template name="make-performer">
        <xsl:param name="element-name">performer</xsl:param>
        <xsl:param name="type-code">PRF</xsl:param>
        <xsl:param name="performer-time"/>
        <xsl:param name="organization"/>
        <xsl:element name="{$element-name}">
            <xsl:attribute name="typeCode" select="$type-code"/>
            <xsl:if test="$performer-time">
                <time value="{performer-time}"/>
            </xsl:if>
            <assignedEntity>
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
                <telecom value="{fhir:telecom/fhir:value/@value}">
                    <xsl:call-template name="telecomUse">
                        <xsl:with-param name="use" select="fhir:telecom/@use"/>
                    </xsl:call-template>
                </telecom>
                <assignedPerson>
                    <name>
                        <given><xsl:value-of select="fhir:name/fhir:given/@value"/></given>
                        <family><xsl:value-of select="fhir:name/fhir:family/@value"/></family>
                        <suffix><xsl:value-of select="fhir:name/fhir:suffix/@value"/></suffix>
                    </name>
                </assignedPerson>
                <xsl:comment>TODO: Add represented organization</xsl:comment>
            </assignedEntity>
        </xsl:element>
    </xsl:template>
    
    
</xsl:stylesheet>