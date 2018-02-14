# PhCP-Public-Transforms

This folder contains CDA to FHIR and FHIR to CDA transforms for the Pharmacist Care Plan document type.

The transforms are in XSLT, with a Java program to invoke them. The Java program is currently required for CDA to FHIR conversion (it adds UUIDs to the input CDA files) and for any transform involving JSON content. 

To run the CDA to FHIR transform, use com.lantanagroup.phcpdemo.CDA2FHIR. 

To run from the command line, call that class with the following command line parameters:

-cda CDA-INPUT-FILE -fhir FHIR-OUTPUT-FILE -transform LOCATION-OF-cda2fhir.xslt

You can optionally add the fhirJson parameter. If present it will output FHIR in JSON syntax instead of XML. 

To run via a service, create a CDA2FHIR instance (contructor requires you pass the location of cda2fhir.xslt as a File), then call the method with the following signature, which takes input/output streams:

public void runTransform(InputStream cdaIn, OutputStream fhirOut, boolean fhirJson)

TBD: create the FHIR to CDA driver. 
 
It is possible to run the transforms directly using OxygenXML or Saxon PE. To do so, run cda2fhir-SaxonPE.xslt or fhir2cda.xslt. If using Oxygen, be sure to select SaxonPE as your XSLT processor. 
 