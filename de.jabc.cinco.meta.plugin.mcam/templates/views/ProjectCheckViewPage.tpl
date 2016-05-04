package ${McamViewPagePackage};

import graphicalgraphmodel.CGraphModel;
import graphmodel.GraphModel;

import java.io.File;
import java.util.Arrays;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;

import de.jabc.cinco.meta.plugin.mcam.runtime.core._CincoAdapter;
import de.jabc.cinco.meta.plugin.mcam.runtime.core._CincoId;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.CheckViewPage;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.utils.EclipseUtils;
import de.jabc.cinco.meta.core.referenceregistry.ReferenceRegistry;

public class ProjectCheckViewPage extends CheckViewPage<_CincoId, GraphModel, CGraphModel, _CincoAdapter<_CincoId, GraphModel, CGraphModel>> {

	private String[] fileExtensions = { 
		// @PROJECT_CHECK_PAGE_EXT
		"" 
	};

	private IProject iProject = null;

	public ProjectCheckViewPage(String pageId) {
		super(pageId);
	}
	
	@Override
	public void addCheckProcess(IFile iFile, Resource resource) {
		// @PROJECT_CHECK_PAGE_ADD
		// ${CliPackage}.${GraphModelName}Execution fe = new ${GraphModelName}Execution();
		// getCheckProcesses().add(fe.createCheckPhase(fe.initApiAdapterFromResource(resource, EclipseUtils.getFile(iFile))));
	}

	@SuppressWarnings("restriction")
	public void addCheckProcesses(IResource iResource) {
		if (iResource instanceof org.eclipse.core.internal.resources.Project)
			iProject = ((org.eclipse.core.internal.resources.Project) iResource);

		if (iResource instanceof org.eclipse.core.internal.resources.File)
			if (Arrays.asList(fileExtensions).contains(
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

	public EObject loadModel(IResource res) {
		File file = new File(res.getLocation().toOSString());
		ResourceSet resSet = new ResourceSetImpl();
		URI uri = URI.createFileURI(file.getAbsolutePath());
		
		EObject eObj = ReferenceRegistry.getInstance().getGraphModelFromURI(uri);
		if (eObj != null && eObj instanceof GraphModel) {
			return eObj;
		}
			
		Resource resource = resSet.getResource(uri, true);
		for (EObject obj : resource.getContents()) {
			if (obj instanceof GraphModel) {
				ReferenceRegistry.getInstance().addElement((GraphModel) obj);
				return (GraphModel) obj;
			}
				
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
