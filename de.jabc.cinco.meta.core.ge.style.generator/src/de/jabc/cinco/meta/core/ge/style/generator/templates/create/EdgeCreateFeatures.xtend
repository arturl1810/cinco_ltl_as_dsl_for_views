package de.jabc.cinco.meta.core.ge.style.generator.templates.create

import de.jabc.cinco.meta.core.ge.style.generator.templates.util.GeneratorUtils
import de.jabc.cinco.meta.core.ge.style.model.errorhandling.ECincoError
import graphmodel.Node
import mgl.Edge
import mgl.ModelElement
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.ICreateConnectionContext
import org.eclipse.graphiti.features.context.impl.AddConnectionContext
import org.eclipse.graphiti.features.impl.AbstractCreateConnectionFeature
import org.eclipse.graphiti.mm.pictograms.Anchor
import org.eclipse.graphiti.mm.pictograms.Connection
import style.Styles

class EdgeCreateFeatures extends GeneratorUtils{
	
	def doGenerateEdgeCreateFeature(Edge e, Styles styles) '''
	package «e.packageNameCreate»;
	
	public class CreateFeature«e.fuName» extends «AbstractCreateConnectionFeature.name» {
		
		private «ECincoError.name» error = «ECincoError.name».OK;
		
		public CreateFeature«e.fuName»(«IFeatureProvider.name» fp) {
			super(fp, "«e.fuName»", "Create a new edge: «e.fuName»");
		}
		
		public boolean canCreate(«ICreateConnectionContext.name» context, boolean apiCall) {
			if (apiCall) {
				«Object.name» source = getBusinessObject(context.getSourceAnchor());
				«Object.name» target = getBusinessObject(context.getTargetAnchor());
		
				boolean srcOK = false;
				boolean trgOK = false;
				if (source != null && target != null) {
					srcOK=((graphmodel.Node) source).canStart(«e.graphModel.beanPackage».«e.fuName».class);
					trgOK=((graphmodel.Node) target).canEnd(«e.graphModel.beanPackage».«e.fuName».class);
				}
				if (! (srcOK && trgOK) && getError().equals(«ECincoError.name».OK))
					setError(«ECincoError.name».MAX_IN);
				return (srcOK && trgOK);
			}
			return false;
		}
	
		public boolean canCreate(«ICreateConnectionContext.name» context) {
			return canCreate(context, true);
		}
	
		@Override
		public «Connection.name» create(«ICreateConnectionContext.name» context) {
			«Connection.name» connection = null;
			«Object.name» source = getBusinessObject(context.getSourceAnchor());
			«Object.name» target = getBusinessObject(context.getTargetAnchor());

			if (source != null && target != null) {
				«e.graphModel.beanPackage».«e.fuName» «e.fuName.toLowerCase» = «e.graphModel.beanPackage».«e.graphModel.fuName.toLowerCase.toFirstUpper»Factory.eINSTANCE.create«e.fuName»();
					if (source instanceof «ModelElement.name») {
						«e.fuName.toLowerCase».setSourceElement( («Node.name») source);
					}
					if (target instanceof «ModelElement.name») {
						«e.fuName.toLowerCase».setTargetElement( («Node.name») target);
					}

				«AddConnectionContext.name» addContext = 
					new «AddConnectionContext.name»(context.getSourceAnchor(), context.getTargetAnchor());
				addContext.setNewObject(«e.fuName.toLowerCase»);
				connection = («Connection.name») getFeatureProvider().addIfPossible(addContext);
			}
			return connection;
		}	
	
		@Override
		public boolean canStartConnection(«ICreateConnectionContext.name» context) {
			«Object.name» source = getBusinessObject(context.getSourceAnchor());
			if (source instanceof graphmodel.Node) {	
				if (! ((graphmodel.Node) source).canStart(«e.graphModel.beanPackage».«e.fuName».class)) {
					if (getError().equals(«ECincoError.name».OK))
						setError(«ECincoError.name».MAX_OUT);
				}
				else return true;
			}
			return false;
		}
	
		private «Object.name» getBusinessObject(«Anchor.name» anchor) {
			if (anchor != null) {
				«Object.name» bo = getBusinessObjectForPictogramElement(anchor.getParent());
				return bo;
			}
			return null;
		}

«««		private boolean checkSource(«Object.name» source) {
«««			if (source instanceof «e.graphModel.beanPackage».Start) {
«««				if (((«e.graphModel.beanPackage».Start) source).getOutgoing(«e.graphModel.beanPackage».«e.fuName».class).size() < 1)
«««					return true;
«««				else setError(«ECincoError.name».MAX_OUT);
«««			} 
«««			if (getError().equals(«ECincoError.name».OK))
«««				setError(«ECincoError.name».INVALID_SOURCE);
«««
«««			return false;
«««		}
«««
«««		private boolean checkTarget(«Object.name» target){
«««			if (target instanceof «e.graphModel.beanPackage».End) {
«««				if (true) return true;
«««				else setError(«ECincoError.name».MAX_IN);
«««			}
«««			if (target instanceof «e.graphModel.beanPackage».Activity) {
«««				if (true)
«««					return true;
«««				else setError(«ECincoError.name».MAX_IN);
«««			}
«««			if (getError().equals(«ECincoError.name».OK))
«««				setError(«ECincoError.name».INVALID_TARGET);
«««
«««			return false;
«««		}
		
		public «ECincoError.name» getError() {
			return error;
		}
		
		public void setError(«ECincoError.name» error) {
			this.error = error;
		}
	}
	'''
}