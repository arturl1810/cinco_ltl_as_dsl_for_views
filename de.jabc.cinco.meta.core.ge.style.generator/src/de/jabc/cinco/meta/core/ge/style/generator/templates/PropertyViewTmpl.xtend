package de.jabc.cinco.meta.core.ge.style.generator.templates

import mgl.GraphModel
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.GeneratorUtils
import org.eclipse.ui.ISelectionListener
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import de.jabc.cinco.meta.core.ui.properties.CincoPropertyView
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.ui.IWorkbenchPart
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.IStructuredSelection

import static extension de.jabc.cinco.meta.core.utils.CincoUtils.* import mgl.UserDefinedType
import mgl.Attribute
import org.eclipse.emf.ecore.EObject
import org.eclipse.gef.GraphicalEditPart
import org.eclipse.graphiti.ui.editor.DiagramBehavior
import org.eclipse.graphiti.mm.pictograms.ConnectionDecorator
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.ui.platform.GraphitiShapeEditPart
import org.eclipse.graphiti.ui.platform.GraphitiConnectionEditPart
import org.eclipse.graphiti.platform.IDiagramBehavior
import de.jabc.cinco.meta.core.ge.style.generator.graphiti.utils.CincoGraphitiUtils

class PropertyViewTmpl extends GeneratorUtils {
	
def generatePropertyView(GraphModel gm)'''
package «gm.packageName».property.view;


public class «gm.fuName»PropertyView implements «ISelectionListener.name» {

	private «PictogramElement.name» lastSelected;
	private static «ISelectionListener.name» listener;

	public static void initEStructuralFeatureInformation(){

		if (listener == null) {
			listener = new «gm.fuName»PropertyView();
			«CincoPropertyView.name».addSelectionListener(listener);
		}

		«CincoPropertyView.name».init_EStructuralFeatures(«gm.beanPackage».impl.«gm.fuName»Impl.class, 
			new «EStructuralFeature.name»[] {
			«FOR attr : gm.attributes SEPARATOR ","»
				«gm.beanPackage».«gm.name.toLowerCase.toFirstUpper»Package.eINSTANCE.get«gm.fuName»_«attr.name.toFirstUpper»()
			«ENDFOR»
			}
		);
		
		«FOR n : gm.nodes»
		«CincoPropertyView.name».init_EStructuralFeatures(«n.beanPackage».impl.«n.fuName»Impl.class, 
			new «EStructuralFeature.name»[] {
			«FOR attr : n.attributes.filter[!isAttributeHidden] SEPARATOR ","»
				«gm.beanPackage».«gm.name.toLowerCase.toFirstUpper»Package.eINSTANCE.get«n.fuName»_«attr.name.toFirstUpper»()
			«ENDFOR»
			}
		);
		«ENDFOR»
		
		«FOR e : gm.edges»
		«CincoPropertyView.name».init_EStructuralFeatures(«e.beanPackage».impl.«e.fuName»Impl.class, 
			new «EStructuralFeature.name»[] {
			«FOR attr : e.attributes.filter[!isAttributeHidden] SEPARATOR ","»
				«gm.beanPackage».«gm.name.toLowerCase.toFirstUpper»Package.eINSTANCE.get«e.fuName»_«attr.name.toFirstUpper»()
			«ENDFOR»
			}
		);
		«ENDFOR»

		«FOR t : gm.types.filter[t | t instanceof UserDefinedType].map[t | t as UserDefinedType]»
		«CincoPropertyView.name».init_EStructuralFeatures(«t.beanPackage».impl.«t.fuName»Impl.class, 
			new «EStructuralFeature.name»[] {
			«FOR attr : t.attributes.filter[!isAttributeHidden] SEPARATOR ","»
				«gm.beanPackage».«gm.name.toLowerCase.toFirstUpper»Package.eINSTANCE.get«t.fuName»_«attr.name.toFirstUpper»()
			«ENDFOR»
			}
		);
		«ENDFOR»

		«CincoPropertyView.name».init_MultiLineAttributes(new «EStructuralFeature.name»[] {
		«FOR attr : gm.allModelAttributes.filter[isAttributeMultiLine] SEPARATOR ","»
			«gm.beanPackage».«gm.name.toLowerCase.toFirstUpper»Package.eINSTANCE.get«attr.modelElement.fuName»_«attr.name.toFirstUpper»()
		«ENDFOR»			
		});

		«CincoPropertyView.name».init_ReadOnlyAttributes(new «EStructuralFeature.name»[] {
		«FOR attr : gm.allModelAttributes.filter[isAttributeReadOnly] SEPARATOR ","»
			«gm.beanPackage».«gm.name.toLowerCase.toFirstUpper»Package.eINSTANCE.get«attr.modelElement.fuName»_«attr.name.toFirstUpper»()
		«ENDFOR»
		});
	}
	

	@Override
	public void selectionChanged(«IWorkbenchPart.name» part, «ISelection.name» selection) {
		if (isStructuredSelection(selection)) {
			«Object.name» element = ((«IStructuredSelection.name») selection).getFirstElement();
			«PictogramElement.name» pe = null;
			if (element instanceof «GraphicalEditPart.name»)
				pe = getPictogramElement(element);
			
			«IDiagramBehavior.name» diagramBehavior = «CincoGraphitiUtils.name».getDiagramBehavior(pe);
			if (diagramBehavior instanceof «DiagramBehavior.name») {
				«DiagramBehavior.name» db = («DiagramBehavior.name») diagramBehavior;		
				«EObject.name» bo = getBusinessObject(pe);
			

				if (pe instanceof «ConnectionDecorator.name» && !pe.equals(lastSelected)) {
					«Connection.name» connection = ((«ConnectionDecorator.name») pe).getConnection();
				
					lastSelected = pe;
					db.getDiagramContainer().selectPictogramElements(new «PictogramElement.name»[] {
						pe, connection
					});
				}
			}
			lastSelected = pe;
		}
		
	}


	private «EObject.name» getBusinessObject(«PictogramElement.name» pe) {
		return «Graphiti.name».getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
	}

	private «PictogramElement.name» getPictogramElement(«Object.name» element) {
		if (element instanceof «GraphitiShapeEditPart.name») 
			return ((«GraphitiShapeEditPart.name») element).getPictogramElement();
		
		if (element instanceof «GraphitiConnectionEditPart.name»)
			return ((«GraphitiConnectionEditPart.name») element).getPictogramElement();
		
		return null;
	}

	private boolean isStructuredSelection(«ISelection.name» selection) {
		return selection instanceof «IStructuredSelection.name»;
	}
	
}

'''
}