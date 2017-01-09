package de.jabc.cinco.meta.core.ge.style.generator.templates

<<<<<<< Updated upstream
import de.jabc.cinco.meta.core.ge.style.generator.runtime.createfeature.CincoCreateFeature
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.GeneratorUtils
=======
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils;
import de.jabc.cinco.meta.core.ge.style.model.createfeature.CincoCreateFeature
import de.jabc.cinco.meta.core.utils.CincoUtils
>>>>>>> Stashed changes
import graphicalgraphmodel.CModelElementContainer
import graphmodel.ModelElementContainer
import java.util.ArrayList
import java.util.List
import mgl.Edge
import mgl.GraphModel
import mgl.Node
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.transaction.RecordingCommand
import org.eclipse.emf.transaction.TransactionalEditingDomain
import org.eclipse.graphiti.IExecutionInfo
import org.eclipse.graphiti.dt.IDiagramTypeProvider
import org.eclipse.graphiti.features.ICreateConnectionFeature
import org.eclipse.graphiti.features.ICreateFeature
import org.eclipse.graphiti.features.IFeature
import org.eclipse.graphiti.features.context.IContext
import org.eclipse.graphiti.features.context.IDoubleClickContext
import org.eclipse.graphiti.features.context.IPictogramElementContext
import org.eclipse.graphiti.features.context.impl.CreateConnectionContext
import org.eclipse.graphiti.features.context.impl.MoveShapeContext
import org.eclipse.graphiti.features.context.impl.ResizeShapeContext
import org.eclipse.graphiti.features.custom.ICustomFeature
import org.eclipse.graphiti.mm.pictograms.Anchor
import org.eclipse.graphiti.mm.pictograms.AnchorContainer
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.palette.IPaletteCompartmentEntry
import org.eclipse.graphiti.palette.impl.ConnectionCreationToolEntry
import org.eclipse.graphiti.palette.impl.ObjectCreationToolEntry
import org.eclipse.graphiti.palette.impl.PaletteCompartmentEntry
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.tb.ContextButtonEntry
import org.eclipse.graphiti.tb.DefaultToolBehaviorProvider
import org.eclipse.graphiti.tb.IContextButtonPadData

import static extension de.jabc.cinco.meta.core.utils.CincoUtils.*

class ToolBehaviorProviderTmpl extends GeneratorUtils{
	
/**
 *  Generates the Class 'LayoutUtils' for the graphmodel gm
 * @param gm : GraphModel
 */
def generateToolBehaviorProvider(GraphModel gm)

'''package «gm.packageName»;

public class «gm.fuName»ToolBehaviorProvider extends «DefaultToolBehaviorProvider.name» {

	public «gm.fuName»ToolBehaviorProvider(«IDiagramTypeProvider.name» diagramTypeProvider) {
		super(diagramTypeProvider);
	}

	@Override
	public «IContextButtonPadData.name» getContextButtonPad(
			«IPictogramElementContext.name» context) {
		
		«IContextButtonPadData.name» data = super.getContextButtonPad(context);
		«PictogramElement.name» pe = context.getPictogramElement();
		

		setGenericContextButtons(data, pe, CONTEXT_BUTTON_DELETE | CONTEXT_BUTTON_UPDATE);
		
		«CreateConnectionContext.name» ccc = new «CreateConnectionContext.name»();
		ccc.setSourcePictogramElement(pe);
		«Anchor.name» anchor = null;
		if (pe instanceof «Anchor.name») {
			anchor = («Anchor.name») pe;
		} else if (pe instanceof «AnchorContainer.name») {
			anchor = «Graphiti.name».getPeService().getChopboxAnchor((«AnchorContainer.name») pe);
		}
		ccc.setSourceAnchor(anchor);
		
		«ContextButtonEntry.name» contextButtonEntry = new «ContextButtonEntry.name»(null, context);
		contextButtonEntry.setText("Create connection");
		contextButtonEntry.setIconId("_Connection.gif");
		
		«ICreateConnectionFeature.name»[] ccf = getFeatureProvider().getCreateConnectionFeatures();
		for («ICreateConnectionFeature.name» f : ccf) {
			if (f.isAvailable(ccc) && f.canStartConnection(ccc)) {
				contextButtonEntry.addDragAndDropFeature(f);
			}
		}
		
		if (contextButtonEntry.getDragAndDropFeatures().size() > 0) {
			data.getDomainSpecificContextButtons().add(contextButtonEntry);
		}
		
		return data;
	}

	@Override
	public «IPaletteCompartmentEntry.name»[] getPalette() {
		«List.name»<«IPaletteCompartmentEntry.name»> palette = new «ArrayList.name»<>();
		«IPaletteCompartmentEntry.name»[] p = super.getPalette();
		/**for («IPaletteCompartmentEntry.name» compartment : p) {
			if (!compartment.getLabel().equals("Connections")) {
				palette.add(compartment);
			}
		}**/	

		«ICreateFeature.name» cf = null;
		«ICreateConnectionFeature.name» ccf = null;
		«ObjectCreationToolEntry.name» objectCreationToolEntry = null;
		«ConnectionCreationToolEntry.name» connectionCreationToolEntry = null;
		«PaletteCompartmentEntry.name» compartmentEntry = null;
		«var paletteNamesMap = gm.paletteGroupsMap»
		«FOR paletteName : paletteNamesMap.keySet»
		«IF !gm.paletteGroupsMap.get(paletteName).empty»
		compartmentEntry = new «PaletteCompartmentEntry.name»("«paletteName»", null);
		palette.add(compartmentEntry);
		«FOR me : gm.paletteGroupsMap.get(paletteName)»
		«IF me instanceof Node»
		cf = new «me.packageNameCreate».CreateFeature«me.fuName»(getFeatureProvider());

		objectCreationToolEntry = new «ObjectCreationToolEntry.name»(
			cf.getCreateName(),
			cf.getCreateDescription(),
			cf.getCreateImageId(),
			cf.getCreateLargeImageId(), 
			cf);
		
		compartmentEntry.addToolEntry(objectCreationToolEntry);
		«ELSEIF me instanceof Edge»
		ccf = new «me.packageNameCreate».CreateFeature«me.fuName»(getFeatureProvider());

		connectionCreationToolEntry = new «ConnectionCreationToolEntry.name»(
		ccf.getCreateName(),
		ccf.getCreateDescription(),
		ccf.getCreateImageId(),
		ccf.getCreateLargeImageId());

		compartmentEntry.addToolEntry(connectionCreationToolEntry);
		«ENDIF»
		«ENDFOR»
		«ENDIF»
		«ENDFOR»
		
	
		return palette.toArray(new «IPaletteCompartmentEntry.name»[palette.size()]);
	}

	@Override
	public boolean equalsBusinessObjects(«Object.name» o1, «Object.name» o2) {
		if (o1 != null)
			return o1.equals(o2);
		else return o2 == null;
	}
	
	@Override
	public «ICustomFeature.name» getDoubleClickFeature(«IDoubleClickContext.name» context) {
		«PictogramElement.name»[] pes = context.getPictogramElements();
		if (! (pes != null && pes.length == 1 && pes[0].getLink() != null) ) {
			return super.getDoubleClickFeature(context);
		}
		«Object.name» bo = pes[0].getLink().getBusinessObjects().get(0);
		return super.getDoubleClickFeature(context);
	}

	@Override
	public «PictogramElement.name» getSelection(«PictogramElement.name» originalPe, «PictogramElement.name»[] oldSelection) {
		«EObject.name» bo = «Graphiti.name».getLinkService().getBusinessObjectForLinkedPictogramElement(originalPe);
		«FOR me : gm.modelElements.filter[isSelectDisabled]»
		if («instanceofCheck(me, "bo")»)
			return getDiagramTypeProvider().getDiagram();
		«ENDFOR»
		return super.getSelection(originalPe, oldSelection);
	}
	
	@Override
	public void postExecute(«IExecutionInfo.name» executionInfo) {
		«IFeature.name» f = executionInfo.getExecutionList()[0].getFeature();
		«IContext.name» c = executionInfo.getExecutionList()[0].getContext();
		
		«TransactionalEditingDomain.name» _dom = getDiagramTypeProvider().getDiagramBehavior().getEditingDomain();
		_dom.getCommandStack().execute(new «RecordingCommand.name»(_dom) {
		
		
			@Override
			protected void doExecute() {
				«FOR n : gm.modelElements»
				«IF n instanceof Node»
				«IF booleanWriteMethodCallPostCreate(n)»
				if(f instanceof  «packageNameCreate(n)».CreateFeature«n.fuName»)
				{
					graphmodel.ModelElement modelCreate = ((«CincoCreateFeature.name») f).getModelElement();
					«writeMethodCallPostCreate(n)»
				}
				«ENDIF»
				«ENDIF»
				«IF n instanceof Edge»
				«IF booleanWriteMethodCallPostCreate(n)»
				if(f instanceof «packageNameCreate(n)».CreateFeature«n.fuName»)
				{
					graphmodel.ModelElement modelCreate = ((«CincoCreateFeature.name») f).getModelElement();
					«writeMethodCallPostCreate(n)»
				}
				«ENDIF»
				«ENDIF»
				«IF booleanWriteMethodCallPostMove(n)»
				if (c instanceof «MoveShapeContext.name»)
				{
					«Diagram.name» diagram = f.getFeatureProvider().getDiagramTypeProvider().getDiagram();
					int x = ((«MoveShapeContext.name») c).getX();
					int y = ((«MoveShapeContext.name») c).getY();
					int deltaX = ((«MoveShapeContext.name») c).getDeltaX();
					int deltaY = ((«MoveShapeContext.name») c).getDeltaY();
					«ContainerShape.name» sourceShape = ((«MoveShapeContext.name») c).getSourceContainer();
					«ContainerShape.name» targetShape = ((«MoveShapeContext.name») c).getTargetContainer();
					
					«EObject.name»[] sourceModel = «Graphiti.name».getLinkService().getAllBusinessObjectsForLinkedPictogramElement(sourceShape);
					«EObject.name»[] targetModel = «Graphiti.name».getLinkService().getAllBusinessObjectsForLinkedPictogramElement(targetShape);
					info.scce.cinco.product.«gm.name.toLowerCase».api.c«gm.name.toLowerCase».C«gm.name» containerGraph = info.scce.cinco.product.«gm.name.toLowerCase».graphiti.«gm.name»Wrapper.wrapGraphModel(((«ModelElementContainer.name»)sourceModel[0]).getModelElements().get(0).getRootElement(), diagram);
					«CModelElementContainer.name» CSource = containerGraph.findCModelElementContainer((«ModelElementContainer.name»)sourceModel[0]);
					«CModelElementContainer.name» CTarget = containerGraph.findCModelElementContainer((«ModelElementContainer.name»)targetModel[0]);
					
					«PictogramElement.name» shape = ((«MoveShapeContext.name»)c).getPictogramElement();
					«EObject.name»[] modelMove = «Graphiti.name».getLinkService().getAllBusinessObjectsForLinkedPictogramElement(shape);
					info.scce.cinco.product.«gm.name.toLowerCase».api.c«gm.name.toLowerCase».C«gm.name» graph = info.scce.cinco.product.«gm.name.toLowerCase».graphiti.«gm.name»Wrapper.wrapGraphModel(((«n.fqBeanName»)modelMove[0]).getRootElement(), diagram);
					info.scce.cinco.product.«gm.name.toLowerCase».api.c«gm.name.toLowerCase».C«n.name» «n.name.toLowerCase» = graph.findC«n.name»((«n.fqBeanName»)modelMove[0]);
					«writeMethodCallPostMove(n)»
				}
				«ENDIF»
				«IF booleanWriteMethodCallPostResize(n)» 
				if (c instanceof «ResizeShapeContext.name»)
				{
					int height = ((«ResizeShapeContext.name») c).getHeight();
					int width = ((«ResizeShapeContext.name») c).getWidth();
					int direction = ((«ResizeShapeContext.name») c).getDirection();
					
					«PictogramElement.name» shape = ((«ResizeShapeContext.name»)c).getPictogramElement();
					«EObject.name»[] modelResize = «Graphiti.name».getLinkService().getAllBusinessObjectsForLinkedPictogramElement(shape);
					«Diagram.name» diagram = f.getFeatureProvider().getDiagramTypeProvider().getDiagram();
					info.scce.cinco.product.«gm.name.toLowerCase».api.c«gm.name.toLowerCase».C«gm.name» graph = info.scce.cinco.product.«gm.name.toLowerCase».graphiti.«gm.name»Wrapper.wrapGraphModel(((«n.fqBeanName»)modelResize[0]).getRootElement(), diagram);
					info.scce.cinco.product.«gm.name.toLowerCase».api.c«gm.name.toLowerCase».C«n.name» «n.name.toLowerCase» = graph.findC«n.name»((«n.fqBeanName»)modelResize[0]);
					«writeMethodCallPostResize(n)»
				}
				«ENDIF»
	«««		«IF booleanWriteMethodCallPostSelect(n)»
	«««		if(c instanceof SelectShapeContext)
	«««		{
	«««			graphmodel.ModelElement modelSelect = ((de.jabc.cinco.meta.core.ge.style.model.createfeature.CincoCreateFeature) f).getModelElement();
	«««			«writeMethodCallPostSelect(n)»
	«««		}
	«««		«ENDIF»
			«ENDFOR»
			}
		});
	}
}
'''
	
}