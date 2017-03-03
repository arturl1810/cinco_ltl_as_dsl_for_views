package de.jabc.cinco.meta.core.ge.style.generator.templates.reconnect

import mgl.Edge
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import org.eclipse.graphiti.features.impl.DefaultReconnectionFeature
import de.jabc.cinco.meta.core.ge.style.generator.runtime.errorhandling.ECincoError
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IReconnectionContext
import de.jabc.cinco.meta.core.ui.highlight.ReconnectRegistry
import de.jabc.cinco.meta.core.ui.highlight.Highlighter
import org.eclipse.graphiti.mm.pictograms.Anchor
import org.eclipse.graphiti.features.context.impl.ReconnectionContext
import graphmodel.Node
import org.eclipse.graphiti.features.context.impl.UpdateContext
import org.eclipse.graphiti.features.IUpdateFeature

class EdgeReconnectFeatures {
	
	extension de.jabc.cinco.meta.core.utils.generator.GeneratorUtils = new GeneratorUtils

	def doGenerateEdgeReconnectFeature(Edge e)'''
	package «e.packageNameReconnect»;
	
	public class ReconnectFeature«e.fuName» extends «DefaultReconnectionFeature.name»{
	
		private «ECincoError.name» error = «ECincoError.name».OK;
	
		public ReconnectFeature«e.fuName»(«IFeatureProvider.name» fp) {
			super(fp);
		}
		
		@Override
		public void canceledReconnect(«IReconnectionContext.name» context) {
			«Highlighter.name».INSTANCE.get().onReconnectionCancel(«ReconnectRegistry.name».INSTANCE.remove(context.getConnection()));
			super.canceledReconnect(context);
		}
		
		@Override
		public void preReconnect(«IReconnectionContext.name» context) {
			«Highlighter.name».INSTANCE.get().onReconnectionEnd(«ReconnectRegistry.name».INSTANCE.remove(context.getConnection()));
			super.preReconnect(context);
		}
	
		public boolean canReconnect(«IReconnectionContext.name» context, boolean apiCall) {
			if (apiCall) {
				if (!«ReconnectRegistry.name».INSTANCE.containsKey(context.getConnection())) {
					«ReconnectRegistry.name».INSTANCE.put(context.getConnection(),"");
					«ReconnectRegistry.name».INSTANCE.put(context.getConnection(),
							«Highlighter.name».INSTANCE.get().onReconnectionStart(this, context));
				}
				«Anchor.name» newAnchor = context.getNewAnchor();
				«Anchor.name» oldAnchor = context.getOldAnchor();
					if (newAnchor != null && newAnchor.equals(oldAnchor))
						return true;
				if (newAnchor != null) {
					«Object.name» bo = getBusinessObjectForPictogramElement(context.getNewAnchor().getParent());
					if («ReconnectionContext.name».RECONNECT_TARGET.equals(context.getReconnectType())) {
						return ((graphmodel.Node) bo).canEnd(«e.fqBeanName».class);
					}
					
					if («ReconnectionContext.name».RECONNECT_SOURCE.equals(context.getReconnectType())) {
						return ((«Node.name») bo).canStart(«e.fqBeanName».class);
					}
				}
				return false;
			}
			return false;
		}
		
		@Override
		public boolean canReconnect(«IReconnectionContext.name» context) {
			return canReconnect(context, true);
		}	
	
		@Override
		public void postReconnect(«IReconnectionContext.name» context) {
			if (context.getNewAnchor().equals(context.getOldAnchor()))
				return;		
	
			«Object.name» boNode = getBusinessObjectForPictogramElement(context.getNewAnchor().getParent());
			«Object.name» boEdge = getBusinessObjectForPictogramElement(context.getConnection());
			
			if («ReconnectionContext.name».RECONNECT_TARGET.equalsIgnoreCase(context.getReconnectType()) && 
					boEdge instanceof «graphmodel.Edge.name») {
				
				«graphmodel.Edge.name» edge = («graphmodel.Edge.name») boEdge;
				edge.setTargetElement((«graphmodel.Node.name») boNode);
			}
	
			if («ReconnectionContext.name».RECONNECT_SOURCE.equals(context.getReconnectType()) && 
				boEdge instanceof «graphmodel.Edge.name») {
				«graphmodel.Edge.name» edge = («graphmodel.Edge.name») boEdge;
				edge.setSourceElement((«graphmodel.Node.name») boNode);
			}
	
			«UpdateContext.name» uc = new «UpdateContext.name»(context.getConnection());
			«IUpdateFeature.name» uf = getFeatureProvider().getUpdateFeature(uc);
			if (uf != null && uf.canUpdate(uc))
				uf.update(uc);
		}
	
		public «ECincoError.name» getError() {
			return error;
		}
	
		public void setError(«ECincoError.name» error) {
			this.error = error;
		}
	
		
	}
	'''
}