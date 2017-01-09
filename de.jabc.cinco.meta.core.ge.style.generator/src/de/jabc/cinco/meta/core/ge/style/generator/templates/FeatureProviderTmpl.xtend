package de.jabc.cinco.meta.core.ge.style.generator.templates

import de.jabc.cinco.meta.core.ge.style.generator.runtime.addfeature.LibraryComponentAddFeature
import de.jabc.cinco.meta.core.ge.style.generator.runtime.provider.CincoFeatureProvider
import de.jabc.cinco.meta.core.utils.MGLUtils
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import graphmodel.ModelElement
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
import org.eclipse.graphiti.features.ICreateConnectionFeature
import org.eclipse.graphiti.features.ICreateFeature
import org.eclipse.graphiti.features.IDeleteFeature
import org.eclipse.graphiti.features.IFeature
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.ILayoutFeature
import org.eclipse.graphiti.features.IMoveShapeFeature
import org.eclipse.graphiti.features.IReconnectionFeature
import org.eclipse.graphiti.features.IResizeShapeFeature
import org.eclipse.graphiti.features.IUpdateFeature
import org.eclipse.graphiti.features.context.IAddContext
import org.eclipse.graphiti.features.context.IContext
import org.eclipse.graphiti.features.context.ICreateContext
import org.eclipse.graphiti.features.context.ICustomContext
import org.eclipse.graphiti.features.context.IDeleteContext
import org.eclipse.graphiti.features.context.ILayoutContext
import org.eclipse.graphiti.features.context.IMoveShapeContext
import org.eclipse.graphiti.features.context.IReconnectionContext
import org.eclipse.graphiti.features.context.IResizeShapeContext
import org.eclipse.graphiti.features.context.IUpdateContext
import org.eclipse.graphiti.features.context.impl.AddContext
import org.eclipse.graphiti.features.custom.ICustomFeature
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.ui.features.DefaultFeatureProvider

class FeatureProviderTmpl extends GeneratorUtils{
	
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
			if (sameResource && «instanceofCheck(me,"bo")») 
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
			if (bo.eClass().getName().equals("«ed.name»"))
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

		«FOR n : gm.nodes»
		if («n.instanceofCheck("bo")»)
			return new «n.packageNameDelete».DeleteFeature«n.fuName»(this);
		«ENDFOR»
		
«««		if (bo instanceof info.scce.cinco.product.somegraph.somegraph.SomeNode)
«««			return new DeleteSomeNodeFeature(this);
«««
«««		if (bo instanceof info.scce.cinco.product.somegraph.somegraph.Transition)
«««			return new DeleteTransitionFeature(this);

		return super.getDeleteFeature(context);
	}
	
	@Override
	public «ILayoutFeature.name» getLayoutFeature(«ILayoutContext.name» context) {
		«Object.name» o = getBusinessObjectForPictogramElement(context.getPictogramElement());
		if (o instanceof «EObject.name») {
			«EObject.name» bo = («EObject.name») o;
			if (bo instanceof «ModelElement.name»){
				«FOR n : gm.nodes»
					if («n.instanceofCheck("bo")»)
						return new «n.packageNameLayout».LayoutFeature«n.fuName»(this);
				«ENDFOR»
				«FOR e : gm.edges»
					if («e.instanceofCheck("bo")»)
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
			if (bo instanceof «ModelElement.name»){
				«FOR n : gm.nodes»
					if («n.instanceofCheck("bo")»)
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
			if (bo instanceof «ModelElement.name»){
				«FOR n : gm.nodes»
					if («n.instanceofCheck("bo")»)
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
			if (bo instanceof «ModelElement.name»){
				«FOR n : gm.nodes»
					if («n.instanceofCheck("bo")»)
						return new «n.packageNameUpdate».UpdateFeature«n.fuName»(this);
				«ENDFOR»
				«FOR e : gm.edges»
					if («e.instanceofCheck("bo")»)
						return new «e.packageNameUpdate».UpdateFeature«e.fuName»(this);
				«ENDFOR»
			}
		}

		return super.getUpdateFeature(context);
	}
	

«««	@Override
«««	public «IUpdateFeature.name» getUpdateFeature(«IUpdateContext.name» context) {
«««		«PictogramElement.name» pe = context.getPictogramElement();
«««		Object o = getBusinessObjectForPictogramElement(pe);
«««		if (o instanceof «EObject.name») {
«««			«EObject.name» bo = («EObject.name») o;
«««			if ( (bo instanceof graphmodel.ModelElement) || bo instanceof graphmodel.GraphModel)
«««				return new «CincoUpdateFeature.name»(this);
««««««			if (bo.eClass().getName().equals("SomeNode"))
««««««				return new UpdateSomeNodeFeature(this);
««««««
««««««			if (bo.eClass().getName().equals("Transition"))
««««««				return new UpdateTransitionFeature(this);
«««
«««		}
«««		return super.getUpdateFeature(context);
«««	}

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

«««	@Override
«««	public «IMoveShapeFeature.name» getMoveShapeFeature(«IMoveShapeContext.name» context) {
«««		«Object.name» o = getBusinessObjectForPictogramElement(context.getShape());
«««		if (o instanceof «EObject.name») {
«««			«EObject.name» bo = («EObject.name») o;
«««			if (bo instanceof «Node.name»)
«««				return new «CincoMoveShapeFeature.name»(this);
««««««			if (bo.eClass().getName().equals("SomeNode"))
««««««				return new MoveSomeNodeFeature(this);
«««
«««		}
«««		return super.getMoveShapeFeature(context);
«««	}

«««	@Override
«««	public «ILayoutFeature.name» getLayoutFeature(«ILayoutContext.name» context) {
«««		«Object.name» o = getBusinessObjectForPictogramElement(context.getPictogramElement());
«««		if (o instanceof «EObject.name») {
«««			«EObject.name» bo = («EObject.name») o;
«««			if (bo instanceof «ModelElement.name»)
«««				return new «CincoLayoutFeature.name»(this);
««««««			if (bo.eClass().getName().equals("SomeNode"))
««««««				return new LayoutSomeNodeFeature(this);
««««««
««««««			if (bo.eClass().getName().equals("Transition"))
««««««				return new LayoutTransitionFeature(this);
«««
«««		}
«««		return super.getLayoutFeature(context);
«««	}

«««	@Override
«««	public «IResizeShapeFeature.name» getResizeShapeFeature(«IResizeShapeContext.name» context) {
«««		«Object.name» o = getBusinessObjectForPictogramElement(context.getPictogramElement());
«««		if (o instanceof «EObject.name») {
«««			«EObject.name» bo = («EObject.name») o;
«««			if (bo instanceof «ModelElement.name»)
«««				return new «CincoResizeFeature.name»(this);
««««««			if (bo.eClass().getName().equals("SomeNode"))
««««««				return new ResizeSomeNodeFeature(this);
««««««
««««««			if (bo.eClass().getName().equals("SomeGraph"))
««««««				return new ResizeSomeGraphFeature(this);
«««		}
«««		return super.getResizeShapeFeature(context);
«««	}

«««	@Override
«««	public ICopyFeature getCopyFeature(ICopyContext context) {
«««		return new «gm.fuName»CopyFeature(this);
«««	}
«««	
«««	@Override
«««	public IPasteFeature getPasteFeature(IPasteContext context) {
«««		return new «gm.fuName»PasteFeature(this);
«««	}

	@Override
	public «ICustomFeature.name»[] getCustomFeatures(«ICustomContext.name» context) {
		«PictogramElement.name» pe = context.getPictogramElements()[0];
		«Object.name» o = getBusinessObjectForPictogramElement(pe);
		if (o instanceof «EObject.name») {
			«EObject.name» bo = («EObject.name») o;
			«FOR me : gm.modelElements»
			if («me.instanceofCheck("bo")») {
				return new «ICustomFeature.name»[] {
					«FOR annotValue : MGLUtils.getAllAnnotation("contextMenuAction", me) SEPARATOR ","»
					new «annotValue»(this)
					«ENDFOR»
				};
			}
			
			«ENDFOR»
		}
		return new «ICustomFeature.name»[] {};
	}
	
	@Override
	public «Object.name»[] executeFeature(final «IFeature.name» f, final «IContext.name» c) {
		if (f instanceof «ICreateFeature.name») {
			final «Object.name»[] created = new Object[2];
			
			«TransactionalEditingDomain.name» dom = getDiagramTypeProvider().getDiagramBehavior().getEditingDomain();
			«Assert.name».isNotNull(dom, «String.name».format("The TransactionalEditingDomain is null"));
			
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
		} else {
			getDiagramTypeProvider().getDiagramBehavior().executeFeature(f, c);
			return null;
		}
	}
	
}
'''
	
}