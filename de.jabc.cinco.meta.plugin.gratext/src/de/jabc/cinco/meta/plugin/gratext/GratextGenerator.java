package de.jabc.cinco.meta.plugin.gratext;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.codegen.ecore.genmodel.GenModel;
import org.eclipse.emf.codegen.ecore.genmodel.GenPackage;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.util.EcoreUtil;

import de.jabc.cinco.meta.core.utils.CincoUtil;
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;
import de.jabc.cinco.meta.plugin.gratext.template.AstFactoryTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.FormatterTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextEcoreTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextGenmodelTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextGrammarTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextMWETemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextResourceTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.InternalPackageTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.LinkingServiceTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.RuntimeModuleTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.ScopeProviderTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.TransformerTemplate;
import mgl.GraphModel;
import mgl.Import;

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
				GraphModel gm = CincoUtil.getImportedGraphModel(i);
				String gmName = gm.getName().substring(0, 1).toUpperCase();
				if (gm.getName().length() > 1) {
					gmName += gm.getName().substring(1).toLowerCase();
				}
				String genPackage = createGenPackageName(gm.getPackage(), gmName.toLowerCase(), gmName + "Package");
				genPackages.put(gm.getNsURI(), genPackage);
				String genModelUri = "platform:/resource/" + getModelProjectSymbolicName() + "/src-gen/model/" + gm.getName() + ".genmodel";
				genModelURIs.put(gm.getNsURI(), genModelUri);
			}
			if (i.getImportURI().endsWith(".ecore")) {
				GenModel gm = CincoUtil.getImportedGenmodel(i);
				String genModelUri = URI.createPlatformResourceURI(gm.eResource().getURI().toPlatformString(false), false).toString();
				gm.getGenPackages().forEach(genPkg -> {
					String name = getName(genPkg);
					String genPackage = createGenPackageName(genPkg.getBasePackage(), name, genPkg.getPrefix() + "Package");
					String nsURI = getNSURI(genPkg, i);
					
					genPackages.put(nsURI, genPackage);
					genModelURIs.put(nsURI, genModelUri);
				});
			}
		});
	}
	
	private String createGenPackageName(String basePkg, String pkgSuffix, String pkgName) {
		String name = (basePkg != null) ? (basePkg + ".") : "";
		name += (pkgSuffix != null) ? pkgSuffix + "." : "";
		return name + pkgName;
	}
	
	private String getName(GenPackage genPkg) {
		String name = genPkg.getEcorePackage().getName();
		if (name == null)
			name = genPkg.getPrefix().toLowerCase();
		return name;
	}
	
	private String getNSURI(GenPackage genPkg, Import i) {
		if (genPkg.getNSURI() != null)
			return genPkg.getNSURI();
		if (i.getImportURI().endsWith(".ecore")) {
			URI uri = URI.createURI(i.getImportURI());
			Resource res = CincoUtil.getResource(uri.toString(), i.eResource());
			TreeIterator<Object> contents = EcoreUtil.getAllContents(res, true);
			while (contents.hasNext()) {
				Object content = contents.next();
				if (content instanceof EPackage) {
					if (((EPackage) content).getName().equals(getName(genPkg))) {
						return ((EPackage) content).getNsURI();
					}
				}
			};
		}
		if (i.getImportURI().endsWith(".mgl")) {
			GraphModel gm = CincoUtil.getImportedGraphModel(i);
			return gm.getNsURI();
		}
		return null;
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
			.inPackage(basePkg + ".generator")
			.createFile(modelName + "GratextTransformer.xtend")
			.withContent(TransformerTemplate.class);
		
		inSrcFolder("src")
			.inPackage(basePkg)
			.createFile(targetName + "Resource.xtend")
			.withContent(GratextResourceTemplate.class);
		
		inSrcFolder("src")
		.inPackage("internal")
		.createFile("InternalPackage.xtend")
		.withContent(InternalPackageTemplate.class);
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
		
		inSrcFolder("src")
			.inPackage(basePkg)
			.createFile(targetName + "AstFactory.java")
			.withContent(AstFactoryTemplate.class);
		
		inSrcFolder("src")
			.inPackage(basePkg)
			.createFile(targetName + "LinkingService.java")
			.withContent(LinkingServiceTemplate.class);
		
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
				"org.antlr.runtime",
				"org.apache.commons.logging",
				"de.jabc.cinco.meta.core.mgl.model",
				"de.jabc.cinco.meta.core.ui",
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
}
