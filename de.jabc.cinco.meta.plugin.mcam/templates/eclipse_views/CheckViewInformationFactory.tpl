package ${McamViewBasePackage};

import java.io.File;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;

public class CheckViewInformationFactory {

	public static CheckViewInformation create(File origFile, Resource res) {
		for (EObject obj : res.getContents()) {
		// @FACTORY
		// if (res instanceof info.scce.cinco.product.flowgraph.flowgraph.FlowGraph)
		//	return new info.scce.cinco.product.flowgraph.mcam.views.flowgraph.views.CheckViewInformation(origFile, res);

		}
		return null;
	}
		
}
