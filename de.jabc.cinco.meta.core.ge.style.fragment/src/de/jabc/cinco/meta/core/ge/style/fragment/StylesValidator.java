package de.jabc.cinco.meta.core.ge.style.fragment;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import mgl.Annotation;
import mgl.Attribute;
import mgl.Edge;
import mgl.GraphModel;
import mgl.MglPackage;
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

import style.EdgeStyle;
import style.NodeStyle;
import style.Style;
import style.Styles;
import de.jabc.cinco.meta.core.pluginregistry.validation.ValidationResult;
import de.jabc.cinco.meta.core.pluginregistry.validation.IMetaPluginValidator;
import de.jabc.cinco.meta.core.utils.CincoUtil;
import de.jabc.cinco.meta.core.utils.PathValidator;

import static de.jabc.cinco.meta.core.pluginregistry.validation.ValidationResult.newError;

public class StylesValidator implements IMetaPluginValidator {

	public StylesValidator() {

	}

	@Override
	public ValidationResult<String, EStructuralFeature> checkAll(EObject eObject) {
		ValidationResult<String, EStructuralFeature> ep = null;
		if ( !(eObject instanceof Annotation) )
			return null;
		Annotation annotation = (Annotation) eObject;
		ModelElement me = getModelElement((Annotation) eObject);
		if (me instanceof GraphModel) {
			if (annotation.getName().equals(CincoUtil.ID_STYLE))
				ep = checkGraphModelStyleAnnotation((GraphModel) me, annotation);
			if (annotation.getName().equals(CincoUtil.ID_DISABLE_HIGHLIGHT)) 
				ep = checkGraphModelDisableHighlight((GraphModel) me, annotation);
		}
			
		if (me instanceof Node && annotation.getName().equals(CincoUtil.ID_STYLE)) {
			ep = checkNodeContainerStyleAnnotation((Node) me, annotation);
		}
		if (me instanceof NodeContainer && annotation.getName().equals(CincoUtil.ID_STYLE)) {
			ep = checkNodeContainerStyleAnnotation((NodeContainer) me, annotation);
		}
		if (me instanceof Edge && annotation.getName().equals(CincoUtil.ID_STYLE)) {
			ep = checkEdgeStyleAnnotation((Edge) me, annotation);
		}
		if (annotation.getName().equals(CincoUtil.ID_ICON)) {
			ep = checkIcon(annotation);
		}
		if (me instanceof ModelElement && annotation.getName().equals(CincoUtil.ID_DISABLE)) {
			ep = checkDisable(me, annotation);
		}
		
		return ep;
	} 
	
	private ValidationResult<String, EStructuralFeature> checkDisable(ModelElement me,	Annotation annotation) {
		ValidationResult<String, EStructuralFeature> result = null;
		if (me instanceof Node)
			result = checkPredefinedValue(CincoUtil.DISABLE_NODE_VALUES, annotation);
		if (me instanceof Edge)
			result = checkPredefinedValue(CincoUtil.DISABLE_EDGE_VALUES, annotation);
		return result;
	}
	
	private ValidationResult<String, EStructuralFeature> checkPredefinedValue(Collection<String> values, Annotation annotation) {
		for (String s : annotation.getValue()) {
			if (!values.contains(s))
				return newError(
					"Invalid value: \"" +s+ "\". Possible values are: " + values, 
					annotation.eClass().getEStructuralFeature(MglPackage.ANNOTATION__NAME));
		}
		return null;
	}
	
	private ValidationResult<String, EStructuralFeature> checkIcon(Annotation annotation) {
		if (annotation.getValue().size() == 0)
			return newError(
					"Please specify an icon by relative or platform path", annotation.eClass()
					.getEStructuralFeature("value"));
		
		String path = annotation.getValue().get(0);
		String retval = PathValidator.checkPath(annotation, path);
		ValidationResult<String, EStructuralFeature> ep = newError(
				retval ,annotation.eClass()
				.getEStructuralFeature("value"));
		return (retval.isEmpty()) ? null : ep;
	}

	private ValidationResult<String, EStructuralFeature> checkNodeContainerStyleAnnotation(ModelElement me, Annotation annot) {
		Styles styles = getStyles(getGraphModel(me));
		if (annot.getValue().size() == 0) {
			return newError(
					"Please define a style for this style annotation", annot.eClass()
					.getEStructuralFeature("value"));
		}
		String styleName = annot.getValue().get(0);
		if (styleName == null || styleName.isEmpty())
			return newError(
					"No style for this node defined", annot.eClass()
							.getEStructuralFeature("value"));
		if (styles == null)
			return null;
		
		Style style = null;
		for (Style s : styles.getStyles()) {
			if (s.getName().equals(styleName) ){
				if (s instanceof EdgeStyle)
					return newError(
							"Edge style assigned to a node...",
							annot.eClass().getEStructuralFeature("value"));
				style = s;
				break;
			}
		}
		
		if (style == null) {
			return newError(
					"Style: " + styleName +" does not exist",
					annot.eClass().getEStructuralFeature("value"));
		}
		
		NodeStyle ns = (NodeStyle) style;
		int params = ns.getParameterCount();//checkFormatStringParameters(ns.getMainShape());
		if (params > annot.getValue().size()-1)
			return newError(
					"Style: " + styleName +" contains text element with " + params + " parameter(s) but you provided: " + (annot.getValue().size()-1),
					annot.eClass().getEStructuralFeature("value"));
		if (params < annot.getValue().size()-1) {
			return newError(
					"Style: " + styleName +" contains text element with " + params + " parameter(s) but you provided: " + (annot.getValue().size()-1),
					annot.eClass().getEStructuralFeature("value"));
		}
		else if (params == annot.getValue().size()-1) {
			List<String> errors = checkParameters(me, annot.getValue());
			if (errors != null && !errors.isEmpty()) {
				String retVal = "";
				for (String s : errors)
					retVal += s;
				return newError(
						retVal,
						annot.eClass().getEStructuralFeature("value"));
			}
		}
		return null;
	}

	private ValidationResult<String, EStructuralFeature> checkEdgeStyleAnnotation(Edge edge, Annotation annot) {
		Styles styles = getStyles(getGraphModel(edge));
		if (annot.getValue() == null || annot.getValue().isEmpty())
			return null;
		String styleName = annot.getValue().get(0);
		if (styleName == null || styleName.isEmpty())
			return newError(
					"No style for this node defined", annot.eClass()
							.getEStructuralFeature("value"));
		if (styles == null)
			return null;

		Style style = null;
		
		for (Style s : styles.getStyles()) {
			if (s.getName().equals(styleName) ){
				if (s instanceof NodeStyle)
					return newError(
							"Node style assigned to this edge...",
							annot.eClass().getEStructuralFeature("value"));
				style = s;
				break;
			}
		}
		
		if (style == null) {
			return newError(
					"Style: " + styleName +" does not exist",
					annot.eClass().getEStructuralFeature("value"));
		}
		
		EdgeStyle es = (EdgeStyle) style;
		int params = es.getParameterCount();
		if (params > annot.getValue().size()-1)
			return newError(
					"Style: " + styleName +" contains text element with " + params + " parameters but you provided: " + (annot.getValue().size()-1),
					annot.eClass().getEStructuralFeature("value"));
		if (params < annot.getValue().size()-1) {
			return newError(
					"Style: " + styleName +" contains text element with " + params + " parameter(s) but you provided: " + (annot.getValue().size()-1),
					annot.eClass().getEStructuralFeature("value"));
		}
		else if (params == annot.getValue().size()-1) {
			List<String> errors = checkParameters(edge, annot.getValue());
			if (errors != null && !errors.isEmpty()) {
				String retVal = "";
				for (String s : errors)
					retVal += s;
				return newError(
						retVal,
						annot.eClass().getEStructuralFeature("value"));
			}
		}
		
		return null;
	}
	
	private List<String> checkParameters(ModelElement me, EList<String> value) {
		List<String> errorMessages = new ArrayList<>();
//		for (String s : value) {
//			Pattern p = Pattern.compile("\\$\\{(.*)\\}");
//			Matcher m = p.matcher(s);
//			if (m.matches()){
//				String attrName = m.group(1);
//				if ( attrName.split("\\.").length > 1 ) {
//					attrName = attrName.split("\\.")[0];
//				}
//					if (InheritanceUtil.checkMGLInheritance(me) != null && !InheritanceUtil.checkMGLInheritance(me).isEmpty())
//						return errorMessages;
//					boolean isAttr = false;
//					List<Attribute> attributes = getAllAttributes(me);
//					for (Attribute attr : attributes) {
//						if (attr.getName().equals(attrName)) {
//							isAttr = true;
//							break;
//						}
//					}
//					if (me instanceof Node) {
//						if (((Node) me).getPrimeReference() != null && ((Node)me).getPrimeReference().getName().equals(attrName)) {
//							isAttr = true;
//						}
//					}
//				
//				if (!isAttr)
//					errorMessages.add("Parameter: " + s + " is not an attribute...\n");
//			}
//		}
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
		}
		return attributes;
	}

	
	private ValidationResult<String, EStructuralFeature> checkGraphModelStyleAnnotation(GraphModel gm, Annotation annot) {
		if (annot != null && annot.getValue().size() == 0) {
			return newError("Missing path to style file", 
					annot.eClass().getEStructuralFeature("value"));
		} else {
			PathValidator.checkPath(annot, annot.getValue().get(0));
			Styles styles = getStyles(gm);
			if (styles == null)
				return newError("Style file " + annot.getValue().get(0)+" does not exist", 
						annot.eClass().getEStructuralFeature("value"));
		}
		return null;
	}
	
	private ValidationResult<String, EStructuralFeature> checkGraphModelDisableHighlight(GraphModel me, Annotation annotation) {
		return checkPredefinedValue(CincoUtil.DISABLE_HIGHLIGHT_VALUES, annotation);
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
		
	private Styles getStyles(GraphModel gm) {
		for (Annotation a : gm.getAnnotations()) {
			if (CincoUtil.ID_STYLE.equals(a.getName())) {
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
