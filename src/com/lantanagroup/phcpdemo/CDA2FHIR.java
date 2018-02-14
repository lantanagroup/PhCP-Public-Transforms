package com.lantanagroup.phcpdemo;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.util.UUID;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

public class CDA2FHIR extends PhcpTransformer {
	
	private static final String LANTANAGROUP_NAMESPACE = "http://www.lantanagroup.com";
	public CDA2FHIR(File xsltFile) throws TransformerConfigurationException {
		super(xsltFile);
	}
	
	public void runTransform(InputStream cdaIn, OutputStream fhirOut, boolean fhirJson) throws TransformerException, ParserConfigurationException, SAXException, IOException {
		ByteArrayInputStream preProcessedIn;
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
		dbf.setNamespaceAware(true);
		DocumentBuilder db = dbf.newDocumentBuilder();
		Document doc = db.parse(cdaIn);
		addUuidExtensions(doc,doc.getDocumentElement());
		preProcessedIn = doc2InputStream(doc);
		ByteArrayOutputStream tempOut = new ByteArrayOutputStream();
		super.runTransform(preProcessedIn, tempOut);
		String finalOutStr;
		if (fhirJson) {
			finalOutStr = xml2json(new String(tempOut.toByteArray()));
		} else {
			finalOutStr = new String(tempOut.toByteArray());
		}
		fhirOut.write(finalOutStr.getBytes());
	}
	
	private void addUuidExtensions(Document doc, Element elem) {
		UUID uuid = UUID.randomUUID();
		Attr uuidAttr = doc.createAttributeNS(LANTANAGROUP_NAMESPACE, "uuid");
		uuidAttr.setPrefix("lcg");
		uuidAttr.setValue(uuid.toString());
		elem.setAttributeNode(uuidAttr);
		NodeList nl = elem.getChildNodes();
		for (int i = 0 ; i < nl.getLength() ; i++){
			Node n = nl.item(i);
			if (n.getNodeType() == Node.ELEMENT_NODE){
				addUuidExtensions(doc,(Element)n);
			}
		}
	}
	
	public ByteArrayInputStream doc2InputStream(Document doc) throws TransformerConfigurationException, TransformerException {
		Transformer t = TransformerFactory.newInstance().newTransformer();
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		StreamResult sr = new StreamResult(baos);
		DOMSource ds = new DOMSource(doc);
		t.transform(ds, sr);
		ByteArrayInputStream stream = new ByteArrayInputStream(baos.toByteArray());
		return stream;
	}
	
	public void runTransform(File in, File out, boolean fhirJson) throws IOException, TransformerException, ParserConfigurationException, SAXException {
		ByteArrayInputStream bin = new ByteArrayInputStream(Files.readAllBytes(in.toPath()));
		ByteArrayOutputStream bout = new ByteArrayOutputStream();
		runTransform(bin,bout,fhirJson);
		String finalOutStr;
		if (fhirJson) {
			finalOutStr = xml2json(new String(bout.toByteArray()));
		} else {
			finalOutStr = new String(bout.toByteArray());
		}
		Files.write(out.toPath(), finalOutStr.getBytes());
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
    	cdaFile = new File(line.getOptionValue( "cda" ));
    	fhirFile = new File(line.getOptionValue( "fhir" ));
    	transformFile = new File(line.getOptionValue( "transform" ));
	    if( line.hasOption( "fhirJson" ) ) {
	    	fhirJson = true;
	    }
	    CDA2FHIR c2f = new CDA2FHIR(transformFile);
	    c2f.runTransform(cdaFile, fhirFile, fhirJson);
	}
}
