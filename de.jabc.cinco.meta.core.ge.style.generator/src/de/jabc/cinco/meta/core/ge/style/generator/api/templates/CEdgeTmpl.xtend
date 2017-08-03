package de.jabc.cinco.meta.core.ge.style.generator.api.templates

import de.jabc.cinco.meta.core.ge.style.generator.runtime.api.CModelElement
import de.jabc.cinco.meta.core.ge.style.generator.runtime.provider.CincoFeatureProvider
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import graphmodel.GraphModel
import graphmodel.IdentifiableElement
import mgl.Edge
import org.eclipse.graphiti.datatypes.ILocation
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.IReconnectionFeature
import org.eclipse.graphiti.features.context.impl.ReconnectionContext
import org.eclipse.graphiti.mm.pictograms.Anchor
import org.eclipse.graphiti.mm.pictograms.AnchorContainer
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.ui.services.GraphitiUi
import graphmodel.Node
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoGraphitiCopier
import graphmodel.internal.InternalEdge
import de.jabc.cinco.meta.core.ge.style.generator.runtime.api.CNode
import de.jabc.cinco.meta.runtime.xapi.GraphModelExtension
import graphmodel.internal.InternalNode
import graphmodel.ModelElementContainer

class CEdgeTmpl extends APIUtils {
	
extension CModelElementTmpl = new CModelElementTmpl

def doGenerateImpl(Edge me)'''
package «me.packageNameAPI»;

public «IF me.isIsAbstract»abstract «ENDIF»class «me.fuCName» extends «me.fqBeanImplName» implements «CModelElement.name»
	«IF !me.allSuperTypes.empty», «FOR st: me.allSuperTypes SEPARATOR ","» «st.fqBeanName» «ENDFOR» «ENDIF» {
	
	private «PictogramElement.name» pe;
	
	«me.constructor»
	
	public «me.pictogramElementReturnType» getPictogramElement() {
		if (pe == null)
			this.pe = ((«me.graphModel.fqCName») getRootElement()).fetchPictogramElement(this);
		return («me.pictogramElementReturnType») this.pe;
	}
	
	public void setPictogramElement(«PictogramElement.name» pe) {
		this.pe = pe;
	}
	
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
	
	private «IFeatureProvider.name» getFeatureProvider() {
		return «GraphitiUi.name».getExtensionManager().createFeatureProvider(getDiagram());
	}
	
	@Override
	public «Diagram.name» getDiagram() {
		«GraphModel.name» gm = getRootElement();
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
	
	private «Connection.name» getPictogramElement(«IdentifiableElement.name» target) {
		«FOR st : me.allSuperTypes»
		if («st.instanceofCheck("target")»)
			return ((«st.fqCName») target).getPictogramElement();
		«ENDFOR»
		
		return null;
	}
	
	@Override
	public <T extends «graphmodel.Edge.name»> T clone(«Node.name» source, «Node.name» target) {
		«CincoGraphitiCopier.name» copier = new «CincoGraphitiCopier.name»();
		«Connection.name» clonePE = («Connection.name») copier.copyPE(getPictogramElement());
		«InternalEdge.name» clone = («InternalEdge.name») clonePE.getLink().getBusinessObjects().get(0);
		«graphmodel.Edge.name» _edge = («graphmodel.Edge.name») clone.getElement();
		
		clonePE.setStart(((«CNode.name») source).getAnchor());
		clonePE.setEnd(((«CNode.name») target).getAnchor());
		
		_edge.setSourceElement(source);
		_edge.setTargetElement(target);
		
		«GraphModelExtension.name» gmx = new «GraphModelExtension.name»();
		«ModelElementContainer.name» commonContainer = gmx.getCommonContainer(source.getContainer().getInternalContainerElement(), («InternalNode.name») source.getInternalElement(), («InternalNode.name») target.getInternalElement()).getContainerElement();
		commonContainer.getInternalContainerElement().getModelElements().add(clone);
		((«CModelElement.name») commonContainer).getDiagram().getConnections().add(clonePE);
		((«CModelElement.name») commonContainer).addLinksToDiagram(clonePE);
		
		if (_edge instanceof «CModelElement.name»)
			((«CModelElement.name») _edge).setPictogramElement(clonePE);
		
		return (T) clone.getElement();
	}
	
	«me.updateContent»
	
	«me.deleteContent»
	
	«me.highlightContent»
}
'''
	

def doGenerateView(Edge me)'''
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