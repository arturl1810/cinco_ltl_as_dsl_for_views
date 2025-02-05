package de.jabc.cinco.meta.core.ge.style.generator.templates.add

import de.jabc.cinco.meta.core.ge.style.generator.templates.util.StyleUtil
import de.jabc.cinco.meta.core.referenceregistry.ReferenceRegistry
import de.jabc.cinco.meta.core.utils.CincoUtil
import graphmodel.internal.InternalIdentifiableElement
import graphmodel.internal.InternalModelElementContainer
import java.util.List
import mgl.Node
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IAddContext
import org.eclipse.graphiti.features.context.impl.AddContext
import org.eclipse.graphiti.features.context.impl.CreateContext
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.mm.pictograms.Shape
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.services.IGaService
import org.eclipse.graphiti.services.IPeService
import style.NodeStyle
import style.Styles
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoAddFeature
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoAddFeaturePrime

class NodeAddFeatures extends StyleUtil {
	
	var Node n;
	var NodeStyle s;

	/**
	 * Generates the 'Add-Feature' for a given node
	 * @param n : The node
	 * @param styles : The style
	 */
	def doGenerateNodeAddFeature(Node n, Styles styles) {

		this.n = n
		s = CincoUtil.getStyleForNode(n,styles)
'''package «n.packageNameAdd»;

public class AddFeature«n.fuName» extends «CincoAddFeature.name» {
	
	/**
	 * Call of the Superclass
	 * @param fp : Fp is the parameter of Superclass-call
	*/
	public AddFeature«n.fuName»(«IFeatureProvider.name» fp) {
		super(fp);
	}
	
	/**
	 * Checks if a context can be added.
	 * @param context : Contains the information, needed to let a feature add a pictogram element
	 * @return Returns true if the context can be added and false if not.
	*/
	public boolean canAdd(«IAddContext.name» context) {
		return true;
	}
	
	/**
	 * Adds a pictogram element to a ContainerShape.
	 * @param context : Contains the information, needed to let a feature add a pictogram element
	*/
	public «PictogramElement.name» add(«IAddContext.name» context) {
		Object newObject = context.getNewObject();
		«n.fqInternalBeanName» bo = («n.fqInternalBeanName») newObject;
		
		«ContainerShape.name» d = context.getTargetContainer();
		
		«IPeService.name» peService = «Graphiti.name».getPeService();
		«IGaService.name» gaService = «Graphiti.name».getGaService();
		
		«s.mainShape.getAlgorithmCode("d",n)»
	}
	
	/**
	 * Links all Shapes by linking the given picotgram element to the given business or domain 
	 * @param pe : A representation of the model object "Pictogram Element"
	 * @param bo : A representation of the model object "EObject". EObject is the root of all modeled objects
	*/
	private void linkAllShapes(«PictogramElement.name» pe, «EObject.name» bo) {
		«EObject.name» elm = bo;
		if (bo instanceof «InternalIdentifiableElement.name») {
			elm = ((«InternalIdentifiableElement.name»)bo).getElement();
		}
		link(pe, elm);
		if (pe instanceof «ContainerShape.name») {
			«List.name»<«Shape.name»> children =
					((«ContainerShape.name») pe).getChildren();
			for («Shape.name» child : children) {
				linkAllShapes(child, elm);
			}
		}
	}
}
'''
	}
	
	/**
	 * Generates the 'Add-Feature' for a given prime
	 * @param n : The node
	 * @param styles : The style
	 * 
	 */
	def doGeneratePrimeAddFeature(Node n,Styles styles) {
		this.n = n
		s=CincoUtil.getStyleForNode(n, styles)
'''package «n.packageNameAdd»;

public class AddFeaturePrime«n.fuName» extends «CincoAddFeaturePrime.name» {
	
	/**
	 * Call of the superclass
	 * @param fp : fp is the parameter of the Superclass-call
	*/
	public AddFeaturePrime«n.fuName»(«IFeatureProvider.name» fp) {
		super(fp);
	}
	
	/**
	 * Checks if a context can be added
	 * @param context : Contains the information, needed to let a feature add a pictogram element
	 * @return Returns true if the context can be added and false if not.
	*/
	public boolean canAdd(«IAddContext.name» context) {
		createFeature = 
			new «n.packageNameCreate».CreateFeature«n.fuName»(getFeatureProvider());
		«CreateContext.name» cc = 
			new «CreateContext.name»();
		«ContainerShape.name» container = context.getTargetContainer();
		cc.setTargetContainer(container);
		«EObject.name» target = 
			«Graphiti.name».getLinkService().getBusinessObjectForLinkedPictogramElement(container);
		«"target".toInternalElement»
		«EObject.name» bo = («EObject.name») context.getNewObject();
		if (!(target instanceof «InternalModelElementContainer.name»))
			return false;
		
		«EObject.name» element = bo;
		if (bo instanceof «InternalIdentifiableElement.name»)
			element = ((«InternalIdentifiableElement.name») bo).getElement();
			
		if(
			((element.eClass().getName().equals("«n.retrievePrimeReference.primeTypeElement»")
				|| (element.eClass().getEAllSuperTypes().stream().anyMatch(_superClass -> _superClass.getName().equals("«n.retrievePrimeReference.primeTypeElement»")))
				&& element.eClass().getEPackage().getNsURI().equals("«n.retrievePrimeReference.nsURI»"))))
				return ((«InternalModelElementContainer.name») target).canContain(«n.fqBeanName».class);
			«IF (n.retrievePrimeReference.primeTypeElement.equals("EObject") && n.retrievePrimeReference.nsURI.equals("http://www.eclipse.org/emf/2002/Ecore"))»
			if (element.eClass().getName().equals("EObject")
				|| getAllSuperInterfaces(element.getClass()).stream().anyMatch(_superClass -> _superClass.getName().equals("org.eclipse.emf.ecore.EObject")))
				return ((«InternalModelElementContainer.name») target).canContain(«n.fqBeanName».class);
			«ENDIF»
		
		return false;
	}
	
	/**
	 * Adds a pictogram element to a ContainerShape.
	 * @param context : Contains the information, needed to let a feature add a pictogram element 
	*/
	public «PictogramElement.name» add(«IAddContext.name» context) {
		createFeature = 
			new «n.packageNameCreate».CreateFeature«n.fuName»(getFeatureProvider());
		
		«CreateContext.name» cc = 
			new «CreateContext.name»();
			
		«EObject.name» element = («EObject.name») context.getNewObject();
		if (element instanceof «InternalIdentifiableElement.name») {
			element = ((«InternalIdentifiableElement.name»)element).getElement();
		}
		
		cc.putProperty("libraryComponentUID", «ReferenceRegistry.name».getInstance().getID(element));
		«ReferenceRegistry.name».getInstance().addElement(element);
		cc.setTargetContainer(context.getTargetContainer());
		cc.setLocation(context.getX(), context.getY());
		cc.setSize(context.getWidth(), context.getHeight());
		«Object.name»[] newObject = createFeature.create(cc);
		if (newObject.length == 0) throw new «RuntimeException.name»("Failed to create object in \"CreateFeature«n.fuName»\"");
		return («PictogramElement.name») newObject[1];
	}
	
}
'''
	}
	
}