<?xml version="1.0" encoding="UTF-8"?>
<!-- 

Copyright 2017 Lantana Consulting Group

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:hl7-org:v3"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xmlns:lcg="http://www.lantanagroup.com" xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
   xmlns:cda="urn:hl7-org:v3" xmlns:fhir="http://hl7.org/fhir" xmlns:uuid="java:java.util.UUID"
   xmlns:xhtml="http://www.w3.org/1999/xhtml" version="2.0"
   exclude-result-prefixes="lcg xsl cda fhir xhtml">

   <xsl:include href="fhir2cda-CD.xslt"/>
   <xsl:include href="fhir2cda-II.xslt"/>
   <xsl:include href="fhir2cda-TEL.xslt"/>
   <xsl:include href="fhir2cda-ADDR.xslt"/>
   <xsl:include href="fhir2cda-RecordTarget.xslt"/>
   <xsl:include href="fhir2cda-utility.xslt"/>
   <xsl:include href="fhir2cda-narrative.xslt"/>
   <xsl:include href="fhir2cda-Author.xslt"/>
   <xsl:include href="fhir2cda-Custodian.xslt"/>
   <xsl:include href="fhir2cda-LegalAuthenticator.xslt"/>
   <xsl:include href="fhir2cda-Intervention.xslt"/>
   <xsl:include href="fhir2cda-MedicationActivity.xslt"/>
   <xsl:include href="fhir2cda-ServiceEvent.xslt"/>
   <xsl:include href="fhir2cda-Goal.xslt"/>
   <xsl:include href="fhir2cda-AllergyIntolerance.xslt"/>
   <xsl:include href="fhir2cda-ProblemObservation.xslt"/>
   <xsl:include href="fhir2cda-VitalSigns.xslt"/>
   <xsl:include href="fhir2cda-OutcomeObservation.xslt"/>
   

   <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
   
   <xsl:template match="/">
      <xsl:message>Begining transform</xsl:message>
      <xsl:choose>
         <xsl:when test="fhir:Bundle/fhir:type[@value='document']">
            <xsl:apply-templates select="fhir:Bundle/fhir:type[@value='document']"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message terminate="yes">This transform can only be run on a FHIR Bundle resource where type = document</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      
   </xsl:template>

   <xsl:template match="fhir:Bundle/fhir:type[@value='document']">
      <xsl:apply-templates select="//fhir:Composition"/>
   </xsl:template>

   <xsl:template match="fhir:Composition">
      <xsl:variable name="docId" select="uuid:randomUUID()"/>
      <ClinicalDocument>
         <realmCode code="US"/>
         <typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>
         <templateId root="2.16.840.1.113883.10.20.22.1.1" extension="2015-08-01"/>
         <templateId root="2.16.840.1.113883.10.20.22.1.15" extension="2015-08-01"/>
         <!-- generate a new ID for this document. Save the FHIR document id in parentDocument with a type of XFRM -->
         <id root="{$docId}"/>
         <xsl:for-each select="fhir:type">
            <xsl:call-template name="CodeableConcept2CD"/>
         </xsl:for-each>
         <title><xsl:value-of select="fhir:title/@value"/></title>
         <effectiveTime>
            <xsl:attribute name="value">
               <xsl:call-template name="Date2TS">
                  <xsl:with-param name="date" select="fhir:date/@value"/>
                  <xsl:with-param name="includeTime" select="true()" />
               </xsl:call-template>
            </xsl:attribute>
         </effectiveTime>
         <xsl:choose>
            <xsl:when test="fhir:confidentiality">
               <confidentialityCode codeSystem="2.16.840.1.113883.5.25" code="{fhir:confidentiality/@value}"/>
            </xsl:when>
            <xsl:otherwise>
               <confidentialityCode nullFlavor="NI"/>
            </xsl:otherwise>
         </xsl:choose>
         <!-- TODO: Add languageCode -->
         <xsl:if test="fhir:language">
            <languageCode code="{fhir:language/@value}"/>
         </xsl:if>
         
         <xsl:apply-templates select="fhir:subject"/>
         <xsl:apply-templates select="fhir:author"/>
         <xsl:choose>
            <xsl:when test="fhir:custodian">
               <xsl:apply-templates select="fhir:custodian"/>
            </xsl:when>
            <xsl:otherwise>
               <custodian nullFlavor="NI">
                  <assignedCustodian nullFlavor="NI">
                     <representedCustodianOrganization nullFlavor="NI">
                        <id nullFlavor="NI"/>
                     </representedCustodianOrganization>
                  </assignedCustodian>
               </custodian>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:apply-templates select="fhir:attester"/>
         <xsl:apply-templates select="fhir:event"/>
         
         <component>
            <structuredBody>
               <xsl:for-each select="fhir:section">
                  <xsl:sort select="fhir:title/@value"/>
                  <xsl:call-template name="section">
                     <xsl:with-param name="title" select="fhir:title/@value"/>
                  </xsl:call-template>
               </xsl:for-each>
            </structuredBody>
         </component>
         
      </ClinicalDocument>
   </xsl:template>
   
   <xsl:template name="section">		
      <xsl:param name="title" />
      <component>
         <section>
            <xsl:variable name="generated-narrative" select="fhir:text/fhir:status/@value"/>
            <!--xsl:apply-templates select="fhir:extension[1]" mode="templateId"/-->
            <xsl:call-template name="section-templates"/>
            <code>
               <xsl:apply-templates select="fhir:code"/>
            </code>
            <!--
            <code code="{fhir:code/fhir:coding/fhir:code/@value}"
               displayName="{fhir:code/fhir:coding/fhir:display/@value}"
               codeSystemName="{fhir:code/fhir:coding/fhir:system/@value}"/>
            -->
            <title><xsl:value-of select="$title"/></title>
            <text>
               <xsl:if test="normalize-space(fhir:text/xhtml:div/xhtml:div[@class='custom']) != 'No information.'">
                  <xsl:apply-templates select="fhir:text" mode="narrative"/>
               </xsl:if>
            </text>
            <xsl:for-each select="fhir:entry">
               <xsl:for-each select="fhir:reference">
                  <xsl:variable name="referenceURI">
                     <xsl:call-template name="resolve-to-full-url">
                        <xslt:with-param name="referenceURI" select="@value"></xslt:with-param>
                     </xsl:call-template>
                  </xsl:variable>
                  
                  <xsl:for-each select="//fhir:entry[fhir:fullUrl/@value=$referenceURI]">
                     <xsl:apply-templates select="fhir:resource/fhir:*" mode="entry">
                        <xsl:with-param name="generated-narrative"></xsl:with-param>
                     </xsl:apply-templates>
                  </xsl:for-each>
               </xsl:for-each>
            </xsl:for-each>
         </section>
      </component>
   </xsl:template>
   
   <xsl:template name="section-templates">
      <xsl:variable name="loinc-code" select="fhir:code/fhir:coding[fhir:system/@value='http://loinc.org']/fhir:code/@value"/>
      <xsl:choose>
         <xsl:when test="$loinc-code='75310-3'">
            <templateId root="2.16.840.1.113883.10.20.22.2.58" extension="2015-08-01" />
            <templateId root="2.16.840.1.113883.10.20.37.2.1" extension="2017-08-01" />
         </xsl:when>
         <xsl:when test="$loinc-code='61146-7'">
            <templateId root="2.16.840.1.113883.10.20.22.2.60" />
            <templateId root="2.16.840.1.113883.10.20.37.2.2" extension="2017-08-01" />
         </xsl:when>
         <xsl:when test="$loinc-code='62387-6'">
            <templateId root="2.16.840.1.113883.10.20.21.2.3" extension="2015-08-01" />
            <templateId root="2.16.840.1.113883.10.20.37.2.4" extension="2017-08-01" />
         </xsl:when>
         <xsl:when test="$loinc-code='11383-7'">
            <templateId root="2.16.840.1.113883.10.20.22.2.61" />
            <templateId root="2.16.840.1.113883.10.20.37.2.3" extension="2017-08-01" />
         </xsl:when>
         <xsl:when test="$loinc-code='48768-6'">
            <templateId root="2.16.840.1.113883.10.20.22.2.18" extension="2015-08-01" />
         </xsl:when>
      </xsl:choose>
      
   </xsl:template>
   
   <xsl:template match="fhir:*" mode="entry" priority="-10">
      <xsl:comment>
         <xsl:text>TODO: unmapped entry </xsl:text>
         <xsl:value-of select="local-name(.)"/>
         <xsl:text> </xsl:text>
         <xsl:if test="fhir:meta/fhir:profile/@value">
            <xsl:value-of select="fhir:meta/fhir:profile/@value"/>
         </xsl:if>
      </xsl:comment>
   </xsl:template>
   
   <xsl:template match="fhir:*" mode="entry-relationship" priority="-10">
      <xsl:comment>
         <xsl:text>TODO: unmapped entryRelationship</xsl:text>
         <xsl:value-of select="local-name(.)"/>
         <xsl:text> </xsl:text>
         <xsl:if test="fhir:meta/fhir:profile/@value">
            <xsl:value-of select="fhir:meta/fhir:profile/@value"/>
         </xsl:if>
      </xsl:comment>
   </xsl:template>
   
</xsl:stylesheet>
