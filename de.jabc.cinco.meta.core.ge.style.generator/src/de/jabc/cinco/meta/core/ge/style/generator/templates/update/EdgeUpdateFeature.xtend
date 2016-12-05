package de.jabc.cinco.meta.core.ge.style.generator.templates.update

import de.jabc.cinco.meta.core.ge.style.generator.templates.util.GeneratorUtils
import mgl.Edge
import org.eclipse.graphiti.features.impl.AbstractUpdateFeature
import com.sun.el.ExpressionFactoryImpl
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IUpdateContext
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.features.IReason
import org.eclipse.emf.transaction.TransactionalEditingDomain
import org.eclipse.graphiti.features.impl.Reason
import org.eclipse.graphiti.features.context.impl.LayoutContext
import org.eclipse.graphiti.features.ILayoutFeature
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.Shape
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.ConnectionDecorator
import org.eclipse.graphiti.mm.algorithms.AbstractText
import java.util.IllegalFormatException
import style.Styles

class EdgeUpdateFeature extends GeneratorUtils{
	
	def doGenerateEdgeUpdateFeature(Edge e, Styles styles)'''
	package «e.packageNameUpdate»;
	
	public class UpdateFeature«e.fuName» extends «AbstractUpdateFeature.name»{
		
		private static «ExpressionFactoryImpl.name» factory = new «ExpressionFactoryImpl.name»();
		private static «e.graphModel.packageName».expression.«e.graphModel.fuName»ExpressionLanguageContext elContext;
		
		public UpdateFeature«e.fuName»(«IFeatureProvider.name» fp) {
			super(fp);
		}
	
		@Override
		public boolean canUpdate(«IUpdateContext.name» context) {
			«PictogramElement.name» pe = context.getPictogramElement();
			«EObject.name» bo = «Graphiti.name».getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
			return (bo instanceof «e.fqBeanName»);
		}
	
		@Override
		public «IReason.name» updateNeeded(«IUpdateContext.name» context) {
			«PictogramElement.name» pe = context.getPictogramElement();
			«e.fqBeanName» bo =( «e.fqBeanName») «Graphiti.name».getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
			if (checkUpdateNeeded(bo, pe)) {
				/*
				«TransactionalEditingDomain.name» dom = getDiagramBehavior().getEditingDomain();
				dom.getCommandStack().execute(new RecordingCommand(dom) {
					@Override
					protected void doExecute() {
						update(context);
					}
				});*/
				return «Reason.name».createTrueReason();
			}
			return «Reason.name».createFalseReason();
		}
	
		@Override
		public boolean update(«IUpdateContext.name» context) {
			«PictogramElement.name» pe = context.getPictogramElement();
			«e.fqBeanName» bo = ( «e.fqBeanName») «Graphiti.name».getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
			updateText(bo, pe);
			«LayoutContext.name» lContext = new «LayoutContext.name»(context.getPictogramElement());
			«ILayoutFeature.name» lf = getFeatureProvider().getLayoutFeature(lContext);
			if (lf.canLayout(lContext)) {
				return lf.layout(lContext);
			}		
			return false;
		}
		
		private void updateText( «e.fqBeanName» transition, «PictogramElement.name» pe) {
			if (pe instanceof «ContainerShape.name») {
				«PictogramElement.name» tmp = pe;
				Object o = «Graphiti.name».getLinkService().getBusinessObjectForLinkedPictogramElement(tmp);
				if (transition.equals(o) || o == null)
				for («Shape.name» _s : ((«ContainerShape.name») pe).getChildren()) {
					updateText(transition, _s);
				}
			} 
			if (pe instanceof «Connection.name») {
				«Connection.name» connection = («Connection.name») pe;
				for («ConnectionDecorator.name» cd : connection.getConnectionDecorators()) {
					updateText(transition, cd); 
				} 
			} else {
				if (pe.getGraphicsAlgorithm() instanceof «AbstractText.name») {
					«ClassLoader.name» contextClassLoader = «Thread.name».currentThread().getContextClassLoader();
					«AbstractText.name» t = («AbstractText.name») pe.getGraphicsAlgorithm();
					try {
						«Thread.name».currentThread().setContextClassLoader(UpdateFeature«e.fuName».class.getClassLoader());
						«String.name» formatString = «Graphiti.name».getPeService().getPropertyValue(t, «e.graphModel.packageName».«e.graphModel.name»GraphitiUtils.KEY_FORMAT_STRING);
						t.setValue(«String.name».format(formatString , "test"));
					} 
					catch («IllegalFormatException.name» ife) {
						t.setValue("STRING FORMAT ERROR");
					} 
					finally {
						«Thread.name».currentThread().setContextClassLoader(contextClassLoader);
					}
				}
			}
		}
	
		public static boolean checkUpdateNeeded( «e.fqBeanName» transition, «PictogramElement.name» pe) {
			boolean updateNeeded;
			if (pe instanceof «ContainerShape.name») {
				for («Shape.name» _s : ((«ContainerShape.name») pe).getChildren()) {
					return checkUpdateNeeded(transition, _s);
				}
			} 
			if (pe instanceof «Connection.name») {
				«Connection.name» connection = («Connection.name») pe;
				for («ConnectionDecorator.name» cd : connection.getConnectionDecorators()) {
					updateNeeded = checkUpdateNeeded(transition, cd);
					if (updateNeeded)
						return true;
				}
			} else {
				«Object.name» o = «Graphiti.name».getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
				if (pe.getGraphicsAlgorithm() instanceof «AbstractText.name» && transition.equals(o)) {
					«ClassLoader.name» contextClassLoader = «Thread.name».currentThread().getContextClassLoader();
					try {
						«Thread.name».currentThread().setContextClassLoader( «e.packageNameUpdate».UpdateFeature«e.fuName».class.getClassLoader());
						«AbstractText.name» t = («AbstractText.name») pe.getGraphicsAlgorithm();
						«String.name» formatString = «Graphiti.name».getPeService().getPropertyValue(t, «e.graphModel.packageName».«e.graphModel.name»GraphitiUtils.KEY_FORMAT_STRING);
						«String.name» oldVal = «String.name».format(formatString);
						«String.name» newVal = t.getValue();
						return (!newVal.equals(oldVal));
					} 
					finally {
						«Thread.name».currentThread().setContextClassLoader(contextClassLoader);
					}
				}
			}
			return false;
		}
	}
	'''
}