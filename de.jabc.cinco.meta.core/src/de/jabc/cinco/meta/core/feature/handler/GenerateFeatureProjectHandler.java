package de.jabc.cinco.meta.core.feature.handler;

import java.util.ArrayList;
import java.util.HashSet;

import mgl.GraphModel;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.ui.handlers.HandlerUtil;
import org.eclipse.ui.progress.IProgressService;
import org.eclipse.xtext.resource.IResourceDescriptions;
import org.eclipse.xtext.ui.resource.IResourceSetProvider;

import com.google.inject.Inject;

import de.jabc.cinco.meta.core.BundleRegistry;
import de.jabc.cinco.meta.core.featuregenerator.Generate_Feature_XML;
import de.jabc.cinco.meta.core.pluginregistry.PluginRegistry;
import de.jabc.cinco.meta.core.ui.listener.MGLSelectionListener;
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;
import de.metaframe.jabc.framework.execution.DefaultLightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.context.DefaultLightweightExecutionContext;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;

public class GenerateFeatureProjectHandler extends AbstractHandler {

	@Inject
	IResourceDescriptions resourceDescriptions;

	@Inject
	IResourceSetProvider resourceSetProvider;

	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		IProgressService ps = HandlerUtil
				.getActiveWorkbenchWindowChecked(event).getWorkbench()
				.getProgressService();
		try {
			IFile file = MGLSelectionListener.INSTANCE.getCurrentMGLFile();
			if(file!=null){
				ResourceSet rSet = new ResourceSetImpl();
				generateFeature(file,rSet);
				
			}
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		return null;
	}

	private void generateFeature(IFile file, ResourceSet rSet) {
		Resource res = rSet.createResource(URI
				.createPlatformResourceURI(file.getFullPath()
						.toPortableString(), true));
		try {
			res.load(null);
			GraphModel model = (GraphModel) res.getContents()
					.get(0);
			String packageName = ProjectCreator.getProjectSymbolicName(ProjectCreator.getProject(model.eResource())); 
			String projectName = packageName + ".feature";
			ArrayList<String> srcFolders = new ArrayList<>();
			srcFolders.add("src");
			ArrayList<IProject> referencedProjects = new ArrayList<>();
			HashSet<String> requiredBundles = new HashSet<>();
			IResource iRes = ResourcesPlugin.getWorkspace().getRoot().findMember(new Path(model.eResource().getURI().toPlatformString(true)));
			String symbolicName;
			if (iRes != null)
				symbolicName = ProjectCreator.getProjectSymbolicName(iRes.getProject());
			else symbolicName = model.getPackage();
			requiredBundles.add(symbolicName);
			ArrayList<String> exportedPackages = new ArrayList<>();
			ArrayList<String> additionalNatures = new ArrayList<>();
			additionalNatures.add("org.eclipse.pde.FeatureNature");

			IProject featureProject = ProjectCreator.createProject(
					projectName, srcFolders, referencedProjects,
					requiredBundles, exportedPackages,
					additionalNatures, null,false);
			String featureProjectPath = featureProject.getLocation().addTrailingSeparator().toPortableString();
			
			// Generating feature.xml
			LightweightExecutionContext context = new DefaultLightweightExecutionContext(null);
			context.put("packageName", packageName);
			context.put("annotationToMGLPackageMap", PluginRegistry.getInstance().getMGLDependentPlugins());
			context.put("annotationToPackageMap", PluginRegistry.getInstance().getUsedPlugins());
			context.put("annotationToFragmentMap", PluginRegistry.getInstance().getUsedFragments());
			context.put("annotationToMGLFragmentMap", PluginRegistry.getInstance().getMGLDependentFragments());
			context.put("annotationToPackageMap", PluginRegistry.getInstance().getUsedPlugins());
			context.put("featureProjectPath",featureProjectPath);
			context.put("graphModel",model);
			context.put("otherPluginIDs", BundleRegistry.INSTANCE.getPluginIDs());
			context.put("otherFragmentIDs", BundleRegistry.INSTANCE.getFragmentIDs());
			LightweightExecutionEnvironment env = new DefaultLightweightExecutionEnvironment(context);
			if(new Generate_Feature_XML().execute(env).equals("error"))
				throw new Exception("Could not create feature.xml",(Throwable)context.get("exception"));
			featureProject.refreshLocal(IResource.DEPTH_INFINITE,
					null);
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		
	}
}

