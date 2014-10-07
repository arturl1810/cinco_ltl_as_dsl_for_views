package de.jabc.cinco.meta.core.ge.style.fragment;

import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import mgl.Annotation;
import mgl.Edge;
import mgl.GraphModel;
import mgl.Node;
import mgl.NodeContainer;
import mgl.Type;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal.IReplacementTextApplier;

import style.EdgeStyle;
import style.NodeStyle;
import style.Style;
import style.Styles;
import de.jabc.cinco.meta.core.pluginregistry.proposalprovider.IMetaPluginAcceptor;
import de.jabc.cinco.meta.core.utils.xtext.ChooseFileTextApplier;

public class StyleValueProposalProvider implements IMetaPluginAcceptor {

	private final String STYLE_ID = "style";
	private final String ICON_ID = "icon";
	
	public StyleValueProposalProvider() {
		// TODO Auto-generated constructor stub
	}

	@Override
	public List<String> getAcceptedStrings(Annotation annotation) {
		String annotName = annotation.getName();
		Styles styles;
		if (STYLE_ID.equals(annotName)) {
			if(annotation.getParent() instanceof Type){
				Type type = (Type) annotation.getParent();
				GraphModel gModel = null;
				try {
					if (type instanceof Node) {
						gModel = ((Node) type).getGraphModel();
						styles = getStyles(gModel);
						return getNodeStyles(styles);
					}
					if (type instanceof Edge) {
						gModel = ((Edge) type).getGraphModel();
						styles = getStyles(gModel);
						return getEdgeStyles(styles);
					}
					if (type instanceof NodeContainer) {
						gModel = ((NodeContainer) type).getGraphModel();
						styles = getStyles(gModel);
						return getNodeStyles(styles);
						
					}
					if (type instanceof GraphModel) {
						gModel = (GraphModel) type;
						return Collections.emptyList();
					}
				} catch (FileNotFoundException fnfe) {
					return Collections.emptyList();
				}
			}
		}
		
		if (ICON_ID.equals(annotName)) {
			List<String> ret = new ArrayList<>();
			ret.add("Choose file...");
			return ret;
		}
			
		
		return Collections.emptyList();
				
	}
	
	private List<String> getNodeStyles(Styles styles) {
		List<String> nodeStyles = new ArrayList<>();
		for (Style s : styles.getStyles()) {
			if (s instanceof NodeStyle) {
				nodeStyles.add(s.getName());
			}
		}
		return nodeStyles;
	}
	
	private List<String> getEdgeStyles(Styles styles) {
		List<String> edgeStyles = new ArrayList<>();
		for (Style s : styles.getStyles()) {
			if (s instanceof EdgeStyle) {
				edgeStyles.add(s.getName());
			}
		}
		return edgeStyles;
	}

	private Styles getStyles(GraphModel gModel) throws FileNotFoundException {
		for (Annotation annot : gModel.getAnnotations()) {
			if (STYLE_ID.equals(annot.getName())) {
				String path = annot.getValue().get(0);
				URI uri = URI.createURI(annot.getValue().get(0), true);
				Resource res = null;
				if (uri.isPlatformResource())
					res = new ResourceSetImpl().getResource(uri, true);
				else {
					IProject p = ResourcesPlugin.getWorkspace().getRoot().getFile(new Path(gModel.eResource().getURI().toPlatformString(true))).getProject();
					IFile file = p.getFile(path);
					URI fileURI = URI.createPlatformResourceURI(file.getFullPath().toOSString(), true);
					res = new ResourceSetImpl().getResource(fileURI, true);
				}
				if (res == null) {
					throw new FileNotFoundException(annot.getValue().get(0));
				}
				
				Object o = res.getContents().get(0);
				if (o instanceof Styles) 
					return (Styles) o;
				else throw new FileNotFoundException(annot.getValue().get(0));
			}
		}
		return null;
	}

	@Override
	public IReplacementTextApplier getTextApplier(Annotation annotation) {
		if (ICON_ID.equals(annotation.getName())) {
			return new ChooseFileTextApplier(annotation);
		}
		return null;
	}

}
