package de.jabc.cinco.meta.plugin.mcam;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import org.eclipse.core.resources.IProject;
import org.eclipse.emf.ecore.EcorePackage;

import freemarker.template.TemplateException;
import mgl.Attribute;
import mgl.Edge;
import mgl.GraphModel;
import mgl.ModelElement;
import mgl.Node;
import mgl.NodeContainer;

public class McamImplementationGenerator {

	private GraphModel gModel = null;
	private String graphModelName = null;

	private IProject project = null;

	private String basePackage = null;
	private String mcamPackageSuffix = null;
	private String graphModelPackageSuffix = null;
	
	private ArrayList<String> changeModuleClasses = new ArrayList<>();

	public McamImplementationGenerator(GraphModel gModel, IProject project,
			String basePackage, String mcamPackage) {
		super();
		this.gModel = gModel;
		this.graphModelName = this.gModel.getName();
		this.project = project;
		this.basePackage = basePackage;
		this.mcamPackageSuffix = mcamPackage;
		this.graphModelPackageSuffix = "." + graphModelName.toLowerCase();
	}

	public String generate() {
		try {
			generateEntityId();
			generateModelAdapter();
			generateChangeModules();
			generateCliExecution();
			return "default";
		} catch (IOException | TemplateException e) {
			e.printStackTrace();
		}
		return "error";
	}

	private void generateEntityId() throws IOException, TemplateException {
		Map<String, Object> data = new HashMap<String, Object>();
		data.put("GraphModelName", graphModelName);
		data.put("Package", basePackage + mcamPackageSuffix + ".adapter");

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/adapter/EntityId.tpl", project);
		templateGen.setFilename(graphModelName + "Id.java");
		templateGen.setPkg((String) data.get("Package"));
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generateModelAdapter() throws IOException, TemplateException {
		Map<String, Object> data = new HashMap<String, Object>();
		data.put("GraphModelName", graphModelName);
		data.put("GraphModelExtension", gModel.getFileExtension());
		data.put("GraphPackage", basePackage + graphModelPackageSuffix);
		data.put("Package", basePackage + mcamPackageSuffix + ".adapter");

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/adapter/ModelAdapter.tpl", project);
		templateGen.setFilename(graphModelName + "Adapter.java");
		templateGen.setPkg((String) data.get("Package"));
		templateGen.setData(data);
		templateGen.generateFile();
	}
	
	private void generateCliExecution() throws IOException, TemplateException {
		Map<String, Object> data = new HashMap<String, Object>();
		data.put("Package", basePackage + mcamPackageSuffix + ".cli");
		data.put("GraphModelName", graphModelName);
		data.put("AdapterPackage", basePackage + mcamPackageSuffix + ".adapter");
		data.put("ChangeModules", changeModuleClasses);
		data.put("ChangeModulePackage", basePackage + mcamPackageSuffix + ".modules.changes");

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/cli/CliMain.tpl", project);
		templateGen.setFilename("CliMain.java");
		templateGen.setPkg((String) data.get("Package"));
		templateGen.setData(data);
		templateGen.generateFile();

		templateGen = new TemplateGenerator("templates/cli/CliExecution.tpl",
				project);
		templateGen.setFilename("CliExecution.java");
		templateGen.setPkg((String) data.get("Package"));
		templateGen.setData(data);
		templateGen.generateFile();

		templateGen = new TemplateGenerator(
				"templates/cli/FrameworkExecution.tpl", project);
		templateGen.setFilename("FrameworkExecution.java");
		templateGen.setPkg((String) data.get("Package"));
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generateChangeModules() throws IOException, TemplateException {
		for (Attribute attribute : gModel.getAttributes()) {
			generateAttributeChangeModule(gModel, attribute);
		}
		
		for (Node node : gModel.getNodes()) {
			generateAddChangeModule(node);
			generateDeleteChangeModule(node);
			generateStyleChangeModule(node);
			generateContainmentChangeModule(node);
			for (Attribute attribute : node.getAttributes()) {
				generateAttributeChangeModule(node, attribute);
			}
		}
		for (Edge edge : gModel.getEdges()) {
			generateAddChangeModule(edge);
			generateDeleteChangeModule(edge);
			generateContainmentChangeModule(edge);
			for (Attribute attribute : edge.getAttributes()) {
				generateAttributeChangeModule(edge, attribute);
			}
		}
		for (NodeContainer container : gModel.getNodeContainers()) {
			generateAddChangeModule(container);
			generateDeleteChangeModule(container);
			generateStyleChangeModule(container);
			generateContainmentChangeModule(container);
			for (Attribute attribute : container.getAttributes()) {
				generateAttributeChangeModule(container, attribute);
			}
		}
	}

	private void generateAttributeChangeModule(ModelElement element, Attribute attribute) throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/modules/AttributeChangeModule.tpl", project);
		Map<String, Object> data = new HashMap<String, Object>();
		
		data.put("ClassName", element.getName() + attribute.getName().substring(0,1).toUpperCase() + attribute.getName().substring(1) + "Change");
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		
		data.put("Package", basePackage + mcamPackageSuffix + ".modules.changes");
		templateGen.setPkg((String) data.get("Package"));
		
		data.put("GraphModelName", graphModelName);
		data.put("GraphPackage", basePackage + graphModelPackageSuffix);
		data.put("AdapterPackage", basePackage + mcamPackageSuffix + ".adapter");
		data.put("ModelElementName", element.getName());
		data.put("AttributeName", attribute.getName());
		data.put("AttributeType", EcorePackage.eINSTANCE.getEClassifier(attribute.getType()).getInstanceClass().getSimpleName());
		
		templateGen.setData(data);
		templateGen.generateFile();
		changeModuleClasses.add((String) data.get("ClassName"));
	}
	
	private void generateAddChangeModule(ModelElement element) throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/modules/AddElementModule.tpl", project);
		Map<String, Object> data = new HashMap<String, Object>();
		
		data.put("ClassName", element.getName() + "AddChange");
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		
		data.put("Package", basePackage + mcamPackageSuffix + ".modules.changes");
		templateGen.setPkg((String) data.get("Package"));
		
		data.put("GraphModelName", graphModelName);
		data.put("GraphPackage", basePackage + graphModelPackageSuffix);
		data.put("AdapterPackage", basePackage + mcamPackageSuffix + ".adapter");
		data.put("ModelElementName", element.getName());
		
		templateGen.setData(data);
		templateGen.generateFile();
		changeModuleClasses.add((String) data.get("ClassName"));
	}
	
	private void generateDeleteChangeModule(ModelElement element) throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/modules/DeleteElementModule.tpl", project);
		Map<String, Object> data = new HashMap<String, Object>();
		
		data.put("ClassName", element.getName() + "DeleteChange");
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		
		data.put("Package", basePackage + mcamPackageSuffix + ".modules.changes");
		templateGen.setPkg((String) data.get("Package"));
		
		data.put("GraphModelName", graphModelName);
		data.put("GraphPackage", basePackage + graphModelPackageSuffix);
		data.put("AdapterPackage", basePackage + mcamPackageSuffix + ".adapter");
		data.put("ModelElementName", element.getName());
		
		templateGen.setData(data);
		templateGen.generateFile();
		changeModuleClasses.add((String) data.get("ClassName"));
	}
	
	private void generateStyleChangeModule(ModelElement element) throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/modules/StyleChangeModule.tpl", project);
		Map<String, Object> data = new HashMap<String, Object>();
		
		data.put("ClassName", element.getName() + "StyleChange");
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		
		data.put("Package", basePackage + mcamPackageSuffix + ".modules.changes");
		templateGen.setPkg((String) data.get("Package"));
		
		data.put("GraphModelName", graphModelName);
		data.put("GraphPackage", basePackage + graphModelPackageSuffix);
		data.put("AdapterPackage", basePackage + mcamPackageSuffix + ".adapter");
		data.put("ModelElementName", element.getName());
		
		templateGen.setData(data);
		templateGen.generateFile();
		changeModuleClasses.add((String) data.get("ClassName"));
	}
	
	private void generateContainmentChangeModule(ModelElement element) throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/modules/ContainmentChangeModule.tpl", project);
		Map<String, Object> data = new HashMap<String, Object>();
		
		data.put("ClassName", element.getName() + "ContainmentChange");
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		
		data.put("Package", basePackage + mcamPackageSuffix + ".modules.changes");
		templateGen.setPkg((String) data.get("Package"));
		
		data.put("GraphModelName", graphModelName);
		data.put("GraphPackage", basePackage + graphModelPackageSuffix);
		data.put("AdapterPackage", basePackage + mcamPackageSuffix + ".adapter");
		data.put("ModelElementName", element.getName());
		
		templateGen.setData(data);
		templateGen.generateFile();
		changeModuleClasses.add((String) data.get("ClassName"));
	}

}
