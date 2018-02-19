package de.jabc.cinco.meta.core.utils;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.apache.commons.io.FilenameUtils;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.codegen.ecore.genmodel.GenModel;
import org.eclipse.emf.codegen.ecore.genmodel.GenPackage;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.xtext.util.StringInputStream;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;

import de.jabc.cinco.meta.runtime.xapi.ResourceExtension;
import de.jabc.cinco.meta.util.xapi.FileExtension;
import de.jabc.cinco.meta.util.xapi.WorkspaceExtension;
import mgl.Annotatable;
import mgl.Annotation;
import mgl.Attribute;
import mgl.Edge;
import mgl.GraphModel;
import mgl.Import;
import mgl.ModelElement;
import mgl.Node;
import productDefinition.CincoProduct;
import style.EdgeStyle;
import style.NodeStyle;
import style.Style;
import style.Styles;


public class CincoUtil {
	
	static WorkspaceExtension workspaceExtension = new WorkspaceExtension();
	static FileExtension fileExtension = new FileExtension();
	static ResourceExtension resourceExtension = new ResourceExtension();
	
	public static final String ID_STYLE = "style";
	public static final String ID_ICON = "icon";
	public static final String ID_DISABLE= "disable";
	public static final String ID_DISABLE_CREATE = "create";
	public static final String ID_DISABLE_DELETE = "delete";
	public static final String ID_DISABLE_MOVE = "move";
	public static final String ID_DISABLE_RESIZE = "resize";
	public static final String ID_DISABLE_RECONNECT = "reconnect";
	public static final String ID_DISABLE_SELECT = "select";
	public static final String ID_ATTRIBUTE_HIDDEN = "propertiesViewHidden";
	public static final String ID_DISABLE_HIGHLIGHT = "disableHighlight";
	public static final String ID_DISABLE_HIGHLIGHT_CONTAINMENT = "containment";
	public static final String ID_DISABLE_HIGHLIGHT_RECONNECTION = "reconnection";
	public static Set<String> DISABLE_NODE_VALUES = new HashSet<String>(Arrays.asList("create", "delete", "move", "resize", "select"));
	public static Set<String> DISABLE_EDGE_VALUES = new HashSet<String>(Arrays.asList("create", "delete", "reconnect", "select"));
	public static Set<String> DISABLE_HIGHLIGHT_VALUES = new HashSet<String>(Arrays.asList("containment", "reconnection"));
	
	private final static String PLUGIN_FRAME = "<?xml version=\"1.0\" encoding=\""+System.getProperty("file.encoding")+"\"?>\n"
			+ "<?eclipse version=\"3.0\"?>\n"
			+ "<plugin>\n"
			+ "</plugin>";
	
	public static boolean isCreateDisabled(ModelElement me) {
		return isDisabled(me, ID_DISABLE_CREATE);
	}
	
	public static boolean isMoveDisabled(ModelElement me) {
		return isDisabled(me, ID_DISABLE_MOVE);
	}
	
	public static boolean isResizeDisabled(ModelElement me) {
		return isDisabled(me, ID_DISABLE_RESIZE);
	}
	
	public static boolean isSelectDisabled(ModelElement me) {
		return isDisabled(me, ID_DISABLE_SELECT);
	}
	
	public static boolean isReconnectDisabled(ModelElement me) {
		return isDisabled(me, ID_DISABLE_RECONNECT);
	}
	
	public static boolean isDeleteDisabled(ModelElement me) {
		return isDisabled(me, ID_DISABLE_DELETE);
	}
	
	public static boolean isDisabled(ModelElement me) {
		Set<String> values = DISABLE_NODE_VALUES;
		if (me instanceof mgl.Edge)
			values = DISABLE_EDGE_VALUES;
		for (Annotation annot : me.getAnnotations())
			if (annot.getName().equals(ID_DISABLE))
				return (annot.getValue().isEmpty() || annot.getValue().containsAll(values));
		return false;
	}
	
	private static boolean isDisabled(ModelElement me, String id) {
		for (Annotation annot : me.getAnnotations()) {
			if (annot.getName().equals(ID_DISABLE)) {
				return (annot.getValue().isEmpty() || annot.getValue().contains(id));
			}
		}
		return false;
	}
	
	public static boolean isHighlightContainmentDisabled(Annotatable me) {
		return isHighlightDisabled(me, ID_DISABLE_HIGHLIGHT_CONTAINMENT);
	}
	
	public static boolean isHighlightReconnectionDisabled(Annotatable me) {
		return isHighlightDisabled(me, ID_DISABLE_HIGHLIGHT_RECONNECTION);
	}
	
	public static boolean isHighlightDisabled(Annotatable me) {
		for (Annotation annot : me.getAnnotations()) {
			if (annot.getName().equals(ID_DISABLE_HIGHLIGHT)) {
				return annot.getValue().isEmpty() || annot.getValue().containsAll(DISABLE_HIGHLIGHT_VALUES);
			}
		}
		return false;
	}
	
	private static boolean isHighlightDisabled(Annotatable me, String id) {
		for (Annotation annot : me.getAnnotations()) {
			if (annot.getName().equals(ID_DISABLE_HIGHLIGHT)) {
				return annot.getValue().isEmpty() || annot.getValue().contains(id);
			}
		}
		return false;
	}
	
	public static boolean isAttributeReadOnly(Attribute attr) {
		for (Annotation annot : attr.getAnnotations()) {
			if (annot.getName().equals("readOnly"))
				return true;
		}
		return false;
	}
	
	public static boolean isAttributeFile(Attribute attr) {
		for (Annotation annot : attr.getAnnotations()) {
			if (annot.getName().equals("file"))
				return true;
		}
		return false;
	}
	
	public static boolean isAttributeColor(Attribute attr) {
		for (Annotation annot : attr.getAnnotations()) {
			if (annot.getName().equals("color"))
				return true;
		}
		return false;
	}
	
	public static boolean isAttributeHidden(Attribute attr) {
		for (Annotation annot : attr.getAnnotations()) {
			if (annot.getName().equals(ID_ATTRIBUTE_HIDDEN))
				return true;
		}
		return false;
	}
	
	public static boolean isGrammarAttribute(Attribute attr) {
		for (Annotation annot : attr.getAnnotations()) {
			if (annot.getName().equals("grammar"))
				return true;
		}
		return false;
	}
	
	public static Resource getStylesResource(String pathToStyles, IProject p) {
		Resource res = null;
		URI uri = URI.createURI(pathToStyles, true);
		try {
			res = null;
			if (uri.isPlatformResource())
				res = new ResourceSetImpl().getResource(uri, true);
			else {
				IFile file = p.getFile(pathToStyles);
				URI fileURI = URI.createPlatformResourceURI(file.getFullPath().toOSString(), true);
				res = new ResourceSetImpl().getResource(fileURI, true);
			}
			return res;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	
	public static Styles getStyles(GraphModel gm) {
		for (Annotation a : gm.getAnnotations()) {
			if (ID_STYLE.equals(a.getName())) {
				String path = a.getValue().get(0);
				URI uri = PathValidator.getURIForString(gm, path);
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
	
	public static boolean hasAppearanceProvider(ModelElement me) {
		Style style = getStyleForModelElement(me, getStyles(MGLUtil.getGraphModel(me)));
		return style.getAppearanceProvider() != null && !style.getAppearanceProvider().isEmpty();
	}
	
	public static String getAppearanceProvider(ModelElement me) {
		Style style = getStyleForModelElement(me, getStyles(MGLUtil.getGraphModel(me)));
		return style.getAppearanceProvider().replaceAll("\\\"", "");
	}
	
	public static Style getStyleForModelElement(mgl.ModelElement me , Styles st) {
		if (me instanceof Node)
			return getStyleForNode((mgl.Node) me, st);
		if (me instanceof Edge)
			return getStyleForEdge((mgl.Edge) me, st);
		return null;
	}
	
	public static NodeStyle getStyleForNode(mgl.Node n, Styles st) {
		Styles styles = st;
		String styleName = getStyleName(n);
		Style findStyle = findStyle(styles, styleName);
		if (findStyle instanceof NodeStyle)
			return (NodeStyle) findStyle;
		return null;
	}
	
	public static EdgeStyle getStyleForEdge(Edge e, Styles st) {
		Styles styles = st;
		String styleName = getStyleName(e);
		Style findStyle = findStyle(styles, styleName);
		if (findStyle instanceof EdgeStyle)
			return (EdgeStyle) findStyle;
		return null;
	}
	
	public static Styles getStyles(GraphModel gm,IProject project) {
		for (Annotation a : gm.getAnnotations()) {
			if (ID_STYLE.equals(a.getName())) {
				String path = a.getValue().get(0);
				IFile iFile = project.getFile(path);
				return new FileExtension().getContent(iFile, Styles.class);
			}
		}
		return null;
	}
	
	public static Style findStyle(Styles styles, String name) {
		if (styles == null)
			return null;
		for (Style s : styles.getStyles()) {
			if (name.equals(s.getName()))
				return s;
		}
		return null;
	}

	public static String getStyleName(ModelElement me) {
		List<Annotation> styles = me.getAnnotations().stream().filter(a -> a.getName().equals("style")).collect(Collectors.toList());
		if (styles != null && styles.size() > 0)
			return styles.get(0).getValue().get(0);
		return null;
	}
	
	public static CincoProduct getCincoProduct(IFile file) {
		URI uri = URI.createFileURI(file.getLocation().toString());
		Resource res = new ResourceSetImpl().getResource(uri, true);
		return getCincoProduct(res);
	}

	public static CincoProduct getCincoProduct(Resource res) {
		for (TreeIterator<EObject> it = res.getAllContents(); it.hasNext(); ) {
			EObject o = it.next();
			if (o instanceof CincoProduct)
				return (CincoProduct) o; 
		}
		return null;
	}
	
//	public static GraphModel getGraphModel(IFile file) {
//		URI uri = URI.createFileURI(file.getLocation().toString());
//		Resource res = new ResourceSetImpl().getResource(uri, true);
//		return getGraphModel(res);
//	}
//
//	public static GraphModel getGraphModel(Resource res) {
//		for (TreeIterator<EObject> it = res.getAllContents(); it.hasNext(); ) {
//			EObject o = it.next();
//			if (o instanceof GraphModel)
//				return (GraphModel) o; 
//		}
//		return null;
//	}

	public static Annotation getAnnotation(Attribute attr, String annotName) {
		List<Annotation> annots = attr.getAnnotations().stream().filter(a -> a.getName().equals(annotName)).collect(Collectors.toList());
		return (annots.isEmpty()) ? null : annots.get(0);
	}
	
	public static boolean isAttributeMultiValued(Attribute attr) {
		return attr.getUpperBound() != 1;
	}
	
	public static boolean isAttributeMultiLine(Attribute attr) {
		for (Annotation annot : attr.getAnnotations()) {
			if (annot.getName().equals("multiLine"))
				return true;
		}
		return false;
	}
	
	public static void refreshFiles(IProgressMonitor monitor, IFile...files) {
		for (IFile f : files)
			try {
				f.refreshLocal(IResource.DEPTH_ZERO, monitor);
			} catch (CoreException e) {
				System.err.println("Refresh folder error...");
				e.printStackTrace();
			}
	}
	
	public static void refreshFolders(IProgressMonitor monitor, IFolder...folders) {
		for (IFolder f : folders)
			try {
				f.refreshLocal(IResource.DEPTH_ONE, monitor);
			} catch (CoreException e) {
				System.err.println("Refresh folder error...");
				e.printStackTrace();
			}
	}

	public static void refreshProject(IProgressMonitor monitor, IProject p){
		try {
			p.refreshLocal(IResource.DEPTH_INFINITE, monitor);
		} catch (CoreException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public static List<String> getUsedExtensions(GraphModel gModel) {
		List<String> extensions = new ArrayList<>();
		for (Import i : gModel.getImports()) {
			if (i.getImportURI().endsWith(".mgl")) {
				GraphModel gm = getImportedGraphModel(i);
				extensions.add(gm.getFileExtension());
			}
			if (i.getImportURI().endsWith(".ecore")) {
				GenModel gm = getImportedGenmodel(i);
				extensions.add(getFileExtension(gm));
			}
		}
		extensions.add(gModel.getFileExtension());
		return extensions;
	}
	
	public static IFile getFile(URI uri, EObject obj) {
		IFile file = null;
		if (uri.isPlatform()) {
			file = workspaceExtension.getFile(uri);
		} else {
			file = workspaceExtension.getResource(obj).getProject().getFile(new Path(uri.toString()));
		}
		return file;
	}
	
	public static GenModel getImportedGenmodel(Import i) {
		URI uri = URI.createURI(FilenameUtils.removeExtension(i.getImportURI()).concat(".genmodel"));
		Resource res = getResource(uri.toString(), i.eResource());
		
		return resourceExtension.getContent(res, GenModel.class, 0);
	}

	public static GraphModel getImportedGraphModel(Import i) {
		URI uri = URI.createURI(i.getImportURI(), true);
		IFile file = getFile(uri, i);
		return fileExtension.getContent(file, GraphModel.class, 0);
	}
	
	private static String getFileExtension(GenModel genModel) {
		for (GenPackage gp : genModel.getAllGenPackagesWithClassifiers()) {
			return gp.getFileExtension();
		}
		
		return "";
	}

	public static EObject getCPD(IFile cpdFile) {
			URI uri = URI.createFileURI(cpdFile.getLocation().toString());
			Resource res = new ResourceSetImpl().getResource(uri, true);
			if (res == null)
				throw new RuntimeException("Could not load resource for: " + uri);
			if (res.getContents().isEmpty())
				throw new RuntimeException("Resource: \""+res+ "\" is empty...");
			return res.getContents().get(0);
	}
	
	/**This method adds an extension point to the plugin.xml file given by {@linkplain pluginXMLPath}.
	 * The extension point should be passed as String representing the extension point. If an extension with
	 * this {@linkplain extensionCommentID} already exists, the old one is replaced by this extension.
	 * 
	 * @param pluginXMLPath Location of the plugin.xml file
	 * @param content String representation of the extension point
	 * @param extensionCommentID An unique ID which will be added as identifier to the extension point
	 */
	public static void addExtension(String pluginXMLPath, String content, String extensionCommentID, String projectName) {
		String p = pluginXMLPath;
		String c = content;
		String pName = projectName;
		
		IProgressMonitor monitor = new NullProgressMonitor();
		try {
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
				String CINCO_GEN = extensionCommentID;
	//			String CINCO_GEN = new String("<!--@CincoGen "+gName+"-->");
				ArrayList<String> extensions = getExtensionsWithDOM(originalText);
				ArrayList<String> remove = new ArrayList<>();
				for (String ext : extensions) {
					if (ext.contains(CINCO_GEN))
						remove.add(ext);
				}
				
				extensions.removeAll(remove);
				
				StringBuilder updatedText = new StringBuilder(PLUGIN_FRAME);
				int offset = updatedText.indexOf("</plugin>");
				for (String ext : extensions)
					updatedText.insert(offset, ext);
				updatedText.insert(offset, c);				
				FileOutputStream fos = new FileOutputStream(f);
				fos.write(updatedText.toString().getBytes());
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
				//System.out.println(file.getFullPath());
			}
		}catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (CoreException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	/**
	 * Loads the resource for the specified {@link path}
	 * 
	 * @param path The path describing the resource location
	 * @param res A helper variable: If the path is given as project relative path, this parameter is used to compute the current {@link IProject}
	 */
	public static Resource getResource(String path, Resource res) {
        if (path == null || path.isEmpty())
        	return null;
         IWorkspaceRoot root = ResourcesPlugin.getWorkspace().getRoot();
         URI uri = URI.createURI(path);
        if (uri.isPlatform()) {
        	return res.getResourceSet().getResource(uri,true);
        } else {
	        IFile resFile = null;
	        if (res.getURI().isPlatform())
	        	resFile = root.getFile(new Path(res.getURI().toPlatformString(true)));
	        else resFile = root.getFileForLocation(Path.fromOSString(res.getURI().path()));
	        
	        IFile file = resFile.getProject().getFile(path);
        	return res.getResourceSet().getResource(getURI(file),true);
        }
        
	}
	
	private static URI getURI(IFile file) {
        if (file!=null && file.exists()) 
        	return URI.createPlatformResourceURI(file.getFullPath().toPortableString(), true);
        else return null;
	}
	
	private static ArrayList<String> getExtensionsWithDOM(String origText) {
		try {
			ArrayList<String> extensions = new ArrayList<>();
			DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
			Document doc = dBuilder.parse(new StringInputStream(origText));
			doc.getDocumentElement().normalize();
			NodeList extensionNodes = doc.getElementsByTagName("extension");
			for (int extensionIndex = 0; extensionIndex < extensionNodes.getLength(); extensionIndex++) {
				org.w3c.dom.Node extensionNode = extensionNodes.item(extensionIndex);				
				// https://stackoverflow.com/questions/2223020/convert-an-org-w3c-dom-node-into-a-string
				StringWriter writer = new StringWriter();
				Transformer transformer = TransformerFactory.newInstance().newTransformer();
				transformer.transform(new DOMSource(extensionNode), new StreamResult(writer));
				String extensionString = writer.toString();
				//remove <?xml version="1.0" encoding="UTF-8"?>
				extensionString = extensionString.substring(extensionString.indexOf("?>") + 2);
				extensions.add(extensionString);				
			}
			return extensions;			
		}
		catch (Throwable t) {
			throw new RuntimeException(t);
		}
	}
	
	public static void writeContentToFile(IFile f, String contents) {
		StringInputStream sis = new StringInputStream(contents);
		try {
			if (f.exists())
				f.setContents(sis, IResource.DEPTH_ONE, null);
			else f.create(sis, true, null);
		} catch (CoreException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public static Annotation findAnnotation(ModelElement me, String annotName) {
		EList<Annotation> anno = me.getAnnotations();
		Iterator<Annotation> iter = anno.iterator();
		while(iter.hasNext())
		{
			Annotation next = iter.next();
			if(next.getName().equals(annotName))
			{
				return next;
			}
		}
		return null;
	}
	
	public static Annotation findAnnotationPostCreate(ModelElement me)
	{
		return findAnnotation(me, "postCreate");
	}
	
	public static Annotation findAnnotationPostMove(ModelElement me)
	{
		return findAnnotation(me, "postMove");
	}
	
	public static Annotation findAnnotationPostResize(ModelElement me)
	{
		return findAnnotation(me, "postResize");
	}
	
	public static Annotation findAnnotationPostSelect(ModelElement me)
	{
		return findAnnotation(me, "postSelect");
	}
	
	public static Annotation findAnnotationDoubleClick(ModelElement me)
	{
		return findAnnotation(me, "doubleClickAction");
	}
	
}
