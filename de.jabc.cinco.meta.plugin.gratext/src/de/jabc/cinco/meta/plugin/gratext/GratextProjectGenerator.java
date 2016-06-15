package de.jabc.cinco.meta.plugin.gratext;

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
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.codegen.ecore.genmodel.GenModel;
import org.eclipse.emf.codegen.ecore.genmodel.GenPackage;
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
import de.jabc.cinco.meta.plugin.gratext.template.GratextEditorTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextGeneratorTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextGenmodelTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextGrammarTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextMWETemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextQualifiedNameProviderTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextResourceTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.ModelGeneratorTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.PageAwareDiagramEditorTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.PluginXmlTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.RestoreActionTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.RuntimeModuleTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.ScopeProviderTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.UiPluginXmlTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.action.GratextBackupSchemaTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.action.GratextPluginXmlTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.action.GratextRestoreSchemaTemplate;

public class GratextProjectGenerator extends ProjectGenerator {

	private static final String PROJECT_ACRONYM = "gratext";
	private static final String PROJECT_SUFFIX = "Gratext";
	
	private GraphModel model;
	
	@Override
	protected void init(Map<String, Object> context) {
		model = (GraphModel) context.get("graphModel");
		initGenModelFiles();
	}
	
	protected void initGenModelFiles() {
		getWorkspaceFiles("genmodel").forEach(f -> { try {
			Resource res = new ResourceSetImpl().getResource(
				URI.createPlatformResourceURI(f.getFullPath().toOSString(), true), true);
			res.load(null);
			for (EObject content : res.getContents()) {	
				if (content instanceof GenModel) {
					final GenModel genModel = (GenModel) content;
					genModel.getGenPackages().forEach(p -> {
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
	public IProject execute(Map<String, Object> context) {
		IProject project = super.execute(context);
		
		String basePkg = getProjectDescriptor().getBasePackage();
		String targetName = getProjectDescriptor().getTargetName();
		String modelName = getModelDescriptor().getName();
		
		final GraphModelDescriptor desc = getModelDescriptor();
		
		new EmptyProjectGenerator(getSymbolicName() + ".ui"  ) {
			public GraphModelDescriptor getModelDescriptor() {
				return desc;
			};
			@Override protected List<String> getSourceFolders() {
				return list("src", "src-gen", "xtend-gen");
			};
			@Override protected Set<String> getRequiredBundles() {
				return new HashSet<>(list(
					basePkg,
					"de.jabc.cinco.meta.plugin.gratext.runtime"
				));
			};
			@Override protected List<String> getNatures() {
				return list(
					"org.eclipse.pde.PluginNature",
					"org.eclipse.xtext.ui.shared.xtextNature"
				);
			}
			@Override protected java.util.List<String> getManifestExtensions() {
				return list("Bundle-ActivationPolicy: lazy\n"
						+ "Import-Package: org.apache.log4j,\n"
						+ " org.eclipse.emf.common.util,\n"
						+ " org.eclipse.emf.ecore.resource,\n"
						+ " org.eclipse.emf.edit.domain,\n"
						+ " org.eclipse.emf.transaction,\n"
						+ " org.eclipse.emf.transaction.impl,\n"
						+ " org.eclipse.emf.transaction.util,\n"
						+ " org.eclipse.gef,\n"
						+ " org.eclipse.graphiti.ui.editor;version=\"0.11.2\",\n"
						+ " org.eclipse.ui.editors.text,\n"
						+ " org.eclipse.ui.ide,\n"
						+ " org.eclipse.ui.part,\n"
						+ " org.eclipse.ui.views.properties.tabbed,\n"
						+ " org.eclipse.xtext.ui.editor"
				);
			}
			
			@Override protected List<String> getBuildPropertiesBinIncludes() {
				return list("plugin.xml");
			}
			
			@Override protected void createFiles() {
				inSrcFolder("src")
					.inPackage(basePkg + ".ui")
					.createFile(targetName + "Editor.java")
					.withContent(GratextEditorTemplate.class);

				inSrcFolder("src")
					.inPackage(basePkg + ".ui")
					.createFile("PageAware" + modelName + "DiagramEditor.java")
					.withContent(PageAwareDiagramEditorTemplate.class);
				
				createFile("plugin.xml")
					.withContent(UiPluginXmlTemplate.class);
			}
			
		}.execute(context);
		
		String actionProjectName = getModelProjectSymbolicName() + ".gratext.action";
		IProject gratextProject = ResourcesPlugin.getWorkspace().getRoot().getProject(actionProjectName);
		try {
			gratextProject.delete(true, true, null);
		} catch (CoreException e) {
			e.printStackTrace();
		}
		
		new EmptyProjectGenerator(actionProjectName) {
//			@Override protected List<String> getSourceFolders() {
//				return list("src-gen");
//			};
			@Override protected Set<String> getRequiredBundles() {
				return new HashSet<>(list(
						 "org.eclipse.core.runtime",
						 "org.eclipse.core.resources",
						 "org.eclipse.e4.core.di",
						 "org.eclipse.ui",
						 "de.jabc.cinco.meta.core.utils",
						 "de.jabc.cinco.meta.plugin.gratext.runtime"
					));
			};
			@Override protected List<String> getNatures() {
				return list(
					"org.eclipse.pde.PluginNature"
				);
			}
			@Override protected java.util.List<String> getManifestExtensions() {
				return list("Bundle-ActivationPolicy: lazy");
			};
			
//			@Override protected java.util.List<String> getExportedPackages() {
//				return list("info.scce.cinco.gratext");
//			};
			
			@Override protected List<String> getBuildPropertiesBinIncludes() {
				return list("plugin.xml");
			}
			
			@Override protected void createFiles() {
				inSrcFolder("schema")
					.createFile("info.scce.cinco.gratext.backup.exsd")
					.withContent(GratextBackupSchemaTemplate.class);
				
				inSrcFolder("schema")
					.createFile("info.scce.cinco.gratext.restore.exsd")
					.withContent(GratextRestoreSchemaTemplate.class);
				
				createFile("plugin.xml")
					.withContent(GratextPluginXmlTemplate.class);
				
			};
		}.execute(context);
		
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
		
		inSrcFolder("src")
			.inPackage(basePkg + ".generator")
			.createFile("BackupAction.java")
			.withContent(BackupActionTemplate.class);
		
		inSrcFolder("src")
			.inPackage(basePkg + ".generator")
			.createFile(modelName + "ModelGenerator.xtend")
			.withContent(ModelGeneratorTemplate.class);
		
		inSrcFolder("src")
			.inPackage(basePkg + ".generator")
			.createFile("RestoreAction.java")
			.withContent(RestoreActionTemplate.class);
		
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
		
		createFile("plugin.xml")
			.withContent(PluginXmlTemplate.class);
	}
	
	@Override
	protected List<String> getBuildPropertiesBinIncludes() {
		return list(
			"plugin.xml",
			"plugin.properties"
		);
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
		return genModels.get(nsURI);
	}
	
	Map<String, GenPackage> genPackages = new HashMap<>();
	
	public GenPackage getGenPackage(String nsURI) {
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
