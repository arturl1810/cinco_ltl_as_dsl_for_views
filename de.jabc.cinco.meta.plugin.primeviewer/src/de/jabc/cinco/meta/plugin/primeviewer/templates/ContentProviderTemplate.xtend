package de.jabc.cinco.meta.plugin.primeviewer.templates

import mgl.Node
import org.eclipse.core.resources.IProject
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import de.jabc.cinco.meta.core.utils.projects.ContentWriter
import org.eclipse.jface.viewers.Viewer
import org.eclipse.jface.viewers.ITreeContentProvider
import org.eclipse.emf.ecore.EObject
import org.eclipse.core.resources.IFile
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import java.util.ArrayList
import org.eclipse.emf.common.util.TreeIterator
import de.jabc.cinco.meta.plugin.primeviewer.PrimeViewerExtension

class ContentProviderTemplate {

	static extension PrimeViewerExtension pvExtension = new PrimeViewerExtension

	def static doGenerateContentProviderContent(Node n, IProject p) {
		val packageName = n.graphModel.package+'.primeviewer.'+n.primeTypePackagePrefix
		ContentWriter::writeJavaFile(p, 'src', packageName, n.primeTypeName+"ContentProvider.java", n.getContent.toString);
	}

	def static getContent(Node n) '''
	package «n.graphModel.package».primeviewer.«n.primeTypePackagePrefix»;
	
	
	public class «n.primeTypeName»ContentProvider implements «ITreeContentProvider.name»{
	
		private «Viewer.name» viewer;
	
		@Override
		public void dispose() {
			
		}
	
		@Override
		public void inputChanged(«Viewer.name» viewer, «Object.name» oldInput, «Object.name» newInput) {
			this.viewer = viewer;
			
		}
	
		@Override
		public «Object.name»[] getElements(«Object.name» inputElement) {
			return null;
		}
	
		@Override
		public «Object.name»[] getChildren(«Object.name» parentElement) {
			try{
			if(parentElement instanceof «IFile.name»){
			«IFile.name» file = («IFile.name») parentElement;
			if(file.getName().endsWith("«n.primeFileExtension»")){
				«URI.name» fileURI = «URI.name».createPlatformResourceURI(file.getFullPath().toString(), true) ;
				«EObject.name» prime = null;
				«Resource.name» resource = new «ResourceSetImpl.name»().getResource(fileURI, true);
				«ArrayList.name»<«EObject.name»> eObjList = new «ArrayList.name»<>();
				«TreeIterator.name»<«EObject.name»> x = resource.getAllContents();
				while(x.hasNext()){
				«EObject.name» o = x.next();
		            if((o.eClass().getName().equals("«n.primeTypeName»")||o.eClass().getEAllSuperTypes().stream().anyMatch(e -> e.getName().equals("«n.primeTypeName»")) )&& o.eClass().getEPackage().getNsPrefix().equals("«n.primeTypePackagePrefix»")){
			        		prime = o;
			        		eObjList.add(o);
			        }
		        		
		        }
		        if(prime==null)
		        	return null;
		        
		        return eObjList.toArray();
		        
			}
			return null;
			}
			return null;
			}catch(Exception e){
				return null;		
			}
		}
	
		@Override
		public «Object.name» getParent(«Object.name» element) {
	
			return null;
		}
	
		@Override
		public boolean hasChildren(«Object.name» element) {
			try{
			if(element instanceof «IFile.name»){
			«IFile.name» file = («IFile.name») element;
			if(file.getName().endsWith("«n.primeFileExtension»")){
				«URI.name» fileURI = «URI.name».createPlatformResourceURI(file.getFullPath().toString(), true) ;
				«Resource.name» resource = new «ResourceSetImpl.name»().getResource(fileURI, true);	        
				return resource.getContents().size()>=1;
			}
			return false;
		}
		}catch(«Exception.name» e){return false;}
		
		return false;
		}
	}
	'''
	
}