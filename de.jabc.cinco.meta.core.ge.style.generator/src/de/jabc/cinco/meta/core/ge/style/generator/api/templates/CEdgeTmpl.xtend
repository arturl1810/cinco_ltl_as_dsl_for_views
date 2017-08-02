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

class CEdgeTmpl extends APIUtils {
	
extension CModelElementTmpl = new CModelElementTmpl

def doGenerateImpl(Edge me)'''
package «me.packageNameAPI»;

public «IF me.isIsAbstract»abstract «ENDIF»class «me.fuCName» extends «me.fqBeanImplName» 
	«IF !me.allSuperTypes.empty» implements «FOR st: me.allSuperTypes SEPARATOR ","» «st.fqBeanName» «ENDFOR» «ENDIF»{
	
	private «PictogramElement.name» pe;
	
	«me.constructor»
	
	public «me.pictogramElementReturnType» getPictogramElement() {
		if (pe == null)
			this.pe = ((«me.graphModel.fqCName») getRootElement()).fetchPictogramElement(this);
		return («me.pictogramElementReturnType») this.pe;
	}
	
	public void setPictogramElement(«me.pictogramElementReturnType» pe) {
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
	
	private «Connection.name» getPictogramElement(«IdentifiableElement.name» target) {
		«FOR st : me.allSuperTypes»
		if («st.instanceofCheck("target")»)
			return ((«st.fqCName») target).getPictogramElement();
		«ENDFOR»
		
		return null;
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