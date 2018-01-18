package de.jabc.cinco.meta.core.ge.style.generator.templates

import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import mgl.GraphModel
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import graphmodel.internal.InternalContainer
import graphmodel.internal.InternalModelElementContainer
import org.eclipse.core.runtime.IPath
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.dt.IDiagramTypeProvider
import org.eclipse.graphiti.ui.services.GraphitiUi

import static extension de.jabc.cinco.meta.core.utils.MGLUtil.hasPostCreateHook
import graphmodel.ModelElementContainer
import mgl.Node
import graphmodel.internal.InternalNode
import mgl.Edge

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
		@Override
		public «me.fqBeanName» create«me.fuName»(«InternalModelElementContainer.name» container) {
			«me.fqInternalBeanName» ime = («me.fqInternalBeanName») super.create«me.fuName»(container).getInternalElement();
			«me.fqCName» me = new «me.fqCName»();
			«EcoreUtil.name».setID(ime, me.getId()+"_INTERNAL");
			ime.setElement(me);
			return me;
		}
		«ELSEIF me instanceof Edge»
		@Override
		public «me.fqBeanName» create«me.fuName»(«InternalNode.name» source, «InternalNode.name» target) {
			«me.fqInternalBeanName» ime = («me.fqInternalBeanName») super.create«me.fuName»(source, target).getInternalElement();
			«me.fqCName» me = new «me.fqCName»();
			«EcoreUtil.name».setID(ime, me.getId()+"_INTERNAL");
			ime.setElement(me);
			return me;
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
	
	}
	'''
	
}