package de.jabc.cinco.meta.core.ge.style.generator.templates.delete

import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoDeleteFeature
import de.jabc.cinco.meta.core.utils.CincoUtils
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import mgl.Node
import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IDeleteContext
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.services.Graphiti
import style.Styles

class NodeDeleteFeatures extends GeneratorUtils{
	
	/**
	 * Generates the Class 'DeleteFeature' for the graphmodel gm
 	 * @param n : Node
 	 * @param styles : Styles
 	 */
	def doGenerateNodeDeleteFeature(Node n, Styles styles)'''
	package «n.packageNameDelete»;
	
	public class DeleteFeature«n.fuName» extends «CincoDeleteFeature.name» {

		public DeleteFeature«n.fuName»(«IFeatureProvider.name» fp) {
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
				if (bo instanceof «n.fqBeanName») {
					return true;
				}
				return super.canDelete(context);
			}
			return false;
		}
		
		@Override
		public boolean canDelete(«IDeleteContext.name» context) {
			return canDelete(context, «!CincoUtils.isDeleteDisabled(n)»);
		}
		
	
		@Override
		public void delete(«IDeleteContext.name» context) {
			super.delete(context);		
		}
	
		@Override
		protected boolean getUserDecision(«IDeleteContext.name» context) {
			return true;
		}
	
	}
	''' 
	
}