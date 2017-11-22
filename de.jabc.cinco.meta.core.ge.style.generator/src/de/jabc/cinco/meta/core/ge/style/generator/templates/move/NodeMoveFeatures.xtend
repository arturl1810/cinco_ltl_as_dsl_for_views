package de.jabc.cinco.meta.core.ge.style.generator.templates.move

import de.jabc.cinco.meta.core.ge.style.generator.runtime.errorhandling.ECincoError
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoMoveShapeFeature
import de.jabc.cinco.meta.core.utils.CincoUtil
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import graphmodel.internal.InternalContainer
import graphmodel.internal.InternalEdge
import graphmodel.internal.InternalModelElementContainer
import java.util.HashSet
import mgl.Node
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IMoveShapeContext
import style.Styles
import de.jabc.cinco.meta.runtime.xapi.GraphModelExtension
import graphmodel.internal.InternalNode
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import mgl.ModelElement

class NodeMoveFeatures extends GeneratorUtils{
	
	extension APIUtils = new APIUtils
	
	/**
	 * Generates the 'Move-Feature' for a given node
	 * @param n : The node
	 * @param style : The style
	 */
	def doGenerateNodeMoveFeature(Node n, Styles styles)'''
	package «n.packageNameMove»;
	
	public class MoveFeature«n.fuName» extends «CincoMoveShapeFeature.name» {
		
		private «ECincoError.name» error = «ECincoError.name».OK;
		
		/**
		 * Call of the Superclass
		 * @param fp: Fp is the parameter of the Superclass-Call
		*/
		public MoveFeature«n.fuName»(«IFeatureProvider.name» fp) {
			super(fp);
		}
		
		/**
		 * Checks if a shape is moveable
		 * @param context : Contains the information, needed to let a feature move a shape
		 * @param apiCall : Apicall shows if the Cinco Api is used
		 * @return Returns true if a shape can be moved and false if not
		*/
		public boolean canMoveShape(«IMoveShapeContext.name» context, boolean apiCall) {
			if (apiCall) {
				«Object.name» o = getBusinessObjectForPictogramElement(context.getShape());
				«Object.name» source = getBusinessObjectForPictogramElement(context.getSourceContainer());
				«Object.name» target = getBusinessObjectForPictogramElement(context.getTargetContainer());
				«IF n.isFixed(styles)»
				return false;
				«ELSE»
				if (source != null && source.equals(target))
					return true;
				if (target instanceof «InternalModelElementContainer.name»)
					return ((«InternalModelElementContainer.name») target).canContain(«n.fqBeanName».class);
				if (getError().equals(«ECincoError.name».OK))
					setError(«ECincoError.name».INVALID_CONTAINER);
				return false;
				«ENDIF»
			}
			return false;
		}
		
		/**
		 * Checks if a shape is moveable by using the method 'canMoveShape(context,apiCall)'
		 * @param context : Contains the information, needed to let a feature move a shape
		 * @return Returns true if a shape can be moved and false if not
		*/
		@Override
		public boolean canMoveShape(«IMoveShapeContext.name» context) {
			return canMoveShape(context, «!CincoUtil.isMoveDisabled(n)»);
		}
	
		/**
		 * Moves a Shape by removing the shape at the source and adding it at the target
		 * @param context : Contains the information, needed to let a feature move a shape
		*/
		@Override
		public void moveShape(«IMoveShapeContext.name» context) {
			«n.fqInternalBeanName» o = («n.fqInternalBeanName») getBusinessObjectForPictogramElement(context.getShape());
			«InternalModelElementContainer.name» target = («InternalModelElementContainer.name») getBusinessObjectForPictogramElement(context.getTargetContainer());
			
			super.moveShape(context);
			
			if (o.getElement() instanceof «n.fqCName») {
				«n.possibleContainers.map[pc | 
					'''
					if («internalInstanceofCheck(pc as ModelElement, "target")»)
						((«n.fqBeanName») o.getElement()).
						moveTo((«pc.fqBeanName») target.getContainerElement(), context.getX(), context.getY());'''
				].join("\n")»
			}
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
		
	}
	'''
	/**
	 * Auxiliary method to check if a style of a node is fixed
	 * @param n : The node
	 * @param style : The style
	 * @return Returns true if the style of a node is fixed and false if not
	 */
	def isFixed(Node n, Styles styles)
	{
		var style = CincoUtil.getStyleForNode(n, styles);
		return style.fixed;
	}
}