package com.lantanagroup.phcpdemo;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.nio.file.Files;
import java.util.UUID;

import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.hl7.fhir.instance.model.api.IBaseResource;

import ca.uhn.fhir.context.FhirContext;
import ca.uhn.fhir.parser.IParser;
import ca.uhn.fhir.parser.XmlParser;

public abstract class PhcpTransformer {

	private TransformerFactory tf = TransformerFactory.newInstance();
	private Templates compiledXslt;
	private final FhirContext ctx = FhirContext.forDstu3();
	private static final String XML_DEC = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
	
	public PhcpTransformer(File xsltFile) throws TransformerConfigurationException {
		StreamSource xslt = new StreamSource(xsltFile);
		compiledXslt = tf.newTemplates(xslt);
	}
	
	protected void runTransform(InputStream in, OutputStream out) throws TransformerException {
		StreamSource ss = new StreamSource(in);
		StreamResult sr = new StreamResult(out);
		Transformer t = compiledXslt.newTransformer();
		t.transform(ss, sr);
	}
	
	public String xml2json (String xmlStr){
		IParser xmlParser = ctx.newXmlParser();
		IBaseResource res = xmlParser.parseResource(xmlStr);
		IParser jsonParser = ctx.newJsonParser();
		jsonParser.setPrettyPrint(true);
		String jsonStr = jsonParser.encodeResourceToString(res);
		return jsonStr;
	}
	
	public String json2xml (String jsonStr) throws IOException{
		IParser jsonParser = ctx.newJsonParser();
		IBaseResource res = jsonParser.parseResource(jsonStr);
		XmlParser xmlParser = (XmlParser) ctx.newXmlParser();
		xmlParser.setPrettyPrint(true);
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		OutputStreamWriter osw = new OutputStreamWriter(baos,"UTF-8");
		xmlParser.doEncodeResourceToWriter(res,osw);
		osw.close();
		String xmlStr = new String(baos.toByteArray());
		if (xmlStr.startsWith("<?xml)") == false ){
			xmlStr = XML_DEC + xmlStr;
		}
		return xmlStr;
	}

	protected static CommandLine parseArgs(String[] args) throws ParseException {
		Option cda = Option.builder("cda").hasArg().required(true).desc("CDA input document").build();
		Option fhir = Option.builder("fhir").hasArg().required(true).desc("FHIR output document").build();
		Option transform = Option.builder("transform").hasArg().required(true).desc("Location of the cda2fhir.xslt file").build();
		Option debug = Option.builder("fhirJson").desc("Use FHIR JSON vs. FHIR XML").build();
		Options options = new Options();
		options.addOption(cda);
		options.addOption(fhir);
		options.addOption(transform);
		options.addOption(debug);
		CommandLineParser parser = new DefaultParser();
        CommandLine line = parser.parse( options, args );
		return line;
	}

}
