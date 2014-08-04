package de.jabc.cinco.meta.core.ge.generator.action;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import mgl.Annotation;
import mgl.GraphModel;
import mgl.Import;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.codegen.ecore.generator.Generator;
import org.eclipse.emf.codegen.ecore.genmodel.GenModel;
import org.eclipse.emf.codegen.ecore.genmodel.GenModelFactory;
import org.eclipse.emf.codegen.ecore.genmodel.GenModelPackage;
import org.eclipse.emf.codegen.ecore.genmodel.GenPackage;
import org.eclipse.emf.codegen.ecore.genmodel.generator.GenBaseGeneratorAdapter;
import org.eclipse.emf.codegen.ecore.genmodel.generator.GenPackageGeneratorAdapter;
import org.eclipse.emf.codegen.ecore.genmodel.impl.GenPackageImpl;
import org.eclipse.emf.codegen.ecore.genmodel.util.GenModelUtil;
import org.eclipse.emf.common.util.BasicMonitor;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.EcorePackage;
import org.eclipse.emf.ecore.plugin.EcorePlugin;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.IActionDelegate;
import org.eclipse.ui.handlers.HandlerUtil;
import org.eclipse.xtend.typesystem.emf.EcoreUtil2;
import org.osgi.framework.Bundle;

import style.Styles;
import de.jabc.cinco.meta.core.ge.generator.Main;
import de.jabc.cinco.meta.core.mgl.transformation.helper.ServiceException;
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;
import de.metaframe.jabc.framework.execution.DefaultLightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.context.DefaultLightweightExecutionContext;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;

public class Generate extends AbstractHandler {

	private GraphModel gModel;
	
	public Generate() {
		// TODO Auto-generated constructor stub
	}

	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		
		ISelection sel = HandlerUtil.getActiveMenuSelection(event);
		
		if (sel instanceof IStructuredSelection && !sel.isEmpty()) {
		IStructuredSelection ssel = (IStructuredSelection) sel;
		IFile file = (IFile) ssel.getFirstElement();
		NullProgressMonitor monitor = new NullProgressMonitor();
		
		Resource resource = new ResourceSetImpl().getResource(URI.createPlatformResourceURI(file.getFullPath().toOSString(), true), true);
	    Styles styles = null;
	    try {
	    	gModel = loadGraphModel(resource);
			generateGenModelCode(file);
			
			for (Annotation a : gModel.getAnnotations()) {
				if ("style".equals(a.getName())) {
					String stylePath = a.getValue().get(0);
					styles = loadStyles(stylePath);
				}
			}
			
			String mglProjectName = file.getProject().getName();
			String projectName = gModel.getPackage().concat(".graphiti");
			String path = ResourcesPlugin.getWorkspace().getRoot().getLocation().append(projectName).toOSString();
			
			List<String> srcFolders = getSrcFolders();
			List<String> cleanDirs = getCleanDirectory();
		    Set<String> reqBundles = getReqBundles();
		    reqBundles.add(file.getProject().getName());
		    IProject p = ProjectCreator.createProject(projectName, srcFolders, null, reqBundles, null, null, monitor, cleanDirs, false);
		    copyIcons(file.getProject(), p, monitor);
		    copyIcons("de.jabc.cinco.meta.core.ge.generator", p, monitor);
		    
		    try {
				p.refreshLocal(IResource.DEPTH_INFINITE, monitor);
			} catch (CoreException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		    String outletPath = p.getFolder("src-gen").getLocation().makeAbsolute().toString();
		    String customFeatureOutletPath = p.getFolder("src").getLocation().makeAbsolute().toOSString();
			
			LightweightExecutionContext context = new DefaultLightweightExecutionContext(null);
			context.put("graphModel", gModel);
			context.put("styles", styles);
			context.put("mglProjectName", mglProjectName);
			context.put("projectName", projectName);
			context.put("fullPath", path);
			context.put("outletPath", outletPath);
			context.put("customFeatureOutletPath", customFeatureOutletPath);
			LightweightExecutionEnvironment env = new DefaultLightweightExecutionEnvironment(context);
			
			Main tmp = new Main();
			String result = tmp.execute(env);
			if (result.equals("error")) {
				Exception e = (Exception) context.get("exception");
				throw new ExecutionException(e.getMessage());
			}
			
			p.refreshLocal(IResource.DEPTH_INFINITE, monitor);
		} catch (IOException e) {
			e.printStackTrace();
		} catch (CoreException e) {
			e.printStackTrace();
		}
	}
		return null;
	}
	

	private void copyIcons(IProject source, IProject target, NullProgressMonitor monitor) {
		IFolder srcIcons = source.getFolder("icons");
		try {
			srcIcons.copy(target.getFolder("icons").getFullPath(), true, monitor);
		} catch (CoreException e) {
			e.printStackTrace();
		}
		
	}

	private Styles loadStyles(String path) throws IOException {
		Styles s = null;
		Resource res = new ResourceSetImpl().getResource(
				URI.createPlatformResourceURI(path, true), true);

		if (res != null && res.getContents().get(0) instanceof Styles) {
			res.load(null);
			EcoreUtil.resolveAll(res.getResourceSet());
			s = (Styles) res.getContents().get(0);
		} else {
			throw new IOException("Couldn't load resource from: \""
					+ path + "\"");
		}
		return s;
	}
	
	private GraphModel loadGraphModel(Resource res) throws IOException{
		if (res == null)
			throw new IOException("Resource is null");
		if (res.getContents().get(0) instanceof GraphModel) {
			return (GraphModel) res.getContents().get(0);
		} else {
			throw new IOException("Could not load GraphModel (mgl) from resource: "+res);
		}
	}
	
	private void generateGenModelCode(IFile mglModelFile) throws IOException {
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
	
	private Collection<? extends GenPackage> getUsedGenPackages() {
		if (gModel == null)
			return Collections.emptyList();
		List<GenPackage> genPackages = new ArrayList<>();
		for (Import _import : gModel.getImports()) {
			String impString = _import.getImportURI();
			EPackage ePackage = EcoreUtil2.getEPackage(impString);
			Map<String, URI> map = EcorePlugin.getEPackageNsURIToGenModelLocationMap(true);
			URI genModelUri = map.get(ePackage.getNsURI());
			
			if (genModelUri.isRelative())
				genModelUri = URI.createPlatformResourceURI(genModelUri.toPlatformString(true), true);
			
			Resource res = new ResourceSetImpl().getResource(genModelUri, true);
			TreeIterator<EObject> it = res.getAllContents();
			while (it.hasNext()) {
				EObject object = it.next();
				if (object instanceof GenPackage) {
					if (((GenPackage) object).getNSURI().equals(ePackage.getNsURI())) {
						genPackages.add((GenPackage) object);
					} else if (object instanceof GenModel) {
						it.prune();
					}
					System.out.println(genModelUri);
				}
			}
		
		}
		return genPackages;
	}
	private Set<String> getReqBundles() {
		HashSet<String> reqBundles = new HashSet<String>();
		List<Bundle> bundles = new ArrayList<Bundle>();

		bundles.add(Platform.getBundle("org.eclipse.emf.transaction"));
		bundles.add(Platform.getBundle("org.eclipse.graphiti"));
		bundles.add(Platform.getBundle("org.eclipse.graphiti.ui"));
		bundles.add(Platform.getBundle("org.eclipse.core.runtime"));
		bundles.add(Platform.getBundle("org.eclipse.ui"));
		bundles.add(Platform.getBundle("org.eclipse.ui.ide"));
		bundles.add(Platform
				.getBundle("org.eclipse.ui.views.properties.tabbed"));
		bundles.add(Platform.getBundle("org.eclipse.gef"));
		bundles.add(Platform.getBundle("org.eclipse.emf.transaction"));
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.mgl.model"));
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.ge.style.model"));
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.referenceregistry"));
		
		bundles.add(Platform.getBundle("javax.el"));
		bundles.add(Platform.getBundle("com.sun.el"));

		for (Bundle b : bundles) {
			StringBuilder s = new StringBuilder();
			s.append(b.getSymbolicName());
			s.append(";bundle-version=");
			s.append("\"" + b.getVersion().getMajor() + "."
					+ b.getVersion().getMinor() + "."
					+ b.getVersion().getMicro() + "\"");
			reqBundles.add(s.toString());
		}
		return reqBundles;
	}
	
	private List<String> getSrcFolders() {
		ArrayList<String> folders = new ArrayList<String>();
		folders.add("src");
		folders.add("src-gen");
		return folders;
	}

	private List<String> getCleanDirectory() {
		ArrayList<String> cleanDirs = new ArrayList<String>();
		cleanDirs.add("src-gen");
		cleanDirs.add("icons");
		return cleanDirs;
	}

	private void copyIcons(String bundleId, IProject p, IProgressMonitor monitor) {
		Bundle b = Platform.getBundle(bundleId);
		InputStream fis=null;
		try {
			
			fis = FileLocator.openStream(b, new Path("/icons/_Connection.gif"), false);
			File trgFile = p.getFolder("icons").getFile("_Connection.gif").getLocation().toFile();
			trgFile.createNewFile();
			OutputStream os = new FileOutputStream(trgFile);
			int bt;
			while ((bt = fis.read()) != -1) {
				os.write(bt);
			}
			fis.close();
			os.flush();
			os.close();
			
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			
			e.printStackTrace();
		}
	}
}
