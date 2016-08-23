package de.jabc.cinco.meta.core.mgl.ui;

import mgl.Annotation;
import mgl.ModelElement;

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
	private IHyperlinkHelper helper;
	
	@Override
	public IHyperlink[] detectHyperlinks(ITextViewer textViewer,
			IRegion region, boolean canShowMultipleHyperlinks) {
		
		if (!(textViewer instanceof XtextSourceViewer))
			return null;
		
		XtextSourceViewer viewer = (XtextSourceViewer) textViewer; //Viewer holen
		XtextDocument doc = (XtextDocument) viewer.getInput();  //Datei (mgl) holen
		
		Resource res = new ResourceSetImpl().getResource(doc.getResourceURI(), true); //uri-pfad
		
		//Helper um object zu erstellen
		EObjectAtOffsetHelper resolver = new EObjectAtOffsetHelper();
		//Object wird erstellt
		EObject object = resolver.resolveElementAt((XtextResource) res, region.getOffset());
		//Object enthält annotation-name:style, value: [redCircle]
		
		
		//Wenn Object eine Annotation ist und zu einem Modelelement gehört (Knoten/Kante)
		if (object instanceof Annotation && ((Annotation) object).getParent() instanceof ModelElement) {
			//neuer Linkhelper wird erstellt, HyperLinks werden erstellt und zurückgegeben
			return new MGLHyperLinkHelper().createHyperlinksByOffset((XtextResource) res, region.getOffset(), canShowMultipleHyperlinks);
		} else {
			//auf dem vorhandenen helper (@Inject) werden Hyperlinks erstellt und zurückgegeben
			return helper.createHyperlinksByOffset((XtextResource) res, region.getOffset(), canShowMultipleHyperlinks) ;
		}
		
	}

}
