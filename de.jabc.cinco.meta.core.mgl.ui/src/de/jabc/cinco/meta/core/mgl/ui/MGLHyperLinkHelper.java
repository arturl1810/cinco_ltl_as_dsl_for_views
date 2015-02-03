package de.jabc.cinco.meta.core.mgl.ui;

import mgl.Annotation;
import mgl.GraphModel;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.URIConverter;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.jface.text.Region;
import org.eclipse.jface.text.hyperlink.IHyperlink;
import org.eclipse.jface.viewers.ILabelProvider;
import org.eclipse.xtext.nodemodel.ICompositeNode;
import org.eclipse.xtext.nodemodel.util.NodeModelUtils;
import org.eclipse.xtext.resource.EObjectAtOffsetHelper;
import org.eclipse.xtext.resource.IResourceServiceProvider;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.ui.editor.GlobalURIEditorOpener;
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
		
		Region region = new Region(annotNode.getOffset(), annotNode.getLength());
		
		URIConverter uriConverter = resource.getResourceSet().getURIConverter();
		URI uri = EcoreUtil.getURI(style);
		URI normUri = uri.isPlatformResource() ? uri : uriConverter.normalize(uri);
		
		XtextHyperlink xtextHyperlink = getHyperlinkProvider().get();
		xtextHyperlink.setHyperlinkRegion(region);
		xtextHyperlink.setHyperlinkText(getLabelProvider().getText(style));
		xtextHyperlink.setURI(normUri);
		
		acceptor.accept(xtextHyperlink);
	}
	
}
