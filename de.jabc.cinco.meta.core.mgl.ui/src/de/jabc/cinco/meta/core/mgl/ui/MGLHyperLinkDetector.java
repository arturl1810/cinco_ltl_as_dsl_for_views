package de.jabc.cinco.meta.core.mgl.ui;

import mgl.Annotatable;
import mgl.Annotation;
import mgl.Attribute;
import mgl.GraphModel;
import mgl.ModelElement;
import mgl.Type;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.URIConverter;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.resource.impl.URIConverterImpl;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.ITextViewer;
import org.eclipse.jface.text.Region;
import org.eclipse.jface.text.hyperlink.IHyperlink;
import org.eclipse.jface.text.hyperlink.IHyperlinkDetector;
import org.eclipse.xtext.nodemodel.ICompositeNode;
import org.eclipse.xtext.nodemodel.util.NodeModelUtils;
import org.eclipse.xtext.resource.EObjectAtOffsetHelper;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.ui.editor.XtextSourceViewer;
import org.eclipse.xtext.ui.editor.hyperlinking.HyperlinkHelper;
import org.eclipse.xtext.ui.editor.hyperlinking.XtextHyperlink;
import org.eclipse.xtext.ui.editor.model.XtextDocument;
import org.eclipse.xtext.util.TextRegion;

import de.jabc.cinco.meta.core.utils.CincoUtils;
import style.Style;
import style.Styles;

public class MGLHyperLinkDetector implements IHyperlinkDetector {

	@Override
	public IHyperlink[] detectHyperlinks(ITextViewer textViewer,
			IRegion region, boolean canShowMultipleHyperlinks) {
		
		if (!(textViewer instanceof XtextSourceViewer))
			return null;
		
		XtextSourceViewer viewer = (XtextSourceViewer) textViewer;
		XtextDocument doc = (XtextDocument) viewer.getInput();
		Resource res = new ResourceSetImpl().getResource(doc.getResourceURI(), true);
		
		IHyperlink[] hyperHyper = new MGLHyperLinkHelper().createHyperlinksByOffset((XtextResource) res, region.getOffset(), canShowMultipleHyperlinks);
		return hyperHyper;
	}

}

class MGLHyperLinkHelper extends HyperlinkHelper {
	
	@Override
	public IHyperlink[] createHyperlinksByOffset(XtextResource resource,
			int offset, boolean createMultipleHyperlinks) {
		
		EObjectAtOffsetHelper helper = new EObjectAtOffsetHelper();
		EObject semanticObject = helper.resolveElementAt(resource, offset);
		
		XtextHyperlink hyperLink = getHyperLinkForObject(semanticObject);
		
		return new IHyperlink[] {hyperLink};
	}

	private XtextHyperlink getHyperLinkForObject(EObject semanticObject) {
		if (!(semanticObject instanceof Annotation)) 
			return null;
		Annotation annot = (Annotation) semanticObject;
		String name = annot.getName();
		Styles styles = null;
		Style style = null;
		Resource stylesRes = null;
		if ("style".equals(name)) {
			String styleName = annot.getValue().get(0);
			GraphModel gm = getGraphModel(annot);
			String stylePath = null;
			
			for (Annotation a : gm.getAnnotations()) {
				if ("style".equals(a.getName())) {
					stylePath = a.getValue().get(0);
				}
			}
			
			URI resURI = semanticObject.eResource().getURI();
			IProject p = null;
			for (String s : resURI.segments()) {
				p = ResourcesPlugin.getWorkspace().getRoot().getProject(s);
				if (p.exists())
					break;
			}
			
			
			stylesRes = CincoUtils.getStylesResource(stylePath, p);
			for (EObject o : stylesRes.getContents()) {
				if (o instanceof Styles) {
					styles = (Styles) o;
					break;
				}
			}
			if (styles != null) {
				for (Style s: styles.getStyles())
					if (s.getName().equals(styleName)){
						style = s;
						break;
					}
			}
			
			
			
		}
		
		EObjectAtOffsetHelper helper = new EObjectAtOffsetHelper();
		ICompositeNode node = NodeModelUtils.findActualNodeFor(style);
		Region toRegion = new Region(node.getOffset(), node.getLength());
		
		XtextHyperlink xtextHyperlink = getHyperlinkProvider().get();
		xtextHyperlink.setHyperlinkRegion(toRegion);
		xtextHyperlink.setHyperlinkText(getLabelProvider().getText(semanticObject));
		xtextHyperlink.setURI(stylesRes.getURI());
		
		return xtextHyperlink;
	}

	private GraphModel getGraphModel(Annotation annot) {
		GraphModel gm = null;
		for (EObject o :annot.eResource().getContents()) {
			if (o instanceof GraphModel)
				return (GraphModel) o;
		}
		
		
		return gm;
	}
	
}