package de.jabc.cinco.meta.plugin.mcam;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import mgl.GraphModel;

import org.eclipse.core.resources.IProject;

import freemarker.template.TemplateException;

public class McamViewGenerator {
	public static String viewPackageSuffix = "views";
	
	private String graphModelName = null;

	private IProject project = null;

	private String basePackage = null;

	public Map<String, Object> data = new HashMap<>();

	public McamViewGenerator(GraphModel gModel, IProject project,
			String basePackage) {
		super();
		this.project = project;
		this.basePackage = basePackage;
		this.graphModelName = gModel.getName();

		data.put("GraphModelName", graphModelName);
		data.put("GraphModelExtension", gModel.getFileExtension());

		data.put("GraphModelPackage",
				basePackage + "." + graphModelName.toLowerCase());
		data.put("AdapterPackage", this.basePackage + "." + McamImplementationGenerator.mcamPackageSuffix
				+ "." + McamImplementationGenerator.adapterPackageSuffix);
		data.put("StrategyPackage", this.basePackage + "." + McamImplementationGenerator.mcamPackageSuffix
				+ "." + McamImplementationGenerator.strategiesPackageSuffix);
		data.put("UtilPackage", this.basePackage + "." + McamImplementationGenerator.mcamPackageSuffix
				+ "." + McamImplementationGenerator.utilPackageSuffix);
		
		data.put("ViewPackage", this.basePackage + "." + McamImplementationGenerator.mcamPackageSuffix
				+ "." + viewPackageSuffix);
		
	}

	public String generate() {
		try {
			generateActivator();
			generateMergeProcessTreeRenderer();
			generateConflictView();
			generateConflictViewInformation();
			generateCheckView();
			generateCheckViewInformation();
			generatePluginXml();
			generateManifest();
			generateBuildProperties();
			generateContextsXml();
			generateResourceChangeListener();
			return "default";
		} catch (IOException | TemplateException e) {
			e.printStackTrace();
		}
		return "error";
	}

	private void generateActivator()
			throws IOException, TemplateException {
		data.put("ClassName", "Activator");

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/Activator.tpl", project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ViewPackage"));
		templateGen.setData(data);
		templateGen.generateFile();
	}
	
	private void generateMergeProcessTreeRenderer()
			throws IOException, TemplateException {
		data.put("ClassName", "MergeProcessTreeRenderer");

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/MergeProcessTreeRenderer.tpl", project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ViewPackage") + ".util");
		templateGen.setData(data);
		templateGen.generateFile();
	}
	
	private void generateCheckViewInformation()
			throws IOException, TemplateException {
		data.put("ClassName", "CheckViewInformation");

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/CheckViewInformation.tpl", project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ViewPackage") + ".views");
		templateGen.setData(data);
		templateGen.generateFile();
	}
	
	private void generateCheckView()
			throws IOException, TemplateException {
		data.put("ClassName", "CheckView");

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/CheckView.tpl", project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ViewPackage") + ".views");
		templateGen.setData(data);
		templateGen.generateFile();
	}
	
	private void generateConflictViewInformation()
			throws IOException, TemplateException {
		data.put("ClassName", "ConflictViewInformation");

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/ConflictViewInformation.tpl", project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ViewPackage") + ".views");
		templateGen.setData(data);
		templateGen.generateFile();
	}
	
	private void generateConflictView()
			throws IOException, TemplateException {
		data.put("ClassName", "ConflictView");

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/ConflictView.tpl", project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ViewPackage") + ".views");
		templateGen.setData(data);
		templateGen.generateFile();
	}
	
	private void generatePluginXml()
			throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/plugin.tpl", project);
		templateGen.setFilename("plugin.xml");
		templateGen.setPkg("");
		templateGen.setBasePath("");
		templateGen.setData(data);
		templateGen.generateFile();
	}
	
	private void generateManifest()
			throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/Manifest.tpl", project);
		templateGen.setFilename("MANIFEST.MF");
		templateGen.setPkg("");
		templateGen.setBasePath("META-INF");
		templateGen.setData(data);
		templateGen.generateFile();
	}
	
	private void generateBuildProperties()
			throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/build.properties", project);
		templateGen.setFilename("build.properties");
		templateGen.setPkg("");
		templateGen.setBasePath("");
		templateGen.setData(data);
		templateGen.generateFile();
	} 
	
	private void generateContextsXml()
			throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/contexts.tpl", project);
		templateGen.setFilename("contexts.xml");
		templateGen.setPkg("");
		templateGen.setBasePath("");
		templateGen.setData(data);
		templateGen.generateFile();
	}
	
	private void generateResourceChangeListener() throws IOException, TemplateException {
		data.put("ClassName", "ResourceChangeListener");
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/ResourceChangeListener.tpl", project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ViewPackage") + ".util");
		templateGen.setData(data);
		templateGen.generateFile();
		
		TemplateGenerator templateGen2 = new TemplateGenerator(
				"templates/eclipse_views/DeltaPrinter.tpl", project);
		templateGen2.setFilename("DeltaPrinter.java");
		templateGen2.setPkg((String) data.get("ViewPackage") + ".util");
		templateGen2.setData(data);
		templateGen2.generateFile();
	}
}
