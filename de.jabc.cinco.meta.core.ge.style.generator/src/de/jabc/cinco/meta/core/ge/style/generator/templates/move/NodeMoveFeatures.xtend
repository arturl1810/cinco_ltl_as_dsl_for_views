package de.jabc.cinco.meta.core.ge.style.generator.templates.move

import de.jabc.cinco.meta.core.ge.style.generator.runtime.errorhandling.ECincoError
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoMoveShapeFeature
import de.jabc.cinco.meta.core.utils.CincoUtils
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import graphmodel.Container
import graphmodel.Edge
import graphmodel.ModelElementContainer
import java.util.HashSet
import mgl.Node
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IMoveShapeContext
import style.Styles
import graphmodel.internal.InternalModelElementContainer
import graphmodel.internal.InternalContainer
import graphmodel.internal.InternalEdge

class NodeMoveFeatures extends GeneratorUtils{
	
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
			return canMoveShape(context, «!CincoUtils.isMoveDisabled(n)»);
		}
	
		/**
		 * Moves a Shape by removing the shape at the source and adding it at the target
		 * @param context : Contains the information, needed to let a feature move a shape
		*/
		@Override
		public void moveShape(«IMoveShapeContext.name» context) {
			«Object.name» o = getBusinessObjectForPictogramElement(context.getShape());
			«Object.name» source = getBusinessObjectForPictogramElement(context.getSourceContainer());
			«Object.name» target = getBusinessObjectForPictogramElement(context.getTargetContainer());
			if (source instanceof «InternalContainer.name») {
				«InternalContainer.name» nc = («InternalContainer.name») source;
				nc.getModelElements().remove((«n.fqInternalBeanName») o);
			}
			if (source instanceof «n.graphModel.fqInternalBeanName») {
				«n.graphModel.fqInternalBeanName» tmp = («n.graphModel.fqInternalBeanName») source;
				tmp.getModelElements().remove((«n.fqInternalBeanName») o);
			}
			if (target instanceof «n.graphModel.fqInternalBeanName») {
				«n.graphModel.fqInternalBeanName» tmp = («n.graphModel.fqInternalBeanName») target;
				tmp.getModelElements().add((«n.fqInternalBeanName») o);
			}
			if (target instanceof «InternalContainer.name») {
				«InternalContainer.name» tmp = («InternalContainer.name») target;
				tmp.getModelElements().add((«n.fqInternalBeanName») o);
			}
			
			«HashSet.name»<«InternalEdge.name»> all = new «HashSet.name»<>();
			«n.fqInternalBeanName» tmp = («n.fqInternalBeanName») o;
			all.addAll(tmp.getIncoming());
			all.addAll(tmp.getOutgoing());
			for («InternalEdge.name» e : all) {
				«InternalModelElementContainer.name» ce = e.getContainer();
				«InternalModelElementContainer.name» common = 
					«n.graphModel.packageName».«n.graphModel.name»GraphitiUtils.getInstance().getCommonContainer(ce.getContainerElement(), («Edge.name») e.getElement()).getInternalContainerElement();;
				ce.getModelElements().remove(e);
				common.getModelElements().add(e);
			}

			super.moveShape(context);
		}
		
		/**
		 * Tries to get the root of the pictogram element, the coordinates of the context and the source and target
		 * @param context : Contains the information, needed to let a feature move a shape
		*/
		@Override
		protected void postMoveShape(«IMoveShapeContext.name» context) {
			try {
				«n.fqInternalBeanName» _s = («n.fqInternalBeanName») getBusinessObjectForPictogramElement(context.getPictogramElement());
				//«n.graphModel.beanPackage».«n.graphModel.name» _root = _s.getRootElement();
				//«n.graphModel.package».api.c«n.graphModel.name.toLowerCase».C«n.graphModel.name» _wrapped = «n.graphModel.package».graphiti.«n.graphModel.name»Wrapper.wrapGraphModel(_root, getDiagram());
			
				int x = context.getX();
				int y = context.getY();
				int deltaX = context.getDeltaX();
				int deltaY = context.getDeltaY();
			
				«InternalModelElementContainer.name» source = («InternalModelElementContainer.name») getBusinessObjectForPictogramElement(context.getSourceContainer());
				«InternalModelElementContainer.name» target = («InternalModelElementContainer.name») getBusinessObjectForPictogramElement(context.getTargetContainer());
		
				//«n.graphModel.package».api.c«n.graphModel.name.toLowerCase».C«n.fuName» cModelElement= _wrapped.findC«n.fuName»(_s);
				//graphicalgraphmodel.CModelElementContainer cSource = _wrapped.findCModelElementContainer(source);
				//graphicalgraphmodel.CModelElementContainer cTarget= _wrapped.findCModelElementContainer(target);
			
			} catch (Exception e) {
			
			}
			super.postMoveShape(context);
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
		var style = CincoUtils.getStyleForNode(n, styles);
		return style.fixed;
	}
}