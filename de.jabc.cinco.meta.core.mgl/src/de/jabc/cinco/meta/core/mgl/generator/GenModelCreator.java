package de.jabc.cinco.meta.core.mgl.generator;

import java.util.Collections;

import  org.eclipse.core.runtime.IPath;
import org.eclipse.emf.codegen.ecore.genmodel.GenJDKLevel;
import org.eclipse.emf.codegen.ecore.genmodel.GenModel;
import org.eclipse.emf.codegen.ecore.genmodel.GenModelFactory;
import org.eclipse.emf.codegen.ecore.genmodel.GenPackage;
import org.eclipse.emf.codegen.ecore.genmodel.GenRuntimeVersion;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.importer.ecore.EcoreImporter;

public class GenModelCreator {	
	public static GenModel createGenModel(IPath ecorePath,EPackage ePackage,String projectName,IPath projectPath){
		IPath genModelPath = ecorePath.removeFileExtension().addFileExtension("genmodel");
		URI genModelURI = URI.createURI(genModelPath.toString());
		Resource genModelResource =
                Resource.Factory.Registry.INSTANCE.getFactory(genModelURI).createResource(genModelURI); 
		GenModel genModel = GenModelFactory.eINSTANCE.createGenModel(); 
		genModelResource.getContents().add(genModel);
        ResourceSet resourceSet = new ResourceSetImpl(); 
        resourceSet.getResources().add(genModelResource);
        System.out.println(projectPath);
        genModel.setModelDirectory("/"+projectPath.append("src-gen").toPortableString());
        genModel.getForeignModel().add("platform:/resource/"+projectPath.append("src-gen/model").addTrailingSeparator().toPortableString()+ecorePath.lastSegment());
        //genModel.getForeignModel().add("platform:/plugin/de.jabc.cinco.meta.core.mgl/model/GraphModel.ecore");
        
        genModel.initialize(Collections.singleton(ePackage));
        GenPackage genPackage = (GenPackage)genModel.getGenPackages().get(0);
        genModel.setModelName(genModelURI.trimFileExtension().lastSegment());
        String s = ePackage.getNsPrefix();
        s = Character.toUpperCase(s.charAt(0)) + s.substring(1); 
        genPackage.setPrefix(s);
        genModel.setRuntimeVersion(GenRuntimeVersion.EMF28);
        genModel.setComplianceLevel(GenJDKLevel.JDK70_LITERAL);
        genModel.setModelPluginID(projectName);
        genModel.setEditPluginID(projectName+".edit");
        genModel.setEditorPluginID(projectName+".editor");
        genModel.setTestsPluginID(projectName+".tests");
        genModel.setCanGenerate(true);
        //genModel.getUsedGenPackages().addAll(genModel.computeMissingUsedGenPackages());

        
		return genModel;
	}
}
