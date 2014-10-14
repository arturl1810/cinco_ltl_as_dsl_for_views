package de.jabc.cinco.meta.core.utils;

import java.io.IOException;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.emf.codegen.ecore.generator.Generator;
import org.eclipse.emf.codegen.ecore.genmodel.GenModel;
import org.eclipse.emf.codegen.ecore.genmodel.GenPackage;
import org.eclipse.emf.codegen.ecore.genmodel.generator.GenBaseGeneratorAdapter;
import org.eclipse.emf.common.util.BasicMonitor;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;

public class GeneratorHelper {
	public static void generateGenModelCode(IFile mglModelFile) throws IOException {
		String modelName = (mglModelFile.getName().endsWith(".mgl")) 
				? mglModelFile.getName().split("\\.")[0] 
				: mglModelFile.getName();
				
		IProject project = mglModelFile.getProject();
		IFile genModelFile = project.getFile("src-gen/model/" + modelName +".genmodel");
		
		if (!genModelFile.exists())
			throw new IOException("The file: " + modelName+".genmodel does not exist");
		
		Resource res = new ResourceSetImpl().getResource(
				URI.createPlatformResourceURI(genModelFile.getFullPath().toOSString(), true),true);
		for (EObject o : res.getContents()) {	
			if (o instanceof GenModel) {
				GenModel genModel = (GenModel) o;
				for (GenPackage gm : genModel.getUsedGenPackages()) {
					if (!gm.getGenModel().equals(genModel)) {
						genModel.getUsedGenPackages().add(gm);
					}
				}
//				genModel.getUsedGenPackages().addAll(getUsedGenPackages());
				System.out.println(genModel.getUsedGenPackages());
				genModel.setCanGenerate(true);
				Generator generator = new Generator();
				generator.setInput(genModel);
				generator.generate(genModel, GenBaseGeneratorAdapter.MODEL_PROJECT_TYPE, new BasicMonitor());
			}
		}
	}
}