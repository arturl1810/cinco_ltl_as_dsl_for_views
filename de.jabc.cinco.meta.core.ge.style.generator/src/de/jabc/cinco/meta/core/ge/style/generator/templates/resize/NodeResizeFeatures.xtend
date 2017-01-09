package de.jabc.cinco.meta.core.ge.style.generator.templates.resize

import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoAbstractResizeFeature
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoResizeFeature
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.GeneratorUtils
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils;
import de.jabc.cinco.meta.core.ge.style.model.features.CincoAbstractResizeFeature
import de.jabc.cinco.meta.core.ge.style.model.features.CincoResizeFeature
import de.jabc.cinco.meta.core.utils.CincoUtils
import mgl.Node
import org.eclipse.emf.transaction.RecordingCommand
import org.eclipse.emf.transaction.TransactionalEditingDomain
import org.eclipse.emf.transaction.util.TransactionUtil
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IResizeShapeContext
import style.Styles

class NodeResizeFeatures extends GeneratorUtils{
	
	def doGenerateNodeResizeFeature(Node n, Styles styles)'''
	package «n.packageNameResize»;
	
	public class ResizeFeature«n.fuName» extends «CincoAbstractResizeFeature.name» {
		
		«n.fqBeanName» bo;
		
		public ResizeFeature«n.fuName»(«IFeatureProvider.name» fp) {
			super(fp);
		}
		
		public boolean canResizeShape(«IResizeShapeContext.name» context, boolean apiCall) {
			if (apiCall) {
				«Object.name» bo = getBusinessObjectForPictogramElement(context.getPictogramElement());
				return (bo instanceof «n.fqBeanName»);
			}
			return false;
		}
		
		@Override
		public boolean canResizeShape(«IResizeShapeContext.name» context) {
			return canResizeShape(context, «!CincoUtils.isResizeDisabled(n)»);
		}
		
		@Override
		public void resizeShape(final «IResizeShapeContext.name» context) {
			«TransactionalEditingDomain.name» dom = «TransactionUtil.name».getEditingDomain(getDiagram());
			if (dom == null) 
				dom = «TransactionalEditingDomain.name».Factory.INSTANCE.createEditingDomain(getDiagram().eResource().getResourceSet());
			dom.getCommandStack().execute(new «RecordingCommand.name»(dom, "Resize") {
				@Override
				protected void doExecute() {
					bo = («n.fqBeanName») getBusinessObjectForPictogramElement(context.getPictogramElement());

					«CincoResizeFeature.name».resize(context);
					layoutPictogramElement(context.getPictogramElement());
				}
			});
		}	
	}
	'''
}