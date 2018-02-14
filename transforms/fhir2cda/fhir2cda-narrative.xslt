<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns="urn:hl7-org:v3" 
	xmlns:fhir="http://hl7.org/fhir" 
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:sdtc="urn:hl7-org:sdtc" 
	exclude-result-prefixes="xsl fhir xhtml xsi">
	
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	
	<xsl:strip-space elements="*"/>
	
	
	<xsl:template match="fhir:text" mode="narrative"><xsl:apply-templates mode="narrative"/></xsl:template>
	
	<xsl:template match="xhtml:div"  mode="narrative"><xsl:apply-templates mode="narrative"/></xsl:template>
	
	
	<xsl:template match="xhtml:p"  mode="narrative">
		<paragraph><xsl:apply-templates select="@*" mode="narrative"/><xsl:apply-templates mode="narrative"/></paragraph>
	 </xsl:template>
	
	<xsl:template match="xhtml:ol"  mode="narrative">
		<list listType="ordered"><xsl:apply-templates select="@*" mode="narrative"/><xsl:apply-templates mode="narrative"/></list>
	</xsl:template>
	
	<xsl:template match="xhtml:ul"  mode="narrative">
		<list listType="unordered"><xsl:apply-templates select="@*" mode="narrative"/><xsl:apply-templates mode="narrative"/></list>
	</xsl:template>
	
	<xsl:template match="xhtml:li"  mode="narrative">
		<item><xsl:apply-templates select="@*" mode="narrative"/><xsl:apply-templates mode="narrative"/></item>
	</xsl:template>
	
	<xsl:template match="xhtml:span"  mode="narrative">
		<content><xsl:apply-templates select="@*" mode="narrative"/><xsl:apply-templates mode="narrative"/></content>
	</xsl:template>

	<xsl:template match="@lang"  mode="narrative">
		<!-- not a valid attribute -->
	</xsl:template>
	
	<xsl:template match="xhtml:a"  mode="narrative">
		<linkHtml href="{@href}"><xsl:apply-templates mode="narrative"/></linkHtml>
	</xsl:template>
	
	<xsl:template match="xhtml:br"  mode="narrative">
		<br/>
	</xsl:template>
	
	<xsl:template match="xhtml:table" mode="narrative">
		<xsl:choose>
			<xsl:when test="xhtml:tbody">
				<xsl:element name="{local-name()}"><xsl:apply-templates select="@*" mode="table-atts"/><xsl:apply-templates mode="narrative"/></xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="{local-name()}">
					<tbody>
						<xsl:apply-templates select="@*" mode="table-atts"/><xsl:apply-templates mode="narrative"/>
					</tbody>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="
			xhtml:caption | 
			xhtml:col | 
			xhtml:colgroup | 
			xhtml:thead | 
			xhtml:tfoot | 
			xhtml:tbody | 
			xhtml:tr | 
			xhtml:th | 
			xhtml:td" mode="narrative">
		<xsl:element name="{local-name()}"><xsl:apply-templates select="@*" mode="table-atts"/><xsl:apply-templates mode="narrative"/></xsl:element>
	</xsl:template>

	<xsl:template match="@class" mode="narrative">
		<xsl:variable name="this" select="."/>
		<xsl:attribute name="styleCode" select="$this"/>
	</xsl:template>

	<xsl:template match="@style" mode="narrative">
		<xsl:variable name="this" select="."/>
		<xsl:choose>
			<xsl:when test="contains($this, 'text-decoration')">
				<xsl:if test="contains($this, 'underline')">
					<xsl:attribute name="styleCode">
						<xsl:value-of select="'Underlined'"/>
					</xsl:attribute>
				</xsl:if>
			</xsl:when>
			<xsl:when test="contains($this, 'list-style-type')">
				<xsl:choose>
					<xsl:when test="contains($this, 'disc')">
						<xsl:attribute name="styleCode">
							<xsl:value-of select="'Disc'"/>
						</xsl:attribute>						
					</xsl:when>
					<xsl:when test="contains($this, 'circle')">
						<xsl:attribute name="styleCode">
							<xsl:value-of select="'Circle'"/>
						</xsl:attribute>						
					</xsl:when>
					<xsl:when test="contains($this, 'square')">
						<xsl:attribute name="styleCode">
							<xsl:value-of select="'Square'"/>
						</xsl:attribute>						
					</xsl:when>	
					<xsl:when test="contains($this, 'decimal')">
						<xsl:attribute name="styleCode">
							<xsl:value-of select="'Arabic'"/>
						</xsl:attribute>						
					</xsl:when>					
					<xsl:when test="contains($this, 'lower-roman')">
						<xsl:attribute name="styleCode">
							<xsl:value-of select="'LittleRoman'"/>
						</xsl:attribute>						
					</xsl:when>					
					<xsl:when test="contains($this, 'upper-roman')">
						<xsl:attribute name="styleCode">
							<xsl:value-of select="'BigRoman'"/>
						</xsl:attribute>						
					</xsl:when>					
					<xsl:when test="contains($this, 'lower-alpha')">
						<xsl:attribute name="styleCode">
							<xsl:value-of select="'LittleAlpha'"/>
						</xsl:attribute>						
					</xsl:when>					
					<xsl:when test="contains($this, 'upper-alpha')">
						<xsl:attribute name="styleCode">
							<xsl:value-of select="'BigAlpha'"/>
						</xsl:attribute>						
					</xsl:when>										
				</xsl:choose>	
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- styles:
		border
		color
		direction: ltr rtl
		font-family
		font-size (absolute, relative, %)
		font-style: normal italic oblique
		list-style-type: disc circle square
		text-align: left right center justify
		text-decoration: none underline overline line-through blink
	-->
	
	<xsl:template match="@*" mode="table-atts">
		<xsl:variable name="attval" select="."/>
		<xsl:choose>
			<!-- Suppress defaulted colspan and rowspan attributes. XMLSpy adds them when the FHIR schema is attached, causing problems.  -->
			<xsl:when test="(local-name() = 'colspan' or local-name() = 'rowspan') and $attval='1'"></xsl:when>
			<!-- Suppress @class in tables  -->
			<xsl:when test="(local-name() = 'class')"></xsl:when>
			<xsl:otherwise><xsl:copy/></xsl:otherwise>
		</xsl:choose>		
	</xsl:template>
	
	<xsl:template match="@id" mode="#all">
		<xsl:attribute name="ID"><xsl:value-of select="."/></xsl:attribute>
	</xsl:template>

	<xsl:template match="@*" mode="narrative"><xsl:variable name="this" select="."/><xsl:copy/></xsl:template>

	<!-- styleCodes -->

	<xsl:template match="xhtml:b" mode="narrative"><content styleCode="Bold"><xsl:apply-templates select="@*" mode="narrative"/><xsl:apply-templates mode="narrative"/></content></xsl:template>

	<xsl:template match="xhtml:i" mode="narrative"><content styleCode="Italics"><xsl:apply-templates select="@*" mode="narrative"/><xsl:apply-templates mode="narrative"/></content></xsl:template>

	<!-- if from internal editor, sometimes a deprecated 'u' element may be used -->
	<xsl:template match="xhtml:u" mode="narrative"><content styleCode="Underline"><xsl:apply-templates select="@*" mode="narrative"/><xsl:apply-templates mode="narrative"/></content></xsl:template>
		
	<xsl:template match="xhtml:*" mode="narrative">
		<xsl:apply-templates select="@*" mode="narrative"/><xsl:apply-templates  mode="narrative"/>
	</xsl:template>
	
	
</xsl:stylesheet>
