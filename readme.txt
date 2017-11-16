This folder contains CDA to FHIR and FHIR to CDA transforms for the Pharmacist Care Plan document type. 
The transforms are written using XSLT with java extensions for creating UUIDs. As such they will currently only run using the Saxon PE (professional edition) XSLT process. 
Saxon PE is included in the Oxygen XML Editor, so the transforms can be run using Oxygen. 
Future releases will move the UUID creation to a separate piece of Java code, and provide a command-line tool for running the transforms. 
 