package de.jabc.cinco.meta.plugin.gratext.runtime.editor;

import java.util.function.Function;

import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.ui.IEditorInput;

public class PageAwareEditorDescriptor {

	private String name;
	private Class<? extends PageAwareEditorPart> editorClass;
	private Function<IEditorInput,PageAwareEditorInput> inputMapper;
	private Function<Resource, String> sourceCodeGenerator;
	
	public PageAwareEditorDescriptor(String name, Class<? extends PageAwareEditorPart> editorClass, Function<IEditorInput,PageAwareEditorInput> inputMapper, Function<Resource, String> sourceCodeGenerator) {
		super();
		this.editorClass = editorClass;
		this.inputMapper = inputMapper;
		this.name = name;
		this.sourceCodeGenerator = sourceCodeGenerator;
	}

	public String getName() {
		return name;
	}

	public Class<? extends PageAwareEditorPart> getEditorClass() {
		return editorClass;
	}

	public Function<IEditorInput, PageAwareEditorInput> getInputMapper() {
		return inputMapper;
	}

	public Function<Resource, String> getSourceCodeGenerator() {
		return sourceCodeGenerator;
	}
	
	public PageAwareEditorPart newEditor() {
		try {
			return editorClass.newInstance();
		} catch (InstantiationException | IllegalAccessException e) {
			e.printStackTrace();
			return null;
		}
	}
}
