package de.jabc.cinco.meta.plugin.primeviewer.tmpl.file

import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import de.jabc.cinco.meta.plugin.template.FileTemplate
import graphmodel.GraphModel
import graphmodel.ModelElement
import graphmodel.Type
import java.net.MalformedURLException
import java.net.URI
import java.net.URISyntaxException
import mgl.Node
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.IWorkspace
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.jface.viewers.ILabelProvider
import org.eclipse.jface.viewers.ILabelProviderListener
import org.eclipse.swt.graphics.Image

class LabelProviderTmpl extends FileTemplate {
	
	static extension GeneratorUtils = new GeneratorUtils
	
	Node node
	CharSequence primeTypeName
	
	new(Node primeNode) {
		node = primeNode
		primeTypeName = node.primeTypeName
	}
	
	override getTargetFileName() '''«primeTypeName»LabelProvider.java'''
	
	override template() '''
		package «package»;
		
		public class «primeTypeName»LabelProvider implements «ILabelProvider.name» {
		
			@Override
			public void addListener(«ILabelProviderListener.name» listener) {}
		
			@Override
			public void dispose() {}
		
			@Override
			public boolean isLabelProperty(«Object.name» element, «String.name» property) {
				return false;
			}
		
			@Override
			public void removeListener(«ILabelProviderListener.name» listener) {}
		
			@Override
			public «Image.name» getImage(«Object.name» element) {
				if(element instanceof «EObject.name»){
					«EObject.name» eElement = («EObject.name») element;
					if(«primeTypeName»ProviderHelper.isA«primeTypeName»(eElement)){
						«EStructuralFeature.name» cincoImagePathFeature = eElement.eClass().getEStructuralFeature("cincoImagePath");
						if(cincoImagePathFeature!=null){
							«Object.name» imagePath= eElement.eGet(cincoImagePathFeature);
							«ImageDescriptor.name» imgDescriptor = null;
							try {
							                   «IProject.name» pr = getProject(eElement.eResource());
								«IFile.name» imageFile = pr.getFile(imagePath.toString());
								if(imageFile!=null && imageFile.exists())
									imgDescriptor = «ImageDescriptor.name».createFromURL(imageFile.getLocationURI().toURL());
								«Image.name» img = null;
								if(imgDescriptor!=null){
									img= imgDescriptor.createImage();
								}
								if(img!=null){
									return «ImageDescriptor.name».createFromImageData(img.getImageData().scaledTo(16, 16)).createImage();
								}else{
									imgDescriptor = «ImageDescriptor.name».createFromURL(new «URI.name»("file://"+imagePath.toString()).toURL());
									if(imgDescriptor!=null)
										img= imgDescriptor.createImage();
									if(img!=null)
										return «ImageDescriptor.name».createFromImageData(img.getImageData().scaledTo(16, 16)).createImage();
								}
								return «ImageDescriptor.name».createFromImageData(img.getImageData().scaledTo(16, 16)).createImage();
							} catch («MalformedURLException.name» e) {
								e.printStackTrace();
							} catch («URISyntaxException.name» e) {
								e.printStackTrace();
							}
						}
					}
				}
				return null;
			}
		
			@Override
			public String getText(«Object.name» element) {
				if(element instanceof «EObject.name»){
					«EObject.name» eElement = («EObject.name») element;
					if («primeTypeName»ProviderHelper.isA«primeTypeName»(eElement)) {
						
						if (eElement instanceof «GraphModel.name») {
							eElement = ((«GraphModel.name»)element).getInternalElement();
						}
						else if (eElement instanceof «ModelElement.name») {
							eElement = ((«ModelElement.name»)element).getInternalElement();
						}
						else if (eElement instanceof «Type.name») {
							eElement = ((«Type.name»)element).getInternalElement();
						}
						
						Object val = «node.primeElementLabel»;
						return (val != null) ? val.toString() : "«primeTypeName»";
					}
				}
				return null;
			}
		
			private «IProject.name» getProject(«Resource.name» res){
				«IWorkspace.name» workspace = «ResourcesPlugin.name».getWorkspace();
				«org.eclipse.emf.common.util.URI.name» uri = res.getURI();
				if(uri.isPlatformResource()) {
					«IFile.name» iFile = workspace.getRoot().getFile(new «Path.name»(uri.toPlatformString(true)));
					return iFile.getProject();
				}
				return null;
			}
		}
	'''
	
	
	def primeElementLabel(Node it) {
		val annotVal = anyPrimeReference?.annotations
			.findFirst[name == "pvLabel"]?.value?.get(0)
		if (!annotVal.nullOrEmpty)
			'''eElement.eGet(eElement.eClass().getEStructuralFeature("«annotVal»"))'''
		else
			'''"«primeTypeName»"'''
	}
}
