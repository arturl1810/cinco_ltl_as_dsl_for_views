package de.jabc.cinco.meta.core.ge.style.generator.templates.update

import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoUpdateFeature
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.Shape
import style.Styles
import mgl.ModelElement
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.ui.editor.DiagramBehavior
import org.eclipse.graphiti.services.Graphiti
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoLayoutFeature
import de.jabc.cinco.meta.core.utils.CincoUtil
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.gef.GraphicalEditPart
import org.eclipse.gef.EditPart
import graphmodel.IdentifiableElement

class ModelElementUpdateFeatures extends GeneratorUtils{
	
	/**
	 * Generates the Class 'UpdateFeature' for the Node n
	 * @param n : The node
	 * @param styles : Styles
	 */
	def doGenerateModelElementUpdateFeature(ModelElement me, Styles styles)'''
	package «me.packageNameUpdate»;
	
	public class UpdateFeature«me.fuName» extends «CincoUpdateFeature.name» {
		
		public UpdateFeature«me.fuName»(«IFeatureProvider.name» fp) {
			super(fp);
		}
	
		@Override
		protected void updateStyle(«EObject.name» bo, «Shape.name» s) {
		«IF CincoUtil::hasAppearanceProvider(me)»
			«Diagram.name» d = getDiagram();
			if (bo instanceof «IdentifiableElement.name»)
				bo = ((«IdentifiableElement.name») bo).getInternalElement();
			«String.name» gaName = «Graphiti.name».getPeService().getPropertyValue(s.getGraphicsAlgorithm(), «CincoLayoutFeature.name».KEY_GA_NAME);
			if (gaName != null && !gaName.isEmpty() && d != null) {
				«me.graphModel.packageName».«me.graphModel.fuName»LayoutUtils
					.updateStyleFromAppearance(
						s.getGraphicsAlgorithm(), 
						new «CincoUtil::getAppearanceProvider(me)»().getAppearance(
							(«me.fqBeanName»)((«me.fqInternalBeanName») bo).getElement(), gaName), d);
			}
			«Object.name» object = «Graphiti.name».getLinkService().getBusinessObjectForLinkedPictogramElement(s);
			if («me.instanceofCheck("object")») {
				object = ((«me.fqBeanName») object).getInternalElement();
				if (s instanceof «ContainerShape.name») {
					for («Shape.name» g : ((«ContainerShape.name») s).getChildren()) {
						updateStyle((«me.fqInternalBeanName») object, g);
					}
				}
			}
		«ENDIF»
		}
		
		@Override
		protected void updateStyle(«EObject.name» bo, «Connection.name» s) {
			«IF CincoUtil::hasAppearanceProvider(me)»
				«Diagram.name» d = getDiagram();
				if (bo instanceof «IdentifiableElement.name»)
					bo = ((«IdentifiableElement.name») bo).getInternalElement();
				String gaName = «Graphiti.name».getPeService().getPropertyValue(s.getGraphicsAlgorithm(), «CincoLayoutFeature.name».KEY_GA_NAME);
				if (gaName != null && !gaName.isEmpty() && d != null) {
					«me.graphModel.packageName».«me.graphModel.fuName»LayoutUtils.
						updateStyleFromAppearance(
							s.getGraphicsAlgorithm(), 
							new «CincoUtil::getAppearanceProvider(me)»().getAppearance(
								(«me.fqBeanName»)((«me.fqInternalBeanName») bo).getElement(), gaName), d);
				}
				«Object.name» object = «Graphiti.name».getLinkService().getBusinessObjectForLinkedPictogramElement(s);
				if («me.instanceofCheck("object")») {
					object = ((«me.fqBeanName») object).getInternalElement();
					for («Shape.name» g : s.getConnectionDecorators()) {
						updateStyle((«me.fqInternalBeanName») object, g);
					}
					
				}
				
				if (!(getDiagramBehavior() instanceof «DiagramBehavior.name»))
					return;
				«DiagramBehavior.name» db = («DiagramBehavior.name») getDiagramBehavior();
				if (db == null)
					return;
				«GraphicalEditPart.name» editPart = db.getEditPartForPictogramElement(s);
				if (editPart == null)
					return;
				int selected_info = editPart.getSelected();
				editPart.setSelected(«EditPart.name».SELECTED_NONE);
				editPart.setSelected(selected_info);
			«ENDIF»
		}
	}
	'''

}