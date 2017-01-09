package de.jabc.cinco.meta.core.ge.style.generator.api.templates

import mgl.GraphModel
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.GeneratorUtils
import cincoapi.CGraphModel

import de.jabc.cinco.meta.core.utils.MGLUtils
import org.eclipse.graphiti.features.context.impl.CreateContext
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.ui.services.GraphitiUi
import mgl.ModelElement
import mgl.NodeContainer
import mgl.ContainingElement
import mgl.Node
import org.eclipse.graphiti.features.context.impl.CreateConnectionContext
import mgl.ReferencedModelElement
import org.eclipse.emf.ecore.EObject
import de.jabc.cinco.meta.core.ge.style.generator.runtime.provider.CincoFeatureProvider

class CModelElementTmpl extends GeneratorUtils {
	
def doGenerateInterface(ModelElement me)'''
package «me.packageNameAPI»;

public interface «me.fuCName» extends «IF me.extends == null»«me.superClass»«ELSE»«me.extends.fuCName»«ENDIF», «me.fqBeanName» {
	
	«IF me instanceof NodeContainer»
	«FOR n : MGLUtils::getContainableNodes(me as NodeContainer).filter[!isIsAbstract]»
	public «n.fqBeanName» new«n.fuName»(int x, int y);
	public «n.fqBeanName» new«n.fuName»(int x, int y, int width, int height);
	«ENDFOR»
	«ENDIF»
	
	«IF me instanceof Node»
	«FOR e : MGLUtils::getOutgoingConnectingEdges(me as Node)»
	«FOR target : MGLUtils::getPossibleTargets(e)»
	public «e.fuCName» new«e.fuName»(«target.fuCName» cTarget);
	«ENDFOR»
	«ENDFOR»
	
	public void move(int x, int y);
	«FOR cont : MGLUtils::getPossibleContainers(me as Node)»
	public void move(«cont.fuCName» target, int x, int y);
	«ENDFOR»
	
	«IF me.isPrime»
	public «EObject.name» get«me.primeName.toFirstUpper»();
	«ENDIF»
	
	«ENDIF»
	
}

'''

def doGenerateImpl(ModelElement me)'''
package «me.packageNameAPI»;

public «IF me.isIsAbstract»abstract«ENDIF» class «me.fuCImplName» extends «me.fqBeanImplName» implements «me.fuCName» {
	
	private «PictogramElement.name» pe;
	
	@Override
	public «PictogramElement.name» getPictogramElement() {
		return this.pe;
	}
	
	@Override
	public void setPictogramElement(«PictogramElement.name» pe) {
		this.pe = pe;
	}
	
	«IF me instanceof ContainingElement»
	«FOR n : MGLUtils::getContainableNodes(me).filter[!isIsAbstract]»

	public «n.fuCName» new«n.fuName»(int x, int y) {
		«CreateContext.name» cc = new «CreateContext.name»();
		cc.setLocation(10, 10);
		cc.setTargetContainer((«ContainerShape.name») getPictogramElement());
		
		cc.setLocation(x,y);
		cc.setSize(-1,-1);
		
		«IFeatureProvider.name» fp = getFeatureProvider();
		«n.fqCreateFeatureName» cf = new «n.fqCreateFeatureName»(fp);
		if (fp instanceof «CincoFeatureProvider.name») {
			Object[] retVal = ((«CincoFeatureProvider.name») fp).executeFeature(cf, cc);
			«n.fuCName» tmp = («n.fuCName») retVal[0];
			tmp.setPictogramElement((«PictogramElement.name») retVal[1]);
			return tmp;
		}
		return null;
	}
	
	public «n.fuCName» new«n.fuName»(int x, int y, int width, int height) {
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
				tmp.setPictogramElement((«PictogramElement.name») retVal[1]);
				return tmp;
			}
			return null;
		}
	«ENDFOR»
	«ENDIF»
	
	«IF me instanceof Node»
	«FOR e : MGLUtils::getOutgoingConnectingEdges(me as Node)»
	«FOR target : MGLUtils::getPossibleTargets(e)»
	public «e.fuCName» new«e.fuName»(«target.fuCName» cTarget) {
		«CreateConnectionContext.name» cc = new «CreateConnectionContext.name»();
		cc.setSourcePictogramElement(getPictogramElement());
		cc.setTargetPictogramElement(cTarget.getPictogramElement());
		
		«IFeatureProvider.name» fp = getFeatureProvider();
		«e.fqCreateFeatureName» cf = new «e.fqCreateFeatureName»(fp);
		if (fp instanceof «CincoFeatureProvider.name») {
			Object[] retVal = ((«CincoFeatureProvider.name») fp).executeFeature(cf, cc);
			«e.fuCName» tmp = («e.fuCName») retVal[0];
			tmp.setPictogramElement((«PictogramElement.name») retVal[1]);
			return tmp;
		}
		return null;
	}
	«ENDFOR»
	«ENDFOR»
	
	«FOR cont : MGLUtils::getPossibleContainers(me as Node)»
	«ENDFOR»
	«ENDIF»
	
	private «IFeatureProvider.name» getFeatureProvider() {
		«Diagram.name» d = («Diagram.name») getPictogramElement();
		return «GraphitiUi.name».getExtensionManager().createFeatureProvider(d);
	}
}
'''
	
} 