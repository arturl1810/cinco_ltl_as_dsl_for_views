package de.jabc.cinco.meta.core.ge.style.generator.api.templates

import de.jabc.cinco.meta.core.ge.style.generator.runtime.api.CModelElement
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoGraphitiCopier
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoResizeFeature
import de.jabc.cinco.meta.core.ge.style.generator.runtime.provider.CincoFeatureProvider
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import de.jabc.cinco.meta.core.utils.MGLUtil
import graphmodel.GraphModel
import graphmodel.IdentifiableElement
import graphmodel.ModelElementContainer
import mgl.ModelElement
import mgl.Node
import mgl.NodeContainer
import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.IMoveShapeFeature
import org.eclipse.graphiti.features.context.impl.AddContext
import org.eclipse.graphiti.features.context.impl.CreateConnectionContext
import org.eclipse.graphiti.features.context.impl.CreateContext
import org.eclipse.graphiti.features.context.impl.MoveShapeContext
import org.eclipse.graphiti.features.context.impl.ResizeShapeContext
import org.eclipse.graphiti.features.impl.DefaultMoveShapeFeature
import org.eclipse.graphiti.mm.pictograms.AnchorContainer
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.mm.pictograms.Shape
import org.eclipse.graphiti.ui.services.GraphitiUi
import de.jabc.cinco.meta.core.ge.style.generator.runtime.api.CNode
import org.eclipse.graphiti.mm.pictograms.PictogramsFactory
import graphmodel.internal.InternalNode
import org.eclipse.emf.ecore.util.EcoreUtil
import graphmodel.internal.InternalModelElementContainer
import java.util.ArrayList
import graphmodel.internal.InternalModelElement
import java.util.List
import graphmodel.Edge
import graphmodel.internal.InternalEdge

class CNodeTmpl extends APIUtils {

extension CModelElementTmpl = new CModelElementTmpl


def doGenerateImpl(Node me)'''
package «me.packageNameAPI»;

public «IF me.isIsAbstract»abstract «ENDIF»class «me.fuCName» extends «me.fqBeanImplName» implements «CNode.name»
	«IF !me.allSuperTypes.empty», «FOR st: me.allSuperTypes SEPARATOR ","» «st.fqBeanName» «ENDFOR» «ENDIF» {
	
	private «PictogramElement.name» pe;
	
	«me.constructor»
	
	public «me.pictogramElementReturnType» getPictogramElement() {
		if (pe == null)
			this.pe = ((«(me.graphModel as ModelElement).fqCName») getRootElement()).fetchPictogramElement(this);
		return («me.pictogramElementReturnType») this.pe;
	}
	
	public void setPictogramElement(«PictogramElement.name» pe) {
		this.pe = pe;
	}
	
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
		«MoveShapeContext.name» mc = new «MoveShapeContext.name»((«Shape.name») getPictogramElement());
«««		if (!(target instanceof «cont.fuCName»))
«««			throw new «RuntimeException.name»(
«««				«String.name».format("Parameter \"target\" of wrong type: Expected type: %s, given type %s", 
«««				«cont.fuCName».class, target.getClass()));
		mc.setTargetContainer((«ContainerShape.name») ((«CModelElement.name») target).getPictogramElement());
		mc.setSourceContainer((«ContainerShape.name») ((«CModelElement.name») this.getContainer()).getPictogramElement());
		
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
	
	private «IFeatureProvider.name» getFeatureProvider() {
		return «GraphitiUi.name».getExtensionManager().createFeatureProvider(getDiagram());
	}
	
	@Override
	public «Diagram.name» getDiagram() {
		«GraphModel.name» gm = getRootElement();
		if (gm instanceof «(me.rootElement as ModelElement).fqCName»)
			return ((«(me.rootElement as ModelElement).fqCName») gm).getPictogramElement();
		«PictogramElement.name» curr = getPictogramElement();
		while (curr.eContainer() != null)
			curr = («PictogramElement.name») curr.eContainer();
		if (curr instanceof «Connection.name») {
			return ((«Connection.name») curr).getParent();
		}
		return («Diagram.name») curr;
	}
	
	private «ContainerShape.name» getPictogramElement(«IdentifiableElement.name» target) {
		«FOR st : me.allSuperTypes»
		if («st.instanceofCheck("target")»)
			return ((«st.fqCName») target).getPictogramElement();
		«ENDFOR»
		
		return null;
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
	
	@Override
	public <T extends «graphmodel.Node.name»> T clone(«ModelElementContainer.name» targetContainer) {
		«CincoGraphitiCopier.name» copier = new «CincoGraphitiCopier.name»();
		«Shape.name» clonePE = copier.copy(this.getPictogramElement());
		«InternalNode.name» bo = («InternalNode.name») clonePE.getLink().getBusinessObjects().get(0);
		((«CNode.name») bo.getElement()).setPictogramElement(clonePE);
		//«EcoreUtil.name».setID(bo, getInternalElement().getId());
		//«EcoreUtil.name».setID(bo.getElement(), getId());
		«ContainerShape.name» parentContainerShape = null;
		if (targetContainer instanceof «CModelElement.name») {
			parentContainerShape = ((«CModelElement.name») targetContainer).getPictogramElement();
			parentContainerShape.getChildren().add((«Shape.name») clonePE);
			targetContainer.getInternalContainerElement().getModelElements().add(bo);
			((«CModelElement.name») targetContainer).addLinksToDiagram(clonePE);
		}
		if (bo instanceof «InternalModelElementContainer.name») {
			«List.name»<«InternalModelElement.name»> remove = new «ArrayList.name»<>();
			remove.addAll(((«InternalModelElementContainer.name») bo).getModelElements());
			remove.stream().filter(me -> me instanceof «InternalEdge.name»).forEach(e -> ((«Edge.name»)e.getElement()).delete());
			remove.stream().filter(me -> me instanceof «InternalNode.name»).forEach(e -> ((«graphmodel.Node.name»)e.getElement()).delete());
		}
		
		return (T) bo.getElement();
	}
	
	«me.updateContent»
	
	«me.deleteContent»
	
	«me.highlightContent»
}
'''
	
	
def doGenerateView(Node me)'''
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
} 