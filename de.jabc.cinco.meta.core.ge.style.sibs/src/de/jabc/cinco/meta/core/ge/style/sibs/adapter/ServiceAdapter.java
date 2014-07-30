package de.jabc.cinco.meta.core.ge.style.sibs.adapter;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.nio.file.FileSystem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import mgl.Annotation;
import mgl.Attribute;
import mgl.GraphModel;
import mgl.GraphicalElementContainment;
import mgl.Import;
import mgl.ModelElement;
import mgl.Node;
import mgl.NodeContainer;
import mgl.ReferencedAttribute;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.EcoreFactory;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.emf.ecore.xml.type.internal.RegEx.REUtil;

import style.AbsolutPosition;
import style.AbstractShape;
import style.Alignment;
import style.Appearance;
import style.Color;
import style.ConnectionDecorator;
import style.ContainerShape;
import style.EdgeStyle;
import style.Font;
import style.HAlignment;
import style.LineStyle;
import style.NodeStyle;
import style.Size;
import style.Style;
import style.StyleFactory;
import style.Styles;
import style.VAlignment;
import de.jabc.adapter.common.collection.Branches;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;
import de.metaframe.jabc.framework.sib.parameter.foundation.ContextExpressionFoundation;
import de.metaframe.jabc.framework.sib.parameter.foundation.ContextKeyFoundation;


public class ServiceAdapter {

	private static Map<String, String> shapeNames = new HashMap<String, String>();
	private static Map<String, String> gaNames = new HashMap<String, String>();
	private static Map<String, String> keywords = new HashMap<String, String>();
	private static int appearanceCount = 0;
	
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
						for (Attribute a : n.getAttributes()) {
							if (a.getName().equals(attrName)) {
								context.put(attributeName, attrName);
								return "NodeAttribute";
							}
						}
					}
				} else {
					for (Attribute a : me.getAttributes()) {
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

	public static String loadGraphitiImage(LightweightExecutionEnvironment env,
			ContextKeyFoundation imagePath, ContextKeyFoundation imageId, ContextKeyFoundation relativePath) {

		LightweightExecutionContext context = env.getLocalContext();
		try {
			String p = (String) context.get(imagePath);
			String projectName = (String) context.get("projectName");
			String mglProjectName = (String) context.get("mglProjectName");
			File file = new File(p);
			if (file.exists()) {
				FileInputStream fis = new FileInputStream(file);
				File trgFile = ResourcesPlugin.getWorkspace().getRoot().getProject(projectName).getFolder("icons").getFile(file.getName()).getLocation().toFile();
				trgFile.createNewFile();
				OutputStream os = new FileOutputStream(trgFile);
				int bt;
				while ((bt = fis.read()) != -1) {
					os.write(bt);
				}
				fis.close();
				os.flush();
				os.close();
				String id = (file.getName().contains(".") ? file.getName().split("\\.")[0] : file.getName());
				String relPath = "icons/" + file.getName();
				context.put(relativePath, relPath);
				context.put(imageId, id);
				return Branches.DEFAULT;
			} else {
				IProject project = ResourcesPlugin.getWorkspace().getRoot().getProject(mglProjectName);
				IFile iFile = project.getFile(p);
				if (iFile.exists()) {
					String id = (iFile.getName().contains(".") ? iFile.getName().split("\\.")[0] : iFile.getName());
					context.put(imageId, id);
					context.put(relativePath, p);
					return Branches.DEFAULT;
				}
			}
			System.out.println("Throwing exception");
			context.putGlobally("exception", new Exception("No file found at given path: " + p));
			return Branches.ERROR;
			
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
			NodeContainer nc = (NodeContainer) context.get(nodeContainer);
			ModelElement n = (ModelElement) context.get(node);
			
			for (GraphicalElementContainment containedNode : nc.getContainableElements() ) {
				if (containedNode.getType() == null)
					return Branches.TRUE;
				if (containedNode.getType().equals(n)) {
					return Branches.TRUE;
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
			ContainerShape relTo = relPos.getRelativeTo();
			Size relToSize = relTo.getSize();
			
			Size shapeSize = (Size) context.get(size);
			
			HAlignment ha = relPos.getHorizontal();
			VAlignment va = relPos.getVertical();
			int xMargin = relPos.getXMargin();
			int yMargin = relPos.getYMargin();

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

			absPos.setXPos(x+xMargin);
			absPos.setYPos(y+yMargin);
			
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
	
	private static void setValues(Appearance app, Appearance newApp) {
		if (app != null) {
			Appearance parent = app.getParent();
			
			setValues(parent, newApp);
			
			if (app.getAngle() != -1) 
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
			newApp.setFilled(true);
		if (newApp.getLineInVisible() == null)
			newApp.setLineInVisible(false);
		if (newApp.getAngle() == -1)
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
				String importUri = i.getImportURI();
				importUri = importUri.replace("platform:/resource", "");
				IPath path = new Path(importUri);
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
			Integer count = 0;
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
				list.add(es.getInlineAppearance());
			}
		
			for (ConnectionDecorator cd : es.getDecorator()) {
				if (cd.getDecoratorShape() instanceof AbstractShape) {
					getInlineAppearance((AbstractShape) cd.getDecoratorShape(), list);
				}
				
				if (cd.getPredefinedDecorator() != null &&
						cd.getPredefinedDecorator().getInlineAppearance() != null) {
					String name = "_Appearance" + appearanceCount++;
					cd.getPredefinedDecorator().getInlineAppearance().setName(name);
					list.add(cd.getPredefinedDecorator().getInlineAppearance());
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
			context.put(width, maxWidth);
			return Branches.DEFAULT;
		} catch (Exception e) {
			context.put("exception", e);
			return Branches.ERROR;
		}
	}
}
