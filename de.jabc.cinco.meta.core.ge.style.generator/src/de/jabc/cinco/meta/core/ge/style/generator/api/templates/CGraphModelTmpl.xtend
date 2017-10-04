package de.jabc.cinco.meta.core.ge.style.generator.api.templates

import de.jabc.cinco.meta.core.ge.style.generator.runtime.api.CModelElement
import de.jabc.cinco.meta.core.ge.style.generator.runtime.provider.CincoFeatureProvider
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import de.jabc.cinco.meta.core.utils.MGLUtil
import graphmodel.ModelElement
import java.io.IOException
import java.util.List
import mgl.GraphModel
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IPath
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.graphiti.dt.IDiagramTypeProvider
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.IUpdateFeature
import org.eclipse.graphiti.features.context.impl.AddContext
import org.eclipse.graphiti.features.context.impl.CreateContext
import org.eclipse.graphiti.features.context.impl.UpdateContext
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.ui.services.GraphitiUi
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.transaction.TransactionalEditingDomain
import org.eclipse.graphiti.ui.internal.editor.DiagramEditorDummy
import org.eclipse.emf.transaction.util.TransactionUtil

import static extension de.jabc.cinco.meta.core.utils.MGLUtil.isReferencedModelElement

class CGraphModelTmpl extends APIUtils {
	
def doGenerateView(GraphModel me)'''
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

def doGenerateImpl(GraphModel me)'''
package «me.packageNameAPI»;

public «IF me.isIsAbstract»abstract «ENDIF»class «me.fuCName» extends «me.fqBeanImplName»  implements «CModelElement.name»
	«IF !me.allSuperTypes.empty» ,«FOR st: me.allSuperTypes SEPARATOR ","» «st.fqBeanName» «ENDFOR» «ENDIF»{
	
	private «PictogramElement.name» pe;
	private «IFeatureProvider.name» fp;
	
	«me.constructor»
	
	public «me.pictogramElementReturnType» getPictogramElement() {
		if (pe == null && eResource() != null) {
			«EObject.name» bo = this.eResource().getContents().get(0);
			if (bo instanceof «Diagram.name»)
				pe = («Diagram.name») bo;
		}
		return («me.pictogramElementReturnType») this.pe;
	}
	
	public void setPictogramElement(«PictogramElement.name» pe) {
		this.pe = pe;
	}
	
	«FOR n : MGLUtil::getContainableNodes(me).filter[!isIsAbstract && !isPrime]»
	@Override
	public «n.fqBeanName» new«n.fuName»(int x, int y) {
		return new«n.fuName»(x,y,-1,-1);
	}
	
	@Override
	public «n.fqBeanName» new«n.fuName»(«String.name» id, int x, int y, int width, int height) {
		«n.fqBeanName» obj = new«n.fuName»(x, y, width, height);
		«EcoreUtil.name».setID(obj, id);
		return obj;
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
		public «n.fqBeanName» new«n.fuName»(«EObject.name» «n.retrievePrimeReference.name», int x, int y) {
			return new«n.fuName»(«n.retrievePrimeReference.name»,x,y,-1,-1);
		}
		
		@Override
		public «n.fqBeanName» new«n.fuName»(«EObject.name» «n.retrievePrimeReference.name», int x, int y, int width, int height) {
			«AddContext.name» ac = new «AddContext.name»();
			ac.setLocation(10, 10);
			ac.setTargetContainer((«ContainerShape.name») getPictogramElement());
			ac.setNewObject(«n.retrievePrimeReference.name»);
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
	
	public «me.fqBeanName» new«me.fuName»(«String.name» path, «String.name» fileName, boolean postCreateHook) {
		«me.fqBeanName» graph = super.new«me.fuName»(path, fileName, postCreateHook);
		«Diagram.name» diagram = «Graphiti.name».getPeCreateService().createDiagram("«me.fuName»", fileName, true);
		
		«Resource.name» res = graph.eResource();
		res.getContents().add(0,diagram);
		
		«IFeatureProvider.name» fp = «GraphitiUi.name».getExtensionManager().createFeatureProvider(diagram);
		fp.link(diagram, graph);
		
		graph.save();
	
		return graph;
	}
	
	public void update() {
		«IFeatureProvider.name» fp = getFeatureProvider();
		if (fp != null) try {
			«PictogramElement.name» pe = getPictogramElement();
			if (pe != null) {
				«UpdateContext.name» uc = new «UpdateContext.name»(getPictogramElement());
				«IUpdateFeature.name» uf = fp.getUpdateFeature(uc);
				if (fp instanceof «CincoFeatureProvider.name») {
					((«CincoFeatureProvider.name») fp).executeFeature(uf, uc);
				}
			}
		} catch («NullPointerException.name» e) {
			e.printStackTrace();
			return;
		}
	}
	
	@Override
	public void delete() {
		throw new «UnsupportedOperationException.name»("Deleting a Graphmodel by api is not supported at the moment.");
	}
	
	@SuppressWarnings("restriction")
	public «IFeatureProvider.name» getFeatureProvider() {
		if (this.fp != null) try {
			«Diagram.name» diagram = getDiagram();
			if (diagram != null) {
				«IDiagramTypeProvider.name» dtp = fp.getDiagramTypeProvider();
				if (dtp.getDiagram() == null) {
					«TransactionalEditingDomain.name» editingDomain = «TransactionUtil.name».getEditingDomain(diagram);
					«DiagramEditorDummy.name» diagramEditor = new «DiagramEditorDummy.name»(dtp, editingDomain);
					dtp.init(diagram, diagramEditor.getDiagramBehavior());
				}
			}
			return this.fp;
		} catch(NullPointerException e) {
			e.printStackTrace();
		} finally {
			return this.fp;
		}
		«Diagram.name» diagram = null;
		try {
			diagram = getDiagram();
		} catch(NullPointerException ignore) {}
		if (diagram != null)
			this.fp = «GraphitiUi.name».getExtensionManager().createFeatureProvider(diagram);
		«IDiagramTypeProvider.name» dtp = «GraphitiUi.name».getExtensionManager().createDiagramTypeProvider("«me.dtpId»");
		this.fp = dtp.getFeatureProvider();
		return fp;
	}
	
	public void setFeatureProvider(«IFeatureProvider.name» provider) {
		this.fp = provider;
	}
	
	@Override
	public «Diagram.name» getDiagram() {
		«PictogramElement.name» curr = getPictogramElement();
		while (curr != null && curr.eContainer() != null)
			curr = («PictogramElement.name») curr.eContainer();
		if (curr instanceof «Connection.name») {
			return ((«Connection.name») curr).getParent();
		}
		return («Diagram.name») curr;
	}
	
	public «PictogramElement.name» fetchPictogramElement(«ModelElement.name» me) {
		«List.name»<«PictogramElement.name»> pes = «Graphiti.name».getLinkService().getPictogramElements(getDiagram(), me.getInternalElement());
		if (pes != null && pes.size() > 0 )
			return pes.get(0);
		return null;
	}
	
}
'''
	
} 