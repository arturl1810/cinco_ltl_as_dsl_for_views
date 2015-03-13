package de.jabc.cinco.meta.plugin.mcam;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import mgl.GraphModel;

import org.eclipse.core.resources.IProject;

import freemarker.template.TemplateException;

public class McamConflictViewGenerator {
	public static String conflictViewPackageSuffix = "conflictview";
	
	private String graphModelName = null;

	private IProject project = null;

	private String basePackage = null;

	public Map<String, Object> data = new HashMap<>();

	public McamConflictViewGenerator(GraphModel gModel, IProject project,
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
		data.put("ConflictViewPackage", this.basePackage + "." + McamImplementationGenerator.mcamPackageSuffix
				+ "." + conflictViewPackageSuffix);
	}

	public String generate() {
		try {
			generateActivator();
			generateMergeProcessTreeRenderer();
			generateConflictView();
			generateConflictViewInformation();
			generatePluginXml();
			generateManifest();
			generateBuildProperties();
			generateContextsXml();
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
				"templates/conflict_view/Activator.tpl", project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ConflictViewPackage"));
		templateGen.setData(data);
		templateGen.generateFile();
	}
	
	private void generateMergeProcessTreeRenderer()
			throws IOException, TemplateException {
		data.put("ClassName", "MergeProcessTreeRenderer");

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/conflict_view/MergeProcessTreeRenderer.tpl", project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ConflictViewPackage") + ".util");
		templateGen.setData(data);
		templateGen.generateFile();
	}
	
	private void generateConflictViewInformation()
			throws IOException, TemplateException {
		data.put("ClassName", "ConflictViewInformation");

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/conflict_view/ConflictViewInformation.tpl", project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ConflictViewPackage") + ".views");
		templateGen.setData(data);
		templateGen.generateFile();
	}
	
	private void generateConflictView()
			throws IOException, TemplateException {
		data.put("ClassName", "ConflictView");

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/conflict_view/ConflictView.tpl", project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ConflictViewPackage") + ".views");
		templateGen.setData(data);
		templateGen.generateFile();
	}
	
	private void generatePluginXml()
			throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/conflict_view/plugin.tpl", project);
		templateGen.setFilename("plugin.xml");
		templateGen.setPkg("");
		templateGen.setBasePath("");
		templateGen.setData(data);
		templateGen.generateFile();
	}
	
	private void generateManifest()
			throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/conflict_view/Manifest.tpl", project);
		templateGen.setFilename("MANIFEST.MF");
		templateGen.setPkg("");
		templateGen.setBasePath("META-INF");
		templateGen.setData(data);
		templateGen.generateFile();
	}
	
	private void generateBuildProperties()
			throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/conflict_view/build.properties", project);
		templateGen.setFilename("build.properties");
		templateGen.setPkg("");
		templateGen.setBasePath("");
		templateGen.setData(data);
		templateGen.generateFile();
	} 
	
	private void generateContextsXml()
			throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/conflict_view/contexts.tpl", project);
		templateGen.setFilename("contexts.xml");
		templateGen.setPkg("");
		templateGen.setBasePath("");
		templateGen.setData(data);
		templateGen.generateFile();
	}
}
