package ${McamViewBasePackage};

import org.eclipse.core.resources.IFile;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.ui.IEditorPart;
import org.eclipse.emf.ecore.resource.Resource;

import de.jabc.cinco.meta.plugin.mcam.runtime.views.PageFactory;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.CheckViewPage;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.ConflictViewPage;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.utils.EclipseUtils;
import de.jabc.cinco.meta.runtime.xapi.ResourceExtension;
import graphmodel.GraphModel;

public class PageFactoryImpl implements PageFactory {

	private ResourceExtension resourceHelper = new ResourceExtension();

	@Override
	public boolean canHandle(Resource resource) {
		if (resource == null)
			return false;
			
		GraphModel model = resourceHelper.getGraphModel(resource);
		if (model == null)
			return false;
			
		// @FACTORY_HANDLE
		// if (obj instanceof info.scce.dime.process.process.Process) return true;
			
		return false;
	}

	@Override
	public CheckViewPage<?, ?, ?> createCheckViewPage(String id, IEditorPart editor) {
		
		IFile iFile = EclipseUtils.getIFile(editor);
		Resource resource = EclipseUtils.getResource(editor);
		GraphModel model = resourceHelper.getGraphModel(resource);

		// @FACTORY_CHECK
		// if (model instanceof info.scce.cinco.product.flowgraph.flowgraph.FlowGraph)
		//	return new info.scce.cinco.product.flowgraph.mcam.views.flowgraph.views.pages.FlowGraphCheckViewPage(id);

		return null;
	}

	@Override
	public CheckViewPage<?, ?, ?> createProjectCheckViewPage(String id, IEditorPart editor) {
		
		IFile iFile = EclipseUtils.getIFile(editor);

		// @FACTORY_PROJECT_CHECK
		// return new info.scce.cinco.product.flowgraph.mcam.views.flowgraph.views.pages.FlowGraphCheckViewPage(id);
	}

	@Override
	public ConflictViewPage<?, ?, ?> createConflictViewPage(String id, IEditorPart editor) {
		
		IFile iFile = EclipseUtils.getIFile(editor);
		Resource resource = EclipseUtils.getResource(editor);
		GraphModel model = resourceHelper.getGraphModel(resource);
		
		// @FACTORY_CONFLICT
		// if (model instanceof info.scce.cinco.product.flowgraph.flowgraph.FlowGraph)
		//	return new info.scce.cinco.product.flowgraph.mcam.views.flowgraph.views.pages.FlowGraphConflictViewPage(id, iFile, resource);

		return null;
	}

}

