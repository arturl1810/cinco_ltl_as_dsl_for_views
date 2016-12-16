package de.jabc.cinco.meta.core.ge.style.generator.templates.delete

import de.jabc.cinco.meta.core.ge.style.generator.templates.util.GeneratorUtils
import mgl.Node
import de.jabc.cinco.meta.core.ui.features.CincoDeleteFeature
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IDeleteContext
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.services.Graphiti
import de.jabc.cinco.meta.core.utils.CincoUtils
import style.Styles

class NodeDeleteFeatures extends GeneratorUtils{
	
	def doGenerateDeleteFeature(Node n, Styles styles)'''
	package «n.packageNameDelete»;
	
	public class DeleteFeature«n.fuName» extends «CincoDeleteFeature.name» {

		public DeleteFeature«n.fuName»(«IFeatureProvider.name» fp) {
			super(fp);
			// TODO Auto-generated constructor stub
		}
		
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