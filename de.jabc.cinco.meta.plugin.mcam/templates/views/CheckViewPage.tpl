package ${McamViewPagePackage};

import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;
import ${GraphModelPackage}.${GraphModelName?lower_case}.${GraphModelName};

import ${CliPackage}.${GraphModelName}Execution;

import org.eclipse.core.resources.IFile;
import org.eclipse.emf.ecore.resource.Resource;

import de.jabc.cinco.meta.plugin.mcam.runtime.core.FrameworkExecution;
import de.jabc.cinco.meta.plugin.mcam.runtime.core._CincoAdapter;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.CheckViewPage;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.utils.EclipseUtils;

public class ${GraphModelName}CheckViewPage extends CheckViewPage<${GraphModelName}Id, ${GraphModelName}, ${GraphModelName}Adapter> {

	public ${GraphModelName}CheckViewPage(String pageId) {
		super(pageId);
	}
	
	@SuppressWarnings("unchecked")
	@Override
	public void addCheckProcess(IFile iFile, Resource resource){
		getCheckProcesses().add(getFrameWorkExecution(iFile).createCheckPhase(getAdapter(iFile, resource)));
	}

	@SuppressWarnings("rawtypes")
	public FrameworkExecution getFrameWorkExecution(IFile iFile) {
		return new ${GraphModelName}Execution();
	}

	@SuppressWarnings("rawtypes")
	@Override
	public _CincoAdapter getAdapter(IFile iFile, Resource resource) {
		return getFrameWorkExecution(iFile).initApiAdapterFromResource(resource, EclipseUtils.getFile(iFile));
	}

}

