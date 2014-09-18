package de.jabc.cinco.meta.core.jabcproject;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.util.Properties;
import java.util.UUID;

import mgl.GraphModel;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.jface.operation.IRunnableWithProgress;


public class TransEM4SIBGenerator implements IRunnableWithProgress {

	private File projectPath =null;
	private IProject project;
	private GraphModel mglModel;
	
	public TransEM4SIBGenerator(IProject project,GraphModel mglModel){
		this.project = project;
		this.projectPath = project.getLocation().makeAbsolute().toFile();
		this.mglModel = mglModel;
	}
	

	@Override
	public void run(IProgressMonitor monitor) throws InvocationTargetException,
			InterruptedException {
		monitor.beginTask("Generate CINCO SIBs for jABC4", 100);
		try{
			
			if(!isJABC4Project(projectPath)){
				monitor.subTask("Generating jABC4 Project");
				generateJABC4Project(projectPath);
			}
			monitor.worked(90);
		}catch(Exception e){
			e.printStackTrace();
			throw new InvocationTargetException(e);
		}
		try {
			monitor.subTask("Refreshing Project");
			project.refreshLocal(IProject.DEPTH_INFINITE, monitor);
			monitor.worked(10);
		} catch (Exception e) {
			throw new InvocationTargetException(e);
		}
		
		monitor.done();
	}


	
	private void generateJABC4Project(File projectPath) throws FileNotFoundException, IOException {
		File projectFile = new File(projectPath +File.separator+"jabc.project");
		if(!projectFile.exists()){
			
			Properties jABC4Project = new Properties();
		
			jABC4Project.setProperty("ID", UUID.randomUUID().toString());
			jABC4Project.setProperty("jabc.project.sibpath.0","<classpath>");
			jABC4Project.setProperty("jabc.project.classpath.0", File.separator+"bin"+ File.separator);
			jABC4Project.setProperty("jabc.project.name",mglModel.getName());
			jABC4Project.setProperty("jabc.project.definition","1.0");
			jABC4Project.setProperty("transem.qualified.package",getEPackageName(mglModel));
			jABC4Project.setProperty("transem.codegenerator.targetDir","src-gen/");
			jABC4Project.setProperty("transem.codegenerator.sourceDir","slg/");
			jABC4Project.setProperty("transem.SIBDir","slg-gen/");
			jABC4Project.store(new FileOutputStream(projectFile), "Saving jABC Project");
			
		}
		
		
	}

	private String getEPackageName(GraphModel mglModel2) {
		String mglName = firstUpper(mglModel2.getName().toLowerCase());
		String mglPackage = mglModel2.getPackage();
		String mglNameLower = mglModel2.getName().toLowerCase();
		return mglPackage.concat(".").concat(mglNameLower).concat(".").concat(mglName).concat("Package");
	}


	


	private boolean isJABC4Project(File projectPath){
		return new File(projectPath.getAbsolutePath()+File.separator+"jabc.project").exists();
	}
	
	private static String firstUpper(String string) {
		String fuString = "";
		if (string == null)
			return null;
		switch (string.length()) {
		case 0:
			return fuString;
		case 1:
			return string.toUpperCase();
		default:
			return string.substring(0, 1).toUpperCase()
					.concat(string.substring(1, string.length()));
		}

	}
	

}
