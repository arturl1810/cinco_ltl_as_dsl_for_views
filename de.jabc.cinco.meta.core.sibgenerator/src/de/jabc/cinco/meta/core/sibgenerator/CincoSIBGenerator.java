package de.jabc.cinco.meta.core.sibgenerator;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.reflect.InvocationTargetException;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.jdt.core.IClasspathEntry;
import org.eclipse.jdt.core.JavaCore;
import org.eclipse.jface.operation.IRunnableWithProgress;
import org.osgi.framework.Bundle;

import transem.mtsg.WritingSIBGenerator;
import de.metaframe.jabc.framework.sib.parameter.StrictList;
import de.metaframe.jabc.framework.sib.parameter.foundation.StrictListFoundation;
public class CincoSIBGenerator implements IRunnableWithProgress{
	
	private IPath cincoPath;
	private IPath outlet;
	private String packageName;
	private File graphModelFile = null; 
	private File graphitiFile = null;
	private IProject project = null;
	public CincoSIBGenerator(IPath cincoPath,IPath outlet, String packageName,IProject project){
		this.cincoPath = cincoPath;
		this.outlet = outlet;
		this.packageName = packageName;
		this.project = project;
		try {
			String tmpDir = System.getProperty("java.io.tmpdir");
			Bundle mglModelBundle = Platform.getBundle("de.jabc.cinco.meta.core.mgl.model");
			URL fileURL= mglModelBundle.getEntry("/model/GraphModel.ecore");
			System.out.println("***** RESOLVING ***** ");
			graphModelFile = new File(tmpDir+"/GraphModel.ecore");
			System.out.println(fileURL);
			InputStream in = FileLocator.openStream(mglModelBundle, new Path(fileURL.getPath()), true);
			OutputStream out = new FileOutputStream(graphModelFile);
			int b =0;
			while((b=in.read())!=-1){
				out.write(b);
			}
			out.flush();
			out.close();
			System.out.println("***** RESOLVING ***** ");
			Bundle bundle = Platform.getBundle("org.eclipse.graphiti.mm");
			graphitiFile = new File(tmpDir+"/graphiti.ecore");
			fileURL = bundle.getEntry("/model/graphiti.ecore");
			in = FileLocator.openStream(bundle, new Path(fileURL.getPath()), true);
			out = new FileOutputStream(graphitiFile);
			b =0;
			while((b=in.read())!=-1){
				out.write(b);
			}
			out.flush();
			out.close();
			
			
			
		} catch (IOException e) {
			e.printStackTrace();
		}
		
	}
	
	
	private void generateCincoSIBs(){
		
//		LightweightExecutionContext context = new DefaultLightweightExecutionContext(null);
//		context.put("modelPath", this.cincoPath.toFile().getAbsolutePath());
//		context.put("outlet",this.outlet.toFile());
//		context.put("packageName", this.packageName);
//		context.put("iconFile",project.getProjectRelativePath().append("icons").makeAbsolute().toPortableString());
//		context.put("groupId",project.getName());
//         context.put("artifactId", "cinco-sibs");
//         context.put("version", "1.0.0");
//         context.put("createMavenProject",false);
		
		 
		 
		    
		 java.lang.String artifactId = "cinco-sibs";
		  
		 boolean beautify = false;
		 boolean createMavenProject = false;
		 java.io.File genModelPath = this.cincoPath.makeAbsolute().removeFileExtension().addFileExtension("genmodel").toFile();
		 boolean generateCodeForEOperations = true;
		 boolean generateSIBs = true;
		 java.lang.String groupId = project.getName();;
		 java.io.File iconFile = project.getProjectRelativePath().append("icons").makeAbsolute().toFile();
		 java.lang.String identifierPrefix = "";
		 java.io.File modelPath = this.cincoPath.makeAbsolute().toFile();
		 java.lang.String outlet = this.outlet.makeAbsolute().toPortableString();
		 java.lang.String packageName = this.packageName;
		 java.lang.String version = "1.0.0";
		 ArrayList<File> list = new ArrayList<>();
		 list.add(graphModelFile);
		 list.add(graphitiFile);
		 StrictList<File> strictList = new StrictList<>(list, File.class);
		 StrictListFoundation<File> additionalEcoreFiles =strictList.asFoundation();
		 boolean sameFolderForResources = true;
		WritingSIBGenerator sibGenerator = new WritingSIBGenerator(additionalEcoreFiles , artifactId, beautify, createMavenProject, genModelPath, generateCodeForEOperations, generateSIBs, groupId, iconFile, identifierPrefix, modelPath, outlet, packageName, sameFolderForResources, version);
		 
		
		
		
		
		try{
		String result = sibGenerator.execute(new HashMap<String,Object>());
		if(result.equals("error")){
			System.out.println("CINCO SIB Generation exited with ERROR");
		}
			
		System.out.println("FINISHED CINCO SIB Generation");
		}catch(Exception e){
			e.printStackTrace();
			
		}
	}

	@Override
	public void run(IProgressMonitor monitor) throws InvocationTargetException,
			InterruptedException {
		if(!monitor.isCanceled())
			monitor.beginTask("Cinco SIB Generation Task", 100);
		
		if(!monitor.isCanceled()){
			monitor.subTask("Generating SIBs for Ecore Model");
			generateCincoSIBs();
		}
		if(!monitor.isCanceled()){
			monitor.subTask("Generating SIBs for GraphModel");
			generateGraphModelSIBs();
		}
		
		if(!monitor.isCanceled()){
			monitor.subTask("Setting Build Path.");
			
				IClasspathEntry sibSourcePath = JavaCore.newSourceEntry(outlet);
				IClasspathEntry ressourcesSourcePath = JavaCore.newSourceEntry(outlet.append("resources"));
				//project.
				
		}
		
		
		try {
			ResourcesPlugin.getWorkspace().getRoot().refreshLocal(IResource.DEPTH_INFINITE, monitor);
		} catch (CoreException e) {
			e.printStackTrace();
		}
		monitor.done();
	}


	private void generateGraphModelSIBs() {
		WritingSIBGenerator sibGenerator = new WritingSIBGenerator();
		HashMap<String,Object> context = new HashMap<>();
		context.put("modelPath", graphModelFile);
		context.put("outlet",this.outlet.toFile());
		context.put("packageName", this.packageName);
		context.put("iconFile",project.getProjectRelativePath().append("icons").makeAbsolute().toPortableString());
		context.put("groupId",project.getName());
         context.put("artifactId", "cinco-sibs");
         context.put("version", "1.0.0");
         context.put("createMavenProject",false);
		try{
		String result = sibGenerator.execute(context);
		if(result.equals("error")){
			Exception e = (Exception)context.get("exception");
					if(e!=null)
						throw(e);
		}
		}catch(Exception e){
			
			e.printStackTrace();
			
		}
		System.out.println("FINISHED GraphModel SIB Generation");
	}


}
