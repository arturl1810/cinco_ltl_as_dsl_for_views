package de.jabc.cinco.meta.plugin.gratext.template

class GratextEditorTemplate extends AbstractGratextTemplate {
			
def parentPackage() { 
	project.basePackage.substring(0, project.basePackage.lastIndexOf("."))
}
			
override template()
'''
package «project.basePackage»;

import static de.jabc.cinco.meta.plugin.gratext.runtime.util.GratextUtils.getUri;
import de.jabc.cinco.meta.plugin.gratext.runtime.editor.MultiPageGratextEditor;
import de.jabc.cinco.meta.plugin.gratext.runtime.editor.PageAwareDiagramEditorInput;
import de.jabc.cinco.meta.plugin.gratext.runtime.editor.PageAwareEditorDescriptor;
import «parentPackage».generator.«model.name»BackupGenerator;

import java.util.Arrays;

import org.eclipse.xtext.ui.editor.XtextEditor;


public class «model.name»GratextEditor extends MultiPageGratextEditor {

	// TODO for debugging only, remove
 	private void print(String msg) {
 		System.out.println("[" + getClass().getSimpleName() + "] " + msg);
 	}
	
	@Override
	protected XtextEditor getSourceEditor() {
		«model.name»GratextExecutableExtensionFactory fac = new «model.name»GratextExecutableExtensionFactory();
		print("getSourceEditor > factory: " + fac);
		try {
			Class<?> clazz = fac.getBundle().loadClass("org.eclipse.xtext.ui.editor.XtextEditor");
			print("getSourceEditor > class: " + clazz);
			Object editor = fac.getInjector().getInstance(clazz);
			print("getSourceEditor > editor: " + editor);
			return (XtextEditor) editor;
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
			return null;
		}
	}

	@Override
	protected Iterable<PageAwareEditorDescriptor> getEditorDescriptors() {
		return Arrays.asList(new PageAwareEditorDescriptor[] {
			new PageAwareEditorDescriptor("Diagram", PageAware«model.name»DiagramEditor.class,
				editorInput -> new PageAwareDiagramEditorInput(getUri(editorInput)),
				innerState -> new «model.name»BackupGenerator().toText(innerState))
		});
	}
}
'''
}