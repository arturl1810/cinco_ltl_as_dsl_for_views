package ${McamViewBasePackage};

import java.io.File;

import org.eclipse.core.resources.IFile;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;

public class ConflictViewInformationFactory {
	public static ConflictViewInformation create(
			File origFile, File remoteFile, File localFile, IFile file, Resource res) {

		for (EObject obj : res.getContents()) {
		// @FACTORY
		// if (res instanceof info.scce.cinco.product.flowgraph.flowgraph.FlowGraph)
		//	return new info.scce.cinco.product.flowgraph.mcam.views.flowgraph.views.ConflictViewInformation(origFile, remoteFile, localFile, file, res);

		}
		return null;
	}
}

