package de.jabc.cinco.meta.core.ui.properties;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.xtext.resource.FileExtensionProvider;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.ui.editor.embedded.IEditedResourceProvider;
import org.eclipse.xtext.ui.resource.IResourceSetProvider;

import com.google.inject.Inject;

public class CincoResourceProvider implements IEditedResourceProvider {

	@Inject	private IResourceSetProvider resProv;
	@Inject private FileExtensionProvider ext;
	
	@Override
	public XtextResource createResource() {
		ResourceSet resourceSet = resProv.get(null);
		URI uri = URI.createURI("synthetic:/mail."+ ext.getPrimaryFileExtension());
		XtextResource result = (XtextResource) resourceSet.createResource(uri); 
		resourceSet.getResources().add(result);
		return result;
	}

}
