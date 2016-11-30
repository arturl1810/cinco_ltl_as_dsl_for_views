package de.jabc.cinco.meta.core.ge.style.generator.templates


import de.jabc.cinco.meta.core.ge.style.generator.templates.util.GeneratorUtils
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

class ImageProviderTmpl extends GeneratorUtils{

	
	
	def generateImageProvider(GraphModel gm)
'''package «gm.packageName»;

public class «gm.fuName»ImageProvider extends «AbstractImageProvider.name» 
	implements «IImageProvider.name» {

	private «Hashtable.name»<«String.name», «String.name»> images;
	
	public «gm.fuName»ImageProvider() {
		«gm.fuName»GraphitiUtils.getInstance().setImageProvider(this);
	}

	public void addImage(«String.name» id, «String.name» path) {
		if (images == null) {
			images = new «Hashtable.name»<«String.name», «String.name»>();
		}
		images.put(id, path);
		addAvailableImages();
	}
	
	public «String.name» getImageId(«String.name» path) {
		for («Entry.entryName»<«String.name», «String.name»> e : images.entrySet()){
			if (e.getValue().equals(path))
				return e.getKey();
		}
		
		return "";
	}

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
def static EList<Node> getIconNodes(GraphModel gm){
		var EList <Node> foundNodes = new BasicEList <Node>();
		var EList <Node> nodes = gm.nodes;		
		for(node : nodes){
			var EList <mgl.Annotation> annots = node.annotations;
			for(annot : annots){
				if(annot.name.equals("icon")){
					foundNodes.add(node);
					}							
				}				
			}
			return foundNodes;			
	}

}