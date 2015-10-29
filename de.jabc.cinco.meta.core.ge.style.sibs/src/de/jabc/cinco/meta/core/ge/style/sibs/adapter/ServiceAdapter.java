package de.jabc.cinco.meta.core.ge.style.sibs.adapter;

import graphmodel.Container;
import graphmodel.GraphmodelPackage;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.jar.Manifest;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import javax.xml.crypto.dsig.keyinfo.RetrievalMethod;

import mgl.Annotation;
import mgl.Attribute;
import mgl.ContainingElement;
import mgl.Edge;
import mgl.GraphModel;
import mgl.GraphicalElementContainment;
import mgl.GraphicalModelElement;
import mgl.Import;
import mgl.IncomingEdgeElementConnection;
import mgl.MglFactory;
import mgl.ModelElement;
import mgl.Node;
import mgl.NodeContainer;
import mgl.OutgoingEdgeElementConnection;
import mgl.ReferencedAttribute;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.emf.ecore.xmi.impl.XMIResourceImpl;
import org.eclipse.xtext.util.StringInputStream;

import style.AbsolutPosition;
import style.AbstractShape;
import style.Alignment;
import style.Appearance;
import style.BooleanEnum;
import style.Color;
import style.ConnectionDecorator;
import style.ContainerShape;
import style.EdgeStyle;
import style.Font;
import style.HAlignment;
import style.Image;
import style.LineStyle;
import style.NodeStyle;
import style.Size;
import style.Style;
import style.StyleFactory;
import style.Styles;
import style.VAlignment;
import de.jabc.adapter.common.collection.Branches;
import de.jabc.cinco.meta.core.utils.CincoUtils;
import de.jabc.cinco.meta.core.utils.InheritanceUtil;
import de.jabc.cinco.meta.core.utils.PathValidator;
import de.jabc.cinco.meta.core.utils.dummycreator.DummyGenerator;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironmentAdapter;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.framework.sib.parameter.ContextKey.Scope;
import de.metaframe.jabc.framework.sib.parameter.foundation.ContextExpressionFoundation;
import de.metaframe.jabc.framework.sib.parameter.foundation.ContextKeyFoundation;


public class ServiceAdapter {

	private static Map<String, String> shapeNames = new HashMap<String, String>();
	private static Map<String, String> gaNames = new HashMap<String, String>();
	private static Map<String, String> keywords = new HashMap<String, String>();
	private static int appearanceCount = 0;
	
	private final static String ID_CONTAINER = "Containers";
	private final static String ID_NODES = "Nodes";
	
	private final static String PLUGIN_FRAME = "<?xml version=\"1.0\" encoding=\""+System.getProperty("file.encoding")+"\"?>\n"
			+ "<?eclipse version=\"3.0\"?>\n"
			+ "<plugin>\n"
			+ "</plugin>";
	
	public ServiceAdapter() {
		
	}
	
	public static String getStyleAnnotation(LightweightExecutionEnvironment env,
			ContextKeyFoundation annotations,
			ContextKeyFoundation annotation) {
	
		LightweightExecutionContext context = env.getLocalContext();
		try {
			List<Annotation> annots = (List<Annotation>) context.get(annotations);
			for (Annotation a : annots) {
				if ("style".equals(a.getName())) {
					context.put(annotation, a);
					break;
				}
			}
			return Branches.DEFAULT;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
	}
	
	public static String checkStyleAnnotationValue(LightweightExecutionEnvironment env,
			ContextKeyFoundation modelElement, ContextKeyFoundation value, ContextKeyFoundation attributeName) {
		LightweightExecutionContext context = env.getLocalContext();
		try {
			ModelElement me = (ModelElement) context.get(modelElement);
			String s = (String) context.get(value);
			Pattern p = Pattern.compile("\\$\\{(\\w+)(?:(\\.)\\w+)*\\}");
			Matcher m = p.matcher(s);
			
			
			if (!m.matches()) {
				return Branches.DEFAULT;
			} else {
				String attrName = m.group(1);
				if (me instanceof Node) {
					Node n = (Node) me;
					if (n.getPrimeReference() != null
							&& attrName.equals(n.getPrimeReference().getName())) {
						context.put(attributeName, attrName);
						s = s.replaceFirst("\\w+\\.", "");
						context.put(value, s);
						return "PrimeRef";
					} else {
						for (Attribute a : getAllAttributes((ModelElement) n)) {
							if (a.getName().equals(attrName)) {
								context.put(attributeName, attrName);
								return "NodeAttribute";
							}
						}
					}
				} else {
					for (Attribute a : getAllAttributes(me)) {
						if (a.getName().equals(attrName)) {
							context.put(attributeName, attrName);
							return "NodeAttribute";
						}
					}
				}
				context.put("exception", new Exception("No Attribute " + attrName + "in node " + me));
				return Branches.ERROR;
			}
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
		
	}

	private static List<Attribute> getAllAttributes(ModelElement me) {
		ModelElement curr = me;
		List<Attribute> attributes = new ArrayList<Attribute>();
		while (curr != null) {
			attributes.addAll(curr.getAttributes());
			curr = getSuperType(curr);
		}
		return attributes;
	}
	
	private static ModelElement getSuperType(ModelElement me) {
		if (me instanceof Node)
			return ((Node) me).getExtends();
		if (me instanceof Edge)
			return ((Edge) me).getExtends();
		return null;
	}

	public static String getStyleAnnotationValues(LightweightExecutionEnvironment env,
			ContextKeyFoundation annotation,
			ContextKeyFoundation values) {
		
		LightweightExecutionContext context = env.getLocalContext();
		try {
			Annotation annot = (Annotation) context.get(annotation);
			List<String> annotValues = annot.getValue();
			List<String> textValues = annotValues.subList(1, annotValues.size());
			context.put(values, textValues);
			return Branches.DEFAULT;
		}catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
		
	}
	
	public static String resolveAnnotationValue(LightweightExecutionEnvironment env,
			ContextKeyFoundation value,
			ContextKeyFoundation result) {
		
		LightweightExecutionContext context = env.getLocalContext();
		try {
			
			return Branches.DEFAULT;
		}catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
	}

	public static String parseExtension(LightweightExecutionEnvironment env,
			ContextKeyFoundation extension,
			ContextKeyFoundation result) {
		
		LightweightExecutionContext context = env.getLocalContext();
		String ext = (String) context.get(extension);
		String retVal = null;
		Pattern extPattner = Pattern.compile("(?:\\w|\\*)*\\.?(\\w*)");
		Matcher m = extPattner.matcher(ext);
		if (m.matches()) {
			if (m.groupCount() > 0 && !m.group(1).isEmpty()) {
				retVal = m.group(1);
			} else {
				retVal = ext;
			}
			context.put(result, retVal);
			return Branches.DEFAULT;
		} else {
				context.putGlobally("exception", new Exception("\""+ext+"\" is not a valid extension"));
				return Branches.ERROR;
		}
	}

	public static String getImageRelativePath(LightweightExecutionEnvironment env,
			ContextKeyFoundation imagePath, ContextKeyFoundation relativePath) {

		LightweightExecutionContext context = env.getLocalContext();
		try {
			String p = (String) context.get(imagePath);
			URI uri = URI.createURI(p);
			String relPath = null;
			if (uri.isPlatformResource()) {
				relPath = uri.path().replaceAll("/", "_");
			}
			else relPath = p;
			context.put(relativePath, relPath);
			return Branches.DEFAULT;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
	}

	public static String hasEStructuralFeature(
			LightweightExecutionEnvironment env,
			ContextKeyFoundation eClass,
			ContextExpressionFoundation featureName) {
		
		LightweightExecutionContext context = env.getLocalContext();
		
		try {
			EClass ec = (EClass) context.get(eClass);
			System.out.println("EClass: " + ec);
			String fName = (String) env.evaluate(featureName);
			System.out.println("FeatureName: " + fName);
			
			EStructuralFeature feature = ec.getEStructuralFeature(fName);
			System.out.println("Feature: " +feature);
			if (feature != null) {
				return Branches.TRUE;
			} else return Branches.FALSE;
			
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
	}

	public static String generateUniqueShapeName(LightweightExecutionEnvironment env,
			ContextKeyFoundation shapeName,
			ContextKeyFoundation uniqueShapeName,
			ContextExpressionFoundation clearCache) {

		LightweightExecutionContext context = env.getLocalContext();
		try {
			String sName = (String) context.get(shapeName);
			Boolean cCache = (Boolean) env.evaluate(clearCache);
			
			String uniqueName;
			
			if (cCache != null && cCache) {
				shapeNames = new HashMap<String, String>();
			}
			
			if (sName != null) {
				uniqueName = sName;
				context.put(uniqueShapeName, uniqueName);
				if (cCache != null && cCache) {
					shapeNames = new HashMap<String, String>();
				}
				return Branches.DEFAULT;
			} else { 
				uniqueName = "Shape"; 
			}
			
			
			int namesCounter = 0;
			while (shapeNames.get(uniqueName + namesCounter) != null)
				namesCounter++;
			
			uniqueName = uniqueName + namesCounter;
			shapeNames.put(uniqueName, new String(""));
			
			context.put(uniqueShapeName, uniqueName);
			
			if (cCache != null && cCache) {
				shapeNames = new HashMap<String, String>();
			}
			
			return Branches.DEFAULT;

		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
		
	}
	
	
	public static String generateUniqueGaName(LightweightExecutionEnvironment env,
			ContextExpressionFoundation graphicsAlgorithmName,
			ContextKeyFoundation uniqueGaNameName,
			ContextExpressionFoundation clearCache) {

		LightweightExecutionContext context = env.getLocalContext();
		try {
			String gaName = (String) env.evaluate(graphicsAlgorithmName);
			Boolean cCache = (Boolean) env.evaluate(clearCache);
			
			if (cCache != null && cCache) {
				gaNames = new HashMap<String, String>();
			}
			
			String uniqueName = gaName;
			
			int namesCounter = 0;
			while (gaNames.get(uniqueName + namesCounter) != null)
				namesCounter++;
			
			uniqueName = uniqueName + namesCounter;
			gaNames.put(uniqueName, new String(""));
			
			context.put(uniqueGaNameName, uniqueName);
			return Branches.DEFAULT;

		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
		
	}

	public static String getModelElementIdentifier(
			LightweightExecutionEnvironment env,
			ContextKeyFoundation modelElementName,
			ContextKeyFoundation meIdentifier) {

		LightweightExecutionContext context = env.getLocalContext();
		try {
			String meName = (String) context.get(modelElementName);
			meName = meName.substring(0, 1).toLowerCase() + meName.substring(1);
			
			for (ReservedKeyWords s : ReservedKeyWords.values()) {
				String keyword = s.getKeyword();
				keywords.put(keyword, new String(""));
				keywords.put(keyword.substring(0, 1).toUpperCase() + keyword.substring(1), new String(""));
			}
			
			if (keywords.get(meName) != null)
				meName = "_" + meName;
			
			context.put(meIdentifier, meName);
			return Branches.DEFAULT;

		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
		
	}

	public static String isNodeContained(LightweightExecutionEnvironment env,
			ContextKeyFoundation nodeContainer,
			ContextKeyFoundation node) {
		
		LightweightExecutionContext context = env.getLocalContext();
		try {
			ContainingElement nc = (ContainingElement) context.get(nodeContainer);
			ModelElement n = (ModelElement) context.get(node);
			
			if (nc instanceof GraphModel && nc.getContainableElements().isEmpty())
				return Branches.TRUE;
			if (nc instanceof NodeContainer && nc.getContainableElements().isEmpty())
				return Branches.FALSE;
			
			for (GraphicalElementContainment containedNode : nc.getContainableElements() ) {
				if (containedNode.getTypes() == null || containedNode.getTypes().isEmpty())
					return Branches.TRUE;
				
				if (containedNode.getTypes().contains(n))
					return Branches.TRUE;
				
				if (n instanceof Node) {
					Node extend = (Node) n;
					while (extend != null) {
						extend = extend.getExtends();
						if (containedNode.getTypes().contains(extend))
							return Branches.TRUE;
					}
				}
			}
			
			return Branches.FALSE;
			
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
	}

	public static String computePosition(LightweightExecutionEnvironment env,
			ContextKeyFoundation relativePosition,
			ContextKeyFoundation size,
			ContextKeyFoundation position) {

		LightweightExecutionContext context = env.getLocalContext();
		try {
			Alignment relPos = (Alignment) context.get(relativePosition);
			
			AbstractShape shape = relPos.getShape();
			
			ContainerShape parentContainerShape = shape.getParentContainerShape();
			ContainerShape relTo = parentContainerShape;
			Size relToSize = relTo.getSize();
			
			Size shapeSize = (Size) context.get(size);
			
			HAlignment ha = relPos.getHorizontal();
			VAlignment va = relPos.getVertical();

			AbsolutPosition absPos = StyleFactory.eINSTANCE.createAbsolutPosition();
			int x=0, y=0;
			switch (ha.getValue()) {
			case HAlignment.LEFT_VALUE:
				x = 0;
				break;
			case HAlignment.CENTER_VALUE:
				x = (relToSize.getWidth() / 2) - (shapeSize.getWidth() / 2);
				break;
			case HAlignment.RIGHT_VALUE:
				x = relToSize.getWidth() - shapeSize.getWidth();
				break;
			default:
				x = 0;
				break;
			}
			switch (va.getValue()) {
			case VAlignment.TOP_VALUE:
				y = 0;
				break;
			case VAlignment.MIDDLE_VALUE:
				y = (relToSize.getHeight() / 2) - (shapeSize.getHeight() / 2);
				break;
			case VAlignment.BOTTOM_VALUE:
				y = relToSize.getHeight() - shapeSize.getHeight();
				break;
			default:
				break;
			}

			absPos.setXPos(x);
			absPos.setYPos(y);
			
			context.put(position, absPos);
			return Branches.DEFAULT;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
		
	}

	public static String generateAppearance(
			LightweightExecutionEnvironment env,
			ContextKeyFoundation appearance,
			ContextKeyFoundation newAppearance) {
		
		LightweightExecutionContext context = env.getLocalContext();
		try {
			Appearance app = (Appearance) context.get(appearance);
			Appearance newApp = StyleFactory.eINSTANCE.createAppearance();
			
			setValues(app, newApp);
			context.put(newAppearance, newApp);
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
		
		return Branches.DEFAULT;
	}
	
	private static void setValues(Appearance app, Appearance newApp) throws IOException {
		if (app != null) {
//			EcoreUtil.resolveAll(app);
			Appearance parent = app.getParent();
			setValues(parent, newApp);
			
			if (app.getAngle() != -1.0)
				newApp.setAngle(app.getAngle());
			
			if (app.getBackground() != null){
				newApp.setBackground(EcoreUtil.copy(app.getBackground()));
			}
			
			if (app.getFont() != null)
				newApp.setFont(EcoreUtil.copy(app.getFont()));
			
			if (app.getForeground() != null) {
				newApp.setForeground(EcoreUtil.copy(app.getForeground()));
			}
			if (app.getLineStyle() != LineStyle.SOLID)
				newApp.setLineStyle(app.getLineStyle());
			if (app.getLineWidth() != -1)
				newApp.setLineWidth(app.getLineWidth());
			if (!app.getName().isEmpty())
				newApp.setName(app.getName());
			if (app.getTransparency() != -1.0)
				newApp.setTransparency(app.getTransparency());
			if (app.getLineInVisible() != null)
				newApp.setLineInVisible(app.getLineInVisible());
			if (app.getFilled() != null) 
				newApp.setFilled(app.getFilled());
		}
	}
	
	public static String generateAppearanceDefaultValues(LightweightExecutionEnvironment env,
			ContextKeyFoundation appearance) {
		
		LightweightExecutionContext context = env.getLocalContext();
		
		try {
			
			Appearance newApp = (Appearance) context.get(appearance);
			
		if (newApp.getFilled() == null)
			newApp.setFilled(BooleanEnum.UNDEF);
		if (newApp.getLineInVisible() == null)
			newApp.setLineInVisible(false);
		if (newApp.getAngle() == -1.0)
			newApp.setAngle(0);
		if (newApp.getBackground() == null) {
			Color white = StyleFactory.eINSTANCE.createColor();
			white.setR(255);
			white.setG(255);
			white.setB(255);
			newApp.setBackground(white);
		}
		
		if (newApp.getForeground() == null) {
			Color black = StyleFactory.eINSTANCE.createColor();
			black.setR(0);
			black.setG(0);
			black.setB(0);
			newApp.setForeground(black);
		}
		if (newApp.getFont() == null) {
			Font f = StyleFactory.eINSTANCE.createFont();
			f.setFontName("Arial");
			f.setSize(8);
			f.setIsBold(false);
			f.setIsItalic(false);
			newApp.setFont(f);
		}
		if (newApp.getLineStyle().equals(LineStyle.UNSPECIFIED))
			newApp.setLineStyle(LineStyle.SOLID);
		if (newApp.getLineWidth() == -1)
			newApp.setLineWidth(1);
		if (newApp.getTransparency() == -1.0)
			newApp.setTransparency(0.0);
									
			return Branches.DEFAULT;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
	}

	public static String getImportsPackageName(
			LightweightExecutionEnvironment env,
			ContextKeyFoundation graphModelImports,
			ContextKeyFoundation imports) {

		LightweightExecutionContext context = env.getLocalContext();
		
		try {
			List<Import> gmImports= (List<Import>) context.get(graphModelImports);
			List<String> imps = new ArrayList<>();
			
			for (Import i : gmImports){
				URI importUri = PathValidator.getURIForString(i, i.getImportURI());
				IPath path = new Path(importUri.toPlatformString(true));
				IWorkspaceRoot root = ResourcesPlugin.getWorkspace().getRoot();
				IFile file = root.getFile(path);
				IProject p = file.getProject();
				IFile mglFile = findMGLFile(p.getFolder("model"));
				if (mglFile != null) {
					Resource res = new ResourceSetImpl().getResource(
							URI.createPlatformResourceURI(mglFile.getFullPath().toOSString(), true), 
							true);
					for (EObject o : res.getContents()) {
						if (o instanceof GraphModel) {
							GraphModel gm = (GraphModel) o;
							if (gm.getPackage() != null && !gm.getPackage().isEmpty()) {
								imps.add(gm.getPackage().concat("." + gm.getName().toLowerCase()));
							} else imps.add(gm.getName().toLowerCase());
						}
					}
				} else {
					Resource res = new ResourceSetImpl().getResource(
							URI.createPlatformResourceURI(file.getFullPath().toOSString(), true), true);
					for (EObject o : res.getContents()) {
						if (o instanceof EPackage) {
							EPackage ePackage = (EPackage) o;
							imps.add(ePackage.getName());
						}
					}
				}
			}
			context.put(imports, imps);
			return Branches.DEFAULT;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
		
	}

	private static IFile findMGLFile(IContainer container) throws CoreException {
		for (IResource res : container.members()) {
			if (res instanceof IFile) {
				IFile file = (IFile) res;
				if ("mgl".equals(file.getFileExtension()))
					return file;
			} else return findMGLFile((IContainer) res);
		}
		return null;
	}

	public static String fileExists(LightweightExecutionEnvironment env,
			ContextKeyFoundation path) {

		LightweightExecutionContext context = env.getLocalContext();
		
		try {
			String p = (String) context.get(path);
			File file = new File(p);
			if (file.exists())
				return Branches.TRUE;
			else return Branches.FALSE;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
	}

	public static String collectInlineAppearances(
			LightweightExecutionEnvironment env,
			ContextKeyFoundation styles,
			ContextKeyFoundation inlineAppearances) {
		
		LightweightExecutionContext context = env.getLocalContext();
		
		try {
			Styles s = (Styles) context.get(styles);
			List<Appearance> list = new ArrayList<>();
			for (Style style : s.getStyles()) 
				getInlineAppearance(style, list);
			
			context.put(inlineAppearances, list);
			
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
		
		return Branches.DEFAULT;
	}

	private static void getInlineAppearance(Style style, List<Appearance> list) {
		
		if (style instanceof NodeStyle)
			getInlineAppearance(((NodeStyle) style).getMainShape(), list);
		
		if (style instanceof EdgeStyle) {
			EdgeStyle es = (EdgeStyle) style;
			if (es.getInlineAppearance() != null) {
				String name = "_Appearance" + appearanceCount++;
				es.getInlineAppearance().setName(name);
				
				/** The subsequent parent call resolves an object that is possibly a proxy **/
				es.getInlineAppearance().getParent();
				list.add(es.getInlineAppearance());
			}
		
			for (ConnectionDecorator cd : es.getDecorator()) {
				if (cd.getDecoratorShape() instanceof AbstractShape) {
					getInlineAppearance((AbstractShape) cd.getDecoratorShape(), list);
				}
				
				if (cd.getPredefinedDecorator() != null &&
						cd.getPredefinedDecorator().getInlineAppearance() != null) {
					Appearance cdApp = cd.getPredefinedDecorator().getInlineAppearance();
					String name = "_Appearance" + appearanceCount++;
					cdApp.setName(name);
					cdApp.getParent();
					list.add(cdApp);
				}
			}
				
		}
				
	}
		

	private static void getInlineAppearance(AbstractShape as,	List<Appearance> list) {
		Appearance app = as.getInlineAppearance();
		if (app != null) {
			String name = "_Appearance" + appearanceCount++;
			app.setName(name);
			list.add(app);
			/** The subsequent parent call resolves an object that is possibly a proxy **/
			app.getParent();
		}
		if (as instanceof ContainerShape) {
			for (AbstractShape abstractShape : ((ContainerShape) as).getChildren())
				getInlineAppearance(abstractShape, list);
		}
	}

	public static String computeAttributeLabelSize(
			LightweightExecutionEnvironment env,
			ContextKeyFoundation attributes,
			ContextKeyFoundation width) {

		LightweightExecutionContext context = env.getLocalContext();
		try {
			List<Object> attrs = (List<Object>) context.get(attributes);
			int maxWidth = 0;
			for (Object a : attrs) {
				if (a instanceof Attribute)
					maxWidth = Math.max(((Attribute) a).getName().length() * 8 , maxWidth);
				if (a instanceof ReferencedAttribute)
					maxWidth = Math.max(((ReferencedAttribute) a).getName().length() * 8 , maxWidth);
			}
			maxWidth = Math.max(maxWidth, 105);
			context.put(width, maxWidth);
			return Branches.DEFAULT;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
	}

	public static String isEdgeUsed(LightweightExecutionEnvironment env,
			ContextKeyFoundation edge,
			ContextKeyFoundation graphicalModelElements) {

		LightweightExecutionContext context = env.getLocalContext();
		try {
			Edge e = (Edge) context.get(edge);
			List<GraphicalModelElement> gme = (List<GraphicalModelElement>) context.get(graphicalModelElements);
			boolean in = false, out = false;
			for (GraphicalModelElement n : gme) {
				
//				if (n.getIncomingEdgeConnections().isEmpty()) {
//					/* No incoming elements defined -> allow this edge */
//					in = true;
//				}
				
//				if (n.getOutgoingEdgeConnections().isEmpty()) {
//					/* No outgoing elements defined -> allow this edge */
//					out = true;
//				}
				
				for (IncomingEdgeElementConnection ieec : n.getIncomingEdgeConnections()) {
					if (in) break;
					if (ieec.getConnectingEdges().isEmpty())
						in = true;
					for (Edge incoming : ieec.getConnectingEdges()) {
						if (incoming.equals(e)) {
							in = true;
							break;
						}
					}
				}
				for (OutgoingEdgeElementConnection oeec : n.getOutgoingEdgeConnections()) {
					if (out) break;
					if (oeec.getConnectingEdges().isEmpty())
						out = true;
					for (Edge outgoing : oeec.getConnectingEdges()) {
						if (outgoing.equals(e)) {
							out = true;
							break;
						}
					}
				}
			}
			
			if (in && out)
				return Branches.TRUE;
			
			return Branches.FALSE;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
	}

	public static String isMultiLineAttribute(
			LightweightExecutionEnvironment env,
			ContextKeyFoundation attribute) {
		LightweightExecutionContext context = env.getLocalContext();
		try {
			Attribute attr = (Attribute) context.get(attribute);
			for (Annotation a : attr.getAnnotations())
				if ("multiLine".equals(a.getName()))
					return Branches.TRUE;
			
			return Branches.FALSE;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
	}

	public static String getEdgeSourceElementConnections(
			LightweightExecutionEnvironment env,
			ContextKeyFoundation edge,
			ContextKeyFoundation gme,
			ContextKeyFoundation edgeElementConnectionsMap) {
		
		LightweightExecutionContext context = env.getLocalContext();
		try {
			Edge e = (Edge) context.get(edge);
			List<GraphicalModelElement> graphicalModelElements = (List<GraphicalModelElement>) context.get(gme);
			HashMap<GraphicalModelElement, List<OutgoingEdgeElementConnection>> map = new HashMap<>();
			for (GraphicalModelElement n : graphicalModelElements) {
				ArrayList<OutgoingEdgeElementConnection> oeecs = new ArrayList<>();
				if (n.getOutgoingEdgeConnections().isEmpty()) {
					List<Edge> edges = (n instanceof Node) ? ((Node)n).getGraphModel().getEdges() : ((NodeContainer)n).getGraphModel().getEdges();
					/*There are no IncomingEdgeElementConnections defined for this node
					 * -> allow this node type as target for all edges OOOORRRR NOT*/
//					for (Edge tmp :edges) {
//						OutgoingEdgeElementConnection tmpOEEC = MglFactory.eINSTANCE.createOutgoingEdgeElementConnection();
//						tmpOEEC.setConnectedElement(n);
//						tmpOEEC.setLowerBound(0);
//						tmpOEEC.setUpperBound(-1);
//						oeecs.add(tmpOEEC);
//					}
					
				}
				for (OutgoingEdgeElementConnection oeec : n.getOutgoingEdgeConnections()) {
					for (Edge out : oeec.getConnectingEdges()) {
						if (out.equals(e))
							oeecs.add(oeec);
					}
					
					if (oeec.getConnectingEdges().isEmpty()) {
						/*IncomingEdgeElementConnection is defined for node but this one is a star.*/
						oeecs.add(oeec);
					}
				}
				if (!oeecs.isEmpty())
					map.put(n, oeecs);
			}
			
			context.put(edgeElementConnectionsMap, map);
			
			return Branches.DEFAULT;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
	}
	
	public static String getEdgeTargetElementConnections(
			LightweightExecutionEnvironment env,
			ContextKeyFoundation edge,
			ContextKeyFoundation gme,
			ContextKeyFoundation edgeElementConnectionsMap) {
		
		LightweightExecutionContext context = env.getLocalContext();
		try {
			Edge e = (Edge) context.get(edge);
			List<GraphicalModelElement> graphicalModelElements = (List<GraphicalModelElement>) context.get(gme);
			HashMap<GraphicalModelElement, List<IncomingEdgeElementConnection>> map = new HashMap<>();
			for (GraphicalModelElement n : graphicalModelElements) {
				ArrayList<IncomingEdgeElementConnection> ieecs = new ArrayList<>();
				if (n.getIncomingEdgeConnections().isEmpty()) {
					List<Edge> edges = (n instanceof Node) ? ((Node)n).getGraphModel().getEdges() : ((NodeContainer) n).getGraphModel().getEdges();
					/*There are no IncomingEdgeElementConnections defined for this node
					 * -> allow this node type as target for all edges OOORRRR NOT*/
//					for (Edge tmp : edges) {
//						IncomingEdgeElementConnection tmpIEEC = MglFactory.eINSTANCE.createIncomingEdgeElementConnection();
//						tmpIEEC.setConnectedElement(n);
//						tmpIEEC.setLowerBound(0);
//						tmpIEEC.setUpperBound(-1);
//						ieecs.add(tmpIEEC);
//					}
					
				}
				for (IncomingEdgeElementConnection ieec : n.getIncomingEdgeConnections()) {
					for (Edge out : ieec.getConnectingEdges()) {
						if (out.equals(e))
							ieecs.add(ieec);
					}
					
					if (ieec.getConnectingEdges().isEmpty()) {
						/*IncomingEdgeElementConnection is defined for node but this one is a star.*/
						ieecs.add(ieec);
					}
					
				}
				if (!ieecs.isEmpty())
					map.put(n, ieecs);
			}
			
			context.put(edgeElementConnectionsMap, map);
			
			return Branches.DEFAULT;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
	}
	
	public static String generateEdgeSourceCode(LightweightExecutionEnvironment env,
			ContextKeyFoundation mapEntry,
			ContextKeyFoundation code){
		
		LightweightExecutionContext context = env.getLocalContext();
		try {
			Entry<GraphicalModelElement, List<OutgoingEdgeElementConnection>> entry = (Entry<GraphicalModelElement, List<OutgoingEdgeElementConnection>>) context.get(mapEntry);
			GraphicalModelElement n = entry.getKey();
			List<OutgoingEdgeElementConnection> oeecs = entry.getValue();
			StringBuilder sbType = new StringBuilder();
			StringBuilder sbBound = new StringBuilder();
			String importPath = (String) context.get(new ContextKey("importPath").asFoundation());
			String fqNodeName = importPath + "." + n.getName();
			
			for (Iterator<OutgoingEdgeElementConnection> it = oeecs.iterator(); it.hasNext();) {
				OutgoingEdgeElementConnection oeec = it.next();
				int bound = oeec.getUpperBound();
				if (bound >= 0) {
					if (oeec.getConnectingEdges().isEmpty()) {
						sbBound.append("((" + fqNodeName+") source).getIncoming().size()");
					}
					for (Iterator<Edge> edgeIt = oeec.getConnectingEdges().iterator(); edgeIt.hasNext();) {
						Edge e = edgeIt.next();
						sbBound.append("((" + fqNodeName+") source).getOutgoing("+ importPath + "." +e.getName()+".class).size()");
						if (edgeIt.hasNext())
							sbBound.append(" + ");
					}
					sbBound.append( " < " + bound);
				} else {
					sbBound.append("true");
				}
				if (it.hasNext())
					sbBound.append(" &&\n\t");
			}
			
			sbType.append("if (source instanceof " + fqNodeName+") {\n\t");
			sbType.append("if ("+sbBound.toString()+")\n\t\treturn true;\n\t"
					+ "else setError(ECincoError.MAX_OUT);\n} ");
			
			context.put(code, sbType.toString());
			return Branches.DEFAULT;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
	}
	
	public static String generateEdgeTargetCode(LightweightExecutionEnvironment env,
			ContextKeyFoundation mapEntry,
			ContextKeyFoundation code){
		
		LightweightExecutionContext context = env.getLocalContext();
		try {
			Entry<GraphicalModelElement, List<IncomingEdgeElementConnection>> entry = (Entry<GraphicalModelElement, List<IncomingEdgeElementConnection>>) context.get(mapEntry);
			GraphicalModelElement n = entry.getKey();
			List<IncomingEdgeElementConnection> oeecs = entry.getValue();
			StringBuilder sbType = new StringBuilder();
			StringBuilder sbBound = new StringBuilder();
			String importPath = (String) context.get(new ContextKey("importPath").asFoundation());
			String fqNodeName = importPath + "." + n.getName();
			
			for (Iterator<IncomingEdgeElementConnection> it = oeecs.iterator(); it.hasNext();) {
				IncomingEdgeElementConnection ieec = it.next();
				int bound = ieec.getUpperBound();
				if (bound >= 0) {
					if (ieec.getConnectingEdges().isEmpty()) {
						sbBound.append("((" + fqNodeName +") target).getIncoming().size()");
					}
					for (Iterator<Edge> edgeIt = ieec.getConnectingEdges().iterator(); edgeIt.hasNext();) {
						Edge e = edgeIt.next();
						sbBound.append("((" + fqNodeName+") target).getIncoming("+ importPath + "." +e.getName()+".class).size()");
						if (edgeIt.hasNext())
							sbBound.append(" + ");
					}
					sbBound.append( " < " + bound);
				} else {
					sbBound.append("true");
				}
				if (it.hasNext())
					sbBound.append(" &&\n\t");
			}
			
			sbType.append("if (target instanceof " + fqNodeName +") {\n\t");
			sbType.append("if ("+sbBound.toString()+")\n\t\treturn true;\n\t"
					+ "else setError(ECincoError.MAX_IN);\n}");

			context.put(code, sbType.toString());
			return Branches.DEFAULT;

		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
	}

	public static String getCustomFeatureClassName(LightweightExecutionEnvironment env,
			ContextKeyFoundation annotation,
			ContextKeyFoundation className) {

		LightweightExecutionContext context = env.getLocalContext();
		
		try {
			Annotation annot = (Annotation) context.get(annotation);
			List<String> values = (List<String>) annot.getValue();
			IProject project = (IProject) context.get("project");
			if (values.size() == 1) {
				context.put(className, values.get(0));
			} else {
				context.put(className, values.get(1));
				importPackage(project.getName(), values.get(1));
			}
				
			return Branches.DEFAULT;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
	}

	private static void exportPackage(String projectName, String fqcn) throws IOException, CoreException {
		IProject p = ResourcesPlugin.getWorkspace().getRoot().getProject(projectName);
		if (!p.exists()) {
			return;
		}
		IFile iManiFile= p.getFolder("META-INF").getFile("MANIFEST.MF");
		Manifest manifest = new Manifest(iManiFile.getContents());
		
		StringBuilder sb = new StringBuilder(fqcn);
		int lastDotIndex = sb.lastIndexOf(".");
		String newPackageName = sb.subSequence(0, lastDotIndex).toString();
		String exportPackage = manifest.getMainAttributes().getValue("Export-Package");
		String[] pkgs = exportPackage.split(",");
		boolean found= false;
		for (String s : pkgs) {
			if (s.equals(newPackageName))
				found = true;
		}
		
		if (!found) {
			String newVal = manifest.getMainAttributes().getValue("Export-Package").concat(","+newPackageName);
			manifest.getMainAttributes().putValue("Export-Package", newVal);
			manifest.write(new FileOutputStream(iManiFile.getLocation().toFile()));
		}
		
	}

	private static void importPackage(String projectName, String fqcn) throws IOException, CoreException {
		IProject p = ResourcesPlugin.getWorkspace().getRoot().getProject(projectName);
		if (!p.exists()) {
			return;
		}
		IFile iManiFile= p.getFolder("META-INF").getFile("MANIFEST.MF");
		Manifest manifest = new Manifest(iManiFile.getContents());
		
		StringBuilder sb = new StringBuilder(fqcn);
		int lastDotIndex = sb.lastIndexOf(".");
		String newPackageName = sb.subSequence(0, lastDotIndex).toString();
		String importPackage = manifest.getMainAttributes().getValue("Import-Package");
		boolean found= false;
		if (importPackage != null) { 
			String[] pkgs = importPackage.split(",");
			for (String s : pkgs) {
				if (s.equals(newPackageName))
					found = true;
			}
		} else {
			importPackage = new String();
		}
		if (!found) {
			String newVal = new String();
			if (manifest.getMainAttributes().getValue("Import-Package") == null)
				newVal = newVal.concat(newPackageName);
			else newVal = manifest.getMainAttributes().getValue("Import-Package").concat(","+newPackageName);
			manifest.getMainAttributes().putValue("Import-Package", newVal);
			manifest.write(new FileOutputStream(iManiFile.getLocation().toFile()));
		}
	}
	
	public static String resolveMGLInheritance(LightweightExecutionEnvironment env,	ContextKeyFoundation graphModel) {
		LightweightExecutionContext context = env.getLocalContext();
		
		try {
			GraphModel gm = (GraphModel) context.get(graphModel);
			List<ModelElement> modelElements = new ArrayList<>();
			Map<ModelElement, List<Attribute>> attributesMap = new HashMap<>();
			modelElements.addAll(gm.getNodes());
			//modelElements.addAll(gm.getNodeContainers());
			modelElements.addAll(gm.getEdges());
			for (ModelElement me : modelElements) {
				attributesMap.put(me, InheritanceUtil.getInheritedAttributes(me));
			}
			
//			for (ModelElement me : modelElements) {
//				me.getAttributes().clear();
//				me.getAttributes().addAll(EcoreUtil.copyAll(attributesMap.get(me)));
//			}

			return Branches.DEFAULT;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
	}

	public static String initializeContainer(LightweightExecutionEnvironment env, ContextKeyFoundation graphModel) {
		
		LightweightExecutionContext context = env.getLocalContext();
		
		try {
			GraphModel gm = (GraphModel) context.get(graphModel);
			for (Node noc : gm.getNodes()) {
				
				if(noc instanceof NodeContainer){
					NodeContainer nc = (NodeContainer)noc;
					if (nc.getContainableElements().isEmpty()) {
						
						for (Node node : gm.getNodes()) {
							GraphicalElementContainment gec = MglFactory.eINSTANCE.createGraphicalElementContainment();
							gec.setContainingElement(nc);
	//						gec.setType(node);
							gec.setLowerBound(0);
							gec.setUpperBound(-1);
							nc.getContainableElements().add(gec);
						}
						
						for (Node container : gm.getNodes()) {
							if(container instanceof NodeContainer){
								GraphicalElementContainment gec = MglFactory.eINSTANCE.createGraphicalElementContainment();
								gec.setContainingElement(nc);
		//						gec.setType(container);
								nc.getContainableElements().add(gec);
							}
						}
					}
				}
			}
			return Branches.DEFAULT;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
	}

	public static String isPrimeNode(LightweightExecutionEnvironment env,
			ContextKeyFoundation node) {
		
		LightweightExecutionContext context = env.getLocalContext();
		
		try {
			Node n = (Node) context.get(node);
			if (n.getPrimeReference() == null) {
				return Branches.FALSE;
			} else return Branches.TRUE;
			
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
		
	}

	public static String getPaletteGroups(LightweightExecutionEnvironment env,
			ContextKeyFoundation graphmodel, ContextKeyFoundation gn2men) {
		
		LightweightExecutionContext context = env.getLocalContext();
		try {
			GraphModel gm = (GraphModel) context.get(graphmodel);
			HashMap<String, List<GraphicalModelElement>> map = new HashMap<>();
			
			map.put(ID_NODES, new ArrayList<GraphicalModelElement>());
			
			/** After libComp changes in MGL.ecore mgl.NodeContainer is subtype of mgl.Node... **/
			for (Node n : gm.getNodes()){
				if (n.isIsAbstract() || n.getPrimeReference() != null || CincoUtils.isCreateDisabled(n))
					continue;
				if (!hasPaletteCategory(n))
					map.get(ID_NODES).add(n);
				
				for (Annotation a : n.getAnnotations()) {
					if ("palette".equals(a.getName())) {
						for (String v : a.getValue()) {
							if (map.get(v) == null)
								map.put(v, new ArrayList<GraphicalModelElement>());
							map.get(v).add(n);
						}
					}
				}
			}
			
			for (Edge e : gm.getEdges()){
				if (e.isIsAbstract() || CincoUtils.isCreateDisabled(e))
					continue;
				for (Annotation a : e.getAnnotations()) {
					if ("palette".equals(a.getName())) {
						for (String v : a.getValue()) {
							if (map.get(v) == null)
								map.put(v, new ArrayList<GraphicalModelElement>());
							map.get(v).add(e);
						}
					}
				}
			}
			
			map.remove("none");
			map.remove("None");
			map.remove("NONE");
			
			context.put(gn2men, map);
			return Branches.DEFAULT;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
	}

	public static String isEmpty(LightweightExecutionEnvironment env,
			ContextKeyFoundation collection) {
		
		LightweightExecutionContext context = env.getLocalContext();
		
		try {
			@SuppressWarnings("unchecked")
			Collection<Object> coll = (Collection<Object>) context.get(collection);
			if (coll.isEmpty())
				return Branches.TRUE;
			else return Branches.FALSE;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		
		}
		
	}


	private static boolean hasPaletteCategory(ModelElement me) {
		for (Annotation a : me.getAnnotations())
			if (a.getName().equals("palette")) {
				return true;
			}
		return false;
	}

	public static String isAbstract(LightweightExecutionEnvironment env,
			ContextKeyFoundation modelElement) {
		
		LightweightExecutionContext context = env.getLocalContext();
		try {
			ModelElement me = (ModelElement) context.get(modelElement);
			if (me.isIsAbstract())
				return Branches.TRUE;
			else return Branches.FALSE;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
		
	}

	public static String getAllIcons(LightweightExecutionEnvironment env,
			ContextKeyFoundation graphModel,
			ContextKeyFoundation iconsList) {

		LightweightExecutionContext context = env.getLocalContext();
		
		try {
			GraphModel gm = (GraphModel) context.get(graphModel);
			HashMap<String, String> paths = new HashMap<>();
			URI uri = null;
			for (TreeIterator<EObject> it = gm.eResource().getAllContents(); it.hasNext(); ){
				EObject o = it.next();
				if (o instanceof Annotation) {
					Annotation a  = (Annotation) o;
					if ("icon".equals(a.getName())) {
						if (a.getValue().size() == 1 && PathValidator.isRelativePath(o,a.getValue().get(0))) {
							uri = PathValidator.getURIForString(o, a.getValue().get(0));
							paths.put(a.getValue().get(0), uri.toPlatformString(true));
						}
						else if (a.getValue().size() > 1 && PathValidator.isRelativePath(o,a.getValue().get(1))){
								uri = PathValidator.getURIForString(o, a.getValue().get(1));
								paths.put(a.getValue().get(1), uri.toPlatformString(true));
						}
						
					}
				}
			}
			
			Styles styles = CincoUtils.getStyles(gm);
			for (TreeIterator<EObject> it = styles.eResource().getAllContents(); it.hasNext();){
				EObject o = it.next();
				if (o instanceof Image) {
					Image img  = (Image) o;
					String path = img.getPath();
					if (PathValidator.isRelativePath(img, path)) {
						uri = PathValidator.getURIForString(img, path);
						paths.put(path, uri.toPlatformString(true));
					}
				}
			}
			
			context.put(iconsList, paths);
			return Branches.DEFAULT;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
		
	}

	/**
	 * @param env
	 * @param path
	 * @param content
	 * @param projectName 
	 * @return
	 */
	public static String writePluginXMLContent(
			LightweightExecutionEnvironment env, ContextKeyFoundation path,
			ContextKeyFoundation content, ContextKeyFoundation projectName) {
		
		LightweightExecutionContext context = env.getLocalContext();
		try {
			NullProgressMonitor monitor = new NullProgressMonitor();
		
			String p = (String) context.get(path);
			String c = (String) context.get(content);
			String gName = (String) context.get(new ContextKey("graphModelName", Scope.GLOBAL, true).asFoundation());
			String pName = (String) context.get(projectName);
			
			ResourcesPlugin.getWorkspace().getRoot().getProject(pName).refreshLocal(IResource.DEPTH_INFINITE, monitor);
			
			File f = new File(p);
			if (f.exists()) {
						FileInputStream fis = new FileInputStream(f);
						BufferedReader reader = new BufferedReader(new InputStreamReader(fis));
						String line = null;
						String originalText = new String();
						while ((line = reader.readLine()) != null) {
							originalText += line.concat("\n");
						}
						fis.close();
						fis = new FileInputStream(f);
						reader = new BufferedReader(new InputStreamReader(fis));
						String CINCO_GEN = new String("<!--@CincoGen "+gName+"-->");
						ArrayList<String> extensions = getExtensions(originalText);
						ArrayList<String> remove = new ArrayList<>();
						for (String ext : extensions) {
							if (ext.contains(CINCO_GEN))
								remove.add(ext);
						}
						
						extensions.removeAll(remove);
						
						StringBuilder sb = new StringBuilder(PLUGIN_FRAME);
						int offset = sb.indexOf("</plugin>");
						sb.insert(offset, c);
						for (String ext : extensions)
							sb.insert(offset, ext);
						originalText = sb.toString();
						FileOutputStream fos = new FileOutputStream(f);
						fos.write(originalText.getBytes());
						fos.close();
						fis.close();
			} else {
				StringBuilder sb = new StringBuilder();
				sb.append(PLUGIN_FRAME);
				int offset = sb.indexOf("</plugin>");
				sb.insert(offset, c);
				IProject project = ResourcesPlugin.getWorkspace().getRoot().getProject(pName);
				IFile file = project.getFile("plugin.xml");
				if (!file.exists()) {
					file.create(new StringInputStream(sb.toString()), true, monitor);
				}
				else {
					file.setContents(new StringInputStream(sb.toString()), IFile.DEPTH_INFINITE, monitor);
				}
				file.getProject().refreshLocal(IFile.DEPTH_INFINITE, monitor);
				System.out.println(file.getFullPath());
			}
			return Branches.DEFAULT;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
	}

	private static ArrayList<String> getExtensions(String c) {
		ArrayList<String> extensions = new ArrayList<>();
		String[] lines = c.split("\n");
		StringBuilder sb = new StringBuilder();
		for (String s : lines) {
			if (s.contains("<extension")) 
				sb = new StringBuilder();
			
			sb.append(s.concat("\n"));
			
			if (s.contains("</extension>")) 
				extensions.add(sb.toString());
			
		}
		return extensions;
	}

	public static String isAttributeHidden(LightweightExecutionEnvironment env,
			ContextKeyFoundation attribute) {

		LightweightExecutionContext context = env.getLocalContext();
		try {
			EObject o = (EObject) context.get(attribute);
			if (!(o instanceof Attribute))
				return Branches.FALSE;
			Attribute attr = (Attribute) o;
			for (Annotation a : attr.getAnnotations())
				if (a.getName().equals("propertiesViewHidden"))
					return Branches.TRUE;
			return Branches.FALSE;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
	}

	public static String putDynamicLinkedMap(LightweightExecutionEnvironment env,
			ContextKeyFoundation variable, Map<Object, String> elements) {
		
		 LightweightExecutionContext context = env.getLocalContext();
		try {
			LinkedHashMap<Object, Object> map = new LinkedHashMap<>();
			for (Entry<Object, String> e : elements.entrySet()) {
				Object key = e.getKey();
				Object type = context.get(e.getValue());
				map.put(key, type);
			}
			context.put(variable, map);
			return Branches.DEFAULT;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
	}

	public static String isCreateDisabled(LightweightExecutionEnvironment env, ContextKeyFoundation modelElement) {
		
		LightweightExecutionContext context = env.getLocalContext();
		try {
			
			ModelElement me = (ModelElement) context.get(modelElement);
			if (CincoUtils.isCreateDisabled(me))
				return Branches.TRUE;
			
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
		
		return Branches.FALSE;
	}
	
	public static String isDeleteDisabled(LightweightExecutionEnvironment env,
			ContextKeyFoundation modelElement) {
		
		LightweightExecutionContext context = env.getLocalContext();
		try {
			
			ModelElement me = (ModelElement) context.get(modelElement);
			if (CincoUtils.isDeleteDisabled(me))
				return Branches.TRUE;
			
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
		
		return Branches.FALSE;
	}
	
	public static String isMoveDisabled(LightweightExecutionEnvironment env, ContextKeyFoundation modelElement) {
		
		LightweightExecutionContext context = env.getLocalContext();
		try {
			
			ModelElement me = (ModelElement) context.get(modelElement);
			if (CincoUtils.isMoveDisabled(me))
				return Branches.TRUE;
			
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
		
		return Branches.FALSE;
	}
	
	public static String isResizeDisabled(LightweightExecutionEnvironment env, ContextKeyFoundation modelElement) {
		
		LightweightExecutionContext context = env.getLocalContext();
		try {
			
			ModelElement me = (ModelElement) context.get(modelElement);
			if (CincoUtils.isResizeDisabled(me))
				return Branches.TRUE;
			
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
		
		return Branches.FALSE;
	}

	public static String isReconnectDisabled(LightweightExecutionEnvironment env, ContextKeyFoundation modelElement) {
	
		LightweightExecutionContext context = env.getLocalContext();
		try {
			
			ModelElement me = (ModelElement) context.get(modelElement);
			if (CincoUtils.isReconnectDisabled(me))
				return Branches.TRUE;
			
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
		
		return Branches.FALSE;
	}

	public static String isSelectDisabled(LightweightExecutionEnvironment env, ContextKeyFoundation modelElement) {
	
		LightweightExecutionContext context = env.getLocalContext();
		try {
			
			ModelElement me = (ModelElement) context.get(modelElement);
			if (CincoUtils.isSelectDisabled(me))
				return Branches.TRUE;
			
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
		
		return Branches.FALSE;
	}

	public static String isAttributeReadOnly(LightweightExecutionEnvironment env,
			ContextKeyFoundation attribute) {
		
		LightweightExecutionContext context = env.getLocalContext();
		try {
			
			Attribute attr = (Attribute) context.get(attribute);
			if (CincoUtils.isAttributeReadOnly(attr))
				return Branches.TRUE;
			
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
		
		return Branches.FALSE;
	}

	public static String isAttributeMultiValued(
			LightweightExecutionEnvironment env, ContextKeyFoundation attribute) {

		LightweightExecutionContext context = env.getLocalContext();
		try {
			Attribute attr = (Attribute) context.get(attribute);
			if (CincoUtils.isAttributeMultiValued(attr))
				return Branches.TRUE;
			
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
		
		return Branches.FALSE;
		
	}

	public static String isAttributeMultiLine(
			LightweightExecutionEnvironment env, ContextKeyFoundation attribute) {

		LightweightExecutionContext context = env.getLocalContext();
		try {
			Attribute attr = (Attribute) context.get(attribute);
			if (CincoUtils.isAttributeMultiLine(attr))
				return Branches.TRUE;
			
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
		
		return Branches.FALSE;
		
	}

	@SuppressWarnings("rawtypes")
	public String createDummyGraphModel(LightweightExecutionEnvironmentAdapter env,Boolean dawid) {
		LightweightExecutionContext context = env.getLocalContext();
		try {
				GraphModel gm = dawid?DummyGenerator.createDawidDummyGM():DummyGenerator.createDummyGraphModel();
			context.putGlobally("graphModel", gm);
			context.putGlobally("apiPrefix", "C");
			context.putGlobally("outletPath", "/home/kopetzki/workspace/runtime-MGL/de.scce.cinco.product.dummy/src-gen/");
			context.putGlobally("pluginXMLPath", "/home/kopetzki/workspace/runtime-MGL/info.scce.cinco.product.dummy/plugin.xml");
			EPackage ePkg =GraphmodelPackage.eINSTANCE;
			
			context.putGlobally("abstractGraphModel",ePkg);
			context.put(new ContextKey("resource", Scope.GLOBAL, true).asFoundation(),new XMIResourceImpl(URI.createFileURI("/tmp/"+gm.getName()+".ecore")));
			HashMap<String, EPackage> ecoreMap = new HashMap<String,EPackage>(); 
			HashMap<EPackage, String> genModelMap = new HashMap<EPackage, String>();
			
			
			context.put("genmodelMap",genModelMap);
			context.put("registeredGeneratorPlugins",new HashMap());
			context.put("registeredPackageMap",ecoreMap);
			
			context.putGlobally("debugRun", true);
			
			return Branches.DEFAULT;
		} catch (Exception e) {
			context.putGlobally("exception", e);
			return Branches.ERROR;
		}
	}

	public String createDummyStyles(LightweightExecutionEnvironmentAdapter env) {
		
		LightweightExecutionContext context = env.getLocalContext();
		try {
			Styles stlyes = DummyGenerator.createDummyStyles();
			context.putGlobally("styles", stlyes);
			context.putGlobally("debugRun", true);
			
			return Branches.DEFAULT;
		} catch (Exception e) {
			context.putGlobally("exception", e);
			return Branches.ERROR;
		}
	}

	public static String isELExpression(LightweightExecutionEnvironment env,
			ContextKeyFoundation modelElement,
			ContextKeyFoundation value,
			ContextKeyFoundation attributeName) {
		LightweightExecutionContext context = env.getLocalContext();
		try {
			ModelElement me = (ModelElement) context.get(modelElement);
			String s = (String) context.get(value);
			Pattern p = Pattern.compile("\\$\\{.*\\}");
			Matcher m = p.matcher(s);
			
			if (m.matches())
				return Branches.TRUE;
			else return Branches.FALSE;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
	}
	
}
