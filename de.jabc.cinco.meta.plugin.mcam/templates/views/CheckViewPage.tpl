package ${McamViewPagePackage};

import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;
import ${GraphModelPackage}.${GraphModelName?lower_case}.${GraphModelName};
import ${GraphModelPackage}.api.c${GraphModelName?lower_case}.C${GraphModelName};

import info.scce.mcam.framework.processes.CheckProcess;

import ${CliPackage}.${GraphModelName}Execution;

import org.eclipse.core.resources.IFile;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.ui.IEditorPart;

import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.CheckViewPage;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.utils.EclipseUtils;

public class ${GraphModelName}CheckViewPage extends CheckViewPage<${GraphModelName}Id, ${GraphModelName}, C${GraphModelName}, ${GraphModelName}Adapter> {

	public ${GraphModelName}CheckViewPage(String pageId, IFile iFile, Resource resource) {
		super(pageId, iFile, resource);
	}
	
	@Override
	protected CheckProcess<${GraphModelName}Id, ${GraphModelName}Adapter> createCp() {
		${GraphModelName}Execution fe = new ${GraphModelName}Execution();
		return fe.createCheckPhase(fe.initApiAdapterFromResource(this.resource, EclipseUtils.getFile(iFile)));
	}

	@Override
	protected C${GraphModelName} getWrapperFromEditor(IEditorPart editorPart) {

		return null;
	}
}

