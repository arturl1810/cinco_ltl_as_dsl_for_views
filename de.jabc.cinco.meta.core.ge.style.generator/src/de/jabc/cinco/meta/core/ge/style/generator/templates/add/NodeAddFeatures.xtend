package de.jabc.cinco.meta.core.ge.style.generator.templates.add

import de.jabc.cinco.meta.core.ge.style.generator.templates.util.StyleUtils
import de.jabc.cinco.meta.core.ge.style.model.features.CincoAbstractAddFeature
import de.jabc.cinco.meta.core.utils.CincoUtils
import graphmodel.ModelElementContainer
import mgl.Node
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IAddContext
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.services.IGaService
import org.eclipse.graphiti.services.IPeService
import style.NodeStyle
import style.Styles
import org.eclipse.graphiti.features.context.impl.CreateContext
import org.eclipse.graphiti.features.context.impl.AddContext
import de.jabc.cinco.meta.core.referenceregistry.ReferenceRegistry

class NodeAddFeatures extends StyleUtils {
	
	var Node n;
	var NodeStyle s;
	
	def doGenerateNodeAddFeature(Node n, Styles styles) {
		this.n = n
		s = CincoUtils.getStyleForNode(n,styles)
'''package «n.packageNameAdd»;

public class AddFeature«n.fuName» extends «CincoAbstractAddFeature.name» {
	
	public AddFeature«n.fuName»(«IFeatureProvider.name» fp) {
		super(fp);
	}
	
	public boolean canAdd(«IAddContext.name» context) {
		return true;
	}
	
	public «PictogramElement.name» add(«IAddContext.name» context) {
		«n.fqBeanName» bo = («n.fqBeanName») context.getNewObject();
		if (bo.getId() == null || bo.getId().isEmpty())
			bo.setId(«EcoreUtil.name».generateUUID());
		
		«ContainerShape.name» d = context.getTargetContainer();
		
		«IPeService.name» peService = «Graphiti.name».getPeService();
		«IGaService.name» gaService = «Graphiti.name».getGaService();
		
		«s.mainShape.getAlgorithmCode("d",n)»
	}
	
	private void linkAllShapes(«PictogramElement.name» pe, «EObject.name» bo) {
		link(pe, bo);
		if (pe instanceof «ContainerShape.name») {
			((«ContainerShape.name») pe).getChildren().forEach(c -> linkAllShapes(c, bo));
		}
	}
}
'''
	}
	
	def doGeneratePrimeAddFeature(Node n,Styles styles) {
		this.n = n
		s=CincoUtils.getStyleForNode(n, styles)
'''package «n.packageNameAdd»;

public class AddFeaturePrime«n.fuName» extends «CincoAbstractAddFeature.name» {
	
	public AddFeaturePrime«n.fuName»(«IFeatureProvider.name» fp) {
		super(fp);
	}
	
	public boolean canAdd(«IAddContext.name» context) {
		«ContainerShape.name» container = context.getTargetContainer();
		«EObject.name» target = 
			«Graphiti.name».getLinkService().getBusinessObjectForLinkedPictogramElement(container);
		«EObject.name» bo = («EObject.name») context.getNewObject();
		if (!(target instanceof «ModelElementContainer.name»))
			return false;
		if((bo.eClass().getName().equals("«n.primeReference.primeType»")
				|| (bo.eClass().getEAllSuperTypes().stream().anyMatch(_superClass -> _superClass.getName().equals("«n.primeReference.primeType»"))))
				&& bo.eClass().getEPackage().getNsURI().equals("«n.primeReference.nsURI»"))
		
			return ((«ModelElementContainer.name») target).canContain(«n.fqBeanName».class);
		return false;
	}
	
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
			((«n.fqBeanName») object).setLibraryComponentUID(«EcoreUtil.name».getID((«EObject.name») context.getNewObject()));
			«ReferenceRegistry.name».getInstance().addElement((«EObject.name») context.getNewObject());
			«n.packageNameAdd».AddFeature«n.fuName» af = new «n.packageNameAdd».AddFeature«n.fuName»(getFeatureProvider());
			«AddContext.name» ac = new «AddContext.name»(context, object);
			if (af.canAdd(ac))
				return af.add(ac);
		}
		return null;
	}
	
}
'''
	}
	
}