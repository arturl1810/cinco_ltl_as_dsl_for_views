package de.jabc.cinco.meta.core.ge.style.generator.templates.update

import com.sun.el.ExpressionFactoryImpl
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils;
import java.util.IllegalFormatException
import mgl.Node
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.transaction.TransactionalEditingDomain
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.ILayoutFeature
import org.eclipse.graphiti.features.IReason
import org.eclipse.graphiti.features.context.IUpdateContext
import org.eclipse.graphiti.features.context.impl.LayoutContext
import org.eclipse.graphiti.features.impl.AbstractUpdateFeature
import org.eclipse.graphiti.features.impl.Reason
import org.eclipse.graphiti.mm.algorithms.AbstractText
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.ConnectionDecorator
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.mm.pictograms.Shape
import org.eclipse.graphiti.services.Graphiti
import style.Styles

class NodeUpdateFeatures extends GeneratorUtils{
	
	var static number = 0
	
	/**
	 * Generates the Class 'UpdateFeature' for the Node n
	 * @param n : The node
	 * @param styles : Styles
	 */
	def doGenerateNodeUpdateFeature(Node n, Styles styles)'''
	package «n.packageNameUpdate»;
	
	public class UpdateFeature«n.fuName» extends «AbstractUpdateFeature.name» {
		
		private static «ExpressionFactoryImpl.name» factory = new «ExpressionFactoryImpl.name»();
		private static «n.graphModel.packageName».expression.«n.graphModel.fuName»ExpressionLanguageContext elContext;
		
		public UpdateFeature«n.fuName»(«IFeatureProvider.name» fp) {
			super(fp);
		}
	
		@Override
		public boolean canUpdate(«IUpdateContext.name» context) {
			«PictogramElement.name» pe = context.getPictogramElement();
			«EObject.name» bo = «Graphiti.name».getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
			return (bo instanceof «n.fqBeanName»);
		}
	
		@Override
		public «IReason.name» updateNeeded(«IUpdateContext.name» context) {
			«PictogramElement.name» pe = context.getPictogramElement();
			«n.fqBeanName» bo =( «n.fqBeanName») «Graphiti.name».getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
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
			 «n.fqBeanName» bo = ( «n.fqBeanName») «Graphiti.name».getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
			updateText(bo, pe);
			«LayoutContext.name» lContext = new «LayoutContext.name»(context.getPictogramElement());
			«ILayoutFeature.name» lf = getFeatureProvider().getLayoutFeature(lContext);
			if (lf.canLayout(lContext)) {
				return lf.layout(lContext);
			}		
			return false;
		}
		
		/**
		 *Updates the text of the node
		 * @param «n.name.toLowerCase» : The node
		 * @ param pe : PictrogramElement
		 */
		private void updateText( «n.fqBeanName» «n.name.toLowerCase», «PictogramElement.name» pe) {
			if (pe instanceof «ContainerShape.name») {
				«PictogramElement.name» tmp = pe;
				Object o = «Graphiti.name».getLinkService().getBusinessObjectForLinkedPictogramElement(tmp);
				if («n.name.toLowerCase».equals(o) || o == null)
				for («Shape.name» _s : ((«ContainerShape.name») pe).getChildren()) {
					updateText(«n.name.toLowerCase», _s);
				}
			} 
			if (pe instanceof «Connection.name») {
				«Connection.name» connection = («Connection.name») pe;
				for («ConnectionDecorator.name» cd : connection.getConnectionDecorators()) {
					updateText(«n.name.toLowerCase», cd); 
				} 
			} else {
				if (pe.getGraphicsAlgorithm() instanceof «AbstractText.name») {
					«ClassLoader.name» contextClassLoader = «Thread.name».currentThread().getContextClassLoader();
					«AbstractText.name» t = («AbstractText.name») pe.getGraphicsAlgorithm();
					try {
						«Thread.name».currentThread().setContextClassLoader(UpdateFeature«n.fuName».class.getClassLoader());
						«setValue(n)»
						
						«String.name» formatString = «Graphiti.name».getPeService().getPropertyValue(t, «n.graphModel.packageName».«n.graphModel.name»GraphitiUtils.KEY_FORMAT_STRING);
						t.setValue(String.format(formatString «fill(n)»));
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
	
		/**
		 * Checks if the text needs to be updated
		 * @param «n.name.toLowerCase» :
		 * @param pe : PictrogramElement
		 * @return Returns true if an update is needed
		 */
		public static boolean checkUpdateNeeded( «n.fqBeanName» «n.name.toLowerCase», «PictogramElement.name» pe) {
			boolean updateNeeded;
			if (pe instanceof «ContainerShape.name») {
				for («Shape.name» _s : ((«ContainerShape.name») pe).getChildren()) {
					return checkUpdateNeeded(«n.name.toLowerCase», _s);
				}
			} 
			if (pe instanceof «Connection.name») {
				«Connection.name» connection = («Connection.name») pe;
				for («ConnectionDecorator.name» cd : connection.getConnectionDecorators()) {
					updateNeeded = checkUpdateNeeded(«n.name.toLowerCase», cd);
					if (updateNeeded)
						return true;
				}
			} else {
				«Object.name» o = «Graphiti.name».getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
				if (pe.getGraphicsAlgorithm() instanceof «AbstractText.name» && «n.name.toLowerCase».equals(o)) {
					«ClassLoader.name» contextClassLoader = «Thread.name».currentThread().getContextClassLoader();
					try {
						«Thread.name».currentThread().setContextClassLoader( «n.packageNameUpdate».UpdateFeature«n.fuName».class.getClassLoader());
						«AbstractText.name» t = («AbstractText.name») pe.getGraphicsAlgorithm();
						«setValue(n)»
						
						«String.name» formatString = «Graphiti.name».getPeService().getPropertyValue(t, «n.graphModel.packageName».«n.graphModel.name»GraphitiUtils.KEY_FORMAT_STRING);
						String oldVal = String.format(formatString«fill(n)»);
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
	
	/**
	 * Generates code to set the value of the node n
	 * @param n : The node
	 */
	def setValue(Node n){
		var listAnnot = n.annotations;
		var annot = listAnnot.get(0);
		var listValue = annot.value;
		number = 0
		
		return '''
		«FOR value : listValue»
		«IF number != 1»
		elContext = new «n.packageName».expression.«n.graphModel.name»ExpressionLanguageContext(«n.name.toLowerCase»);
		Object tmp«number = number+1»Value = factory.createValueExpression(elContext, "«value»", Object.class).getValue(elContext); 
		«ENDIF»
		«ENDFOR»''' 
	}
	
	/**
	 * Generates the valuename
	 * @param n : Node
	 */
	def fill(Node n){
		var listAnnot = n.annotations;
		var annot = listAnnot.get(0);
		var listValue = annot.value;
		number = 0
		return 
		//'''«FOR value : listValue»«IF value.startsWith("${")»,tmp«number = number+1»Value«ENDIF»«ENDFOR»'''
		'''«FOR value : listValue», «IF number != 1»tmp«number = number+1»Value «ENDIF»«ENDFOR»'''
	}
}