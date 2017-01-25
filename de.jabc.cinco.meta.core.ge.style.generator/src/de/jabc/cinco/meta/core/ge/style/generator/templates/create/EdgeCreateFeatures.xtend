package de.jabc.cinco.meta.core.ge.style.generator.templates.create

import de.jabc.cinco.meta.core.ge.style.generator.runtime.errorhandling.ECincoError
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import graphmodel.Node
import mgl.Edge
import mgl.ModelElement
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.ICreateConnectionContext
import org.eclipse.graphiti.features.context.impl.AddConnectionContext
import org.eclipse.graphiti.features.impl.AbstractCreateConnectionFeature
import org.eclipse.graphiti.mm.pictograms.Anchor
import org.eclipse.graphiti.mm.pictograms.Connection
import style.Styles

class EdgeCreateFeatures extends GeneratorUtils{

	/**
	 * Generates the 'Create-Feature' for a given edge 
	 * @param e : The edge
	 * @param styles : The style
	 */
	def doGenerateEdgeCreateFeature(Edge e, Styles styles) '''
	package «e.packageNameCreate»;
	
	public class CreateFeature«e.fuName» extends «AbstractCreateConnectionFeature.name» {
		
		private «ECincoError.name» error = «ECincoError.name».OK;
		
		/**
		 * Call of the Superclass
		 * @param fp : Fp is the parameter of the Superclass-Call
		*/
		public CreateFeature«e.fuName»(«IFeatureProvider.name» fp) {
			super(fp, "«e.fuName»", "Create a new edge: «e.fuName»");
		}
		
		/**
	     * Checks if a context can be created
		 * @param context : Contains the information, needed to let a feature create a connection
		 * @param apiCall : ApiCall shows if the Cinco Api is used
		 * @return Returns true if the context can be created and false if not
		*/
		public boolean canCreate(«ICreateConnectionContext.name» context, boolean apiCall) {
			if (apiCall) {
				«Object.name» source = getBusinessObject(context.getSourceAnchor());
				«Object.name» target = getBusinessObject(context.getTargetAnchor());
		
				boolean srcOK = false;
				boolean trgOK = false;
				if (source != null && target != null) {
					srcOK=((graphmodel.Node) source).canStart(«e.graphModel.beanPackage».«e.fuName».class);
					trgOK=((graphmodel.Node) target).canEnd(«e.graphModel.beanPackage».«e.fuName».class);
				}
				if (! (srcOK && trgOK) && getError().equals(«ECincoError.name».OK))
					setError(«ECincoError.name».MAX_IN);
				return (srcOK && trgOK);
			}
			return false;
		}
	
		/**
		 * Checks if a context can be created by using the method 'canCreate(context,apiCall)'
		 * @param context : Contains the information, needed to let a feature create a connection
		 * @return Returns true if the context can be created and false if not
		*/
		public boolean canCreate(«ICreateConnectionContext.name» context) {
			return canCreate(context, true);
		}
	
		/**
		 * Creates a connection between a source and a target and returns it
		 * @param context : Contains the information, needed to let a feature create a connection
		 * @return Returns the new connection between source and target
		*/
		@Override
		public «Connection.name» create(«ICreateConnectionContext.name» context) {
			«Connection.name» connection = null;
			«Object.name» source = getBusinessObject(context.getSourceAnchor());
			«Object.name» target = getBusinessObject(context.getTargetAnchor());

			if (source != null && target != null) {
				«e.graphModel.beanPackage».«e.fuName» «e.fuName.toLowerCase» = «e.graphModel.beanPackage».«e.graphModel.fuName.toLowerCase.toFirstUpper»Factory.eINSTANCE.create«e.fuName»();
					if (source instanceof «ModelElement.name») {
						«e.fuName.toLowerCase».setSourceElement( («Node.name») source);
					}
					if (target instanceof «ModelElement.name») {
						«e.fuName.toLowerCase».setTargetElement( («Node.name») target);
					}

				«AddConnectionContext.name» addContext = 
					new «AddConnectionContext.name»(context.getSourceAnchor(), context.getTargetAnchor());
				addContext.setNewObject(«e.fuName.toLowerCase»);
				connection = («Connection.name») getFeatureProvider().addIfPossible(addContext);
			}
			return connection;
		}	
	
		/**
		 * Checks if a connection can start at the source with the given edge
		 * @param context : Contains the information, needed to let a feature create a connection
		 * @return Returns true if the connection can start to create and false if not
		*/
		@Override
		public boolean canStartConnection(«ICreateConnectionContext.name» context) {
			«Object.name» source = getBusinessObject(context.getSourceAnchor());
			if (source instanceof graphmodel.Node) {	
				if (! ((graphmodel.Node) source).canStart(«e.graphModel.beanPackage».«e.fuName».class)) {
					if (getError().equals(«ECincoError.name».OK))
						setError(«ECincoError.name».MAX_OUT);
				}
				else return true;
			}
			return false;
		}
	
		/**
		 * Returns the business object of the pictogram element 'anchor'
		 * @param anchor : Anchor is a representation of the model object 'Anchor'.
		 * @return Returns the business object of the pictogram element 'anchor'  or null if 'anchor' is null
		*/
		private «Object.name» getBusinessObject(«Anchor.name» anchor) {
			if (anchor != null) {
				«Object.name» bo = getBusinessObjectForPictogramElement(anchor.getParent());
				return bo;
			}
			return null;
		}

«««		private boolean checkSource(«Object.name» source) {
«««			if (source instanceof «e.graphModel.beanPackage».Start) {
«««				if (((«e.graphModel.beanPackage».Start) source).getOutgoing(«e.graphModel.beanPackage».«e.fuName».class).size() < 1)
«««					return true;
«««				else setError(«ECincoError.name».MAX_OUT);
«««			} 
«««			if (getError().equals(«ECincoError.name».OK))
«««				setError(«ECincoError.name».INVALID_SOURCE);
«««
«««			return false;
«««		}
«««
«««		private boolean checkTarget(«Object.name» target){
«««			if (target instanceof «e.graphModel.beanPackage».End) {
«««				if (true) return true;
«««				else setError(«ECincoError.name».MAX_IN);
«««			}
«««			if (target instanceof «e.graphModel.beanPackage».Activity) {
«««				if (true)
«««					return true;
«««				else setError(«ECincoError.name».MAX_IN);
«««			}
«««			if (getError().equals(«ECincoError.name».OK))
«««				setError(«ECincoError.name».INVALID_TARGET);
«««
«««			return false;
«««		}
		
		/**
		 * Get-method for an error
		 * @return Returns an 'error' in which 'error' is  'ECincoError.OK'
    	*/
		public «ECincoError.name» getError() {
			return error;
		}
		
		/**
		 * Set-method for an error
		 * @param error : Error is a value of the enum: MAX_CARDINALITY, MAX_IN, MAX_OUT, INVALID_SOURCE, INVALID_TARGET, INVALID_CONTAINER, INVALID_CLONE_TARGET, OK
		*/
		public void setError(«ECincoError.name» error) {
			this.error = error;
		}
	}
	'''
}