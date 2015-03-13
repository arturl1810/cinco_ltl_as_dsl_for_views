package de.jabc.cinco.meta.plugin.mcam;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import org.eclipse.core.resources.IProject;
import org.eclipse.emf.ecore.EcorePackage;

import freemarker.template.TemplateException;
import mgl.Annotation;
import mgl.Attribute;
import mgl.Edge;
import mgl.GraphModel;
import mgl.ModelElement;
import mgl.Node;
import mgl.NodeContainer;

public class McamImplementationGenerator {

	public static String mcamPackageSuffix = "mcam";

	public static String adapterPackageSuffix = "adapter";
	public static String cliPackageSuffix = "cli";
	public static String modulesPackageSuffix = "modules";
	public static String changeModulesPackageSuffix = "changes";
	public static String checkModulesPackageSuffix = "checks";
	public static String strategiesPackageSuffix = "strategies";

	private GraphModel gModel = null;
	private String graphModelName = null;

	private IProject project = null;

	private String basePackage = null;

	private ArrayList<String> changeModuleClasses = new ArrayList<>();
	private ArrayList<String> checkModuleClasses = new ArrayList<>();
	private String customMergeStrategy = "";
	
	public Map<String, Object> data = new HashMap<>();

	private ArrayList<HashMap<String, Object>> modelLabels = new ArrayList<>();
	private HashMap<ModelElement, ArrayList<Attribute>> entityAttributes = new HashMap<>();

	public McamImplementationGenerator(GraphModel gModel, IProject project,
			String basePackage) {
		super();
		this.gModel = gModel;
		this.project = project;
		this.basePackage = basePackage;
		this.graphModelName = gModel.getName();
		
		getCustomImplementations();

		data.put("GraphModelName", graphModelName);
		data.put("GraphModelExtension", gModel.getFileExtension());

		data.put("BasePackage", basePackage);

		data.put("GraphModelPackage",
				basePackage + "." + graphModelName.toLowerCase());
		data.put("AdapterPackage", this.basePackage + "." + mcamPackageSuffix
				+ "." + adapterPackageSuffix);
		data.put("ModulePackage", this.basePackage + "."
				+ mcamPackageSuffix + "." + modulesPackageSuffix);
		data.put("ChangeModulePackage", this.basePackage + "."
				+ mcamPackageSuffix + "." + modulesPackageSuffix + "."
				+ changeModulesPackageSuffix);
		data.put("CheckModulePackage", this.basePackage + "."
				+ mcamPackageSuffix + "." + modulesPackageSuffix + "."
				+ checkModulesPackageSuffix);
		data.put("CliPackage", this.basePackage + "." + mcamPackageSuffix + "."
				+ cliPackageSuffix);
		data.put("StrategyPackage", this.basePackage + "." + mcamPackageSuffix
				+ "." + strategiesPackageSuffix);

		data.put("ChangeModules", changeModuleClasses);
		data.put("CheckModules", checkModuleClasses);
		
		data.put("ModelLabels", modelLabels);
		
		data.put("CustomMergeStrategy", customMergeStrategy);
		data.put("MergeStrategyClass", this.graphModelName + "MergeStrategy");

		initEntityAttributesMap();
	}

	private void initEntityAttributesMap() {
		entityAttributes.put(gModel, new ArrayList<Attribute>());
		for (Attribute attribute : gModel.getAttributes()) {
			entityAttributes.get(gModel).add(attribute);
		}

		for (Node node : gModel.getNodes()) {
			entityAttributes.put(node, new ArrayList<Attribute>());
			for (Attribute attribute : node.getAttributes()) {
				entityAttributes.get(node).add(attribute);
			}
		}
		for (Edge edge : gModel.getEdges()) {
			entityAttributes.put(edge, new ArrayList<Attribute>());
			for (Attribute attribute : edge.getAttributes()) {
				entityAttributes.get(edge).add(attribute);
			}
		}
		for (NodeContainer container : gModel.getNodeContainers()) {
			entityAttributes.put(container, new ArrayList<Attribute>());
			for (Attribute attribute : container.getAttributes()) {
				entityAttributes.get(container).add(attribute);
			}
		}
	}

	public String generate() {
		try {
			for (ModelElement element : entityAttributes.keySet()) {
				addLabelEntry(element);

				if (!(element instanceof GraphModel)) {
					generateAddChangeModule(element);
					generateDeleteChangeModule(element);
//					generateContainmentChangeModule(element);
					
					if (element instanceof Edge)
						generateSourceTargetChangeModule(element);

//					if (!(element instanceof Edge))
//						generateStyleChangeModule(element);
				}

				for (Attribute attribute : entityAttributes.get(element)) {
					generateAttributeChangeModule(element, attribute);
				}
			}

			generateEntityId();
			generateModelAdapter();

			generateMergeStrategy();
			generateCliExecution();
			return "default";
		} catch (IOException | TemplateException e) {
			e.printStackTrace();
		}
		return "error";
	}
	
	private void getCustomImplementations() {
		for (Annotation annotation : gModel.getAnnotations()) {
			if ("mcam_changemodule".equals(annotation.getName()))
				changeModuleClasses.add(annotation.getValue().get(0));
			if ("mcam_checkmodule".equals(annotation.getName()))
				checkModuleClasses.add(annotation.getValue().get(0));
			if ("mcam_mergestrategy".equals(annotation.getName()))
				customMergeStrategy = annotation.getValue().get(0);
		}
	}

	private void addLabelEntry(ModelElement element) {
		for (Attribute attribute : element.getAttributes()) {
			for (Annotation annotation : attribute.getAnnotations()) {
				if ("mcam_label".equals(annotation.getName())) {
					HashMap<String, Object> labelEntry = new HashMap<>();
					labelEntry.put("type", element.getName());
					labelEntry.put("attribute", attribute.getName());
					labelEntry.put("primitive",
							isPrimitiveDataType(attribute.getType()));
					modelLabels.add(labelEntry);
				}
			}
		}
	}

	private boolean isPrimitiveDataType(String type) {
		for (ModelElement element : entityAttributes.keySet()) {
			if (type.equals(element.getName()))
				return false;
		}
		return true;
	}

	private void generateEntityId() throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/adapter/EntityId.tpl", project);
		templateGen.setFilename(graphModelName + "Id.java");
		templateGen.setPkg((String) data.get("AdapterPackage"));
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generateModelAdapter() throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/adapter/ModelAdapter.tpl", project);
		templateGen.setFilename(graphModelName + "Adapter.java");
		templateGen.setPkg((String) data.get("AdapterPackage"));
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generateCliExecution() throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/cli/CliMain.tpl", project);
		templateGen.setFilename("CliMain.java");
		templateGen.setPkg((String) data.get("CliPackage"));
		templateGen.setData(data);
		templateGen.generateFile();

		templateGen = new TemplateGenerator("templates/cli/CliExecution.tpl",
				project);
		templateGen.setFilename("CliExecution.java");
		templateGen.setPkg((String) data.get("CliPackage"));
		templateGen.setData(data);
		templateGen.generateFile();

		templateGen = new TemplateGenerator(
				"templates/cli/FrameworkExecution.tpl", project);
		templateGen.setFilename("FrameworkExecution.java");
		templateGen.setPkg((String) data.get("CliPackage"));
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generateMergeStrategy() throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/strategies/MergeStrategy.tpl", project);
		templateGen.setFilename((String) data.get("MergeStrategyClass")
				+ ".java");
		templateGen.setPkg((String) data.get("StrategyPackage"));
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generateAttributeChangeModule(ModelElement element,
			Attribute attribute) throws IOException, TemplateException {
		data.put("ClassName", element.getName() + "Attribute"
				+ attribute.getName().substring(0, 1).toUpperCase()
				+ attribute.getName().substring(1) + "Change");
		data.put("ModelElementName", element.getName());
		data.put("AttributeName", attribute.getName());
		if (isPrimitiveDataType(attribute.getType()))
			data.put("AttributeType",
					EcorePackage.eINSTANCE.getEClassifier(attribute.getType())
							.getInstanceClass().getSimpleName());
		else
			data.put("AttributeType", attribute.getType().toString());

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/modules/AttributeChangeModule.tpl", project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ChangeModulePackage"));
		templateGen.setData(data);
		templateGen.generateFile();

		changeModuleClasses.add((String) data.get("ChangeModulePackage") + "." + (String) data.get("ClassName"));
	}

	private void generateAddChangeModule(ModelElement element)
			throws IOException, TemplateException {
		data.put("ClassName", element.getName() + "AddChange");
		data.put("ModelElementName", element.getName());

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/modules/AddElementModule.tpl", project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ChangeModulePackage"));
		templateGen.setData(data);
		templateGen.generateFile();

		changeModuleClasses.add((String) data.get("ChangeModulePackage") + "." + (String) data.get("ClassName"));
	}

	private void generateDeleteChangeModule(ModelElement element)
			throws IOException, TemplateException {
		data.put("ClassName", element.getName() + "DeleteChange");
		data.put("ModelElementName", element.getName());

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/modules/DeleteElementModule.tpl", project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ChangeModulePackage"));
		templateGen.setData(data);
		templateGen.generateFile();

		changeModuleClasses.add((String) data.get("ChangeModulePackage") + "." + (String) data.get("ClassName"));
	}
	
	private void generateSourceTargetChangeModule(ModelElement element)
			throws IOException, TemplateException {
		data.put("ClassName", element.getName() + "SourceTargetChange");
		data.put("ModelElementName", element.getName());

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/modules/SourceTargetChangeModule.tpl", project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ChangeModulePackage"));
		templateGen.setData(data);
		templateGen.generateFile();

		changeModuleClasses.add((String) data.get("ChangeModulePackage") + "." + (String) data.get("ClassName"));
	}

	private void generateStyleChangeModule(ModelElement element)
			throws IOException, TemplateException {
		data.put("ClassName", element.getName() + "StyleChange");
		data.put("ModelElementName", element.getName());

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/modules/StyleChangeModule.tpl", project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ChangeModulePackage"));
		templateGen.setData(data);
		templateGen.generateFile();

		changeModuleClasses.add((String) data.get("ChangeModulePackage") + "." + (String) data.get("ClassName"));
	}

	private void generateContainmentChangeModule(ModelElement element)
			throws IOException, TemplateException {
		data.put("ModelElementName", element.getName());
		data.put("ClassName", element.getName() + "ContainmentChange");

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/modules/ContainmentChangeModule.tpl", project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ChangeModulePackage"));
		templateGen.setData(data);
		templateGen.generateFile();

		changeModuleClasses.add((String) data.get("ChangeModulePackage") + "." + (String) data.get("ClassName"));
	}

}
