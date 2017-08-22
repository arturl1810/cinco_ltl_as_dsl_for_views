package ${McamViewPagePackage};

import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;
import ${GraphModelPackage}.${GraphModelName?lower_case}.${GraphModelName};

import ${CliPackage}.${GraphModelName}Execution;

import info.scce.mcam.framework.processes.CompareProcess;
import info.scce.mcam.framework.processes.MergeProcess;

import java.io.File;

import org.eclipse.core.resources.IFile;
import org.eclipse.emf.ecore.resource.Resource;

import de.jabc.cinco.meta.plugin.mcam.runtime.core.FrameworkExecution;
import de.jabc.cinco.meta.plugin.mcam.runtime.core._CincoAdapter;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.ConflictViewPage;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.utils.EclipseUtils;

public class ${GraphModelName}ConflictViewPage extends ConflictViewPage<${GraphModelName}Id, ${GraphModelName}, ${GraphModelName}Adapter> {

	public ${GraphModelName}ConflictViewPage(String pageId, IFile iFile, Resource resource) {
		super(pageId, iFile, resource);
	}
	

	@Override
	protected MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter> createMp() {

		${GraphModelName}Execution fe = new ${GraphModelName}Execution();
		
		String path = iFile.getRawLocation().toOSString();
		
		File origFile = new File(path);
		File remoteFile = new File(path + ".remote");
		File localFile = new File(path + ".local");
		if (origFile.exists() && localFile.exists()
				&& remoteFile.exists()) {

			${GraphModelName}Adapter orig = fe.initApiAdapter(origFile);
			${GraphModelName}Adapter local = fe.initApiAdapter(localFile);
			${GraphModelName}Adapter remote = fe.initApiAdapter(remoteFile);

			${GraphModelName}Adapter mergeModel = fe.initApiAdapterFromResource(this.resource, origFile);

			CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> localCompare = fe.executeComparePhase(orig, local);
			CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> remoteCompare = fe.executeComparePhase(orig, remote);
			return fe.createMergePhase(localCompare, remoteCompare, mergeModel);
		}
		return null;
	}

	@SuppressWarnings("rawtypes")
	@Override
	public _CincoAdapter getAdapter(IFile iFile, Resource resource) {
		return getFrameWorkExecution(iFile).initApiAdapterFromResource(resource, EclipseUtils.getFile(iFile));
	}

	@SuppressWarnings("rawtypes")
	public FrameworkExecution getFrameWorkExecution(IFile iFile) {
		return new ${GraphModelName}Execution();
	}
}

