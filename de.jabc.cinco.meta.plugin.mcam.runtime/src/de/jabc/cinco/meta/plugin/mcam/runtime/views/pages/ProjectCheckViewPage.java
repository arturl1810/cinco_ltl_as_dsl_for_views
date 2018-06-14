package de.jabc.cinco.meta.plugin.mcam.runtime.views.pages;

import graphmodel.GraphModel;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;

import de.jabc.cinco.meta.plugin.mcam.runtime.core.FrameworkExecution;
import de.jabc.cinco.meta.plugin.mcam.runtime.core._CincoAdapter;
import de.jabc.cinco.meta.plugin.mcam.runtime.core._CincoId;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.PageFactory;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.CheckViewPage;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.utils.EclipseUtils;
import de.jabc.cinco.meta.core.referenceregistry.ReferenceRegistry;
import de.jabc.cinco.meta.runtime.xapi.ResourceExtension;

public class ProjectCheckViewPage extends CheckViewPage<_CincoId, GraphModel, _CincoAdapter<_CincoId, GraphModel>> {

	private ResourceExtension resourceHelper = new ResourceExtension();

	private String[] tmpNames = { "temp", "tmp" };

	private IProject iProject = null;
	
	private List<PageFactory> pageFactories = null;

	public ProjectCheckViewPage(String pageId, List<PageFactory> pageFactories) {
		super(pageId);
		this.pageFactories = pageFactories;
	}
	
	public List<String> getFileExtensions() {
		List<String> list = new ArrayList<>();
		for (PageFactory pageFactory : pageFactories) {
			list.addAll(pageFactory.getFileExtensions());
		}
		return list;
	}
	
	@SuppressWarnings("rawtypes")
	public FrameworkExecution getFrameWorkExecution(IFile iFile) {
		for (PageFactory pageFactory : pageFactories) {
			FrameworkExecution fe = pageFactory.getFrameWorkExecution(iFile);
			if (fe != null)
				return fe;
		}
		return null;
	}

	@SuppressWarnings("rawtypes")
	@Override
	public _CincoAdapter getAdapter(IFile iFile, Resource resource) {
		return getFrameWorkExecution(iFile).initApiAdapterFromResource(resource, EclipseUtils.getFile(iFile));
	}

	@SuppressWarnings("unchecked")
	@Override
	public void addCheckProcess(IFile iFile, Resource resource) {
		getCheckProcesses().add(getFrameWorkExecution(iFile).createCheckPhase(getAdapter(iFile, resource)));
	}

	@SuppressWarnings("restriction")
	public void addCheckProcesses(IResource iResource) {
		if (iResource instanceof org.eclipse.core.internal.resources.Project)
			iProject = ((org.eclipse.core.internal.resources.Project) iResource);

		if (ignoreResource(iResource))
			return;

		if (iResource instanceof org.eclipse.core.internal.resources.File)
			if (Arrays.asList(getFileExtensions()).contains(
					iResource.getFileExtension())) {
				EObject model = loadModel(iResource);
				addCheckProcess((IFile) iResource, model.eResource());
			}

		if (iResource instanceof org.eclipse.core.internal.resources.Container)
			try {
				for (IResource subRes : ((org.eclipse.core.internal.resources.Container) iResource)
						.members()) {
					addCheckProcesses(subRes);
				}
			} catch (CoreException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	}

	private boolean ignoreResource(IResource iResource) {
		System.out.println("Ignore " + iResource);
		for (String string : Arrays.asList(tmpNames)) {
			if (iResource.getName().toLowerCase().contains(string.toLowerCase()))
				return true;
		}
		return false;
	}

	public EObject loadModel(IResource res) {
		File file = new File(res.getLocation().toOSString());
		ResourceSet resSet = new ResourceSetImpl();
		URI uri = URI.createFileURI(file.getAbsolutePath());
		
		GraphModel model = ReferenceRegistry.getInstance().getGraphModelFromURI(uri);
		if (model != null)
			return model;
			
		Resource resource = resSet.getResource(uri, true);
		model = resourceHelper.getGraphModel(resource);
		if (model != null) {
			ReferenceRegistry.getInstance().addElement(model);
			return model;
		}
		
		System.out.println("Model " + file.getName() + " not found");
		return null;
	}

	@Override
	public void reload() {
		getCheckProcesses().clear();
		addCheckProcesses(iProject);
		super.reload();
	}

}
