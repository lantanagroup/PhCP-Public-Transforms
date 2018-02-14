package com.lantanagroup.phcpdemo;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.ParseException;
import org.apache.commons.io.IOUtils;
import org.xml.sax.SAXException;

public class FHIR2CDA extends PhcpTransformer {

	public FHIR2CDA(File xsltFile) throws TransformerConfigurationException {
		super(xsltFile);
		// TODO Auto-generated constructor stub
	}

	public void runTransform(InputStream fhirIn, OutputStream cdaOut, boolean fhirJson) throws TransformerException, ParserConfigurationException, SAXException, IOException {
		System.out.println("Starting CDA to FHIR Transform");
		InputStream preProcessedIn;
		if (fhirJson) {
			ByteArrayOutputStream bos = new ByteArrayOutputStream();
			IOUtils.copy(fhirIn, bos);
			System.out.println("Converting from JSON to XML");
			String str = json2xml(new String(bos.toByteArray()));
			preProcessedIn = new ByteArrayInputStream(str.getBytes());
		} else {
			preProcessedIn = fhirIn;
		}
		super.runTransform(preProcessedIn, cdaOut);
		System.out.println("Finished CDA to FHIR Transform");
	}
	
	public static void main (String[] args) {
		try {
			runTransform(args);
		} catch (Throwable e) {
			e.printStackTrace();
		}
	}

	public static void runTransform(String[] args) throws ParseException, IOException, TransformerException, ParserConfigurationException, SAXException {
		CommandLine line = parseArgs(args);
        File cdaFile = null;
        File fhirFile;
        File transformFile;
        boolean fhirJson = false;
    	fhirFile = new File(line.getOptionValue( "fhir" ));
    	cdaFile = new File(line.getOptionValue( "cda" ));
    	transformFile = new File(line.getOptionValue( "transform" ));
	    if( line.hasOption( "fhirJson" ) ) {
	    	fhirJson = true;
	    }
	    FHIR2CDA f2c = new FHIR2CDA(transformFile);
	    f2c.runTransform(fhirFile, cdaFile, fhirJson);
	}
	
	public void runTransform(File in, File out, boolean fhirJson) throws IOException, TransformerException, ParserConfigurationException, SAXException {
		ByteArrayInputStream bin = new ByteArrayInputStream(Files.readAllBytes(in.toPath()));
		ByteArrayOutputStream bout = new ByteArrayOutputStream();
		runTransform(bin,bout,fhirJson);
		Files.write(out.toPath(), bout.toByteArray());
	}
}
