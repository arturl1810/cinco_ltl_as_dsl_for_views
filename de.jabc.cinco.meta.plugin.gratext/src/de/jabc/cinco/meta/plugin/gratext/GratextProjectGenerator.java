package de.jabc.cinco.meta.plugin.gratext;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import mgl.GraphModel;
import mgl.GraphicalModelElement;
import mgl.Import;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.codegen.ecore.genmodel.GenModel;
import org.eclipse.emf.codegen.ecore.genmodel.GenPackage;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;

import de.jabc.cinco.meta.core.utils.CincoUtils;
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;
import de.jabc.cinco.meta.plugin.gratext.descriptor.GraphModelDescriptor;
import de.jabc.cinco.meta.plugin.gratext.descriptor.ProjectDescriptor;
import de.jabc.cinco.meta.plugin.gratext.template.BackupGeneratorTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.DiagramTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextEcoreTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextEditorTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextGeneratorTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextGenmodelTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextGrammarTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextMWETemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextQualifiedNameProviderTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextResourceTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.ModelGeneratorTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.PageAwareDiagramEditorTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.RuntimeModuleTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.ScopeProviderTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.UiPluginXmlTemplate;
import de.jabc.cinco.meta.plugin.gratext.util.ModelDescriptorRegistry;

public class GratextProjectGenerator extends ProjectGenerator {

	private static final String PROJECT_ACRONYM = "gratext";
	private static final String PROJECT_SUFFIX = "Gratext";
	
	private GraphModel model;
	
	@Override
	protected void init(Map<String, Object> context) {
		model = (GraphModel) context.get("graphModel");
		System.out.println("[GratextGen] model: " + model.getName());
		collectImports();
//		initGenModelFiles();
	}
	
	private void collectImports() {
		for (String ext : CincoUtils.getUsedExtensions(model)) {
			System.out.println("[GratextGen]  > ext: " + ext);
		}
		
		
		model.getImports().forEach(i -> {
			System.out.println("[GratextGen]  > import: " + i.getImportURI());
			if (i.getImportURI().endsWith(".mgl")) {
				GraphModel gm = getImportedGraphModel(i);
				
				String gmName = gm.getName().substring(0, 1).toUpperCase();
				if (gm.getName().length() > 1) {
					gmName += gm.getName().substring(1).toLowerCase();
				}
				
				String genPackage = gm.getPackage() + "." + gmName.toLowerCase() + "." + gmName + "Package";
				System.out.println("[GratextGen]    > model.genPkg: " + genPackage);
				genPackages.put(gm.getNsURI(), genPackage);

				System.out.println("[GratextGen]    > model.nsUri: " + gm.getNsURI());
				
				String genModelUri = "platform:/resource/" + getModelProjectSymbolicName() + "/src-gen/model/" + gm.getName() + ".genmodel";
				genModelURIs.put(gm.getNsURI(), genModelUri);
				System.out.println("[GratextGen]    > model.genModel: " + genModelUri);
				
//				genModels.put(gm.getNsURI(), uri);
				
				
			}
			if (i.getImportURI().endsWith(".ecore")) {
				GenModel gm = getImportedGenmodel(i);
				
//				gm.getUsedGenPackages().forEach(genPkg -> {
//					System.out.println("[GratextGen]      > usedGenPkg: " + genPkg);
//					System.out.println("[GratextGen]      > usedGenPkg.nsUri: " + genPkg.getNSURI());
//				});
				gm.getGenPackages().forEach(genPkg -> {
					String genPackage = genPkg.getBasePackage() + "." + genPkg.getEcorePackage().getName() + "." + genPkg.getPrefix() + "Package";
					System.out.println("[GratextGen]    > genPkg: " + genPackage);
					genPackages.put(genPkg.getNSURI(), genPackage);
					
					System.out.println("[GratextGen]    > genPkg.nsUri: " + genPkg.getNSURI());
					
					String genModelUri = gm.eResource().getURI().toString();
					System.out.println("[GratextGen]    > genPkg.genModel: " + genModelUri);
					genModelURIs.put(genPkg.getNSURI(), genModelUri);
				});
			}
		});
	}
	
	private GenModel getImportedGenmodel(Import i) {
		
//		URI genModelURI = URI.createURI(
//				FilenameUtils.removeExtension(i.getImportURI()).concat(".genmodel"));
//		System.out.println("[GratextGen] imported GenModel: " + genModelURI);
		
		URI genModelURI = URI.createURI(new Path(i.getImportURI()).removeFileExtension().addFileExtension("genmodel").toOSString());
		System.out.println("[GratextGen] imported GenModel: " + genModelURI);
		
		Resource res = new ResourceSetImpl().getResource(genModelURI, true);
		if (res != null)
			try {
				res.load(null);
				EObject genModel = res.getContents().get(0);
				if (genModel instanceof GenModel)
					return (GenModel) genModel;
			} catch (IOException e) {
				e.printStackTrace();
			}
		return null;
	}

	private GraphModel getImportedGraphModel(Import i) {
		URI gmURI = URI.createURI(i.getImportURI(), true);
		Resource res = new ResourceSetImpl().getResource(gmURI, true);
		EObject graphModel = res.getContents().get(0);
		if (graphModel instanceof GraphModel)
			return (GraphModel) graphModel;
		return null;
	}
	
//	private void listUsedEcoreModels(Map<String, Object> context) {
//		
//		HashMap<EPackage, String> genModelMap = PluginRegistry.getInstance().getGenModelMap();
//		for (Entry<EPackage, String> entry : genModelMap.entrySet()) {
//			System.out.println("[GratextGen] genmodel: " + entry.getKey() + " => " + entry.getValue());
//		}
//		@SuppressWarnings("unchecked")
//		Set<EPackage> pkgs = (Set<EPackage>) context.get("usedEcoreModels");
//		if (pkgs != null) for (EPackage pkg : pkgs) {
//			XMIResourceImpl res = new XMIResourceImpl(URI.createURI(genModelMap.get(pkg)));
//			try {
//				res.load(null);
//				res.getAllContents().forEachRemaining(c -> {
//					if (c instanceof GenPackage) {
//						String path = ((GenPackage) c).eResource().getURI().trimFileExtension().toString() + ".genmodel";
//						System.out.println("[GratextGen] used genmodel: " + path);
//					}
//				});
//			} catch (IOException e) {
//				e.printStackTrace();
//			}
//		}
//	}
//	
//	private void listUsedGenModels(Map<String, Object> context) {
//		@SuppressWarnings("unchecked")
//		Set<EPackage> pkgs = (Set<EPackage>) context.get("referencedMGLEPackages");
//		if (pkgs != null) for (EPackage pkg : pkgs) {
//			String path = pkg.eResource().getURI().trimFileExtension().toString() + ".genmodel";
//			System.out.println("[GratextGen] referenced genmodel: " + path);
//		}
//	}
	
//	protected void initGenModelFiles() {
//		getWorkspaceFiles("genmodel").forEach(f -> { try {
//			Resource res = new ResourceSetImpl().getResource(
//				URI.createPlatformResourceURI(f.getFullPath().toOSString(), true), true);
//			res.load(null);
//			for (EObject content : res.getContents()) {	
//				if (content instanceof GenModel) {
//					final GenModel genModel = (GenModel) content;
//					genModel.getGenPackages().forEach(p -> {
//						genModelFiles.put(p.getNSURI(), f);
//						genModels.put(p.getNSURI(), genModel);
//						genPackages.put(p.getNSURI(), p);
//					});
//				}
//			}
//		} catch(Exception e) {
//			e.printStackTrace();
//		}});
//	}

	@Override
	public IProject execute(Map<String, Object> context) {
		IProject project = super.execute(context);
		
		String basePkg = getProjectDescriptor().getBasePackage();
		String targetName = getProjectDescriptor().getTargetName();
		String modelName = getModelDescriptor().getName();
		
		final GraphModelDescriptor desc = getModelDescriptor();
		
//		new EmptyProjectGenerator(getSymbolicName() + ".ui"  ) {
//			public GraphModelDescriptor getModelDescriptor() {
//				return desc;
//			};
//			@Override protected List<String> getSourceFolders() {
//				return list("src", "src-gen", "xtend-gen");
//			};
//			@Override protected Set<String> getRequiredBundles() {
//				return new HashSet<>(list(
//					basePkg,
//					"de.jabc.cinco.meta.plugin.gratext.runtime"
//				));
//			};
//			@Override protected List<String> getNatures() {
//				return list(
//					"org.eclipse.pde.PluginNature",
//					"org.eclipse.xtext.ui.shared.xtextNature"
//				);
//			}
//			@Override protected java.util.List<String> getManifestExtensions() {
//				return list("Bundle-ActivationPolicy: lazy\n"
//						+ "Import-Package: org.apache.log4j,\n"
//						+ " org.eclipse.emf.common.util,\n"
//						+ " org.eclipse.emf.ecore.resource,\n"
//						+ " org.eclipse.emf.edit.domain,\n"
//						+ " org.eclipse.emf.transaction,\n"
//						+ " org.eclipse.emf.transaction.impl,\n"
//						+ " org.eclipse.emf.transaction.util,\n"
//						+ " org.eclipse.gef,\n"
//						+ " org.eclipse.graphiti.ui.editor;version=\"0.11.2\",\n"
//						+ " org.eclipse.ui.editors.text,\n"
//						+ " org.eclipse.ui.ide,\n"
//						+ " org.eclipse.ui.part,\n"
//						+ " org.eclipse.ui.views.properties.tabbed,\n"
//						+ " org.eclipse.xtext.ui.editor"
//				);
//			}
//			
//			@Override protected List<String> getBuildPropertiesBinIncludes() {
//				return list("plugin.xml");
//			}
//			
//			@Override protected void createFiles() {
//				inSrcFolder("src")
//					.inPackage(basePkg + ".ui")
//					.createFile(targetName + "Editor.java")
//					.withContent(GratextEditorTemplate.class);
//
//				inSrcFolder("src")
//					.inPackage(basePkg + ".ui")
//					.createFile("PageAware" + modelName + "DiagramEditor.java")
//					.withContent(PageAwareDiagramEditorTemplate.class);
//				
//				createFile("plugin.xml")
//					.withContent(UiPluginXmlTemplate.class);
//			}
//			
//		}.execute(context);
		
//		String actionProjectName = getModelProjectSymbolicName() + ".gratext.action";
//		IProject gratextProject = ResourcesPlugin.getWorkspace().getRoot().getProject(actionProjectName);
//		try {
//			gratextProject.delete(true, true, null);
//		} catch (CoreException e) {
//			e.printStackTrace();
//		}
//		
//		new EmptyProjectGenerator(actionProjectName) {
////			@Override protected List<String> getSourceFolders() {
////				return list("src-gen");
////			};
//			@Override protected Set<String> getRequiredBundles() {
//				return new HashSet<>(list(
//						 "org.eclipse.core.runtime",
//						 "org.eclipse.core.resources",
//						 "org.eclipse.e4.core.di",
//						 "org.eclipse.ui",
//						 "de.jabc.cinco.meta.core.utils",
//						 "de.jabc.cinco.meta.plugin.gratext.runtime"
//					));
//			};
//			@Override protected List<String> getNatures() {
//				return list(
//					"org.eclipse.pde.PluginNature"
//				);
//			}
//			@Override protected java.util.List<String> getManifestExtensions() {
//				return list("Bundle-ActivationPolicy: lazy");
//			};
//			
////			@Override protected java.util.List<String> getExportedPackages() {
////				return list("info.scce.cinco.gratext");
////			};
//			
//			@Override protected List<String> getBuildPropertiesBinIncludes() {
//				return list("plugin.xml");
//			}
//			
//			@Override protected void createFiles() {
//				inSrcFolder("schema")
//					.createFile("info.scce.cinco.gratext.backup.exsd")
//					.withContent(GratextBackupSchemaTemplate.class);
//				
//				inSrcFolder("schema")
//					.createFile("info.scce.cinco.gratext.restore.exsd")
//					.withContent(GratextRestoreSchemaTemplate.class);
//				
//				createFile("plugin.xml")
//					.withContent(GratextPluginXmlTemplate.class);
//				
//			};
//		}.execute(context);
		
		return project;
	}
	
	@Override
	protected void createFiles() {
		String basePkg = getProjectDescriptor().getBasePackage();
		String targetName = getProjectDescriptor().getTargetName();
		String modelName = getModelDescriptor().getName();
		
		inSrcFolder("model")
			.inPackage(basePkg)
			.createFile(targetName + ".ecore")
			.withContent(GratextEcoreTemplate.class);
		
		inSrcFolder("model")
			.inPackage(basePkg)
			.createFile(targetName + ".genmodel")
			.withContent(GratextGenmodelTemplate.class);
			
		inSrcFolder("src")
			.inPackage(basePkg)
			.createFile(targetName + ".xtext")
			.withContent(GratextGrammarTemplate.class);
				
		inSrcFolder("src")
			.inPackage(basePkg)
			.createFile(targetName + ".mwe2")
			.withContent(GratextMWETemplate.class);
				
		inSrcFolder("src")
			.inPackage(basePkg + ".generator")
			.createFile("GratextGenerator.xtend")
			.withContent(GratextGeneratorTemplate.class);
		
		inSrcFolder("src")
			.inPackage(basePkg + ".generator")
			.createFile(modelName + "BackupGenerator.xtend")
			.withContent(BackupGeneratorTemplate.class);
		
//		inSrcFolder("src")
//			.inPackage(basePkg + ".generator")
//			.createFile("BackupAction.java")
//			.withContent(BackupActionTemplate.class);
		
		inSrcFolder("src")
			.inPackage(basePkg + ".generator")
			.createFile(modelName + "ModelGenerator.xtend")
			.withContent(ModelGeneratorTemplate.class);
		
//		inSrcFolder("src")
//			.inPackage(basePkg + ".generator")
//			.createFile("RestoreAction.java")
//			.withContent(RestoreActionTemplate.class);
		
		inSrcFolder("src")
			.inPackage(basePkg + ".scoping")
			.createFile(targetName + "QualifiedNameProvider.java")
			.withContent(GratextQualifiedNameProviderTemplate.class);

		inSrcFolder("src")
			.inPackage(basePkg + ".scoping")
			.createFile(targetName + "ScopeProvider.xtend")
			.withContent(ScopeProviderTemplate.class);
		
		inSrcFolder("src")
			.inPackage(basePkg)
			.createFile(targetName + "RuntimeModule.java")
			.withContent(RuntimeModuleTemplate.class);

		inSrcFolder("src")
			.inPackage(basePkg)
			.createFile(targetName + "Resource.xtend")
			.withContent(GratextResourceTemplate.class);

		inSrcFolder("src")
			.inPackage(basePkg)
			.createFile(modelName + "Diagram.xtend")
			.withContent(DiagramTemplate.class);
		
//		createFile("plugin.xml")
//			.withContent(PluginXmlTemplate.class);
	}
	
	@Override
	protected List<String> getBuildPropertiesBinIncludes() {
		return list(
			"plugin.xml",
			"plugin.properties"
		);
	}
	
	@Override
	protected List<String> getDirectoriesToBeCleaned() {
		return null; // means delete project if existent
	}
	
	@Override
	protected List<String> getSourceFolders() {
		return list(
			"src",
			"src-gen",
			"xtend-gen",
			"model",
			"model-gen"
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
			"de.jabc.cinco.meta.core.mgl.model",
			"de.jabc.cinco.meta.core.utils",
			"de.jabc.cinco.meta.plugin.gratext.runtime"
		}));
	}
	
	@Override
	protected List<String> getExportedPackages() {
		return list(
			getProjectDescriptor().getBasePackage() + ".generator"
		);
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
		return list();
	}
	
	private GraphModelDescriptor modelDesc;
	
	public GraphModelDescriptor getModelDescriptor() {
		if (model == null) 
			model = (GraphModel) getContext().get("graphModel");
			
		if (modelDesc == null)
			modelDesc = ModelDescriptorRegistry.INSTANCE.get(model);
		
		if (modelDesc == null) {
			modelDesc = new GraphModelDescriptor(model);
			modelDesc.setBasePackage(model.getPackage());
			ModelDescriptorRegistry.INSTANCE.add(modelDesc);
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
	
	private Map<String,String> genModelURIs = new HashMap<>();
	
	public String getGenModelURI(String nsURI) {
		return genModelURIs.get(nsURI);
	}
	
	Map<String, String> genPackages = new HashMap<>();
	
	public String getGenPackage(String nsURI) {
		return genPackages.get(nsURI);
	}
	
	private Set<String> referenced = new HashSet<>();
	
	public boolean addGenPackageReference(String nsURI) {
		return referenced.add(nsURI);
	}
	
	public Set<String> getGenPackageReferences() {
		return referenced;
	}

	@Override
	public String getProjectAcronym() {
		return PROJECT_ACRONYM;
	}

	@Override
	public String getProjectSuffix() {
		return PROJECT_SUFFIX;
	}
}
