package de.jabc.cinco.meta.core.ge.style.ui;



import java.util.Iterator;

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
import org.eclipse.xtext.Keyword;
import org.eclipse.xtext.RuleCall;
import org.eclipse.xtext.nodemodel.BidiTreeIterable;
import org.eclipse.xtext.nodemodel.BidiTreeIterator;
import org.eclipse.xtext.nodemodel.ICompositeNode;
import org.eclipse.xtext.nodemodel.ILeafNode;
import org.eclipse.xtext.nodemodel.INode;
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

import de.jabc.cinco.meta.core.ge.style.ui.internal.StyleActivator;





public class StyleHyperLinkHelper extends HyperlinkHelper {
	@Inject
	Provider<XtextHyperlink> provider;
	
	@Inject
	IResourceServiceProvider.Registry reg;
	
	public StyleHyperLinkHelper() {
		StyleActivator.getInstance().getInjector("de.jabc.cinco.meta.core.ge.style.Style").injectMembers(this);
	}
	
	@Override
	public void createHyperlinksByOffset(XtextResource resource, int offset, IHyperlinkAcceptor acceptor) {
		
		EObjectAtOffsetHelper oHelper = new EObjectAtOffsetHelper();
		EObject object = oHelper.resolveElementAt(resource, offset);
		if (!(object instanceof Style))
			return;
		
				
		Style style = (Style) object;
		String context = style.getAppearanceProvider();
		String searchClass = context.substring(1, context.length()-1).trim();

		ICompositeNode styleNode = NodeModelUtils.getNode(style);
		INode appearanceProviderNode = findAppearanceProviderNode(styleNode);
		if (appearanceProviderNode == null) 
			return;
		
		Region region = new Region(appearanceProviderNode.getOffset(), appearanceProviderNode.getLength());
		
		String path = searchPath(searchClass);
		if (path == null){					
			return;
		}

		
		
		URIConverter uriConverter = resource.getResourceSet().getURIConverter();	
		
		URI uri = URI.createPlatformResourceURI(path, true);
		URI normUri = uri.isPlatformResource() ? uri : uriConverter.normalize(uri);
		
		XtextHyperlink xtextHyperlink = getHyperlinkProvider().get();
		xtextHyperlink.setHyperlinkRegion(region);
		xtextHyperlink.setHyperlinkText(getLabelProvider().getText(style.getName()));
		xtextHyperlink.setURI(normUri);

		acceptor.accept(xtextHyperlink);			
		
		
	}
	
	
	/**
	 * @param styleNode The AST node representing the selected Style
	 * @return The AST node representing the fully qualified name of the implementing appearance provider class
	 */
	private INode findAppearanceProviderNode(ICompositeNode styleNode) {
		BidiTreeIterator<INode> it = styleNode.getAsTreeIterable().iterator();
		while (it.hasNext()) {
			INode current = it.next();
			System.out.println(current.getGrammarElement());
			if (current.getGrammarElement() instanceof Keyword) {
				Keyword kw = (Keyword) current.getGrammarElement();
				if ("appearanceProvider".equals(kw.getValue())) {
					return findRuleCall(current);
				}
			}
		}
		return null;
	}
	
	private INode findRuleCall(INode appearanceProviderNode) {
		INode current = appearanceProviderNode;
		while (current.getNextSibling() != null) {
			EObject grammarElement = current.getGrammarElement();
			if (grammarElement instanceof RuleCall) {
				return current;
			}
			current = current.getNextSibling();
		}
		return null;
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
