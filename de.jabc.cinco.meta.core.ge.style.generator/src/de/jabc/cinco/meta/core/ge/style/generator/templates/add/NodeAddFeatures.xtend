package de.jabc.cinco.meta.core.ge.style.generator.templates.add

import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoAbstractAddFeature
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.StyleUtils
import de.jabc.cinco.meta.core.referenceregistry.ReferenceRegistry
import de.jabc.cinco.meta.core.utils.CincoUtil
import graphmodel.ModelElementContainer
import mgl.Node
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IAddContext
import org.eclipse.graphiti.features.context.impl.AddContext
import org.eclipse.graphiti.features.context.impl.CreateContext
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.services.IGaService
import org.eclipse.graphiti.services.IPeService
import style.NodeStyle
import style.Styles
import graphmodel.internal.InternalModelElement
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import graphmodel.internal.InternalModelElementContainer

class NodeAddFeatures extends StyleUtils {

	extension APIUtils = new APIUtils()
	
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

public class AddFeature«n.fuName» extends «CincoAbstractAddFeature.name» {
	
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
		link(pe, bo);
		if (pe instanceof «ContainerShape.name») {
			((«ContainerShape.name») pe).getChildren().forEach(c -> linkAllShapes(c, bo));
		}
	}
}
'''
	}
	
	/**
	 * Generates the 'Add-Feature' for a given node with the extra that nodes can be marked as 'prime'
	 * @param n : The node
	 * @param styles : The style
	 * 
	 */
	def doGeneratePrimeAddFeature(Node n,Styles styles) {
		this.n = n
		s=CincoUtil.getStyleForNode(n, styles)
'''package «n.packageNameAdd»;

public class AddFeaturePrime«n.fuName» extends «CincoAbstractAddFeature.name» {
	
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
		«ContainerShape.name» container = context.getTargetContainer();
		«EObject.name» target = 
			«Graphiti.name».getLinkService().getBusinessObjectForLinkedPictogramElement(container);
		«EObject.name» bo = («EObject.name») context.getNewObject();
		if (!(target instanceof «InternalModelElementContainer.name»))
			return false;
		if((bo.eClass().getName().equals("«n.primeReference.primeType»")
				|| (bo.eClass().getEAllSuperTypes().stream().anyMatch(_superClass -> _superClass.getName().equals("«n.primeReference.primeType»"))))
				&& bo.eClass().getEPackage().getNsURI().equals("«n.primeReference.nsURI»"))
		
			return ((«InternalModelElementContainer.name») target).canContain(«n.fqBeanName».class);
		return false;
	}
	
	/**
	 * Adds a pictogram element to a ContainerShape.
	 * @param context : Contains the information, needed to let a feature add a pictogram element 
	*/
	public «PictogramElement.name» add(«IAddContext.name» context) {
		«n.packageNameCreate».CreateFeature«n.fuName» cf = 
			new «n.packageNameCreate».CreateFeature«n.fuName»(getFeatureProvider());
		
		«CreateContext.name» cc = 
			new «CreateContext.name»();
			
		cc.setTargetContainer(context.getTargetContainer());
		«Object.name»[] newObject = cf.create(cc);
		if (newObject.length == 0) throw new «RuntimeException.name»("Failed to create object in \"CreateFeature«n.fuName»\"");
		«Object.name» object = newObject[0];
		if (object instanceof «n.fqBeanName») {
			«n.fqInternalBeanName» ime = («n.fqInternalBeanName») ((«n.fqBeanName») object).getInternalElement();
			ime.setLibraryComponentUID(«EcoreUtil.name».getID((«EObject.name») context.getNewObject()));
			«ReferenceRegistry.name».getInstance().addElement((«EObject.name») context.getNewObject());
			«n.packageNameAdd».AddFeature«n.fuName» af = new «n.packageNameAdd».AddFeature«n.fuName»(getFeatureProvider());
			«AddContext.name» ac = new «AddContext.name»(context, ime);
			if (af.canAdd(ac))
				return af.add(ac);
		}
		return null;
	}
	
}
'''
	}
	
}