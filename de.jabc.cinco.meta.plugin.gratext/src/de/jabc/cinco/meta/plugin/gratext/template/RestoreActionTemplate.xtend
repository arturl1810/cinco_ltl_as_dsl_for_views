package de.jabc.cinco.meta.plugin.gratext.template

class RestoreActionTemplate extends AbstractGratextTemplate {
		
def restoreGenerator() {
	fileFromTemplate(ModelGeneratorTemplate)
}
		
override template()
'''	
package «project.basePackage».generator;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IPath;

public class RestoreAction extends de.jabc.cinco.meta.plugin.gratext.runtime.action.RestoreAction {

	@Override
	public void run(IFile file, IPath targetFolder) {
		new «restoreGenerator.classSimpleName»().doGenerate(file, targetFolder.toOSString());
	}
}
'''
}