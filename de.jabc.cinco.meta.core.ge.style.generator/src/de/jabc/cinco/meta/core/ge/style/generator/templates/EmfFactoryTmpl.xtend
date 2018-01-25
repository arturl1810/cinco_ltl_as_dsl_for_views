package de.jabc.cinco.meta.core.ge.style.generator.templates

import de.jabc.cinco.meta.core.ge.style.generator.runtime.api.CGraphModel
import de.jabc.cinco.meta.core.ge.style.generator.runtime.api.CModelElement
import de.jabc.cinco.meta.core.ge.style.generator.runtime.provider.CincoFeatureProvider
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import graphmodel.internal.InternalModelElementContainer
import graphmodel.internal.InternalNode
import mgl.Edge
import mgl.GraphModel
import mgl.Node
import org.eclipse.core.runtime.IPath
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.graphiti.dt.IDiagramTypeProvider
import org.eclipse.graphiti.features.IAddFeature
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.impl.AddContext
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.ui.services.GraphitiUi

import static extension de.jabc.cinco.meta.core.utils.MGLUtil.hasPostCreateHook
import de.jabc.cinco.meta.core.ge.style.generator.runtime.api.CNode
import graphmodel.internal.InternalEdge
import org.eclipse.graphiti.mm.pictograms.Anchor
import org.eclipse.graphiti.mm.pictograms.AnchorContainer
import org.eclipse.graphiti.features.context.impl.AddConnectionContext
import de.jabc.cinco.meta.core.utils.MGLUtil
import de.jabc.cinco.meta.runtime.xapi.GraphModelExtension
import graphmodel.internal.InternalGraphModel
import graphmodel.internal.InternalModelElement

class EmfFactoryTmpl {

	extension APIUtils = new APIUtils()
	
	def generateFactory(GraphModel gm) '''
	package «gm.packageName»;
	
	public class «gm.fuName»Factory extends «gm.fqFactoryName» {
		
		public static «gm.fuName»Factory eINSTANCE = new «gm.fuName»Factory();
		
		@Override
		public «EObject.name» create(«EClass.name» eClass) {
			«FOR me : gm.modelElements.filter[!isIsAbstract]»
			if (eClass.getName().equals("«me.name»"))
				return create«me.fuName»();
			«ENDFOR»
			return super.create(eClass);
		}
		
		«FOR me : gm.modelElements.filter[!isIsAbstract]»
		@Override
		public «me.fqBeanName» create«me.fuName»() {
			«me.fqInternalBeanName» ime = («me.fqInternalBeanName») super.create«me.fuName»().getInternalElement();
			«me.fqCName» me = new «me.fqCName»();
			«EcoreUtil.name».setID(ime, me.getId()+"_INTERNAL");
			ime.setElement(me);
			return me;
		}
		
		«IF me instanceof Node»
			«IF me.prime»
				public «me.fqBeanName» create«me.fuName»(«String.name» libraryComponentUID, «InternalModelElementContainer.name» container, int x, int y, int width, int height) {
			«ELSE»
				public «me.fqBeanName» create«me.fuName»(«InternalModelElementContainer.name» container, int x, int y, int width, int height) {
			«ENDIF»
			«me.fqInternalBeanName» ime = («me.fqInternalBeanName») create«me.fuName»().getInternalElement();
			container.getModelElements().add(ime);
			ime.setX(x);
			ime.setY(y);
			ime.setWidth(width);
			ime.setHeight(height);
			«IF me.prime»
			ime.setLibraryComponentUID(libraryComponentUID);
			«ENDIF»
			addNode(container, ime);
			ime.getElement().update();
			«IF MGLUtil::hasPostCreateHook(me)»
				«me.packageName».«me.graphModel.fuName»Factory.eINSTANCE.postCreates((«me.fqBeanName») ime.getElement());
			«ENDIF»
			return («me.fqBeanName») ime.getElement();
		}
		«ELSEIF me instanceof Edge»
		@Override
		public «me.fqBeanName» create«me.fuName»(«InternalNode.name» source, «InternalNode.name» target) {
			«me.fqInternalBeanName» ime = («me.fqInternalBeanName») create«me.fuName»().getInternalElement();
			ime.set_sourceElement(source);
			ime.set_targetElement(target);
			«InternalModelElementContainer.name» container = new «GraphModelExtension.name»().getCommonContainer(source.getRootElement(), source, target);
			container.getModelElements().add(ime);
			addEdge(source, target, ime);
			ime.getElement().update();
			«IF MGLUtil::hasPostCreateHook(me)»
				«me.packageName».«me.graphModel.fuName»Factory.eINSTANCE.postCreates((«me.fqBeanName») ime.getElement());
			«ENDIF»
			return («me.fqBeanName») ime.getElement();
		}
		«ENDIF»
		«ENDFOR»
		
		public «gm.fqBeanName» create«gm.fuName»(«String.name» path, «String.name» fileName) {
			«IPath.name» filePath = new «Path.name»(path).append(fileName).addFileExtension("«gm.fileExtension»");
			«URI.name» uri = «URI.name».createPlatformResourceURI(filePath.toOSString() ,true);
			«Resource.name» res = new «ResourceSetImpl.name»().createResource(uri);
			«String.name» fNameWithExt = (fileName.contains(".")) ? fileName : fileName.concat(".«gm.fileExtension»");
			«String.name» dName = fNameWithExt.split("\\.")[0];
			
			«gm.fqCName» model = («gm.fqCName») create«gm.fuName»();
			«Diagram.name» diagram = «Graphiti.name».getPeService().createDiagram("«gm.fuName»", dName, true);
			
			res.getContents().add(diagram);
			res.getContents().add(model.getInternalElement());
			model.setPictogramElement(diagram);
			
			«IDiagramTypeProvider.name» dtp = «GraphitiUi.name».getExtensionManager().createDiagramTypeProvider(diagram, "«gm.dtpId»");
			model.setFeatureProvider(dtp.getFeatureProvider());
			dtp.getFeatureProvider().link(diagram, model.getInternalElement());
			
			«IF gm.hasPostCreateHook»
			postCreates(model);
			«ENDIF»
			
			try {
				res.save(null);
			} catch (java.io.IOException e) {
				e.printStackTrace();
			}
			return model;
		}
	
		private «PictogramElement.name» addNode(«InternalModelElementContainer.name» parent, «InternalNode.name» node) {
			«AddContext.name» ac = new «AddContext.name»();
			ac.setNewObject(node);
			ac.setLocation(node.getX(), node.getY());
			ac.setSize(node.getWidth(), node.getHeight());
			ac.setTargetContainer(((«CModelElement.name») parent.getElement()).getPictogramElement());
			
			«IFeatureProvider.name» fp =
							(parent instanceof «InternalGraphModel.name») 
							? ((«CGraphModel.name») parent.getElement()).getFeatureProvider()
							: ((«CGraphModel.name») ((«InternalModelElement.name») parent).getRootElement().getElement()).getFeatureProvider();
			«IAddFeature.name» af = fp.getAddFeature(ac);
			if (fp instanceof «CincoFeatureProvider.name») {
				if (af.canAdd(ac)) {
					return af.add(ac);
				}
			}
			return null;
		}
	
	private «PictogramElement.name» addEdge(«InternalNode.name» source, «InternalNode.name» target, «InternalEdge.name» edge) {
		«PictogramElement.name» sourcePE = ((«CNode.name») source.getElement()).getPictogramElement();
		«PictogramElement.name» targetPE = ((«CNode.name») target.getElement()).getPictogramElement();
		
		«Anchor.name» sAnchor = ((«AnchorContainer.name») sourcePE).getAnchors().get(0);
		«Anchor.name» tAnchor = ((«AnchorContainer.name») targetPE).getAnchors().get(0);
		
		«AddConnectionContext.name» acc = new «AddConnectionContext.name»(sAnchor, tAnchor);
		acc.setNewObject(edge);
		
		«IFeatureProvider.name» fp = ((«CGraphModel.name») source.getRootElement().getElement()).getFeatureProvider();
		«IAddFeature.name» af = fp.getAddFeature(acc);
		if (fp instanceof «CincoFeatureProvider.name») {
			if (af.canAdd(acc)) {
				return af.add(acc);
			}
		}
		return null;
	}
	
	}
	'''
	
}