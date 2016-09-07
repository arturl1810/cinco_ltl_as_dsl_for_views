package de.jabc.cinco.meta.plugin.gratext;

import java.io.IOException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import mgl.GraphModel;
import mgl.Import;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.codegen.ecore.genmodel.GenModel;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;

public class GratextGenerator extends ProjectGenerator {
	
	private Map<String,String> genModelURIs = new HashMap<>();
	private Map<String, String> genPackages = new HashMap<>();
	private Set<String> referenced = new HashSet<>();
	
	public void execute(GraphModel model) {
		this.model = model;
		Map<String, Object> ctx = new HashMap<>();
		ctx.put("graphModel", model);
		super.execute(ctx);
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
		URI genModelURI = URI.createURI(new Path(i.getImportURI()).removeFileExtension().addFileExtension("genmodel").toOSString());
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

	@Override
	protected void createFiles() {
		// TODO Auto-generated method stub
		
	}

	@Override
	protected List<String> getNatures() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	protected String getSymbolicName() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	protected List<String> getBuildPropertiesBinIncludes() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	protected List<String> getExportedPackages() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	protected List<String> getManifestExtensions() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	protected Map<String, String> getPackages() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	protected List<IProject> getReferencedProjects() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	protected Set<String> getRequiredBundles() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	protected List<String> getSourceFolders() {
		// TODO Auto-generated method stub
		return null;
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
