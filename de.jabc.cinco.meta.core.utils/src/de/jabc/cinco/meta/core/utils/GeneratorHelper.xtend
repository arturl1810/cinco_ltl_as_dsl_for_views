package de.jabc.cinco.meta.core.utils

import de.jabc.cinco.meta.util.xapi.FileExtension
import de.jabc.cinco.meta.util.xapi.ResourceExtension
import java.io.IOException
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IProject
import org.eclipse.emf.codegen.ecore.generator.Generator
import org.eclipse.emf.codegen.ecore.genmodel.GenModel
import org.eclipse.emf.codegen.ecore.genmodel.GenPackage
import org.eclipse.emf.codegen.ecore.genmodel.generator.GenBaseGeneratorAdapter
import org.eclipse.emf.codegen.ecore.genmodel.util.GenModelUtil
import org.eclipse.emf.common.util.BasicMonitor
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl

class GeneratorHelper {
	
	
	def static void generateGenModelCode(IProject project, String modelName) throws IOException {
		var IFile genModelFile = project.getFile('''src-gen/model/«modelName».genmodel''')
		if(!genModelFile.exists()) throw new IOException('''The file: «modelName».genmodel does not exist''');
		var ResourceSetImpl resourceSet = new ResourceSetImpl()
		var Resource res = resourceSet.getResource(
			URI.createPlatformResourceURI(genModelFile.getFullPath().toOSString(), true), true)
		res.load(null)
		for (EObject o : res.getContents()) {
			if (o instanceof GenModel) {
				var GenModel genModel = (o as GenModel)
				for (GenPackage gp : genModel.getUsedGenPackages()) {
					
					if (gp.getGenModel != null && !gp.getGenModel().equals(genModel)) {
						genModel.getUsedGenPackages().add(gp)
					}
				}
				generateGenModelCode(genModel)
			}
		}
	}

	/** 
	 * convenience method for {@link #generateGenModelCode(IProject, String)} that extracts
	 * the project and model name from the provided MGL file
	 * @param mglModelFile
	 * @throws IOException
	 */
	def static void generateGenModelCode(IFile mglModelFile) throws IOException {
		var String modelName = if((mglModelFile.getName().endsWith(".mgl"))) mglModelFile.getName().split("\\.").
				get(0) else mglModelFile.getName()
		var IProject project = mglModelFile.getProject()
		generateGenModelCode(project, modelName)
	}

	/** 
	 * Generates Code from previously created/loaded Genmodel
	 * @param genModel
	 */
	def static void generateGenModelCode(GenModel genModel) {
		// Change method and call generateGenModelCode(IProject project, String modelName) throws IOException{
		genModel.setCanGenerate(true)
		var Generator generator = GenModelUtil.createGenerator(genModel)
		generator.generate(genModel, GenBaseGeneratorAdapter.MODEL_PROJECT_TYPE, new BasicMonitor())
	}
}
