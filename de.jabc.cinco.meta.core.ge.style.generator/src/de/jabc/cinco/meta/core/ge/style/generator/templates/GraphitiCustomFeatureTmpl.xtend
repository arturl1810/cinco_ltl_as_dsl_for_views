package de.jabc.cinco.meta.core.ge.style.generator.templates

import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import mgl.GraphModel

class GraphitiCustomFeatureTmpl extends APIUtils {
	
	def generateCustomFeature(GraphModel gm) '''
	package «gm.packageName»;
	
	import de.jabc.cinco.meta.runtime.action.CincoCustomAction;
	import graphmodel.IdentifiableElement;
	import graphmodel.internal.InternalModelElement;
	import org.eclipse.graphiti.features.IFeatureProvider;
	import org.eclipse.graphiti.features.context.ICustomContext;
	import org.eclipse.graphiti.features.custom.AbstractCustomFeature;
	import org.eclipse.graphiti.features.custom.ICustomFeature;
	import org.eclipse.graphiti.services.Graphiti;
	import org.eclipse.graphiti.mm.pictograms.PictogramElement;
	
	class «gm.fuName»GraphitiCustomFeature<T extends IdentifiableElement> extends AbstractCustomFeature implements ICustomFeature{
		
		private CincoCustomAction<T> delegate;
		
		public «gm.fuName»GraphitiCustomFeature(IFeatureProvider fp) {
			super(fp);
		}
		
		public «gm.fuName»GraphitiCustomFeature(IFeatureProvider fp, CincoCustomAction<T> cca) {
			super(fp);
			this.delegate = cca;
		}
		
		@Override
		public String getDescription() {
			return delegate.getName();
		}
		
		@Override
		public String getName() {
			return delegate.getName();
		}
		
		@Override
		public boolean canExecute(ICustomContext context) {
			PictogramElement pe = context.getPictogramElements()[0];
			T bo = (T) Graphiti.getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
			«FOR me : gm.modelElements»
			if («me.instanceofCheck("bo")») {
				«me.fqCName» «me.flCName» = new «me.fqCName»((«me.fqBeanName») bo,pe);
				return delegate.canExecute((T) «me.flCName»);
			}
			«ENDFOR»
			else {
				throw new RuntimeException("Error in canExecute with element: " + bo);
			}
«««			switch bo {
«««				InternalModelElement : delegate.canExecute(bo.element as T)
«««			}
		}
		
		@Override
		public void execute(ICustomContext context) {
			PictogramElement pe = context.getPictogramElements()[0];
			T bo = (T) Graphiti.getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
			«FOR me : gm.modelElements»
			if («me.instanceofCheck("bo")») {
				«me.fqCName» «me.flCName» = new «me.fqCName»((«me.fqBeanName») bo,pe);
				delegate.execute((T) «me.flCName»);
			}
			«ENDFOR»
			else {
				throw new RuntimeException("Error in canExecute with element: " + bo);
			}
«««			switch bo {
«««				InternalModelElement : delegate.execute(bo.element as T)
«««				default : throw new RuntimeException("Error in canExecute with element: " + bo) 
«««			}
		}
		
		
	}
	'''
	
	
}