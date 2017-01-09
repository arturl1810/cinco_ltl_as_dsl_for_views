package de.jabc.cinco.meta.core.ge.style.generator.templates

import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils;
import mgl.GraphModel
import org.eclipse.emf.ecore.EObject
import java.io.File
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IProject
import java.io.FileNotFoundException
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException
import org.eclipse.graphiti.dt.IDiagramTypeProvider
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.IEditorPart
import org.eclipse.graphiti.ui.services.GraphitiUi
import graphmodel.ModelElementContainer
import graphmodel.ModelElement
import org.eclipse.emf.ecore.util.EcoreUtil
import graphmodel.Edge
import java.util.Arrays
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.features.IFeatureProvider
import org.osgi.framework.Bundle
import org.eclipse.core.runtime.Platform
import org.eclipse.core.runtime.FileLocator
import org.eclipse.core.resources.ResourcesPlugin
import graphmodel.Container
import org.eclipse.core.runtime.Path
import org.eclipse.graphiti.services.Graphiti
import style.Polygon
import style.Polyline

class GraphitiUtilsTmpl extends GeneratorUtils {

/**
 * Generates a utility class for the {@link Graphiti} framework. The class is used to
 * load images and compute and transform {@link Polygon} and {@link Polyline} points
 * 
 * TODO: This class should be moved to cinco-meta.
 * 
 * @param gm The processed {@link GraphModel}
 */	
def generateGraphitiUtils(GraphModel gm)
'''package «gm.packageName»;

public class «gm.fuName»GraphitiUtils {

	public static final «String.name» KEY_FORMAT_STRING = "formatString";
	private «gm.fuName»ImageProvider ip;
	private «IDiagramTypeProvider.name» dtp;

	private static «gm.fuName»GraphitiUtils instance;

	private «gm.fuName»GraphitiUtils() {
	}
	
	public static «gm.fuName»GraphitiUtils getInstance() {
		if (instance == null)
			instance = new «gm.fuName»GraphitiUtils();
		return instance;
	}

	public static «gm.beanPackage».«gm.fuName» addToResource(«Diagram.name» d, «IFeatureProvider.name» fp) {
		«gm.beanPackage».«gm.fuName» somegraph = null;
		for (Object o : d.eResource().getContents()){
			if (o instanceof «gm.beanPackage».«gm.fuName») {
				somegraph = («gm.beanPackage».«gm.fuName») o;
				break;
			}
		}
		if (somegraph == null) {
			somegraph = «gm.beanPackage».«gm.firstUpperOnly»Factory.eINSTANCE.create«gm.fuName»();
			d.eResource().getContents().add(somegraph);
			fp.link(d, somegraph);
		}
		
	return somegraph;
	}

	public «String.name» loadGraphitiImage(«String.name» path, «EObject.name» bo) {
		try{
		
			«File.name» file = new «File.name»(path);
			«Bundle.name» b = «Platform.name».getBundle("«gm.package»");
			«File.name» bundleFile = «FileLocator.name».getBundleFile(b);
		
			if (!file.exists()) {
				«String.name» filePath = bo.eResource().getURI().toPlatformString(true);
				«IFile.name» resFile = «ResourcesPlugin.name».getWorkspace().getRoot().getFile(new «Path.name»(filePath));
				«IProject.name» p = resFile.getProject();
				«IFile.name» iFile = p.getFile(path);
				if (iFile.exists()) {
					file = iFile.getLocation().toFile();
				}
				else {
					throw new «FileNotFoundException.name»("No file with path: " + path +" found...");
				}
			}
			
			«FileInputStream.name» fis = new «FileInputStream.name»(file);
			«File.name» trgFile = bundleFile.toPath().resolve("icons/"+file.getName()).toFile();
			trgFile.createNewFile();
			«FileOutputStream.name» fos = new «FileOutputStream.name»(trgFile);
			
			copy(fis, fos);
			
			«String.name» id = (file.getName().contains(".") ? file.getName().split("\\.")[0] : file.getName());
			«String.name» relPath = "icons/" + file.getName();
			addImage(id, relPath);
			return id;
			
		} catch («FileNotFoundException.name» e) {
			e.printStackTrace();
		} catch («IOException.name» e) {
			e.printStackTrace();
		} 
		return null;
		
	}

	public void addImage(«String.name» id, «String.name» path) {
		ip.addImage(id, path);
	}

	public «String.name» getImageId(«String.name» path) {
		return ip.getImageId(path);
	}

	public void setImageProvider(«gm.fuName»ImageProvider ip) {
		this.ip = ip;
	}

	public void loadImages() {
		ip.initImages();
	}

	public void setDTP(«IDiagramTypeProvider.name» dtp) {
		this.dtp = dtp;
	}
	
«««	public «IDiagramTypeProvider.name» getDTP() {
«««		if («PlatformUI.name».getWorkbench().getActiveWorkbenchWindow() == null ||
«««				«PlatformUI.name».getWorkbench().getActiveWorkbenchWindow().getActivePage() == null) 
«««			return loadByDarkFeature();
«««		«IEditorPart.name» part = «PlatformUI.name».getWorkbench().getActiveWorkbenchWindow().getActivePage().getActiveEditor();
«««		if (part instanceof «gm.fuName»DiagramEditor)
«««			return ((«gm.fuName»DiagramEditor) part).getDiagramTypeProvider();
«««		return this.dtp;
«««	}

«««	private «IDiagramTypeProvider.name» loadByDarkFeature() {
«««		«IDiagramTypeProvider.name» dtp = «GraphitiUi.name».getExtensionManager().createDiagramTypeProvider(«gm.fuName»Wrapper.DTP_ID);
«««		return dtp;
«««	}

	private void copy(«FileInputStream.name» fis, «FileOutputStream.name» fos) {
		int b = 0;
		try {
			while ((b = fis.read()) != -1) {
				fos.write(b);
			}
			fis.close();
			fos.flush();
			fos.close();
		} catch («IOException.name» e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public «ModelElementContainer.name» getCommonContainer(«ModelElementContainer.name» ce, «Edge .name» e) {
		«ModelElement.name» source = e.getSourceElement();
		«ModelElement.name» target = e.getTargetElement();
		if («EcoreUtil.name».isAncestor(ce, source) && «EcoreUtil.name».isAncestor(ce, target)) {
			for («Container.name» c : ce.getAllContainers()) {
				if («EcoreUtil.name».isAncestor(c, source) && «EcoreUtil.name».isAncestor(c, target)) {
					return getCommonContainer(c, e);
				}
			}
		} else if (ce instanceof «ModelElement.name») {
			return getCommonContainer(((«ModelElement.name») ce).getContainer(), e);
		}
		return ce;
		
	}

	public int max(int[] values) {
		java.util.OptionalInt max = «Arrays.name».stream(values).max();
		if (max.isPresent())
			return max.getAsInt();
		else return 0;
	}

	public int min(int[] values) {
		java.util.OptionalInt min = «Arrays.name».stream(values).min();
		if (min.isPresent())
			return min.getAsInt();
		else return 0;
	}
	
	public int[] transform(int[] values, int deltaX, int deltaY) {
		if (values.length > 0) {
			for (int i=0; i<values.length;i+=2){
				values[i] = values[i] + deltaX;
				values[i+1] = values[i+1] + deltaY;
			}
		}
		return values;
	}

}

'''
	
}