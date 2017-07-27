package de.jabc.cinco.meta.core.ge.style.generator.api.templates

import de.jabc.cinco.meta.core.ge.style.generator.runtime.provider.CincoFeatureProvider
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import de.jabc.cinco.meta.core.utils.MGLUtil
import mgl.ContainingElement
import mgl.Edge
import mgl.GraphModel
import mgl.ModelElement
import mgl.Node
import org.eclipse.graphiti.datatypes.ILocation
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.IMoveShapeFeature
import org.eclipse.graphiti.features.IReconnectionFeature
import org.eclipse.graphiti.features.context.impl.CreateConnectionContext
import org.eclipse.graphiti.features.context.impl.CreateContext
import org.eclipse.graphiti.features.context.impl.MoveShapeContext
import org.eclipse.graphiti.features.context.impl.ReconnectionContext
import org.eclipse.graphiti.mm.pictograms.Anchor
import org.eclipse.graphiti.mm.pictograms.AnchorContainer
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.mm.pictograms.Shape
import org.eclipse.graphiti.ui.services.GraphitiUi
import de.jabc.cinco.meta.core.utils.xtext.PickColorApplier
import org.eclipse.emf.ecore.util.EcoreUtil
import java.util.List
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.features.impl.DefaultMoveShapeFeature
import org.eclipse.graphiti.ui.features.DefaultDeleteFeature
import org.eclipse.graphiti.features.context.impl.DeleteContext
import org.eclipse.graphiti.features.IDeleteFeature
import org.eclipse.graphiti.features.context.impl.UpdateContext
import org.eclipse.graphiti.features.IUpdateFeature
import org.eclipse.graphiti.features.context.impl.AddContext
import org.eclipse.graphiti.features.context.impl.ResizeShapeContext
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoResizeFeature
import graphmodel.IdentifiableElement
import mgl.NodeContainer

class CModelElementTmpl extends APIUtils {
	
def doGenerateView(ModelElement me)'''
package «me.packageNameAPI»;

public class «me.fuCViewName» extends «me.fqBeanViewName» {
	
«««	«IF me instanceof NodeContainer»
«««	«FOR n : MGLUtils::getContainableNodes(me as NodeContainer).filter[!isIsAbstract]»
«««	public «n.fqBeanName» new«n.fuName»(int x, int y);
«««	public «n.fqBeanName» new«n.fuName»(int x, int y, int width, int height);
«««	«ENDFOR»
«««	«ENDIF»
«««	
«««	«IF me instanceof Node»
«««	«FOR e : MGLUtils::getOutgoingConnectingEdges(me as Node)»
«««	«FOR target : MGLUtils::getPossibleTargets(e)»
«««	public «e.fuCName» new«e.fuName»(«target.fuCName» cTarget);
«««	«ENDFOR»
«««	«ENDFOR»
«««	
«««	public void move(int x, int y);
«««	«FOR cont : MGLUtils::getPossibleContainers(me as Node)»
«««	public void move(«cont.fuCName» target, int x, int y);
«««	«ENDFOR»
«««	
«««	«IF me.isPrime»
«««	public «EObject.name» get«me.primeName.toFirstUpper»();
«««	«ENDIF»
«««	
«««	«ENDIF»
	
}

'''

def doGenerateImpl(ModelElement me)'''
package «me.packageNameAPI»;

public «IF me.isIsAbstract»abstract «ENDIF»class «me.fuCName» extends «me.fqBeanImplName» 
	«IF !me.allSuperTypes.empty» implements «FOR st: me.allSuperTypes SEPARATOR ","» «st.fqBeanName» «ENDFOR» «ENDIF»{
	
	private «PictogramElement.name» pe;
	
	«me.constructor»
	
	public void setPictogramElement(«me.pictogramElementReturnType» pe) {
		this.pe = pe;
	}
	
	«IF me instanceof NodeContainer»
	«FOR n : MGLUtil::getContainableNodes(me).filter[!isIsAbstract && !isPrime]»
	@Override
	public «n.fqBeanName» new«n.fuName»(int x, int y) {
		return new«n.fuName»(x,y,-1,-1);
	}
	
	@Override
	public «n.fqBeanName» new«n.fuName»(int x, int y, int width, int height) {
			«CreateContext.name» cc = new «CreateContext.name»();
			cc.setLocation(10, 10);
			cc.setTargetContainer((«ContainerShape.name») getPictogramElement());
			
			cc.setLocation(x,y);
			cc.setSize(width,height);
			
			«IFeatureProvider.name» fp = getFeatureProvider();
			«n.fqCreateFeatureName» cf = new «n.fqCreateFeatureName»(fp);
			if (fp instanceof «CincoFeatureProvider.name») {
				Object[] retVal = ((«CincoFeatureProvider.name») fp).executeFeature(cf, cc);
				«n.fuCName» tmp = («n.fuCName») retVal[0];
				tmp.setPictogramElement((«n.pictogramElementReturnType») retVal[1]);
				return tmp;
			}
			return null;
		}
	«ENDFOR»
	
	«FOR n : MGLUtil::getContainableNodes(me).filter[isPrime]»
		@Override
		public «n.fqBeanName» new«n.fuName»(«EObject.name» «n.primeReference.name», int x, int y) {
			return new«n.fuName»(«n.primeReference.name»,x,y,-1,-1);
		}
		
		@Override
		public «n.fqBeanName» new«n.fuName»(«EObject.name» «n.primeReference.name», int x, int y, int width, int height) {
			«AddContext.name» ac = new «AddContext.name»();
			ac.setLocation(10, 10);
			ac.setTargetContainer((«ContainerShape.name») getPictogramElement());
			
			ac.setLocation(x,y);
			ac.setSize(width,height);
			
			«IFeatureProvider.name» fp = getFeatureProvider();
			«n.fqPrimeAddFeatureName» af = new «n.fqPrimeAddFeatureName»(fp);
			if (fp instanceof «CincoFeatureProvider.name») {
				Object[] retVal = ((«CincoFeatureProvider.name») fp).executeFeature(af, ac);
				«n.fuCName» tmp = («n.fuCName») retVal[0];
				tmp.setPictogramElement((«n.pictogramElementReturnType») retVal[1]);
				return tmp;
			}
			return null;
		}
	«ENDFOR»
	«ENDIF»
	
	«IF me instanceof Node»
	«FOR e : MGLUtil::getOutgoingConnectingEdges(me as Node)»
	«FOR target : e.possibleTargets»
	@Override
	public «e.fqBeanName» new«e.fuName»(«target.fqBeanName» target) {
		if (!(target instanceof «target.fuCName»))
			throw new «RuntimeException.name»(
				«String.name».format("Parameter \"target\" of wrong type: Expected type: %s, given type %s", 
				«target.fuCName».class, target.getClass()));
		«CreateConnectionContext.name» cc = new «CreateConnectionContext.name»();
		cc.setSourcePictogramElement(getPictogramElement());
		cc.setTargetPictogramElement(((«target.fuCName») target).getPictogramElement());
		
		cc.setSourceAnchor(((«AnchorContainer.name»)this.getPictogramElement()).getAnchors().get(0));
		cc.setTargetAnchor(((«AnchorContainer.name»)((«target.fuCName»)target).getPictogramElement()).getAnchors().get(0));
		
		«IFeatureProvider.name» fp = getFeatureProvider();
		«e.fqCreateFeatureName» cf = new «e.fqCreateFeatureName»(fp);
		if (fp instanceof «CincoFeatureProvider.name») {
			Object[] retVal = ((«CincoFeatureProvider.name») fp).executeFeature(cf, cc);
			«e.fuCName» tmp = («e.fuCName») retVal[0];
«««			tmp.setPictogramElement((«PictogramElement.name») retVal[1]);
			return tmp;
		}
		return null;
	}
	
	«ENDFOR»
	«ENDFOR»
	
	«FOR cont : MGLUtil::getPossibleContainers(me as Node)»
	@Override
	public void _moveTo(«cont.fqBeanName» target, int x, int y) {
		«MoveShapeContext.name» mc = new «MoveShapeContext.name»((«Shape.name») this.pe);
«««		if (!(target instanceof «cont.fuCName»))
«««			throw new «RuntimeException.name»(
«««				«String.name».format("Parameter \"target\" of wrong type: Expected type: %s, given type %s", 
«««				«cont.fuCName».class, target.getClass()));
		mc.setTargetContainer((«ContainerShape.name») getPictogramElement(target));
		mc.setSourceContainer((«ContainerShape.name») this.getPictogramElement());
		
		mc.setX(x);
		mc.setY(y);
		
		«IFeatureProvider.name» fp = getFeatureProvider();
		«IMoveShapeFeature.name» mf = new «DefaultMoveShapeFeature.name»(fp); 
		if (fp instanceof «CincoFeatureProvider.name») {
			((«CincoFeatureProvider.name») fp).executeFeature(mf, mc);
			super._moveTo(target,x,y);
		}
	}
	
	«ENDFOR»
	
	@Override
	public void resize(int width, int height) {
		«ResizeShapeContext.name» rc = new «ResizeShapeContext.name»(getPictogramElement());
		«CincoResizeFeature.name» rf = new «CincoResizeFeature.name»(getFeatureProvider());
		
		rc.setSize(width, height);	
		rc.setLocation(getX(), getY());
		rf.activateApiCall(true);		
		
		if (rf.canResizeShape(rc))
			rf.resizeShape(rc);
		
		super.resize(width, height);
	}
	«ENDIF»
	
	«IF !(me instanceof GraphModel) && !(me instanceof Edge)»
	@Override
	public void move(int x, int y) {
		«MoveShapeContext.name» mc = new «MoveShapeContext.name»((«Shape.name») this.pe);
		
		mc.setTargetContainer((«ContainerShape.name») this.getPictogramElement().eContainer());
		mc.setSourceContainer((«ContainerShape.name») this.getPictogramElement().eContainer());
		
		mc.setX(x);
		mc.setY(y);
		
		«IFeatureProvider.name» fp = getFeatureProvider();
		«IMoveShapeFeature.name» mf = new «DefaultMoveShapeFeature.name»(fp);
		if (fp instanceof «CincoFeatureProvider.name») {
			((«CincoFeatureProvider.name») fp).executeFeature(mf, mc);
			super.move(x, y);
		}
	}
	
	@Override
	public void delete(){
		«DeleteContext.name» mc = new «DeleteContext.name»((«Shape.name») this.pe);
		
		«IFeatureProvider.name» fp = getFeatureProvider();
		«IDeleteFeature.name» mf = new «DefaultDeleteFeature.name»(fp);
		if (fp instanceof «CincoFeatureProvider.name») {
			((«CincoFeatureProvider.name») fp).executeFeature(mf, mc);
			super.delete();
		}
	}
	«ENDIF»
	
	«IF me instanceof Edge»
	«FOR source : me.possibleSources»
	@Override
	public void reconnectSource(«source.fqBeanName» source) {
		«Anchor.name» oldAnchor = ((«AnchorContainer.name») pe).getAnchors().get(0);
		«Anchor.name» newAnchor = ((«AnchorContainer.name») ((«source.fuCName») source).getPictogramElement()).getAnchors().get(0);
		«ILocation.name» loc = org.eclipse.graphiti.ui.services.GraphitiUi.getPeService().getLocationRelativeToDiagram(newAnchor);
		
		«ReconnectionContext.name» rc = new «ReconnectionContext.name»((«Connection.name») getPictogramElement(), oldAnchor, newAnchor, loc);
		rc.setReconnectType(«ReconnectionContext.name».RECONNECT_SOURCE);
		
		«IFeatureProvider.name» fp = getFeatureProvider();
		«IReconnectionFeature.name» rf = fp.getReconnectionFeature(rc);
		if (fp instanceof «CincoFeatureProvider.name») {
			((«CincoFeatureProvider.name») fp).executeFeature(rf, rc);
		}
	}
	
	«ENDFOR»
	
	«FOR target : me.possibleTargets»
	@Override
	public void reconnectTarget(«target.fqBeanName» target) {
		«Anchor.name» oldAnchor = ((«AnchorContainer.name») pe).getAnchors().get(0);
		«Anchor.name» newAnchor = ((«AnchorContainer.name») ((«target.fuCName») target).getPictogramElement()).getAnchors().get(0);
		«ILocation.name» loc = org.eclipse.graphiti.ui.services.GraphitiUi.getPeService().getLocationRelativeToDiagram(newAnchor);
		
		«ReconnectionContext.name» rc = new «ReconnectionContext.name»((«Connection.name») getPictogramElement(), oldAnchor, newAnchor, loc);
		rc.setReconnectType(«ReconnectionContext.name».RECONNECT_TARGET);
		
		«IFeatureProvider.name» fp = getFeatureProvider();
		«IReconnectionFeature.name» rf = fp.getReconnectionFeature(rc);
		if (fp instanceof «CincoFeatureProvider.name») {
			((«CincoFeatureProvider.name») fp).executeFeature(rf, rc);
		}
	}
	«ENDFOR»	
	«ENDIF»
	
	public void update() {
		try {
			«IFeatureProvider.name» fp = getFeatureProvider();
			«UpdateContext.name» uc = new «UpdateContext.name»(getPictogramElement());
			«IUpdateFeature.name» uf = fp.getUpdateFeature(uc);
			if (fp instanceof «CincoFeatureProvider.name») {
				((«CincoFeatureProvider.name») fp).executeFeature(uf, uc);
			}
		} catch («NullPointerException.name» e) {
			e.printStackTrace();
			return;
		}
	}
	
	private «IFeatureProvider.name» getFeatureProvider() {
«««		«IF !(me instanceof GraphModel)»
«««		«Diagram.name» d = («Diagram.name») ((«me.graphModel.fuCName») this.getRootElement()).getPictogramElement();
«««		«ELSE»
«««		«Diagram.name» d = («Diagram.name») getPictogramElement();
«««		«ENDIF»
		return «GraphitiUi.name».getExtensionManager().createFeatureProvider(getDiagram());
	}
	
	private «Diagram.name» getDiagram() {
		«graphmodel.GraphModel.name» gm = getRootElement();
		if (gm instanceof «me.rootElement.fqCName»)
			return ((«me.rootElement.fqCName») gm).getPictogramElement();
		«PictogramElement.name» curr = getPictogramElement();
		while (curr.eContainer() != null)
			curr = («PictogramElement.name») curr.eContainer();
		if (curr instanceof «Connection.name») {
			return ((«Connection.name») curr).getParent();
		}
		return («Diagram.name») curr;
	}
	
	«IF me instanceof Node»
	private «ContainerShape.name» getPictogramElement(«IdentifiableElement.name» target) {
		«FOR st : me.allSuperTypes»
		if («st.instanceofCheck("target")»)
			return ((«st.fqCName») target).getPictogramElement();
		«ENDFOR»
		
		return null;
	}
	«ENDIF»
	
	«IF me instanceof Edge»
	private «Connection.name» getPictogramElement(«IdentifiableElement.name» target) {
		«FOR st : me.allSuperTypes»
		if («st.instanceofCheck("target")»)
			return ((«st.fqCName») target).getPictogramElement();
		«ENDFOR»
		
		return null;
	}
	«ENDIF»
	
	«IF me instanceof GraphModel»
	public «PictogramElement.name» fetchPictogramElement(«graphmodel.ModelElement.name» me) {
		«List.name»<«PictogramElement.name»> pes = «Graphiti.name».getLinkService().getPictogramElements(getDiagram(), me.getInternalElement());
		if (pes != null && pes.size() > 0 )
			return pes.get(0);
		return null;
	}
	«ENDIF»
}
'''
	
} 