package de.jabc.cinco.meta.plugin.gratext;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import mgl.GraphModel;
import mgl.GraphicalModelElement;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.codegen.ecore.generator.Generator;
import org.eclipse.emf.codegen.ecore.genmodel.GenModel;
import org.eclipse.emf.codegen.ecore.genmodel.GenPackage;
import org.eclipse.emf.codegen.ecore.genmodel.generator.GenBaseGeneratorAdapter;
import org.eclipse.emf.codegen.ecore.genmodel.impl.GenPackageImpl;
import org.eclipse.emf.common.util.BasicMonitor;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;

import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;
import de.jabc.cinco.meta.plugin.gratext.descriptor.GraphModelDescriptor;
import de.jabc.cinco.meta.plugin.gratext.descriptor.ProjectDescriptor;
import de.jabc.cinco.meta.plugin.gratext.template.BackupActionTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.BackupGeneratorTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextEcoreTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextGeneratorTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextGenmodelTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextGrammarTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextMWETemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextQualifiedNameProviderTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.ModelGeneratorTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.PluginXmlTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.RestoreActionTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.RuntimeModuleTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.ScopeProviderTemplate;

public class GratextProjectGenerator extends ProjectGenerator {

	private static final String PROJECT_ACRONYM = "gratext";
	private static final String PROJECT_SUFFIX = "Gratext";
	private final String GRAPHICAL_GRAPH_MODEL_PATH = "/de.jabc.cinco.meta.core.ge.style.model/"
													+ "model/"
													+ "GraphicalGraphModel.genmodel";
	
	private GraphModel model;
	
	@Override
	protected void init(Map<String, Object> context) {
		model = (GraphModel) context.get("graphModel");
		initGenModelFiles();
	}
	
	protected void initGenModelFiles() {
		getFiles("genmodel").forEach(f -> { try {
//			System.out.println("GenModelFile: " + f.getFullPath()); // /info.scce.dime/src-gen/model/Search.genmodel
			Resource res = new ResourceSetImpl().getResource(
				URI.createPlatformResourceURI(f.getFullPath().toOSString(), true), true);
			res.load(null);
			for (EObject content : res.getContents()) {	
				if (content instanceof GenModel) {
					final GenModel genModel = (GenModel) content;
//					System.out.println(" > modelName: " + genModel.getModelName()); // Search
//					System.out.println(" > modelDir: " + genModel.getModelDirectory()); // /info.scce.dime/src-gen
					genModel.getGenPackages().forEach(p -> {
//						System.out.println(" > genPackage: " + p);
//						System.out.println("   > nsURI: " + p.getNSURI()); // http://dime.scce.info/search
//						System.out.println("   > prefix: " + p.getPrefix()); // Search
//						System.out.println("   > basePackage: " + p.getBasePackage()); // info.scce.dime.search
//						System.out.println("   > ecore.name: " + p.getEcorePackage().getName()); // search
						genModelFiles.put(p.getNSURI(), f);
						genModels.put(p.getNSURI(), genModel);
						genPackages.put(p.getNSURI(), p);
					});
				}
			}
		} catch(Exception e) {
			e.printStackTrace();
		}});
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
		
//		generateGenModelCode(getFileDescriptor(GratextGenmodelTemplate.class).resource());
		
			
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
	
	protected void generateGenModelCode(IFile genModelFile) {
		try {
			
			Resource res = new ResourceSetImpl().getResource(
					URI.createPlatformResourceURI(genModelFile.getFullPath().toOSString(), true),true);
			res.load(null);
			GenModel genModel = null;
			for (EObject content : res.getContents()) {	
				if (content instanceof GenModel) {
					genModel = (GenModel) content;
					for (GenPackage gm : new ArrayList<>(genModel.getUsedGenPackages())) {
						if (!gm.getGenModel().equals(genModel)) {
							GenPackage pkg = getGenPackage(gm.getNSURI());
							if (pkg != null) {
								System.out.println("Push UsedGenPackage: " + pkg);
								genModel.getUsedGenPackages().add(pkg);
							}
						}
					}
					Resource absGraphmodelGenModel = new ResourceSetImpl().getResource(
							URI.createPlatformPluginURI(GRAPHICAL_GRAPH_MODEL_PATH , true), true);
					for (EObject o : absGraphmodelGenModel.getContents()) {
						if (o instanceof GenModel)
							genModel.getUsedGenPackages().addAll(((GenModel) o).getGenPackages());
					}
//					System.out.println(genModel.getUsedGenPackages());
					genModel.setCanGenerate(true);
					genModel.reconcile();
					Generator generator = new Generator();
					generator.setInput(genModel);
					generator.generate(genModel, GenBaseGeneratorAdapter.MODEL_PROJECT_TYPE, BasicMonitor.toMonitor(getProgressMonitor()));
				}
			}
			
//			IResource iRes = ResourcesPlugin.getWorkspace().getRoot()
//					.getProject(getModelProjectSymbolicName()).getFile("/src-gen/model/" + getModelDescriptor().getName() + ".genmodel");
//			if (iRes.exists()) {
//				Resource modelGenModel = new ResourceSetImpl().getResource(
//							URI.createFileURI(iRes.getLocation().toOSString()), true );
//				for (EObject content : modelGenModel.getContents()) {
//					if (content instanceof GenModel)
//						genModel.getUsedGenPackages().addAll(((GenModel) content).getGenPackages());
//				}
//			}
			
			
			
			
		} catch(Exception e) {
			e.printStackTrace();
//			throw new GenerationException("Failed to generate model code from genmodel file " + genModelFile, e);
		}
	}
	
	@Override
	protected void createFiles(FileCreator creator) {
		String basePkg = getProjectDescriptor().getBasePackage();
		String targetName = getProjectDescriptor().getTargetName();
		String modelName = getModelDescriptor().getName();
		
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
				
//		creator.inSrcFolder("src")
//			.inPackage(basePkg + ".generator")
//			.createFile(targetName + "Generator.xtend")
//			.withContent(ModelGeneratorTemplate.class, this);
		
		creator.inSrcFolder("src")
			.inPackage(basePkg + ".generator")
			.createFile("GratextGenerator.xtend")
			.withContent(GratextGeneratorTemplate.class, this);
		
		creator.inSrcFolder("src")
			.inPackage(basePkg + ".generator")
			.createFile(modelName + "BackupGenerator.xtend")
			.withContent(BackupGeneratorTemplate.class, this);
		
		creator.inSrcFolder("src")
			.inPackage(basePkg + ".generator")
			.createFile("BackupAction.java")
			.withContent(BackupActionTemplate.class, this);
		
		creator.inSrcFolder("src")
			.inPackage(basePkg + ".generator")
			.createFile(modelName + "ModelGenerator.xtend")
			.withContent(ModelGeneratorTemplate.class, this);
		
		creator.inSrcFolder("src")
			.inPackage(basePkg + ".generator")
			.createFile("RestoreAction.java")
			.withContent(RestoreActionTemplate.class, this);
		
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
		
		creator.createFile("plugin.xml")
			.withContent(PluginXmlTemplate.class, this);
		
		
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
			"xtend-gen",
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
	
	
	public IProject getModelProject() {
		return ResourcesPlugin.getWorkspace().getRoot().findMember(
				new Path(model.eResource().getURI().toPlatformString(true))).getProject();
	}
	
	public String getModelProjectSymbolicName() {
		IResource res = ResourcesPlugin.getWorkspace().getRoot().findMember(
				new Path(model.eResource().getURI().toPlatformString(true)));
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
			"org.eclipse.emf.transaction",
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
	
	private Map<String,IFile> genModelFiles = new HashMap<>();
	
	public IFile getGenModelFile(String nsURI) {
		return genModelFiles.get(nsURI);
	}
	
	private Map<String,GenModel> genModels = new HashMap<>();
	
	public GenModel getGenModel(String nsURI) {
		//System.out.println("Get GenModel " + nsURI + " = " + genModels.get(nsURI));
		return genModels.get(nsURI);
	}
	
	Map<String, GenPackage> genPackages = new HashMap<>();
	
	public GenPackage getGenPackage(String nsURI) {
		//System.out.println("Get GenPackage " + nsURI + " = " + genPackages.get(nsURI));
		return genPackages.get(nsURI);
	}
	
	private Set<String> referenced = new HashSet<>();
	
	public Set<String> getGenPackageReferences() {
		return referenced;
	}
	
	public boolean isReferenced(String nsURI) {
		return referenced.contains(nsURI);
	}
	
	public boolean addGenPackageReference(String nsURI) {
		//System.out.println("Referenced package " + nsURI);
		return referenced.add(nsURI);
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
	
	
}
