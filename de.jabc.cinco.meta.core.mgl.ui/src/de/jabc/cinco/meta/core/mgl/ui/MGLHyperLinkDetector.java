package de.jabc.cinco.meta.core.mgl.ui;

import mgl.Annotation;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.ITextViewer;
import org.eclipse.jface.text.hyperlink.IHyperlink;
import org.eclipse.jface.text.hyperlink.IHyperlinkDetector;
import org.eclipse.xtext.resource.EObjectAtOffsetHelper;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.ui.editor.XtextSourceViewer;
import org.eclipse.xtext.ui.editor.hyperlinking.IHyperlinkHelper;
import org.eclipse.xtext.ui.editor.model.XtextDocument;

import com.google.inject.Inject;

public class MGLHyperLinkDetector implements IHyperlinkDetector {

	@Inject
	IHyperlinkHelper helper;
	
	@Override
	public IHyperlink[] detectHyperlinks(ITextViewer textViewer,
			IRegion region, boolean canShowMultipleHyperlinks) {
		
		if (!(textViewer instanceof XtextSourceViewer))
			return null;
		
		XtextSourceViewer viewer = (XtextSourceViewer) textViewer;
		XtextDocument doc = (XtextDocument) viewer.getInput();
		
		Resource res = new ResourceSetImpl().getResource(doc.getResourceURI(), true);
		
		EObjectAtOffsetHelper resolver = new EObjectAtOffsetHelper();
		EObject object = resolver.resolveElementAt((XtextResource) res, region.getOffset());
		
		if (object instanceof Annotation) {
			return new MGLHyperLinkHelper().createHyperlinksByOffset((XtextResource) res, region.getOffset(), canShowMultipleHyperlinks);
		} else {
			return helper.createHyperlinksByOffset((XtextResource) res, region.getOffset(), canShowMultipleHyperlinks) ;
		}
		
	}

}
