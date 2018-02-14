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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns="http://hl7.org/fhir"
                xmlns:lcg="http://www.lantanagroup.com"
                xmlns:cda="urn:hl7-org:v3"
                xmlns:fhir="http://hl7.org/fhir"
                xmlns:uuid="java:java.util.UUID"
                version="2.0"
                exclude-result-prefixes="lcg cda uuid fhir">

   <xsl:import href="cda2fhir-includes.xslt"/>

   <xsl:output method="xml" indent="yes" encoding="UTF-8" />
   <xsl:strip-space elements="*"/>
   
   <xsl:template match="/">
      
      <!-- 
         
         ================================  WARNING ===================================
         This transforms assumes that lcg:uuid attributes have been added to all 
         elements of the input CDA document (the Java program that invokes this 
         transform adds those attributes automatically). If that is not true (such as 
         for transform development/debugging) you should be using Oxygen-cda2fhir.xslt 
         with the Saxon-PE XSLT processor.
         ==============================================================================
         
      -->
      
      <xsl:apply-templates select="." mode="convert"/>
   </xsl:template>
  
   
</xsl:stylesheet>
