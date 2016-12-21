package de.jabc.cinco.meta.plugin.gratext.template

class BackupActionTemplate extends AbstractGratextTemplate {
		
def backupGenerator() {
	fileFromTemplate(SerializerTemplate)
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
		BackupGenerator<?> generator = new «backupGenerator.classSimpleName»();
		generator.setIdSuffix("GRATEXT");
		try {
			generator.doGenerate(file, targetFolder.toOSString());
		} catch(Exception e) {
			e.printStackTrace();
		}
	}
}
'''
}