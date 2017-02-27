package de.jabc.cinco.meta.core.ge.style.generator.templates

import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import java.util.ArrayList
import java.util.List
import mgl.GraphModel
import org.eclipse.emf.common.notify.Notification
import org.eclipse.emf.ecore.util.EContentAdapter
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.IUpdateFeature
import org.eclipse.graphiti.features.context.impl.CustomContext
import org.eclipse.graphiti.features.context.impl.UpdateContext
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.ui.platform.GFPropertySection
import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.mm.pictograms.Diagram

class GraphModelEContentAdapterTmpl extends APIUtils {
	
	def generateGraphModelEContentAdapter(GraphModel gm) '''
	package «gm.packageName».content.adapter;
	
	import java.util.List;
	
	public class «gm.fuName»EContentAdapter extends «EContentAdapter.name» {
	
		private «gm.packageName».«gm.fuName»DiagramTypeProvider dtp;
		private static «gm.fuName»EContentAdapter instance;
		private static «List.name»<«GFPropertySection.name»> sections = new «ArrayList.name»<>();
		
		protected «gm.fuName»EContentAdapter() {
			dtp = («gm.packageName».«gm.fuName»DiagramTypeProvider) «gm.packageName».«gm.fuName»GraphitiUtils.getInstance().getDTP();
		}
	
		public static «gm.fuName»EContentAdapter getInstance() {
			if (instance == null)
				instance = new «gm.fuName»EContentAdapter();
			return instance;
		}
	
		protected «Diagram.name» getDiagram(){
			if («gm.packageName».«gm.fuName»GraphitiUtils.getInstance().getDTP() == null)
				return null;
			return «gm.packageName».«gm.fuName»GraphitiUtils.getInstance().getDTP().getDiagram();
		}
		
		protected «IFeatureProvider.name» getFeatureProvider() {
			return «gm.packageName».«gm.fuName»GraphitiUtils.getInstance().getDTP().getFeatureProvider();
		}
		
	
		@Override
		public void notifyChanged(«Notification.name» notification) {
			«Object.name» o = notification.getNotifier();
			if («gm.internalInstanceofCheck("o")») {
				«gm.fqBeanName» tmp = («gm.fqBeanName») ((«gm.fqInternalBeanName») o).getElement();
				if (getDiagram() == null)
					return;
				«List.name»<«PictogramElement.name»> pes = «Graphiti.name».getLinkService().getPictogramElements(getDiagram(), tmp);
				if (pes == null || pes.isEmpty())
					return;
				«PictogramElement.name» pe = pes.get(0);
	
				«UpdateContext.name» uContext = new «UpdateContext.name»(pes.get(0));
				«IFeatureProvider.name» fp = getFeatureProvider();
				if (fp == null) 
					return;
				«IUpdateFeature.name» uf = fp.getUpdateFeature(uContext);
				if (uf != null && uf.canUpdate(uContext)) {
					uf.update(uContext);
				}
	
				try {
					«CustomContext.name» cc = new «CustomContext.name»();
					cc.setPictogramElements(new «PictogramElement.name»[] {pe});
				} catch («Exception.name	» e) {
					e.printStackTrace();
				}
				refreshPropertyView();
			}
			
			
		}
	
		public void addAdapter(«EObject.name» bo) {
			if («gm.instanceofCheck("bo")») {
				if (!((«gm.fqBeanName») bo).getInternalElement().eAdapters().contains(getInstance()))
					((«gm.fqBeanName») bo).getInternalElement().eAdapters().add(getInstance());
			}
			«
			FOR me : gm.modelElements»
			if («me.instanceofCheck("bo")») {
				if (!((«me.fqBeanName») bo).getInternalElement().eAdapters().contains(«me.fuName»EContentAdapter.getInstance()))
					((«me.fqBeanName») bo).getInternalElement().eAdapters().add(«me.fuName»EContentAdapter.getInstance());
			}
			«ENDFOR»
			
	
		}
		
		protected void refreshPropertyView() {
			for («GFPropertySection.name» gfPS : sections) {
				if (gfPS != null)
					gfPS.refresh();
			}
		}
	
		public static List<«GFPropertySection.name»> getSections() {
			return sections;
		}
		
		public void addSection(«GFPropertySection.name» gfPS) {
			if (!sections.contains(gfPS))
				sections.add(gfPS);
		}
	
		public void remove(«GFPropertySection.name» gfPS) {
			sections.remove(gfPS);
		}
		
	}
	'''
	
	
	
}