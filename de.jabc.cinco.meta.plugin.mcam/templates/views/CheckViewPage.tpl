package ${McamViewPagePackage};

import ${AdapterPackage}.${GraphModelName}Id;
import ${GraphModelPackage}.${GraphModelName?lower_case}.${GraphModelName};
import ${GraphModelPackage}.api.c${GraphModelName?lower_case}.C${GraphModelName};

import ${CliPackage}.${GraphModelName}Execution;

import java.io.File;

import org.eclipse.core.resources.IFile;

import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.CheckViewPage;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.utils.EclipseUtils;

public class ${GraphModelName}CheckViewPage extends CheckViewPage<${GraphModelName}Id, ${GraphModelName}, C${GraphModelName}> {

	public ${GraphModelName}CheckViewPage(Object obj) {
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
		return fe.createCheckPhase(fe.initApiAdapter(EclipseUtils.getFile(file)));
	}
}

