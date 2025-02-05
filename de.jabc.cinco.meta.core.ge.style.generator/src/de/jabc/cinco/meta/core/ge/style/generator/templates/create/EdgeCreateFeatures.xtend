package de.jabc.cinco.meta.core.ge.style.generator.templates.create

import de.jabc.cinco.meta.core.ge.style.generator.runtime.createfeature.CincoCreateEdgeFeature
import de.jabc.cinco.meta.core.ge.style.generator.runtime.errorhandling.ECincoError
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import de.jabc.cinco.meta.runtime.xapi.GraphModelExtension
import de.jabc.cinco.meta.runtime.xapi.ResourceExtension
import graphmodel.ModelElement
import graphmodel.Node
import graphmodel.internal.InternalGraphModel
import graphmodel.internal.InternalModelElement
import graphmodel.internal.InternalModelElementContainer
import graphmodel.internal.InternalNode
import mgl.Edge
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.ICreateConnectionContext
import org.eclipse.graphiti.features.context.impl.AddConnectionContext
import org.eclipse.graphiti.mm.pictograms.Anchor
import org.eclipse.graphiti.mm.pictograms.Connection
import style.Styles
import de.jabc.cinco.meta.core.ge.style.generator.runtime.highlight.Highlighter
import de.jabc.cinco.meta.core.utils.CincoUtil

class EdgeCreateFeatures extends APIUtils{

	/**
	 * Generates the 'Create-Feature' for a given edge 
	 * @param e : The edge
	 * @param styles : The style
	 */
	def doGenerateEdgeCreateFeature(Edge e, Styles styles) '''
	package «e.packageNameCreate»;
	
	public class CreateFeature«e.fuName» extends «CincoCreateEdgeFeature.name»<«ModelElement.name»> {
		
«««		private «ECincoError.name» error = «ECincoError.name».OK;
		private «ICreateConnectionContext.name» context;
		
		private boolean doneChanges = false;
		
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
				«InternalNode.name» source = («InternalNode.name») getBusinessObject(context.getSourceAnchor());
				«InternalNode.name» target = («InternalNode.name») getBusinessObject(context.getTargetAnchor());
				
				
				boolean srcOK = false;
				boolean trgOK = false;
				if (source != null && target != null) {
					srcOK = source.canStart(«e.fqBeanName».class);
					trgOK = target.canEnd(«e.fqBeanName».class);
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
			«InternalNode.name» source = («InternalNode.name») getBusinessObject(context.getSourceAnchor());
			«InternalNode.name» target = («InternalNode.name») getBusinessObject(context.getTargetAnchor());
			
			if (source != null && target != null) {
				
				«e.fqBeanName» «e.flName» = 
					(«e.fqCName») 
					«e.packageName».«e.graphModel.fuName»Factory.eINSTANCE.create«e.fuName»(source, target);
				
				connection = ((«e.fqCName») «e.flName»).getPictogramElement();
			}
			doneChanges = true;
			return connection;
		}	
	
		/**
		 * Checks if a connection can start at the source with the given edge
		 * @param context : Contains the information, needed to let a feature create a connection
		 * @return Returns true if the connection can start to create and false if not
		*/
		@Override
		public boolean canStartConnection(«ICreateConnectionContext.name» context) {
			this.context = context;
			«Object.name» source = getBusinessObject(context.getSourceAnchor());
			if (source instanceof «InternalNode.name») {	
				if (! ((«InternalNode.name») source).canStart(«e.fqBeanName».class)) {
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
		
		@Override
		public boolean hasDoneChanges() {
			return doneChanges;
		}
		
		«IF ! CincoUtil.isHighlightReconnectionDisabled(e.graphModel)»
			private «String.name» highlightContextKey;
			
			@Override
			public void startConnecting() {
				super.startConnecting();
				highlightContextKey = «Highlighter.name».INSTANCE.get().onConnectionStart(this, context);
			}
		
			@Override
			public void canceledAttaching(«ICreateConnectionContext.name» context) {
				super.canceledAttaching(context);
				if (highlightContextKey != null) {
					«Highlighter.name».INSTANCE.get().onConnectionCancel(highlightContextKey);
					highlightContextKey = null;
				}
				doneChanges = false;
			}
		
			@Override
			public void endConnecting() {
				super.endConnecting();
				if (highlightContextKey != null) {
					«Highlighter.name».INSTANCE.get().onConnectionEnd(highlightContextKey);
					highlightContextKey = null;
				}
			}
		«ELSE»
			@Override
			public void canceledAttaching(«ICreateConnectionContext.name» context) {
				super.canceledAttaching(context);
				doneChanges = false;
			}
		«ENDIF»
	}
	'''
}