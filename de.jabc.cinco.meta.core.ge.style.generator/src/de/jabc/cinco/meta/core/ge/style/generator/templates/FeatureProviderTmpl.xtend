package de.jabc.cinco.meta.core.ge.style.generator.templates

import de.jabc.cinco.meta.core.ge.style.generator.runtime.addfeature.LibraryComponentAddFeature
import de.jabc.cinco.meta.core.ge.style.generator.runtime.customfeature.GraphitiCustomFeature
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoAddBendpointFeature
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoCopyFeature
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoLayoutFeature
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoMoveBendpointFeature
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoPasteFeature
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoRemoveBendpointFeature
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoUpdateFeature
import de.jabc.cinco.meta.core.ge.style.generator.runtime.provider.CincoFeatureProvider
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import de.jabc.cinco.meta.core.utils.MGLUtil
import graphmodel.internal.InternalModelElement
import graphmodel.internal.InternalNode
import mgl.GraphModel
import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.Assert
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.transaction.RecordingCommand
import org.eclipse.emf.transaction.TransactionalEditingDomain
import org.eclipse.graphiti.dt.IDiagramTypeProvider
import org.eclipse.graphiti.features.IAddFeature
import org.eclipse.graphiti.features.ICopyFeature
import org.eclipse.graphiti.features.ICreateConnectionFeature
import org.eclipse.graphiti.features.ICreateFeature
import org.eclipse.graphiti.features.IDeleteFeature
import org.eclipse.graphiti.features.IFeature
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.ILayoutFeature
import org.eclipse.graphiti.features.IMoveShapeFeature
import org.eclipse.graphiti.features.IPasteFeature
import org.eclipse.graphiti.features.IReconnectionFeature
import org.eclipse.graphiti.features.IResizeShapeFeature
import org.eclipse.graphiti.features.IUpdateFeature
import org.eclipse.graphiti.features.context.IAddContext
import org.eclipse.graphiti.features.context.IContext
import org.eclipse.graphiti.features.context.ICopyContext
import org.eclipse.graphiti.features.context.ICreateConnectionContext
import org.eclipse.graphiti.features.context.ICreateContext
import org.eclipse.graphiti.features.context.ICustomContext
import org.eclipse.graphiti.features.context.IDeleteContext
import org.eclipse.graphiti.features.context.ILayoutContext
import org.eclipse.graphiti.features.context.IMoveShapeContext
import org.eclipse.graphiti.features.context.IPasteContext
import org.eclipse.graphiti.features.context.IReconnectionContext
import org.eclipse.graphiti.features.context.IResizeShapeContext
import org.eclipse.graphiti.features.context.IUpdateContext
import org.eclipse.graphiti.features.context.impl.AddContext
import org.eclipse.graphiti.features.custom.ICustomFeature
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.ui.features.DefaultFeatureProvider
import org.eclipse.graphiti.features.context.IMoveBendpointContext
import org.eclipse.graphiti.features.context.IAddBendpointContext
import org.eclipse.graphiti.features.context.IRemoveBendpointContext
import org.eclipse.graphiti.features.IMoveBendpointFeature
import org.eclipse.graphiti.features.IAddBendpointFeature
import org.eclipse.graphiti.features.IRemoveBendpointFeature

class FeatureProviderTmpl extends APIUtils{
	
/**
 * Generates the {@link IFeatureProvider} code for the Graphmodel
 * 
 * @param gm The processed {@link GraphModel}
 */
def generateFeatureProvider(GraphModel gm)'''
package «gm.packageName»;

import «gm.packageNameCreate».*;
import «gm.packageNameAdd».*;

public class «gm.fuName»FeatureProvider extends «DefaultFeatureProvider.name» implements «CincoFeatureProvider.name»{
	
	public «gm.fuName»FeatureProvider(«IDiagramTypeProvider.name» dtp) {
		super(dtp);
	}
	
	@Override
	public «IAddFeature.name»[] getAllLibComponentAddFeatures() {
		return new «IAddFeature.name»[] {
			«FOR pn : gm.nodes.filter[isPrime]»
			«pn.addFeaturePrimeCode»
			«ENDFOR»
		};
	}
	
	@Override
	public «IAddFeature.name» getAddFeature(«IAddContext.name» context) {
		«Object.name» o =  context.getNewObject();
		if (o instanceof «IFile.name») {
			o = getGraphModel((«IFile.name») o);
			if (context instanceof «AddContext.name»)
				((«AddContext.name») context).setNewObject(o);
		}
		if (o instanceof «EObject.name») {
			«EObject.name» bo = («EObject.name») o;
			boolean sameResource = bo.eResource() != null ? bo.eResource().equals(getDiagramTypeProvider().getDiagram().eResource()) : true ;
			
			«FOR me : gm.nodes»
			if (sameResource && «internalInstanceofCheck(me,"bo")») 
				return new «gm.packageNameAdd».AddFeature«me.fuName»(this);
			«IF isPrime(me)»
			if((bo.eClass().getName().equals("«me.primeReference.primeType»")
				|| (bo.eClass().getEAllSuperTypes().stream().anyMatch(_superClass -> _superClass.getName().equals("«me.primeReference.primeType»"))))
				&& bo.eClass().getEPackage().getNsURI().equals("«me.primeReference.nsURI»")
				&& !sameResource)
				return new «LibraryComponentAddFeature.name»(this);
			«ENDIF»		
			«ENDFOR»
			
			«FOR ed : gm.edges»
			if («ed.internalInstanceofCheck("bo")»)
				return new «gm.packageNameAdd».AddFeature«ed.name»(this);
			«ENDFOR»
		}

		return super.getAddFeature(context);
	}

	private «Object.name» getGraphModel(«IFile.name» file) {
		«URI.name» fileUri = «URI.name».createPlatformResourceURI(file.getFullPath().toString(), true);
		«Resource.name» res = new «ResourceSetImpl.name»().getResource(fileUri, true);
		if (res != null) {
			for («EObject.name» o : res.getContents()) {
				if (o instanceof «graphmodel.GraphModel.name») {
					return o;
				}
			}
		}
		return null;
	}

	@Override
	public «ICreateFeature.name»[] getCreateFeatures() {
		return new «ICreateFeature.name»[] {
		«FOR me : gm.nodes.filter[!isIsAbstract] SEPARATOR ","»
			new «me.packageNameCreate».CreateFeature«me.fuName»(this)
		«ENDFOR»
		};
	}

	@Override
	public «ICreateConnectionFeature.name»[] getCreateConnectionFeatures() {
		return new «ICreateConnectionFeature.name»[] {
		«FOR e : gm.edges.filter[!isIsAbstract] SEPARATOR ","»
			new «e.packageNameCreate».CreateFeature«e.fuName»(this)	
		«ENDFOR»

		};
	}

	@Override
	public «IDeleteFeature.name» getDeleteFeature(«IDeleteContext.name» context) {
		«EObject.name» bo = («EObject.name») getBusinessObjectForPictogramElement(context.getPictogramElement());
		
		«FOR n : gm.modelElements.filter[!(it instanceof GraphModel)]»
		if («n.internalInstanceofCheck("bo")»)
			return new «n.packageNameDelete».DeleteFeature«n.fuName»(this);
		«ENDFOR»
		
		return super.getDeleteFeature(context);
	}
	
	@Override
	public «ILayoutFeature.name» getLayoutFeature(«ILayoutContext.name» context) {
		«Object.name» o = getBusinessObjectForPictogramElement(context.getPictogramElement());
		if (o instanceof «EObject.name») {
			«EObject.name» bo = («EObject.name») o;
			
			if (bo instanceof «InternalModelElement.name»){
				
					if (bo instanceof «InternalNode.name»)
						return new «CincoLayoutFeature.name»(this);
				
				«FOR e : gm.edges»
					if («e.internalInstanceofCheck("bo")»)
					    return new «e.packageNameLayout».LayoutFeature«e.fuName»(this);
				«ENDFOR»
			}
		}

		return super.getLayoutFeature(context);
	}
	
	@Override
	public «IResizeShapeFeature.name» getResizeShapeFeature(«IResizeShapeContext.name» context) {
		«Object.name» o = getBusinessObjectForPictogramElement(context.getPictogramElement());
		if (o instanceof «EObject.name») {
			«EObject.name» bo = («EObject.name») o;
			
			if (bo instanceof «InternalModelElement.name»){
				«FOR n : gm.nodes»
					if («n.internalInstanceofCheck("bo")»)
						return new «n.packageNameResize».ResizeFeature«n.fuName»(this);
				«ENDFOR»
			}
		}

		return super.getResizeShapeFeature(context);
	}
	
	@Override
	public «IMoveShapeFeature.name» getMoveShapeFeature(«IMoveShapeContext.name» context) {
		«Object.name» o = getBusinessObjectForPictogramElement(context.getPictogramElement());
		if (o instanceof «EObject.name») {
			«EObject.name» bo = («EObject.name») o;
			
			if (bo instanceof «InternalModelElement.name»){
				«FOR n : gm.nodes»
					if («n.internalInstanceofCheck("bo")»)
						return new «n.packageNameMove».MoveFeature«n.fuName»(this);
				«ENDFOR»
			}
		}

		return super.getMoveShapeFeature(context);
	}
	
		@Override
	public «IUpdateFeature.name» getUpdateFeature(«IUpdateContext.name» context) {
		«Object.name» o = getBusinessObjectForPictogramElement(context.getPictogramElement());
		if (o instanceof «EObject.name») {
			«EObject.name» bo = («EObject.name») o;
			
			if (bo instanceof «InternalModelElement.name»){
				return new «CincoUpdateFeature.name»(this);
			}
		}

		return super.getUpdateFeature(context);
	}
	


	@Override
	public «IReconnectionFeature.name» getReconnectionFeature(«IReconnectionContext.name» context) {
		«Object.name» o = getBusinessObjectForPictogramElement(context.getConnection());
		if (o instanceof «EObject.name») {
			«EObject.name» bo = («EObject.name») o;
«««			if (bo.eClass().getName().equals("Transition"))
«««				return new ReconnectTransitionFeature(this);

		}
		return super.getReconnectionFeature(context);
	}


	@Override
	public «ICustomFeature.name»[] getCustomFeatures(«ICustomContext.name» context) {
		«PictogramElement.name» pe = context.getPictogramElements()[0];
		«Object.name» o = getBusinessObjectForPictogramElement(pe);
		if (o instanceof «EObject.name») {
			«EObject.name» bo = («EObject.name») o;
			
			«FOR me : gm.modelElements»
			if («me.internalInstanceofCheck("bo")») {
				return new «ICustomFeature.name»[] {
					«FOR annotValue : MGLUtil.getAllAnnotation("contextMenuAction", me) SEPARATOR ","»
					new «GraphitiCustomFeature.name»<«me.fqBeanName»>(this,new «annotValue»())
					«ENDFOR»
				};
			}
			
			«ENDFOR»
		}
		return new «ICustomFeature.name»[] {};
	}
	
	@Override
		public «IMoveBendpointFeature.name» getMoveBendpointFeature(«IMoveBendpointContext.name» context) {
			return new «CincoMoveBendpointFeature.name»(this);
		}
		
		@Override
		public «IAddBendpointFeature.name» getAddBendpointFeature(«IAddBendpointContext.name» context) {
			return new «CincoAddBendpointFeature.name»(this);
		}
		
		@Override
		public «IRemoveBendpointFeature.name» getRemoveBendpointFeature(«IRemoveBendpointContext.name» context) {
			return new «CincoRemoveBendpointFeature.name»(this);
		}
	
	@Override
	public «ICopyFeature.name» getCopyFeature(«ICopyContext.name» context) {
		return new «CincoCopyFeature.name»(this);
	}
		
	@Override
	public «IPasteFeature.name» getPasteFeature(«IPasteContext.name» context) {
		return new «CincoPasteFeature.name»(this);
	}
	
	@Override
	public «Object.name»[] executeFeature(final «IFeature.name» f, final «IContext.name» c) {
		«TransactionalEditingDomain.name» dom = getDiagramTypeProvider().getDiagramBehavior().getEditingDomain();
		if (dom == null) 
			dom = «TransactionalEditingDomain.name».Factory.INSTANCE.createEditingDomain();
		«Assert.name».isNotNull(dom, «String.name».format("The TransactionalEditingDomain is null"));
		if (f instanceof «ICreateFeature.name») {
			final «Object.name»[] created = new Object[2];
			
			dom.getCommandStack().execute(new «RecordingCommand.name»(dom, f.getName()) {
				
				@Override
				protected void doExecute() {
					«ICreateFeature.name» cf = («ICreateFeature.name») f;
					if (cf.canCreate((«ICreateContext.name») c)) {
						«Object.name»[] result = cf.create((«ICreateContext.name») c);
						if (result.length == 2) {
							created[0] = result[0];
							created[1] = result[1];
						}
					}
				}
			});
			
			return created;
			
		} else if (f instanceof «ICreateConnectionFeature.name») {
					final «Object.name»[] created = new «Object.name»[2];
					
					dom.getCommandStack().execute(new «RecordingCommand.name»(dom, f.getName()) {
						
						@Override
						protected void doExecute() {
							«ICreateConnectionFeature.name» cf = («ICreateConnectionFeature.name») f;
							if (cf.canCreate((«ICreateConnectionContext.name») c)) {
								«Connection.name» conn = cf.create((«ICreateConnectionContext.name») c);
								if (conn != null) {
									«EObject.name» bo = conn.getLink().getBusinessObjects().get(0);
									created[0] = ((«InternalModelElement.name») bo).getElement();
									created[1] = conn;
								}
							}
						}
					});
					return created;
		} else {
			getDiagramTypeProvider().getDiagramBehavior().executeFeature(f, c);
			return null;
		}
	}
	
}
'''
	
}