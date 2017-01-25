package de.jabc.cinco.meta.core.ge.style.generator.templates.update

import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils;
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

class EdgeUpdateFeatures extends GeneratorUtils{
	
	var static number = 0
	
	/** 
	 * Generates the 'Update-Feature' for a given edge
	 * @param e : The edge
	 * @param styles : The style
	*/	
	def doGenerateEdgeUpdateFeature(Edge e, Styles styles)'''
	package «e.packageNameUpdate»;
	
	public class UpdateFeature«e.fuName» extends «AbstractUpdateFeature.name»{
		
		private static «ExpressionFactoryImpl.name» factory = new «ExpressionFactoryImpl.name»();
		private static «e.graphModel.packageName».expression.«e.graphModel.fuName»ExpressionLanguageContext elContext;
		
		/**
		 * Call of the Superclass
		 * @param fp : Fp is the parameter of the Superclass-Call
		*/
		public UpdateFeature«e.fuName»(«IFeatureProvider.name» fp) {
			super(fp);
		}
		
		/**
		 * Checks if a pictogram element can be updated
		 * @param context : Contains the information, needed to let a feature update a pictogram element
		 * @return Returns true if a pictogram element can be updated and false if not
		*/
		@Override
		public boolean canUpdate(«IUpdateContext.name» context) {
			«PictogramElement.name» pe = context.getPictogramElement();
			«EObject.name» bo = «Graphiti.name».getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
			return (bo instanceof «e.fqBeanName»);
		}
	
		/**
		 * Checks if an Update for a pictogram element is needed
		 * @param context : Contains the information, needed to let a feature update a pictogram element
		 * @return Returns a 'true reason' or a 'false reason' to update a pictogram element
		*/
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
		
		/**
		 * Checks if the update process was successful
		 * @param context : Contains the information, needed to let a feature update a pictogram element
		 * @return Returns true if the update process was successful and false if not
		*/
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

		
		/**
		 * Updates the text on an edge
		 * @param «e.name.toLowerCase» : «e.name.toLowerCase» is the pictogram element that will be updated
		 * @param pe : A representation of the model object 'Pictogram Element'
		*/
		private void updateText( «e.fqBeanName» «e.flName», «PictogramElement.name» pe) {
			if (pe instanceof «ContainerShape.name») {
				«PictogramElement.name» tmp = pe;
				Object o = «Graphiti.name».getLinkService().getBusinessObjectForLinkedPictogramElement(tmp);
				if («e.fuName.toFirstLower».equals(o) || o == null)
				for («Shape.name» _s : ((«ContainerShape.name») pe).getChildren()) {
					updateText(«e.fuName.toFirstLower», _s);
				}
			} 
			if (pe instanceof «Connection.name») {
				«Connection.name» connection = («Connection.name») pe;
				for («ConnectionDecorator.name» cd : connection.getConnectionDecorators()) {
					updateText(«e.fuName.toFirstLower», cd); 
				} 
			} else {
				if (pe.getGraphicsAlgorithm() instanceof «AbstractText.name») {
					«ClassLoader.name» contextClassLoader = «Thread.name».currentThread().getContextClassLoader();
					«AbstractText.name» t = («AbstractText.name») pe.getGraphicsAlgorithm();
					try {
						«Thread.name».currentThread().setContextClassLoader(UpdateFeature«e.fuName».class.getClassLoader());
						«getValue(e)»
						
						«String.name» formatString = «Graphiti.name».getPeService().getPropertyValue(t, «e.graphModel.packageName».«e.graphModel.name»GraphitiUtils.KEY_FORMAT_STRING);
						t.setValue(«String.name».format(formatString «fill(e)»));
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
		
		/*
		 * Checks if an update is needed
		 * @param «e.name.toLowerCase» : «e.name.toLowerCase» is the pictogram element that will be updated
		 * @param pe : A representation of the model object 'Pictogram Element'
		 * @return Returns true if an update is needed and false if not
		*/
		public static boolean checkUpdateNeeded(«e.graphModel.beanPackage».«e.fuName» «e.fuName.toFirstLower», «PictogramElement.name» pe) {
			boolean updateNeeded;
			if (pe instanceof «ContainerShape.name») {
				for («Shape.name» _s : ((«ContainerShape.name») pe).getChildren()) {
					return checkUpdateNeeded(«e.fuName.toFirstLower», _s);
				}
			} 
			if (pe instanceof «Connection.name») {
				«Connection.name» connection = («Connection.name») pe;
				for («ConnectionDecorator.name» cd : connection.getConnectionDecorators()) {
					updateNeeded = checkUpdateNeeded(«e.fuName.toFirstLower», cd);

					if (updateNeeded)
						return true;
				}
			} else {
				«Object.name» o = «Graphiti.name».getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
				if (pe.getGraphicsAlgorithm() instanceof «AbstractText.name» && «e.fuName.toFirstLower».equals(o)) {
					«ClassLoader.name» contextClassLoader = «Thread.name».currentThread().getContextClassLoader();
					try {
						«Thread.name».currentThread().setContextClassLoader( «e.packageNameUpdate».UpdateFeature«e.fuName».class.getClassLoader());
						«AbstractText.name» t = («AbstractText.name») pe.getGraphicsAlgorithm();
						«getValue(e)»
						
						«String.name» formatString = «Graphiti.name».getPeService().getPropertyValue(t, «e.graphModel.packageName».«e.graphModel.name»GraphitiUtils.KEY_FORMAT_STRING);
						«String.name» oldVal = «String.name».format(formatString «fill(e)»);
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
	 * Auxiliary method to get the text value of a given edge
	 * @param e : The edge
	 */
	def getValue(Edge e){
		var listAnnot = e.annotations;
		var annot = listAnnot.get(0);
		var listValue = annot.value;
		number = 0
		
		return '''
		«FOR value : listValue»«IF value.startsWith("${")»

		elContext = new «e.packageName».expression.«e.graphModel.name»ExpressionLanguageContext(«e.flName»);
		Object tmp«number = number+1»Value = factory.createValueExpression(elContext, "«value»", Object.class).getValue(elContext); 
		«ENDIF»«ENDFOR»''' 

	}
	/** 
	 * Auxiliary method
	 * @param e : The edge
	*/	
	def fill(Edge e){
		var listAnnot = e.annotations;
		var annot = listAnnot.get(0);
		var listValue = annot.value;
		number = 0
		return 
		'''«FOR value : listValue SEPARATOR ","»«IF value.startsWith("${")»tmp«number = number+1»Value«ENDIF»«ENDFOR»'''
	}
}