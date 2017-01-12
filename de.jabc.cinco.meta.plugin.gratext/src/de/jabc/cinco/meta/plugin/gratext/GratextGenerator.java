package de.jabc.cinco.meta.plugin.gratext;

import java.io.IOException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import mgl.GraphModel;
import mgl.Import;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.codegen.ecore.genmodel.GenModel;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;

import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;
import de.jabc.cinco.meta.plugin.gratext.template.SerializerTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.DiagramTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.FormatterTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextEcoreTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextGenmodelTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextGrammarTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextMWETemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextQualifiedNameProviderTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextResourceTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.ModelizerTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.RuntimeModuleTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.ScopeProviderTemplate;

public class GratextGenerator extends ProjectGenerator {
	
	private Map<String,String> genModelURIs = new HashMap<>();
	private Map<String, String> genPackages = new HashMap<>();
	private Set<String> referenced = new HashSet<>();
	
	public GratextGenerator(GraphModel model) {
		this.model = model;
	}
	
	public String getProjectAcronym() {
		return "gratext";
	}
	
	public String getProjectSuffix() {
		return "Gratext";
	}
	
	@Override
	protected void init(Map<String, Object> context) {
		model.getImports().forEach(i -> {
			if (i.getImportURI().endsWith(".mgl")) {
				GraphModel gm = getImportedGraphModel(i);
				String gmName = gm.getName().substring(0, 1).toUpperCase();
				if (gm.getName().length() > 1) {
					gmName += gm.getName().substring(1).toLowerCase();
				}
				
				String genPackage = gm.getPackage() + "." + gmName.toLowerCase() + "." + gmName + "Package";
				genPackages.put(gm.getNsURI(), genPackage);
				
				String genModelUri = "platform:/resource/" + getModelProjectSymbolicName() + "/src-gen/model/" + gm.getName() + ".genmodel";
				genModelURIs.put(gm.getNsURI(), genModelUri);
			}
			if (i.getImportURI().endsWith(".ecore")) {
				GenModel gm = getImportedGenmodel(i);
				gm.getGenPackages().forEach(genPkg -> {
					String genPackage = genPkg.getBasePackage() + "." + genPkg.getEcorePackage().getName() + "." + genPkg.getPrefix() + "Package";
					genPackages.put(genPkg.getNSURI(), genPackage);
					
					String genModelUri = URI.createPlatformResourceURI(
							gm.eResource().getURI().toPlatformString(false), false).toString();
					genModelURIs.put(genPkg.getNSURI(), genModelUri);
				});
			}
		});
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
			
//		inSrcFolder("src")
//			.inPackage(basePkg)
//			.createFile(targetName + ".xtext")
//			.withContent(GratextGrammarTemplate.class);
				
//		inSrcFolder("src")
//			.inPackage(basePkg)
//			.createFile(targetName + ".mwe2")
//			.withContent(GratextMWETemplate.class);
				
//		inSrcFolder("src")
//			.inPackage(basePkg + ".generator")
//			.createFile("GratextGenerator.xtend")
//			.withContent(GratextGeneratorTemplate.class);
		
		inSrcFolder("src")
			.inPackage(basePkg + ".generator")
			.createFile(modelName + "Serializer.xtend")
			.withContent(SerializerTemplate.class);
		
		inSrcFolder("src")
			.inPackage(basePkg + ".generator")
			.createFile(modelName + "Modelizer.xtend")
			.withContent(ModelizerTemplate.class);
		
//		inSrcFolder("src")
//			.inPackage(basePkg + ".scoping")
//			.createFile(targetName + "QualifiedNameProvider.java")
//			.withContent(GratextQualifiedNameProviderTemplate.class);

//		inSrcFolder("src")
//			.inPackage(basePkg + ".scoping")
//			.createFile(targetName + "ScopeProvider.xtend")
//			.withContent(ScopeProviderTemplate.class);
		
//		inSrcFolder("src")
//			.inPackage(basePkg)
//			.createFile(targetName + "RuntimeModule.java")
//			.withContent(RuntimeModuleTemplate.class);

		inSrcFolder("src")
			.inPackage(basePkg)
			.createFile(targetName + "Resource.xtend")
			.withContent(GratextResourceTemplate.class);

		inSrcFolder("src")
			.inPackage(basePkg)
			.createFile(modelName + "Diagram.xtend")
			.withContent(DiagramTemplate.class);
	}
	
	public void proceed() {

		String basePkg = getProjectDescriptor().getBasePackage();
		String targetName = getProjectDescriptor().getTargetName();
		
		IFile file = inSrcFolder("bin")
			.inPackage(basePkg)
			.createFile(targetName + ".xtext")
			.withContent(GratextGrammarTemplate.class);
		
		try {
			file.setDerived(true, null);
		} catch (CoreException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		inSrcFolder("src")
			.inPackage(basePkg)
			.createFile(targetName + ".xtext")
			.withContent(GratextGrammarTemplate.class);
			
		inSrcFolder("src")
			.inPackage(basePkg)
			.createFile(targetName + ".mwe2")
			.withContent(GratextMWETemplate.class);
		
		inSrcFolder("src")
			.inPackage(basePkg + ".scoping")
			.createFile(targetName + "QualifiedNameProvider.java")
			.withContent(GratextQualifiedNameProviderTemplate.class);

		inSrcFolder("src")
			.inPackage(basePkg + ".scoping")
			.createFile(targetName + "ScopeProvider.xtend")
			.withContent(ScopeProviderTemplate.class);

		inSrcFolder("src")
			.inPackage(basePkg + ".formatting")
			.createFile(targetName + "Formatter.xtend")
			.withContent(FormatterTemplate.class);
		
		inSrcFolder("src")
			.inPackage(basePkg)
			.createFile(targetName + "RuntimeModule.java")
			.withContent(RuntimeModuleTemplate.class);
	}

	@Override
	protected List<String> getNatures() {
		return list(
			"org.eclipse.pde.PluginNature",
			"org.eclipse.xtext.ui.shared.xtextNature"
		);
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
	protected List<String> getExportedPackages() {
		return list(
			getProjectDescriptor().getBasePackage() + ".generator"
		);
	}

	@Override
	protected List<String> getManifestExtensions() {
		return list(/* none */);
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
		return list(/* none */);
	}

	@Override
	protected Set<String> getRequiredBundles() {
		return set(
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
				"org.eclipse.graphiti",
				"org.eclipse.graphiti.ui",
				"org.antlr.runtime",
				"org.apache.commons.logging",
				"de.jabc.cinco.meta.core.mgl.model",
				"de.jabc.cinco.meta.core.ge.style.generator.runtime",
				"de.jabc.cinco.meta.core.ge.style.model",
				"de.jabc.cinco.meta.core.utils",
				"de.jabc.cinco.meta.plugin.gratext.runtime"
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

	public String getGenModelURI(String nsURI) {
		return genModelURIs.get(nsURI);
	}
	
	public String getGenPackage(String nsURI) {
		return genPackages.get(nsURI);
	}
	
	public boolean addGenPackageReference(String nsURI) {
		return referenced.add(nsURI);
	}
	
	public Set<String> getGenPackageReferences() {
		return referenced;
	}
	
	private GenModel getImportedGenmodel(Import i) {
		URI genModelURI = URI.createURI(new Path(i.getImportURI()).removeFileExtension().addFileExtension("genmodel").toString());
		Resource res = new ResourceSetImpl().getResource(genModelURI, true);
		if (res != null) try {
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
}
