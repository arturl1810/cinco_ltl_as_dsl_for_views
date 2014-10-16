package de.jabc.cinco.meta.core.ge.style.fragment;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import mgl.Annotation;
import mgl.Attribute;
import mgl.Edge;
import mgl.GraphModel;
import mgl.ModelElement;
import mgl.Node;
import mgl.NodeContainer;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;

import style.AbstractShape;
import style.ConnectionDecorator;
import style.ContainerShape;
import style.EdgeStyle;
import style.MultiText;
import style.NodeStyle;
import style.Style;
import style.Styles;
import style.Text;
import de.jabc.cinco.meta.core.pluginregistry.validation.ErrorPair;
import de.jabc.cinco.meta.core.pluginregistry.validation.IMetaPluginValidator;
import de.jabc.cinco.meta.core.utils.InheritanceUtil;
import de.jabc.cinco.meta.core.utils.PathValidator;

public class StylesValidator implements IMetaPluginValidator {

	private static final String ID_STYLE = "style";
	private static final String ID_ICON = "icon";
	
	public StylesValidator() {
		// TODO Auto-generated constructor stub
	}

	@Override
	public ErrorPair<String, EStructuralFeature> checkAll(EObject eObject) {
		ErrorPair<String, EStructuralFeature> ep = null;
		if ( !(eObject instanceof Annotation) )
			return null;
		Annotation annotation = (Annotation) eObject;
		ModelElement me = getModelElement((Annotation) eObject);
		if (me instanceof GraphModel && annotation.getName().equals(ID_STYLE))
			ep = checkGraphModelStyleAnnotation((GraphModel) me, annotation);
		
		if (me instanceof Node && annotation.getName().equals(ID_STYLE)) {
			ep = checkNodeContainerStyleAnnotation((Node) me, annotation);
		}
		if (me instanceof NodeContainer && annotation.getName().equals(ID_STYLE)) {
			ep = checkNodeContainerStyleAnnotation((NodeContainer) me, annotation);
		}
		if (me instanceof Edge && annotation.getName().equals(ID_STYLE)) {
			ep = checkEdgeStyleAnnotation((Edge) me, annotation);
		}
		if (annotation.getName().equals(ID_ICON)) {
			ep = checkIcon(annotation);
		}
		
		return ep;
	}
	
	private ErrorPair<String, EStructuralFeature> checkIcon(
			Annotation annotation) {
		if (annotation.getValue().size() == 0)
			return new ErrorPair<String, EStructuralFeature>(
					"Please specify an icon by relative or platform path", annotation.eClass()
					.getEStructuralFeature("value"));
		
		String path = annotation.getValue().get(0);
		String retval = PathValidator.checkPath(annotation, path);
		ErrorPair<String, EStructuralFeature> ep = new ErrorPair<String, EStructuralFeature>(
				retval ,annotation.eClass()
				.getEStructuralFeature("value"));
		return (retval.isEmpty()) ? null : ep;
	}

	private ErrorPair<String, EStructuralFeature> checkNodeContainerStyleAnnotation(ModelElement me, Annotation annot) {
		Styles styles = getStyles(getGraphModel(me));
		if (annot.getValue().size() == 0) {
			return new ErrorPair<String, EStructuralFeature>(
					"Please define a style for this style annotation", annot.eClass()
					.getEStructuralFeature("value"));
		}
		String styleName = annot.getValue().get(0);
		if (styleName == null || styleName.isEmpty())
			return new ErrorPair<String, EStructuralFeature>(
					"No style for this node defined", annot.eClass()
							.getEStructuralFeature("value"));
		if (styles == null)
			return null;
		
		Style style = null;
		for (Style s : styles.getStyles()) {
			if (s.getName().equals(styleName) ){
				if (s instanceof EdgeStyle)
					return new ErrorPair<String, EStructuralFeature>(
							"Edge style assigned to a node...",
							annot.eClass().getEStructuralFeature("value"));
				style = s;
				break;
			}
		}
		
		if (style == null) {
			return new ErrorPair<String, EStructuralFeature>(
					"Style: " + styleName +" does not exist",
					annot.eClass().getEStructuralFeature("value"));
		}
		
		NodeStyle ns = (NodeStyle) style;
		int params = checkFormatStringParameters(ns.getMainShape());
		if (params > annot.getValue().size()-1)
			return new ErrorPair<String, EStructuralFeature>(
					"Style: " + styleName +" contains text element with " + params + " parameters but you provided: " + (annot.getValue().size()-1),
					annot.eClass().getEStructuralFeature("value"));
		if (params < annot.getValue().size()-1) {
			return new ErrorPair<String, EStructuralFeature>(
					"Style: " + styleName +" contains text element with " + params + " parameters but you provided: " + (annot.getValue().size()-1),
					annot.eClass().getEStructuralFeature("value"));
		}
		else if (params == annot.getValue().size()-1) {
			List<String> errors = checkParameters(me, annot.getValue());
			if (errors != null && !errors.isEmpty()) {
				String retVal = "";
				for (String s : errors)
					retVal += s;
				return new ErrorPair<String, EStructuralFeature>(
						retVal,
						annot.eClass().getEStructuralFeature("value"));
			}
		}
		return null;
	}

	private ErrorPair<String, EStructuralFeature> checkEdgeStyleAnnotation(Edge edge, Annotation annot) {
		Styles styles = getStyles(getGraphModel(edge));
		String styleName = annot.getValue().get(0);
		if (styleName == null || styleName.isEmpty())
			return new ErrorPair<String, EStructuralFeature>(
					"No style for this node defined", annot.eClass()
							.getEStructuralFeature("value"));
		if (styles == null)
			return null;

		Style style = null;
		
		for (Style s : styles.getStyles()) {
			if (s.getName().equals(styleName) ){
				if (s instanceof NodeStyle)
					return new ErrorPair<String, EStructuralFeature>(
							"Node style assigned to this edge...",
							annot.eClass().getEStructuralFeature("value"));
				style = s;
				break;
			}
		}
		
		if (style == null) {
			return new ErrorPair<String, EStructuralFeature>(
					"Style: " + styleName +" does not exist",
					annot.eClass().getEStructuralFeature("value"));
		}
		
		EdgeStyle es = (EdgeStyle) style;
		for (ConnectionDecorator cd : es.getDecorator()) {
			if (cd.getDecoratorShape() instanceof Text) {
				int params = checkFormatStringParameters((AbstractShape) cd.getDecoratorShape());
				
				if (params > annot.getValue().size()-1)
					return new ErrorPair<String, EStructuralFeature>(
							"Style: " + styleName +" contains text element with " + params + " parameters but you provided: " + (annot.getValue().size()-1),
							annot.eClass().getEStructuralFeature("value"));
				else if (params == annot.getValue().size()-1) {
					List<String> errors = checkParameters(edge, annot.getValue());
					if (errors != null && !errors.isEmpty()) {
						String retVal = "";
						for (String s : errors)
							retVal += s;
						return new ErrorPair<String, EStructuralFeature>(
								retVal,
								annot.eClass().getEStructuralFeature("value"));
					}
				}
			}
		}
		
		return null;
	}
	
	private List<String> checkParameters(ModelElement me, EList<String> value) {
		List<String> errorMessages = new ArrayList<>();
		for (String s : value) {
			Pattern p = Pattern.compile("\\$\\{(.*)\\}");
			Matcher m = p.matcher(s);
			if (m.matches()){
				String attrName = m.group(1);
				if ( attrName.split("\\.").length > 1 ) {
					attrName = attrName.split("\\.")[0];
				}
					if (InheritanceUtil.checkMGLInheritance(me) != null && !InheritanceUtil.checkMGLInheritance(me).isEmpty())
						return errorMessages;
					boolean isAttr = false;
					List<Attribute> attributes = getAllAttributes(me);
					for (Attribute attr : attributes) {
						if (attr.getName().equals(attrName)) {
							isAttr = true;
							break;
						}
					}
					if (me instanceof Node) {
						if (((Node) me).getPrimeReference() != null && ((Node)me).getPrimeReference().getName().equals(attrName)) {
							isAttr = true;
						}
					}
				
				if (!isAttr)
					errorMessages.add("Parameter: " + s + " is not an attribute...\n");
			}
		}
		return errorMessages;
	}
	
	private List<Attribute> getAllAttributes(ModelElement me) {
		List<Attribute> attributes = new ArrayList<>();
		while (me != null) {
			attributes.addAll(me.getAttributes());
			if (me instanceof Node)
				me = ((Node) me).getExtends();
			if (me instanceof Edge)
				me = ((Edge) me).getExtends();
			if (me instanceof NodeContainer)
				me = ((NodeContainer) me).getExtends();
		}
		return attributes;
	}

	private int checkFormatStringParameters(AbstractShape main) {
		String value = "";
		if (main instanceof Text) {
			value = ((Text) main).getValue();
			int i = 0;
			for (char s : value.toCharArray()) {
				if ('%' == s)
					i++;
			}
			return i;
		}
		else if (main instanceof MultiText) { 
			value = ((MultiText) main).getValue();
			int i = 0;
			for (char s : value.toCharArray()) {
				if ('%' == s)
					i++;
			}
			return i;
		}
		
		if (main instanceof ContainerShape) {
			int retval = 0;
			for (AbstractShape as : ((ContainerShape) main).getChildren()) {
				retval += checkFormatStringParameters(as);
			}
			return retval;
		}
		return 0;
	}
	
	private ErrorPair<String, EStructuralFeature> checkGraphModelStyleAnnotation(GraphModel gm, Annotation annot) {
		if (annot != null && annot.getValue().size() == 0) {
			return new ErrorPair<String, EStructuralFeature>("Missing path to style file", 
					annot.eClass().getEStructuralFeature("value"));
		} else {
			PathValidator.checkPath(annot, annot.getValue().get(0));
			Styles styles = getStyles(gm);
			if (styles == null)
				return new ErrorPair<String, EStructuralFeature>("Style file " + annot.getValue().get(0)+" does not exist", 
						annot.eClass().getEStructuralFeature("value"));
		}
		return null;
	}
	
	private ModelElement getModelElement(Annotation annot) {
		if (annot.getParent() instanceof ModelElement)
			return (ModelElement) annot.getParent();
		return null;
	}
	
	private GraphModel getGraphModel(ModelElement me) {
		if (me instanceof Node) {
			return ((Node) me).getGraphModel();
		}
		if (me instanceof Edge) {
			return ((Edge) me).getGraphModel();
		}
		if (me instanceof NodeContainer) {
			return ((NodeContainer) me).getGraphModel();
		}
		return null;
	}
	
	private Annotation getStyleAnnotation(ModelElement me) {
		for (Annotation a : me.getAnnotations()) {
			if (ID_STYLE.equals(a.getName())) {
				return a;
			}
		}
		return null;
	}
	
	private Styles getStyles(GraphModel gm) {
		for (Annotation a : gm.getAnnotations()) {
			if (ID_STYLE.equals(a.getName())) {
				String path = a.getValue().get(0);
				URI uri = URI.createURI(path, true);
				try {
					Resource res = null;
					if (uri.isPlatformResource()) {
						res = new ResourceSetImpl().getResource(uri, true);
					}
					else {
						IProject p = ResourcesPlugin.getWorkspace().getRoot().getFile(new Path(gm.eResource().getURI().toPlatformString(true))).getProject();
						IFile file = p.getFile(path);
						if (file.exists()) {
							URI fileURI = URI.createPlatformResourceURI(file.getFullPath().toOSString(), true);
							res = new ResourceSetImpl().getResource(fileURI, true);
						}
						else {
							return null;
						}
					}
					
					for (Object o : res.getContents()) {
						if (o instanceof Styles)
							return (Styles) o;
					}
				} catch (Exception e) {
					e.printStackTrace();
					return null;
				}
			}
		}
		return null;
	}
	
}
