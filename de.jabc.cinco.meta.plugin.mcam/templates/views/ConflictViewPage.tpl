package ${McamViewPagePackage};

import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;
import ${GraphModelPackage}.${GraphModelName?lower_case}.${GraphModelName};
import ${GraphModelPackage}.api.c${GraphModelName?lower_case}.C${GraphModelName};

import ${CliPackage}.${GraphModelName}Execution;

import info.scce.mcam.framework.processes.CompareProcess;

import java.io.File;

import org.eclipse.core.resources.IFile;

import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.ConflictViewPage;

public class ${GraphModelName}ConflictViewPage extends ConflictViewPage<${GraphModelName}Id, ${GraphModelName}, C${GraphModelName}> {

	public ${GraphModelName}ConflictViewPage(Object obj) {
		super(obj);
	}
	
	@Override
	protected String getPageId(Object obj) {
		if (obj instanceof IFile == false || obj == null) 
			return null;

		IFile file = (IFile) obj;
		String path = file.getRawLocation().toOSString();
		File origFile = new File(path);
		return origFile.getAbsolutePath();
	}

	@Override
	protected Object getPageRootObject(Object obj) {
		if (obj instanceof IFile == false || obj == null) 
			return null;

		IFile file = (IFile) obj;
		${GraphModelName}Execution fe = new ${GraphModelName}Execution();
		
		String path = file.getRawLocation().toOSString();
		
		File origFile = new File(path);
		File remoteFile = new File(path + ".remote");
		File localFile = new File(path + ".local");
		if (origFile.exists() && localFile.exists()
				&& remoteFile.exists()) {

			${GraphModelName}Adapter orig = fe.initApiAdapter(origFile);
			${GraphModelName}Adapter local = fe.initApiAdapter(localFile);
			${GraphModelName}Adapter remote = fe.initApiAdapter(remoteFile);

			${GraphModelName}Adapter mergeModel = fe.initApiAdapter(origFile);

			CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> localCompare = fe.executeComparePhase(orig, local);
			CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> remoteCompare = fe.executeComparePhase(orig, remote);
			return fe.createMergePhase(localCompare, remoteCompare, mergeModel);
		}
		return null;
	}
}

