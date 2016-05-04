package ${McamViewPagePackage};

import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;
import ${GraphModelPackage}.${GraphModelName?lower_case}.${GraphModelName};
import ${GraphModelPackage}.api.c${GraphModelName?lower_case}.C${GraphModelName};

import ${CliPackage}.${GraphModelName}Execution;

import org.eclipse.core.resources.IFile;
import org.eclipse.emf.ecore.resource.Resource;

import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.CheckViewPage;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.utils.EclipseUtils;

public class ${GraphModelName}CheckViewPage extends CheckViewPage<${GraphModelName}Id, ${GraphModelName}, C${GraphModelName}, ${GraphModelName}Adapter> {

	public ${GraphModelName}CheckViewPage(String pageId) {
		super(pageId);
	}
	
	@Override
	public void addCheckProcess(IFile iFile, Resource resource){
		${GraphModelName}Execution fe = new ${GraphModelName}Execution();
		getCheckProcesses().add(fe.createCheckPhase(fe.initApiAdapterFromResource(resource, EclipseUtils.getFile(iFile))));
	}

}

