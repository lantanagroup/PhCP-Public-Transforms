<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://hl7.org/fhir" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:cda="urn:hl7-org:v3" xmlns:fhir="http://hl7.org/fhir" xmlns:sdtc="urn:hl7-org:sdtc"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:lcg="http://www.lantanagroup.com" version="2.0"
	xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="lcg xslt cda fhir xs xsi sdtc xhtml">

	<xsl:param name="template-profile-mapping-file">../template-profile-mapping.xml</xsl:param>
	<xsl:variable name="template-profile-mapping"
		select="document($template-profile-mapping-file)/mapping"/>
	<xsl:key name="referenced-acts"
		match="cda:*[not(cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.122')]"
		use="cda:id/@root"/>

	<xsl:template name="create-bundle-entry">
		<entry>
			<fullUrl value="urn:uuid:{@lcg:uuid}"/>
			<resource>
				<xsl:apply-templates select="." mode="#default"/>
			</resource>
		</entry>
	</xsl:template>


	<xsl:template match="cda:*[cda:templateId]" mode="bundle-entry" priority="-1">
		<!-- Suppress any unknown clinical statements -->
		<xsl:for-each select="cda:templateId">
			<xsl:message terminate="no">
				<xsl:text>No template match for </xsl:text>
				<xsl:value-of select="@root"/>
				<xsl:if test="@extension">
					<xsl:text>: </xsl:text>
					<xsl:value-of select="@extension"/>
				</xsl:if>
			</xsl:message>

			<xsl:comment><xsl:text>No template match for </xsl:text>
                    <xsl:value-of select="@root"/>
                    <xsl:if test="@extension">
                        <xsl:text>: </xsl:text><xsl:value-of select="@extension"/>
                    </xsl:if>
                </xsl:comment>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="add-meta">
		<xsl:variable name="profiles">
			<xsl:apply-templates select="cda:templateId" mode="template2profile"/>
		</xsl:variable>
		<xsl:if test="$profiles/fhir:profile">
			<meta>
				<xsl:apply-templates select="cda:templateId" mode="template2profile"/>
			</meta>
		</xsl:if>
	</xsl:template>

	<xsl:template match="cda:templateId" mode="template2profile">
		<xsl:variable name="templateURI">
			<xsl:text>urn:hl7ii:</xsl:text>
			<xsl:value-of select="@root"/>
			<xsl:if test="@extension">
				<xsl:text>:</xsl:text>
				<xsl:value-of select="@extension"/>
			</xsl:if>
		</xsl:variable>
		<xsl:for-each select="$template-profile-mapping/map[@templateURI = $templateURI]">
			<profile value="{@profileURI}"/>
		</xsl:for-each>
		<xsl:comment>CDA templateId: <xsl:value-of select="$templateURI"/></xsl:comment>
	</xsl:template>

	<xsl:function name="lcg:dateFromcdaTS" as="xs:string">
		<!-- Just get the date part, ignoring any time data -->
		<xsl:param name="cdaTS" as="xs:string"/>

		<xsl:variable name="date" as="xs:string">
			<xsl:choose>
				<xsl:when test="string-length($cdaTS) > 6">
					<xsl:value-of
						select="string-join((substring($cdaTS, 1, 4), substring($cdaTS, 5, 2), substring($cdaTS, 7, 2)), '-')"
					/>
				</xsl:when>
				<xsl:when test="string-length($cdaTS) > 4">
					<xsl:value-of
						select="string-join((substring($cdaTS, 1, 4), substring($cdaTS, 5, 2)), '-')"
					/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring($cdaTS, 1, 4)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$date"/>
	</xsl:function>

	<xsl:function name="lcg:cdaTS2date" as="xs:string">
		<!-- the FHIR specification allows ignoring seconds, but the FHIR XSD does not -->
		<!-- set seconds to 0 for simplicity -->
		<xsl:param name="cdaTS" as="xs:string"/>
		<xsl:variable name="date" as="xs:string" select="lcg:dateFromcdaTS($cdaTS)"/>
		<!--
		<xsl:message>cdaTS=<xsl:value-of select="$cdaTS"/></xsl:message>
		-->
		<xsl:choose>
			<xsl:when test="matches($cdaTS, '[-+]')">
				<xsl:variable name="time"
					select="concat(substring($cdaTS, 9, 2), ':', substring($cdaTS, 11, 2), ':00')"
					as="xs:string"/>
				<xsl:variable name="timezone" as="xs:string">
					<xsl:choose>
						<xsl:when test="contains($cdaTS, '-')">
							<xsl:sequence
								select="concat('-', substring(substring-after($cdaTS, '-'), 1, 2), ':', substring(substring-after($cdaTS, '-'), 3, 2))"
							/>
						</xsl:when>
						<xsl:when test="contains($cdaTS, '+')">
							<xsl:sequence
								select="concat('+', substring(substring-after($cdaTS, '+'), 1, 2), ':', substring(substring-after($cdaTS, '+'), 3, 2))"
							/>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:sequence select="concat($date, 'T', $time, $timezone)"/>
			</xsl:when>
			<xsl:when test="string-length($cdaTS) > 8">
				<xsl:variable name="time" as="xs:time">
					<xsl:sequence
						select="adjust-time-to-timezone(xs:time(concat(substring($cdaTS, 9, 2), ':', substring($cdaTS, 11, 2), ':00.000')))"
					/>
				</xsl:variable>
				<xsl:sequence
					select="concat($date, 'T', format-time($time, '[H01]:[m01]:[s01][Z]'))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$date"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:template name="TS2Date">
		<xsl:param name="ts"/>
		<xsl:param name="date-only" select="false()"/>
		<xsl:variable name="without-offset">
			<xsl:choose>
				<xsl:when test="contains($ts, '-')">
					<xsl:value-of select="substring-before(translate($ts, 'T', ''), '-')"/>
				</xsl:when>
				<xsl:when test="contains($ts, '+')">
					<xsl:value-of select="substring-before(translate($ts, 'T', ''), '+')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$ts"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="default-date-part">
			<xsl:choose>
				<xsl:when test="$date-only"/>
				<xsl:otherwise>01</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="default-time-part">
			<xsl:choose>
				<xsl:when test="$date-only"/>
				<xsl:otherwise>00</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="year" select="substring($without-offset, 1, 4)"/>
		<xsl:variable name="month">
			<xsl:choose>
				<xsl:when test="substring($without-offset, 5, 2)">
					<xsl:value-of select="substring($without-offset, 5, 2)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$default-date-part"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="day">
			<xsl:choose>
				<xsl:when test="substring($without-offset, 7, 2)">
					<xsl:value-of select="substring($without-offset, 7, 2)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$default-date-part"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="hour">
			<xsl:choose>
				<xsl:when test="substring($without-offset, 9, 2)">
					<xsl:value-of select="substring($without-offset, 9, 2)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$default-time-part"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="minute">
			<xsl:choose>
				<xsl:when test="substring($without-offset, 11, 2)">
					<xsl:value-of select="substring($without-offset, 11, 2)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$default-time-part"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="second">
			<xsl:choose>
				<xsl:when test="substring($without-offset, 13, 2)">
					<xsl:value-of select="substring($without-offset, 13, 2)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$default-time-part"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="offset-direction">
			<xsl:if test="contains($ts, '-')">-</xsl:if>
			<xsl:if test="contains($ts, '+')">+</xsl:if>
		</xsl:variable>
		<xsl:variable name="offset">
			<xsl:choose>
				<xsl:when test="contains($ts, '-')">
					<xsl:value-of select="translate(substring-after($ts, '-'), ':', '')"/>
				</xsl:when>
				<xsl:when test="contains($ts, '+')">
					<xsl:value-of select="translate(substring-after($ts, '+'), ':', '')"/>
				</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$year"/>
		<xsl:if test="$month != ''">
			<xsl:text>-</xsl:text>
			<xsl:value-of select="$month"/>
		</xsl:if>
		<xsl:if test="$day != ''">
			<xsl:text>-</xsl:text>
			<xsl:value-of select="$day"/>
		</xsl:if>

		<!-- add the time, timezone, 'Z', etc, only if full dateTime -->
		<xsl:if test="not($date-only)">
			<xsl:if test="$hour != ''">
				<xsl:text>T</xsl:text>
				<xsl:value-of select="$hour"/>
			</xsl:if>
			<xsl:if test="$minute != ''">
				<xsl:text>:</xsl:text>
				<xsl:value-of select="$minute"/>
			</xsl:if>
			<xsl:if test="$second != ''">
				<xsl:text>:</xsl:text>
				<xsl:value-of select="$second"/>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="string-length($offset) = 2">
					<xsl:variable name="offset-hour" select="substring($offset, 1, 2)"/>
					<xsl:value-of select="concat($offset-direction, $offset-hour, ':00')"/>
				</xsl:when>
				<xsl:when test="string-length($offset) = 4">
					<xsl:variable name="offset-hour" select="substring($offset, 1, 2)"/>
					<xsl:variable name="offset-minute" select="substring($offset, 3, 2)"/>
					<xsl:value-of
						select="concat($offset-direction, $offset-hour, ':', $offset-minute)"/>
				</xsl:when>
				<xsl:otherwise>Z</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>


	<xsl:template name="convertOID">
		<xsl:param name="oid"/>
		<xsl:variable name="mapping" select="document('../oid-uri-mapping.xml')/mapping"/>
		<xsl:choose>
			<xsl:when test="$mapping/map[@oid = $oid]">
				<xsl:value-of select="$mapping/map[@oid = $oid][1]/@uri"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="contains($oid, '.')">urn:oid:</xsl:when>
					<xsl:when test="contains($oid, '-')">urn:uuid:</xsl:when>
				</xsl:choose>
				<xsl:value-of select="$oid"/>
				<xsl:message>Warning: Unmapped OID - <xsl:value-of select="$oid"/></xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- data types -->
	<xsl:template match="cda:effectiveTime" mode="instant">
		<xsl:param name="elementName">date</xsl:param>
		<xsl:choose>
			<xsl:when test="./@value and not(cda:low) and not(cda:center)">
				<xsl:element name="{$elementName}">
					<xsl:attribute name="value">
						<xsl:value-of select="lcg:cdaTS2date(./@value)"/>
					</xsl:attribute>
				</xsl:element>
			</xsl:when>
			<xsl:when test="cda:low/@value and not(@value) and not(cda:center)">
				<xsl:element name="{$elementName}">
					<xsl:attribute name="value">
						<xsl:value-of select="lcg:cdaTS2date(cda:low/@value)"/>
					</xsl:attribute>
				</xsl:element>
			</xsl:when>
			<xsl:when test="cda:center/@value and not(@value) and not(cda:low)">
				<xsl:element name="{$elementName}">
					<xsl:attribute name="value">
						<xsl:value-of select="lcg:cdaTS2date(cda:center/@value)"/>
					</xsl:attribute>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="cda:name" mode="display">
		<xsl:if test="cda:prefix">
			<xsl:value-of select="cda:prefix"/>
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="cda:family and cda:given">
				<xsl:for-each select="cda:given">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
				<xsl:value-of select="cda:family/text()"/>
			</xsl:when>
			<xsl:when test="cda:given and not(cda:family)">
				<xsl:value-of select="cda:given"/>
			</xsl:when>
			<xsl:when test="cda:family and not(cda:given)">
				<xsl:value-of select="cda:family/text()"/>
			</xsl:when>
			<xsl:otherwise>NAME NOT GIVEN</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="cda:suffix">
			<xsl:text>, </xsl:text>
			<xsl:value-of select="cda:suffix"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="cda:name[not(@nullFlavor)]">
		<xsl:variable name="name-string">
			<xsl:for-each select="text() | cda:*">
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="use">
			<xsl:choose>
				<xsl:when test="@use = 'L'">usual</xsl:when>
				<xsl:when test="@use = 'P'">nickname</xsl:when>
				<xsl:when test="descendant::*/@qualifier = 'BR'">maiden</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string-length(normalize-space($name-string)) > 0">
			<name>
				<xsl:if test="string-length($use) > 0">
					<use value="{$use}"/>
				</xsl:if>
				<xsl:if test="string-length(normalize-space(.)) > 0">
					<text>
						<xsl:attribute name="value">
							<xsl:value-of select="normalize-space(cda:family)"/>
							<xsl:text>,</xsl:text>
							<xsl:for-each select="cda:suffix">
								<xsl:text> </xsl:text>
								<xsl:value-of select="normalize-space(.)"/>
								<xsl-text>,</xsl-text>
							</xsl:for-each>
							<xsl:for-each select="cda:prefix">
								<xsl:text> </xsl:text>
								<xsl:value-of select="normalize-space(.)"/>
							</xsl:for-each>
							<xsl:for-each select="cda:given">
								<xsl:text> </xsl:text>
								<xsl:value-of select="normalize-space(.)"/>
							</xsl:for-each>
							<xsl:if test="string-length($use) > 0">
								<text> (</text>
								<xsl:value-of select="$use"/>
								<text> name)</text>
							</xsl:if>
						</xsl:attribute>
					</text>
				</xsl:if>
				<xsl:for-each select="cda:family">
					<xsl:if test="string-length(.) &gt; 0">
						<family value="{.}"/>
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each select="cda:given">
					<xsl:if test="string-length(.) &gt; 0">
						<given value="{.}"/>
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each select="cda:prefix">
					<xsl:if test="string-length(.) &gt; 0">
						<prefix value="{.}"/>
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each select="cda:suffix">
					<xsl:if test="string-length(.) &gt; 0">
						<suffix value="{.}"/>
					</xsl:if>
				</xsl:for-each>
			</name>
		</xsl:if>
	</xsl:template>

	<xsl:template match="cda:telecom">
		<xsl:variable name="type">
			<xsl:choose>
				<xsl:when test="contains(@value, ':')">
					<xsl:value-of select="substring-before(@value, ':')"/>
				</xsl:when>
				<xsl:otherwise>tel</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="value">
			<xsl:choose>
				<xsl:when test="contains(@value, ':')">
					<xsl:value-of select="substring-after(@value, ':')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@value"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="@nullFlavor">
				<xsl:comment>Omitting null telecom</xsl:comment>
				<!-- Removing the following, in FHIR just leave out nulled elements like this -->
				<!--
				<telecom>
					<system value="phone"/>
					<value>
						<xsl:attribute name="value">Unknown</xsl:attribute>
					</value>
				</telecom>
				-->
			</xsl:when>
			<xsl:otherwise>
				<telecom>
					<system>
						<xsl:attribute name="value">
							<xsl:choose>
								<xsl:when test="$type = 'tel'">phone</xsl:when>
								<xsl:when test="$type = 'mailto'">email</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$type"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
					</system>
					<value>
						<xsl:choose>
							<xsl:when test="@value">
								<xsl:attribute name="value">
									<xsl:value-of select="$value"/>
								</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<!-- TODO: Believe this extension needs to appear 1st in the datatype resource -->
								<!-- this appears to cause problems with the FHIR->JSON converter -->
								<!--<extension url="http://hl7.org/fhir/v3/NullFlavor"> 
									<valueCode value="UNK"/>
								</extension>-->
								<xsl:attribute name="value">Unknown</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
					</value>
					<xsl:if test="@use">
						<use>
							<xsl:attribute name="value">
								<xsl:choose>
									<xsl:when test="@use = 'H' or @use = 'HP' or @use = 'HV'"
										>home</xsl:when>
									<xsl:when test="@use = 'WP' or @use = 'DIR' or @use = 'PUB'"
										>work</xsl:when>
									<xsl:when test="@use = 'MC'">mobile</xsl:when>
									<!-- default to work -->
									<xsl:otherwise>work</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
						</use>
					</xsl:if>
					<xsl:apply-templates select="cda:useablePeriod"/>
				</telecom>
			</xsl:otherwise>

		</xsl:choose>
	</xsl:template>


	<xsl:template match="cda:useablePeriod[@value or cda:low/@value or cda:high/@value]">
		<xsl:choose>
			<xsl:when test="@value">
				<period>
					<start value="{lcg:cdaTS2date(@value)}"/>
					<end value="{lcg:cdaTS2date(@value)}"/>
				</period>
			</xsl:when>
			<xsl:when test="cda:low/@value or cda:high/@value">
				<period>
					<xsl:if test="cda:low/@value">
						<start value="{lcg:cdaTS2date(cda:low/@value)}"/>
					</xsl:if>
					<xsl:if test="cda:high/@value">
						<end value="{lcg:cdaTS2date(cda:high/@value)}"/>
					</xsl:if>
				</period>
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment>Unable to map usablePeriod to a FHIR period</xsl:comment>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="cda:addr[not(@nullFlavor)]">
		<xsl:variable name="addr-string">
			<xsl:for-each select="text() | cda:*">
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:if test="string-length($addr-string) &gt; 0">
			<address>
				<xsl:if test="@use">
					<use>
						<xsl:attribute name="value">
							<xsl:choose>
								<xsl:when test="@use = 'H' or @use = 'HP' or @use = 'HV'"
									>home</xsl:when>
								<xsl:when test="@use = 'WP' or @use = 'DIR' or @use = 'PUB'"
									>work</xsl:when>
								<!-- default to work -->
								<xsl:otherwise>work</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
					</use>
				</xsl:if>
				<xsl:for-each select="cda:streetAddressLine[not(@nullFlavor)]">
					<xsl:if test="string-length(.) &gt; 0">
						<line value="{normalize-space(.)}"/>
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each select="cda:city[not(@nullFlavor)]">
					<xsl:if test="string-length(.) &gt; 0">
						<city value="{normalize-space(.)}"/>
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each select="cda:state[not(@nullFlavor)]">
					<xsl:if test="string-length(.) &gt; 0">
						<state value="{normalize-space(.)}"/>
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each select="cda:postalCode[not(@nullFlavor)]">
					<xsl:if test="string-length(.) &gt; 0">
						<postalCode value="{normalize-space(.)}"/>
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each select="cda:country[not(@nullFlavor)]">
					<xsl:if test="string-length(.) &gt; 0">
						<country value="{normalize-space(.)}"/>
					</xsl:if>
				</xsl:for-each>
				<xsl:apply-templates select="cda:useablePeriod"/>
			</address>
		</xsl:if>
	</xsl:template>

	<xsl:template match="cda:id | cda:setId">
		<xsl:param name="elementName">identifier</xsl:param>
		<xsl:variable name="mapping" select="document('../oid-uri-mapping.xml')/mapping"/>
		<xsl:variable name="oid" select="@root"/>
		<xsl:variable name="root-uri">
			<xsl:choose>
				<xsl:when test="$mapping/map[@oid = $oid]">
					<xsl:value-of select="$mapping/map[@oid = $oid][1]/@uri"/>
				</xsl:when>
				<xsl:when test="contains(@root, '.')">
					<xsl:text>urn:oid:</xsl:text><xsl:value-of select="@root"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>urn:uuid:</xsl:text><xsl:value-of select="@root"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="@nullFlavor">
				<!-- TODO: ignore for now, add better handling later -->
			</xsl:when>
			<xsl:when test="@root and @extension">
				<xsl:element name="{$elementName}">
					<system value="{$root-uri}"/>
					<value value="{@extension}"/>
				</xsl:element>
			</xsl:when>
			<xsl:when test="@root and not(@extension)">
				<xsl:element name="{$elementName}">
					<system value="urn:ietf:rfc:3986"/>
					<value value="{$root-uri}"/>
				</xsl:element>
			</xsl:when>
		</xsl:choose>

	</xsl:template>

	<!-- cda:raceCode, sdtc:raceCode are used in mode extension-raceCode, which calls this template -->
	<xsl:template
		match="
			cda:code | cda:confidentialityCode | cda:maritalStatusCode | cda:routeCode
			| cda:raceCode | sdtc:raceCode | cda:ethnicGroupCode | cda:religiousAffiliationCode | cda:targetSiteCode">
		<xsl:param name="elementName" select="'codeableConcept'"/>
		<xsl:param name="includeCoding" select="true()"/>
		<xsl:call-template name="newCreateCodableConcept">
			<xsl:with-param name="elementName" select="$elementName"/>
			<xsl:with-param name="includeCoding" select="$includeCoding"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="cda:birthTime">
		<xsl:param name="element-name">birthDate</xsl:param>
		<xsl:if test="not(@nullFlavor)">
			<xsl:element name="{$element-name}">
				<xsl:attribute name="value" select="lcg:dateFromcdaTS(@value)"/>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template match="cda:administrativeGenderCode">
		<xsl:variable name="cda-gender" select="@code"/>
		<gender>
			<xsl:choose>
				<xsl:when test="$cda-gender = 'M'">
					<xsl:attribute name="value">male</xsl:attribute>
				</xsl:when>
				<xsl:when test="$cda-gender = 'F'">
					<xsl:attribute name="value">female</xsl:attribute>
				</xsl:when>
				<xsl:when test="$cda-gender = 'UN'">
					<xsl:attribute name="value">other</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="value">unknown</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
		</gender>
		<!--
		<xsl:variable name="gendercode" select="@code"/>
		<xsl:variable name="display">
			<xsl:choose>
				<xsl:when test="@displayName">
					<xsl:value-of select="normalize-space(@displayName)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="$gendercode = 'F' or $gendercode = 'Female'"
							>Female</xsl:when>
						<xsl:when test="$gendercode = 'M' or $gendercode = 'Male'">Male</xsl:when>
						<xsl:when test="$gendercode = 'UN' or $gendercode = 'Undifferentiated'"
							>Undifferentiated</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$gendercode"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<gender>
			<xsl:attribute name="value">
				<xsl:choose>
					<xsl:when test="$gendercode = 'F' or $gendercode = 'Female'">F</xsl:when>
					<xsl:when test="$gendercode = 'M' or $gendercode = 'Male'">M</xsl:when>
					<xsl:when test="$gendercode = 'UN' or $gendercode = 'Undifferentiated'"
						>UN</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$gendercode"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</gender>
		-->
	</xsl:template>



	<xsl:template match="cda:interpretationCode">
		<xsl:call-template name="newCreateCodableConcept">
			<xsl:with-param name="elementName" select="'interpretation'"/>
			<xsl:with-param name="codeSystem" select="'urn:oid:2.16.840.1.113883.1.11.78'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="cda:value[@xsi:type = 'PQ']">
		<xsl:param name="elementName" select="'valueQuantity'"/>
		<xsl:element name="{$elementName}">
			<xsl:if test="@value">
				<value>
					<xsl:attribute name="value">
						<xsl:value-of select="@value"/>
					</xsl:attribute>
				</value>
			</xsl:if>
			<xsl:if test="@unit">
				<unit>
					<xsl:attribute name="value">
						<xsl:value-of select="@unit"/>
					</xsl:attribute>
				</unit>
			</xsl:if>
		</xsl:element>
	</xsl:template>



	<xsl:template match="cda:value[@xsi:type = 'CD' or @xsi:type = 'CE']">

		<xsl:param name="elementName" select="'valueCodeableConcept'"/>
		<xsl:param name="includeCoding" select="true()"/>
		<xsl:call-template name="newCreateCodableConcept">
			<xsl:with-param name="elementName" select="$elementName"/>
			<xsl:with-param name="includeCoding" select="$includeCoding"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="newCreateCodableConcept">
		<xsl:param name="elementName"/>
		<xsl:param name="includeCoding" select="true()"/>
		<xsl:param name="codeSystem"/>
		<xsl:variable name="originalTextReference">
			<xsl:value-of select="substring(cda:originalText/cda:reference/@value, 2)"/>
		</xsl:variable>
		<xsl:variable name="originalText">
			<xsl:choose>
				<xsl:when test="cda:originalText/cda:reference">
					<xsl:choose>
						<xsl:when test="//*[@ID = $originalTextReference]/text()">
							<xsl:value-of select="//*[@ID = $originalTextReference]/text()"/>
						</xsl:when>
						<xsl:when test="//*[@ID = $originalTextReference]/../text()">
							<xsl:value-of
								select="//*[@ID = $originalTextReference]/following-sibling::text()"
							/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="cda:originalText">
					<xsl:value-of select="cda:originalText"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="isValue" select="false()"/>
		<xsl:variable name="display">
			<xsl:choose>
				<xsl:when test="@displayName">
					<xsl:value-of select="@displayName"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$originalText"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="nullFlavor">
			<xsl:choose>
				<xsl:when test="not(@nullFlavor) and not(@code) and not(@codeSystem)">NI</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@nullFlavor"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="content">
			<xsl:call-template name="createCodableConceptContent">
				<xsl:with-param name="codeSystem" select="@codeSystem"/>
				<xsl:with-param name="code" select="@code"/>
				<xsl:with-param name="displayName" select="$display"/>
				<xsl:with-param name="isValue" select="$isValue"/>
				<xsl:with-param name="nullFlavor" select="$nullFlavor"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="translations">
			<xsl:for-each select="cda:translation">
				<xsl:variable name="this-display">
					<xsl:choose>
						<xsl:when test="@displayName">
							<xsl:value-of select="normalize-space(@displayName)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(cda:originalText)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="nullFlavor">
					<xsl:choose>
						<xsl:when test="not(@nullFlavor) and not(@code) and not(@codeSystem)"
							>NI</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@nullFlavor"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="this-translation">
					<xsl:call-template name="createCodableConceptContent">
						<xsl:with-param name="codeSystem" select="@codeSystem"/>
						<xsl:with-param name="code" select="@code"/>
						<xsl:with-param name="displayName" select="$this-display"/>
						<xsl:with-param name="isValue" select="$isValue"/>
						<xsl:with-param name="nullFlavor" select="$nullFlavor"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>

					<xsl:when test="$includeCoding = true()">
						<coding>
							<xsl:copy-of select="$this-translation"/>
						</coding>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="$this-translation"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>

		<xsl:element name="{$elementName}">
			<xsl:choose>
				<xsl:when test="$includeCoding = true()">
					<coding>
						<xsl:copy-of select="$content"/>
					</coding>
					<xsl:copy-of select="$translations"/>
					<xsl:if
						test="string-length($originalText) &gt; 0 and normalize-space($originalText) != ''">
						<xsl:element name="text">
							<xsl:attribute name="value">
								<xsl:value-of select="normalize-space($originalText)"/>
							</xsl:attribute>
						</xsl:element>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="$content"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>

	</xsl:template>





	<xsl:template match="cda:value[@xsi:type = 'ST']">
		<xsl:param name="elementName" select="'valueString'"/>
		<xsl:element name="{$elementName}">
			<xsl:attribute name="value">
				<xsl:value-of select="."/>
			</xsl:attribute>
		</xsl:element>
	</xsl:template>


	<xsl:template match="cda:value[@xsi:type = 'INT']">
		<xsl:param name="elementName" select="'valueInteger'"/>
		<xsl:element name="{$elementName}">
			<xsl:attribute name="value">
				<xsl:value-of select="@value"/>
			</xsl:attribute>
		</xsl:element>
	</xsl:template>

	<!-- generic -->
	<!-- This does not support translation elements. Try newCreateCodableConcept instead -->
	<!-- Consider this deprecated for CD and CE datatypes, eventually refactor everything to use newCreateCodableConcept or a version of it that is applicable for II datatypes, then remove createCodableConcept -->
	<!--
	<xsl:template name="createCodableConcept">
		<xsl:param name="source-element"/>
		<xsl:param name="codeSystem"/>
		<xsl:param name="code"/>
		<xsl:param name="displayName"/>
		<xsl:param name="originalText"/>
		<xsl:param name="label"/>
		<xsl:param name="elementName"/>
		<xsl:param name="includeCoding" select="true()"/>
		<xsl:param name="isValue" select="false()"/>
		<xsl:variable name="content">
			<xsl:call-template name="createCodableConceptContent">
				<xsl:with-param name="codeSystem" select="$codeSystem"/>
				<xsl:with-param name="code" select="$code"/>
				<xsl:with-param name="displayName" select="$displayName"/>
				<xsl:with-param name="label" select="$label"/>
				<xsl:with-param name="isValue" select="$isValue"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="$source-element">
			<xsl:comment><xsl:value-of select="local-name($source-element)"/></xsl:comment>
			<xsl:comment><xsl:value-of select="$source-element/@nullFlavor"/></xsl:comment>
		</xsl:if>

		<xsl:element name="{$elementName}">
			<xsl:choose>
				<xsl:when test="$includeCoding">
					<coding>
						<xsl:copy-of select="$content"/>
					</coding>
					<xsl:if test="string-length($originalText) &gt; 0">
						<xsl:element name="text">
							<xsl:attribute name="value">
								<xsl:value-of select="$originalText"/>
							</xsl:attribute>
						</xsl:element>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="$content"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	-->

	<xsl:template name="createCodableConceptContent">
		<xsl:param name="codeSystem"/>
		<xsl:param name="code"/>
		<xsl:param name="displayName"/>
		<!--
		<xsl:param name="label"/>
		-->
		<xsl:param name="isValue" select="false()"/>
		<xsl:param name="nullFlavor"/>
		<xsl:variable name="codeOrValueElementName">
			<xsl:choose>
				<xsl:when test="not($isValue)">code</xsl:when>
				<xsl:otherwise>value</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$codeSystem and $nullFlavor = ''">
			<system>
				<xsl:attribute name="value">
					<xsl:call-template name="convertOID">
						<xsl:with-param name="oid" select="$codeSystem"/>
					</xsl:call-template>
				</xsl:attribute>
			</system>
		</xsl:if>
		<xsl:if test="$code">
			<xsl:element name="{$codeOrValueElementName}">
				<xsl:attribute name="value">
					<xsl:value-of select="$code"/>
				</xsl:attribute>
			</xsl:element>
		</xsl:if>

		<xsl:if test="not($nullFlavor = '') and not($code)">
			<system value="http://hl7.org/fhir/v3/NullFlavor"/>
			<xsl:element name="{$codeOrValueElementName}">
				<xsl:attribute name="value">
					<xsl:value-of select="$nullFlavor"/>
				</xsl:attribute>
			</xsl:element>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="$displayName and not($displayName = '') and $nullFlavor = ''">
				<display>
					<xsl:attribute name="value">
						<xsl:value-of select="$displayName"/>
					</xsl:attribute>
				</display>
			</xsl:when>
			<xsl:when test="not($nullFlavor = '')">
				<display>
					<xsl:attribute name="value">
						<xsl:choose>
							<xsl:when test="$nullFlavor = 'ASKU'">Asked but unknown</xsl:when>
							<xsl:when test="$nullFlavor = 'MSK'">Masked</xsl:when>
							<xsl:when test="$nullFlavor = 'NINF'">Negative infinity</xsl:when>
							<xsl:when test="$nullFlavor = 'NI'">No Information</xsl:when>
							<xsl:when test="$nullFlavor = 'NA'">Not applicable</xsl:when>
							<xsl:when test="$nullFlavor = 'NASK'">Not asked</xsl:when>
							<xsl:when test="$nullFlavor = 'OTH'">Other</xsl:when>
							<xsl:when test="$nullFlavor = 'PINF'">Positive</xsl:when>
							<xsl:when test="$nullFlavor = 'QS'">Sufficient</xsl:when>
							<xsl:when test="$nullFlavor = 'NAV'">Temporarily</xsl:when>
							<xsl:when test="$nullFlavor = 'TRC'">Trace</xsl:when>
							<xsl:when test="$nullFlavor = 'UNC'">Un-encoded</xsl:when>
							<xsl:when test="$nullFlavor = 'UNK'">Unknown</xsl:when>
							<xsl:otherwise>Invalid nullFlavor</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</display>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="cda:effectiveTime[@value or cda:low/@value or cda:high/@value]"
		mode="period">
		<xsl:param name="element-name">period</xsl:param>
		<xsl:element name="{$element-name}">
			<xsl:call-template name="effectiveTimeInner"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="cda:effectiveTime" mode="timingPeriod">
		<timingPeriod>
			<xsl:call-template name="effectiveTimeInner"/>
		</timingPeriod>
	</xsl:template>

	<xsl:template match="cda:effectiveTime" mode="whenGiven">
		<whenGiven>
			<xsl:call-template name="effectiveTimeInner"/>
		</whenGiven>
	</xsl:template>

	<xsl:template match="cda:effectiveTime" mode="event">
		<event>
			<xsl:call-template name="effectiveTimeInner"/>
		</event>
	</xsl:template>

	<xsl:template match="cda:effectiveTime[@operator = 'A']">
		<repeat>
			<frequency value="1"/>
			<xsl:choose>
				<xsl:when
					test="cda:period/@value and not(cda:period/cda:low) and not(cda:period/cda:high)">
					<duration>
						<xsl:attribute name="value">
							<xsl:value-of select="normalize-space(cda:period/@value)"/>
						</xsl:attribute>
					</duration>
				</xsl:when>
				<xsl:when test="not(cda:period/@value) and cda:period/cda:low/@value">
					<duration>
						<xsl:attribute name="value">
							<xsl:value-of select="cda:period/cda:low/@value"/>
						</xsl:attribute>
					</duration>
				</xsl:when>
				<xsl:when
					test="not(cda:period/@value) and not(cda:period/cda:low/@value) and cda:period/cda:high/@value">
					<duration>
						<xsl:attribute name="value">
							<xsl:value-of select="cda:period/cda:high/@value"/>
						</xsl:attribute>
					</duration>
				</xsl:when>
			</xsl:choose>

			<xsl:choose>
				<xsl:when
					test="cda:period/@unit and not(cda:period/cda:low) and not(cda:period/cda:high)">
					<units>
						<xsl:attribute name="value">
							<xsl:value-of select="cda:period/@unit"/>
						</xsl:attribute>
					</units>
				</xsl:when>
				<xsl:when test="not(cda:period/@unit) and cda:period/cda:low/@unit">
					<units>
						<xsl:attribute name="value">
							<xsl:value-of select="cda:period/cda:low/@unit"/>
						</xsl:attribute>
					</units>
				</xsl:when>
				<xsl:when
					test="not(cda:period/@unit) and not(cda:period/cda:low/@unit) and cda:period/cda:high/@unit">
					<units>
						<xsl:attribute name="value">
							<xsl:value-of select="cda:period/cda:high/@unit"/>
						</xsl:attribute>
					</units>
				</xsl:when>
			</xsl:choose>
		</repeat>
	</xsl:template>

	<xsl:template name="effectiveTimeInner">

		<xsl:if test="cda:low[@value]">
			<start value="{lcg:cdaTS2date(cda:low/@value)}"/>
		</xsl:if>
		<xsl:if test="cda:high[@value]">
			<end value="{lcg:cdaTS2date(cda:high/@value)}"/>
		</xsl:if>
		<xsl:if test="@value and not(cda:low/@value)">
			<start value="{lcg:cdaTS2date(@value)}"/>
			<end value="{lcg:cdaTS2date(@value)}"/>
		</xsl:if>
		<xsl:if test="cda:center/@value and not(cda:width/@value)">
			<start value="{lcg:cdaTS2date(cda:center/@value)}"/>
			<end value="{lcg:cdaTS2date(cda:center/@value)}"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="II2Identifier">
		<xsl:param name="this"/>

		<!-- if an II with @root only, then system is IETF, and value is the URI
			if @extension, then system is the @root and value is the @extension
			-->
		<xsl:choose>
			<xsl:when test="$this/@extension">
				<system>
					<xsl:attribute name="value">urn:oid:<xsl:value-of select="$this/@root"
						/></xsl:attribute>
				</system>
				<value>
					<xsl:attribute name="value">
						<xsl:value-of select="$this/@extension"/>
					</xsl:attribute>
				</value>
			</xsl:when>
			<xsl:otherwise>
				<system value="urn:ietf:rfc:3986"/>
				<value>
					<xsl:attribute name="value">urn:oid:<xsl:value-of select="$this/@root"
						/></xsl:attribute>
				</value>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!--
        Helper templates
        -->
	<xsl:template match="cda:effectiveTime" mode="extension-effectiveTime">
		<extension url="http://lantana.com/fhir/Profile/organizer#effectiveTime">
			<valuePeriod>
				<xsl:if test="cda:low">
					<start>
						<xsl:attribute name="value">
							<xsl:value-of select="lcg:cdaTS2date(cda:low/@value)"/>
						</xsl:attribute>
					</start>
				</xsl:if>
				<xsl:if test="cda:high">
					<end>
						<xsl:attribute name="value">
							<xsl:value-of select="lcg:cdaTS2date(cda:high/@value)"/>
						</xsl:attribute>
					</end>
				</xsl:if>
			</valuePeriod>
		</extension>
	</xsl:template>

	<xsl:template match="cda:effectiveTime" mode="applies">
		<xsl:choose>
			<xsl:when test="@value and @value != ''">
				<appliesDateTime>
					<xsl:attribute name="value">
						<xsl:value-of select="lcg:cdaTS2date(@value)"/>
					</xsl:attribute>
				</appliesDateTime>
			</xsl:when>
			<xsl:when
				test="(cda:low/@value and not(cda:high/@value)) or cda:low/@value = cda:high/@value">
				<appliesDateTime>
					<xsl:attribute name="value">
						<xsl:value-of select="lcg:cdaTS2date(cda:low/@value)"/>
					</xsl:attribute>
				</appliesDateTime>
			</xsl:when>
			<xsl:otherwise>
				<appliesPeriod>
					<xsl:if test="cda:low">
						<start>
							<xsl:attribute name="value">
								<xsl:value-of select="lcg:cdaTS2date(cda:low/@value)"/>
							</xsl:attribute>
						</start>
					</xsl:if>
					<xsl:if test="cda:high">
						<end>
							<xsl:attribute name="value">
								<xsl:value-of select="lcg:cdaTS2date(cda:high/@value)"/>
							</xsl:attribute>
						</end>
					</xsl:if>
				</appliesPeriod>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="cda:effectiveTime" mode="appliesPeriod">
		<appliesPeriod>
			<xsl:choose>
				<xsl:when test="@value and @value != ''">
					<start>
						<xsl:attribute name="value">
							<xsl:value-of select="lcg:cdaTS2date(@value)"/>
						</xsl:attribute>
					</start>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="cda:low">
						<start>
							<xsl:attribute name="value">
								<xsl:value-of select="lcg:cdaTS2date(cda:low/@value)"/>
							</xsl:attribute>
						</start>
					</xsl:if>
					<xsl:if test="cda:high">
						<end>
							<xsl:attribute name="value">
								<xsl:value-of select="lcg:cdaTS2date(cda:high/@value)"/>
							</xsl:attribute>
						</end>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</appliesPeriod>
	</xsl:template>

	<xsl:template name="subject-reference">
		<xsl:param name="element-name">subject</xsl:param>
		<!-- TODO: handle multiple subjects (record as a group where allowed) -->
		<xsl:element name="{$element-name}">
			<xsl:choose>
				<xsl:when test="cda:subject">
					<reference value="urn:uuid:{cda:subject/@lcg:uuid}"/>
				</xsl:when>
				<xsl:when test="ancestor::cda:section/cda:subject">
					<reference value="urn:uuid:{ancestor::cda:section[1]/cda:subject/@lcg:uuid}"/>
				</xsl:when>
				<xsl:otherwise>
					<reference value="urn:uuid:{/cda:ClinicalDocument/cda:recordTarget/@lcg:uuid}"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<xsl:template name="author-reference">
		<xsl:param name="element-name">author</xsl:param>

		<!-- TODO: handle multiple authors. May not be legal for all resources.  -->
		<xsl:element name="{$element-name}">
			<xsl:choose>
				<xsl:when test="cda:author">
					<!-- TODO: test to see author.id is the same as an ancestor author, if so use that URN -->
					<reference value="urn:uuid:{cda:author/@lcg:uuid}"/>
				</xsl:when>
				<xsl:when test="ancestor::cda:section[1]/cda:author">
					<reference value="urn:uuid:{ancestor::cda:section/cda:author/@lcg:uuid}"/>
				</xsl:when>
				<xsl:otherwise>
					<reference value="urn:uuid:{/cda:ClinicalDocument/cda:author/@lcg:uuid}"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<xsl:template match="cda:act[cda:templateId[@root = '2.16.840.1.113883.10.20.22.4.122']]"
		mode="reference">
		<xsl:param name="sectionEntry">false</xsl:param>
		<xsl:param name="listEntry">false</xsl:param>
		<xsl:variable name="reference-id" select="cda:id"/>
		<xsl:for-each select="key('referenced-acts', $reference-id/@root)">
			<xsl:choose>
				<xsl:when test="$reference-id/@extension = cda:id/@extension">
					<xsl:choose>
						<xsl:when test="$sectionEntry = 'true'">
							<entry>
								<reference value="urn:uuid:{@lcg:uuid}"/>
							</entry>
						</xsl:when>
						<xsl:when test="$listEntry = 'true'">
							<entry>
								<item>
									<reference value="urn:uuid:{@lcg:uuid}"/>
								</item>
							</entry>
						</xsl:when>
						<xsl:otherwise>
							<reference value="urn:uuid:{@lcg:uuid}"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$reference-id[not(@extension)] and cda:id[not(@extension)]">
					<xsl:choose>
						<xsl:when test="$sectionEntry = 'true'">
							<entry>
								<reference value="urn:uuid:{@lcg:uuid}"/>
							</entry>
						</xsl:when>
						<xsl:when test="$listEntry = 'true'">
							<entry>
								<item>
									<reference value="urn:uuid:{@lcg:uuid}"/>
								</item>
							</entry>
						</xsl:when>
						<xsl:otherwise>
							<reference value="urn:uuid:{@lcg:uuid}"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="cda:*" mode="reference" priority="-1">
		<xsl:param name="sectionEntry">false</xsl:param>
		<xsl:param name="listEntry">false</xsl:param>
		<xsl:choose>
			<xsl:when test="$sectionEntry = 'true'">
				<entry>
					<reference value="urn:uuid:{@lcg:uuid}"/>
				</entry>
			</xsl:when>
			<xsl:when test="$listEntry = 'true'">
				<entry>
					<item>
						<reference value="urn:uuid:{@lcg:uuid}"/>
					</item>
				</entry>
			</xsl:when>
			<xsl:otherwise>
				<reference value="urn:uuid:{@lcg:uuid}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
