package de.jabc.cinco.meta.core.ge.style.generator.templates


import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils;
import org.eclipse.graphiti.ui.platform.AbstractImageProvider
import org.eclipse.graphiti.ui.platform.IImageProvider
import java.util.Hashtable
import java.util.Map.Entry
import org.osgi.framework.Bundle
import org.eclipse.core.runtime.Platform
import java.io.File
import java.net.URL
import org.eclipse.core.runtime.FileLocator
import java.util.Enumeration
import org.eclipse.core.runtime.IPath
import org.eclipse.core.runtime.Path
import java.io.IOException

import org.eclipse.emf.common.util.EList
import mgl.GraphModel
import mgl.Node
import org.eclipse.emf.common.util.BasicEList
import mgl.ModelElement

class ImageProviderTmpl extends GeneratorUtils {


	
/**
 * Generates the {@link IImageProvider} code
 *
 * @param gm The processed {@link mgl.GraphModel} 
 */	
	def generateImageProvider(GraphModel gm)
'''package «gm.packageName»;


public class «gm.fuName»ImageProvider extends «AbstractImageProvider.name» 
	implements «IImageProvider.name» {

	private «Hashtable.name»<«String.name», «String.name»> images;
	
	/**
	 * Sets an ImageProvider
	*/
	public «gm.fuName»ImageProvider() {
		«gm.fuName»GraphitiUtils.getInstance().setImageProvider(this);
	}

	/**
	 * Adds an image to the editor
	 * @param id : Id of an image
	 * @param path : Path of the image
	 */
	public void addImage(«String.name» id, «String.name» path) {
		if (images == null) {
			images = new «Hashtable.name»<«String.name», «String.name»>();
		}
		images.put(id, path);
		addAvailableImages();
	}
	
	/**
	 * Returns the id of an image.
	 * @param path : Path is the path of an image
	 * @return Returns the id of an image.
	*/
	public «String.name» getImageId(«String.name» path) {
		for («Entry.entryName»<«String.name», «String.name»> e : images.entrySet()){
			if (e.getValue().equals(path))
				return e.getKey();
		}
		
		return "";
	}
	
    /**
     * Adds available images if the 'ImageFilePath' is is null
     * If the HashTable 'images' is null a new one will be created
    */
	@Override
	protected void addAvailableImages() {
		if (images == null) {
			images = new «Hashtable.name»<«String.name», «String.name»>();
		}
		for («Entry.entryName»<«String.name», «String.name»> e : images.entrySet()) {
			if (getImageFilePath(e.getKey()) == null)
				addImageFilePath(e.getKey(), e.getValue());
		}
	}
	
	/**
	 * Each image is logged in by adding the images and creating the related path.
	*/
	public void initImages() {
		«Bundle.name» b = «Platform.name».getBundle("«gm.package».editor.graphiti");
		«File.name» file;
		try {
			«URL.name» url = null;
			
«««			Suche im GraphModel "gm" nach nodes die eine @icon Annotation haben
«««			Jedes gefundene icon muss angemeldet werden (siehe alten generator)
	
		«FOR iconnodes : getIconNodes(gm)» 
		url =  «FileLocator.name».find(b, new «Path.name»("«getIconNodeValue(iconnodes)»"), null);
		addImage("«getIconNodeValue(iconnodes)»", url.getPath());		
		«ENDFOR»
		
			file = «FileLocator.name».getBundleFile(b);
			«File.name» genIconsFile = file.toPath().resolve("resources-gen/icons").toFile();
			if (genIconsFile.exists()) {
				for («File.name» f : genIconsFile.listFiles()){
					«String.name» fileName = f.getName();
					«String.name» id = fileName;
					addImage(id, "/resources-gen/icons/"+fileName);
				}
			}
			if (!genIconsFile.exists() ) {
				«Enumeration.name»<«URL.name»> entries = b.findEntries("resources-gen/icons/", "*", true);
				while(entries.hasMoreElements()){
					«URL.name» entry = entries.nextElement();
					«IPath.name» path = new «Path.name»(entry.getPath());
					«File.name» i = path.toFile();
					«String.name» fileName = i.getName();
					«String.name» id = fileName;
					addImage(id, path.toString());
				}
			}
		} catch («IOException.name» e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}

'''
	/**
	 * Auxiliary method to get all nodes with the annotation "icon"
	 * @param gm : The Graphmodel
	 * @return Returns a list of all found nodes with the annotation "icon"
	 */
	def static EList<ModelElement> getIconNodes(GraphModel gm) {
		var EList<ModelElement> foundNodes = new BasicEList<ModelElement>();
		var EList<Node> nodes = gm.nodes;
		for (node : nodes) {
			var EList<mgl.Annotation> annots = node.annotations;
			for (annot : annots) {
				if (annot.name.equals("icon")) {
					foundNodes.add(node);
				}
			}
		}
		if (!gm.iconPath.nullOrEmpty)
			foundNodes.add(gm);
		
		return foundNodes;
	}

}
