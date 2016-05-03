package de.jabc.cinco.meta.plugin.gratext.template

class BackupActionTemplate extends AbstractGratextTemplate {
		
def backupGenerator() {
	fileFromTemplate(BackupGeneratorTemplate)
}
		
override template()
'''	
package «project.basePackage».generator;

import de.jabc.cinco.meta.plugin.gratext.runtime.generator.BackupGenerator;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IPath;

public class BackupAction extends de.jabc.cinco.meta.plugin.gratext.runtime.action.BackupAction {

	@Override
	public void run(IFile file, IPath targetFolder) {
		BackupGenerator<?> generator = new «backupGenerator.nameWithoutExtension»();
		generator.setIdSuffix("GRATEXT");
		generator.doGenerate(file, targetFolder.toOSString());
	}
}
'''
}