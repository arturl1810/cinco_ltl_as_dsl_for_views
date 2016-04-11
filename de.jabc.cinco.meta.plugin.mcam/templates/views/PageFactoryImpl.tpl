package ${McamViewBasePackage};

import org.eclipse.core.resources.IFile;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.ui.IEditorPart;
import org.eclipse.emf.ecore.resource.Resource;

import de.jabc.cinco.meta.plugin.mcam.runtime.views.PageFactory;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.CheckViewPage;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.ConflictViewPage;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.utils.EclipseUtils;

public class PageFactoryImpl implements PageFactory {

	@Override
	public CheckViewPage<?, ?, ?, ?> createCheckViewPage(String id, IEditorPart editor) {
		
		IFile iFile = EclipseUtils.getIFile(editor);
		Resource resource = EclipseUtils.getResource(editor);

		for (EObject obj : resource.getContents()) {

			// @FACTORY_CHECK
			// if (res instanceof info.scce.cinco.product.flowgraph.flowgraph.FlowGraph)
			//	return new info.scce.cinco.product.flowgraph.mcam.views.flowgraph.views.pages.FlowGraphCheckViewPage(id, iFile, resource);

		}
		return null;
	}

	@Override
	public ConflictViewPage<?, ?, ?, ?> createConflictViewPage(String id, IEditorPart editor) {
		
		IFile iFile = EclipseUtils.getIFile(editor);
		Resource resource = EclipseUtils.getResource(editor);

		for (EObject obj : resource.getContents()) {

			// @FACTORY_CONFLICT
			// if (res instanceof info.scce.cinco.product.flowgraph.flowgraph.FlowGraph)
			//	return new info.scce.cinco.product.flowgraph.mcam.views.flowgraph.views.pages.FlowGraphConflictViewPage(id, iFile, resource);

		}
		return null;
	}

}
