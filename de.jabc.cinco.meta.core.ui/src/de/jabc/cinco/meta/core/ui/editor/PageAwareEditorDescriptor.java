package de.jabc.cinco.meta.core.ui.editor;

import java.util.function.Function;

import org.eclipse.ui.IEditorInput;

public class PageAwareEditorDescriptor {

	private String name;
	private Class<? extends PageAwareEditor> editorClass;
	private Function<IEditorInput,PageAwareEditorInput> inputMapper;
	private PageAwareEditor editor;
	
	public PageAwareEditorDescriptor(PageAwareEditor editor) {
		this.editor = editor;
		this.editorClass = editor.getClass();
	}
	
	public PageAwareEditorDescriptor(Class<? extends PageAwareEditor> editorClass) {
		this.editorClass = editorClass;
	}
	
	public PageAwareEditorDescriptor(String name, Class<? extends PageAwareEditor> editorClass, Function<IEditorInput,PageAwareEditorInput> inputMapper) { //, Function<Resource, String> sourceCodeGenerator) {
		super();
		this.editorClass = editorClass;
		this.inputMapper = inputMapper;
		this.name = name;
	}
	
	public PageAwareEditor getEditor() {
		if (editor == null) {
			editor = newEditor();
		}
		return editor;
	}

	public String getPageName() {
		if (name == null) {
			name = getEditor().getPageName();
		}
		return name;
	}

	public Class<? extends PageAwareEditor> getEditorClass() {
		return editorClass;
	}

	public Function<IEditorInput, PageAwareEditorInput> getInputMapper() {
		if (inputMapper == null) {
			inputMapper = input -> getEditor().mapEditorInput(input);
		}
		return inputMapper;
	}
	
	public PageAwareEditor newEditor() {
		try {
			return editorClass.newInstance();
		} catch (InstantiationException | IllegalAccessException e) {
			e.printStackTrace();
			return null;
		}
	}
}
