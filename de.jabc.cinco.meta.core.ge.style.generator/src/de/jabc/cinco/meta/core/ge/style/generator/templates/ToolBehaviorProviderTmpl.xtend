package de.jabc.cinco.meta.core.ge.style.generator.templates

import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
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
import org.eclipse.graphiti.features.custom.ICustomFeature
import org.eclipse.graphiti.mm.pictograms.Anchor
import org.eclipse.graphiti.mm.pictograms.AnchorContainer
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.palette.IPaletteCompartmentEntry
import org.eclipse.graphiti.palette.impl.ConnectionCreationToolEntry
import org.eclipse.graphiti.palette.impl.ObjectCreationToolEntry
import org.eclipse.graphiti.palette.impl.PaletteCompartmentEntry
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.tb.ContextButtonEntry
import org.eclipse.graphiti.tb.DefaultToolBehaviorProvider
import org.eclipse.graphiti.tb.IContextButtonPadData

import static extension de.jabc.cinco.meta.core.utils.CincoUtil.*
import graphmodel.internal.InternalModelElement
import graphmodel.internal.InternalGraphModel
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoDeleteFeature

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
	public org.eclipse.graphiti.tb.IDecorator[] getDecorators(org.eclipse.graphiti.mm.pictograms.PictogramElement pe) {
		return de.jabc.cinco.meta.core.ui.highlight.DecoratorRegistry.complementDecorators(pe, super.getDecorators(pe));
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
		«"bo".toNonInternalElement»
		
		«FOR me : gm.modelElements.filter[booleanWriteMethodCallDoubleClick]»
			if («me.instanceofCheck("bo")») 
				«me.writeMethodCallDoubleClick»
		«ENDFOR»
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
		/**
		 * This is a workaround to solve the delete problem:
		 * On one hand side, allowing the execute method for all features leads to the double undo behavior. The user has to push "Ctrl+Z" two time to undo a change.
		 * On the other hand side, omitting the execute method for the delete feature leads to the dangling business object problem: The graphical representation is
		 * deleted, but the business object stays in the graphmodel.
		 */
		if (!(f instanceof «CincoDeleteFeature.name»))
			return;
		«TransactionalEditingDomain.name» _dom = getDiagramTypeProvider().getDiagramBehavior().getEditingDomain();
		_dom.getCommandStack().execute(new «RecordingCommand.name»(_dom) {
		
		
			@Override
			protected void doExecute() {
			}
		});
	}
}
'''
	
}