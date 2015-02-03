package de.jabc.cinco.meta.core.mgl.ui;

import mgl.Annotation;
import mgl.GraphModel;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.URIConverter;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.jface.text.Region;
import org.eclipse.jface.text.hyperlink.IHyperlink;
import org.eclipse.xtext.nodemodel.ICompositeNode;
import org.eclipse.xtext.nodemodel.util.NodeModelUtils;
import org.eclipse.xtext.resource.EObjectAtOffsetHelper;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.ui.editor.hyperlinking.HyperlinkHelper;
import org.eclipse.xtext.ui.editor.hyperlinking.HyperlinkLabelProvider;
import org.eclipse.xtext.ui.editor.hyperlinking.IHyperlinkAcceptor;
import org.eclipse.xtext.ui.editor.hyperlinking.XtextHyperlink;

import com.google.inject.Inject;
import com.google.inject.Provider;

import style.Style;
import de.jabc.cinco.meta.core.utils.CincoUtils;

public class MGLHyperLinkHelper extends HyperlinkHelper {

	@Inject@HyperlinkLabelProvider
	Provider<XtextHyperlink> provider;
	
	@Override
	public void createHyperlinksByOffset(XtextResource resource, int offset, IHyperlinkAcceptor acceptor) {
		EObjectAtOffsetHelper oHelper = new EObjectAtOffsetHelper();
		EObject object = oHelper.resolveElementAt(resource, offset);
		if (!(object instanceof Annotation))
			return;
		Annotation annot = (Annotation) object;
		GraphModel gm = CincoUtils.getGraphModel(resource);
		if (gm == null)
			return;
		Style style = CincoUtils.findStyle(CincoUtils.getStyles(gm), annot.getValue().get(0));
		if (style == null)
			return;
		
		ICompositeNode annotNode = NodeModelUtils.getNode(annot);
		ICompositeNode styleNode = NodeModelUtils.getNode(style);
		
		Region region = new Region(annotNode.getOffset(), annotNode.getLength());
		
		URIConverter uriConverter = resource.getResourceSet().getURIConverter();
		URI uri = EcoreUtil.getURI(style);
		URI normUri = uri.isPlatformResource() ? uri : uriConverter.normalize(uri);
		
		XtextHyperlink xtextHyperlink = provider.get();
		xtextHyperlink.setHyperlinkRegion(region);
		xtextHyperlink.setHyperlinkText(NodeModelUtils.getTokenText(styleNode));
		xtextHyperlink.setURI(normUri);
		
		
	}
	
}
