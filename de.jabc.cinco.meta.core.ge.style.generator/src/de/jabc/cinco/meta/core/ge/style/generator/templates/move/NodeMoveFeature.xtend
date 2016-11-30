package de.jabc.cinco.meta.core.ge.style.generator.templates.move

import de.jabc.cinco.meta.core.ge.style.generator.templates.util.GeneratorUtils
import de.jabc.cinco.meta.core.ge.style.model.errorhandling.ECincoError
import de.jabc.cinco.meta.core.ge.style.model.features.CincoMoveShapeFeature
import graphmodel.Container
import graphmodel.Edge
import graphmodel.ModelElementContainer
import java.util.HashSet
import mgl.Node
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IMoveShapeContext
import de.jabc.cinco.meta.core.utils.CincoUtils
import style.Styles

class NodeMoveFeature extends GeneratorUtils{
	
	def doGenerateNodeMoveFeature(Node n, Styles styles)'''
	package «n.packageNameMove»;
	
	public class MoveFeature«n.fuName» extends «CincoMoveShapeFeature.name» {
		
		private «ECincoError.name» error = «ECincoError.name».OK;
		
		public MoveFeature«n.fuName»(«IFeatureProvider.name» fp) {
			super(fp);
		}
		
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
				if (target instanceof graphmodel.ModelElementContainer)
					return ((graphmodel.ModelElementContainer) target).canContain(«n.fqBeanName».class);
				if (getError().equals(«ECincoError.name».OK))
					setError(«ECincoError.name».INVALID_CONTAINER);
				return false;
				«ENDIF»
			}
			return false;
		}
		
		@Override
		public boolean canMoveShape(«IMoveShapeContext.name» context) {
			return canMoveShape(context, «!CincoUtils.isMoveDisabled(n)»);
		}
	
		@Override
		public void moveShape(«IMoveShapeContext.name» context) {
			«Object.name» o = getBusinessObjectForPictogramElement(context.getShape());
			«Object.name» source = getBusinessObjectForPictogramElement(context.getSourceContainer());
			«Object.name» target = getBusinessObjectForPictogramElement(context.getTargetContainer());
			if (source instanceof «Container.name») {
				«Container.name» nc = («Container.name») source;
				nc.getModelElements().remove((«n.fqBeanName») o);
			}
			if (source instanceof «n.graphModel.beanPackage».«n.graphModel.name») {
				«n.graphModel.beanPackage».«n.graphModel.name» tmp = («n.graphModel.beanPackage».«n.graphModel.name») source;
				tmp.getModelElements().remove((«n.fqBeanName») o);
			}
			if (target instanceof «n.graphModel.beanPackage».«n.graphModel.name») {
				«n.graphModel.beanPackage».«n.graphModel.name» tmp = («n.graphModel.beanPackage».«n.graphModel.name») target;
				tmp.getModelElements().add((«n.fqBeanName») o);
			}
			if (target instanceof «Container.name») {
				«Container.name» tmp = («Container.name») target;
				tmp.getModelElements().add((«n.fqBeanName») o);
			}
			
			«HashSet.name»<«Edge.name»> all = new «HashSet.name»<>();
			«n.fqBeanName» tmp = («n.fqBeanName») o;
			all.addAll(tmp.getIncoming());
			all.addAll(tmp.getOutgoing());
			for («Edge.name» e : all) {
			«ModelElementContainer.name» ce = e.getContainer();
			«ModelElementContainer.name» common = «n.graphModel.packageName».«n.graphModel.name»GraphitiUtils.getInstance().getCommonContainer(ce, e);
			ce.getModelElements().remove(e);
			common.getModelElements().add(e);
			}

			super.moveShape(context);
		}

		@Override
		protected void postMoveShape(«IMoveShapeContext.name» context) {
			try {
				«n.fqBeanName» _s = («n.fqBeanName») getBusinessObjectForPictogramElement(context.getPictogramElement());
				«n.graphModel.beanPackage».«n.graphModel.name» _root = _s.getRootElement();
				//«n.graphModel.package».api.c«n.graphModel.name.toLowerCase».C«n.graphModel.name» _wrapped = «n.graphModel.package».graphiti.«n.graphModel.name»Wrapper.wrapGraphModel(_root, getDiagram());
			
				int x = context.getX();
				int y = context.getY();
				int deltaX = context.getDeltaX();
				int deltaY = context.getDeltaY();
			
				«ModelElementContainer.name» source = («ModelElementContainer.name») getBusinessObjectForPictogramElement(context.getSourceContainer());
				«ModelElementContainer.name» target = («ModelElementContainer.name») getBusinessObjectForPictogramElement(context.getTargetContainer());
		
				//«n.graphModel.package».api.c«n.graphModel.name.toLowerCase».C«n.fuName» cModelElement= _wrapped.findC«n.fuName»(_s);
				//graphicalgraphmodel.CModelElementContainer cSource = _wrapped.findCModelElementContainer(source);
				//graphicalgraphmodel.CModelElementContainer cTarget= _wrapped.findCModelElementContainer(target);
			
			} catch (Exception e) {
			
			}
			super.postMoveShape(context);
		}

		public «ECincoError.name» getError() {
			return error;
		}

		public void setError(«ECincoError.name» error) {
			this.error = error;
		}
		
	}
	'''
	
	def isFixed(Node n, Styles styles)
	{
		var style = CincoUtils.getStyleForNode(n, styles);
		return style.fixed;
	}
}