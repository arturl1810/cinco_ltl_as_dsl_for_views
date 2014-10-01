package de.jabc.cinco.meta.core.mgl.generator;

import java.util.ArrayList;

import org.eclipse.core.runtime.IPath;
import org.eclipse.emf.codegen.ecore.genmodel.GenJDKLevel;
import org.eclipse.emf.codegen.ecore.genmodel.GenModel;
import org.eclipse.emf.codegen.ecore.genmodel.GenModelFactory;
import org.eclipse.emf.codegen.ecore.genmodel.GenPackage;
import org.eclipse.emf.codegen.ecore.genmodel.GenRuntimeVersion;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.Resource;

public class GenModelCreator {	
	public static GenModel createGenModel(IPath ecorePath,EPackage ePackage,String projectName, String projectID, IPath projectPath){
		IPath genModelPath = ecorePath.removeFileExtension().addFileExtension("genmodel");
		URI genModelURI = URI.createURI(genModelPath.toString());
		Resource genModelResource =
                Resource.Factory.Registry.INSTANCE.getFactory(genModelURI).createResource(genModelURI); 
		GenModel genModel = GenModelFactory.eINSTANCE.createGenModel(); 
		genModelResource.getContents().add(genModel);
        genModel.setModelDirectory("/"+projectPath.append("src-gen").toPortableString());
        
        ArrayList<EPackage> ePackageList = new ArrayList<>();
        ePackageList.add(ePackage);
        genModel.initialize(ePackageList);
        GenPackage genPackage = (GenPackage)genModel.getGenPackages().get(0);
        genModel.setModelName(genModelURI.trimFileExtension().lastSegment());
        String s = ePackage.getNsPrefix();
        s = Character.toUpperCase(s.charAt(0)) + s.substring(1); 
        genPackage.setPrefix(s);
        genModel.setRuntimeVersion(GenRuntimeVersion.EMF28);
        genModel.setComplianceLevel(GenJDKLevel.JDK70_LITERAL);
        genModel.setModelPluginID(projectID);
        genModel.setEditPluginID(projectID+".edit");
        genModel.setEditorPluginID(projectID+".editor");
        genModel.setTestsPluginID(projectID+".tests");
        genModel.setCanGenerate(true);
        
		return genModel;
	}

}
