package de.jabc.cinco.meta.plugin.primeviewer.tmpl.file

import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import de.jabc.cinco.meta.plugin.template.FileTemplate
import java.util.ArrayList
import mgl.Node
import org.eclipse.core.resources.IFile
import org.eclipse.emf.common.util.TreeIterator
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.jface.viewers.ITreeContentProvider
import org.eclipse.jface.viewers.Viewer

class ContentProviderTmpl extends FileTemplate {
	
	static extension GeneratorUtils = new GeneratorUtils
	
	Node node
	CharSequence primeTypeName
	CharSequence primeTypePackagePrefix
	
	new(Node primeNode) {
		node = primeNode
		primeTypeName = node.primeTypeName
		primeTypePackagePrefix = node.primeTypePackagePrefix
	}
	
	override getTargetFileName() '''«primeTypeName»ContentProvider.java'''
	
	override template() '''
		package «package»;
		
		public class «primeTypeName»ContentProvider implements «ITreeContentProvider.name»{
		
			private «Viewer.name» viewer;
		
			@Override
			public void dispose() {}
		
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
				if(file.getName().endsWith("«node.primeFileExtension»")){
					«URI.name» fileURI = «URI.name».createPlatformResourceURI(file.getFullPath().toString(), true) ;
					«EObject.name» prime = null;
					«Resource.name» resource = new «ResourceSetImpl.name»().getResource(fileURI, true);
					«ArrayList.name»<«EObject.name»> eObjList = new «ArrayList.name»<>();
					«TreeIterator.name»<«EObject.name»> x = resource.getAllContents();
					while(x.hasNext()){
					«EObject.name» o = x.next();
					          if((o.eClass().getName().equals("«primeTypeName»")||o.eClass().getEAllSuperTypes().stream().anyMatch(e -> e.getName().equals("«primeTypeName»")) )&& o.eClass().getEPackage().getNsPrefix().equals("«primeTypePackagePrefix»")){
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
				if(file.getName().endsWith("«node.primeFileExtension»")){
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
	
	CharSequence _primeFileExtension
	
	def primeFileExtension(Node it) {
		_primeFileExtension ?: (_primeFileExtension =
			anyPrimeReference.annotations
				.findFirst[name == "pvFileExtension"]
				?.value?.get(0) ?: primeTypeName)
	}
}
