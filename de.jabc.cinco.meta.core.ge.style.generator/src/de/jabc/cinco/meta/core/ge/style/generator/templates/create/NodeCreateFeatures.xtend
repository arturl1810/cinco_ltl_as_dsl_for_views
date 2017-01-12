package de.jabc.cinco.meta.core.ge.style.generator.templates.create

import de.jabc.cinco.meta.core.ge.style.generator.runtime.errorhandling.ECincoError
import de.jabc.cinco.meta.core.utils.CincoUtils
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
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
	

	/** 
	 * Generates the 'Create-Feature' for a given node
	 * @param n : The node
	 * @param styles : The style
	*/	
	def doGenerateNodeCreateFeature(Node n, Styles styles) '''
	package «n.packageNameCreate»;
	
	public class CreateFeature«n.fuName» extends  de.jabc.cinco.meta.core.ge.style.generator.runtime.createfeature.CincoCreateFeature<graphmodel.ModelElement>{
		
		private «ECincoError.name» error = «ECincoError.name».OK;
		
		/**
		 * Call of the Superclass
		 * @param fp: Fp is the parameter of the Superclass-Call
		*/
		public CreateFeature«n.fuName»(«IFeatureProvider.name» fp) {
			super(fp, "«n.fuName»", "Create «n.fuName»");
		}

		«IF !n.iconNodeValue.nullOrEmpty»	
		/**
		 * @return Returns the image id
		*/
		@Override
		public String getCreateImageId() {
			return "«getIconNodeValue(n)»";
		}
		«ENDIF»
	
		/**
		 * Checks if a context can be created
		 * @param context Contains the information, needed to let a feature create a pictogram element
		 * @param apiCall: ApiCall shows if the Cinco Api is used
		 * @return Returns true if the context can be created and false if not
		*/
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
		
		/**
		 * Creates a pictogram element with the given 'context'
		 * @param context: Contains the information, needed to let a feature create a pictogram element
		 * @return Returns a list with the created pictogram elements and its graphical representation
	    */
		public «Object.name»[] create(«ICreateContext.name» context) {
		«n.fqBeanName» «n.flName» = «n.fqFactoryName».eINSTANCE.create«n.fuName»();
		setModelElement(«n.flName»);
		«PictogramElement.name» target = context.getTargetContainer();
		«EObject.name» targetBO = («EObject.name») getBusinessObjectForPictogramElement(target);

		if (targetBO instanceof «ModelElementContainer.name») {
			((«ModelElementContainer.name») targetBO).getModelElements().add(«n.flName»);		
		}

		«PictogramElement.name» pe = null;
		«IF !n.isPrime»
		pe = addGraphicalRepresentation(context, «n.flName»);
		«ENDIF»
		return new «Object.name»[] {«n.flName», pe};
	}
		
		/**
		 * Checks if a context can be created by using the method 'canCreate(context,apiCall)'
		 * @param context: Contains the information, needed to let a feature create a pictogram element
		 * @return Returns true if the context can be created and false if not
	    */
		@Override
		public boolean canCreate(«ICreateContext.name» context) {
			return canCreate(context, «!CincoUtils.isCreateDisabled(n)»);
		}
		
		/**
		 * Get-method for an error
		 * @return Returns an 'error' in which 'error' is  'ECincoError.OK'
		*/
		public «ECincoError.name» getError() {
			return error;
		}

	    /**
		 * Set-method for an error
		 * @param error: Error is a value of the enum: MAX_CARDINALITY, MAX_IN, MAX_OUT, INVALID_SOURCE, INVALID_TARGET, INVALID_CONTAINER, INVALID_CLONE_TARGET, OK
		*/
		public void setError(«ECincoError.name» error) {
			this.error = error;
		}
	}
	'''
}