package de.jabc.cinco.meta.plugin.gratext;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import mgl.GraphModel;
import mgl.GraphicalElementContainment;
import mgl.GraphicalModelElement;
import mgl.NodeContainer;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.codegen.ecore.generator.Generator;
import org.eclipse.emf.codegen.ecore.generator.GeneratorAdapterFactory;
import org.eclipse.emf.codegen.ecore.genmodel.GenModel;
import org.eclipse.emf.codegen.ecore.genmodel.GenModelPackage;
import org.eclipse.emf.codegen.ecore.genmodel.generator.GenBaseGeneratorAdapter;
import org.eclipse.emf.codegen.ecore.genmodel.generator.GenModelGeneratorAdapter;
import org.eclipse.emf.codegen.ecore.genmodel.generator.GenModelGeneratorAdapterFactory;
import org.eclipse.emf.common.util.BasicMonitor;
import org.eclipse.emf.common.util.Diagnostic;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.xmi.impl.EcoreResourceFactoryImpl;

import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;
import de.jabc.cinco.meta.plugin.gratext.descriptor.GraphModelDescriptor;
import de.jabc.cinco.meta.plugin.gratext.descriptor.ProjectDescriptor;
import de.jabc.cinco.meta.plugin.gratext.template.GratextEcoreTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextGenmodelTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextGrammarTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextMWETemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextQualifiedNameProviderTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.ModelGeneratorTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.RuntimeModuleTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.ScopeProviderTemplate;

public class GratextProjectGenerator extends ProjectGenerator {

	private static final String PROJECT_ACRONYM = "gratext";
	private static final String PROJECT_SUFFIX = "Gratext";
	
	private GraphModel model;
	
	@Override
	protected void init(Map<String, Object> context) {
		System.out.println("Execute Gratext Plugin:");
		model = (GraphModel) context.get("graphModel");
//		printGraphModel(); // debug only
	}
	
	@Override
	public void execute(Map<String, Object> context) {
		super.execute(context);
		
		new EmptyProjectGenerator(getSymbolicName() + ".ui"  ) {
			@Override protected List<String> getSourceFolders() {
				return list("src", "src-gen", "xtend-gen");
			};
			@Override protected Set<String> getRequiredBundles() {
				return new HashSet<>(list(
					getProjectDescriptor().getBasePackage()));
			};
			@Override protected List<String> getNatures() {
				return list(
					"org.eclipse.pde.PluginNature",
					"org.eclipse.xtext.ui.shared.xtextNature"
				);
			}
			@Override protected java.util.List<String> getManifestExtensions() {
				return list("Bundle-ActivationPolicy: lazy");
			};
		}.execute(context);
		
		
//		generateModelCode();
		
//		new EmptyProjectGenerator(getSymbolicName() + ".tests") {
//			@Override protected List<String> getSourceFolders() {
//				return list("src-gen");
//			};
//			@Override protected Set<String> getRequiredBundles() {
//				return new HashSet<>(list("com.google.inject"));
//			};
//		}.execute(context);
//		new EmptyProjectGenerator(getSymbolicName() + ".sdk" ).execute(context);
	}
	
	protected void generateModelCode() {
		System.out.println("Generating model code...");
		IFile genModelFile = getFileDescriptor(GratextGenmodelTemplate.class).resource();
		URI uri = URI.createPlatformResourceURI(genModelFile.getFullPath().toString(), true);
		
		ResourceSet set = new ResourceSetImpl();
		EcoreResourceFactoryImpl ecoreFactory = new EcoreResourceFactoryImpl();
		Resource.Factory.Registry registry = set.getResourceFactoryRegistry();
		Map<String, Object> map = registry.getExtensionToFactoryMap();
		map.put("ecore", ecoreFactory);
		map.put("genmodel", ecoreFactory);

		GenModelPackage.eINSTANCE.eClass();

		Resource res = set.getResource(uri, true);
		try {
			res.load(new HashMap<>());
		} catch (IOException e) {}

		GenModel genModel = null;
		TreeIterator<EObject> list = res.getAllContents();
		while (list.hasNext()) {
			EObject obj = list.next();
			if (obj instanceof GenModel) {
				genModel = (GenModel) obj;
				break;
			}
		}
		genModel.reconcile();
		genModel.setCanGenerate(true);
		
		GeneratorAdapterFactory.Descriptor.Registry.INSTANCE.addDescriptor(GenModelPackage.eNS_URI, GenModelGeneratorAdapterFactory.DESCRIPTOR);
		Generator generator = new Generator();
		generator.setInput(genModel);
		generator.requestInitialize();
		Diagnostic d = generator.generate(genModel, GenBaseGeneratorAdapter.MODEL_PROJECT_TYPE, new BasicMonitor());
		System.out.println("Code generation done: " + d.getMessage());
		
		
//		GeneratorAdapterFactory factory = GenModelGeneratorAdapterFactory.DESCRIPTOR.createAdapterFactory();
//		GenModelGeneratorAdapter adapter = new GenModelGeneratorAdapter(factory);
//		adapter.generate(genModel, GenModelGeneratorAdapter.MODEL_PROJECT_TYPE, new BasicMonitor());
	}
	
	@Override
	protected void createFiles(FileCreator creator) {
		String basePkg = getProjectDescriptor().getBasePackage();
		String targetName = getProjectDescriptor().getTargetName();
		
		creator.inSrcFolder("model")
			.inPackage(basePkg)
			.createFile(targetName + ".ecore")
			.withContent(GratextEcoreTemplate.class, this);
		
		creator.inSrcFolder("model")
			.inPackage(basePkg)
			.createFile(targetName + ".genmodel")
			.withContent(GratextGenmodelTemplate.class, this);
			
		creator.inSrcFolder("src")
			.inPackage(basePkg)
			.createFile(targetName + ".xtext")
			.withContent(GratextGrammarTemplate.class, this);
				
		creator.inSrcFolder("src")
			.inPackage(basePkg)
			.createFile(targetName + ".mwe2")
			.withContent(GratextMWETemplate.class, this);
				
		creator.inSrcFolder("src")
			.inPackage(basePkg + ".generator")
			.createFile(targetName + "Generator.xtend")
			.withContent(ModelGeneratorTemplate.class, this);
		
		creator.inSrcFolder("src")
			.inPackage(basePkg + ".scoping")
			.createFile(targetName + "QualifiedNameProvider.java")
			.withContent(GratextQualifiedNameProviderTemplate.class, this);

		creator.inSrcFolder("src")
			.inPackage(basePkg + ".scoping")
			.createFile(targetName + "ScopeProvider.xtend")
			.withContent(ScopeProviderTemplate.class, this);
		
		
		creator.inSrcFolder("src")
			.inPackage(basePkg)
			.createFile(targetName + "RuntimeModule.java")
			.withContent(RuntimeModuleTemplate.class, this);
	
	}
	
	@Override
	protected List<String> getBuildPropertiesBinIncludes() {
		return list(
			"src/",
			"src-gen/",
			"plugin.xml"
		);
	}
	
	@Override
	protected List<String> getSourceFolders() {
		return list(
			"src",
			"src-gen",
			"model"
		);
	}
	
	@Override
	protected Map<String, String> getPackages() {
		String basePkg = getProjectDescriptor().getBasePackage();
		Map<String, String> map = new HashMap<>();
		map.put("src", basePkg);
		map.put("model", basePkg);
		map.put("model", basePkg + ".generator");
		return map;
	}
	
//	@Override
//	protected SrcFile[] getSourceFiles(String srcFolder, String pkg) {
//		switch(srcFolder) {
//		case "src": switch(pkg) {
//			case "": return new SrcFile[] {
//					new SrcFile(getModelDescriptor().getName() + "Gratext.xtext", GratextEcoreTemplate.class),
//					new SrcFile(getModelDescriptor().getName() + "GratextGenerator.mwe2", GratextMWETemplate.class),
//				};
//			case "generator": return new SrcFile[] {
//					new SrcFile(getModelDescriptor().getName() + "ModelGenerator.xtend", ModelGeneratorTemplate.class),
//				};
//		}
//		case "model": switch(pkg) {
//			case "": return new SrcFile[] {
//					new SrcFile("Gratext.ecore", GratextEcoreTemplate.class),
//					new SrcFile("Gratext.genmodel", GratextGenmodelTemplate.class),
//				};
//		}}
//		return new SrcFile[]{};
//	}
	
	@Override
	protected List<IProject> getReferencedProjects() {
		return Arrays.asList(new IProject[] {
				// none
		});
	}
	
	@Override
	protected String getSymbolicName() {
		return getProjectDescriptor().getSymbolicName();
	}
	
	
	public String getModelProjectSymbolicName() {
		IResource res = ResourcesPlugin.getWorkspace().getRoot().findMember(
				new Path(getModelDescriptor().instance().eResource().getURI().toPlatformString(true)));
		return (res != null)
				? ProjectCreator.getProjectSymbolicName(res.getProject())
				: model.getPackage();
	}
	
	@Override
	protected Set<String> getRequiredBundles() {
		return new HashSet<String>(Arrays.asList(new String[] {
			getModelProjectSymbolicName(),
			"org.eclipse.ui",
			"org.eclipse.ui.navigator",
			"org.eclipse.swt",
			"org.eclipse.core.runtime",
			"org.eclipse.core.resources",
			"org.eclipse.emf.common",
			"org.eclipse.emf.ecore",
			"org.eclipse.emf.codegen.ecore",
			"org.eclipse.emf.mwe.utils",
			"org.eclipse.emf.mwe2.launch",
			"org.eclipse.xtext",
			"org.eclipse.xtext.generator",
			"org.eclipse.xtext.util",
			"org.eclipse.xtext.xbase",
			"org.eclipse.xtext.xbase.lib",
			"org.eclipse.xtext.common.types",
			"org.eclipse.graphiti.ui",
			"org.antlr.runtime",
			"org.apache.commons.logging",
			"de.jabc.cinco.meta.core.mgl.model"
		}));
	}
	
	@Override
	protected List<String> getExportedPackages() {
		return list();
	}
	
	@Override
	protected List<String> getNatures() {
		return list(
			"org.eclipse.pde.PluginNature",
			"org.eclipse.xtext.ui.shared.xtextNature"
		);
	}
	
	@Override
	protected List<String> getManifestExtensions() {
		return null;
	}
	
	private GraphModelDescriptor modelDesc;
	
	public GraphModelDescriptor getModelDescriptor() {
		if (model == null) {
			model = (GraphModel) getContext().get("graphModel");
		}
		if (modelDesc == null) {
			modelDesc = new GraphModelDescriptor(model);
			modelDesc.setBasePackage(model.getPackage());
		}
		return modelDesc;
	}
	
	private ProjectDescriptor projectDesc;
	
	public ProjectDescriptor getProjectDescriptor() {
		String basePkg = getModelDescriptor().getBasePackage() + "." + PROJECT_ACRONYM;
		if (projectDesc == null || (projectDesc.instance() == null && project != null)) {
			projectDesc = new ProjectDescriptor(project)
				.setSymbolicName(basePkg)
				.setTargetName(getModelDescriptor().getName() + PROJECT_SUFFIX);
			projectDesc.setBasePackage(basePkg)
				.setAcronym(PROJECT_ACRONYM);
		}
		return projectDesc;
	}
	
	class ContainmentDescriptor {
		
		List<GraphicalModelElement> types;
		int lower;
		int upper;

		public ContainmentDescriptor(List<GraphicalModelElement> types, int lower, int upper) {
			this.types = types;
			this.lower = lower;
			this.upper = upper;
		}
	}
		
	void printGraphModel() {
		GraphModel graphModel = (GraphModel) ctx.get("graphModel");
		printContainer(graphModel);
		graphModel.getNodes().stream().filter(NodeContainer.class::isInstance).forEach(node -> {
			printContainer((NodeContainer) node);
		});
		
		Map<?,?> modelElements = (Map<?,?>) ctx.get("modelElements");
		System.out.println(" > ModelElements: " + ((modelElements != null) ? modelElements.getClass().getSimpleName() : "null"));
		
		modelElements.entrySet().stream().forEach(entry -> System.out.println("   > " + entry.getKey() + " = " + entry.getValue()));
		
		EPackage ePackage = (EPackage) ctx.get("ePackage");
		System.out.println(" > ePackage: " + ((ePackage != null) ? ePackage.getClass().getSimpleName() : "null"));
	}

	void printContainer(NodeContainer container) {
		System.out.println(" > " + container.getName());
		EList<GraphicalElementContainment> containables = container.getContainableElements();
		if (containables.isEmpty())
			System.out.println("   > Containable: NONE");
		else containables.stream().forEach(c -> {
			EList<GraphicalModelElement> types = c.getTypes();
			if (types.isEmpty())
				System.out.println("   > Containable: ALL");
			else {
				System.out.print("   > Containable: ");
				types.stream().forEach(t -> System.out.print(t.getName() + " "));
				System.out.println("["
					+ (c.getLowerBound() == -1 ? "*" : c.getLowerBound()) + ","
					+ (c.getUpperBound() == -1 ? "*" : c.getUpperBound()) + "]");
				new ContainmentDescriptor(new ArrayList<>(types), c.getLowerBound(), c.getLowerBound());
			};
		});
	}
	
	void printContainer(GraphModel model) {
		System.out.println(" > " + model.getName());
		EList<GraphicalElementContainment> containables = model.getContainableElements();
		if (containables.isEmpty())
			System.out.println("   > Containable: ALL");
		else containables.stream().forEach(c -> {
			System.out.println("   > Containable: " + c);
			EList<GraphicalModelElement> types = c.getTypes();
			if (types.isEmpty())
				System.out.println("     > ALL");
			else {
				System.out.print("     > ");
				types.stream().forEach(t -> System.out.print(t.getName() + " "));
				System.out.println("["
					+ (c.getLowerBound() == -1 ? "*" : c.getLowerBound()) + ","
					+ (c.getUpperBound() == -1 ? "*" : c.getUpperBound()) + "]");
			};
		});
	}
	
	
}
