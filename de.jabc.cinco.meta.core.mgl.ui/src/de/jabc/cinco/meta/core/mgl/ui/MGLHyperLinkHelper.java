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
import org.eclipse.jdt.core.ICompilationUnit;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.IPackageFragment;
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
import de.jabc.cinco.meta.core.utils.CincoUtils;

public class MGLHyperLinkHelper extends HyperlinkHelper {

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
			GraphModel gm = CincoUtils.getGraphModel(resource);
			if (gm == null)
				return;

			Style style = CincoUtils.findStyle(CincoUtils.getStyles(gm), annot.getValue().get(0));
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
		
		else if ("contextMenuAction".equals(annot.getName())){
			GraphModel gModel = CincoUtils.getGraphModel(resource);
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
		
		
		else if ("doubleClickAction".equals(annot.getName())){
			GraphModel gModel = CincoUtils.getGraphModel(resource);
			if(gModel == null){
				return;
			}
			EObject doubleClick = (EObject) annot;

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
			//Creates the URI
			URI uri = URI.createPlatformResourceURI(path, true);
			URI normUri = uri.isPlatformResource() ? uri : uriConverter.normalize(uri);

			//annotation in the mgl-file gets a hyperlink/hyperlink-apperance
			XtextHyperlink xtextHyperlink = getHyperlinkProvider().get();
			xtextHyperlink.setHyperlinkRegion(region);
			xtextHyperlink.setHyperlinkText(getLabelProvider().getText(doubleClick));
			xtextHyperlink.setURI(normUri);

			acceptor.accept(xtextHyperlink);	

		}
		
		else if ("postCreate".equals(annot.getName())) {
			GraphModel gModel = CincoUtils.getGraphModel(resource);
			if(gModel == null){
				return;
			}

			EObject postCreate = (EObject) annot;

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
			//Creates URI
			URI uri = URI.createPlatformResourceURI(path, true);
			URI normUri = uri.isPlatformResource() ? uri : uriConverter.normalize(uri);

			//annotation in the mgl-file gets a hyperlink/hyperlink-apperance
			XtextHyperlink xtextHyperlink = getHyperlinkProvider().get();
			xtextHyperlink.setHyperlinkRegion(region);
			xtextHyperlink.setHyperlinkText(getLabelProvider().getText(postCreate));
			xtextHyperlink.setURI(normUri);

			acceptor.accept(xtextHyperlink);
		}
						
		else if ("postAttributeValueChange".equals(annot.getName())){
			GraphModel gModel = CincoUtils.getGraphModel(resource);
			if(gModel == null){
				return;
			}
			EObject post = (EObject) annot;

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
			//Creates URI
			URI uri = URI.createPlatformResourceURI(path, true);
			URI normUri = uri.isPlatformResource() ? uri : uriConverter.normalize(uri);

			//annotation in the mgl-file gets a hyperlink/hyperlink-apperance
			XtextHyperlink xtextHyperlink = getHyperlinkProvider().get();
			xtextHyperlink.setHyperlinkRegion(region);
			xtextHyperlink.setHyperlinkText(getLabelProvider().getText(post));
			xtextHyperlink.setURI(normUri);

			acceptor.accept(xtextHyperlink);
		}
		else if ("preDelete".equals(annot.getName())){
			GraphModel gModel = CincoUtils.getGraphModel(resource);
			if(gModel == null){
				return;
			}
			EObject pre = (EObject) annot;

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
			//Creates URI
			URI uri = URI.createPlatformResourceURI(path, true);
			URI normUri = uri.isPlatformResource() ? uri : uriConverter.normalize(uri);

			//annotation in the mgl-file gets a hyperlink/hyperlink-apperance
			XtextHyperlink xtextHyperlink = getHyperlinkProvider().get();
			xtextHyperlink.setHyperlinkRegion(region);
			xtextHyperlink.setHyperlinkText(getLabelProvider().getText(pre));
			xtextHyperlink.setURI(normUri);

			acceptor.accept(xtextHyperlink);
		}
		
		else if("postMove".equals(annot.getName())){
			GraphModel gModel = CincoUtils.getGraphModel(resource);
			if(gModel == null){
				return;
			}
			EObject postMove = (EObject) annot;

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
			//Creates URI
			URI uri = URI.createPlatformResourceURI(path, true);
			URI normUri = uri.isPlatformResource() ? uri : uriConverter.normalize(uri);

			//annotation in the mgl-file gets a hyperlink/hyperlink-apperance
			XtextHyperlink xtextHyperlink = getHyperlinkProvider().get();
			xtextHyperlink.setHyperlinkRegion(region);
			xtextHyperlink.setHyperlinkText(getLabelProvider().getText(postMove));
			xtextHyperlink.setURI(normUri);

			acceptor.accept(xtextHyperlink);
		}
		
		else if("postResize".equals(annot.getName())){
			//Graphmodel wird entnommen
			GraphModel gModel = CincoUtils.getGraphModel(resource);
			if(gModel == null){
				return;
			}
			EObject postRe = (EObject) annot;

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
			//Creates URI
			URI uri = URI.createPlatformResourceURI(path, true);
			URI normUri = uri.isPlatformResource() ? uri : uriConverter.normalize(uri);

			//annotation in the mgl-file gets a hyperlink/hyperlink-apperance
			XtextHyperlink xtextHyperlink = getHyperlinkProvider().get();
			xtextHyperlink.setHyperlinkRegion(region);
			xtextHyperlink.setHyperlinkText(getLabelProvider().getText(postRe));
			xtextHyperlink.setURI(normUri);

			acceptor.accept(xtextHyperlink);
		}
		
		else if ("postSelect".equals(annot.getName())){
			//Graphmodel wird entnommen
			GraphModel gModel = CincoUtils.getGraphModel(resource);
			if(gModel == null){
				return;
			}
			EObject postSe = (EObject) annot;

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
			//Creates URI
			URI uri = URI.createPlatformResourceURI(path, true);
			URI normUri = uri.isPlatformResource() ? uri : uriConverter.normalize(uri);

			//annotation in the mgl-file gets a hyperlink/hyperlink-apperance
			XtextHyperlink xtextHyperlink = getHyperlinkProvider().get();
			xtextHyperlink.setHyperlinkRegion(region);
			xtextHyperlink.setHyperlinkText(getLabelProvider().getText(postSe));
			xtextHyperlink.setURI(normUri);

			acceptor.accept(xtextHyperlink);
		}
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
					//get packages 
					try {
						IPackageFragment[] packages = jproject.getPackageFragments();
						for (IPackageFragment iPackageFragment : packages) {
							//get files 
							ICompilationUnit[] files = iPackageFragment.getCompilationUnits();
							for (ICompilationUnit iCompilationUnit : files) {
								//searches the class with the same name as the searchClass
								String foundClass = iCompilationUnit.getElementName().substring(0, iCompilationUnit.getElementName().lastIndexOf("."));
								foundClass = iCompilationUnit.getParent().getElementName()+ "." + foundClass;
								if(foundClass.equals(searchClass)){
									path = iCompilationUnit.getPath().toString();
								}								
							}
						}
					} catch (JavaModelException e) {}
				}		
		return path;
	}
}
