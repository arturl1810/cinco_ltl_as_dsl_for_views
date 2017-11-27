package file

import de.jabc.cinco.meta.plugin.template.FileTemplate

class EditorTmpl extends FileTemplate {
	
	override getTargetFileName() '''«model.name»GratextEditor.java'''
	
	override template() '''
		package «package»;
		
		import de.jabc.cinco.meta.plugin.gratext.runtime.editor.MultiPageGratextEditor;
		import org.eclipse.xtext.ui.editor.XtextEditor;
		
		public class «model.name»GratextEditor extends MultiPageGratextEditor {
		
			@Override
			protected XtextEditor getSourceEditor() {
				«model.name»GratextExecutableExtensionFactory fac = new «model.name»GratextExecutableExtensionFactory();
				try {
					Class<?> clazz = fac.getBundle().loadClass("org.eclipse.xtext.ui.editor.XtextEditor");
					Object editor = fac.getInjector().getInstance(clazz);
					return (XtextEditor) editor;
				} catch (ClassNotFoundException e) {
					e.printStackTrace();
					return null;
				}
			}
		}
	'''
	
}