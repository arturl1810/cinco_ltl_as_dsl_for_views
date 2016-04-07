package ${McamViewBasePackage};

import org.eclipse.core.resources.IFile;
import org.eclipse.emf.ecore.EObject;

import de.jabc.cinco.meta.plugin.mcam.runtime.views.PageFactory;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.CheckViewPage;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.ConflictViewPage;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.utils.EclipseUtils;

public class PageFactoryImpl implements PageFactory {

	@Override
	public CheckViewPage<?, ?, ?> createCheckViewPage(IFile file) {
		
		for (EObject obj : EclipseUtils.getResource(file).getContents()) {

			// @FACTORY_CHECK
			// if (res instanceof info.scce.cinco.product.flowgraph.flowgraph.FlowGraph)
			//	return new info.scce.cinco.product.flowgraph.mcam.views.flowgraph.views.pages.FlowGraphCheckViewPage(file);

		}
		return null;
	}

	@Override
	public ConflictViewPage<?, ?, ?> createConflictViewPage(IFile file) {
		for (EObject obj : EclipseUtils.getResource(file).getContents()) {

			// @FACTORY_CONFLICT
			// if (res instanceof info.scce.cinco.product.flowgraph.flowgraph.FlowGraph)
			//	return new info.scce.cinco.product.flowgraph.mcam.views.flowgraph.views.pages.FlowGraphConflictViewPage(file);

		}
		return null;
	}

}

