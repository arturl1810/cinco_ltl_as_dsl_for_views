package de.jabc.cinco.meta.core.mgl.ui;

import mgl.Annotation;
import mgl.GraphModel;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.URIConverter;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.IType;
import org.eclipse.jdt.core.JavaCore;
import org.eclipse.jdt.core.JavaModelException;
import org.eclipse.jface.text.Region;
import org.eclipse.xtext.nodemodel.ICompositeNode;
import org.eclipse.xtext.nodemodel.util.NodeModelUtils;
import org.eclipse.xtext.resource.EObjectAtOffsetHelper;
import org.eclipse.xtext.resource.IResourceServiceProvider;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.ui.editor.hyperlinking.HyperlinkHelper;
import org.eclipse.xtext.ui.editor.hyperlinking.IHyperlinkAcceptor;
import org.eclipse.xtext.ui.editor.hyperlinking.XtextHyperlink;

import style.Style;

import com.google.inject.Inject;
import com.google.inject.Provider;

import de.jabc.cinco.meta.core.mgl.ui.internal.MGLActivator;
import de.jabc.cinco.meta.core.utils.CincoUtil;
import de.jabc.cinco.meta.util.xapi.ResourceExtension;



public class MGLHyperLinkHelper extends HyperlinkHelper {

	private String[] annotationsForClasses = new String [] {
			"contextMenuAction",
			"doubleClickAction",
			"preDelete",
			"postCreate",
			"postAttributeValueChange",
			"postDelete",
			"postMove", 
			"postResize",
			"postSelect",
			"mcam_checkmodule"
	};
	
	@Inject
	Provider<XtextHyperlink> provider;
	
	@Inject
	IResourceServiceProvider.Registry reg;
	
	public MGLHyperLinkHelper() {
		MGLActivator.getInstance().getInjector("de.jabc.cinco.meta.core.mgl.MGL").injectMembers(this);
	}
	
	/**
	 * Sets Hyperlinks to all annotations in a graphmodel
	 */
	@Override
	public void createHyperlinksByOffset(XtextResource resource, int offset, IHyperlinkAcceptor acceptor) {
		EObjectAtOffsetHelper oHelper = new EObjectAtOffsetHelper();
		EObject object = oHelper.resolveElementAt(resource, offset);
		//checks if the object has an annotation
		if (!(object instanceof Annotation))
			return;
		//creates an annotation of the object
		Annotation annot = (Annotation) object;
		if ("style".equals(annot.getName())) {
			GraphModel gm = new ResourceExtension().getContent(resource, GraphModel.class, 0);
			if (gm == null)
				return;

			Style style = CincoUtil.findStyle(CincoUtil.getStyles(gm), annot.getValue().get(0));
			if (style == null)
				return;

			ICompositeNode annotNode = NodeModelUtils.getNode(annot);
			//finds the region which needs a hyperlink/hyperlink-appearance
			Region region = new Region(annotNode.getOffset(), annotNode.getLength());
			//URI of the annotation object will be generated
			URIConverter uriConverter = resource.getResourceSet().getURIConverter();
			URI uri = EcoreUtil.getURI(style);
			URI normUri = uri.isPlatformResource() ? uri : uriConverter.normalize(uri);


			//annotation in the mgl-file gets a hyperlink/hyperlink-apperance
			XtextHyperlink xtextHyperlink = getHyperlinkProvider().get();
			xtextHyperlink.setHyperlinkRegion(region);
			xtextHyperlink.setHyperlinkText(getLabelProvider().getText(style));
			xtextHyperlink.setURI(normUri);

			acceptor.accept(xtextHyperlink);
		} 
		
		else if (isJavaClassAnnotation(annot.getName())) {
			GraphModel gModel = new ResourceExtension().getContent(resource, GraphModel.class, 0);
			if(gModel == null){
				return;
			}

			EObject contextMenu = (EObject) annot;

			ICompositeNode annotNode = NodeModelUtils.getNode(annot);
			//finds the region which needs a hyperlink/hyperlink-appearance
			Region region = new Region(annotNode.getOffset(), annotNode.getLength());

			URIConverter uriConverter = resource.getResourceSet().getURIConverter();	
			//reads the text of the annotation
			URI uri2 = URI.createURI(annot.getValue().get(0));
			String URI2 =  uri2.toString();
			//finds the class to the annotation-text 
			String path = searchPath(URI2);
			if (path == null){
				return;
			}
			
			//creates the URI
			URI uri = URI.createPlatformResourceURI(path, true);
			URI normUri = uri.isPlatformResource() ? uri : uriConverter.normalize(uri);

			//annotation in the mgl-file gets a hyperlink/hyperlink-apperance
			XtextHyperlink xtextHyperlink = getHyperlinkProvider().get();
			xtextHyperlink.setHyperlinkRegion(region);
			xtextHyperlink.setHyperlinkText(getLabelProvider().getText(contextMenu));
			xtextHyperlink.setURI(normUri);

			acceptor.accept(xtextHyperlink);
		}
		
	}
		private boolean isJavaClassAnnotation(String annotName) {
			for (String knownName : annotationsForClasses) {
				if (knownName.equals(annotName))
					return true;
			}
			return false;
		}
	

	/**
	 * Searches for a class by  a search word
	 * @param searchClass is the search word
	 * @return returns the path of the wanted class
	 */
	private String searchPath(String searchClass){
		String path = null;
		IWorkspaceRoot root = ResourcesPlugin.getWorkspace().getRoot();
		//get Projects 
				IProject [] projects = root.getProjects();
				for (IProject iProject : projects) {
					IJavaProject jproject = JavaCore.create(iProject);
					// Search only in existing projects
					if (!jproject.exists())
						continue;
					//get packages 
					try {
						IType type = jproject.findType(searchClass);
						if (type != null) {
							return type.getPath().toString();
						}
					} catch (JavaModelException e) {
						e.printStackTrace();
					}
				}		
		return path;
	}
}
