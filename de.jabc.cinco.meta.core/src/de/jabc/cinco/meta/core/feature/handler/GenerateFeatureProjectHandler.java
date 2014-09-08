package de.jabc.cinco.meta.core.feature.handler;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.HashSet;

import mgl.Annotation;
import mgl.GraphModel;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.jface.operation.IRunnableWithProgress;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.ui.handlers.HandlerUtil;
import org.eclipse.ui.progress.IProgressService;
import org.eclipse.xtext.resource.IResourceDescriptions;
import org.eclipse.xtext.resource.IResourceFactory;
import org.eclipse.xtext.ui.resource.IResourceSetProvider;

import com.google.inject.Inject;

import de.jabc.cinco.meta.core.featuregenerator.Generate_Feature_XML;
import de.jabc.cinco.meta.core.pluginregistry.PluginRegistry;
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
			ISelection selection = HandlerUtil.getActiveMenuSelection(event);
			if (selection instanceof StructuredSelection) {
				StructuredSelection structuredSelection = (StructuredSelection) selection;
				IFile file = null;
				if (structuredSelection.getFirstElement() instanceof IFile) {
					file = (IFile) structuredSelection.getFirstElement();
					ResourceSet rSet = new ResourceSetImpl();
					
			//ps.run(true, true, new FeatureGenerator(file,rSet));
			ps.busyCursorWhile(new FeatureGenerator(file,rSet));
				}
			}
		} catch (InvocationTargetException | InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return false;
	}

	private class FeatureGenerator implements IRunnableWithProgress {

		private ExecutionEvent event;
		private IFile file;
		private ResourceSet rSet;

		public FeatureGenerator(IFile file, ResourceSet rSet) {
			this.file = file;
			this.rSet = rSet;
		}

		@Override
		public void run(IProgressMonitor monitor)
				throws InvocationTargetException, InterruptedException {

					Resource res = rSet.createResource(URI
							.createPlatformResourceURI(file.getFullPath()
									.toPortableString(), true));
					try {
						res.load(null);
						GraphModel model = (GraphModel) res.getContents()
								.get(0);
						String packageName = model.getPackage();
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
						if (hasStyleAnnotation(model))
							requiredBundles.add(packageName + ".graphiti");
						ArrayList<String> exportedPackages = new ArrayList<>();
						ArrayList<String> additionalNatures = new ArrayList<>();
						additionalNatures.add("org.eclipse.pde.FeatureNature");

						IProject featureProject = ProjectCreator.createProject(
								projectName, srcFolders, referencedProjects,
								requiredBundles, exportedPackages,
								additionalNatures, monitor,false);
						String featureProjectPath = featureProject.getLocation().addTrailingSeparator().toPortableString();
						
						// Generating feature.xml
						LightweightExecutionContext context = new DefaultLightweightExecutionContext(null);
						context.put("packageName", packageName);
						context.put("graphitiPackageName", packageName.concat(".graphiti"));
						context.put("annotationToMGLPackageMap", PluginRegistry.getInstance().getMGLDependentPlugins());
						context.put("annotationToPackageMap", PluginRegistry.getInstance().getUsedPlugins());
						context.put("annotationToFragmentMap", PluginRegistry.getInstance().getUsedFragments());
						context.put("annotationToMGLFragmentMap", PluginRegistry.getInstance().getMGLDependentFragments());
						context.put("annotationToPackageMap", PluginRegistry.getInstance().getUsedPlugins());
						context.put("featureProjectPath",featureProjectPath);
						context.put("graphModel",model);
						LightweightExecutionEnvironment env = new DefaultLightweightExecutionEnvironment(context);
						if(new Generate_Feature_XML().execute(env).equals("error"))
							throw new Exception("Could not create feature.xml",(Throwable)context.get("exception"));
						featureProject.refreshLocal(IResource.DEPTH_INFINITE,
								monitor);
					} catch (Exception e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				
			}
	}
	
	private boolean hasStyleAnnotation(GraphModel model) {
		for (Annotation a : model.getAnnotations()) {
			if ("style".equals(a.getName()))
				return true;
		}
		return false;
	}
}
