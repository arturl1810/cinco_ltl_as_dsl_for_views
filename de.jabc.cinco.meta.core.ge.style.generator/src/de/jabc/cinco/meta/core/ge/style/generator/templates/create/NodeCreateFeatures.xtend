package de.jabc.cinco.meta.core.ge.style.generator.templates.create

import de.jabc.cinco.meta.core.ge.style.generator.templates.util.GeneratorUtils
import de.jabc.cinco.meta.core.ge.style.model.errorhandling.ECincoError
import de.jabc.cinco.meta.core.utils.CincoUtils
import graphmodel.ModelElement
import graphmodel.ModelElementContainer
import mgl.Node
import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.ICreateContext
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.services.Graphiti
import style.Styles

class NodeCreateFeatures extends GeneratorUtils{
	
	def doGenerateCreateFeature(Node n) '''
	package «n.packageNameCreate»;
	
	public class CreateFeature«n.fuName» extends de.jabc.cinco.meta.core.ge.style.model.createfeature.CincoCreateFeature<«ModelElement.name»>{
		
		private «ECincoError.name» error = «ECincoError.name».OK;
		
		public CreateFeature«n.fuName»(«IFeatureProvider.name» fp) {
			super(fp, "«n.fuName»", "Create «n.fuName»");
		}

		«IF !n.iconNodeValue.nullOrEmpty»	
		@Override
		public String getCreateImageId() {
			return "«getIconNodeValue(n)»";
		}
		«ENDIF»
	
		public boolean canCreate(«ICreateContext.name» context, boolean apiCall) {
		if (apiCall) {
			«Object.name» target = «Graphiti.name».getLinkService().getBusinessObjectForLinkedPictogramElement(context.getTargetContainer());
			if (target instanceof «ModelElementContainer.name»)
				if (! ((«ModelElementContainer.name») target).canContain(«n.fqBeanName».class)) {
					if (getError().equals(«ECincoError.name».OK))
						setError(«ECincoError.name».MAX_CARDINALITY);
				} else return true;
			return false;
		}
		return false;
		}
		
		public «Object.name»[] create(«ICreateContext.name» context) {
		«n.fqBeanName» «n.flName» = «n.fqFactoryName».eINSTANCE.create«n.fuName»();
		setModelElement(«n.flName»);
		«PictogramElement.name» target = context.getTargetContainer();
		«EObject.name» targetBO = («EObject.name») getBusinessObjectForPictogramElement(target);
«««		«n.graphModel.fqBeanName» «n.graphModel.name.toLowerCase» = «CincoGraphitiUtils.name».addToResource(getDiagram(), this.getFeatureProvider());		

		if (targetBO instanceof «ModelElementContainer.name») {
			((«ModelElementContainer.name») targetBO).getModelElements().add(«n.flName»);		
		}

		«PictogramElement.name» pe = null;
		«IF !n.isPrime»
		pe = addGraphicalRepresentation(context, «n.flName»);
		«ENDIF»
		return new «Object.name»[] {«n.flName», pe};
	}
		
		@Override
		public boolean canCreate(«ICreateContext.name» context) {
			return canCreate(context, «!CincoUtils.isCreateDisabled(n)»);
		}
		
		public «ECincoError.name» getError() {
			return error;
		}

		public void setError(«ECincoError.name» error) {
			this.error = error;
		}
	}
	'''
}