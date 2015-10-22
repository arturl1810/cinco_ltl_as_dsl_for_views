package de.jabc.cinco.meta.plugin.generator;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Scanner;
import java.util.Set;
import java.util.jar.Attributes;
import java.util.jar.Manifest;
import java.util.regex.Pattern;

import mgl.Annotation;
import mgl.GraphModel;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.jdt.core.IJavaModelStatusConstants;
import org.eclipse.jdt.core.JavaModelException;
import org.eclipse.pde.core.plugin.PluginRegistry;
import org.eclipse.xtext.util.StringInputStream;
import org.osgi.framework.Bundle;

import de.jabc.cinco.meta.core.BundleRegistry;
import de.jabc.cinco.meta.core.mgl.transformation.helper.AbstractService;
import de.jabc.cinco.meta.core.mgl.transformation.helper.ServiceException;
import de.jabc.cinco.meta.core.utils.BuildProperties;
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;

public class CreateCodeGeneratorPlugin extends AbstractService {


	private static final String GENERATOR_RUNTIME_BUNDLE_NAME = "de.jabc.cinco.meta.plugin.generator.runtime";

	public CreateCodeGeneratorPlugin() {
	}

	@Override
	public String execute(LightweightExecutionEnvironment environment)
			throws ServiceException {
		LightweightExecutionContext globalContext = environment.getLocalContext().getGlobalContext();
		IProject proj = null;
		try{
			proj = this.createCodeGeneratorEclipseProject(environment);
		}catch(Exception e){
			e.printStackTrace();
			globalContext.put("exception", e);
			return "error";
		}
		
		
		//return callSLG(environment, globalContext, proj);
		return "default";
	}

	@SuppressWarnings("unused")
	private String callSLG(LightweightExecutionEnvironment environment,
			LightweightExecutionContext globalContext, IProject proj) {
		if (proj != null) {
			String s = new Create_Generator_Plugin().execute(environment);
			if (s.equals("default")) {
				try {
					createCodeGeneratorEclipseProject(environment);
					proj.refreshLocal(IResource.DEPTH_INFINITE, new NullProgressMonitor());
					return "default";
				} catch (Exception e) {
					
					globalContext
							.put("exception", e);
					e.printStackTrace();
					System.out.println("Error 0");
					return "error";
				}

			} else {
				return "error";

			}
		} else {
			return "error";
		}
	}
	
	public IProject createCodeGeneratorEclipseProject(
			LightweightExecutionEnvironment environment) {
		LightweightExecutionContext context = environment.getLocalContext().getGlobalContext();
		try {
			GraphModel graphModel = (GraphModel) context.get("graphModel");
			String implementingClassName = "";
			String bundleName = "";
			String outlet = "";
			boolean localBundle = false;
			for(mgl.Annotation anno: graphModel.getAnnotations()){
				if(anno.getName().equals("generatable")){
					if (anno.getValue().size() == 3) {
						bundleName = anno.getValue().get(0);
						implementingClassName = anno.getValue().get(1);
						outlet = anno.getValue().get(2);
						break;
					} else if (anno.getValue().size() == 2) {
						implementingClassName = anno.getValue().get(0);
						outlet = anno.getValue().get(1);
						
					}
				}
			}
			context.put("implementingClassName",implementingClassName);
			context.put("outlet",outlet);
			String packageName = implementingClassName.substring(0, implementingClassName.lastIndexOf('.'));
			
			String className = null;
			try{
				className = implementingClassName.substring(implementingClassName.lastIndexOf('.')+1);
			}catch(Exception e){
				className = "Generator";
			}
			List<String> exportedPackages = new ArrayList<>();
			List<String> additionalNature = new ArrayList<>();
			String projectName = graphModel.getPackage() + ".codegen";
			List<IProject> referencedProjects = new ArrayList<>();
			List<String> srcFolders = new ArrayList<>();
			srcFolders.add("src");
			Set<String> requiredBundles = new HashSet<>();
			
			IResource res = ResourcesPlugin.getWorkspace().getRoot().findMember(new Path(graphModel.eResource().getURI().toPlatformString(true)));
			String symbolicName;
			if (res != null)
				symbolicName = ProjectCreator.getProjectSymbolicName(res.getProject());
			else symbolicName = graphModel.getPackage();
			
			if (bundleName.isEmpty()) {
				localBundle = true;
				bundleName = symbolicName;//res.getProject().getName();
			}
			BundleRegistry.INSTANCE.addBundle(bundleName,false);
			BundleRegistry.INSTANCE.addBundle(GENERATOR_RUNTIME_BUNDLE_NAME, false);
			requiredBundles.add(symbolicName);
			requiredBundles.add("org.eclipse.ui");
			requiredBundles.add("org.eclipse.core.runtime");
			requiredBundles.add("org.eclipse.core.resources");
			requiredBundles.add("org.eclipse.ui.navigator");
			requiredBundles.add("org.eclipse.emf.common");
			requiredBundles.add("org.eclipse.emf.ecore");
			requiredBundles.add("org.eclipse.graphiti.ui");
			requiredBundles.add("org.eclipse.ui.workbench");
			requiredBundles.add("de.jabc.cinco.meta.core.mgl.model");
			requiredBundles.add(GENERATOR_RUNTIME_BUNDLE_NAME);
			
			
			IProject pr = ResourcesPlugin.getWorkspace().getRoot().getProject(bundleName);
			if(pr!=null&&pr.exists()){
				exportPackage(pr,bundleName,packageName,className);
			}else{
				try {
					String modelClassName = graphModel.getName();
					String modelPackage = graphModel.getPackage().concat(".").concat(modelClassName.toLowerCase());
					createGeneratorStubProject(pr,packageName,className,modelPackage,modelClassName,graphModel);
				} catch (Exception e) {
					throw new RuntimeException(e);
				}
			}
			
			
			if(!localBundle)
				requiredBundles.add(bundleName);
			else{
				Bundle b = Platform.getBundle(GENERATOR_RUNTIME_BUNDLE_NAME);
				ProjectCreator.addRequiredBundle(pr, b);
			}
			
			addGeneratorEntry(pr,graphModel);	
			
			
//			IProject tvProject = createGenerationHandlerProject(context,
//					exportedPackages, additionalNature, projectName,
//					referencedProjects, srcFolders, requiredBundles);
			
			return null;
		} catch (Exception e) {
			context.put("exception", e);
			e.printStackTrace();
			return null;
		} finally {
		}

	}

	private void addGeneratorEntry(IProject pr, GraphModel graphModel) throws CoreException {
		String bundleName=null;
		String implementingClassName = null;
		String outlet = null;
		ArrayList<String[]> generators  = new ArrayList<String[]>();
		for(mgl.Annotation anno: graphModel.getAnnotations()){
			if(anno.getName().equals("generatable")){
				if (anno.getValue().size() == 3) {
					bundleName = anno.getValue().get(0);
					implementingClassName = anno.getValue().get(1);
					outlet = anno.getValue().get(2);
					
				} else if (anno.getValue().size() == 2) {
					implementingClassName = anno.getValue().get(0);
					outlet = anno.getValue().get(1);
					bundleName= ProjectCreator.getProjectSymbolicName(pr);
				}
				String[] a = {bundleName,implementingClassName,outlet};
				generators.add(a);
			}
		}
		
		String extension = generateExtension(graphModel, generators);
		
		IFile plFile = pr.getFile("plugin.xml");
		
		addExtension(plFile,extension,graphModel.getName());
		
		
	}

	public String removeGeneratorEntries(String pluginxml,String graphmodelName){
		String regex = String.format("<extension.*<!--@MetaPlugin Generatable %s-->.*</extension>",graphmodelName);
		return java.util.regex.Pattern.compile(regex,Pattern.DOTALL).matcher(pluginxml).replaceAll("");
	}
	
	@SuppressWarnings("resource")
	private void addExtension(IFile plFile, String extension,String graphModelName) throws CoreException {
		if(plFile.exists()){
			
				InputStream l = plFile.getContents(true);
				String contents = new Scanner(l, "UTF-8").useDelimiter("\\A").next();
				contents = removeGeneratorEntries(contents, graphModelName);
				contents = contents.replace("</plugin>", extension+"\n</plugin>");
				plFile.setContents(new StringInputStream(contents), true, true, new NullProgressMonitor());
			
		}else{
			String pluginXML = String.format("<plugin>\n %s\n </plugin>",extension);
			plFile.create(new StringInputStream(pluginXML), true,	new NullProgressMonitor());
		}
		
	}

	private String generateExtension(GraphModel graphModel,
			ArrayList<String[]> generators) {
		StringBuilder sb = new StringBuilder();
		sb.append("<extension\n"+
       "point=\"de.jabc.cinco.meta.plugin.generator.runtime.registry\">\n"+
	    String.format("<!--@MetaPlugin Generatable %s-->\n",graphModel.getName())+
    "<graphmodel\n");
    sb.append(String.format("      class=\"%s\">\n",generateFullyQualifiedName(graphModel)));
    sb.append("</graphmodel>\n");
    
    for(String[]gen: generators){
    	sb.append("<generator\n");
        sb.append(String.format("bundle_id=\"%s\"\n",gen[0]));
        sb.append(String.format("class=\"%s\"\n",gen[1]));
        sb.append(String.format("outlet=\"%s\">\n</generator>\n",gen[2]));
    }
    
    sb.append("</extension>\n");
    
    return sb.toString();
	}

	private Object generateFullyQualifiedName(GraphModel graphModel) {
		String name = graphModel.getName();
		String nameLower = name.toLowerCase();
		String packageName=graphModel.getPackage();
		String fqName = String.format("%s.%s.%s",packageName,nameLower,name);
		return fqName;
	}

	@SuppressWarnings("unused")
	private IProject createGenerationHandlerProject(
			LightweightExecutionContext context, List<String> exportedPackages,
			List<String> additionalNature, String projectName,
			List<IProject> referencedProjects, List<String> srcFolders,
			Set<String> requiredBundles) throws IOException,
			FileNotFoundException, CoreException {
		if(!new Path("/"+projectName).toFile().exists()){
			
		IProgressMonitor progressMonitor = new NullProgressMonitor();
		IProject tvProject = ProjectCreator.createProject(projectName,
				srcFolders, referencedProjects, requiredBundles,
				exportedPackages, additionalNature, progressMonitor,false);
		String projectPath = tvProject.getLocation().makeAbsolute()
				.toPortableString();
		
		context.put("projectPath", projectPath);
		
		File maniFile = tvProject.getLocation().append("META-INF/MANIFEST.MF").toFile();
		BufferedWriter bufwr = new BufferedWriter(new FileWriter(maniFile,true));
		bufwr.append("Bundle-Activator: " +projectName+".Activator\n");
		bufwr.append("Bundle-ActivationPolicy: lazy\n");
		bufwr.flush();
		bufwr.close();
		
		IFile bpf = (IFile) tvProject.findMember("build.properties");
		BuildProperties buildProperties = BuildProperties.loadBuildProperties(bpf);
		buildProperties.appendBinIncludes("plugin.xml");
		buildProperties.store(bpf, progressMonitor);
		return tvProject;
		}
		return null;
	}

	private void exportPackage(IProject pr,String bundleName, String packageName,String className) {
		
			Manifest manni;
			try {
				File manniFile = pr.getFile("/META-INF/MANIFEST.MF").getLocation().makeAbsolute().toFile();
				manni = new Manifest(new FileInputStream(manniFile));
				Attributes mainAttr = manni.getMainAttributes();
				String oldValues = mainAttr.getValue("Export-Package");
				if (oldValues == null)
					oldValues = new String();
				if(!oldValues.contains(packageName)){
					mainAttr.putValue("Export-Package", oldValues.concat(",").concat(packageName));
					manni.write(new FileOutputStream(manniFile));
				}
			} catch (IOException e) {
				throw new RuntimeException("IOException while exporting Package",e);
			}
			
			
		
	}

	private void createGeneratorStubProject(IProject pr,String packageName,String className, String modelPackage,String modelClassName,GraphModel graphModel) throws RuntimeException{
		try{
		String graphModelProjectName = ProjectCreator.getProject(graphModel.eResource()).getName(); 
		String projectName = pr.getName();
		Set<String> requiredBundles = new HashSet<>();
		requiredBundles.add("de.jabc.cinco.meta.core.mgl.model");
		requiredBundles.add("org.eclipse.equinox.registry");
		requiredBundles.add(GENERATOR_RUNTIME_BUNDLE_NAME);
		requiredBundles.add(graphModelProjectName);
		List<IProject> referencedProjects = new ArrayList<>();
		List<String> srcFolders = new ArrayList<>();
		srcFolders.add("src");
		List<String> exportedPackages = new ArrayList<>();
		exportedPackages.add(packageName);
		List<String> additionalNature = new ArrayList<>();
		IProgressMonitor progressMonitor = new NullProgressMonitor();
		IProject tvProject = ProjectCreator.createProject(projectName,
				srcFolders, referencedProjects, requiredBundles,
				exportedPackages, additionalNature, progressMonitor,false);
		tvProject.refreshLocal(IResource.DEPTH_INFINITE, progressMonitor);
		try{
			
			ProjectCreator.createJavaClass(pr, packageName, className,tvProject.getFolder("/src/"),stubContents(packageName,className,modelPackage,modelClassName), progressMonitor);
		}catch(JavaModelException e){
			if(e.getJavaModelStatus().getCode() != IJavaModelStatusConstants.NAME_COLLISION)
				throw e;
		}
		
		
		
		}catch(Exception e){
			throw new RuntimeException("Exception while creating Generator Stub Project", e);
		}
	}

	private String stubContents(String packageName, String className, String modelPackage, String modelClassName) {
		String contents = "package %s;\n"+
				"\n"+
				"import org.eclipse.core.runtime.IPath;\n"+
				"import %s.%s;\n"+
				"import org.eclipse.core.runtime.IProgressMonitor;\n"+
				"import de.jabc.cinco.meta.plugin.generator.runtime.IGenerator;\n"+
				"\n"+
				"\n"+
				"public class %s implements IGenerator<%s>{\n"+
				"\tpublic void generate(%s model,IPath outlet, IProgressMonitor monitor){\n"+
				"\n"+
				"\t}\n"+
				"\n"+
				"}\n";
		return String.format(contents, packageName,modelPackage,modelClassName,className,modelClassName,modelClassName);
	}
	
	

}
