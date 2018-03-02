<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns="http://hl7.org/fhir"
                xmlns:lcg="http://www.lantanagroup.com"
                xmlns:cda="urn:hl7-org:v3"
                xmlns:fhir="http://hl7.org/fhir"
                version="2.0"
                exclude-result-prefixes="lcg cda fhir">
   
   <xsl:include href="cda2fhir-Bundle.xslt"/>
   <xsl:include href="cda2fhir-Composition.xslt"/>
   <xsl:include href="cda2fhir-Patient.xslt"/>
   <xsl:include href="cda2fhir-Practitioner.xslt"/>
   <xsl:include href="cda2fhir-Organization.xslt"/>
   <!--xsl:include href="cda2fhir-List.xslt"/-->
   <xsl:include href="cda2fhir-RequestGroup.xslt"/>
   <xsl:include href="cda2fhir-MedicationRequest.xslt"/>
   <xsl:include href="cda2fhir-MedicationDispense.xslt"/>
   <xsl:include href="cda2fhir-MedicationStatement.xslt"/>
   <xsl:include href="cda2fhir-Condition.xslt"/>
   <xsl:include href="cda2fhir-AllergyIntolerance.xslt"/>
   <xsl:include href="cda2fhir-Goal.xslt"/>
   <xsl:include href="cda2fhir-Observation.xslt"/>
   <xsl:include href="cda2fhir-Coverage.xslt"/>
   <xsl:include href="cda2fhir-Encounter.xslt"/>
   <xsl:include href="cda2fhir-Communication.xslt"/>
   <!--<xsl:include href="cda2fhir-ReferralRequest.xslt"/>-->
   <xsl:include href="cda2fhir-ProcedureRequest.xslt"/>
   <xsl:include href="cda2fhir-RiskAssessment.xslt"/>
   <xsl:include href="cda2fhir-Narrative.xslt"/>
   <xsl:include href="cda2fhir-Procedure.xslt"/>
   <xsl:include href="cda2fhir-FamilyMemberHistory.xslt"/>
   <!-- CarePlan resource not needed for ONC-HIP use case. Revisit later. -->
   
   <xsl:include href="cda2fhir-CarePlan.xslt"/>
   <xsl:include href="c-to-fhir-utility.xslt"/>
   <xsl:include href="cda2fhir-fallback-templates.xslt"/>
  
   
   
</xsl:stylesheet>
