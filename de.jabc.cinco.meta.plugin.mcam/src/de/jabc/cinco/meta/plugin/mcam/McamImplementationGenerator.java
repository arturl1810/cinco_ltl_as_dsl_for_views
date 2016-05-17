package de.jabc.cinco.meta.plugin.mcam;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.eclipse.core.resources.IProject;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EcorePackage;

import freemarker.template.TemplateException;
import mgl.Annotation;
import mgl.Attribute;
import mgl.Edge;
import mgl.GraphModel;
import mgl.GraphicalElementContainment;
import mgl.IncomingEdgeElementConnection;
import mgl.ModelElement;
import mgl.Node;
import mgl.NodeContainer;
import mgl.OutgoingEdgeElementConnection;
import mgl.Type;

public class McamImplementationGenerator {

	public static String mcamPackageSuffix = "mcam";

	public static String adapterPackageSuffix = "adapter";
	public static String cliPackageSuffix = "cli";
	public static String modulesPackageSuffix = "modules";
	public static String changeModulesPackageSuffix = "changes";
	public static String checkModulesPackageSuffix = "checks";

	private GraphModel gModel = null;
	private String graphModelName = null;

	private IProject mcamProject = null;
	private String mcamProjectBasePackage = null;
	private String graphModelProjectName = null;
	private String graphModelPackage = null;

	private ArrayList<String> changeModuleClasses = new ArrayList<>();
	private ArrayList<String> checkModuleClasses = new ArrayList<>();
	private String customMergeStrategy = "";

	public Map<String, Object> data = new HashMap<>();

	private boolean generateMerge = false;
	private boolean generateCheck = false;

	private ArrayList<HashMap<String, Object>> modelLabels = new ArrayList<>();
	private HashMap<ModelElement, ArrayList<Attribute>> entityAttributes = new HashMap<>();
	private HashMap<String, ArrayList<String>> typeNames = new HashMap<>();
	private HashMap<ModelElement, ModelElement> extendsMap = new HashMap<>();

	public McamImplementationGenerator(GraphModel gModel, IProject project,
			String graphModelPackage, String graphModelProjectName) {
		super();
		this.gModel = gModel;
		this.graphModelName = gModel.getName();
		this.graphModelPackage = graphModelPackage;
		this.graphModelProjectName = graphModelProjectName;

		this.mcamProject = project;
		this.mcamProjectBasePackage = graphModelPackage + "."
				+ mcamPackageSuffix;

		parseAnnotations();

		initEntityMaps();

		data.put("GraphModelName", this.graphModelName);
		data.put("GraphModelProjectName", this.graphModelProjectName);
		data.put("GraphModelExtension", this.gModel.getFileExtension());
		data.put("GraphModelPackage", this.graphModelPackage);

		data.put("AdapterPackage", this.mcamProjectBasePackage + "."
				+ adapterPackageSuffix);
		data.put("ChangeModulePackage", this.mcamProjectBasePackage + "."
				+ modulesPackageSuffix + "." + changeModulesPackageSuffix);
		data.put("CheckModulePackage", this.mcamProjectBasePackage + "."
				+ modulesPackageSuffix + "." + checkModulesPackageSuffix);
		data.put("CliPackage", this.mcamProjectBasePackage + "."
				+ cliPackageSuffix);

		data.put("ChangeModules", this.changeModuleClasses);
		data.put("CheckModules", this.checkModuleClasses);

		data.put("CustomMergeStrategy", this.customMergeStrategy);
		data.put("MergeStrategyClass", this.graphModelName + "MergeStrategy");

		data.put("ModelLabels", this.modelLabels);

		data.put("ContainerTypes", this.typeNames.get("Container"));
		data.put("NodeTypes", this.typeNames.get("Node"));
		data.put("EdgeTypes", this.typeNames.get("Edge"));
	}

	public IProject getProject() {
		return mcamProject;
	}

	public String getMcamProjectBasePackage() {
		return mcamProjectBasePackage;
	}

	public boolean doGenerateMerge() {
		return generateMerge;
	}

	public boolean doGenerateCheck() {
		return generateCheck;
	}

	private void initEntityMaps() {
		entityAttributes.put(gModel, new ArrayList<Attribute>());
		typeNames.put("GraphModel", new ArrayList<String>());
		typeNames.get("GraphModel").add(gModel.getName());
		for (Attribute attribute : gModel.getAttributes()) {
			entityAttributes.get(gModel).add(attribute);
		}

		typeNames.put("Node", new ArrayList<String>());
		for (Node node : gModel.getNodes()) {
			if (node.getExtends() != null)
				extendsMap.put(node, node.getExtends());
			typeNames.get("Node").add(node.getName());
			entityAttributes.put(node, new ArrayList<Attribute>());
			for (Attribute attribute : node.getAttributes()) {
				entityAttributes.get(node).add(attribute);
			}
		}

		typeNames.put("Edge", new ArrayList<String>());
		for (Edge edge : gModel.getEdges()) {
			if (edge.getExtends() != null)
				extendsMap.put(edge, edge.getExtends());
			typeNames.get("Edge").add(edge.getName());
			entityAttributes.put(edge, new ArrayList<Attribute>());
			for (Attribute attribute : edge.getAttributes()) {
				entityAttributes.get(edge).add(attribute);
			}
		}

		typeNames.put("Container", new ArrayList<String>());
		for (Node n : gModel.getNodes()) {
			if (!(n instanceof NodeContainer))
				continue;
			NodeContainer container = (NodeContainer) n;
			if (container.getExtends() != null)
				extendsMap.put(container, container.getExtends());
			typeNames.get("Container").add(container.getName());
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

				if (element.isIsAbstract())
					continue;

				if (generateMerge) {
					data.put("ModelElementType", "GraphModel");
					if (!(element instanceof GraphModel)) {

						if (element instanceof Edge) {
							data.put("ModelElementType", "Edge");
							generateAddEdgeChangeModule((Edge) element);
							generateDeleteEdgeChangeModule((Edge) element);
							generateSourceTargetChangeModule((Edge) element);
						}
						if (element instanceof Node) {
							data.put("ModelElementType", "Node");
							generateAddElementChangeModule(element);
							generateDeleteElementChangeModule(element);
							generateMoveResizeElementChangeModule(element);
						}
						if (element instanceof NodeContainer) {
							data.put("ModelElementType", "Container");
							generateAddElementChangeModule(element);
							generateDeleteElementChangeModule(element);
							generateMoveResizeElementChangeModule(element);
						}

					}

					ModelElement elementToGen = element;
					while (elementToGen != null) {
						for (Attribute attribute : entityAttributes
								.get(elementToGen)) {
							generateAttributeChangeModule(element, attribute);
						}
						elementToGen = extendsMap.get(elementToGen);
					}
				}
			}

			generateEntityId();
			generateModelAdapter();
			generateCliExecution();

			return "default";
		} catch (IOException | TemplateException e) {
			e.printStackTrace();
		}
		return "error";
	}

	private void parseAnnotations() {
		for (Annotation annotation : gModel.getAnnotations()) {
			if ("mcam".equals(annotation.getName())) {
				List<String> values = annotation.getValue();
				if (values.size() == 0 || values.contains("check"))
					generateCheck = true;
				if (values.size() == 0 || values.contains("merge"))
					generateMerge = true;
			}
			if ("mcam_changemodule".equals(annotation.getName()))
				changeModuleClasses.add(annotation.getValue().get(0));
			if ("mcam_checkmodule".equals(annotation.getName()))
				checkModuleClasses.add(annotation.getValue().get(0));
			if ("mcam_mergestrategy".equals(annotation.getName()))
				customMergeStrategy = annotation.getValue().get(0);
		}
	}

	private void addLabelEntry(ModelElement element) {
		ModelElement elementToLabel = element;
		boolean labelFound = false;
		while (element != null) {
			for (Attribute attribute : element.getAttributes()) {
				for (Annotation annotation : attribute.getAnnotations()) {
					if ("mcam_label".equals(annotation.getName())) {
						HashMap<String, Object> labelEntry = new HashMap<>();
						labelEntry.put("type", elementToLabel.getName());
						labelEntry.put("attribute", attribute.getName());
						labelEntry.put("isModelElement",
								(getModelElementType(attribute) != null));
						modelLabels.add(labelEntry);
						labelFound = true;
					}
				}
			}
			if (labelFound)
				break;
			element = extendsMap.get(element);
		}
	}

	private ModelElement getModelElementType(Attribute attribute) {
		for (ModelElement element : entityAttributes.keySet()) {
			if (attribute.getType().equals(element.getName()))
				return element;
		}
		return null;
	}

	private Type getEnumType(Attribute attribute) {
		for (Type type : gModel.getTypes()) {
			if (attribute.getType().equals(type.getName()))
				return type;
		}

		return null;
	}

	private Set<ModelElement> getPossibleContainer(ModelElement element) {
		HashSet<ModelElement> possibleContainer = new HashSet<>();

		for (Node n : gModel.getNodes()) {
			if (!(n instanceof NodeContainer))
				continue;
			NodeContainer container = (NodeContainer) n;
			for (GraphicalElementContainment gec : container
					.getContainableElements()) {
				if (gec.eCrossReferences().size() > 0) {
					for (EObject eObj : gec.eCrossReferences()) {
						if (element.getName().equals(
								((ModelElement) eObj).getName())) {
							possibleContainer.add(container);
						}
					}
				} else {
					possibleContainer.add(container);
				}
			}
		}
		return possibleContainer;
	}

	private Set<ModelElement> getPossibleEdgeTargets(ModelElement element) {
		HashSet<ModelElement> possibleSources = new HashSet<>();

		for (Node node : gModel.getNodes()) {
			for (IncomingEdgeElementConnection incEdge : node
					.getIncomingEdgeConnections()) {
				if (incEdge.eCrossReferences().size() > 0) {
					for (EObject eObj : incEdge.eCrossReferences()) {
						if (element.getName().equals(
								((ModelElement) eObj).getName())) {
							possibleSources.add(node);
						}
					}
				} else {
					possibleSources.add(node);
				}

			}
		}

		for (Node n : gModel.getNodes()) {
			if (!(n instanceof NodeContainer))
				continue;
			NodeContainer container = (NodeContainer) n;
			for (IncomingEdgeElementConnection incEdge : container
					.getIncomingEdgeConnections()) {
				if (incEdge.eCrossReferences().size() > 0) {
					for (EObject eObj : incEdge.eCrossReferences()) {
						if (element.getName().equals(
								((ModelElement) eObj).getName())) {
							possibleSources.add(container);
						}
					}
				} else {
					possibleSources.add(container);
				}

			}
		}

		return possibleSources;
	}

	private Set<ModelElement> getPossibleEdgeSources(ModelElement element) {
		HashSet<ModelElement> possibleTargets = new HashSet<>();

		for (Node node : gModel.getNodes()) {
			for (OutgoingEdgeElementConnection outEdge : node
					.getOutgoingEdgeConnections()) {
				if (outEdge.eCrossReferences().size() > 0) {
					for (EObject eObj : outEdge.eCrossReferences()) {
						if (element.getName().equals(
								((ModelElement) eObj).getName())) {
							possibleTargets.add(node);
						}
					}
				} else {
					possibleTargets.add(node);
				}

			}
		}

		for (Node n : gModel.getNodes()) {
			if (!(n instanceof NodeContainer))
				continue;
			NodeContainer container = (NodeContainer) n;
			for (OutgoingEdgeElementConnection outEdge : container
					.getOutgoingEdgeConnections()) {
				if (outEdge.eCrossReferences().size() > 0) {
					for (EObject eObj : outEdge.eCrossReferences()) {
						if (element.getName().equals(
								((ModelElement) eObj).getName())) {
							possibleTargets.add(container);
						}
					}
				} else {
					possibleTargets.add(container);
				}

			}
		}

		return possibleTargets;
	}

	private void generateEntityId() throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/adapter/EntityId.tpl", mcamProject);
		templateGen.setFilename(graphModelName + "Id.java");
		templateGen.setPkg((String) data.get("AdapterPackage"));
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generateModelAdapter() throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/adapter/ModelAdapter.tpl", mcamProject);
		templateGen.setFilename(graphModelName + "Adapter.java");
		templateGen.setPkg((String) data.get("AdapterPackage"));
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generateCliExecution() throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/cli/CliMain.tpl", mcamProject);
		templateGen.setFilename("CliMain.java");
		templateGen.setPkg((String) data.get("CliPackage"));
		templateGen.setData(data);
		templateGen.generateFile();

		templateGen = new TemplateGenerator("templates/cli/CliExecution.tpl",
				mcamProject);
		templateGen.setFilename("CliExecution.java");
		templateGen.setPkg((String) data.get("CliPackage"));
		templateGen.setData(data);
		templateGen.generateFile();

		templateGen = new TemplateGenerator(
				"templates/cli/FrameworkExecution.tpl", mcamProject);
		templateGen.setFilename(graphModelName + "Execution.java");
		templateGen.setPkg((String) data.get("CliPackage"));
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

		if (getModelElementType(attribute) != null) {
			data.put("AttributeCategory", "ModelElement");
			data.put("AttributeType", data.get("GraphModelPackage") + "."
					+ attribute.getType().toString());
		} else if (getEnumType(attribute) != null) {
			data.put("AttributeCategory", "Enum");
			data.put("AttributeType", data.get("GraphModelPackage") + "."
					+ getEnumType(attribute).getName());
		} else {
			data.put("AttributeCategory", "Normal");
			data.put("AttributeType",
					EcorePackage.eINSTANCE.getEClassifier(attribute.getType())
							.getInstanceClass().getName());
		}

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/modules/AttributeChangeModule.tpl", mcamProject);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ChangeModulePackage"));
		templateGen.setData(data);
		templateGen.generateFile();

		changeModuleClasses.add((String) data.get("ChangeModulePackage") + "."
				+ (String) data.get("ClassName"));
	}

	private void generateAddElementChangeModule(ModelElement element)
			throws IOException, TemplateException {
		data.put("ClassName", element.getName() + "AddChange");
		data.put("ModelElementName", element.getName());
		data.put("PossibleContainer", getPossibleContainer(element));

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/modules/AddElementModule.tpl", mcamProject);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ChangeModulePackage"));
		templateGen.setData(data);
		templateGen.generateFile();

		changeModuleClasses.add((String) data.get("ChangeModulePackage") + "."
				+ (String) data.get("ClassName"));
	}

	private void generateDeleteElementChangeModule(ModelElement element)
			throws IOException, TemplateException {
		data.put("ClassName", element.getName() + "DeleteChange");
		data.put("ModelElementName", element.getName());
		data.put("PossibleContainer", getPossibleContainer(element));

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/modules/DeleteElementModule.tpl", mcamProject);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ChangeModulePackage"));
		templateGen.setData(data);
		templateGen.generateFile();

		changeModuleClasses.add((String) data.get("ChangeModulePackage") + "."
				+ (String) data.get("ClassName"));
	}

	private void generateDeleteEdgeChangeModule(Edge element)
			throws IOException, TemplateException {
		data.put("ClassName", element.getName() + "DeleteChange");
		data.put("ModelElementName", element.getName());
		data.put("PossibleEdgeSources", getPossibleEdgeSources(element));
		data.put("PossibleEdgeTargets", getPossibleEdgeTargets(element));

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/modules/DeleteEdgeModule.tpl", mcamProject);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ChangeModulePackage"));
		templateGen.setData(data);
		templateGen.generateFile();

		changeModuleClasses.add((String) data.get("ChangeModulePackage") + "."
				+ (String) data.get("ClassName"));
	}

	private void generateAddEdgeChangeModule(Edge element) throws IOException,
			TemplateException {
		data.put("ClassName", element.getName() + "AddChange");
		data.put("ModelElementName", element.getName());
		data.put("PossibleEdgeSources", getPossibleEdgeSources(element));
		data.put("PossibleEdgeTargets", getPossibleEdgeTargets(element));

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/modules/AddEdgeModule.tpl", mcamProject);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ChangeModulePackage"));
		templateGen.setData(data);
		templateGen.generateFile();

		changeModuleClasses.add((String) data.get("ChangeModulePackage") + "."
				+ (String) data.get("ClassName"));
	}

	private void generateSourceTargetChangeModule(Edge element)
			throws IOException, TemplateException {
		data.put("ClassName", element.getName() + "SourceTargetChange");
		data.put("ModelElementName", element.getName());
		data.put("PossibleEdgeSources", getPossibleEdgeSources(element));
		data.put("PossibleEdgeTargets", getPossibleEdgeTargets(element));

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/modules/SourceTargetChangeModule.tpl", mcamProject);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ChangeModulePackage"));
		templateGen.setData(data);
		templateGen.generateFile();

		changeModuleClasses.add((String) data.get("ChangeModulePackage") + "."
				+ (String) data.get("ClassName"));
	}

	private void generateMoveResizeElementChangeModule(ModelElement element)
			throws IOException, TemplateException {
		data.put("ClassName", element.getName() + "MoveResizeChange");
		data.put("ModelElementName", element.getName());
		data.put("PossibleContainer", getPossibleContainer(element));

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/modules/MoveResizeElementModule.tpl", mcamProject);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ChangeModulePackage"));
		templateGen.setData(data);
		templateGen.generateFile();

		changeModuleClasses.add((String) data.get("ChangeModulePackage") + "."
				+ (String) data.get("ClassName"));
	}

}
