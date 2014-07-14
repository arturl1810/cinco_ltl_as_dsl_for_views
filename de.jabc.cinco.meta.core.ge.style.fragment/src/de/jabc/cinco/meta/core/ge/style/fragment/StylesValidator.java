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

import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;

import style.AbstractShape;
import style.ContainerShape;
import style.EdgeStyle;
import style.MultiText;
import style.NodeStyle;
import style.Style;
import style.Styles;
import style.Text;
import de.jabc.cinco.meta.core.pluginregistry.validation.ErrorPair;
import de.jabc.cinco.meta.core.pluginregistry.validation.IMetaPluginValidator;

public class StylesValidator implements IMetaPluginValidator {

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
		if (me instanceof GraphModel && annotation.getName().equals("Style"))
			ep = checkGraphModelStyleAnnotation((GraphModel) me, annotation);
		
		if (me instanceof Node && annotation.getName().equals("Style")) {
			ep = checkNodeContainerStyleAnnotation((Node) me, annotation);
		}
		if (me instanceof NodeContainer && annotation.getName().equals("Style")) {
			ep = checkNodeContainerStyleAnnotation((NodeContainer) me, annotation);
		}
		if (me instanceof Edge && annotation.getName().equals("Style")) {
			ep = checkEdgeStyleAnnotation((Edge) me, annotation);
		}
		
		return ep;
	}
	
	private ErrorPair<String, EStructuralFeature> checkNodeContainerStyleAnnotation(ModelElement me, Annotation annot) {
		Styles styles = getStyles(getGraphModel(me));
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
		
		return null;
	}
	
	private List<String> checkParameters(ModelElement me,
			EList<String> value) {
		List<String> errorMessages = new ArrayList<>();
		for (String s : value) {
			Pattern p = Pattern.compile("\\$\\{(.*)\\}");
			Matcher m = p.matcher(s);
			if (m.matches()){
				String attrName = m.group(1);
				boolean isAttr = false;
				for (Attribute attr : me.getAttributes()) {
					if (attr.getName().equals(attrName)) {
						isAttr = true;
						break;
					}
				}
				if (!isAttr)
					errorMessages.add("Parameter: " + s + " is not an attribute...\n");
			}
		}
		return errorMessages;
	}
	
	private int checkFormatStringParameters(AbstractShape main) {
		String value = "";
		if (main instanceof Text) {
			value = ((Text) main).getValue();
			String s[] = value.split("%.");
			return s.length-1;
		}
		else if (main instanceof MultiText) { 
			value = ((MultiText) main).getValue();
			String s[] = value.split("%.");
			return s.length-1;
		}
		
		if (main instanceof ContainerShape) {
			for (AbstractShape as : ((ContainerShape) main).getChildren()) {
				return checkFormatStringParameters(as);
			}
		}
		return 0;
	}
	
	private ErrorPair<String, EStructuralFeature> checkGraphModelStyleAnnotation(GraphModel gm, Annotation annot) {
		if (annot != null && annot.getValue().size() == 0) {
			return new ErrorPair<String, EStructuralFeature>("Missing path to style file", 
					annot.eClass().getEStructuralFeature("value"));
		} else {
			Styles styles = getStyles(gm);
			if (styles == null)
				return new ErrorPair<String, EStructuralFeature>("Style file " + annot.getValue().get(0)+" does not exist", 
						annot.eClass().getEStructuralFeature("value"));
		}
		return null;
	}
	
	private ModelElement getModelElement(Annotation annot) {
		return (ModelElement) annot.getParent();
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
			if ("Style".equals(a.getName())) {
				return a;
			}
		}
		return null;
	}
	
	private Styles getStyles(GraphModel gm) {
		for (Annotation a : gm.getAnnotations()) {
			if ("Style".equals(a.getName())) {
				String path = a.getValue().get(0);
				URI uri = URI.createPlatformResourceURI(path, true);
				try {
					Resource res = new ResourceSetImpl().getResource(uri, true);
					for (Object o : res.getContents()) {
						if (o instanceof Styles)
							return (Styles) o;
					}
				} catch (Exception e) {
					return null;
				}
			}
		}
		return null;
	}
	
}
