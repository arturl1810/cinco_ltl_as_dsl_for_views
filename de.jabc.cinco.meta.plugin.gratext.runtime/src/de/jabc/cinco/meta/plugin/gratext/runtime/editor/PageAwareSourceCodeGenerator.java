package de.jabc.cinco.meta.plugin.gratext.runtime.editor;

import org.eclipse.emf.ecore.resource.Resource;

@FunctionalInterface
public interface PageAwareSourceCodeGenerator {

	String generate(Resource innerState);
}
