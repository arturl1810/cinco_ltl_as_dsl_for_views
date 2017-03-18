package de.jabc.cinco.meta.core.ge.style.generator.templates.resize

import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoAbstractResizeFeature
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoResizeFeature
import de.jabc.cinco.meta.core.utils.CincoUtils
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import mgl.Node
import org.eclipse.emf.transaction.RecordingCommand
import org.eclipse.emf.transaction.TransactionalEditingDomain
import org.eclipse.emf.transaction.util.TransactionUtil
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IResizeShapeContext
import style.Styles

class NodeResizeFeatures extends GeneratorUtils{
	
	/**
	 * Generates the 'Resize-Feature' for a node
	 * @param n : The node
	 * @param styles : The style
	 */
	def doGenerateNodeResizeFeature(Node n, Styles styles)'''
	package «n.packageNameResize»;
	
	public class ResizeFeature«n.fuName» extends «CincoAbstractResizeFeature.name» {
		
		«n.fqInternalBeanName» bo;
		
		/**
		 * Call of the Superclass
		 * @param fp: Fp is the parameter of the Superclass-Call
		*/
		public ResizeFeature«n.fuName»(«IFeatureProvider.name» fp) {
			super(fp);
		}
		
		/**
		 * Checks if a shape can be resized
		 * @param context : Contains the information, needed to let a feature resize a shape
		 * @param apiCall : ApiCall shows if the Cinco Api is used
		 * @return Returns true if the shape can be resized and false if not
		*/
		public boolean canResizeShape(«IResizeShapeContext.name» context, boolean apiCall) {
			if (apiCall) {
				«Object.name» bo = getBusinessObjectForPictogramElement(context.getPictogramElement());
				return (bo instanceof «n.fqInternalBeanName»);
			}
			return false;
		}
		
		/**
		 * Checks if a shape can be resized by using the method 'canResizeShape(context,apiCall)'
		 * @param context : Contains the information, needed to let a feature create a shape
		 * @return Returns if the shape can be resized and false if not
		*/
		@Override
		public boolean canResizeShape(«IResizeShapeContext.name» context) {
			return canResizeShape(context, «!CincoUtils.isResizeDisabled(n)»);
		}
		
		/**
		 * Resizes a shape
		 * @param context : Contains the information, needed to let a feature resize a shape
		*/
		@Override
		public void resizeShape(final «IResizeShapeContext.name» context) {
			«TransactionalEditingDomain.name» dom = «TransactionUtil.name».getEditingDomain(getDiagram());
			if (dom == null) 
				dom = «TransactionalEditingDomain.name».Factory.INSTANCE.createEditingDomain(getDiagram().eResource().getResourceSet());
			dom.getCommandStack().execute(new «RecordingCommand.name»(dom, "Resize") {
				@Override
				protected void doExecute() {
					bo = («n.fqInternalBeanName») getBusinessObjectForPictogramElement(context.getPictogramElement());
					bo.setWidth(context.getWidth());
					bo.setHeight(context.getHeight());
					«CincoResizeFeature.name».resize(context);
					layoutPictogramElement(context.getPictogramElement());
				}
			});
		}	
	}
	'''
}