package de.jabc.cinco.meta.core.ge.style.generator.templates.delete

import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoDeleteFeature
import de.jabc.cinco.meta.core.utils.CincoUtil
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IDeleteContext
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.services.Graphiti
import style.Styles
import mgl.ModelElement
import graphmodel.internal.InternalGraphModel

class ModelElementDeleteFeatures extends GeneratorUtils{
	
	/**
	 * Generates the Class 'DeleteFeature' for the graphmodel gm
 	 * @param n : Node
 	 * @param styles : Styles
 	 */
	def doGenerateModelElementDeleteFeature(ModelElement me, Styles styles)'''
	package «me.packageNameDelete»;
	
	public class DeleteFeature«me.fuName» extends «CincoDeleteFeature.name» {

		public DeleteFeature«me.fuName»(«IFeatureProvider.name» fp) {
			super(fp);
		}
		
		/**
		 * Checks if the node can be deleted
		 * @param context : DeleteContext
		 * @param apiCall : Checks if true
		 * @return Return true if it can be deleted
		 */
		public boolean canDelete(«IDeleteContext.name» context, boolean apiCall) {
			if (apiCall) {
				«PictogramElement.name» pe = context.getPictogramElement();
				«EObject.name» bo = «Graphiti.name».getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
				if (bo instanceof «me.fqInternalBeanName») {
					return true;
				}
				return super.canDelete(context);
			}
			return false;
		}
		
		@Override
		public boolean canDelete(«IDeleteContext.name» context) {
			return canDelete(context, «!CincoUtil.isDeleteDisabled(me)»);
		}
	
		@Override
		public void delete(«IDeleteContext.name» context) {
			«Object.name» bo = getBusinessObjectForPictogramElement(context.getPictogramElement());
			if (bo instanceof «me.fqInternalBeanName») {
				«me.fqInternalBeanName» elm = («me.fqInternalBeanName») bo;
				«InternalGraphModel.name» intModel = elm.getRootElement();
				((«me.fqBeanName») elm.getElement()).delete();
				intModel.getElement().updateModelElements();
			}
		}
	
		@Override
		protected boolean getUserDecision(«IDeleteContext.name» context) {
			return true;
		}
	
	}
	''' 
	
}