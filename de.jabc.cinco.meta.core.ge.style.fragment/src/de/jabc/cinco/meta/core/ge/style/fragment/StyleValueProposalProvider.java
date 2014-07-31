package de.jabc.cinco.meta.core.ge.style.fragment;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;

import style.Style;
import style.Styles;
import mgl.Annotation;
import mgl.Edge;
import mgl.GraphModel;
import mgl.Node;
import mgl.NodeContainer;
import mgl.Type;
import de.jabc.cinco.meta.core.pluginregistry.proposalprovider.IMetaPluginAcceptor;

public class StyleValueProposalProvider implements IMetaPluginAcceptor {

	public StyleValueProposalProvider() {
		// TODO Auto-generated constructor stub
	}

	@Override
	public List<String> getAcceptedStrings(Annotation annotation) {
		String annotName = annotation.getName();
		if ("style".equals(annotName)) {
			if(annotation.getParent() instanceof Type){
				Type type = (Type) annotation.getParent();
				GraphModel gModel = null;
				if (type instanceof Node)
					gModel = ((Node) type).getGraphModel();
				if (type instanceof Edge)
					gModel = ((Edge) type).getGraphModel();
				if (type instanceof NodeContainer)
					gModel = ((NodeContainer) type).getGraphModel();
				if (type instanceof GraphModel)
					gModel = (GraphModel) type;
				
				for (Annotation annot : gModel.getAnnotations()) {
					if ("style".equals(annot.getName())) {
						IPath filePath = new Path(annot.getValue().get(0)); 
						IFile file = ResourcesPlugin.getWorkspace().getRoot().getFile(filePath);
						
						if (file == null) 
							return new ArrayList<String>();
						URI fileURI = URI.createPlatformResourceURI(filePath.toOSString(), true);
						Resource res = new ResourceSetImpl().getResource(fileURI, true);
						if (res == null) {
							return new ArrayList<String>();
						}
						
						Object o = res.getContents().get(0);
						if (o instanceof Styles) {
							ArrayList<String> styleNames = new ArrayList<String>();
							Styles styles = (Styles) o;
							for (Style s : styles.getStyles()) {
								styleNames.add(s.getName());
							}
							return styleNames;
						}
						
					}
				}
			}
		}
		return new ArrayList<String>();
	}

}
